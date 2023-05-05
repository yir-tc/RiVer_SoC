BUILD=build
SIM_DIR=sim

GHDL?=/opt/ghdl/bin/ghdl
GHDLFLAGS?=-v --workdir=$(BUILD)

CC=gcc
CFLAGS=-Wall -Wextra -Werror
LDFLAGS=

RISC_CC=riscv32-unknown-elf-gcc
RISC_CFLAGS=-nostdlib
RISC_LDFLAGS=-T $(SW_DIR)/kernel.ld

COMPONENTS = \
	UTIL/fifo UTIL/util UTIL/csa \
	core \
	IFETCH/ifetch \
	DEC/dec \
	EXE/shifter EXE/alu EXE/exec EXE/x0_multiplier EXE/divider \
	MEM/mem MEM/x1_multiplier \
	REG/reg \
	WBK/wbk WBK/x2_multiplier \
	CSR/csr \
	ram_axi_lite \
	CACHES/icache CACHES/buffer_cache CACHES/dcache CACHES/iprefetcher \
	tb/tb_buff_cache tb/tb_ram
TB=core_cache_tb
MODS=$(COMPONENTS) $(TB)
SOURCES=$(addsuffix .vhd, $(MODS))
OBJ=$(addsuffix .o, $(addprefix $(BUILD)/, $(notdir $(MODS))))
SW_DIR=../../SOFT
TEST=$(SW_DIR)/TESTS/I/test_add.s

all: tb_ram #run warning

run: $(TB) kernel
	cp $(SW_DIR)/app.ld kernel sim/
	./$(TB) $(TEST) --vcd=$(SIM_DIR)/$(TB).vcd --wave=$(SIM_DIR)/$(TB).ghw

core_cache_tb : warning $(OBJ) $(BUILD)/simu.o $(BUILD)/ram.o $(BUILD)/core_cache_tb.o
	${GHDL} -e ${GHDLFLAGS} -Wl,$(BUILD)/simu.o,$(BUILD)/ram.o core_cache_tb

core_tb : warning $(OBJ) $(BUILD)/simu.o $(BUILD)/ram.o $(BUILD)/core_tb.o 
	${GHDL} -e ${GHDLFLAGS} -Wl,$(BUILD)/simu.o,$(BUILD)/ram.o core_tb

tb_buff_cache: $(BUILD)/tb_buff_cache.o
	${GHDL} -e ${GHDLFLAGS} tb_buff_cache

tb_ram: $(BUILD)/tb_ram.o $(BUILD)/ram.o
	${GHDL} -e ${GHDLFLAGS} -Wl,$(BUILD)/ram.o tb_ram

$(BUILD)/simu.o: simu.c
	${CC} ${CFLAGS} -c -o $(BUILD)/simu.o simu.c 

$(BUILD)/ram.o: ram.c
	${CC} ${CFLAGS} -c -o $(BUILD)/ram.o ram.c

$(BUILD)/e~$(TB).o: $(OBJ)
	cd $(BUILD) && $(GHDL) --bind $(TB)

$(BUILD)/%.o: $(SOURCES)
	$(GHDL) -a $(GHDLFLAGS) $^

kernel: $(SW_DIR)/exception.s $(SW_DIR)/reset.s
	$(RISC) $(RISC_FLAGS) $^ -o $@

warning :
	@echo
	@echo Please dont forget to give an argument when doing make, otherwise it could segfault
	@echo You have to do : make TEST=pth_to_the_test/test_name
	@echo
clean:
	rm $(BUILD)/* $(SIM_DIR)/* -f *.lst *.o *.cf core_tb *.vcd *.ghw *.out \
	*.out.txt *.out.txt.s
