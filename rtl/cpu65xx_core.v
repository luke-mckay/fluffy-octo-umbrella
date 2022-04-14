// SPDX-License-Identifier: Apache-2.0
/*
 * Copyright 2022, Luke E. McKay.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * MCS6500 Compatible MicroComputer
 * Version 0.0.0
 * Core section of microcomputer.
 */
module cpu65xx_core
#(
  parameter pAddrWidth     = 16,     ///< ADDR width, set to 24 for 65C816
  parameter pRorBugEn      = 0,      ///< Enable ROR bug from original NMOS  6502
  parameter pDecimalEn     = 0,      ///< Disable decimal mode               2A03
  parameter pIsCmosEn      = 0,      ///< CMOS instructions enable           65SC02
  parameter pIsBitsEn      = 0,      ///< CMOS bit instructions enable       65C02
  parameter pIsWdcPwrEn    = 0,      ///< CMOS WDC power instructions        65C02
  parameter pIs16bEn       = 0,      ///< CMOS enable 16-bit mode            65C802
  parameter pIsCeEn        = 0,      ///< CMOS 65CExx instructions enable    65CE02
  parameter pIsElEn        = 0,      ///< Virtual Mindcraft
  parameter pIs740En       = 0,      ///< 740 Family insurctions enable
  parameter pIsDtvEn       = 0,      ///< 65DTVxx instructions enable
  parameter pAsyncBus      = 1,      ///< Original async bus operation
  parameter pClkConfig     = 0,      ///< Original, DualPhaseSingleClock, HalfSpeedSingleClock, Latches,
  parameter pDbgMuxEn      = 1       ///< Debug output multiplexer enable
)(
  //# {{clocks|}}
  input  wire        Clk,         ///<  clock    - PHI1_IN
  input  wire        Rst_n,        ///< Reset                  - RES
  //# {{data bus|}}
  output wire [15:0] Addr,         ///< Address Bus            - Ax
  output wire        W_n,          ///< Data Direction         - R/W
  output wire  [7:0] Wdata,        ///< Output Data Bus        - DBx
  input  wire  [7:0] Rdata,        ///< Input Data Bus         - DBx
  input  wire        Dbe,          ///< Data Bus Enable        - DBE
  input  wire        Ml,           ///< Memory Lock         65C02 - ML
  input  wire        Be,           ///< Bus Enable         65C816 - BE
  output wire        Mx,           ///< Mem/Idx Sel Status 65C816 - MX
  output wire        ValidDataAddr,          ///< Valid Data Addr    65C816 - VDA
  output wire        ValidProgramVect,          ///< Vector Pull        65C816 - VPB
  output wire        ValidProgramAddr,          ///< Valid Program Addr 65C816 - VPA
  //# {{control & status signals|}}
  input  wire        Irq_n,        ///< Interrupt Request      - IRQ
  input  wire        Nmi_n,        ///< Non-Maskable Interrupt - NMI
  input  wire        Rdy,          ///< Ready                  - RDY
  output wire        Sync,         ///< Sync                   - SYNC
  input  wire        So_n,         ///< Set Overflow Flag      - S.O.
  input  wire        Abort_n,     ///< Abort              65C816 - ABORTB
  input  wire        Emulaiton,            ///< Emulation          65C816 - E
  //# {{debug bus|}}
  output wire  [7:0] DebugMux,      ///< Debug output bus       - Custom
  input  wire  [4:0] DebugMuxSel   ///< Debug output selection - Custom
);

endmodule
