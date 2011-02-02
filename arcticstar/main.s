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
	jsr chrset3
	
	jsr $FF8A	;Restore Vectors
	
	; setup screen
	lda #BLACK
	sta BGRCOL
	sta EXTCOL
	
	jsr clear
	
	; load gfx to chrsets
	; set up variables
	
	jsr map_chrs
	
	jsr init_mothership
	
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
			cpx #(22-FIELD_SIZE_Y)
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
	
	lda #(FIELD_SIZE_Y*8)
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
	cpx #FIELD_SIZE_Y
	beq :++
	jmp :--
	:
	lda #(FIELD_SIZE_Y*8)
	sta tmp1
	jmp :---
	:
	
	; draw a mothership!
	;jsr draw_mothership
	
	; init the buffer
	lda #0
	sta buffer_position
	
	
	
	; irq time
	init_raster raster0, #RASTER0_POS
	
_mainloop:
	lda #0 
	sta vblank
:	; wait for vertical blank
	lda vblank 
	beq :-
	; do mainloop here - synced to vblank
	
	; inc counters
	inc frame
	inc mothership_advance_timer
	
	jsr shift_read
	
	jsr map_chrs
	
	; every 8th mothership pos - update the drawing so the stars get replaced!
	lda mothership_pos
	clc
	lsr
	lsr
	lsr
	sta tmp1
	lda %00001111
	bit tmp1
	bne :+
		lda mothership_pos
		jsr draw_mothership_row
	:
	
	ldy mothership_pos
	lda mothership_frame
	
	cmp #0
	bne :+
	lda #0
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_1
	sta jmpframe1+1
	lda table48_HI,y
	adc #>mothership_frame_1
	sta jmpframe1+2
	jmpframe1:
	jsr mothership_frame_1
	jmp end_mframe
	:
	cmp #1
	bne :+
	lda #64
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_1
	sta jmpframe2+1
	lda table48_HI,y
	adc #>mothership_frame_1
	sta jmpframe2+2
	jmpframe2:
	jsr mothership_frame_1
	jmp end_mframe
	:
	cmp #2
	bne :+
	lda #128
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_1
	sta jmpframe3+1
	lda table48_HI,y
	adc #>mothership_frame_1
	sta jmpframe3+2
	jmpframe3:
	jsr mothership_frame_1
	jmp end_mframe
	:
	cmp #3
	bne :+
	lda #0
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_2
	sta jmpframe4+1
	lda table48_HI,y
	adc #>mothership_frame_2
	sta jmpframe4+2
	jmpframe4:
	jsr mothership_frame_2
	jmp end_mframe
	:
	cmp #4
	bne :+
	lda #64
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_2
	sta jmpframe5+1
	lda table48_HI,y
	adc #>mothership_frame_2
	sta jmpframe5+2
	jmpframe5:
	jsr mothership_frame_2
	jmp end_mframe
	:
	lda #128
	clc
	adc mothership_pos
	tax
	lda table48_LO,y
	adc #<mothership_frame_2
	sta jmpframe6+1
	lda table48_HI,y
	adc #>mothership_frame_2
	sta jmpframe6+2
	jmpframe6:
	jsr mothership_frame_2
end_mframe:

	lda mothership_pos
	cmp #64
	bcs :+
		clc
		;lda #128
		;bit frame
		;beq :+
		lda mothership_advance_timer
		cmp #16
		bne :+
		inc mothership_pos
		lda #0
		sta mothership_advance_timer
	:
	inc mothership_frame
	lda mothership_frame
	cmp #6
	bcc :+
	lda #0
	sta mothership_frame
	:
	
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

raster0:	; sky raster
	inc VICIRQ ; acknowledge irq
	jsr game_raster_loop ; does nothing yet!
	.ifdef DEBUG
		lda #CYAN
		sta EXTCOL
	.endif
	
	inc vblank ; vertical blank sig
	
	lda #BLACK
  	sta BGRCOL
	
	jsr chrset3
	
	;jsr MUSIC_PLAY		;play sid/soundfx
	
	init_raster raster1, #RASTER1_POS
	; use this for solar flashes - to come later!
	;init_raster raster_start_solarflash, start_solarflash
	
	jmp $ea31		;call next interrupt

raster1:	; init raster
  	inc VICIRQ ; acknowledge irq
	.ifdef DEBUG
		lda #LGREEN
		sta EXTCOL
	.endif
	
	lda #BLACK
  	sta BGRCOL
	
	jsr chrset1
	
	init_raster raster2, #RASTER2_POS
	
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
	init_raster raster1, #RASTER1_POS
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
	init_raster raster0, #RASTER0_POS
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
	
chrset3:
	; setup vic charset3
	lda #VIC_CHARSET3
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
	cpx #(FIELD_SIZE_Y*8)
	beq :+
	jmp :---
	:
	rts

init_mothership:
	; copy frame 1
	lda #<(MOTHERSHIP+8*0)
	sta addr_from
	lda #>(MOTHERSHIP+8*0)
    sta addr_from+1
    lda #64
    sta addr_to
    lda #>BUFFER
    sta addr_to+1
    jsr init_loop    

    ; copy frame 2
	lda #<(MOTHERSHIP+8*1)
	sta addr_from
	lda #>(MOTHERSHIP+8*1)
    sta addr_from+1
    lda #128
    sta addr_to
    lda #>BUFFER
    sta addr_to+1
    jsr init_loop
    
    ; copy frame 3
	lda #<(MOTHERSHIP+8*2)
	sta addr_from
	lda #>(MOTHERSHIP+8*2)
    sta addr_from+1
    lda #192
    sta addr_to
    lda #>BUFFER
    sta addr_to+1
    jsr init_loop
    
    ; copy frame 4
	lda #<(MOTHERSHIP+8*3)
	sta addr_from
	lda #>(MOTHERSHIP+8*3)
    sta addr_from+1
    lda #64
    sta addr_to
    lda #>(BUFFER+2048)
    sta addr_to+1
    jsr init_loop
    
    ; copy frame 5
	lda #<(MOTHERSHIP+8*4)
	sta addr_from
	lda #>(MOTHERSHIP+8*4)
    sta addr_from+1
    lda #128
    sta addr_to
    lda #>(BUFFER+2048)
    sta addr_to+1
    jsr init_loop
    
    ; copy frame 6
	lda #<(MOTHERSHIP+8*5)
	sta addr_from
	lda #>(MOTHERSHIP+8*5)
    sta addr_from+1
    lda #192
    sta addr_to
    lda #>(BUFFER+2048)
    sta addr_to+1
    jsr init_loop
    
    ; do the first frames speedcode!
    ldx #0
	jsr mothership_frame_2
    
    rts
    
init_loop:
	lda #64 ; number of lines of bitmap to copy
	sta tmp1
:
	; setup vars to copy 1 row of 8 bytes
	ldy #0
    ldx #8
:
	; copy 8 byte row horz to vert in buffer
    lda (addr_from),y
    sta (addr_to),y
    inc addr_from
    bne :+
    inc addr_from+1
:
    inc addr_to+1
    dex
    bne :--
 	
    ; end of copy?
    dec tmp1
    beq :++
    
    ; setup next row
    clc
    lda addr_from
    adc #40 ;(384 pixels wide so 40 + 8 bytes already rolled)
    sta addr_from
    bcc :+
    inc addr_from+1
:
	sec
    lda addr_to+1
    sbc #8
    sta addr_to+1
    inc addr_to
    jmp :----
:
    rts
    
	
map_chrs:
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
buffer_position:
    .byte 0
bitmap_position:
    .word 0
frame:
	.byte 0
	
.include "inc/tables.s"

times8:
	.byte 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184,192,200,208,216,224,232,240,248

solarflash_pos:
	.byte 0
solarflash_width:
	.byte 2
solarflash:
	.byte 145,142,140,137,133,128,122,115,107,98,88,77,65,52,35

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

draw_mothership:
	lda #96
	ldx #0
	:
	clc
	sta PAGE_MEM1 + MOTHERSHIP_LOC,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 40,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 40,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 80,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 80,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 120,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 120,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 160,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 160,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 200,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 200,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 240,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 240,x
	pla
	adc #8
	sta PAGE_MEM1 + MOTHERSHIP_LOC + 280,x
	pha
	lda mothership_colour,x
	sta COLOUR_RAM + MOTHERSHIP_LOC + 280,x
	pla
	sec
	sbc #55
	inx
	cpx #8
	bne :-
	rts
	
draw_mothership_row:
	clc
	lsr
	lsr
	lsr
	sta tmp1
	lda #7
	sec
	sbc tmp1
	cmp #0
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC)
		sta ptr2+1
		lda #96
		jmp end_mptrs
	:
	cmp #1
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 40)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 40)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 40)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 40)
		sta ptr2+1
		lda #96+1*8
		jmp end_mptrs
	:
	cmp #2
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 80)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 80)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 80)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 80)
		sta ptr2+1
		lda #96+2*8
		jmp end_mptrs
	:
	cmp #3
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 120)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 120)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 120)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 120)
		sta ptr2+1
		lda #96+3*8
		jmp end_mptrs
	:
	cmp #4
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 160)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 160)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 160)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 160)
		sta ptr2+1
		lda #96+4*8
		jmp end_mptrs
	:
	cmp #5
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 200)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 200)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 200)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 200)
		sta ptr2+1
		lda #96+5*8
		jmp end_mptrs
	:
	cmp #6
	bne :+
		lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 240)
		sta ptr1
		lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 240)
		sta ptr1+1
		lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 240)
		sta ptr2
		lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 240)
		sta ptr2+1
		lda #96+6*8
		jmp end_mptrs
	:
	lda #<(PAGE_MEM1 + MOTHERSHIP_LOC + 280)
	sta ptr1
	lda #>(PAGE_MEM1 + MOTHERSHIP_LOC + 280)
	sta ptr1+1
	lda #<(COLOUR_RAM + MOTHERSHIP_LOC + 280)
	sta ptr2
	lda #>(COLOUR_RAM + MOTHERSHIP_LOC + 280)
	sta ptr2+1
	lda #96+7*8

	end_mptrs:
	
	ldy #0
	:
	sta (ptr1),y
	pha
	lda mothership_colour,y
	sta (ptr2),y
	pla
	clc
	adc #1
	iny
	cpy #8
	bne :-
	rts	

level:
	.byte 4
landscape_cols:
	.byte DBLUE
	.byte LBLUE
level_colours:
	.byte DBLUE, LBLUE, RED, LRED, DGREEN, LGREEN, DGREY, LGREY, BROWN, ORANGE
mothership_colour:
	;.byte RED,LRED,WHITE,LRED,LRED,RED,BROWN,DGREY
	.byte ORANGE,YELLOW,WHITE,YELLOW,YELLOW,ORANGE,BROWN,DGREY
	;.byte DGREEN,LGREEN,WHITE,LGREEN,LGREEN,DGREEN,DGREEN,DGREY
	;.byte DBLUE,LBLUE,WHITE,LBLUE,LBLUE,DBLUE,DBLUE,DGREY
	;.byte GREY,LGREY,WHITE,LGREY,LGREY,GREY,GREY,DGREY
mothership_pos:
	.byte 0
mothership_frame:
	.byte 0
mothership_advance_timer:
	.byte 0
.include "inc/speedcode.s"

.segment "BUFFER"
	BUFFER:
    .res 16*256,0
	
.segment "CHRMAP"
	CHR_LANDSCAPE:
	.incbin "inc/tile.arcticstar"
	.incbin "inc/tile.arcticstar"
	CHR_MOTHERSHIP:
	.incbin "inc/tile.arcticstar"
.segment "SCREEN"
	
.segment "SPRITES"
	;.incbin "inc/sprites.spr"
	
;.segment "MUSIC"
	;.incbin "inc/silent night.prg",2
	;.incbin "inc/hyperspace.prg",2

.segment "INCLUDES"
	LANDSCAPE:
	;.incbin "inc/spirals2.wbmp",6
	.incbin "inc/rings.wbmp",6
	EOF_LANDSCAPE:
	MOTHERSHIP:
	.incbin "inc/mothership.wbmp",5
	EOF_MOTHERSHIP:
