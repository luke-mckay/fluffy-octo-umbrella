// SPDX-License-Identifier: LGPL-2.1-or-later
/*
 * MCS6500 Compatible MicroComputer TestBench
 * Copyright 2022, Luke E. McKay.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
 * USA
 */

// Standard Library Includes
#include <stdlib.h>
#include <iostream>

// Verilator Includes
#include "verilated.h"
#include "verilated_vcd_c.h"

// Model Includes
extern "C" {
#include "perfect6502/perfect6502.h"
}

// DUT Includes
#include "obj_dir/Vcpu65xx_core.h"


#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;


int main(int argc, char** argv, char** env)
{
  Verilated::mkdir("logs");

  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

  contextp->debug(0);

  contextp->randReset(2);

  contextp->traceEverOn(true);

  contextp->commandArgs(argc, argv);


  Vcpu65xx_core *dut = new Vcpu65xx_core;


  VerilatedVcdC *m_trace = new VerilatedVcdC;
  //dut->trace(m_trace, 5);
  m_trace->open("logs/waveform.vcd");

	int clk = 0;
	void *state = initAndResetChip();

	/* set up memory for user program */
	//init_monitor();

	/* emulate the 6502! */
  while ( !contextp->gotFinish() &&
          (sim_time < MAX_SIM_TIME) )
  {
		step(state);
    //ontextp->timeInc(1);  // 1 timeprecision period passes...
		clk = !clk;

    //dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

		//if (clk) handle_monitor(state);

		//chipStatus(state);
		//if (!(cycle % 1000)) printf("%d\n", cycle);
	};

  m_trace->close();
  // top->final();

#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

  delete dut;
  exit(EXIT_SUCCESS);
}
