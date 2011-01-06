; any ca65 features
.FEATURE c_comments
.macpack cbm
.macpack longbranch

.include "def/hardware.s"
.include "def/macros.s"
.include "def/definitions.s"
.importzp ptr1, ptr2, ptr3, ptr4, tmp1, tmp2, tmp3, tmp4

.segment "ZEROPAGE"
; extra pointers and tmp vars
tmp5 = 02
tmp6 = 03
tmp7 = 04
tmp8 = 05
ptr5 = 06
ptr6 = 08
ptr7 = 10
ptr8 = 12

.segment "CODE"
start:
	cld ; no decimal mode!	
	
	; select VIC bank
	lda CIA2
	and #%11111100
	ora #VIC_LAYOUT
	sta CIA2
	; setup vic charset and screen
	jsr chrset1
	
	jsr $FF8A	;Restore Vectors
	
	; setup screen
	lda #BLACK
	sta BGRCOL
	sta EXTCOL
	
	jsr clear
	
	; load gfx to chrsets
	; set up variables
	
	jsr map_chrs
	
	; get level number, and use it to index the level colours
	lda level
	sec
	sbc #1
	asl
	tax
	lda level_colours,x
	sta landscape_cols
	lda level_colours+1,x
	sta landscape_cols+1
	
	; draw screen
	; draw 22-FIELD_SIZE_Y rows of stars
	lda #<(PAGE_MEM1+84)
	sta ptr1
	lda #>(PAGE_MEM1+84)
	sta ptr1+1
	
	lda #<(PAGE_MEM1+84)
	sta ptr2
	lda #>COLOUR_RAM
	sta ptr2+1
	
	ldx #0
	:
		ldy #0
		:
			jsr rnd
			lsr
			lsr
			lsr
			lsr
			; now we have a number between 1 and 16
			clc
			adc #1
			cmp #8
			bcc :+
			lda #8
			:
			sta (ptr1),y
			lda #WHITE
			sta (ptr2),y
			iny
			cpy #FIELD_SIZE_X
			bne :--
			jsr rollPtrs
			inx
			cpx #(23-FIELD_SIZE_Y)
			bne :---
	ldy #0
	:
	lda #9 ; horizon chr
	sta (ptr1),y
	lda landscape_cols
	sta (ptr2),y
	iny
	cpy #FIELD_SIZE_X
	bne :-	
	
	; then draw the ground
	; roll pointers on a row
	jsr rollPtrs
	
	lda #96
	sta tmp1
	
	ldx #0
	:
	;jsr get_col
	ldy #0
	:
	
	;lda current_col
	lda landscape_cols
	sta (ptr2),y	
	
	lda tmp1
	inc tmp1
	sta (ptr1),y
	
	iny
	cpy #FIELD_SIZE_X
	bne :-
	jsr rollPtrs
	inx
	cpx #6
	beq :+
	cpx #FIELD_SIZE_Y-1
	beq :++
	jmp :--
	:
	lda #96
	sta tmp1
	jmp :---
	:
	; irq time
	init_raster raster1, #RASTER1_POS
	
_mainloop:
	lda #0 
	sta vblank
:	; wait for vertical blank
	lda vblank 
	beq :-
	; do mainloop here - synced to vblank
	jsr shift_read
	
	jsr map_chrs
	jsr game_loop
	jmp _mainloop

; pointer rolling
rollPtrs:
	lda ptr1
	clc
	adc #40
	sta ptr1
	lda ptr1+1
	adc #0
	sta ptr1+1
	lda ptr2
	clc
	adc #40
	sta ptr2
	lda ptr2+1
	adc #0
	sta ptr2+1
	rts
	
; colour cycle stuff
get_col:
	txa
	pha
	ldx cycle_pos
	lda cycle_cols,x
	bne :+
	lda #0
	sta cycle_pos
	lda cycle_cols
	:
	sta current_col
	pla
	tax
	inc cycle_pos
	rts
cycle_cols:
	.byte WHITE,WHITE,WHITE, DGREY,DGREY,DGREY, GREY,GREY,GREY, LGREY,LGREY,LGREY, WHITE
	.byte 0
cycle_pos:
	.byte 0
current_col:
	.byte 0
	
; raster code

raster1:	; banner init raster
  	inc VICIRQ ; acknowledge irq
	jsr game_raster_loop
	.ifdef DEBUG
		lda #LGREEN
		sta EXTCOL
	.endif
	
	inc vblank ; vertical blank sig
	
	lda #BLACK
  	sta BGRCOL
	
	jsr chrset1
	
	jsr MUSIC_PLAY		;play sid/soundfx
	
	init_raster raster2, #RASTER2_POS
	; use this for solar flashes - to come later!
	;init_raster raster_start_solarflash, start_solarflash
	
	jmp $ea31		;call next interrupt
	
raster_start_solarflash:
	inc VICIRQ ; acknowledge irq
	ldx solarflash_pos
	lda solarflash_colour,x
	sta BGRCOL
	init_raster raster_end_solarflash, end_solarflash
	jmp $ea31		;call next interrupt
	
raster_end_solarflash:
	inc VICIRQ ; acknowledge irq
	lda #BLACK
	sta BGRCOL
	jsr roll_solarflash
	init_raster raster2, #RASTER2_POS
	jmp $ea31		;call next interrupt
	
raster2:	; banner init raster
  	inc VICIRQ ; acknowledge irq
	
  	lda landscape_cols+1
  	sta BGRCOL
	init_raster raster3, #RASTER3_POS
	jmp $ea31		;call next interrupt	
	
raster3:	; banner init raster
  	inc VICIRQ ; acknowledge irq
	
	.ifdef DEBUG
		lda #LRED
		sta EXTCOL
	.endif
	jsr chrset2
	init_raster raster1, #RASTER1_POS
	jmp $ea31		;call next interrupt	
	
chrset1:
	; setup vic charset1
	lda #VIC_CHARSET1
	ora #VIC_PAGE1
	sta VMCSB
	rts
	
chrset2:
	; setup vic charset2
	lda #VIC_CHARSET2
	ora #VIC_PAGE1
	sta VMCSB
	rts

shift_read:
	ldx #0
	:
	; take 20 off each row and if it gets below $9000
	; then wrap on $C7B4
	sec
	lda src_row_LO,x
	sbc #FIELD_SIZE_X
	sta src_row_LO,x
	bcs :+
	dec src_row_HI,x
	:
	
	; do the compare
	lda src_row_HI,x
	cmp #$90
	bcs :+
	lda #>($9000 + (20*619))
	sta src_row_HI,x
	lda #<($9000 + (20*619))
	sta src_row_LO,x
	:
	inx
	cpx #96
	beq :+
	jmp :---
	:
	rts
	
;map_chrs_unrolled:
	;.include "inc/speedcode.s"	
	;rts
	
map_chrs:
	; quick colour change 
	lda #WHITE
	sta EXTCOL


	; now for each row, read and write bytes
	; init code
	ldx #95
	:
	stx tmp1
	
	lda src_row_HI,x
	sta ldpos+2
	lda src_row_LO,x
	sta ldpos+1
	lda dest_row_HI,x
	sta svpos+2
	lda dest_row_LO,x
	sta svpos+1
	; use the Y register to copy 20 bytes
	ldy #FIELD_SIZE_X-1
	:
	ldpos:
	lda $0000,y			; 5
	ldx times8,y		; 4
	svpos: ; CA65 seems to mistake this for ZP addressing!
	.byte $9d,$00,$00 	; sta $0000,x		; 5
	dey					; 2
	bpl :-				;--
	ldx tmp1			; 16
	;inc EXTCOL
	dex
	bpl :--
	rts
	
game_loop:
	rts

game_raster_loop:
	rts
	
; routine to clear the screen
clear:
	ldx #0
:
	lda #0
	sta PAGE_MEM1,x
	sta PAGE_MEM1+40,x
	sta PAGE_MEM1+80,x
	sta PAGE_MEM1+120,x
	sta PAGE_MEM1+160,x
	sta PAGE_MEM1+200,x
	sta PAGE_MEM1+240,x
	sta PAGE_MEM1+280,x
	sta PAGE_MEM1+320,x
	sta PAGE_MEM1+360,x
	sta PAGE_MEM1+400,x
	sta PAGE_MEM1+440,x
	sta PAGE_MEM1+480,x
	sta PAGE_MEM1+520,x
	sta PAGE_MEM1+560,x
	sta PAGE_MEM1+600,x
	sta PAGE_MEM1+640,x
	sta PAGE_MEM1+680,x
	sta PAGE_MEM1+720,x
	sta PAGE_MEM1+760,x
	sta PAGE_MEM1+800,x
	sta PAGE_MEM1+840,x
	sta PAGE_MEM1+880,x
	sta PAGE_MEM1+920,x
	sta PAGE_MEM1+960,x
	lda #BLACK
	sta COLOUR_RAM,x
	sta COLOUR_RAM+40,x
	sta COLOUR_RAM+80,x
	sta COLOUR_RAM+120,x
	sta COLOUR_RAM+160,x
	sta COLOUR_RAM+200,x
	sta COLOUR_RAM+240,x
	sta COLOUR_RAM+280,x
	sta COLOUR_RAM+320,x
	sta COLOUR_RAM+360,x
	sta COLOUR_RAM+400,x
	sta COLOUR_RAM+440,x
	sta COLOUR_RAM+480,x
	sta COLOUR_RAM+520,x
	sta COLOUR_RAM+560,x
	sta COLOUR_RAM+600,x
	sta COLOUR_RAM+640,x
	sta COLOUR_RAM+680,x
	sta COLOUR_RAM+720,x
	sta COLOUR_RAM+760,x
	sta COLOUR_RAM+800,x
	sta COLOUR_RAM+840,x
	sta COLOUR_RAM+880,x
	sta COLOUR_RAM+920,x
	sta COLOUR_RAM+960,x
	inx
	cpx #40
	beq :+
	jmp :-
	:
	rts

rnd:
	;jmp rndr

	; use sid white noise generator on channel 3
	;jsr rdinit
	
	;lda RANDOM ;uses SID
	
	; rnd from boulderdash!
	lda $dc04   ;CIA#1  Timer A  Lo byte 
    eor $dc05   ;CIA#1  Timer A  Hi byte 
    eor $dd04   ;CIA#2  Timer A  Lo byte 
    adc $dd05   ;CIA#2  Timer A  Hi byte 
    eor $dd06   ;CIA#2  Timer B  Lo byte 
	eor $dd07   ;CIA#2  Timer B  Hi byte 
  
	rts

vblank:
	.byte 0

.include "inc/tables.s"

times8:
	.byte 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184

solarflash_pos:
	.byte 0
solarflash_width:
	.byte 14
solarflash:
	.byte 152,147,145,142,138,133,127,120,112,103,93,82,70,57,40

solarflash_colour:
	.byte YELLOW
	.byte YELLOW
	.byte YELLOW
	.byte YELLOW
	.byte ORANGE
	.byte ORANGE
	.byte ORANGE
	.byte ORANGE
	.byte LRED
	.byte LRED
	.byte LRED
	.byte RED
	.byte RED
	.byte RED
	
start_solarflash:
	.byte 147
end_solarflash:
	.byte 152
roll_solarflash:
	ldx solarflash_pos
	lda solarflash,x
	sta end_solarflash
	lda solarflash_width
	clc
	adc solarflash_pos
	; allow wider flashes with highest pos at 14
	cmp #14
	bcc :+
	lda #14
	:
	tax
	lda solarflash,x
	sta start_solarflash
	
	inc solarflash_pos
	ldx solarflash_pos
	cpx #14
	bne :+
	ldx #0
	stx solarflash_pos
	rts
	:	
	rts

level:
	.byte 1
landscape_cols:
	.byte DBLUE
	.byte LBLUE
level_colours:
	.byte DBLUE, LBLUE, RED, LRED, DGREEN, LGREEN, DGREY, LGREY, BROWN, ORANGE
	
.segment "CHRMAP"
	.incbin "inc/tile.arcticstar"
	.incbin "inc/tile.arcticstar"
	.incbin "inc/tile.arcticstar"
	.incbin "inc/tile.arcticstar"
.segment "SCREEN"
	
.segment "SPRITES"
	;.incbin "inc/sprites.spr"
	
.segment "MUSIC"
;.incbin "inc/silent night.prg",2
.incbin "inc/hyperspace.prg",2

.segment "INCLUDES"
;.incbin "inc/spirals2.wbmp",6
.incbin "inc/rings.wbmp",6

