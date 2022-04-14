all:

OBJS=perfect6502/perfect6502.o perfect6502/netlist_sim.o
#OBJS+=perfect6502/cbmbasic/runtime.o perfect6502/cbmbasic/runtime_init.o perfect6502/cbmbasic/plugin.o perfect6502/cbmbasic/console.o perfect6502/cbmbasic/emu.o
OBJS+=tb_cpu65xx.o
CPPFLAGS= -O3 #-Wall -O3
CPPFLAGS+= -I/usr/share/verilator/include/
CPPFLAGS+= -D__WORDSIZE=64
CFLAGS= -O3 #-Wall -O3
CFLAGS+= -I/usr/share/verilator/include/
CC=gcc
CXX=g++

DUT_NAME=Vcpu65xx_core
DUT_PATH=obj_dir
include $(DUT_PATH)/$(DUT_NAME)_classes.mk
include $(DUT_PATH)/$(DUT_NAME).mk
OBJS+=$(DUT_PATH)/$(DUT_NAME).o $(DUT_PATH)/$(DUT_NAME)__Syms.o $(DUT_PATH)/$(DUT_NAME)__Trace.o

perfect6502/perfect6502.h:
	git clone https://github.com/mist64/perfect6502.git

hex2v: hex2v.c
	gcc hex2v.c -o hex2v

sindata: sindata.c
	gcc sindata.c -o sindata -lm

sindata.hex: sindata
	./sindata >sindata.hex

%.hex: %.asm
	gpasm $<
	sed -i '1d' $@

%.rom: %.hex hex2v
	./hex2v $< >$@

.PHONY: all clean sim verilate
sim: perfect6502/perfect6502.h $(OBJS) 
	$(CXX) $(CPPFLAGS) $(OBJS) 

verilate obj_dir/Vcpu65xx_core.mk:
	cd ../rtl; verilator --cc cpu65xx_core.v --exe --trace -Mdir ../dv/obj_dir
	cd ../dv

clean:
	rm -rf perfect6502
	rm -rf *.o
	rm -rf a.out
	rm -rf *.d
