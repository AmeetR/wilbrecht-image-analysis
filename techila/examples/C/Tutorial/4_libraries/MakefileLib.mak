CC=gcc

win32: library.dll
win64: library.dll
linux32: liblibrary.so
linux64: liblibrary.so

library.o: library.c
	$(CC) -fPIC -c library.c

library.dll: library.o
	$(CC) -o $@ -shared $?

liblibrary.so: library.o
	$(CC) -o $@ -shared $?

clean:
	rm -f *.o
	rm -f library.dll
	rm -f *.exe
