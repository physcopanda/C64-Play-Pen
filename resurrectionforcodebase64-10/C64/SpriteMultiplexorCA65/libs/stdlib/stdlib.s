; Zero page

; Each enabled bit sets read and write on the processor port (ZPProcessorPort) otherwise the value can just be read.
; Default: $2F, %101111
ZPProcessorPortDDR				= $00
ProcessorPortDDRDefault			= %101111

; Bits 0-2: Configuration for memory areas $A000-$BFFF, $D000-$DFFF and $E000-$FFFF. Values:
; %x00: RAM visible in all three areas.
; %x01: RAM visible at $A000-$BFFF and $E000-$FFFF.
; %x10: RAM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
; %x11: BASIC ROM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF.
; %0xx: Character ROM visible at $D000-$DFFF. (Except for the value %000, see above.)
; %1xx: I/O area visible at $D000-$DFFF. (Except for the value %100, see above.)
; Bit 3: Datasette output signal level.
; Bit 4: Datasette button status; 0 = One or more of PLAY, RECORD, F.FWD or REW pressed; 1 = No button is pressed.
; Bit 5: Datasette motor control; 0 = On; 1 = Off.
; Default: $37, %110111
ZPProcessorPort					= $01
ProcessorPortDefault			= %110111
ProcessorPortAllRAMWithIO		= %100101
ProcessorPortAllRAM				= %100000

; $02 - $06 are unused (apparently).

; $07 - $2a are only really used during BASIC execution.

; By default contains $0801
ZPStartBasicLo					= $2b
ZPStartBasicHi					= $2c

ZPStartVariableLo				= $2d
ZPStartVariableHi				= $2e

ZPStartArrayVariableLo			= $2f
ZPStartArrayVariableHi			= $30

ZPEndArrayVariableLo			= $31
ZPEndArrayVariableHi			= $32

ZPStartStringVariableLo			= $33
ZPStartStringVariableHi			= $34

ZPCurrentStringVariableLo		= $35
ZPCurrentStringVariableHi		= $36

ZPEndBasicLo					= $37
ZPEndBasicHi					= $38

; $39 - $72 are only really used during BASIC execution.

; $73 - $8a
ZPChrGet						= $73

; $8b - $8f are only really used during BASIC execution.

; Also used for datasette status
ZPSTVariable					= $90

ZPStopKeyIndicator				= $91
ZPDatasetteTiming				= $92
ZPLoadVerify					= $93
ZPSerialBusCacheStatus			= $94
ZPSerialBusCache				= $95
ZPDatasetteEndOfTape			= $96
ZPRS232XYTemp					= $97
ZPNumFilesOpen					= $98
ZPCurrentInputDevice			= $99
ZPCurrentOutputDevice			= $9a
ZPDatasetteParity				= $9b
ZPDatasetteByteReady			= $9c
ZPDisplaySystemErrorSwitch		= $9d
ZPRS232OutByte					= $9e
ZPDatasetteNameWriteCount		= $9f
ZPTimeOfDay						= $a0		; $a0 - a2
ZPEOISerialBusSwitch			= $a3
ZPSerialBusBuffer				= $a4
ZPSerialBusBitCounter			= $a5
ZPDatasetteBufferOffset			= $a6
ZPRS232BusBuffer				= $a7
ZPRS232BusBitCounter			= $a8
ZPRS232StopBitSwitch			= $a9
ZPRS232ByteBuffer				= $aa
ZPRS232Parity					= $ab
ZPAddressToSave					= $ac		; $ac - ad
ZPAddressToLoad					= $ae		; $ae - af

; $b0 - $b1 Tape timing constants
ZPTapeTimingConstant			= $b0

ZPDatasetteBufferLo				= $b2
ZPDatasetteBufferHo				= $b3
ZPRS232BitCounter				= $b4
ZPRS232BitBuffer				= $b5

ZPCurrentFileDeviceNumber		= $ba		; Usually the last used device to load a file.

; $b7 - $c4 Various file operation working area

ZPPrevKeyPressed				= $c5
ZPKeyBufferLength				= $c6

; $c7 - $ca Various cursor operations

ZPCurrentKeyPressed				= $cb

; $cc - $f6 Various cursor, screen and keyboard conversion tables

; $f7 - $fa RS232 input and output buffers
RS232InputBufferLo				= $f7
RS232InputBufferHi				= $f8
RS232OutputBufferLo				= $f9
RS232OutputBufferHi				= $fa

; $fb - $fe unused

ProcessorStack					= $0100		; $0100 - $01ff

; $0200 - $0292 Various keyboard buffers and buffers used by BASIC
FlagUpperLowerCaseChange		= $0291		; $80 = Keyboard or chr$(8) does not change upper/lower case

; $0293 - $02ff RS232 and datasette control and buffers

; $0300 - $0312 Used by BASIC

; $0313 unused

DefaultIRQServiceRoutine		= $ea31
MinimalIRQServiceRoutine		= $ea81
IRQServiceRoutineLo				= $0314
IRQServiceRoutineHi				= $0315

; Default = $fe66
BRKServiceRoutineLo				= $0316
BRKServiceRoutineHi				= $0317

DefaultNMIServiceRoutine		= $fe47
NMIServiceRoutineLo				= $0318
NMIServiceRoutineHi				= $0319

DefaultSTOPVector				= $f6ed
STOPVectorLo					= $0328
STOPVectorHi					= $0329

; $031a - $0333 Various vectors for standard routines like open, close, load, save etc

DefaultLOADRoutine				= $f4a5
LoadRoutineLo					= $0330
LoadRoutineHi					= $0331

DefaultSaveRoutine				= $f5ed
SaveRoutineLo					= $0332
SaveRoutineHi					= $0333

; $0334 - $033b unused

; $033c - $03fb Datasette buffer

; $03fc - $03ff unused



; Special memory sections

BASICSTART= $0801			; Default is memory PEEK(43) = 1 and PEEK(44) = 8
SCREENRAM = $0400
SPRITEFRAME = $07f8
BASICROM  = $A000
VIC       = $D000
SID       = $D400
COLORRAM  = $D800
COLOURRAM = $D800
CIA1      = $DC00
CIA2      = $DD00
KERNALROM = $E000

; KERNAL routines

CLRSCR		= $e544
HEADERex	= $F76A

ACPTR   = $FFA5
CHKIN   = $FFC6
CHKOUT  = $FFC9
CHRIN   = $FFCF
CHROUT  = $FFD2
CIOUT   = $FFA8
CINT    = $FF81
CLALL   = $FFE7
CLOSE   = $FFC3
CLRCHN  = $FFCC
GETIN   = $FFE4
IOBASE  = $FFF3
IOINIT  = $FF84
LISTEN  = $FFB1
LOAD    = $FFD5
MEMBOT  = $FF9C
MEMTOP  = $FF99
OPEN    = $FFC0
PLOT    = $FFF0
RAMTAS  = $FF87
RDTIM   = $FFDE
READST  = $FFB7
RESTOR  = $FF8A
SAVE    = $FFD8
SCNKEY  = $FF9F
SCREEN  = $FFED
SECOND  = $FF93
SETLFS  = $FFBA
SETMSG  = $FF90
SETNAM  = $FFBD
SETTIM  = $FFDB
SETTMO  = $FFA2
STOP    = $FFE1
TALK    = $FFB4
TKSA    = $FF96
UDTIM   = $FFEA
UNLSN   = $FFAE
UNTLK   = $FFAB
VECTOR  = $FF8D

; KERNAL Vectors

; Default = $fe43
KERNALNMIServiceRoutineLo		= $fffa
KERNALNMIServiceRoutineHi		= $fffb

; Default = $fce2
KERNALColdStartResetLo			= $fffc
KERNALColdStartResetHi			= $fffd

; Default = $ff48
KERNALIRQServiceRoutineLo		= $fffe
KERNALIRQServiceRoutineHi		= $ffff

; Specific locations within the custom chips

; VIC II Video chip
VIC2Sprite0X					= $d000
VIC2Sprite0Y					= $d001
VIC2Sprite1X					= $d002
VIC2Sprite1Y					= $d003
VIC2Sprite2X					= $d004
VIC2Sprite2Y					= $d005
VIC2Sprite3X					= $d006
VIC2Sprite3Y					= $d007
VIC2Sprite4X					= $d008
VIC2Sprite4Y					= $d009
VIC2Sprite5X					= $d00a
VIC2Sprite5Y					= $d00b
VIC2Sprite6X					= $d00c
VIC2Sprite6Y					= $d00d
VIC2Sprite7X					= $d00e
VIC2Sprite7Y					= $d00f

; Each bit is the X MSB for each sprite.
VIC2SpriteXMSB					= $d010

; Bits 0-2 Vertical scroll.
; 3 Screen height 0 = 24 rows last line 246 (f6) : 1 = 25 rows last line $fa (250)
; 4 0 = Screen off 1 = Screen on
; 5 0 = Text mode 1 = Bitmap mode
; 6 1 = Extended background mode on
; 7 Read: Current raster line position bit 9. Write: Bit 9 of raster line position to generate next interrupt.
; Default: $1b, %00011011
VIC2ScreenControlVDefault		= %00011011
VIC2ScreenControlV				= $d011

; Read: Current raster line position.
; Write: Raster line position to generate next interrupt. Bit 9 in VIC2ScreenControlV must be correct before writing this register.
VIC2Raster						= $d012
VIC2LightPenX					= $d013
VIC2LightPenY					= $d014
VIC2SpriteEnable				= $d015

; Bits 0-2 Horizontal scroll.
; 3 Screen width 0 = 38 columns 1 = 40 columns
; 4 1 = Multicolour on
; 5-7 Unused
; Default: $c8, %11001000
VIC2ScreenControlHDefault		= %11001000
VIC2ScreenControlH				= $d016

; Each bit sets the double height enable for each sprite.
VIC2SpriteDoubleHeight			= $d017

; In text mode:
; Bit 0 is unused
; Bits 1-3 Character memory location * $0800 (2048) inside current VIC bank selected by $dd00.
; In VIC bank 0 and 2 bits %010 ($4) and %011 ($6) select character ROM except in ULTIMAX mode.
; In bitmap mode:
; Bit 3 Bitmap memory location * $2000 (8192) inside current VIC bank selected by $dd00.
; Bits 4-7 Screen memory location * $0400 (1024)  inside current VIC bank selected by $dd00.
; Default: $15, %00010101
VIC2MemorySetupDefault			= %00010101
VIC2MemorySetup					= $d018

; Read:
; Bit 0: 1 = Current raster line is equal to the raster line which is set to generate an interrupt.
; Bit 1: 1 = Sprite-background collision event.
; Bit 2: 1 = Sprite-sprite collision event.
; Bit 3: 1 = Light pen signal received.
; Bit 7: 1 = An event that might generate an interrupt happened.
; Write:
; Bit 0: 1 = Ack raster interrupt.
; Bit 1: 1 = Ack sprite-background collision interrupt.
; Bit 2: 1 = Ack sprite-sprite collision interrupt.
; Bit 3: 1 = Ack light pen signal interrupt.
; Note: While "dec VIC2InteruptStatus" works on the C64 it doesn't work on the C65 in C64 mode. Use: "+MACROAckRasterIRQ_A" or "lda #1 sta VIC2InteruptStatus" to ack just the raster IRQ or "lda VIC2InteruptStatus sta VIC2InteruptStatus" to ack all IRQs
; http://noname.c64.org/csdb/forums/index.php?roomid=11&topicid=39331&firstpost=2
VIC2InteruptStatus				= $d019

; Bit 0: 1 = Raster interrupt enabled.
; Bit 1: 1 = Sprite-background interrupt enabled.
; Bit 2: 1 = Sprite-sprite interrupt enabled.
; Bit 3: 1 = Light pen interrupt enabled.
VIC2InteruptControl				= $d01a

; Each bit sets the sprite background priority for each sprite.
; 0 = Sprite drawn in front of screen contents.
; 1 = Sprite drawn behind of screen contents.
VIC2SpritePriority				= $d01b

; Each bit sets multicolour for each sprite.
; 0 = Sprite is single colour.
; 1 = Sprite is multicolour.
VIC2SpriteMulticolour			= $d01c

; Each bit sets the double width enable for each sprite.
VIC2SpriteDoubleWidth			= $d01d

; Read: For each set bit X the sprite X collided with another sprite.
; Write: For each set bit X allow further sprite-sprite collisions.
VIC2SpriteSpriteCollision		= $d01e

; Read: For each set bit X the sprite X collided with the background.
; Write: For each set bit X allow further sprite-background collisions.
VIC2SpriteBackgroundCollision	= $d01f

VIC2BorderColour				= $d020
VIC2ScreenColour				= $d021

VIC2ExtraBackgroundColour1		= $d022
VIC2ExtraBackgroundColour2		= $d023
VIC2ExtraBackgroundColour3		= $d024

VIC2ExtraSpriteColour1			= $d025
VIC2ExtraSpriteColour2			= $d026

VIC2Sprite0Colour				= $d027
VIC2Sprite1Colour				= $d028
VIC2Sprite2Colour				= $d029
VIC2Sprite3Colour				= $d02a
VIC2Sprite4Colour				= $d02b
VIC2Sprite5Colour				= $d02c
VIC2Sprite6Colour				= $d02d
VIC2Sprite7Colour				= $d02e

; The colour values
VIC2Colour_Black		= 0
VIC2Colour_White		= 1
VIC2Colour_Red			= 2
VIC2Colour_Cyan			= 3
VIC2Colour_Purple		= 4
VIC2Colour_Green		= 5
VIC2Colour_Blue			= 6
VIC2Colour_Yellow		= 7
VIC2Colour_Orange		= 8
VIC2Colour_Brown		= 9
VIC2Colour_LightRed		= 10
VIC2Colour_DarkGrey		= 11
VIC2Colour_Grey			= 12
VIC2Colour_LightGreen	= 13
VIC2Colour_LightBlue	= 14
VIC2Colour_LightGrey	= 15

; Other constant values related to the VIC2
; Unexpanded sprite sizes
VIC2SpriteSizeX = 24
VIC2SpriteSizeY = 21
; The left most position for a 40 column wide screen where the sprite is completely visible
VIC2SpriteXBorderLeft = 24
; The right most sprite position for a 40 column wide screen where it is completely hidden by the border
VIC2SpriteXBorderRight = 256+88
; The top most position for a 25 row screen where the sprite is completely visible
VIC2SpriteYBorderTop = 50
; The bottom most position for a 25 row screen where the sprite is completely hidden by the border
VIC2SpriteYBorderBottom = 250


; SID Audio chip

SIDVoice1FreqLo					= $d400		; Write only
SIDVoice1FreqHi					= $d401		; Write only
SIDVoice1PulseWidthLo			= $d402		; Write only
SIDVoice1PulseWidthHi			= $d403		; Write only

; Bit 0: 0 = Voice off, release cycle. 1 = Voice on do attack-decay-sustain.
; Bit 1: 1 = Synchronization enable.
; Bit 2: 1 = Ring modulation enable.
; Bit 3: 1 = Disable voice.
; Bit 4: 1 = Triangle waveform enable.
; Bit 5: 1 = Sawtooth waveform enable.
; Bit 6: 1 = Rectangle waveform enable.
; Bit 7: 1 = Noise waveform enable.
SIDVoice1Control				= $d404		; Write only

; Bits 0-3 Decay length:
;	%0000, 0: 6 ms.
;	%0001, 1: 24 ms.
;	%0010, 2: 48 ms.
;	%0011, 3: 72 ms.
;	%0100, 4: 114 ms.
;	%0101, 5: 168 ms.
;	%0110, 6: 204 ms.
;	%0111, 7: 240 ms.
;	%1000, 8: 300 ms.
;	%1001, 9: 750 ms.
;	%1010, 10: 1.5 s.
;	%1011, 11: 2.4 s.
;	%1100, 12: 3 s.
;	%1101, 13: 9 s.
;	%1110, 14: 15 s.
;	%1111, 15: 24 s.
; Bits 4-7 Attack length:
;	%0000, 0: 2 ms.
;	%0001, 1: 8 ms.
;	%0010, 2: 16 ms.
;	%0011, 3: 24 ms.
;	%0100, 4: 38 ms.
;	%0101, 5: 56 ms.
;	%0110, 6: 68 ms.
;	%0111, 7: 80 ms.
;	%1000, 8: 100 ms.
;	%1001, 9: 250 ms.
;	%1010, 10: 500 ms.
;	%1011, 11: 800 ms.
;	%1100, 12: 1 s.
;	%1101, 13: 3 s.
;	%1110, 14: 5 s.
;	%1111, 15: 8 s.
SIDVoice1AttackDecay			= $d405		; Write only

; Bits 0-3 Release length.
;	%0000, 0: 6 ms.
;	%0001, 1: 24 ms.
;	%0010, 2: 48 ms.
;	%0011, 3: 72 ms.
;	%0100, 4: 114 ms.
;	%0101, 5: 168 ms.
;	%0110, 6: 204 ms.
;	%0111, 7: 240 ms.
;	%1000, 8: 300 ms.
;	%1001, 9: 750 ms.
;	%1010, 10: 1.5 s.
;	%1011, 11: 2.4 s.
;	%1100, 12: 3 s.
;	%1101, 13: 9 s.
;	%1110, 14: 15 s.
;	%1111, 15: 24 s.
; Bits #4-#7: Sustain volume.
SIDVoice1SustainRelease			= $d406		; Write only

SIDVoice2FreqLo					= $d407		; Write only
SIDVoice2FreqHi					= $d408		; Write only
SIDVoice2PulseWidthLo			= $d409		; Write only
SIDVoice2PulseWidthHi			= $d40a		; Write only
SIDVoice2Control				= $d40b		; Write only
SIDVoice2AttackDecay			= $d40c		; Write only
SIDVoice2SustainRelease			= $d40d		; Write only

SIDVoice3FreqLo					= $d40e		; Write only
SIDVoice3FreqHi					= $d40f		; Write only
SIDVoice3PulseWidthLo			= $d410		; Write only
SIDVoice3PulseWidthHi			= $d411		; Write only
SIDVoice3Control				= $d412		; Write only
SIDVoice3AttackDecay			= $d413		; Write only
SIDVoice3SustainRelease			= $d414		; Write only

SIDFilterCutoffFreqLo			= $d415		; Write only
SIDFilterCutoffFreqHi			= $d416		; Write only

; Bit 0: 1 = Voice #1 filtered.
; Bit 1: 1 = Voice #2 filtered.
; Bit 2: 1 = Voice #3 filtered.
; Bit 3: 1 = External voice filtered.
; Bits 4-7: Filter resonance.
SIDFilterControl				= $d417		; Write only

; Bits 0-3: Volume.
; Bit 4: 1 = Low pass filter enabled.
; Bit 5: 1 = Band pass filter enabled.
; Bit 6: 1 = High pass filter enabled.
; Bit 7: 1 = Voice #3 disabled.
SIDVolumeFilter					= $d418		; Write only

; Paddle is selected by memory address $dd00
SIDPaddleX						= $d419		; Read only

; Paddle is selected by memory address $dd00
SIDPaddleY						= $d41a		; Read only

SIDVoice3WaveformOutput			= $d41b		; Read only
SIDVoice3ADSROutput				= $d41c		; Read only



; CIA1

; Port A read:
; Bit 0: 0 = Port 2 joystick up pressed.
; Bit 1: 0 = Port 2 joystick down pressed.
; Bit 2: 0 = Port 2 joystick right pressed.
; Bit 3: 0 = Port 2 joystick left pressed.
; Bit 4: 0 = Port 2 joystick fire pressed.
; Write:
; Bit x: 0 = Select keyboard matrix column x.
; Bits 6-7: Paddle selection; %01 = Paddle #1; %10 = Paddle #2.
CIA1KeyboardColumnJoystickA		= $dc00

; Port B, keyboard matrix rows and joystick #1. Bits:
; Bit x: 0 = A key is currently being pressed in keyboard matrix row #x, in the column selected at memory address $DC00.
; Bit 0: 0 = Port 1 joystick up pressed.
; Bit 1: 0 = Port 1 joystick down pressed.
; Bit 2: 0 = Port 1 joystick right pressed.
; Bit 3: 0 = Port 1 joystick left pressed.
; Bit 4: 0 = Port 1 joystick fire pressed.
CIA1KeyboardRowsJoystickB		= $dc01

; Each enabled bit sets read and write on CIA1KeyboardColumnJoystickA otherwise the value can just be read.
CIA1PortADDR					= $dc02

; Each enabled bit sets read and write on CIA1KeyboardRowsJoystickB otherwise the value can just be read.
CIA1PortBDDR					= $dc03

CIA1TimerALo					= $dc04
CIA1TimerAHi					= $dc05

CIA1TimerBLo					= $dc06
CIA1TimerBHi					= $dc07

CIA1ToD10thSecsBCD				= $dc08
CIA1ToDSecsBCD					= $dc09
CIA1ToDMinsBCD					= $dc0a
CIA1ToDHoursBCD					= $dc0b
CIA1SerialShift					= $dc0c

; Interrupt control and status register.
; Read bits:
; Bit 0: 1 = Timer A underflow occurred.
; Bit 1: 1 = Timer B underflow occurred.
; Bit 2: 1 = TOD is equal to alarm time.
; Bit 3: 1 = A complete byte has been received into or sent from serial shift register.
; Bit 4: Signal level on FLAG pin, datasette input.
; Bit 7: An interrupt has been generated.
; Write bits:
; Bit 0: 1 = Enable interrupts generated by timer A underflow.
; Bit 1: 1 = Enable interrupts generated by timer B underflow.
; Bit 2: 1 = Enable TOD alarm interrupt.
; Bit 3: 1 = Enable interrupts generated by a byte having been received/sent via serial shift register.
; Bit 4: 1 = Enable interrupts generated by positive edge on FLAG pin.
; Bit 7: Fill bit; bits 0-6, that are set to 1, get their values from this bit; bits 0-6, that are set to 0, are left unchanged.
; Writing $7f will disable all interrupts generated by this CIA.
CIA1InterruptControl			= $dc0d

; Timer A control register. Bits:
; Bit 0: 0 = Stop timer; 1 = Start timer.
; Bit 1: 1 = Indicate timer underflow on port B bit 6.
; Bit 2: 0 = Upon timer underflow, invert port B bit 6; 1 = upon timer underflow, generate a positive edge on port B bit 6 for 1 system cycle. 
; Bit 3: 0 = Timer restarts upon underflow; 1 = Timer stops upon underflow.
; Bit 4: 1 = Load start value into timer.
; Bit 5: 0 = Timer counts system cycles; 1 = Timer counts positive edges on CNT pin.
; Bit 6: Serial shift register direction; 0 = Input, read; 1 = Output, write.
; Bit 7: TOD speed; 0 = 60 Hz; 1 = 50 Hz.
CIA1TimerAControl				= $dc0e

; Timer B control register. Bits:
; Bit 0: 0 = Stop timer; 1 = Start timer.
; Bit 1: 1 = Indicate timer underflow on port B bit 7.
; Bit 2: 0 = Upon timer underflow, invert port B bit 7; 1 = upon timer underflow, generate a positive edge on port B bit 7 for 1 system cycle.
; Bit 3: 0 = Timer restarts upon underflow; 1 = Timer stops upon underflow.
; Bit 4: 1 = Load start value into timer.
; Bits 5-6: %00 = Timer counts system cycles; %01 = Timer counts positive edges on CNT pin; %10 = Timer counts underflows of timer A; %11 = Timer counts underflows of timer A occurring along with a positive edge on CNT pin.
; Bit 7: 0 = Writing into TOD registers sets TOD; 1 = Writing into TOD registers sets alarm time.
CIA1TimerBControl				= $dc0f


; CIA2. Mostly the same as CIA1 except for VIC bank, no datasette, RS232 and generates NMI instead of IRQ.

; Bits 0-1: VIC bank. Values:
; %00, 0: Bank 3, $C000-$FFFF, 49152-65535.
; %01, 1: Bank 2, $8000-$BFFF, 32768-49151.
; %10, 2: Bank 1, $4000-$7FFF, 16384-32767.
; %11, 3: Bank 0, $0000-$3FFF, 0-16383.
; Bit 2: RS232 TXD line, output bit.
; Bit 3: Serial bus ATN OUT; 0 = High; 1 = Low.
; Bit 4: Serial bus CLOCK OUT; 0 = High; 1 = Low.
; Bit 5: Serial bus DATA OUT; 0 = High; 1 = Low.
; Bit 6: Serial bus CLOCK IN; 0 = High; 1 = Low.
; Bit 7: Serial bus DATA IN; 0 = High; 1 = Low.
CIA2PortASerialBusVICBank		= $dd00
CIA2PortASerialBusVICBankDefault= %11

; Read bits:
; Bit 0: RS232 RXD line, input bit.
; Bit 3: RS232 RI line.
; Bit 4: RS232 DCD line.
; Bit 5: User port H pin.
; Bit 6: RS232 CTS line; 1 = Sender is ready to send.
; Bit 7: RS232 DSR line; 1 = Receiver is ready to receive.
; Write bits:
; Bit 1: RS232 RTS line. 1 = Sender is ready to send.
; Bit 2: RS232 DTR line. 1 = Receiver is ready to receive.
; Bit 3: RS232 RI line.
; Bit 4: RS232 DCD line.
; Bit 5: User port H pin.
CIA2PortBRS232					= $dd01

; Each enabled bit sets read and write on CIA2PortASerialBusVICBank otherwise the value can just be read.
CIA2PortADDR					= $dd02

; Each enabled bit sets read and write on CIA2PortBRS232 otherwise the value can just be read.
CIA2PortBDDR					= $dd03

CIA2TimerALo					= $dd04
CIA2TimerAHi					= $dd05

CIA2TimerBLo					= $dd06
CIA2TimerBHi					= $dd07

CIA2ToD10thSecsBCD				= $dd08
CIA2ToDSecsBCD					= $dd09
CIA2ToDMinsBCD					= $dd0a
CIA2ToDHoursBCD					= $dd0b
CIA2SerialShift					= $dd0c

; Non-maskable interrupt control and status register.
; Read bits:
; Bit 0: 1 = Timer A underflow occurred.
; Bit 1: 1 = Timer B underflow occurred.
; Bit 2: 1 = TOD is equal to alarm time.
; Bit 3: 1 = A complete byte has been received into or sent from serial shift register.
; Bit 4: Signal level on FLAG pin.
; Bit 7: A non-maskable interrupt has been generated.
; Write bits:
; Bit 0: 1 = Enable non-maskable interrupts generated by timer A underflow.
; Bit 1: 1 = Enable non-maskable interrupts generated by timer B underflow.
; Bit 2: 1 = Enable TOD alarm non-maskable interrupt.
; Bit 3: 1 = Enable non-maskable interrupts generated by a byte having been received/sent via serial shift register.
; Bit 4: 1 = Enable non-maskable interrupts generated by positive edge on FLAG pin.
; Bit 7: Fill bit; bits 0-6, that are set to 1, get their values from this bit; bits 0-6, that are set to 0, are left unchanged.
; Writing $7f will disable all interrupts generated by this CIA.
CIA2InterruptControl			= $dd0d

; Timer A control register. Bits:
; Bit 0: 0 = Stop timer; 1 = Start timer.
; Bit 1: 1 = Indicate timer underflow on port B bit 6.
; Bit 2: 0 = Upon timer underflow, invert port B bit 6; 1 = upon timer underflow, generate a positive edge on port B bit 6 for 1 system cycle. 
; Bit 3: 0 = Timer restarts upon underflow; 1 = Timer stops upon underflow.
; Bit 4: 1 = Load start value into timer.
; Bit 5: 0 = Timer counts system cycles; 1 = Timer counts positive edges on CNT pin.
; Bit 6: Serial shift register direction; 0 = Input, read; 1 = Output, write.
; Bit 7: TOD speed; 0 = 60 Hz; 1 = 50 Hz.
CIA2TimerAControl				= $dd0e

; Timer B control register. Bits:
; Bit 0: 0 = Stop timer; 1 = Start timer.
; Bit 1: 1 = Indicate timer underflow on port B bit 7.
; Bit 2: 0 = Upon timer underflow, invert port B bit 7; 1 = upon timer underflow, generate a positive edge on port B bit 7 for 1 system cycle.
; Bit 3: 0 = Timer restarts upon underflow; 1 = Timer stops upon underflow.
; Bit 4: 1 = Load start value into timer.
; Bits 5-6: %00 = Timer counts system cycles; %01 = Timer counts positive edges on CNT pin; %10 = Timer counts underflows of timer A; %11 = Timer counts underflows of timer A occurring along with a positive edge on CNT pin.
; Bit 7: 0 = Writing into TOD registers sets TOD; 1 = Writing into TOD registers sets alarm time.
CIA2TimerBControl				= $dd0f

; Memory mapped registers (256 bytes) of optional external devices.
MemoryMappedIOArea1					= $de00
; Memory mapped registers (256 bytes) of optional external devices.
MemoryMappedIOArea2					= $df00

; Constants
CyclesPerSecondPALC64 = 985248



; Useful code fragments
.macro MACROAckRasterIRQ_A
	lda #1
	sta VIC2InteruptStatus				; Ack Raster interupt
.endmacro

.macro MACROAckAllIRQs_A 
	; Ack any interrupts that might have happened from the CIAs
	lda CIA1InterruptControl
	lda CIA2InterruptControl
	; Ack any interrupts that have happened from the VIC2
	lda #$ff
	sta VIC2InteruptStatus
.endmacro

.macro MACRODisableUpperLowerCaseChange_A 
	lda #$80
	sta FlagUpperLowerCaseChange
.endmacro

.macro MACROWaitForTheLastScan_A 
	; Wait for the bottom raster, commonly used before turning on or off the screen and IRQs
	lda #VIC2SpriteYBorderBottom
.w1:
	cmp VIC2Raster
	bne .w1
.endmacro

; Useful for displaying text strings or copying small chunks of memory <= 256 bytes long
.macro DisplayTextMiddle_AX .start , ._end , .scr
	ldx #._end-.start
.dm1:
	lda .start-1,x
	sta .scr + ((40-(._end-.start))/2),x
	dex
	bne .dm1
.endmacro

.macro DisplayTextAt_AX .start , ._end , .scr 
	ldx #._end-.start
.dm1:
	lda .start-1,x
	sta .scr,x
	dex
	bne .dm1
.endmacro

.macro DisplayColourTextMiddle_AX .start , ._end , .scr , .col 
	ldx #._end-.start
.dm1:
	lda .start-1,x
	sta .scr + ((40-(._end-.start))/2),x
	lda #.col
	sta COLOURRAM + (.scr & $3ff) + ((40-(._end-.start))/2),x
	dex
	bne .dm1
.endmacro

.macro DisplayColourTextAt_AX .start , ._end , .scr , .col 
	ldx #._end-.start
.dm1:
	lda .start-1,x
	sta .scr,x
	lda #.col
	sta COLOURRAM + (.scr & $3ff),x
	dex
	bne .dm1
.endmacro

.macro DisplayReversedTextMiddle_AX .start , ._end , .scr 
	ldx #.end-.start
.dm1:
	lda .start-1,x
	ora #128
	sta .scr + ((40-(._end-.start))/2),x
	dex
	bne .dm1
.endmacro

.macro DisplayReversedTextAt_AX .start , ._end , .scr 
	ldx #._end-.start
.dm1:
	lda .start-1,x
	ora #128
	sta .scr,x
	dex
	bne .dm1
.endmacro
