#!/bin/bash
printf "$(pwd)\n"
make -C ../SIM/SystemC/CORE clean
PATH=$PATH:$HOME/riscv/bin SYSTEMC=~/systemc-2.3.3 make -C ../SIM/SystemC/CORE 