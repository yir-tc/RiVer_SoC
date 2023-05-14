BUILD=../../build

RISC_CC=riscv32-unknown-elf-gcc
RISC_CFLAGS=-nostdlib
RISC_LDFLAGS=-T kernel/kernel.ld

CC=gcc
CFLAGS=-Wall -Wextra #-Werror
LDFLAGS=

ASM_SAMPLES = \
	$(wildcard samples/I/*.s) \
	$(wildcard samples/I/*.c) \
	$(wildcard samples/M/*.s) \
	$(wildcard samples/M/*.c)
$(info $$ASM_SAMPLES is [${ASM_SAMPLES}])

ASM_OBJECTS=$(addprefix $(BUILD)/, $(notdir $(ASM_SAMPLES)))
$(info $$ASM_OBJECTS is [${ASM_OBJECTS}])
ASM_OBJECTS:=$(patsubst %.s, %.o, $(ASM_OBJECTS))
ASM_OBJECTS:=$(patsubst %.c, %.o, $(ASM_OBJECTS))
$(info $$ASM_OBJECTS is [${ASM_OBJECTS}])

all: $(BUILD)/loader.o $(BUILD)/ram.o $(BUILD)/kernel $(ASM_OBJECTS)

$(BUILD)/kernel: kernel/exception.s kernel/reset.s
	$(RISC_CC) $(RISC_CFLAGS) $^ -o $@

$(BUILD)/loader.o: loader.c
	${CC} ${CFLAGS} -c -o $(BUILD)/loader.o loader.c 

$(BUILD)/ram.o: ram.c
	${CC} ${CFLAGS} -c -o $(BUILD)/ram.o ram.c

$(BUILD)/%.o: samples/I/%.s $(BUILD)/kernel
	$(RISC_CC) $(RISC_CFLAGS) -march=rv32im $(RISC_LDFLAGS) -o $@ $(BUILD)/kernel $<

$(BUILD)/%.o: samples/I/%.c $(BUILD)/kernel
	$(RISC_CC) $(RISC_CFLAGS) -march=rv32im $(RISC_LDFLAGS) -o $@ $(BUILD)/kernel $<

$(BUILD)/%.o: samples/M/%.s $(BUILD)/kernel
	$(RISC_CC) $(RISC_CFLAGS) -march=rv32im $(RISC_LDFLAGS) -o $@ $(BUILD)/kernel $<

$(BUILD)/%.o: samples/M/%.c $(BUILD)/kernel
	$(RISC_CC) $(RISC_CFLAGS) -march=rv32im $(RISC_LDFLAGS) -o $@ $(BUILD)/kernel $<
