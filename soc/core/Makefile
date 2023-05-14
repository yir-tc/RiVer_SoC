BUILD=../../build

GHDL?=/opt/ghdl/bin/ghdl
GHDLFLAGS?=-v --workdir=$(BUILD)

COMPONENTS = \
	UTIL/fifo UTIL/util UTIL/csa \
	core \
	IFETCH/ifetch \
	DEC/dec \
	EXE/shifter EXE/alu EXE/exec EXE/x0_multiplier EXE/divider \
	MEM/mem MEM/x1_multiplier \
	REG/reg \
	WBK/wbk WBK/x2_multiplier \
	CSR/csr
SOURCES=$(addsuffix .vhd, $(COMPONENTS))
OBJS=$(addsuffix .o, $(addprefix $(BUILD)/, $(notdir $(COMPONENTS))))

all: core.o

core.o: $(OBJS)
	$(GHDL) -a $(GHDLFLAGS) core.vhd

$(BUILD)/%.o: $(SOURCES)
	$(GHDL) -a $(GHDLFLAGS) $^

