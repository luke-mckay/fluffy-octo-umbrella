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

// Test 1: PC increments
//  1      NOP
//         Fill memory with NOPs
//         Make sure PC will increment through all addresses
//         Allow wrap to occur
//         Pass if all addresses are hit and wrap occurs
// Test 2: Immediate operations
//  11     ADC, AND, CMP, CPX, CPY, EOR, LDA, LDX, LDY, ORA, SBC
//  11    0x69,0x29,0xC9,0xE0,0xC0,0x49,0xA9,0xA2,0xA0,0x09,0xE9
//         + & = | ^ - ==
//         A=0x00  0x00
//         X=0x10  0x02
//         Y=0x80  0x04
//         A+=0x11 0x06
//         A==0x11 0x08
//         A+=0xF0 0x0A
//         A==0x01 0x0C
//         A|=0xF6 0x0E
//         A&=0xAA 0x10
//         A==0xA3 0x12
//         A==0xA2 0x14
//         A^=0xFF 0x16
//         A==0x5C 0x18
//         A==0x5D 0x1A
//         X==0x10 0x1C
//         Y==0x40 0x1D
//         X==0x11 0x1E
//         Y==0x80 0x20
//                 0x22
// Test 3:  Implied operations
//  17      CLC, CLD, CLI, CLV, DEX, DEY, INX, INY, SEC, SED, SEI, TAX, TAY,
//  17     0x18,0xD8,0x58,0xB8,0xCA,0x88,0xE8,0xC8,0x38,0xF8,0x78,0xAA,0xA8
//          TYA, TSX, TXA, TXS
//         0x98,0xBA,0x8A,0x9A
//          Tested elsewhere *BRK,*NOP,*PHA,*PHP,*PLA,*PLP,*RTI,*RTS
// Test 4:  Zero page operations
//  10      ASL, BIT, DEC, INC, LSR, ROL, ROR, STA, STX, STY
//  21     0x06,0x24,0xC6,0xE6,0x46,0x26,0x66,0x85,0x86,0x84
//          Tested also *ADC,*AND,*CMP,*CPX,*CPY,*EOR,*LDA,*LDX,*LDY,*ORA,*SBC
// Test 5:  Stack operations
//  4       PHA, PHP, PLA, PLP
//  4      0x48,0x08,0x68,0x28
// Test 6:  Program control operations
//  8       BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
//  8      0x90,0xB0,0xF0,0x30,0xD0,0x10,0x50,0x70
// Test 7:  Interrupts
//  4       BRK, IRQ, NMI, RTI
//  4       Signal tested as instruction *RES
// Test 8:  Absolute operations
//  0      *ADC,*AND,*ASL,*BIT,*CMP,*CPX,*CPY,*DEC,*EOR,*INC,*LDA,*LDX,
//  21     *LDY,*LSR,*ORA,*ROL,*ROR,*SBC,*STA,*STX,*STY
// Test 9:  Program control operaitons part 2
//  3       JMP, JSR, RTS
//  3      0x4C,0x20,0x60

 // Test 10: Indirect
//          JMP indirect
//  1      0x6C

module cr_tb_cpu65xx();

localparam ADDR_MAX = 15; // 16-1, starts at zero


wire                    i_phi1;
wire                    i_phi2;
reg                     i_res_n;
reg                     i_irq_n;
reg                     i_nmi_n;
wire    [ADDR_MAX:0]    o_addr;
wire                    o_sync;
wire                    o_r_w;
wire           [7:0]    o_wdata;
reg                     i_rdy;
reg            [7:0]    i_rdata;
reg                     i_dbe;
reg                     i_so_n;
reg        i_be;           ///< Bus Enable             - BE
reg        i_ml;           ///< Memory Lock         65C02 - ML
reg        i_abortb_n;     ///< Abort              65C816 - ABORTB
reg        i_e;            ///< Emulation          65C816 - E
wire        o_mx;           ///< Mem/Idx Sel Status 65C816 - MX
wire        o_vda;          ///< Valid Data Addr    65C816 - VDA
wire        o_vpb;          ///< Vector Pull        65C816 - VPB
wire        o_vpa;          ///< Valid Program Addr 65C816 - VPA
wire     [7:0]   o_dbg_mux;
reg      [4:0]  i_dbg_mux_sel;

cpu_65xx cpu0 (
    .i_phi1        (i_phi1),
    .i_phi2        (i_phi2),
    .i_res_n       (i_res_n),
    .i_irq_n       (i_irq_n),
    .i_nmi_n       (i_nmi_n),
    .i_rdy         (i_rdy),
    .o_addr        (o_addr),
    .o_r_w         (o_r_w),
    .o_wdata       (o_wdata),
    .i_rdata       (i_rdata),
    .o_sync        (o_sync),
    .i_so_n        (i_so_n),
    .i_dbe         (i_dbe),
    .i_ml          (i_ml),
    .i_be          (i_be),
    .i_abortb_n    (i_abortb_n),
    .i_e           (i_e),
    .o_mx          (o_mx),
    .o_vda         (o_vda),
    .o_vpb         (o_vpb),
    .o_vpa         (o_vpa),
    .o_dbg_mux     (o_dbg_mux),
    .i_dbg_mux_sel (i_dbg_mux_sel)
);


// ********** BIPHASE CLOCK CREATION **********
localparam PERIOD = 500;

reg clk;
reg clk2;
reg clk3;

initial begin
    $dumpfile("db_tb_cpu_65xx.vcd");
    $dumpvars(0, tb_cpu_65xx);
    clk = 1'b0;
    #(PERIOD/2);
    forever begin
        #(PERIOD/2) clk = ~clk;
        clk2 <= #15 clk;
        clk3 <= #(PERIOD-1) clk;
    end
end

assign i_phi1 = (clk2 & clk3);
assign i_phi2 = !clk;
// ******** BIPHASE CLOCK CREATION END ********


// ******** BIPHASE CLOCK CREATION END ********
reg [15:0] cycle;

initial
begin
    cycle = 0;
end

always @(posedge i_phi1)
begin
    cycle = cycle + 1;
end
// ******** BIPHASE CLOCK CREATION END ********


// *************** MEMORY SETUP ***************
reg [7:0] memArray [1024:0];
wire [9:0] local_addr = o_addr > 1024 ? o_addr-/*65280 65024*/64512 : o_addr;
wire [7:0] value3ff = memArray[1023];
wire [7:0] value1ff = memArray[511];
wire [7:0] value1fe = memArray[510];
initial begin
    memArray[1023] <= 8'h00; // FF
    memArray[1022] <= 8'd176;// FE
    memArray[1021] <= 8'h00; // FD
    memArray[1020] <= 8'h01; // FC
    memArray[1019] <= 8'h00; // FB
    memArray[1018] <= 8'd176; // FA
    memArray[1017] <= 8'h00; // F9
    memArray[1016] <= 8'h00; // F8
    memArray[1015] <= 8'h02;
    memArray[1014] <= 8'h03;
    memArray[1013] <= 8'h04;
    memArray[1012] <= 8'h05;
    memArray[1011] <= 8'h06;
    memArray[511]  <= 8'h00;
    memArray[510]  <= 8'h00;
    memArray[509]  <= 8'h00;
    memArray[508]  <= 8'h00;
    memArray[507]  <= 8'h00;
    memArray[506]  <= 8'h00;
    memArray[505]  <= 8'h00;
    memArray[504]  <= 8'h00;
    memArray[503]  <= 8'h00;
    memArray[502]  <= 8'h00;
    memArray[501]  <= 8'h00;
    memArray[500]  <= 8'h00;
    memArray[499]  <= 8'h00;
    memArray[498]  <= 8'h00;
    memArray[0]   <= 8'hEA;  // NOP              1
    memArray[1]   <= 8'hA0;  // LDY immediate    2
    memArray[2]   <= 8'h44;
    memArray[3]   <= 8'hEA;  // NOP
    memArray[4]   <= 8'hA9;  // LDA immediate    3
    memArray[5]   <= 8'hAA;
    memArray[6]   <= 8'hA2;  // LDX immediate    4
    memArray[7]   <= 8'hff;
    memArray[8]   <= 8'h9A;  // TXS              5
    memArray[9]   <= 8'hA2;  // LDX immediate
    memArray[10]  <= 8'h55;
    memArray[11]  <= 8'h2A;  // ROL accumulator  6
    memArray[12]  <= 8'h0A;  // ASL accumulator  7
    memArray[13]  <= 8'h4A;  // LSR accumulator  8
    memArray[14]  <= 8'h6A;  // ROR accumulator  9
    memArray[15]  <= 8'h18;  // SEC             10
    memArray[16]  <= 8'h38;  // CLC             11
    memArray[17]  <= 8'h78;  // SEI             12
    memArray[18]  <= 8'h58;  // CLI             13
    memArray[19]  <= 8'hF8;  // SED             14
    memArray[20]  <= 8'hD8;  // CLD             15
    memArray[21]  <= 8'hB8;  // CLV             16
    memArray[22]  <= 8'h00;  // BRK             17 of 56    30.3%
    memArray[23]  <= 8'hEA;  // NOP
    memArray[24]  <= 8'hCA;  // DEX             18
    memArray[25]  <= 8'h88;  // DEY             19
    memArray[26]  <= 8'hE8;  // INX             20
    memArray[27]  <= 8'hC8;  // INY             21
    memArray[28]  <= 8'hAA;  // TAX             22
    memArray[29]  <= 8'hA8;  // TAY             23
    memArray[30]  <= 8'hBA;  // TSX             24
    memArray[31]  <= 8'hA9;  // LDA immediate
    memArray[32]  <= 8'h55;
    memArray[33]  <= 8'h98;  // TYA             25
    memArray[34]  <= 8'h08;  // PHP             26
    memArray[35]  <= 8'h48;  // PHA             27
    memArray[36]  <= 8'h28;  // PLP             28
    memArray[37]  <= 8'h68;  // PLA             29 of 56    51.7%
    memArray[38]  <= 8'h8A;  // TXA             30
    memArray[39]  <= 8'h69;  // ADC immediate   31
    memArray[40]  <= 8'h23;
    memArray[41]  <= 8'h29;  // AND immediate   32
    memArray[42]  <= 8'h20;
    memArray[43]  <= 8'hA9;  // LDA immediate
    memArray[44]  <= 8'h23;
    memArray[45]  <= 8'hc9;  // CMP immediate   34
    memArray[46]  <= 8'h23;
    memArray[47]  <= 8'hA9;  // LDA immediate
    memArray[48]  <= 8'h22;
    memArray[49]  <= 8'hc9;  // CMP immediate
    memArray[50]  <= 8'h23;
    memArray[51]  <= 8'hE0;  // CPX immediate   35
    memArray[52]  <= 8'h23;
    memArray[53]  <= 8'hC0;  // CPY immediate   36
    memArray[54]  <= 8'h23;
    memArray[55]  <= 8'h49;  // EOR immediate   37
    memArray[56]  <= 8'h55;
    memArray[57]  <= 8'h09;  // ORA immediate   38
    memArray[58]  <= 8'h55;
    memArray[59]  <= 8'hE9;  // SBC immediate   39
    memArray[60]  <= 8'h55;
    memArray[61]  <= 8'h65;  // ADC zero page        now cycle 126NMIremoved   cycle 145
    memArray[62]  <= 8'h03;
    memArray[63]  <= 8'h25;  // AND zero page
    memArray[64]  <= 8'h03;
    memArray[65]  <= 8'h24;  // BIT zero page   33
    memArray[66]  <= 8'h03;
    memArray[67]  <= 8'hC5;  // CMP zero page
    memArray[68]  <= 8'h03;
    memArray[69]  <= 8'hE4;  // CPX zero page
    memArray[70]  <= 8'h03;
    memArray[71]  <= 8'hC4;  // CPY zero page
    memArray[72]  <= 8'h03;
    memArray[73]  <= 8'h45;  // EOR zero page
    memArray[74]  <= 8'h03;
    memArray[75]  <= 8'h05;  // ORA zero page
    memArray[76]  <= 8'h03;
    memArray[77]  <= 8'hE5;  // SBC zero page
    memArray[78]  <= 8'h03;
    memArray[79]  <= 8'h6D;  // ADC absolute            cycle 172
    memArray[80]  <= 8'h03;
    memArray[81]  <= 8'h00;
    memArray[82]  <= 8'h2D;  // AND absolute
    memArray[83]  <= 8'h03;
    memArray[84]  <= 8'h00;
    memArray[85]  <= 8'h2C;  // BIT absolute
    memArray[86]  <= 8'h03;
    memArray[87]  <= 8'h00;
    memArray[88]  <= 8'hCD;  // CMP absolute
    memArray[89]  <= 8'h03;
    memArray[90]  <= 8'h00;
    memArray[91]  <= 8'hEC;  // CPX absolute
    memArray[92]  <= 8'h03;
    memArray[93]  <= 8'h00;
    memArray[94]  <= 8'hCC;  // CPY absolute
    memArray[95]  <= 8'h03;
    memArray[96]  <= 8'h00;
    memArray[97]  <= 8'h4D;  // EOR absolute
    memArray[98]  <= 8'h03;
    memArray[99]  <= 8'h00;
    memArray[100] <= 8'h0D;  // ORA absolute
    memArray[101] <= 8'h03;
    memArray[102] <= 8'h00;
    memArray[103] <= 8'hED;  // SBC absolute
    memArray[104]  <= 8'h03;
    memArray[105]  <= 8'h00;
    memArray[106]  <= 8'h85;  // STA zero page   40
    memArray[107]  <= 8'h05;
    memArray[108]  <= 8'h86;  // STX zero page   41
    memArray[109]  <= 8'h05;
    memArray[110]  <= 8'h84;  // STY zero page   42
    memArray[111]  <= 8'h05;
    memArray[112]  <= 8'h8D;  // STA absolute
    memArray[113]  <= 8'h05;
    memArray[114]  <= 8'h00;
    memArray[115]  <= 8'h8E;  // STX absolute
    memArray[116]  <= 8'h05;
    memArray[117]  <= 8'h00;
    memArray[118]  <= 8'h8C;  // STY absolute
    memArray[119]  <= 8'h05;
    memArray[120]  <= 8'h00;
    memArray[121]  <= 8'h06;  // ASL zero page         cycle 209 w/NMIoff      cycle 231           (was 268)
    memArray[122]  <= 8'h05;
    memArray[123]  <= 8'hC6;  // DEC zero page   43
    memArray[124]  <= 8'h05;
    memArray[125]  <= 8'hE6;  // INC zero page   56
    memArray[126]  <= 8'h05;
    memArray[127]  <= 8'h46;  // LSR zero page
    memArray[128]  <= 8'h05;
    memArray[129]  <= 8'h26;  // ROL zero page
    memArray[130]  <= 8'h05;
    memArray[131]  <= 8'h66;  // ROR zero page
    memArray[132]  <= 8'h05;
    memArray[133]  <= 8'h0E;  // ASL absolute
    memArray[134]  <= 8'h05;
    memArray[135]  <= 8'h00;
    memArray[136]  <= 8'hCE;  // DEC absolute
    memArray[137]  <= 8'h05;
    memArray[138]  <= 8'h00;
    memArray[139]  <= 8'hEE;  // INC absolute
    memArray[140]  <= 8'h05;
    memArray[141]  <= 8'h00;
    memArray[142]  <= 8'h4E;  // LSR absolute
    memArray[143]  <= 8'h05;
    memArray[144]  <= 8'h00;
    memArray[145]  <= 8'h2E;  // ROL absolute
    memArray[146]  <= 8'h05;
    memArray[147]  <= 8'h00;
    memArray[148]  <= 8'h6E;  // ROR absolute            cycle 276 w/NMIoff
    memArray[149]  <= 8'h05;
    memArray[150]  <= 8'h00;
    memArray[151]  <= 8'h90;  // BCC             44
    memArray[152]  <= 8'h10;
    memArray[153]  <= 8'hB0;  // BCS             45        // cycle 282 w/NMI off  //@todo fix fix
    memArray[154]  <= 8'h0C;                           // modified to jump up to the jmp absolute
    memArray[155]  <= 8'hF0;  // BEQ             46
    memArray[156]  <= 8'h10;
    memArray[157]  <= 8'h30;  // BMI             47
    memArray[158]  <= 8'h10;
    memArray[159]  <= 8'hD0;  // BNE             48
    memArray[160]  <= 8'h10;
    memArray[161]  <= 8'h10;  // BPL             49
    memArray[162]  <= 8'h10;
    memArray[163]  <= 8'h50;  // BVC             50
    memArray[164]  <= 8'h10;
    memArray[165]  <= 8'h70;  // BVS             51
    memArray[166]  <= 8'h10;
    memArray[167]  <= 8'h4C;  // JMP absolute    52
    memArray[168]  <= 8'h00;
    memArray[169]  <= 8'h00;
    memArray[170]  <= 8'h6C;  // JMP indirect
    memArray[171]  <= 8'hFF;
    memArray[172]  <= 8'hFC;
    memArray[173]  <= 8'h20;  // JSR             53
    memArray[174]  <= 8'h05;
    memArray[175]  <= 8'h01;
    memArray[176]  <= 8'hEA;  // NOP
    memArray[177]  <= 8'hEA;  // NOP
    memArray[178]  <= 8'hEA;  // NOP
    memArray[179]  <= 8'hEA;  // NOP
    memArray[180]  <= 8'hEA;  // NOP
    memArray[181]  <= 8'h40;  // RTI             54
    memArray[182]  <= 8'h60;  // RTS             55
    memArray[183]  <= 8'hEA;  // NOP
    memArray[184]  <= 8'hEA;  // NOP
    memArray[185]  <= 8'hEA;  // NOP


    memArray[191]  <= 8'h55;  // test needs value
    // memArray[39]  <= 8'h  ;  // ASL zero page,x
    // memArray[39]  <= 8'h  ;  // DEC zero page,x
    // memArray[39]  <= 8'h  ;  // INC zero page,x
    // memArray[39]  <= 8'h  ;  // LSR zero page,x
    // memArray[39]  <= 8'h  ;  // ROL zero page,x
    // memArray[39]  <= 8'h  ;  // ROR zero page,x
    // memArray[39]  <= 8'h  ;  // ASL absolute,x
    // memArray[39]  <= 8'h  ;  // DEC absolute,x
    // memArray[39]  <= 8'h  ;  // INC absolute,x
    // memArray[39]  <= 8'h  ;  // LSR absolute,x
    // memArray[39]  <= 8'h  ;  // ROL absolute,x
    // memArray[39]  <= 8'h  ;  // ROR absolute,x
    // memArray[39]  <= 8'h  ;  // STA indirect,x
    // memArray[39]  <= 8'h  ;  // STX indirect,x
    // memArray[39]  <= 8'h  ;  // STY indirect,x
    // memArray[39]  <= 8'h  ;  // STA absolute,x/y
    // memArray[39]  <= 8'h  ;  // STX absolute,x/y
    // memArray[39]  <= 8'h  ;  // STY absolute,x/y
    // memArray[39]  <= 8'h  ;  // STA zero page,x/y
    // memArray[39]  <= 8'h  ;  // STX zero page,x/y
    // memArray[39]  <= 8'h  ;  // STY zero page,x/y
    // memArray[39]  <= 8'h  ;  // STA indirect,y
    // memArray[39]  <= 8'h  ;  // STX indirect,y
    // memArray[39]  <= 8'h  ;  // STY indirect,y
    // memArray[39]  <= 8'h  ;  // ADC indirect,x
    // memArray[39]  <= 8'h  ;  // AND indirect,x
    // memArray[39]  <= 8'h  ;  // BIT indirect,x
    // memArray[39]  <= 8'h  ;  // CMP indirect,x
    // memArray[39]  <= 8'h  ;  // CPX indirect,x
    // memArray[39]  <= 8'h  ;  // CPY indirect,x
    // memArray[39]  <= 8'h  ;  // EOR indirect,x
    // memArray[39]  <= 8'h  ;  // ORA indirect,x
    // memArray[39]  <= 8'h  ;  // SBC indirect,x
    // memArray[39]  <= 8'h  ;  // ADC absolute,x/y
    // memArray[39]  <= 8'h  ;  // AND absolute,x/y
    // memArray[39]  <= 8'h  ;  // BIT absolute,x/y
    // memArray[39]  <= 8'h  ;  // CMP absolute,x/y
    // memArray[39]  <= 8'h  ;  // CPX absolute,x/y
    // memArray[39]  <= 8'h  ;  // CPY absolute,x/y
    // memArray[39]  <= 8'h  ;  // EOR absolute,x/y
    // memArray[39]  <= 8'h  ;  // ORA absolute,x/y
    // memArray[39]  <= 8'h  ;  // SBC absolute,x/y
    // memArray[39]  <= 8'h  ;  // ADC zero page,x/y
    // memArray[39]  <= 8'h  ;  // AND zero page,x/y
    // memArray[39]  <= 8'h  ;  // BIT zero page,x/y
    // memArray[39]  <= 8'h  ;  // CMP zero page,x/y
    // memArray[39]  <= 8'h  ;  // CPX zero page,x/y
    // memArray[39]  <= 8'h  ;  // CPY zero page,x/y
    // memArray[39]  <= 8'h  ;  // EOR zero page,x/y
    // memArray[39]  <= 8'h  ;  // ORA zero page,x/y
    // memArray[39]  <= 8'h  ;  // SBC zero page,x/y
    // memArray[39]  <= 8'h  ;  // ADC indirect,y
    // memArray[39]  <= 8'h  ;  // AND indirect,y
    // memArray[39]  <= 8'h  ;  // BIT indirect,y
    // memArray[39]  <= 8'h  ;  // CMP indirect,y
    // memArray[39]  <= 8'h  ;  // CPX indirect,y
    // memArray[39]  <= 8'h  ;  // CPY indirect,y
    // memArray[39]  <= 8'h  ;  // EOR indirect,y
    // memArray[39]  <= 8'h  ;  // ORA indirect,y
    // memArray[39]  <= 8'h  ;  // SBC indirect,y

end

always @(local_addr) begin
//    #(10);
//    i_rdata = 8'hzz;
    i_rdata = /*#(PERIOD-PERIOD/3)*/ memArray[local_addr];
end

always @(negedge i_phi1)
begin
    if ((o_r_w == 1'b0) & i_res_n)
    begin
        memArray[local_addr] <= o_wdata;
    end
end

//wire [7:0] testFF = memArray[16'hFFFF];
//wire [7:0] testFE = memArray[16'hFFFE];
// ************* MEMORY SETUP END *************

initial begin
    #(PERIOD*1); // initial values
    i_dbg_mux_sel = 5'h19;
    i_res_n = 0;
    i_irq_n = 0;
    i_nmi_n = 0;
    i_rdy   = 0;
    i_so_n  = 0;
    #(PERIOD*1); // initial values after a clock of nothing
    i_res_n = 0;
    i_irq_n = 1;
    i_nmi_n = 1;
    i_rdy   = 1;
    i_so_n  = 1;
    #(PERIOD*2);
    i_res_n = 1; // deassert reset after required wait
    #(20*PERIOD);
    //i_nmi_n = 0;
    #(20*PERIOD);
    //i_nmi_n = 1;
    #(350*PERIOD);
    $finish(3);
end

// Table of outputs
// cycle  ab   db rw  Fetch   pc  a  x  y  s     p     Execute State ir tcstate pd adl adh sb alu Execute State res                          plaOutputs                                                                                    DPControl
//   0   0000  a2 1   LDX #  0000 aa 00 00 fd nv‑BdIZc   BRK     T1  00 101111  00  00  00 ff  00   BRK     T1   1                          brk/rti,SUMS                                               ADL/ABL,ADH/ABH,SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,ADHPCH,ADLPCL,DL/ADH,DL/DB
//   0   0000  a2 1   LDX #  0000 aa 00 00 fd nv‑BdIZc   BRK     T1  00 101111  a2  01  00 ff  ff   BRK     T1   1                          brk/rti,SUMS                                                     ADL/ABL,ADH/ABH,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHADH,PCLADL
//                                                                                                                 T0‑cpx/inx,T2,T0,T0‑cpx/cpy/inx/iny,T2‑abs‑access,implied,SUMS  ADL/ABL,ADH/ABH,SBX,SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,ADHPCH,PCHADH,#IPC,~IPC,PCLADL,ADLPCL

initial begin
  //  #(43*PERIOD)
  //  $finish;
end

endmodule  // cr_tb_cpu65xx
