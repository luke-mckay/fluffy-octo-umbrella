; SPDX-License-Identifier: LGPL-2.1-or-later
;
; 6502 Compatible Processor Test Code
; Targets Documented 6502 Commands
; Copyright 2022, Luke E. McKay.
;
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
;
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
;
; You should have received a copy of the GNU Lesser General Public
; License along with this library; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
; USA

; **************************************************************
; 64TASS
; cpu65xxTests.asm

; *************************************************************
*       = $02
        .dsection zp   ;declare zero page section
        .cerror * > $30, "Too many zero page variables"

*       = $334
        .dsection bss   ;declare uninitialized variable section
        .cerror * > $400, "Too many variables"

*       = $0801
        .dsection code   ;declare code section
        .cerror * > $1000, "Program too long!"

*       = $1000
        .dsection data   ;declare data section
        .cerror * > $2000, "Data too long!"

*       = $FFF0
        .dsection vectors ;declar vectors section
;        .cerror * > $10, "Vectors too long!"

;−−−−−−−−−−−−−−−−−−−−
        .section code
        NOP
; Immediate operations  (rough)
;  11     ADC, AND, CMP, CPX, CPY, EOR, LDA, LDX, LDY, ORA, SBC
;  11    0x69,0x29,0xC9,0xE0,0xC0,0x49,0xA9,0xA2,0xA0,0x09,0xE9
        LDA $FF
        LDX $FF
        LDY $FF
        LDA $55
        LDX $55
        LDY $CC
        CMP $A5
        CPX $A5
        CPY $A5
        CMP $55
        CPX $55
        CPY $CC
        ADC $11
        CMP $66
        SBC $05
        CMP $61
        ORA $0A
        CMP $6A
        EOR $FF
        CMP $95
        AND $0F
        CMP $95
; Implied operations  (rough)
;  17      CLC, CLD, CLI, CLV, DEX, DEY, INX, INY, SEC, SED, SEI, TAX, TAY,
;  17     0x18,0xD8,0x58,0xB8,0xCA,0x88,0xE8,0xC8,0x38,0xF8,0x78,0xAA,0xA8
;          TYA, TSX, TXA, TXS
;         0x98,0xBA,0x8A,0x9A
;          Tested elsewhere *BRK,*NOP,*PHA,*PHP,*PLA,*PLP,*RTI,*RTS
        CLC
        CLD
        CLI
        CLV
        INX
        CPX $56
        INY
        CPY $CD
        DEX
        CPX $55
        DEY
        CPY $CC
        TYA
        CMP $CC
        TAX
        CPX $CC
        TXS
        LDA $00
        LDX $00
        TAY
        TSX
        TXA
        CMP $CC
        SEC
        SED
        LDA $55
        ADC $35
        SEI
        CLC
        CLD
        CLI

        .section data   ;some data
label   .null "message"
        .send data

        ;jmp error
        .section zp     ;declare some more zero page variables
p3      .addr ?         ;a pointer
        .send zp
        .send code

        .section vectors
        .byte $00
        .byte $01
        .byte $02
        .byte $03
        .byte $04
        .byte $05
        .byte $06
        .byte $07
        .byte $08
        .byte $09
        .byte $0A
        .byte $0B
        .byte $0C
        .byte $0D
        .byte $0E
        .byte $0F
        .send vectors
