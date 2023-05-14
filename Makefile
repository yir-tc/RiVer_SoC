BUILD=build
TEST?=test_add
TESTBENCH?=soc_tb

all: run

run: soc
	$(BUILD)/$(TESTBENCH) $(BUILD)/$(TEST).o

soc: emulator core
	make -C soc TARGET=$(TESTBENCH)

emulator:
	make -C tests/emulator

core:
	make -C soc/core

clean:
	rm build/*
