PROG=dummy
SRCDIR=src
OBJDIR=obj
BINDIR=bin
LISTDIR=list
ELFDIR=elf
ASPATH=/home/dean/arm-2012.09/bin
PREFIX=arm-none-linux-gnueabi
AS=as -march=armv5
LD=ld
OBJDUMP=objdump
OBJCPY=objcopy
ASCMD=${ASPATH}/${PREFIX}-${AS}
LDCMD=${ASPATH}/${PREFIX}-${LD}
OBJDMPCMD=${ASPATH}/${PREFIX}-${OBJDUMP}
OBJCPYCMD=${ASPATH}/${PREFIX}-${OBJCPY}
# assembly files
#S_SRCS = adc.s \
	hello.s

SRCS := $(wildcard src/*.s)

.SUFFIXES: .s .o .elf .bin .list

#OBJS := $(SRCS:src/%.s=obj/%.o)
#OBJS:= obj/hello.o

OBJS := $(SRCS:src/%.s=${OBJDIR}/%.o)
ELFS := $(OBJS:${OBJDIR}/%.o=${ELFDIR}/%.elf)
DUMPS := $(ELFS:${ELFDIR}/%.elf=${LISTDIR}/%.list)
BINDUMPS := $(ELFS:${ELFDIR}/%.elf=${BINDIR}/%.bin)

all: $(PROG)

$(PROG): $(OBJS) $(ELFS) ${DUMPS} ${BINDUMPS}

${OBJDIR}/%.o: ${SRCDIR}/%.s
	$(ASCMD) $< -o $@

${ELFDIR}/%.elf: ${OBJDIR}/%.o
	${LDCMD} $< -o $@

${LISTDIR}/%.list: ${ELFDIR}/%.elf
	$(OBJDMPCMD) -D $< > $@

${BINDIR}/%.bin: ${ELFDIR}/%.elf
	${OBJCPYCMD} -O binary $< $@
	

.PHONY: clean

clean:
	-rm ${OBJDIR}/* ${BINDIR}/* ${LISTDIR}/* ${ELFDIR}/*
