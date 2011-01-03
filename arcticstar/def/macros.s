; ***
; macros for screen effects 
;


; cls routines
; if no args, cls both pages full
; else cls appropriate page area
.macro cls page
	.local cls, cls_pg
	lda #SPACE
	.ifblank page
		ldx #0
cls:
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
		ldy scroller
		cpy #1
		beq :+
			sta PAGE_MEM1+960,x
:
		
		sta PAGE_MEM2,x
		sta PAGE_MEM2+40,x
		sta PAGE_MEM2+80,x
		sta PAGE_MEM2+120,x
		sta PAGE_MEM2+160,x
		sta PAGE_MEM2+200,x
		sta PAGE_MEM2+240,x
		sta PAGE_MEM2+280,x
		sta PAGE_MEM2+320,x
		sta PAGE_MEM2+360,x
		sta PAGE_MEM2+400,x
		sta PAGE_MEM2+440,x
		sta PAGE_MEM2+480,x
		sta PAGE_MEM2+520,x
		sta PAGE_MEM2+560,x
		sta PAGE_MEM2+600,x
		sta PAGE_MEM2+640,x
		sta PAGE_MEM2+680,x
		sta PAGE_MEM2+720,x
		sta PAGE_MEM2+760,x
		sta PAGE_MEM2+800,x
		sta PAGE_MEM2+840,x
		sta PAGE_MEM2+880,x
		sta PAGE_MEM2+920,x
		ldy scroller
		cpy #1
		beq :+
		sta PAGE_MEM2+960,x
:
		inx
		cpx #40
		jne cls
	.else
		ldx #((40-MAZEVIEWWIDTH)/2)-1
cls_pg:
		sta VIC_BANK*$4000+(page*$400)+80,x
		sta VIC_BANK*$4000+(page*$400)+80+40,x
		sta VIC_BANK*$4000+(page*$400)+80+80,x
		sta VIC_BANK*$4000+(page*$400)+80+120,x
		sta VIC_BANK*$4000+(page*$400)+80+160,x
		sta VIC_BANK*$4000+(page*$400)+80+200,x
		sta VIC_BANK*$4000+(page*$400)+80+240,x
		sta VIC_BANK*$4000+(page*$400)+80+280,x
		sta VIC_BANK*$4000+(page*$400)+80+320,x
		sta VIC_BANK*$4000+(page*$400)+80+360,x
		sta VIC_BANK*$4000+(page*$400)+80+400,x
		sta VIC_BANK*$4000+(page*$400)+80+440,x
		sta VIC_BANK*$4000+(page*$400)+80+480,x
		sta VIC_BANK*$4000+(page*$400)+80+520,x
		sta VIC_BANK*$4000+(page*$400)+80+560,x
		sta VIC_BANK*$4000+(page*$400)+80+600,x
		sta VIC_BANK*$4000+(page*$400)+80+640,x
		sta VIC_BANK*$4000+(page*$400)+80+680,x
		sta VIC_BANK*$4000+(page*$400)+80+720,x
		sta VIC_BANK*$4000+(page*$400)+80+760,x
		sta VIC_BANK*$4000+(page*$400)+80+800,x
		sta VIC_BANK*$4000+(page*$400)+80+840,x
		inx
		cpx #(42-(40-MAZEVIEWWIDTH)/2)
		bne cls_pg
	.endif
.endmacro

; col whole screen
; destructive of ptr1, ptr2, ptr3, ptr4
.macro colscreen
.local setcol
	ldy #0
	ldx page_msb
	
	stx ptr1+1
	inx
	stx ptr2+1
	inx
	stx ptr3+1
	inx
	stx ptr4+1
	
	sty ptr1
	sty ptr2
	sty ptr3
	sty ptr4
	
setcol:
	lda (ptr1),y
	tax
	lda charcol,x
	sta $d800,y
	
	lda (ptr2),y
	tax
	lda charcol,x
	sta $d900,y
	
	lda (ptr3),y
	tax
	lda charcol,x
	sta $da00,y
	
	lda (ptr4),y
	tax
	lda charcol,x
	sta $db00,y
	
	iny
	bne setcol
.endmacro

; get screen byte for a position
.macro getScrByte xpos,ypos,_scr_byte
	; store it to _scr_byte
	ldy ypos
	y40 _scr_byte
	lda xpos
	clc
	adc _scr_byte
	sta _scr_byte
	; get loc in video mem
	lda page_msb
	adc _scr_byte+1	
	sta _scr_byte+1
.endmacro

.macro getColByte xpos,ypos,_col_byte
	; store it to _scr_byte
	ldy ypos
	y40 _col_byte
	lda xpos
	clc
	adc _col_byte
	sta _col_byte
	lda #>COLOUR_RAM
	adc _col_byte+1	
	sta _col_byte+1
.endmacro

; get screen mem at start of y coord 
; if yc is specified use that else use y register
.macro getScrY addr,yc 
	.ifblank yc
		; takes y coord from the Y
		; store res addr
		y40 addr
	.else
		; takes y coord from yc - can be x, y or pointer
		; store res addr
		.if (.match (.left (1, {yc}), x))
			x40 addr
		.else
			.if (.match (.left (1, {yc}), y))
				y40 addr
			.else
				ldx yc
				x40 addr
			.endif
		.endif
	.endif
	; get loc in video mem
	lda page_msb
	adc addr+1
	sta addr+1
.endmacro

; get colour mem at start of y coord
; if yc is specified use that else use y register
.macro getColY addr,yc 
	.ifblank yc
		; takes y coord from the Y
		; store res addr
		y40 addr
	.else
		; takes y coord from yc - can be x, y or pointer
		; store res addr
		.if (.match (.left (1, {yc}), x))
			x40 addr
		.else
			.if (.match (.left (1, {yc}), y))
				y40 addr
			.else
				ldx yc
				x40 addr
			.endif
		.endif
	.endif
	lda #$d8
	adc addr+1
	sta addr+1
.endmacro

; flip page between vic pages
.macro pageFlip
	.if(DOUBLEBUFFER=1)
		lda #1
		sec
		sbc page
		sta page
		tax
		lda page_msbs,x
		sta page_msb
		lda page_vics,x
		sta page_vic
	.endif
.endmacro
.macro showPage
	.if(DOUBLEBUFFER=1)
		lda page_vic
		ora #VIC_CHARSET
		sta $d018
	.endif
.endmacro

; rectangular screen blits
.macro blitFromBuffer buf_source,width,height,x_DEST,y_DEST,composit
	.local draw
	getScrByte x_DEST,y_DEST,_blit_dest
	lda #<buf_source
	sta _blit_src
	lda #>buf_source
	sta _blit_src+1
	ldy height
draw:
	tya
	pha
	cpMemz _blit_src,_blit_dest,width,composit ; copies data
	add16b _blit_src,width
	add16b _blit_dest,#40
	pla
	tay
	dey
	bne draw	
.endmacro

; rectangular screen blits
.macro doubleBlitFromBufferAndColour buf_source,width,height,x_DEST,y_DEST,composit
	.local draw
	lda #0 ; page buffer counter
	pha
	:
	getScrByte x_DEST,y_DEST,_blit_dest
	lda #<buf_source
	sta _blit_src
	lda #>buf_source
	sta _blit_src+1
	ldy height
draw:
	tya
	pha
	cpMemz _blit_src,_blit_dest,width,composit ; copies data
	add16b _blit_src,width
	add16b _blit_dest,#40
	pla
	tay
	dey
	bne draw
	
	pageFlip
	pla
	bne :+
		lda #1 ; next page buffer counter
		pha
		jmp:-
	:
	colFromBuffer buf_source,width,height,x_DEST,y_DEST,composit
.endmacro

; rectangular colour blits
.macro colFromBuffer buf_source,width,height,x_DEST,y_DEST,composit,colour
	.local draw
	getColByte x_DEST,y_DEST,_col_byte
	lda #<buf_source
	sta _blit_src
	lda #>buf_source
	sta _blit_src+1
	ldy height
draw:
	tya
	pha
	cpColz _blit_src,_col_byte,width,composit,colour ; copies data
	add16b _blit_src,width
	add16b _col_byte,#40
	pla
	tay
	dey
	bne draw
.endmacro

.macro monoBlit1FromBuffer colour, buf_source, width, x_DEST, y_DEST, composit
	getScrByte x_DEST,y_DEST,_blit_dest
	lda #<buf_source
	sta _blit_src
	lda #>buf_source
	sta _blit_src+1
	cpMemz _blit_src,_blit_dest,width,composit ; copies data
	getColByte x_DEST,y_DEST,_col_byte
	cpColz _blit_src,_col_byte,width,composit,colour ; copies colour mem
.endmacro

; raster IRQ's
.macro init_raster routine, line
	sei
	lda #$7f
	sta CIAICR		;block cia1 interrupts
	sta CI2ICR		;block cia2 interrupts
	lda IRQMSK
	ora #1
	sta IRQMSK		;enable raster interrupts
	lda #<routine
	ldx #>routine
	sta $0314		;change the interrupt vector
	stx $0315
	lda #$1b
	sta $d011
	lda line
	sta RASTER
	cli
.endmacro

; ***
; macros for memory copying
;

; macro for copying upto 256 bytes of memory
; copies a zp src to zp dest
.macro cpMemz src,dest,len,composit
.scope
	ldy len-1
@loop:
	lda (src),y
	.ifnblank composit
	cmp #$20
	beq @sk
	.endif
	sta (dest),y
@sk:
	dey
	cpy #$ff
	bne @loop
.endscope
.endmacro

; macro for copying upto 256 bytes of colour memory
; copies a zp src to zp dest
.macro cpColz src,dest,len,composit,colour
.scope
	ldy len
@loop:
	dey
	lda (src),y
	tax
	.ifnblank composit
	cmp #$20
	beq @sk
	.endif
	.ifnblank colour
		lda colour
	.else
		lda charcol,x
	.endif
	sta (dest),y
@sk:
	cpy #$00
	bne @loop
.endscope
.endmacro

; slowdown speed
.macro slowDown speed
	ldy speed
	cpy #0
	beq :+++
:
	ldx #$ff
:
	dex
	bne :-
	dey
	bne :--
:
.endmacro

.macro hex2dec
	ldy #$2f
  ldx #$3a
  sec
:	iny
  sbc #100
  bcs :-
:	dex
  adc #10
  bmi :-
  adc #$2f
.endmacro

.macro Xscr2maze scrx
	lda scrx
	clc
	adc x_MAZE
.endmacro

.macro Yscr2maze scry
	lda scry
	clc
	adc y_MAZE
.endmacro

.macro XYscr2maze scrx, scry
	Xscr2maze scrx
	tax
	Yscr2maze scry
	tay
.endmacro

.macro XYmaze2scr mazex, mazey
	lda mazex
	sec
	sbc x_MAZE
	tax
	lda mazey
	sec
	sbc y_MAZE
	tay
.endmacro

.macro XYonScr
.local out_, out
	clc	
	cpx #0
	bmi out_
	cpx #28
	bpl out_
	cpy #22
	bpl out_
	jmp out	
out_:
	sec
out:
.endmacro

.macro mazeXtoScrX ;maps from x to acc and sets overflow if req
	clc
	adc #((40 - MAZEVIEWWIDTH)/2) + 3
	asl
	asl
	asl
	bcs :+
	sec
	sbc #1
	clc
	jmp :+++
:
	cmp #0
	bne :+
	lda #255
	clc
	jmp :++
:
	sec
	sbc #1
:
.endmacro



.macro mazeYtoScrY ; as above
	clc
	adc #(25 - MAZEVIEWHEIGHT) + 5
	asl
	asl
	asl
	adc #1
.endmacro

; get maze char at X,Y and store in Acc
.macro mazeChrToAccXY
	clc
	txa
	adc #<world
	sta $fd
	tya
	adc #>world
	sta $fe
	ldy #0
	lda ($fd),y
.endmacro

.macro accToMazeXY
	pha
	clc
	txa
	adc #<world
	sta $fd
	tya
	adc #>world
	sta $fe
	ldy #0
	pla
	sta ($fd),y
.endmacro

; as above but parametised
.macro mazeCharToAcc maze_X, maze_Y
	clc
	lda maze_X
	adc #<world
	sta $fd
	lda maze_Y
	adc #>world
	sta $fe
	ldy #0
	lda($fd),y
.endmacro

.macro is_pal ; carry clear if ntsc or set if pal
l1: 
	lda RASTER
l2: 
	cmp RASTER
	beq l2
	bmi l1
	cmp #$20
.endmacro


.macro test_error_if_acc_minus
	bpl @testminus
		@ouch:
		lda #CYAN
		sta EXTCOL
		lda #YELLOW
		sta EXTCOL
		jmp @ouch
	@testminus:
.endmacro

; ***
; definitions
;
; macros for maths 

; y pointer x 40 and store result in addr
.macro y40 addr 
	lda TABLEx40L,y
	sta addr
	lda TABLEx40H,y
	sta addr+1
.endmacro

; x pointer x 40 and store result in addr
.macro x40 addr 
	lda TABLEx40L,x
	sta addr
	lda TABLEx40H,x
	sta addr+1
.endmacro

; add an 8 bit number to num stored at addr
.macro add16b addr, byte
.local sk
	lda addr
	clc
	adc byte
	sta addr
	bcc sk
	inc addr+1
sk:
.endmacro

.macro add16 arg1, arg2, res ; LSB, MSB
	clc
	lda arg1
	adc arg2
	sta res
	lda arg1+1
	adc arg2+1
	sta res+1
.endmacro

.macro sub16 minuend, subtrahend, result
	sec			; carryflag = 1
	lda minuend		; accu = lowbyte of minuend
	sbc subtrahend		; accu = accu - lowbyte if subtrahend - 1 + carryflag
	sta result		; store lowbyte of result
					; carryflag is now cleared if an underrun occured and set otherwise
	lda minuend+1		; accu = highbyte of minuend
	sbc subtrahend+1	; accu = accu + highbyte of subtrahend - 1 + carryflag
	sta result+1		; store highbyte of result
					; again the carryflag is cleared if an underrun occured and set otherwise
.endmacro