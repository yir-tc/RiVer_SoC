BUILD=../build

GHDL?=/opt/ghdl/bin/ghdl
GHDLFLAGS?=-v --workdir=$(BUILD)

COMPONENTS = \
	ram_axi_lite interface_axi_lite \
	caches/icache caches/buffer_cache caches/dcache caches/iprefetcher
SOURCES=$(addsuffix .vhd, $(COMPONENTS))
OBJ=$(addsuffix .o, $(addprefix $(BUILD)/, $(notdir $(COMPONENTS))))

TARGET ?= soc_cache_tb

all: $(TARGET)

soc_cache_tb: $(BUILD)/loader.o $(BUILD)/ram.o $(BUILD)/e~soc_cache_tb.o $(OBJ)
	cd $(BUILD) && ${GHDL} -e ${GHDLFLAGS} -Wl,$(BUILD)/loader.o -Wl,$(BUILD)/ram.o soc_cache_tb

soc_tb: $(BUILD)/loader.o $(BUILD)/ram.o $(BUILD)/e~soc_tb.o $(OBJ)
	cd $(BUILD) && ${GHDL} -e -v -Wl,$(BUILD)/loader.o -Wl,$(BUILD)/ram.o soc_tb

$(BUILD)/e~$(TARGET).o: $(BUILD)/$(TARGET).o
	cd $(BUILD) && $(GHDL) --bind $(TARGET)

$(BUILD)/$(TARGET).o: $(TARGET).vhd
	$(GHDL) -a $(GHDLFLAGS) $^

$(BUILD)/%.o: $(SOURCES)
	$(GHDL) -a $(GHDLFLAGS) $^

