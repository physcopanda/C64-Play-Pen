.proc InitialiseMachine
	; Initialises everything we can think of to give us a good known state.
	; Leaves interrupts and the screen switched off.
	; a = Processor port flags e.g. lda #ProcessorPortAllRAMWithIO
	; x,y are not preserved
	; Stop interrupts, clear decimal mode and backup the previous stack entries
	sei
	cld
	tay	; Save
	pla
	sta smpreviousStack2+1
	pla
	sta smpreviousStack1+1
	; Grab everything on the stack
	ldx #$ff
	txs
	; Init the processor port
	ldx #ProcessorPortDDRDefault
	stx ZPProcessorPortDDR
	lda #ProcessorPortAllRAMWithIO
	sta ZPProcessorPort
	; Clear all CIA to known state, interrupts off.
	lda #$7f
	sta CIA1InterruptControl
	sta CIA2InterruptControl
	lda #0
	sta VIC2InteruptControl
	sta CIA1TimerAControl
	sta CIA1TimerBControl
	sta CIA2TimerAControl
	sta CIA2TimerBControl

	MACROAckAllIRQs_A

	; Setup kernal and user mode IRQ vectors to point to a blank routine
	lda #<initIRQ
	sta IRQServiceRoutineLo
	sta KERNALIRQServiceRoutineLo
	lda #>initIRQ
	sta IRQServiceRoutineHi
	sta KERNALIRQServiceRoutineHi

	lda #<initNMI
	sta NMIServiceRoutineLo
	sta KERNALNMIServiceRoutineLo
	lda #>initNMI
	sta NMIServiceRoutineHi
	sta KERNALNMIServiceRoutineHi

	MACROWaitForTheLastScan_A
	; Turn off various bits in the VIC2 and SID chips
	; Screen, sprites and volume are disabled.
	lda #0
	sta VIC2ScreenColour
	sta VIC2BorderColour
	sta VIC2ScreenControlV
	sta VIC2SpriteEnable
	sta SIDVolumeFilter


	; Set the user requested ROM state
	sty ZPProcessorPort

	; Restore what was on our stack so we can return
smpreviousStack1:
	lda #$00
	pha
smpreviousStack2:
	lda #$00
	pha

	rts

initIRQ:
	pha
	MACROAckRasterIRQ_A
	pla
initNMI:
	rti
.endproc
