! Copyright 2012-2013 Techila Technologies Ltd.
      module techila
      interface
         integer(kind=c_int) function techila_init() bind(c)
         use, intrinsic :: iso_c_binding
         end function techila_init

         integer(kind=c_int) function techila_unload() bind(c)
         use, intrinsic :: iso_c_binding
         end function techila_unload

!  int techila_peach_handle();
         integer(kind=c_int) function techila_peach_handle() bind(c)
         use, intrinsic :: iso_c_binding
         end function techila_peach_handle

!  int techila_peach_setName(int handle, LPSTR name);
         integer(kind=c_int) function techila_peach_setname(handle, name) bind(c, name="techila_peach_setName")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         end function techila_peach_setname

!   int techila_peach_setDescription(int handle, LPSTR description);
         integer(kind=c_int) function techila_peach_setdescription(handle, desc) bind(c, name="techila_peach_setDescription")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: desc(*)
         end function techila_peach_setDescription

!   int techila_peach_setMessages(int handle, unsigned char messages);
         integer(kind=c_int) function techila_peach_setmessages(handle, messages) bind(c, name="techila_peach_setMessages")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: messages
         end function techila_peach_setmessages

!   int techila_peach_setPriorityI(int handle, int priority);
         integer(kind=c_int) function techila_peach_setpriorityi(handle, priority) bind(c, name="techila_peach_setPriorityI")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: priority
         end function techila_peach_setpriorityi

!   int techila_peach_setPriority(int handle, LPSTR priority);
         integer(kind=c_int) function techila_peach_setpriority(handle, priority) bind(c, name="techila_peach_setPriority")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: priority(*)
         end function techila_peach_setpriority

!   int techila_peach_setProjectId(int handle, int projectid);
         integer(kind=c_int) function techila_peach_setprojectid(handle, pid) bind(c, name="techila_peach_setProjectId")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: pid
         end function techila_peach_setprojectid

!   int techila_peach_setJobs(int handle, int jobs);
         integer(kind=c_int) function techila_peach_setjobs(handle, jobs) bind(c, name="techila_peach_setJobs")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: jobs
         end function techila_peach_setjobs

!   int techila_peach_setAllowPartial(int handle, unsigned char allowPartial);
         integer(kind=c_int) function techila_peach_setallowpartial(handle, partial) bind(c, name="techila_peach_setAllowPartial")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: partial
         end function techila_peach_setallowpartial

!   int techila_peach_setRemove(int handle, unsigned char remove);
         integer(kind=c_int) function techila_peach_setremove(handle, remove) bind(c, name="techila_peach_setRemove")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: remove
         end function techila_peach_setremove

!   int techila_peach_setCleanup(int handle, unsigned char cleanup);
         integer(kind=c_int) function techila_peach_setcleanup(handle, cleanup) bind(c, name="techila_peach_setCleanup")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: cleanup
         end function techila_peach_setcleanup

!   int techila_peach_setClose(int handle, unsigned char close);
         integer(kind=c_int) function techila_peach_setclose(handle, close) bind(c, name="techila_peach_setClose")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: close
         end function techila_peach_setclose

!   int techila_peach_addSourceFile(int handle, LPSTR file);
         integer(kind=c_int) function techila_peach_addsourcefile(handle, file) bind(c, name="techila_peach_addSourceFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: file(*)
         end function techila_peach_addsourcefile

!   int techila_peach_sourcesChanged(int handle);
         integer(kind=c_int) function techila_peach_sourceschanged(handle) bind(c, name="techila_peach_sourcesChanged")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_sourceschanged

!   int techila_peach_putSourceExtras(int handle, LPSTR name,  LPSTR value);
         integer(kind=c_int) function techila_peach_putsourceextras &
         (handle, name, value) bind(c, name="techila_peach_putSourceExtras")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putsourceextras

!   int techila_peach_setExeBundleName(int handle, LPSTR name);
         integer(kind=c_int) function techila_peach_setexebundlename(handle, name) bind(c, name="techila_peach_setExeBundleName")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         end function techila_peach_setexebundlename

!   int techila_peach_setExecutable(int handle, LPSTR executable);
         integer(kind=c_int) function techila_peach_setexecutable(handle, executable) bind(c, name="techila_peach_setExecutable")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: executable(*)
         end function techila_peach_setexecutable

!   int techila_peach_setExeSkipDigest(int handle, unsigned char skipDigest);
         integer(kind=c_int) function techila_peach_setexeskipdigest(handle, skip) bind(c, name="techila_peach_setExeSkipDigest")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: skip
         end function techila_peach_setexeskipdigest

!   int techila_peach_addExeFile(int handle, LPSTR res, LPSTR file, LPSTR osname, LPSTR processor);
         integer(kind=c_int) function techila_peach_addexefile &
         (handle, res, file, osname, processor) bind(c, name="techila_peach_addExeFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: res(*)
         character(kind=c_char), intent(in) :: file(*)
         character(kind=c_char), intent(in) :: osname(*)
         character(kind=c_char), intent(in) :: processor(*)
         end function techila_peach_addexefile

!   int techila_peach_putExeExtras(int handle, LPSTR name, LPSTR value);
         integer(kind=c_int) function techila_peach_putexeextras(handle, name, value) bind(c, name="techila_peach_putExeExtras")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putexeextras

!   int techila_peach_addExeImport(int handle, LPSTR importName);
         integer(kind=c_int) function techila_peach_addexeimport(handle, import) bind(c, name="techila_peach_addExeImport")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: import(*)
         end function techila_peach_addexeimport

!   int techila_peach_addOutputFile(int handle, LPSTR def);
         integer(kind=c_int) function techila_peach_addoutputfile(handle, def) bind(c, name="techila_peach_addOutputFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: def(*)
         end function techila_peach_addoutputfile

!   int techila_peach_newDataBundle(int handle);
         integer(kind=c_int) function techila_peach_newdatabundle(handle) bind(c, name="techila_peach_newDataBundle")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_newdatabundle

!   int techila_peach_newDataBundleWithName(int handle, LPSTR name);
         integer(kind=c_int) function techila_peach_newdatabundlewithname &
         (handle, name) bind(c, name="techila_peach_newDataBundleWithName")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         end function techila_peach_newdatabundlewithname

!   int techila_peach_setDataSkipDigest(int handle, unsigned char skipDigest);
         integer(kind=c_int) function techila_peach_setdataskipdigest(handle, skip) bind(c, name="techila_peach_setDataSkipDigest")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: skip
         end function techila_peach_setdataskipdigest

!   int techila_peach_addDataFile(int handle, LPSTR file);
         integer(kind=c_int) function techila_peach_adddatafile(handle, file) bind(c, name="techila_peach_addDataFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: file(*)
         end function techila_peach_adddatafile

!   int techila_peach_addDataFileWithDir(int handle, LPSTR dir,  LPSTR file);
         integer(kind=c_int) function techila_peach_adddatafilewithdir &
         (handle, dir, file) bind(c, name="techila_peach_addDataFileWithDir")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: dir(*)
         character(kind=c_char), intent(in) :: file(*)
         end function techila_peach_adddatafilewithdir

!   int techila_peach_putDataExtras(int handle, LPSTR name,  LPSTR value);
         integer(kind=c_int) function techila_peach_putdataextras(handle, name, value) bind(c, name="techila_peach_putDataExtras")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putdataextras

!   int techila_peach_setDataCopy(int handle, unsigned char copy);
         integer(kind=c_int) function techila_peach_setdatacopy(handle, copy) bind(c, name="techila_peach_setDataCopy")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: copy
         end function techila_peach_setdatacopy

!   int techila_peach_setJobSkipDigest(int handle, unsigned char skipDigest);
         integer(kind=c_int) function techila_peach_setjobskipdigest(handle, skip) bind(c, name="techila_peach_setJobSkipDigest")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: skip
         end function techila_peach_setjobskipdigest

!   int techila_peach_setJobFileNames(int handle, int paramcount, ...);
!   int techila_peach_addJobFile(int handle, int paramcount, ...);

!   int techila_peach_addJobFile3(int handle, int paramcount, char** params);
         integer(kind=c_int) function techila_peach_addjobfile3 &
         (handle, paramcount, params) bind(c, name="techila_peach_addJobFile3")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: paramcount
         type(c_ptr), dimension(paramcount), intent(in) :: params
         end function techila_peach_addjobfile3


!   int techila_peach_addJobFileWithDir(int handle, LPSTR dir,  int paramcount, ...);
!   int techila_peach_addJobFileWithDir3(int handle, LPSTR dir,  int paramcount, char** params);
         integer(kind=c_int) function techila_peach_addjobfilewithdir3 &
         (handle, dir, paramcount, params) bind(c, name="techila_peach_addJobFileWithDir3")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: dir(*)
         integer(kind=c_int), intent(in), value :: paramcount
         type(c_ptr), dimension(paramcount), intent(in) :: params
         end function techila_peach_addjobfilewithdir3

!   int techila_peach_putJobExtras(int handle, LPSTR name,  LPSTR value);
         integer(kind=c_int) function techila_peach_putjobextras(handle, name, value) bind(c, name="techila_peach_putJobExtras")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putjobextras

!   int techila_peach_setParamSkipDigest(int handle, unsigned char skipDigest);
         integer(kind=c_int) function techila_peach_setparamskipdigest &
         (handle, skip) bind(c, name="techila_peach_setParamSkipDigest")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: skip
         end function techila_peach_setparamskipdigest

!   int techila_peach_addParamFile(int handle, LPSTR file);
         integer(kind=c_int) function techila_peach_addparamfile(handle, file) bind(c, name="techila_peach_addParamFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: file(*)
         end function techila_peach_addparamfile

!   int techila_peach_addParamFileWithDir(int handle, LPSTR dir,  LPSTR file);
         integer(kind=c_int) function techila_peach_addparamfilewithdir &
         (handle, dir, file) bind(c, name="techila_peach_addParamFileWithDir")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: dir(*)
         character(kind=c_char), intent(in) :: file(*)
         end function techila_peach_addparamfilewithdir

!   int techila_peach_addParamFileWithTarget(int handle, LPSTR file,  LPSTR targetName);
         integer(kind=c_int) function techila_peach_addparamfilewithtarget &
         (handle, file, target) bind(c, name="techila_peach_addParamFileWithTarget")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: file(*)
         character(kind=c_char), intent(in) :: target(*)
         end function techila_peach_addparamfilewithtarget

!   int techila_peach_putParamExtras(int handle, LPSTR name,  LPSTR value);
         integer(kind=c_int) function techila_peach_putparamextras(handle, name, value) bind(c, name="techila_peach_putParamExtras")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putparamextras

!   int techila_peach_addParamExternalResource(int handle, LPSTR res);
         integer(kind=c_int) function techila_peach_addparamexternalresource &
         (handle, res) bind(c, name="techila_peach_addParamExternalResource")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: res(*)
         end function techila_peach_addparamexternalresource

!   int techila_peach_setParamCopy(int handle, unsigned char copy);
         integer(kind=c_int) function techila_peach_setparamcopy(handle, copy) bind(c, name="techila_peach_setParamCopy")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: copy
         end function techila_peach_setparamcopy

!   int techila_peach_putProjectParam(int handle, LPSTR name, LPSTR value);
         integer(kind=c_int) function techila_peach_putprojectparam &
         (handle, name, value) bind(c, name="techila_peach_putProjectParam")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(in) :: name(*)
         character(kind=c_char), intent(in) :: value(*)
         end function techila_peach_putprojectparam

!   int techila_peach_setStream(int handle, unsigned char stream);
         integer(kind=c_int) function techila_peach_setstream(handle, stream) bind(c, name="techila_peach_setStream")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         integer(kind=c_int), intent(in), value :: stream
         end function techila_peach_setstream

!   int techila_peach_getProjectHandle(int handle);
         integer(kind=c_int) function techila_peach_getprojecthandle(handle) bind(c, name="techila_peach_getProjectHandle")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_getprojecthandle

!   int techila_peach_getProjectId(int handle);
         integer(kind=c_int) function techila_peach_getprojectid(handle) bind(c, name="techila_peach_getProjectId")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_getprojectid

!   int techila_peach_execute(int handle);
         integer(kind=c_int) function techila_peach_execute(handle) bind(c)
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_execute

!   int techila_peach_nextFile(int handle, LPSTR filename, size_t *len);
         integer(kind=c_int) function techila_peach_nextfile(handle, filename, len) bind(c, name="techila_peach_nextFile")
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         character(kind=c_char), intent(out) :: filename(*)
         integer(kind=c_int), intent(out) :: len
         end function techila_peach_nextfile

!   int techila_peach_done(int handle);
         integer(kind=c_int) function techila_peach_done(handle) bind(c)
         use, intrinsic :: iso_c_binding
         integer(kind=c_int), intent(in), value :: handle
         end function techila_peach_done

      end interface
      end module techila
