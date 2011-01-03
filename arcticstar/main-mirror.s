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

	; draw screen
	; draw 9 rows of stars
	lda #$A0
	sta ptr1
	lda #$50
	sta ptr1+1
	
	lda #$A0
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
			cpy #23
			bne :--
			jsr rollPtrs
			inx
			cpx #8
			bne :---
	ldy #0
	:
	lda #9 ; horizon chr
	sta (ptr1),y
	lda #DBLUE
	sta (ptr2),y
	iny
	cpy #23
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
	
	; if at left or right edge, mirror to make a wider display area
	cpy #0
	beq leftMirror
	cpy #22
	beq rightMirror
	jmp skipMirror
	
	leftMirror:
	;lda current_col
	lda #DBLUE
	sta (ptr2),y
	lda tmp1
	clc
	adc #20
	sta (ptr1),y
	jmp skipPrint
	
	rightMirror:
	;lda current_col
	lda #DBLUE
	sta (ptr2),y
	lda tmp1
	sec
	sbc #21
	sta (ptr1),y
	jmp skipPrint
	skipMirror:
	
	;lda current_col
	lda #DBLUE
	sta (ptr2),y	
	
	lda tmp1
	inc tmp1
	sta (ptr1),y
	
	skipPrint:
	
	iny
	cpy #23
	bne :-
	jsr rollPtrs
	inx
	cpx #7
	beq :+
	cpx #12
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
	jmp $ea31		;call next interrupt

raster2:	; banner init raster
  	inc VICIRQ ; acknowledge irq
	
  	lda #LBLUE
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
	; take 21 off each row and if it gets below $9000
	; then wrap on $C2DC
	sec
	lda src_row_LO,x
	sbc #21
	sta src_row_LO,x
	bcs :+
	dec src_row_HI,x
	:
	
	; do the compare
	lda src_row_HI,x
	cmp #$90
	bcs :+
	lda #$C2
	sta src_row_HI,x
	lda #$C7
	sta src_row_LO,x
	:
	inx
	cpx #96
	beq :+
	jmp :---
	:
	rts

map_chrs:
	; now for each row, read and write bytes
	
	
	
	
	; old init code
	;ldx #24
	;:
	; src ptr
	;lda src_row_LO,x
	;sta ptr1
	;lda src_row_HI,x
	;sta ptr1+1
	
	;dest ptr
	;lda dest_row_LO,x
	;sta ptr2
	;lda dest_row_HI,x
	;sta ptr2+1
	
	; use the Y register to copy 20 bytes
	;ldy #0
	;:
	
	; old loop
	;lda (ptr1),y ; 5
	;pha			; 3
	;sty tmp1		; 3
	;tya			; 2
	;asl			; 2
	;asl			; 2
	;asl			; 2
	;tay			; 2
	;pla			; 4
	;sta (ptr2),y	; 6
	;ldy tmp1		; 3
	;iny			; 2
	;cpy #20		; 2
	;-------------------
	;instructions:	; 38
	
	; new loop
	; init code
	ldx #0
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
	ldy #0
	:
	ldpos:
	lda $0000,y		; 5
	ldx times8,y	; 4
	svpos: ; CA65 seems to mistake this for ZP addressing!
	.byte $9d,$00,$00 ; sta $0000,x		; 5
	iny				; 2
	cpy #21			; 2
	bne :-			;--
	ldx tmp1		; 18
	inx
	cpx #96
	bne :--
	rts

; routine to clear the screen
clear:
	ldx #0
:
	lda #0
	sta $5000,x
	sta $5000+40,x
	sta $5000+80,x
	sta $5000+120,x
	sta $5000+160,x
	sta $5000+200,x
	sta $5000+240,x
	sta $5000+280,x
	sta $5000+320,x
	sta $5000+360,x
	sta $5000+400,x
	sta $5000+440,x
	sta $5000+480,x
	sta $5000+520,x
	sta $5000+560,x
	sta $5000+600,x
	sta $5000+640,x
	sta $5000+680,x
	sta $5000+720,x
	sta $5000+760,x
	sta $5000+800,x
	sta $5000+840,x
	sta $5000+880,x
	sta $5000+920,x
	sta $5000+960,x
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
	
/* 
; use the following javascript to make these two data tables:
hi = "";
lo = "";
gfx_start = 0x9000
gfx_end = 0x9000 + 21*620;
biggest_offset_rows = 20;
row_width = 21;
field_depth = 96;
counter = gfx_start;
for(a=0; a<field_depth; a++){
    foo = biggest_offset_rows*Math.sin((Math.PI/(2*field_depth))*a);
	foo1 = Math.floor(foo);
	foo2 = Math.floor((foo-foo1)*10);
	
	// dithering
	if(foo2>4 && a%2 == 0) foo1++;   
         
        foo3 = Math.max(1,biggest_offset_rows-foo1);
	
        counter += (foo3*row_width);
        
        if(counter > gfx_end){
            counter -= (row_width * 620);
        }
        val = counter.toString(16);
        if(a>0){ hi+=","; lo+=","; }
        
	hi += "$"+val.substring(0,2);
	lo += "$"+val.substring(2,4);	
}
console.log("src_row_HI:\t.byte "+hi+"; high bytes");
console.log("src_row_LO:\t.byte "+lo+"; low bytes");  
*/

; for each row of bytes (96 possible rows)
src_row_HI: .byte $91,$93,$94,$96,$97,$99,$9a,$9c,$9d,$9f,$a0,$a2,$a3,$a4,$a5,$a7,$a8,$a9,$aa,$ab,$ad,$ae,$af,$b0,$b1,$b2,$b3,$b4,$b5,$b6,$b6,$b7,$b8,$b9,$ba,$ba,$bb,$bc,$bd,$bd,$be,$bf,$bf,$c0,$c0,$c1,$c2,$c2,$90,$90,$91,$91,$92,$92,$92,$93,$93,$93,$94,$94,$94,$95,$95,$95,$95,$95,$96,$96,$96,$96,$96,$96,$96,$97,$97,$97,$97,$97,$97,$97,$97,$97,$97,$98,$98,$98,$98,$98,$98,$98,$98,$98,$98,$98,$98,$99; high bytes
src_row_LO: .byte $a4,$48,$d7,$7b,$f5,$84,$fe,$78,$dd,$57,$a7,$0c,$5c,$ac,$e7,$37,$72,$ad,$d3,$f9,$0a,$30,$41,$52,$4e,$5f,$46,$42,$29,$10,$e2,$c9,$9b,$6d,$2a,$fc,$b9,$76,$1e,$db,$83,$2b,$be,$66,$f9,$8c,$0a,$9d,$3f,$bd,$26,$a4,$0d,$76,$ca,$33,$87,$db,$1a,$6e,$ad,$01,$40,$7f,$a9,$e8,$12,$51,$7b,$a5,$ba,$e4,$f9,$23,$38,$62,$77,$8c,$a1,$b6,$cb,$e0,$f5,$0a,$1f,$34,$49,$5e,$73,$88,$9d,$b2,$c7,$dc,$f1,$06; low bytes

times8:
	.byte 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184

/*
; use the following javascript to make these two data tables:
hi = "";
lo = "";
gfx_start = 0x9000
gfx_end = 0x9000 + 21*620;
biggest_offset_rows = 20;
row_width = 21;
field_depth = 96;
counter = gfx_start;
for(a=0; a<field_depth; a++){
        foo = biggest_offset_rows*Math.sin((Math.PI/(2*field_depth))*a);
	foo1 = Math.floor(foo);
	foo2 = Math.floor((foo-foo1)*10);
	
	// dithering
	if(foo2>4 && a%2 == 0) foo1++;   
         
        foo3 = Math.max(1,biggest_offset_rows-foo1);
	
        counter += (foo3*row_width);
        
        if(counter > gfx_end){
            counter -= (row_width * 620);
        }
        val = counter.toString(16);
        if(a>0){ hi+=","; lo+=","; }
        
	hi += "$"+val.substring(0,2);
	lo += "$"+val.substring(2,4);	
}
console.log("start_src_row_HI:\t.byte "+hi+"; high bytes");
console.log("start_src_row_LO:\t.byte "+lo+"; low bytes");   
*/

dest_row_HI: .byte $43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$43,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$45,$45,$45,$45,$45,$45,$45,$45,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$46,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c,$4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d; high bytes
dest_row_LO: .byte $00,$01,$02,$03,$04,$05,$06,$07,$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af,$50,$51,$52,$53,$54,$55,$56,$57,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f,$f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,$00,$01,$02,$03,$04,$05,$06,$07,$a8,$a9,$aa,$ab,$ac,$ad,$ae,$af,$50,$51,$52,$53,$54,$55,$56,$57,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7; low bytes

.segment "CHRMAP"
	.incbin "inc/tile.articstar"
	.incbin "inc/tile.articstar"

.segment "SCREEN"
	
.segment "SPRITES"
	;.incbin "inc/sprites.spr"
	
.segment "MUSIC"
;.incbin "inc/silent night.prg",2
.incbin "inc/hyperspace.prg",2

.segment "INCLUDES"
.incbin "inc/satin.wbmp",6
;.incbin "inc/merry_xmas.wbmp",6
