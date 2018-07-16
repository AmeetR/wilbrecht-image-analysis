# Copyright 2012-2017 Techila Technologies Ltd.

import ctypes
import cPickle
import marshal
import os
import random
import re
import socket
import struct
import sys
import time
import types

class TechilaInterconnectException(Exception):
    pass

class TechilaSemaphoreException(Exception):
    pass

class TechilaSemaphoreTimeoutException(Exception):
    pass


class Singleton(type):
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]

class TechilaSocket(object):
    __metaclass__ = Singleton

    def __init__(self):
        fulljobid = long(os.getenv('TECHILA_JOBID'))
        myjobid = int(os.getenv('TECHILA_JOBID_IN_PROJECT'))
        port = os.getenv('TECHILA_ICPORT')
        jobcount = os.getenv('TECHILA_JOBCOUNT')

        if myjobid is None or port is None:
            raise TechilaInterconnectException('Worker-to-Worker communication not supported. Probably all the required components are not installed into Techila environment.')

        self.fulljobid = long(fulljobid)
        self.myjobid = int(myjobid)
        self.port = int(port)
        self.jobcount = int(jobcount)
        self.socket = None

    def connect(self):
        if self.socket is None:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(('localhost', self.port))
            self.socket = s

    def disconnect(self):
        if self.socket is not None:
            self.socket.close()

        self.socket = None

    def _read_data(self, datalen):
        received = 0
        data = None
        while True:
            bs = datalen - received

            if bs <= 0:
                break

            if bs > 65536:
                bs = 65536

            tmpdata = self.socket.recv(bs)
            l = len(tmpdata)

            received += l

            if data is None:
                data = tmpdata
            else:
                data += tmpdata

        return data

    def _read_int(self):
        buf = self._read_data(4)
        value = int(struct.unpack('!i', buf)[0])
        return value

    def _read_short(self):
        buf = self._read_data(2)
        value = int(struct.unpack('!h', buf)[0])
        return value

    def _fail(self):
        self.disconnect()

class TechilaSemaphore(object):
    """Techila Semaphore."""

    SEMAPHORELOCALREQ = 0x0501L
    SEMAPHORELOCALREL = 0x0502L
    SEMAPHOREGLOBALREQ = 0x0503L
    SEMAPHOREGLOBALREL = 0x0504L
    SEMAPHORELOCALREQTO = 0x0505L
    SEMAPHOREGLOBALREQTO = 0x0506L

    def __init__(self, name, isglobal = False, timeout = -1, ignoreerror = False):
        self.connection = TechilaSocket()
        self.name = name
        self.isglobal = isglobal
        self.timeout = timeout
        self.ignoreerror = ignoreerror

    def reserve(self):
        """Reserve semaphore."""
        if self.connection.socket is None:
            self.connection.connect()

        name = self.name
        isglobal = self.isglobal
        timeout = self.timeout
        ignoreerror = self.ignoreerror

        namelen = len(name)
        if isglobal:
            if timeout < 0:
                m = struct.pack('!hh', TechilaSemaphore.SEMAPHOREGLOBALREQ, namelen) + name
            else:
                m = struct.pack('!hih', TechilaSemaphore.SEMAPHOREGLOBALREQTO, timeout, namelen) + name
        else:
            if timeout < 0:
                m = struct.pack('!hh', TechilaSemaphore.SEMAPHORELOCALREQ, namelen) + name
            else:
                m = struct.pack('!hih', TechilaSemaphore.SEMAPHORELOCALREQTO, timeout, namelen) + name

        self.connection.socket.sendall(m)
        cmdid = self.connection._read_short()
        response = self.connection._read_short()
        self.isglobal = isglobal
        self.name = name

        if response == 255:
            if ignoreerror:
               return False
            raise TechilaSemaphoreException("Error in requesting semaphore '%s'. Make sure the semaphore exists and the scope (local/global) is correct." % name)

        elif response == 254:
            if ignoreerror:
               return False
            raise TechilaSemaphoreTimeoutException("Timeout in requesting semaphore '%s'" % name)
        return True

    def release(self):
        """Release semaphore."""
        if self.connection.socket is None:
            self.connection.connect()

        name = self.name
        isglobal = self.isglobal

        namelen = len(name)
        if isglobal:
            m = struct.pack('!hh', TechilaSemaphore.SEMAPHOREGLOBALREL, namelen) + name
        else:
            m = struct.pack('!hh', TechilaSemaphore.SEMAPHORELOCALREL, namelen) + name

        self.connection.socket.sendall(m)
        cmdid = self.connection._read_short()
        response = self.connection._read_short()

    def __enter__(self):
        return self.reserve()

    def __exit__(self, type, value, traceback):
        self.release()

class TechilaInterconnect(object):
    """Techila Interconnect. Connection is established on object
    initialization."""

    # from Listener.java r857
    GETPROJECTID = 0x0001
    GETJOBID = 0x0002
    GETJOBCOUNT = 0x0003
    INITIALIZE = 0x0100
    SENDDATATOJOB = 0x0101
    READDATA = 0x0102
    READDATAFROMJOB = 0x0103
    WAITFOROTHERS = 0x0104
    READDATAIFEXIST = 0x0105
    SENDDATATOJOBSYNC = 0x0106
    REGISTERJOBID = 0x1001
    UNREGISTERJOBID = 0x1002
    QUERYJOBID = 0x1003
    REQUESTSLOT = 0x1004
    REQUESTACCEPTED = 0x1005
    BLOCKREACHED = 0x1006
    PING = 0x1103
    PONG = 0x1104
    SENDIMDATA = 0x2001
    SENDIMDATAFILE = 0x2002
    EXECCMD = 0x2101
    ABORT = 0x3001


    def __init__(self, timeout = 30000, autoinitialize = True):
        self.connection = TechilaSocket()
        self.myjobid = self.connection.myjobid
        self.port = self.connection.port
        self.jobcount = self.connection.jobcount
        self.connect(timeout, autoinitialize)

    def connect(self, timeout = 30000, autoinitialize = True):
        self.connection.connect()
        if autoinitialize:
            self.initialize(timeout)

    def initialize(self, timeout = 30000):
        m = struct.pack('!hi', TechilaInterconnect.INITIALIZE, timeout)

        self.connection.socket.sendall(m)

        cmdid = self.connection._read_short()
        status = self.connection._read_short()

        if cmdid != TechilaInterconnect.INITIALIZE:
            self.connection._fail()
            raise TechilaInterconnectException('cmdid mismatch, expected %i, got %i' % (TechilaInterconnect.INITIALIZE, cmdid))

        if status != 0:
            self.connection._fail()
            raise TechilaInterconnectException('status not ok, got %i' % status)

    def disconnect(self):
        self.connection.disconnect()

    def send_data_to_job(self, jobid, data):
        """Pickle and send data to job"""
        pickled_data = cPickle.dumps(data, 1)

        return self._send_data_to_job(jobid, pickled_data)

    def _send_data_to_job(self, jobid, data):
        """send string/buffer to job"""
        datalen = len(data)

        m = struct.pack('!hii', TechilaInterconnect.SENDDATATOJOB, jobid, datalen) + data

        l = len(m)
        self.connection.socket.sendall(m)
        return l

    def recv_data_from_job(self, jobid):
        """Receive data from job and unpickle it"""
        data = self._recv_data_from_job(jobid)

        unpickled_data = cPickle.loads(data)

        return unpickled_data

    def _recv_data_from_job(self, jobid):
        """Receive string/buffer from job."""

        m = struct.pack('!hi', TechilaInterconnect.READDATAFROMJOB, jobid)

        self.connection.socket.sendall(m)

        cmdid = self.connection._read_short()
        source = self.connection._read_int()
        datalen = self.connection._read_int()

        if cmdid != TechilaInterconnect.READDATA:
            raise TechilaInterconnectException('cmdid mismatch, expected %i, got %i' % (TechilaInterconnect.READDATA, cmdid))

        if source != jobid:
            raise TechilaInterconnectException('source mismatch, expected %i, got %i' % (jobid, source))

        data = self.connection._read_data(datalen)

        return data


    def wait_for_others(self):
        """Wait for others."""

        m = struct.pack('!h', TechilaInterconnect.WAITFOROTHERS)
        self.connection.socket.sendall(m)

        cmdid = self.connection._read_short()
        status = self.connection._read_short()

        if cmdid != TechilaInterconnect.WAITFOROTHERS:
            raise TechilaInterconnectException('cmdid mismatch, expected %i, got %i' % (TechilaInterconnect.WAITFOROTHERS, cmdid))

        if status != 0:
            raise TechilaInterconnectException('status not ok, got %i' % status)


    def cloudop(self, op, data, target = 0):
        """Run op on all job data"""

        jobid = self.connection.myjobid
        jobs = self.connection.jobcount

        if target > jobs:
            raise TechilaInterconnectException('invalid target specified')

        if float(jobs) / jobid >= 2:
            recv = self.recv_data_from_job(jobid * 2)
            data = apply(op, (data, recv))

            if float(jobs) / jobid > 2:
                recv = self.recv_data_from_job(jobid * 2 + 1)
                data = apply(op, (data, recv))

        if jobid > 1:
            self.send_data_to_job(jobid / 2, data)
            if target == 0:
                result = self.recv_data_from_job(jobid / 2)
            elif target == jobid:
                result = self.recv_data_from_job(1)
            else:
                result = None
        else:
            result = data

        if target == 0:
            if float(jobs) / jobid >= 2:
                self.send_data_to_job(jobid * 2, result)
                if float(jobs) / jobid > 2:
                    self.send_data_to_job(jobid * 2 + 1, result)
        elif jobid == 1 and target != 1:
            self.send_data_to_job(target, result)
            result = None

        return result

    def cloudbc(self, data, srcid = 1):
        """Broadcast a message to all jobs"""

        jobid = self.connection.myjobid
        jobs = self.connection.jobcount

        if srcid > 1:
            if jobid == 1:
                result = self.recv_data_from_job(srcid)
            elif srcid == jobid:
                self.send_data_to_job(1, data)
        else:
            result = data

        if jobid > 1:
            result = self.recv_data_from_job(jobid / 2)

        if float(jobs) / jobid >= 2:
            self.send_data_to_job(jobid * 2, result)
            if float(jobs) / jobid > 2:
                self.send_data_to_job(jobid * 2 + 1, result)

        return result


    def cloudsum(self, data, target = 0):
        """Sum all datas together"""

        def add2(a, b):
            return a + b

        return self.cloudop(add2, data, target)

def get_jobid():
    conn = TechilaSocket()
    return conn.myjobid

def get_jobcount():
    conn = TechilaSocket()
    return conn.jobcount

def save_im_data(imdata):
    send_im_data(imdata)

def send_im_data(imdata):
    imdatafile = 'techila_im_data'

    conn = TechilaSocket()
    if conn.socket is None:
        conn.connect()

    if os.path.exists(imdatafile):
        os.remove(imdatafile)

    f = open(imdatafile, 'wb')
    data = cPickle.Pickler(f, 1)
    data.dump(conn.fulljobid)
    data.dump(imdata)
    f.close()

    l = len(imdatafile)

    m = struct.pack('!hh', TechilaInterconnect.SENDIMDATAFILE, l) + imdatafile

    conn.socket.sendall(m)

def load_im_data(timeout = -1):
    # these won't work if the end-user changes wd
    filename ='techila_iminputdata.dat'
    data = None
    t0 = time.time()
    retries = 2
    while retries > 0 and (timeout == -1 or time.time() - t0 < timeout):
        if os.path.exists(filename):
            try:
                f = open(filename, 'rb')
                p = cPickle.Unpickler(f)
                data = p.load()
                f.close()
                os.remove(filename)
                retries = 0
            except Exception as e:
                retries -= 1
                time.sleep(1)
        else:
            time.sleep(0.1)
    return data

def save_snapshot(*args):
    filename = 'snapshot.dat'
    f = open(filename, 'wb')
    data = cPickle.Pickler(f, 1)
    variables = {}
    for arg in args:
        variables[arg] = sys._getframe(1).f_globals[arg]
    data.dump(variables)
    f.close()

def load_snapshot(filename = 'snapshot.dat'):
    if os.path.exists(filename):
        f = open(filename, 'rb')
        data = cPickle.Unpickler(f)
        variables = data.load()
        for key in variables.keys():
            #print key, variables[key]
            sys._getframe(1).f_globals[key] = variables[key]
        f.close()

def load_pcresults(filenames):
    if type(filenames) is str:
        filenames = [filenames]

    for fn in filenames:
        fn = fn.rstrip()

        f = open(fn, 'rb')
        data = cPickle.Unpickler(f)
        pcresults = data.load()
        f.close()

        for pcresult in pcresults:
            idx = pcresult['idx']
            result = pcresult['result']
            yield result


if __name__ == '__main__':

    paramoffset = 0
    try:
        paramoffset = sys.argv.index('--') + 1
    except ValueError:
        pass

    if len(sys.argv) >= 3:
        # store original current working directory
        origdir = os.getcwd()

        jobidx = int(sys.argv[paramoffset + 1])
        outputfile = sys.argv[paramoffset + 2]

        extra_params = None
        if len(sys.argv) > paramoffset + 3:
            extra_params = sys.argv[paramoffset + 3:]

        inputfile = 'techila_peach_inputdata'

        if not os.path.exists(inputfile):
            raise Exception('Unable to load parameters: ' + inputfile + ' does not exist')

        file = open(inputfile, 'rb')
        data = cPickle.Unpickler(file)
        mode = data.load()

        funcdata = data.load()

        params = data.load()
        files = data.load()
        peachvector = data.load()
        maxidx = data.load()
        steps = data.load()
        pvjifmode = data.load()
        xfuncdatas = data.load()

        file.close()

        #print 'mode', mode
        #print 'funcdata', funcdata
        #print 'files', files

        if files:
            for sourcefile in files:
                sourcefile = re.sub('^(.*[\\\\/])?(.+)\\.((p|P)(y|Y)).?$', '\g<2>', sourcefile)
                exec('from ' + sourcefile + ' import *')

        if mode == 'function':
            code_str = funcdata[0]
            funcname = funcdata[1]
            defaults = funcdata[2]
            closure_values = funcdata[3]
            code = marshal.loads(code_str)
            closure = tuple([ctypes.pythonapi.PyCell_New(ctypes.py_object(v)) for v in closure_values])
            f = types.FunctionType(code, globals(), funcname, defaults, closure)
        elif mode == 'builtin':
            funcname = funcdata[0]
            module = funcdata[1]
            f = getattr(__import__(module, fromlist=[funcname]), funcname)
        else:
            funcname = funcdata[0]
            if not locals().has_key(funcname):
                raise Exception('The function to be called \'%s\' was not found.' % funcname)
            f = locals()[funcname]

        #print peachvector

        # load xfuncdatas
        if xfuncdatas is not None:
            for xfuncdata in xfuncdatas:
                xmode = xfuncdata[0]
                if xmode == 'function':
                    xcode_str = xfuncdata[1]
                    xfuncname = xfuncdata[2]
                    xdefaults = xfuncdata[3]
                    xclosure_values = xfuncdata[4]
                    xcode = marshal.loads(xcode_str)
                    #xPyCell_New = ctypes.pythonapi.PyCell_New
                    #xPyCell_New.restype = ctypes.py_object
                    xclosure = tuple([ctypes.pythonapi.PyCell_New(ctypes.py_object(v)) for v in xclosure_values])
                    xf = types.FunctionType(xcode, globals(), xfuncname, xdefaults, xclosure)

                globals()[xfuncname] = xf


        idxstart = (jobidx - 1) * steps
        idxend = idxstart + steps

        if idxend > maxidx:
            idxend = maxidx

        #print 'indexes', idxstart, idxend

        random.seed((time.time() + jobidx) % pow(2, 31))

        pcresults = []

        if params == None:
            params = []

        idx = idxstart
        while idx < idxend:
            cparams = params[:] # clone
            #print '--- idx', idx

            for i in range(len(cparams)):
                if isinstance(cparams[i], str):
                    if cparams[i] == '<param>':
                        if pvjifmode:
                            jiff = open('pvjifdata', 'rb')
                            p = cPickle.Unpickler(jiff)
                            dataelem = p.load()
                            jiff.close()
                        else:
                            dataelem = peachvector[idx]
                        cparams[i] = dataelem
                    elif cparams[i] == '<vecidx>':
                        cparams[i] = idx
                    elif cparams[i] == '<jobidx>':
                        cparams[i] = jobidx
                    elif cparams[i] == '<extraparams>':
                        cparams[i] = extra_params

            #print cparams

            # for each run, start from the original directory
            os.chdir(origdir)
            result = apply(f, cparams)

            #print 'result == >> ', result

            pcresults.append({'idx': idx, 'result': result})

            idx = idx + 1

        #print 'pcresults', pcresults

        # return to the original directory
        os.chdir(origdir)

        file = open(outputfile, 'wb')
        data = cPickle.Pickler(file, 1)
        data.dump(pcresults)
        file.close()

