; Change list
; Original code from http://codebase64.org/doku.php?id=base:flexible_32_sprite_multiplexer
; 25th October 2007 - Martin Piper
; Conversion to ACME plus various tweaks, bug fix (the interrupt was not always saving X for the RTI in all execution paths) and optimisations mostly shown by the "MPi:" comments.
; 26th October 2007 - Martin Piper
; Fixed a slight bug where if one particular sprite was the very last one to be drawn it wouldn't end the IRQ chain correctly.
; Added a test for sprite Y pos = $ff and then it then finishes rendering all further sprites. This is a quick way to disable a sprite from being rendered.
; Added some extra documentation comments.
; 27th October 2007 - Martin Piper
; Tidied this so the multiplexor is in a separate file and made it a bit more modular.
; 28th October 2007 - Martin Piper
; Updated to 48 sprites.
; 3 November 2007 - Martin Piper
; Tidied up some magic numbers to use constants
; 4 November 2007 - Martin Piper
; Added Multiplex_DiscardSpritesYPos
; Added Multiplex_StartTopInterrupt to enable better interrupt flexibility.
; 6 September 2008 - Martin Piper
; Added Multiplex_EnableEarlyOut
; Added Multiplex_OverflowRasterCheck1/Multiplex_OverflowRasterCheck2
; Used macros for the main sprite drawing and sort routines.
; 27 October 2008 - Martin Piper
; Added Multiplex_LeanAndMean to stop the code from allocating memory for the tables.
; 3 May 2009 - Martin Piper
; Added Multiplex_LogCollisions to log VIC collision information.
; 20 June 2009 - Martin Piper
; Added Multiplex_LogCollisionsBackground to include the VIC background sprite collision register.

; TODO

; Documentation
; This routine works on the principal of reusing sprite slots as soon as possible after the bottom of the sprite is drawn. A couple of lines is used below the sprite bottom for safety.
; This is contrary to the other method of setting a raster to appear N-lines above where the next sprite needs to be drawn.
; Basically starting from just above the first sprite draw the first chunk of eight sprites.
; a) Then check the raster for being below the bottom of the next sprite slot (sprite 0 to 7).
; If raster below then draw the next sprite slot and check for no more sprites (if so then run sorting interrupt instead) and loop to a)
; Set IRQ to trigger no less than three pixels below the current raster.


Multiplex_spriteHeightTweak = 21+2	; Add 2 because the carry is clear when we do "sbc VIC2Raster" and we want to start updating the sprite data on the next line after the sprite bottom.

.ifndef Multiplex_rasterHeight
	Multiplex_rasterHeight = 3
.endif

.macro MACROMultiplex_SpriteStrip _Multiplex_LBLISFP9 , spriteIndex 
	.local _blit0, _next0, _intExitInter0, _Multiplex_inter0, _skipSprite, _no0, _yes0, _Multiplex_nextSpriteFunction
	;--------------------------------------
	; MPi: Calculate with this current raster position and the bottom of the last sprite Y pos
	; Is it better to start a new raster IRQ at the new position or shall we update the sprite now?
	lda VIC2Sprite0Y + (spriteIndex * 2)
	; Carry happens to be always clear at this point due to the code logic
	adc #Multiplex_spriteHeightTweak
	sbc VIC2Raster
	bcc _blit0		; MPi: Process the sprite now not later since we have finished the bottom of the previous sprite using this slot
	cmp #Multiplex_rasterHeight
	bcs _next0		; MPi: If we want to trigger a raster make sure it isn't closer than Multiplex_rasterHeight scan lines from our current position
	lda #Multiplex_rasterHeight
	_next0:	
	clc			; MPi: Process the sprite later next raster IRQ
	adc VIC2Raster
	.ifdef Multiplex_OverflowRasterCheck2
		cmp #Multiplex_DiscardSpritesYPos-Multiplex_rasterHeight-1					; Overflow interrupt check
		bcs _intExitInter0
	.endif
	stx Multiplex_counter

	sta VIC2Raster
	
	lda #<_Multiplex_inter0
	sta Multiplex_IRQServiceRoutineLo
	lda #>_Multiplex_inter0
	sta Multiplex_IRQServiceRoutineHi

	MACROAckRasterIRQ_A
	
	.ifdef Multiplexor_DebugBorder
		lda #VIC2Colour_Cyan 
		sta VIC2BorderColour
	.endif
	lda Multiplex_areg
	ldx Multiplex_xreg
	ldy Multiplex_yreg
	rti
	
	; MPi: Each Multiplex_interX is entered by each subsequent raster IRQ
	_Multiplex_inter0:
	; 8 cycles from the end of the left border
	sta Multiplex_areg		; 3
	stx Multiplex_xreg		; 6
	sty Multiplex_yreg		; 9
	ldx Multiplex_counter	; 12
	
	.ifdef Multiplex_LogCollisions
		lda VIC2SpriteSpriteCollision
		.ifdef Multiplex_LogCollisionsBackground
			ora VIC2SpriteBackgroundCollision
		.endif
		beq _noCol
		.ifdef Multiplexor_UpdateCollisionDetailsSoftEnable
			bit Multiplexor_UpdateCollisionDetailsSoftEnableFlag
			beq _noCol
		.endif
		jsr Multiplexor_UpdateCollisionDetailsNoCheck
		_noCol:
	.endif
	
	; MPi: Each .blitX can also entered by a raster IRQ processing more than one sprite in this band if it is calculated it is better to follow on rather than create a new raster IRQ.
	_blit0:
	ldy Multiplex_indextable,x	; 16
	
	.ifdef Multiplexor_DebugBorder
		inc VIC2BorderColour
	.endif
	
	lda Multiplex_YPos,y	; 20
	
	; If early out is disabled then we have to do the check in the IRQ instead. With it enabled
	; then the extra time in the mainline means time saved in this IRQ.
	.ifndef Multiplex_EnableEarlyOut
		cmp #Multiplex_DiscardSpritesYPos	; 22					; Don't display any sprites once this is reached
		bcs _intExitInter0		; 24
	.endif
	
	; If the sprite y position is already less than the raster then we skip it.
	; This indicates we have more sprites on a row than we can handle and saves a tiny bit of time.
	; This time saved can be used to potentially display more sprites later on instead.
	.ifdef Multiplex_BunchingCheck
		cmp VIC2Raster			; 28
		bcc _skipSprite			; 30
	.endif
	.ifdef Multiplex_LogCollisions
		; Store what sprite is using what index for the collision to use
		sty Multiplex_CollisionHistory + spriteIndex
	.endif
	sta VIC2Sprite0Y + (spriteIndex * 2)
	lda Multiplex_XPosLo,y
	sta VIC2Sprite0X + (spriteIndex * 2)
	lda Multiplex_SpriteFrame,y

	.ident (_Multiplex_LBLISFP9):
	sta Multiplex_spritepointer + spriteIndex

	lda Multiplex_Colour,y
	sta VIC2Sprite0Colour + spriteIndex

	lda Multiplex_XPosHi,y
	beq _no0
		lda #(1 << spriteIndex)
		ora VIC2SpriteXMSB
		bne _yes0
	_no0:	
		lda #$ff - (1 << spriteIndex)
		and VIC2SpriteXMSB
	_yes0:	
		sta VIC2SpriteXMSB
	
	_skipSprite:
		inx
	
	.ifdef Multiplex_OverflowRasterCheck1 
		lda VIC2Raster
		cmp #Multiplex_DiscardSpritesYPos-Multiplex_rasterHeight-1					; Overflow interrupt check
		bcs _intExitInter0
	.endif
		cpx Multiplex_MaxSprSorted
		bcc _Multiplex_nextSpriteFunction
	_intExitInter0:
		jmp Multiplex_exitinter
	_Multiplex_nextSpriteFunction:
.endmacro

.macro MACROMultiplex_SpriteChunk Multiplex_LBLISFP1 , spriteIndex
	ldy Multiplex_indextable + spriteIndex
	ldx Multiplex_YPos,y
.ifdef Multiplex_LogCollisions
	; Store what sprite is using what index for the collision to use
	sty Multiplex_CollisionHistory + spriteIndex
.endif
	stx VIC2Sprite0Y + (spriteIndex * 2)
	ldx Multiplex_XPosLo,y
	stx VIC2Sprite0X + (spriteIndex * 2)
	ldx Multiplex_SpriteFrame,y

	.ident (Multiplex_LBLISFP1):
	stx Multiplex_spritepointer + spriteIndex

	ldx Multiplex_Colour,y
	stx VIC2Sprite0Colour + spriteIndex
	ldx Multiplex_XPosHi,y
.endmacro

.macro MACROMultiplex_SortBlock index , backPos , forward 
	.local _over1, _back1, _over2
	_over1:	
	ldy Multiplex_indextable+index+1
	_back1:	
	ldx Multiplex_indextable+index
	.ident(forward) = _back1
	lda Multiplex_YPos,y
	cmp Multiplex_YPos,x
	bcs _over2
	stx Multiplex_indextable+index+1
	sty Multiplex_indextable+index
	bcc backPos
	_over2:
.endmacro

;--------------------------------------
.proc Multiplex_maininter
	; The main top interrupt that draws the first line of sprites and then figures out what next to plot
	Main:
		sta Multiplex_areg
		stx Multiplex_xreg
		sty Multiplex_yreg
	
	Multiplex_maininterEx:
	.ifdef Multiplexor_DebugBorder 
		inc VIC2BorderColour
	.endif
	.ifdef Multiplex_LogCollisions
		; Deliberately use an invalid index so we don't log old collisions more than once.
		lda #$ff
		sta Multiplex_CollisionHistory
		sta Multiplex_CollisionHistory+1
		sta Multiplex_CollisionHistory+2
		sta Multiplex_CollisionHistory+3
		sta Multiplex_CollisionHistory+4
		sta Multiplex_CollisionHistory+5
		sta Multiplex_CollisionHistory+6
		sta Multiplex_CollisionHistory+7
	
		; Reset the counter for this frame
		lda #0
		sta Multiplex_CollisionCounter
	.endif
	
		ldx Multiplex_MaxSprSorted
		cpx #$09
		bcs morethan8
	
		lda #$4c							; Set jmp $xxxx
		sta switch
	
		lda activatetab,x
		sta VIC2SpriteEnable
	
		lda jumplo,x
		sta Multiplex_jumplo
		lda jumphi,x
		sta Multiplex_jumphi
		lda #$00
		sta VIC2SpriteXMSB
		jmp (Multiplex_jumplo)
	
		morethan8:
		lda #$ff
		sta VIC2SpriteEnable
		lda #$08
		sta Multiplex_counter
	
		lda #$2c							; Set bit $xxxx
		sta switch
		lda #$00
	
		;--------------------------------------
		dospr7:
			MACROMultiplex_SpriteChunk "ISFP1" , 7
			beq dospr6
			lda #$80
		dospr6:
			MACROMultiplex_SpriteChunk "ISFP2" , 6
			beq dospr5
			ora #$40
		dospr5:
			MACROMultiplex_SpriteChunk "ISFP3" , 5
			beq dospr4
			ora #$20
		dospr4:
			MACROMultiplex_SpriteChunk "ISFP4" , 4
			beq dospr3
			ora #$10
		dospr3:
			MACROMultiplex_SpriteChunk "ISFP5" , 3
			beq dospr2
			ora #$08
		dospr2:
			MACROMultiplex_SpriteChunk "ISFP6" , 2
			beq dospr1
			ora #$04
		dospr1:
			MACROMultiplex_SpriteChunk "ISFP7" , 1
			beq dospr0
			ora #$02
		dospr0:
			MACROMultiplex_SpriteChunk "ISFP8" , 0
			beq over
			ora #$01
		over:
		sta VIC2SpriteXMSB
		.ifdef Multiplex_LogCollisions
			; Now "ACK" any pre-existing collisions from the last frame
			lda VIC2SpriteSpriteCollision
			.ifdef Multiplex_LogCollisionsBackground
				lda VIC2SpriteBackgroundCollision
			.endif
		.endif
		.ifdef Multiplexor_DebugBorder
			inc VIC2BorderColour
		.endif
		switch:
		jmp Multiplex_exitinter		; Self modifying for jmp or bit
	
		clc
	
		; MPi: During heavy use (>24 sprites) on average the interrupt updates at least two new sprites and quite often three or four sprites. (Enable Multiplexor_DebugBorder to see this.)
		; Armed with this information there is an average time saving by having reg x maintain Multiplex_counter and being able to do
		; "ldy Multiplex_indextable,x" instead of "lda Multiplex_indextable,y : tay" even taking into account the extra interrupt x register store and restore.
		; This is because the "ldx Multiplex_counter : inx : stx Multiplex_counter" doesn't always need to be done every sprite and can be optimised to be just "inx".
		; However Under light use (<16 sprites) the average interrupt updates one sprites but the extra overhead for the extra interrupt x store and restore is small compared to the savings mentioned above.
		; Basically the theory being optimise for heavy use since heavy use is where the optimisation is more appreciated.
	
		ldx Multiplex_counter
	
		; MPi: From here until the Multiplex_exitinter the sprite plotting code has been reworked to use an extra register (x) and include the optimisations described above.
		Multiplex_intNextSpr0:
			MACROMultiplex_SpriteStrip "ISFP9" , 0
		Multiplex_intNextSpr1:
			MACROMultiplex_SpriteStrip "ISFP10" , 1
		Multiplex_intNextSpr2:
			MACROMultiplex_SpriteStrip "ISFP11" , 2
		Multiplex_intNextSpr3:
			MACROMultiplex_SpriteStrip "ISFP12" , 3
		Multiplex_intNextSpr4:
			MACROMultiplex_SpriteStrip "ISFP13" , 4
		Multiplex_intNextSpr5:
			MACROMultiplex_SpriteStrip "ISFP14" , 5
		Multiplex_intNextSpr6:
			MACROMultiplex_SpriteStrip "ISFP15" , 6
		Multiplex_intNextSpr7:
			MACROMultiplex_SpriteStrip "ISFP16" , 7
		
		jmp Multiplex_intNextSpr0
	
	jumplo:
		.byte <Multiplex_exitinter,<dospr0,<dospr1,<dospr2
		.byte <dospr3,<dospr4,<dospr5,<dospr6
		.byte <dospr7
	
	jumphi:
		.byte >Multiplex_exitinter,>dospr0,>dospr1,>dospr2
		.byte >dospr3,>dospr4,>dospr5,>dospr6
		.byte >dospr7
	
	activatetab:
		.byte $00,$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	
	.ifdef Multiplex_LogCollisions
	
		.macro MACROMultiplex_RegisterCollision colTemp , spriteIndex 
			lsr colTemp
			bcc _noCollisionThisChunk
			lda Multiplex_CollisionHistory+spriteIndex
			bmi _noCollisionThisChunk
			sta Multiplex_CollisionIndexes,y
			; Don't store this sprite again until it is updated
			lda #$ff
			sta Multiplex_CollisionHistory+spriteIndex
			iny
			_noCollisionThisChunk:
		.endmacro
	
		.ifdef Multiplexor_UpdateCollisionDetailsSoftEnable
			; This software flag can be 0 or $ff. If it is 0 then even if the sprite register shows collisions
			; they will not be logged and thus save a little bit of rater time.
			; Useful if the collision is switched on but it needs to be switched off to display tighter packed
			; sprite formations during an animated scene that doesn't need collision.
			Multiplexor_UpdateCollisionDetailsSoftEnableFlag: 
				.byte $ff
		.endif
		
		Multiplexor_UpdateCollisionDetails:
		cmp #0	; Just in case the previous insruction was not lda VIC2SpriteSpriteCollision;
		bne gotCollision
		retCol:
		rts
		gotCollision:
		.ifdef Multiplexor_UpdateCollisionDetailsSoftEnable
			bit Multiplexor_UpdateCollisionDetailsSoftEnableFlag
			beq retCol
		.endif
		Multiplexor_UpdateCollisionDetailsNoCheck:
		sta colTemp
		.ifdef Multiplexor_DebugBorderCollision
			inc VIC2BorderColour
		.endif
		sty colRegTemp
		ldy Multiplex_CollisionCounter
		; Now process all collision flagged sprites
		; Unrolled the loop instead of using indrect X
			MACROMultiplex_RegisterCollision colTemp , 0
			bne furtherCollision1
			jmp noFurtherCollision
		furtherCollision1:
			MACROMultiplex_RegisterCollision colTemp , 1
			bne furtherCollision2
			jmp noFurtherCollision
		furtherCollision2
			MACROMultiplex_RegisterCollision colTemp , 2
			beq noFurtherCollision
			MACROMultiplex_RegisterCollision colTemp , 3
			beq noFurtherCollision
			MACROMultiplex_RegisterCollision colTemp , 4
			beq noFurtherCollision
			MACROMultiplex_RegisterCollision colTemp , 5
			beq noFurtherCollision
			MACROMultiplex_RegisterCollision colTemp , 6
			beq noFurtherCollision
			MACROMultiplex_RegisterCollision colTemp , 7
		
		noFurtherCollision:
			sty Multiplex_CollisionCounter
			ldy colRegTemp
		.ifdef Multiplexor_DebugBorderCollision 
			dec VIC2BorderColour
		.endif
			rts
		colTemp:
			.byte 0
		colRegTemp:
			.byte 0
	.endif
.endproc

;--------------------------------------
.proc Multiplex_exitinter
	; The last interrupt that displays sprites gets to this exit routine.
	Main:
	.ifdef Multiplexor_DebugBorder 
		inc VIC2BorderColour
	.endif
	inc Multiplex_BottomTriggered
	.ifdef MultiplexExt_LastIRQ
		jmp MultiplexExt_LastIRQ
	.else
		.ifndef Multiplex_EnableEarlyOut 
			.ifdef Multiplex_LogCollisions
				; Automatically update this if the Multiplex_EnableEarlyOut is not defined since the IRQ will
				; be after the last sprite.
				lda VIC2SpriteSpriteCollision
				.ifdef Multiplex_LogCollisionsBackground
					ora VIC2SpriteBackgroundCollision
				.endif
				beq _noCol
				.ifdef Multiplexor_UpdateCollisionDetailsSoftEnable
					bit Multiplexor_UpdateCollisionDetailsSoftEnableFlag
					beq _noCol
				.endif
				jsr Multiplexor_UpdateCollisionDetailsNoCheck
				_noCol:
			.endif
		.endif
		
		jsr Multiplex_Sort
		jsr Multiplex_StartTopInterrupt
		jmp Multiplex_AckExitInterrupt
	.endif
.endproc

;--------------------------------------
.proc Multiplex_AckExitInterrupt
	Main:
	MACROAckRasterIRQ_A

	.ifdef Multiplexor_DebugBorder 
		lda #VIC2Colour_Cyan 
		sta VIC2BorderColour
	.endif

	lda Multiplex_areg
	ldx Multiplex_xreg
	ldy Multiplex_yreg
	rti
.endproc

.proc Multiplex_StartTopInterrupt
	Main:
	; Start the main interrupt back at the top of the screen again
	lda #<Multiplex_maininter
	sta Multiplex_IRQServiceRoutineLo
	lda #>Multiplex_maininter
	sta Multiplex_IRQServiceRoutineHi
	
	; MPi: First raster at the top of the first sprite minus a small amount of raster time to allow the first lot of sprites to be displayed
	ldy Multiplex_indextable
	lda Multiplex_YPos,y
	sec
	sbc #8
	bcs storeRaster
	lda #0		; MPi: Don't go up beyond the top line
	storeRaster:
	sta VIC2Raster
	rts
.endproc

;--------------------------------------
.proc Multiplex_Sort
	lda Multiplex_MaxSpr
	sta Multiplex_MaxSprSorted
	cmp #$02
	bcc exit
	sbc #$02
	tay
	lda Multiplex_Sortlo,y
	sta Multiplex_bal
	lda Multiplex_Sorthi,y
	sta Multiplex_bah
	; Self modifying code that puts an RTS ($60) or LDY $xx into the sort routine below depending on how many sprites it wants to process in the index table.
	ldy #$00
	lda #$60
	sta (Multiplex_bal),y
	jsr over0
	ldy #$00
	lda #$a4
	sta (Multiplex_bal),y

	.ifdef Multiplex_EnableEarlyOut
		ldx #0
		l1:
		ldy Multiplex_indextable,x
		lda Multiplex_YPos,y
		cmp #Multiplex_DiscardSpritesYPos	; Don't display any sprites once this is reached
		bcs l2
		inx
		cpx Multiplex_MaxSpr
		bcc l1
		l2:
		stx Multiplex_MaxSprSorted
	.endif
	
	exit:	
	rts
	
	over0:	
	ldy Multiplex_indextable+1
	back0:	
	ldx Multiplex_indextable
	lda Multiplex_YPos,y
	cmp Multiplex_YPos,x
	bcs over1
	stx Multiplex_indextable+1
	sty Multiplex_indextable
	
	sortstart:
	over1:
	MACROMultiplex_SortBlock   1 , back0 , "back1"
	over2:
	SortBlockByteLength = (over2 - over1)
	MACROMultiplex_SortBlock   2 , back1 , "back2"
	MACROMultiplex_SortBlock   3 , back2 , "back3"
	MACROMultiplex_SortBlock   4 , back3 , "back4"
	MACROMultiplex_SortBlock   5 , back4 , "back5"
	MACROMultiplex_SortBlock   6 , back5 , "back6"
	MACROMultiplex_SortBlock   7 , back6 , "back7"
	MACROMultiplex_SortBlock   8 , back7 , "back8"
	MACROMultiplex_SortBlock   9 , back8 , "back9"
	MACROMultiplex_SortBlock  10 , back9 , "back10"
	MACROMultiplex_SortBlock  11 , back10 , "back11"
	MACROMultiplex_SortBlock  12 , back11 , "back12"
	MACROMultiplex_SortBlock  13 , back12 , "back13"
	MACROMultiplex_SortBlock  14 , back13 , "back14"
	MACROMultiplex_SortBlock  15 , back14 , "back15"
	MACROMultiplex_SortBlock  16 , back15 , "back16"
	MACROMultiplex_SortBlock  17 , back16 , "back17"
	MACROMultiplex_SortBlock  18 , back17 , "back18"
	MACROMultiplex_SortBlock  19 , back18 , "back19"
	MACROMultiplex_SortBlock  20 , back19 , "back20"
	MACROMultiplex_SortBlock  21 , back20 , "back21"
	MACROMultiplex_SortBlock  22 , back21 , "back22"
	MACROMultiplex_SortBlock  23 , back22 , "back23"
	MACROMultiplex_SortBlock  24 , back23 , "back24"
	MACROMultiplex_SortBlock  25 , back24 , "back25"
	MACROMultiplex_SortBlock  26 , back25 , "back26"
	MACROMultiplex_SortBlock  27 , back26 , "back27"
	MACROMultiplex_SortBlock  28 , back27 , "back28"
	MACROMultiplex_SortBlock  29 , back28 , "back29"
	MACROMultiplex_SortBlock  30 , back29 , "back30"
	MACROMultiplex_SortBlock  31 , back30 , "back31"
	MACROMultiplex_SortBlock  32 , back31 , "back32"
	MACROMultiplex_SortBlock  33 , back32 , "back33"
	MACROMultiplex_SortBlock  34 , back33 , "back34"
	MACROMultiplex_SortBlock  35 , back34 , "back35"
	MACROMultiplex_SortBlock  36 , back35 , "back36"
	MACROMultiplex_SortBlock  37 , back36 , "back37"
	MACROMultiplex_SortBlock  38 , back37 , "back38"
	MACROMultiplex_SortBlock  39 , back38 , "back39"
	MACROMultiplex_SortBlock  40 , back39 , "back40"
	MACROMultiplex_SortBlock  41 , back40 , "back41"
	MACROMultiplex_SortBlock  42 , back41 , "back42"
	MACROMultiplex_SortBlock  43 , back42 , "back43"
	MACROMultiplex_SortBlock  44 , back43 , "back44"
	MACROMultiplex_SortBlock  45 , back44 , "back45"
	MACROMultiplex_SortBlock  46 , back45 , "back46"
	over47:
	ldy Multiplex_indextable
	rts
.endproc

;--------------------------------------
.proc Multiplex_InitSort
	Main:
	ldx Multiplex_MaxSpr
	stx Multiplex_MaxSprSorted
	dex
.L1:	
	txa
	sta Multiplex_indextable,x
	dex
	bpl .L1

	lda #<Multiplex_Sort::sortstart
	sta Multiplex_bal
	lda #>Multiplex_Sort::sortstart
	sta Multiplex_bah

	ldy #$00
.L2:	
	lda Multiplex_bal
	sta Multiplex_Sortlo,y
	lda Multiplex_bah
	sta Multiplex_Sorthi,y

	lda Multiplex_bal
	clc
	adc #Multiplex_Sort::SortBlockByteLength
	sta Multiplex_bal
	bcc over
	inc Multiplex_bah
over:	
	iny
	cpy #Multiplex_items-1
	bne .L2
	rts
.endproc

;--------------------------------------
Multiplex_SetSpritePointer:
	; Store hi
	sta Multiplex_maininter::ISFP1+2
	sta Multiplex_maininter::ISFP2+2
	sta Multiplex_maininter::ISFP3+2
	sta Multiplex_maininter::ISFP4+2
	sta Multiplex_maininter::ISFP5+2
	sta Multiplex_maininter::ISFP6+2
	sta Multiplex_maininter::ISFP7+2
	sta Multiplex_maininter::ISFP8+2
	sta Multiplex_maininter::ISFP9+2
	sta Multiplex_maininter::ISFP10+2
	sta Multiplex_maininter::ISFP11+2
	sta Multiplex_maininter::ISFP12+2
	sta Multiplex_maininter::ISFP13+2
	sta Multiplex_maininter::ISFP14+2
	sta Multiplex_maininter::ISFP15+2
	sta Multiplex_maininter::ISFP16+2
	rts


.ifndef Multiplex_LeanAndMean
	.align 256, 0
	;--------------------------------------
	; These default Y values show the minimal amount of sprite packing, with 1 y pos increment per sprite, that is available.
	; Note with Multiplexor_DebugBorder this shows eight sprites updated every IRQ band
	Multiplex_YPos:
		.byte $32,$33,$34,$35,$36,$37,$38,$39
		.byte $51,$52,$53,$54,$55,$56,$57,$58
		.byte $70,$71,$72,$73,$74,$75,$76,$77
		.byte $8f,$90,$91,$92,$93,$94,$95,$96
		.byte $ae,$af,$b0,$b1,$b2,$b3,$b4,$b5
		.byte $cd,$ce,$cf,$d0,$d1,$d2,$d3,$d4
	
	
	Multiplex_XPosLo:
		.byte $20,$38,$50,$68,$80,$98,$b0,$c8
		.byte $28,$40,$58,$70,$88,$a0,$b8,$d0
		.byte $30,$48,$60,$78,$90,$a8,$c0,$d8
		.byte $38,$50,$68,$80,$98,$b0,$c8,$e0
		.byte $40,$58,$70,$88,$a0,$b8,$d0,$e8
		.byte $48,$60,$78,$90,$a8,$c0,$d8,$f0
	
	Multiplex_XPosHi:
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $00,$00,$00,$00,$00,$00,$00,$00
	
	Multiplex_Colour:
		.byte $01,$02,$03,$04,$05,$06,$07,$08
		.byte $09,$0a,$0b,$0c,$0d,$0e,$0f,$01
		.byte $01,$02,$03,$04,$05,$06,$07,$08
		.byte $09,$0a,$0b,$0c,$0d,$0e,$0f,$01
		.byte $01,$02,$03,$04,$05,$06,$07,$08
		.byte $09,$0a,$0b,$0c,$0d,$0e,$0f,$01
	
	Multiplex_SpriteFrame:
		.byte $f8,$f9,$fa,$fb,$f8,$f9,$fa,$fb
		.byte $f9,$fa,$fb,$f8,$f9,$fa,$fb,$f8
		.byte $fa,$fb,$f8,$f9,$fa,$fb,$f8,$f9
		.byte $fb,$f8,$f9,$fa,$fb,$f8,$f9,$fa
		.byte $f8,$f9,$fa,$fb,$f8,$f9,$fa,$fb
		.byte $f9,$fa,$fb,$f8,$f9,$fa,$fb,$f8
	
	Multiplex_Sortlo:	
		.res Multiplex_items-1
	Multiplex_Sorthi:	
		.res Multiplex_items-1
.endif
