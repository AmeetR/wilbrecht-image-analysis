# Copyright 2012-2017 Techila Technologies Ltd.

from distutils.core import setup

import imp
import sys
import os

major_ver = sys.version_info[0]

if major_ver != 3:
    raise Exception('This Techila package is for Python 3.x only!')

setup(name='Techila',
      version='2.3',
      description='Techila',
      long_description='Techila',
      author='Techila Technologies Ltd.',
      author_email='info@techilatechnologies.com',
      url='http://www.techilatechnologies.com/',
      license='proprietary',
      packages=['techila'],
#      py_modules=['techila', 'peachclient'],
      )

# reload sys.path
import site
imp.reload(site)

techila = imp.find_module('techila', sys.path[1:])
instdir = techila[1]

sdkroot = None
for arg in sys.argv:
    if arg.startswith('sdkroot='):
        sdkroot = arg.replace('sdkroot=', '')
        break

if not sdkroot:
    setupdir = os.path.dirname(os.path.realpath(sys.argv[0]))
    while True:
        if os.path.exists(os.path.join(setupdir, 'lib')):
            sdkroot = setupdir
            break
        parentdir = os.path.dirname(setupdir)
        if parentdir == setupdir:
            break
        setupdir = parentdir

file = open(os.path.join(instdir, 'sdkroot_config.py'), 'w')
if sdkroot:
    sdkroot = sdkroot.replace('\\', '\\\\')
    file.write('sdkroot="%s"\n' % sdkroot)
else:
    print('Warning: sdkroot is not found, it must be specified in function calls')
file.close()
