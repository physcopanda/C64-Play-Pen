.feature leading_dot_in_identifiers
.feature pc_assignment
.include "libs/stdlib/stdlib.s"
.macpack cbm

.segment "CODE"

; Uncomment this to allow colision logging to be turned on and update into the screen area
;Multiplex_LogCollisions = 1
Multiplex_CollisionCounter		= SCREENRAM + (16*40)
Multiplex_CollisionHistory		= SCREENRAM + (18*40)
Multiplex_CollisionIndexes		= SCREENRAM + (19*40)

; Define what the multiplexor can use
Multiplex_VarBase	= $02
Multiplex_spritepointer	= SPRITEFRAME
Multiplex_IRQServiceRoutineLo = KERNALIRQServiceRoutineLo;
Multiplex_IRQServiceRoutineHi = KERNALIRQServiceRoutineHi;
Multiplex_DiscardSpritesYPos=255
.ifdef Multiplex_LogCollisions 
	Multiplex_items	= 24
.else
	Multiplex_items	= 48
.endif
.include "SpriteMultiplexorVars.s"

; Uncomment this to enable debug borders to be drawn
Multiplexor_DebugBorder = 1

; Uncomment this to enable the music
EnableMusic = 1

; Uncomment this to allow the sprite sort to use a bit more time but save using an extra exit interrupt
Multiplex_EnableEarlyOut = 1

; Uncomment this to test the bunching check code
;Multiplex_BunchingCheck = 1


; Unit test zero page variables
counterx1	= Multiplex_endVars+$00
counterx2	= Multiplex_endVars+$01

countery1	= Multiplex_endVars+$02
countery2	= Multiplex_endVars+$03

xdif		= Multiplex_endVars+$04
ydif		= Multiplex_endVars+$05

xspeed	= Multiplex_endVars+$06
yspeed	= Multiplex_endVars+$07

xoffset	= Multiplex_endVars+$08
yoffset	= Multiplex_endVars+$09

.include "libs/stdlib/BASICEntry900.s"

.macro SpriteLine v 
	.byte v>>16, (v>>8)&255, v&255
.endmacro

; Some sprite data high up in memory
*=$3e00
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255
.byte 255,255,255,255,255,255,255,255

SpriteLine %000000000000000000000000
SpriteLine %010000000000000000000000
SpriteLine %011000000000000000000000
SpriteLine %011100000000000000000000
SpriteLine %011110000000000000000000
SpriteLine %011111000000000000000000
SpriteLine %011111100000000000000000
SpriteLine %011111110000000000000000
SpriteLine %011111111000000000000000
SpriteLine %011111111100000000000000
SpriteLine %011111111000000000000000
SpriteLine %011111100000000000000000
SpriteLine %011111100000000000000000
SpriteLine %011001100000000000000000
SpriteLine %010000110000000000000000
SpriteLine %000000110000000000000000
SpriteLine %000000011000000000000000
SpriteLine %000000011000000000000000
SpriteLine %000000001100000000000000
SpriteLine %000000001100000000000000
SpriteLine %000000000000000000000000
.byte 0

SpriteLine %111111111111111111111111
SpriteLine %111111111111111111111111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000011100000000111
SpriteLine %111000000111110000000111
SpriteLine %111000000111110000000111
SpriteLine %111000000111110000000111
SpriteLine %111000000011100000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111000000000000000000111
SpriteLine %111111111111111111111111
SpriteLine %111111111111111111111111
.byte 0

SpriteLine %111111111111111111111111
SpriteLine %111111111111111111111111
SpriteLine %111100000001100000001111
SpriteLine %111010000001100000010111
SpriteLine %111001000001100000100111
SpriteLine %111000100001100001000111
SpriteLine %111000010001100010000111
SpriteLine %111000001001100100000111
SpriteLine %111000000111111000000111
SpriteLine %111000000111110000000111
SpriteLine %111111111111111111111111
SpriteLine %111000000111110000000111
SpriteLine %111000000111110000000111
SpriteLine %111000001001001000000111
SpriteLine %111000010001000100000111
SpriteLine %111000100001000010000111
SpriteLine %111001000001000001000111
SpriteLine %111010000001000000100111
SpriteLine %111100000001000000010111
SpriteLine %111111111111111111111111
SpriteLine %111111111111111111111111
.byte 0

*=BASICEntry
jmp Start

*=$0c00
;--------------------------------------
.proc Start
	lda #ProcessorPortAllRAMWithIO
	jsr InitialiseMachine

	lda #0
	sta VIC2SpriteDoubleWidth
	sta VIC2SpriteDoubleHeight
	sta VIC2SpritePriority
	sta VIC2SpriteMulticolour

	lda #<Multiplex_maininter
	sta KERNALIRQServiceRoutineLo
	lda #>Multiplex_maininter
	sta KERNALIRQServiceRoutineHi

	lda #<NMIRet
	sta KERNALNMIServiceRoutineLo
	lda #>NMIRet
	sta KERNALNMIServiceRoutineHi

	; Two frames worth of static 48 sprites
	lda #100
	sta countDown
	lda #210
	sta countDown2
	lda #210
	sta countDown3

	; Clear zero page to something we know so that we can display it later on to check none of the variables are out of range.
	ldx #$02
	lda #$80
	L3:
	sta $00,x
	inx
	bne L3

	lda #Multiplex_items					; MPi: Increase to 48 sprites from the original 24 sprite demo
	sta Multiplex_MaxSpr

	lda #$40
	sta xoffset

	lda #$00
	sta yoffset

	lda #$ff
	sta xspeed

	lda #$01
	sta yspeed

	lda #$0a
	sta xdif
	lda #$10
	sta ydif

	jsr Multiplex_InitSort

	lda #1
	sta VIC2InteruptControl
	lda #%00011011
	sta VIC2ScreenControlV
	lda #0
	sta VIC2Raster
	; Ack any interrupts that might have happened so we get a clean start
	lda #1
	sta VIC2InteruptStatus

	cli
	
	.ifdef EnableMusic
		lda #0
		;jsr MusicPlayerStart ; ::TODO:: disabled for now - fix later - JH
	.endif

	; MPi: Just to prove all IRQs save all registers. These characters should never flicker or change from ABC in the top left of the screen.
	lda #1
	ldx #2
	ldy #3
	L2:
	sta SCREENRAM
	stx SCREENRAM+1
	sty SCREENRAM+2
	; MPi: Inc'ing these three store variables should not alter the "ABC" printed by the bit above.
	; In the previous version this code block would show how reg X was not being preserved by the IRQ because the middle character ("B") would update.
	; This is because as the IRQ exits it would sometimes do an extra "ldx Multiplex_xreg" without always doing the corresponding "stx Multiplex_xreg" on entry.
	; *Will not work if EnableMusic is defined since it doesn't save the registers*
	inc Multiplex_areg
	inc Multiplex_xreg
	inc Multiplex_yreg
	
	.ifdef EnableMusic 
		; Try playing some music from the music editor
		lda countDown
		bne L2
		lda countDown2
		bne L2
		.notYet:
			lda Multiplex_BottomTriggered
			beq .notYet
			lda #0
			sta Multiplex_BottomTriggered
		.ifdef Multiplexor_DebugBorder
			inc VIC2BorderColour
		.endif
		;jsr MusicPlayerPlay ; ::TODO:: disabled for now - fix later - JH
		.ifdef Multiplexor_DebugBorder
			dec VIC2BorderColour
		.endif
		.ifdef Multiplex_LogCollisions
			; Automatically update this if the Multiplex_EnableEarlyOut is not defined since the IRQ will
			; be after the last sprite.
			jsr Multiplexor_UpdateCollisionDetails
			; Just blank out the extra entries on the screen to make it easier to see
			lda #' '
			ldy Multiplex_CollisionCounter
			sta Multiplex_CollisionIndexes,y
			sta Multiplex_CollisionIndexes+1,y
			sta Multiplex_CollisionIndexes+2,y
			sta Multiplex_CollisionIndexes+3,y
			sta Multiplex_CollisionIndexes+4,y
			sta Multiplex_CollisionIndexes+5,y
		
		
		.endif
	.endif
	jmp L2
.endproc

NMIRet:
	rti

.align 256
;--------------------------------------
; This function is defined before including "SpriteMultiplexor.a" which then causes the last IRQ to call this
.proc MultiplexExt_LastIRQ
	Main:
	lda #$ef
	cmp CIA1KeyboardRowsJoystickB
	beq over

	ldx countDown
	beq skipToSecond
	dex
	stx countDown
	jmp over

	skipToSecond:
		ldx countDown2
		beq skipToThird
		dex
		stx countDown2
		bne notYet
		; Switch to animating a maximum of 44 sprites
		lda #Multiplex_items-4
		sta Multiplex_MaxSpr
		jsr Multiplex_InitSort
		jmp over
	notYet:
		ldy Multiplex_MaxSpr
		dey
		bmi over
	off1:
		lda Multiplex_YPos,y
		cmp #255
		beq skipOff1
		clc
		adc #1
		sta Multiplex_YPos,y
	skipOff1:
		dey
		bpl off1
		jmp over
	
	skipToThird:
		ldx countDown3
		beq skipToFourth
		dex
		stx countDown3
	skipToFourth:
		.ifdef Multiplexor_DebugBorder
			lda #VIC2Colour_White
			sta VIC2BorderColour
		.endif
		; Because we are exiting the current screen of sprites to display we can move the sprites and sort them.
		jsr Move
	
		ldx countDown3
		beq over
		ldy Multiplex_MaxSpr
		dey
		bmi over
	fiddle:
		txa
		clc
		adc Multiplex_YPos,y
		bcc fiddle2
		lda #255
	fiddle2:
		sta Multiplex_YPos,y
		dey
		bpl fiddle
	
	over:
	.ifdef Multiplexor_DebugBorder
		lda #VIC2Colour_Red
		sta VIC2BorderColour
	.endif
		; MPi: Even without any sprite move being called this still calls the sort to demonstrate just how quick the sort is.
		; The sort (red border area at the bottom of the screen) is actually on average much quicker than the move loop (the white area above the red).
		; This runs the sort using the previous results of the sort as a starting point to work from.
		; It's called the "Ocean method" since it was commonly used in Ocean games.
	jsr Multiplex_Sort
	
	.ifdef Multiplexor_DebugBorder 
		lda #VIC2Colour_Black
		sta VIC2BorderColour
	.endif
	
	jsr Multiplex_StartTopInterrupt
	jmp Multiplex_AckExitInterrupt
	
.endproc

.include "SpriteMultiplexor.s"

countDown:	.byte 0
countDown2:	.byte 0
countDown3:	.byte 0

.proc Move
	Main:
	; Update the first "Multiplex_MaxSpr" sprites
	ldy Multiplex_MaxSpr
	dey
	bmi exit
	.L1:
	lda counterx2
	clc
	adc xdif
	sta counterx2
	clc
	adc counterx1
	tax
	lda sinx,x
	sta Multiplex_XPosLo,y
	lda sinxhi,x
	sta Multiplex_XPosHi,y

	lda countery2
	clc
	adc ydif
	sta countery2
	clc
	adc countery1
	tax
	lda siny,x
	sta Multiplex_YPos,y

	dey
	bpl .L1

	lda #90
	sta Multiplex_YPos + 0
	sta Multiplex_YPos + 1
	lda #109
	sta Multiplex_YPos + 2
	sta Multiplex_YPos + 3
	lda #128
	sta Multiplex_YPos + 4
	sta Multiplex_YPos + 5
	lda #147
	sta Multiplex_YPos + 6
	sta Multiplex_YPos + 7
	lda #166
	sta Multiplex_YPos + 8
	sta Multiplex_YPos + 9
	lda #185
	sta Multiplex_YPos + 10
	sta Multiplex_YPos + 11

	exit:

	; MPi: When uncommented this demonstrates that when a sprite has a Y coord of $ff then the multiplexor will sort them to the end of the list and will stop plotting sprites.
;	lda #$ff
;	sta Multiplex_YPos + 7
;	sta Multiplex_YPos + 17
;	sta Multiplex_YPos + 27
;	sta Multiplex_YPos + 18
;	sta Multiplex_YPos + 19
;	sta Multiplex_YPos + 20
;	sta Multiplex_YPos + 21
;	sta Multiplex_YPos + 22
;	sta Multiplex_YPos + 23


	; MPi: When uncommented demonstrate how only modifying some sprite Y values each frame and keeping others constant results in a faster sort time.
;	lda #50
;	sta Multiplex_YPos + 4
;	sta Multiplex_YPos + 5
;	sta Multiplex_YPos + 6
;	sta Multiplex_YPos + 7
;	lda #80
;	sta Multiplex_YPos + 16
;	sta Multiplex_YPos + 17
;	sta Multiplex_YPos + 18
;	sta Multiplex_YPos + 19
;	lda #110
;	sta Multiplex_YPos + 20
;	sta Multiplex_YPos + 21
;	sta Multiplex_YPos + 22
;	sta Multiplex_YPos + 23
;	lda #140
;	sta Multiplex_YPos + 24
;	sta Multiplex_YPos + 25
;	sta Multiplex_YPos + 26
;	sta Multiplex_YPos + 27
;	lda #170
;	sta Multiplex_YPos + 0
;	sta Multiplex_YPos + 1
;	sta Multiplex_YPos + 2
;	sta Multiplex_YPos + 3
;	lda #200
;	sta Multiplex_YPos + 8
;	sta Multiplex_YPos + 9
;	sta Multiplex_YPos + 10
;	sta Multiplex_YPos + 11
;	lda #230
;	sta Multiplex_YPos + 12
;	sta Multiplex_YPos + 13
;	sta Multiplex_YPos + 14
;	sta Multiplex_YPos + 15


	lda xoffset
	sta counterx2
	lda yoffset
	sta countery2

	lda counterx1
	clc
	adc xspeed
	sta counterx1

	lda countery1
	clc
	adc yspeed
	sta countery1

	rts
.endproc

.include "libs/stdlib/Initialise.s"

.align 256
sinx:
 .byte $af,$b2,$b6,$b9,$bd,$c1,$c4,$c8,$cb,$cf,$d2,$d6,$d9,$dd,$e0,$e3
 .byte $e7,$ea,$ed,$f1,$f4,$f7,$fa,$fd,$00,$03,$06,$09,$0b,$0e,$11,$13
 .byte $16,$18,$1b,$1d,$1f,$21,$24,$26,$28,$2a,$2b,$2d,$2f,$30,$32,$33
 .byte $35,$36,$37,$38,$39,$3a,$3b,$3c,$3c,$3d,$3d,$3e,$3e,$3e,$3e,$3e
 .byte $3e,$3e,$3e,$3e,$3d,$3d,$3c,$3c,$3b,$3a,$39,$38,$37,$36,$35,$33
 .byte $32,$30,$2f,$2d,$2b,$2a,$28,$26,$24,$21,$1f,$1d,$1b,$18,$16,$13
 .byte $11,$0e,$0b,$09,$06,$03,$00,$fd,$fa,$f7,$f4,$f1,$ed,$ea,$e7,$e3
 .byte $e0,$dd,$d9,$d6,$d2,$cf,$cb,$c8,$c4,$c1,$bd,$b9,$b6,$b2,$af,$ab
 .byte $a7,$a4,$a0,$9d,$99,$95,$92,$8e,$8b,$87,$84,$80,$7d,$79,$76,$73
 .byte $6f,$6c,$69,$65,$62,$5f,$5c,$59,$56,$53,$50,$4d,$4b,$48,$45,$43
 .byte $40,$3e,$3b,$39,$37,$35,$32,$30,$2e,$2c,$2b,$29,$27,$26,$24,$23
 .byte $21,$20,$1f,$1e,$1d,$1c,$1b,$1a,$1a,$19,$19,$18,$18,$18,$18,$18
 .byte $18,$18,$18,$18,$19,$19,$1a,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$23
 .byte $24,$26,$27,$29,$2b,$2c,$2e,$30,$32,$35,$37,$39,$3b,$3e,$40,$43
 .byte $45,$48,$4b,$4d,$50,$53,$56,$59,$5c,$5f,$62,$65,$69,$6c,$6f,$73
 .byte $76,$79,$7d,$80,$84,$87,$8b,$8e,$92,$95,$99,$9d,$a0,$a4,$a7,$ab

sinxhi:
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 .byte $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

siny:
 .byte $8d,$8f,$92,$94,$96,$98,$9a,$9c,$9f,$a1,$a3,$a5,$a7,$a9,$ab,$ad
 .byte $af,$b1,$b3,$b5,$b7,$b9,$bb,$bc,$be,$c0,$c2,$c3,$c5,$c7,$c8,$ca
 .byte $cb,$cd,$ce,$d0,$d1,$d2,$d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$dc,$dd
 .byte $de,$df,$e0,$e0,$e1,$e1,$e2,$e2,$e3,$e3,$e3,$e4,$e4,$e4,$e4,$e4
 .byte $e4,$e4,$e4,$e4,$e3,$e3,$e3,$e2,$e2,$e1,$e1,$e0,$e0,$df,$de,$dd
 .byte $dc,$db,$da,$d9,$d8,$d7,$d6,$d5,$d4,$d2,$d1,$d0,$ce,$cd,$cb,$ca
 .byte $c8,$c7,$c5,$c3,$c2,$c0,$be,$bc,$bb,$b9,$b7,$b5,$b3,$b1,$af,$ad
 .byte $ab,$a9,$a7,$a5,$a3,$a1,$9f,$9c,$9a,$98,$96,$94,$92,$8f,$8d,$8b
 .byte $89,$87,$84,$82,$80,$7e,$7c,$7a,$77,$75,$73,$71,$6f,$6d,$6b,$69
 .byte $67,$65,$63,$61,$5f,$5d,$5b,$5a,$58,$56,$54,$53,$51,$4f,$4e,$4c
 .byte $4b,$49,$48,$46,$45,$44,$42,$41,$40,$3f,$3e,$3d,$3c,$3b,$3a,$39
 .byte $38,$37,$36,$36,$35,$35,$34,$34,$33,$33,$33,$32,$32,$32,$32,$32
 .byte $32,$32,$32,$32,$33,$33,$33,$34,$34,$35,$35,$36,$36,$37,$38,$39
 .byte $3a,$3b,$3c,$3d,$3e,$3f,$40,$41,$42,$44,$45,$46,$48,$49,$4b,$4c
 .byte $4e,$4f,$51,$53,$54,$56,$58,$5a,$5b,$5d,$5f,$61,$63,$65,$67,$69
 .byte $6b,$6d,$6f,$71,$73,$75,$77,$7a,$7c,$7e,$80,$82,$84,$87,$89,$8b
 .byte $ff

.ifdef EnableMusic
	; removed init music code as I didn't need to port the musicplayer
.endif

