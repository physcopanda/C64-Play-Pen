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
addr_from = 02
addr_to = 04
.segment "CODE"
start:
	cld ; no decimal mode!	
	
	; select Memory layout
	full_ram_off
	
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
	lda landscape_cols
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
	
	;lda current_col
	lda landscape_cols
	sta (ptr2),y	
	
	lda tmp1
	inc tmp1
	sta (ptr1),y
	
	iny
	cpy #23
	bne :-
	jsr rollPtrs
	inx
	cpx #6
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
	
	lda #159
	sta buffer_position
	
	lda #$9D            ; beginning address of last row of bitmap $C79D
	sta bitmap_position
	lda #$C7
	sta bitmap_position + 1
	
	jsr InitBuffer
	
_mainloop:
	lda #0 
	sta vblank
:	; wait for vertical blank
	lda vblank 
	beq :-
	; do mainloop here - synced to vblank

	; jsr shift_read
	; jsr map_chrs
	lda #1
	;sta $d020
	ldx buffer_position
	jsr SPEEDCODE_BASE
	lda #3
	;sta $d020
	sec
	lda bitmap_position
	sbc #23
	sta bitmap_position
	bcs :+
	dec bitmap_position+1
:
    lda bitmap_position
    cmp #$00
    bne :+
    lda bitmap_position+1
    cmp #$90
    bne :+
	lda #$9D            ; beginning address of last row of bitmap $C79D
	sta bitmap_position
	lda #$C7
	sta bitmap_position + 1
:
	lda buffer_position
	dec buffer_position
	lda buffer_position
	cmp #255
	bne :+
    lda #159
    sta buffer_position
:
   	; CopyRowsFromBitmap
	jsr CopyRowsFromBitmap

	lda #0
	;sta $d020
	jmp _mainloop

; Copy 96 rows from bitmap
InitBuffer:
    sec                 ; first row
    lda bitmap_position
    sta addr_from
    lda bitmap_position+1
    sta addr_from+1
    
    clc
    lda buffer_position
    adc #96
    sta addr_to
    lda #>BUFFER_BASE
    sta addr_to+1

initloop:
    ldy #0
    ldx #23
:
    lda (addr_from),y
    sta (addr_to),y
    inc addr_from
    bne :+
    inc addr_from+1
:
    inc addr_to+1
    dex
    bne :--
    
    sec
    lda addr_from
    sbc #46
    sta addr_from
    bcs :+
    dec addr_from+1
:
    lda #>BUFFER_BASE
    sta addr_to+1
    dec addr_to
    lda addr_to
    cmp buffer_position
    bcc :+
    jmp initloop
:
    rts

; Copy two rows from bitmap
CopyRowsFromBitmap:
    sec                 ; first row
    lda bitmap_position
    sbc #$B7
    sta addr_from
    lda bitmap_position+1
    sbc #$08
    sta addr_from+1
    lda addr_from+1
    cmp #$90
    bcs :+
    clc
    lda #$B4            
	adc addr_from
	sta addr_from
	lda #$37
	adc addr_from + 1
	sta addr_from + 1
    :
    
    lda buffer_position
    sta addr_to
    lda #>BUFFER_BASE
    sta addr_to+1
    ldy #0
    ldx #23
:
    lda (addr_from),y
    sta (addr_to),y
    inc addr_from
    bne :+
    inc addr_from+1
:
    inc addr_to+1
    dex
    bne :--

    sec                 ; second row
    lda bitmap_position
    sbc #$60
    sta addr_from
    lda bitmap_position+1
    sbc #$0E
    sta addr_from+1
    cmp #$90
    bcs :+
    clc
    lda #$B4            
	adc addr_from
	sta addr_from
	lda #$37
	adc addr_from + 1
	sta addr_from + 1
    :
    
    clc
    lda buffer_position
    adc #96
    sta addr_to
    lda #>BUFFER_BASE
    sta addr_to+1
    ldy #0
    ldx #23
:
    lda (addr_from),y
    sta (addr_to),y
    inc addr_from
    bne :+
    inc addr_from+1
:
    inc addr_to+1
    dex
    bne :--

    rts

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
	
;	jsr MUSIC_PLAY		;play sid/soundfx
	
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
	; take 23 off each row and if it gets below $9000
	; then wrap on $C7B4
	sec
	lda src_row_LO,x
	sbc #23
	sta src_row_LO,x
	bcs :+
	dec src_row_HI,x
	:
	
	; do the compare
	lda src_row_HI,x
	cmp #$90
	bcs :+
	lda #$C7
	sta src_row_HI,x
	lda #$9D
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
	; use the Y register to copy 23 bytes
	ldy #0
	:
	ldpos:
	lda $0000,y		; 5
	ldx times8,y	; 4
	svpos: ; CA65 seems to mistake this for ZP addressing!
	.byte $9d,$00,$00 ; sta $0000,x		; 5
	iny				; 2
	cpy #23			; 2
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
	
buffer_position:
    .byte 0

bitmap_position:
    .word 0
    
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
src_row_HI: .byte $91,$93,$95,$97,$98,$9a,$9c,$9d,$9f,$a0,$a2,$a3,$a5,$a6,$a7,$a9,$aa,$ac,$ad,$ae,$af,$b1,$b2,$b3,$b4,$b5,$b6,$b7,$b8,$b9,$ba,$bb,$bc,$bd,$be,$bf,$bf,$c0,$c1,$c2,$c2,$c3,$c4,$c5,$c5,$c6,$c6,$c7,$90,$90,$91,$91,$92,$92,$93,$93,$93,$94,$94,$94,$95,$95,$95,$96,$96,$96,$96,$96,$97,$97,$97,$97,$97,$97,$98,$98,$98,$98,$98,$99,$99,$99,$99,$99,$99,$9a,$9a,$9a,$9a,$9a,$9b,$9b,$9b,$9b,$9b,$9b; high bytes
src_row_LO: .byte $cc,$98,$4d,$19,$b7,$6c,$0a,$a8,$2f,$cd,$3d,$c4,$34,$a4,$fd,$6d,$c6,$1f,$61,$a3,$ce,$10,$3b,$66,$7a,$a5,$a2,$b6,$b3,$b0,$96,$93,$79,$5f,$2e,$14,$e3,$b2,$6a,$39,$f1,$a9,$4a,$02,$a3,$44,$ce,$6f,$45,$cf,$42,$cc,$3f,$b2,$0e,$81,$dd,$39,$7e,$da,$1f,$7b,$c0,$05,$33,$78,$a6,$eb,$19,$47,$75,$a3,$d1,$ff,$2d,$5b,$89,$b7,$e5,$13,$41,$6f,$9d,$cb,$f9,$27,$55,$83,$b1,$df,$0d,$3b,$69,$97,$c5,$f3; low bytes

times8:
	.byte 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168,176,184

/*
; use the following javascript to make these two data tables:
hi = "";
lo = "";
row_width = 23;
rows1 = 6;
rows2 = 6;
start = 0x4300;
for(a=0; a<rows1; a++){
	val = start + (row_width*a*8);
	for(b=0; b<8; b++){
	hex = val.toString(16);
	if(hi!=""){
		hi+=",";
		lo+=",";
	}
	hi += "$"+hex.substring(0,2);
	lo += "$"+hex.substring(2,4);
	val++;
}
    
	
	}
start = 0x4B00;
for(a=0; a<rows2; a++){
    		val = start + (row_width*a*8);
        for(b=0; b<8; b++){
        hex = val.toString(16);
        if(hi!=""){
			hi+=",";
			lo+=",";
		}
		hi += "$"+hex.substring(0,2);
		lo += "$"+hex.substring(2,4);
        val++;
 }
	
	}
	console.log("dest_row_HI:\t.byte "+hi+"; high bytes");
	console.log("dest_row_LO:\t.byte "+lo+"; low bytes");
*/

dest_row_HI:
 
	.byte $43,$43,$43,$43,$43,$43,$43,$43; high bytes row 1  
	.byte $43,$43,$43,$43,$43,$43,$43,$43; high bytes row 2  
	.byte $44,$44,$44,$44,$44,$44,$44,$44; high bytes row 3  
	.byte $45,$45,$45,$45,$45,$45,$45,$45; high bytes row 4  
	.byte $45,$45,$45,$45,$45,$45,$45,$45; high bytes row 5  
	.byte $46,$46,$46,$46,$46,$46,$46,$46; high bytes row 6  
	.byte $4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b; high bytes row 7  
	.byte $4b,$4b,$4b,$4b,$4b,$4b,$4b,$4b; high bytes row 8  
	.byte $4c,$4c,$4c,$4c,$4c,$4c,$4c,$4c; high bytes row 9  
	.byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d; high bytes row 10  
	.byte $4d,$4d,$4d,$4d,$4d,$4d,$4d,$4d; high bytes row 11  
	.byte $4e,$4e,$4e,$4e,$4e,$4e,$4e,$4e; high bytes row 12
dest_row_LO:
 
	.byte $00,$01,$02,$03,$04,$05,$06,$07; low bytes row 1  
	.byte $b8,$b9,$ba,$bb,$bc,$bd,$be,$bf; low bytes row 2  
	.byte $70,$71,$72,$73,$74,$75,$76,$77; low bytes row 3  
	.byte $28,$29,$2a,$2b,$2c,$2d,$2e,$2f; low bytes row 4  
	.byte $e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7; low bytes row 5  
	.byte $98,$99,$9a,$9b,$9c,$9d,$9e,$9f; low bytes row 6  
	.byte $00,$01,$02,$03,$04,$05,$06,$07; low bytes row 7  
	.byte $b8,$b9,$ba,$bb,$bc,$bd,$be,$bf; low bytes row 8  
	.byte $70,$71,$72,$73,$74,$75,$76,$77; low bytes row 9  
	.byte $28,$29,$2a,$2b,$2c,$2d,$2e,$2f; low bytes row 10  
	.byte $e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7; low bytes row 11  
	.byte $98,$99,$9a,$9b,$9c,$9d,$9e,$9f; low bytes row 12  

level:
	.byte 1
landscape_cols:
	.byte DBLUE
	.byte LBLUE
level_colours:
	.byte DBLUE, LBLUE, RED, LRED, DGREEN, LGREEN, DGREY, LGREY, BROWN, ORANGE
	
;.segment "MUSIC"
;.incbin "inc/silent night.prg",2
;.incbin "inc/hyperspace.prg",2

.segment "BUFFER"
    .repeat 5888
        .byte $00
    .endrep

.segment "CHRMAP"
	.incbin "inc/tile.arcticstar"
	.incbin "inc/tile.arcticstar"
.segment "SPEEDCODE"
    .include "inc/speedcode.s"

.segment "SCREEN"
	
.segment "SPRITES"
	;.incbin "inc/sprites.spr"
	
.segment "INCLUDES"
.incbin "inc/rings_wide.wbmp",6
