%TECHILASEMAPHORERESERVE
%
%techilaSemaphoreReserve(name, isglobal, timeout, ignoreerror)
%
% This method reserves a semaphore. The semaphore needs to be released with
% techilaSemaphoreRelease after use-
%
% The parameters for techilaSemaphoreReserve are:
%
% name                     = The name of the semaphore to be reserved
% isglobal                 = Is the semaphore local (project-specific) or
%                            global (shared by all projects). The default
%                            value is false (local).
% timeout                  = Timeout for reserving semaphore. If timeout
%                            exceeds before semaphore is received, the
%                            method throws exception or returns false (if
%                            ignoreerror is true). Default is -1 (no
%                            timeout.)
% ignoreerror              = If true, the timeouts or other errors in
%                            the method call cause return value to be false
%                            instead of exception. Default is false.
%
% Copyright 2015 Techila Technologies Ltd.
