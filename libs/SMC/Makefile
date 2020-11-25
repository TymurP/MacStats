all: smcBinary

smcBinary: smcBinary.o
	gcc -mmacosx-version-min=10.15  -Wall -g -framework IOKit -o smcBinary smcBinary.o

smcBinary.o: smcBinary.h smcBinary.c
	gcc -DCMD_TOOL_BUILD -c smcBinary.c

clean:
	-rm -f smcBinary smcBinary.o
