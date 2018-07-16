PROGRAM=library
SDKROOT=../../../../
SDKLIBDIR=$(SDKROOT)/lib

CC=gcc
CFLAGS=-I$(SDKLIBDIR) -I\"$(JAVA_HOME)/include\" -Wall -pedantic -std=c99
LDFLAGS=-L$(SDKLIBDIR)
LDADDFLAGS=-L. -llibrary

DLL32=-l:$(SDKLIBDIR)/Techila32.dll
DLL64=-l:$(SDKLIBDIR)/Techila64.dll
SO32=-lTechila32
SO64=-lTechila64

default:
	@echo Please select target: linux32 linux64 win32 win64


linux32:
	$(MAKE) -f MakefileLib.mak linux32
	$(MAKE) SDKFLAGS="$(SO32) -ldl" CFLAGS="$(CFLAGS) -I\"$(JAVA_HOME)/include/linux\"" rlinux32

linux64:
	$(MAKE) -f MakefileLib.mak linux64
	$(MAKE) SDKFLAGS="$(SO64) -ldl" CFLAGS="$(CFLAGS) -I\"$(JAVA_HOME)/include/linux\"" rlinux64

win32:
	"$(MAKE)" -f MakefileLib.mak win32
	"$(MAKE)" SDKFLAGS="$(DLL32)" CFLAGS="$(CFLAGS) -I\"$(JAVA_HOME)/include/win32\"" rwin32

win64:
	"$(MAKE)" -f MakefileLib.mak win64
	"$(MAKE)" SDKFLAGS="$(DLL64)" CFLAGS="$(CFLAGS) -I\"$(JAVA_HOME)/include/win32\"" rwin64


rlinux32: local_program run_$(PROGRAM) $(PROGRAM)_dist32

rlinux64: local_program run_$(PROGRAM) $(PROGRAM)_dist64

rwin32: local_program run_$(PROGRAM) $(PROGRAM)_dist32

rwin64: local_program run_$(PROGRAM) $(PROGRAM)_dist64


run_$(PROGRAM): run_$(PROGRAM).o
	$(CC) $(LDFLAGS) $(SDKFLAGS) -o $@ $?

run_$(PROGRAM).o: run_$(PROGRAM).c
	$(CC) $(CFLAGS) -c -o $@ $?

$(PROGRAM)_dist64: $(PROGRAM)_dist64.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(LDADDFLAGS) -o $@ $?

$(PROGRAM)_dist64.o: $(PROGRAM)_dist.c
	$(CC) $(CFLAGS) -c -o $@ $?

$(PROGRAM)_dist32: $(PROGRAM)_dist32.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(LDADDFLAGS) -o $@ $?

$(PROGRAM)_dist32.o: $(PROGRAM)_dist.c
	$(CC) $(CFLAGS) -c -o $@ $?

local_program: local_program.o
	$(CC) $(CFLAGS) $(LDADDFLAGS) -o $@ $?

local_program.o: local_program.c
	$(CC) $(CFLAGS) -c -o $@ $?

clean:
	rm -f *.o *.exe *.so
	rm -f run_$(PROGRAM) $(PROGRAM)_dist32 $(PROGRAM)_dist64 local_program

cleanwin:
	del *.o *.exe *.dll
