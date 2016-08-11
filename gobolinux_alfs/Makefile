CC = gcc
CFLAGS = -Wall
LDFLAGS =
REPOSITORY = http://recipes.gobolinux.org/r/recipes

all: FindBroken SymlinkProgram PackageNames.txt

clean:
	@rm -f *.o *~ FindBroken SymlinkProgram

install:
	@cp -v CreateGoboLinuxTree FindBroken SymlinkProgram /tools/bin
	@cp -v PackageNames.txt /tools/etc/GoboLinux_PackageNames.txt

PackageNames.txt:
	wget -q -O - $(REPOSITORY)  | grep recipe.tar.bz2 | cut -d\" -f2 | sed 's,\(.*\)--\(.*\)--.*,\1,g' | uniq > $@

FindBroken: FindBroken.o 
	$(CC) $(LDFLAGS) -o $@ FindBroken.o

SymlinkProgram: SymlinkProgram.o LinkOrExpandAll.o
	$(CC) $(LDFLAGS) -o $@ SymlinkProgram.o LinkOrExpandAll.o

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
