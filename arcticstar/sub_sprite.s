; ***
; sprite definitions, routines and data 
;

; ***
; definitions
;

.macro drawSprite sprnum, sprf, sprc, sprx, spry
	.local roll1, roll2, jmproll1, jmproll2, endroll
	; draw sprite routine	
	.ifdef DEBUG
		inc EXTCOL
	.endif
	ldy drawn_sprites	; count of total sprites drawn
						; use this as source variable
	
	lda sprf,y 	; get frame for sprite y
	
	ldx #0
	stx SPRITE_POS+(sprnum*2)
	
	ldx #sprnum
	sta VIC_SPRITES1,x
	
	; colour sprite
	lda sprc,y
	sta SPRITE_COLOUR+sprnum
	
	; make coords absolute to screen
	lda spry,y
	mapYtoScrY
	sta SPRITE_POS+1+(sprnum*2)
	
	lda sprx,y
	mapXtoScrX
	php
	clc
	adc SPRITE_POS+(sprnum*2)
	sta SPRITE_POS+(sprnum*2)
	plp
	; watch out for overflow!
	bcs :+
	lda #%11111110	; turn msb off
roll1: ; make sure were setting MSV for correct sprite
	cpx #0
	beq jmproll1
	sec
	rol
	dex
	jmp roll1
jmproll1:
	and SPRITEX_HI
	sta SPRITEX_HI
	jmp endroll
:
	lda #%00000001	; turn msb on
roll2: ; make sure were setting MSV for correct sprite
	cpx #0
	beq jmproll2
	clc
	rol
	dex
	jmp roll2
jmproll2:
	ora SPRITEX_HI
	sta SPRITEX_HI
endroll:
	; inc number of drawn sprites
	inc drawn_sprites
.endmacro

.macro mapXtoScrX
	tax
	rts
.endmacro

.macro mapYtoScrY
	tay
	rts
.endmacro

.macro XYonScreen
	sec
	rts
.endmacro

; ***
; routines
; 

init_sprites:
	; init sprites
	; turn sprites on
	jsr spriteson
	sta $d01c		; multicolour mode on
	lda #$00
	sta $d01d		; double width
	sta $d017		; double height
	lda #$00
	sta SPBGPR
init_multicolour:	; setup sprite colours
	lda #WHITE
	sta MULTI_COLOUR1
	lda #DGREY
	sta MULTI_COLOUR2
	rts

; turn sprites off
spritesoff:
	lda #0
	sta SPRITES
	rts
	
; turn sprites on
spriteson:
	lda #%11111111
	sta SPRITES
	rts


drawSprites:
	; draw game area sprites
	
	; update the sprite jmp register
	lda #MAXSPR
	sec
	sbc drawn_sprites
	sec
	sbc discarded
	sta spr_jmp
	
	cmp #0
	bne :+
	rts
:
	drawSprite 0, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #1
	bne :+
	lda #%00000001
	sta SPRITES
	rts
:
	drawSprite 1, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #2
	bne :+
	lda #%00000011
	sta SPRITES
	rts
:
	drawSprite 2, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #3
	bne :+
	lda #%00000111
	sta SPRITES
	rts
:
	drawSprite 3, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #4
	bne :+
	lda #%00001111
	sta SPRITES
	rts
:
	drawSprite 4, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #5
	bne :+
	lda #%00011111
	sta SPRITES
	rts
:
	drawSprite 5, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #6
	bne :+
	lda #%00111111
	sta SPRITES
	rts
:
	drawSprite 6, sortsprf, sortsprc, sortsprx, sortspry
	lda spr_jmp
	cmp #7
	bne :+
	lda #%01111111
	sta SPRITES
	rts
:
	drawSprite 7, sortsprf, sortsprc, sortsprx, sortspry
	lda #%11111111
	sta SPRITES
	rts
	
init_sort:
	ldx #0
dosort:
	txa
	sta sortorder,x
	cpx #MAXSPR-1
	inx
	bcc dosort
	rts

; y sort routine for sprites
sortSprites:
	ldx #0
sortloop:
	ldy sortorder+1,x
	lda spry,y
	ldy sortorder,x
	cmp spry,y
	bcs sortskip
	stx sortreload+1
sortswap:
	lda sortorder+1,x
	sta sortorder,x
	tya
	sta sortorder+1,x
	cpx #0
	beq sortreload
	dex
	ldy sortorder+1,x
	lda spry,y
	ldy sortorder,x
	cmp spry,y
	bcc sortswap
sortreload:
	ldx #0
sortskip:
	inx
	cpx #MAXSPR-1
	bcc sortloop
	rts
	
; routine to map sorted data
mapSorted:
	;sei
	.ifdef DEBUG
	;lda #RED
	;sta EXTCOL
	.endif

	
	lda #0
	tax
	sta discarded
	sta multiplex_count
:
	ldy sortorder,x
	
	sty tmp1	; store sortorder in _sorter1
	stx tmp2	; current loop counter saved in _sorter2
	
	; if sprite not on screen, discard it!
	lda sprx,y
	sta tmp3	; sprite x in _sorter3
	tax
	
	lda spry,y
	sta tmp4	; sprite y in _sorter4
	tay
	
	;XYmaze2scr _sorter3, _sorter4
	XYonScr
	
	bcc :+
	inc discarded
	jmp :++
:
	lda tmp2
	sec
	sbc discarded
	tax	; x now holds the loop counter - num of discarded sprites
		; this should be the store position in actual sprites
	lda tmp3
	sta sortsprx,x
	lda tmp4
	sta sortspry,x
	
	; if spritenumber if div by 8 then add a raster point
	txa
	beq skipAddRaster
	ora #%11111000
	and #%00000111
	bne skipAddRaster
	lda tmp4
	jsr addSpriteRaster
	
skipAddRaster:
	
	lda tmp1
	tay
	lda sprc,y
	sta sortsprc,x
	lda sprf,y
	sta sortsprf,x
:
	ldx tmp2
	inx
	cpx #MAXSPR
	bcc :---
	
	.ifdef DEBUG
	lda #BLACK
	sta EXTCOL
	.endif
	;cli
	lda sprite_sort_complete
	bne :+
		inc sprite_sort_complete
	:
	rts
	
addSpriteRaster:	; store sprite raster split for multiplexor 
	; get actual y raster point for split
	dex
	lda sortspry,x
	inx
	mapYtoScrY
	sec
	sbc #8
	ldy multiplex_count
	sta multiplex_rasters,y
	inc multiplex_count
	rts


moveSprites:
	; collision logic
	lda mode_player
	cmp #ALIVE
	bne :+
		;jsr movePlayer
	:
	
	;jsr moveUFOs
	;jsr moveBullets
	;jsr check_collisions
	
	rts

hide_spriteX:
	lda #255
	sta spry+2,x ; sprite dead so off screen
	rts

hide_player_sprite:
	lda #255
	sta spry
	sta spry+1
	rts
	
all_sprites_offscreen:
	ldx #0
:
	lda #255
	sta spry,x
	inx
	cpx #MAXSPR
	bcc :-
	
	; map them off into the sprite registers
	jsr spritesoff
	rts
	
;***	
; data for sprite handling
;

drawn_sprites:
	.byte 0	; number of sprites drawn in this frame -reset every frame!
spr_jmp:
	.res 1, 2 ; number of sprites to draw at - auto updated by the sprite mapper each frame 
discarded:
	.byte 0	; frames discarded during mapping
; virtual sprite data
sprx:
	.res MAXSPR,0
spry:
	; test data should sort
	.res MAXSPR,255
sprc:
	.res DGREY,64 ; initial sprite colours
sprf:
	.res 2,13
	.res MAXSPR-2,0

; sorted arrays
sortsprx:
	.res MAXSPR,0
sortspry:
	.res MAXSPR,0
sortsprc:
	.res MAXSPR,0
sortsprf:
	.res MAXSPR,0
; sort index
sortorder:
	.res MAXSPR,0

; other sprite info
sprite_sort_complete:
	.byte 0
multplex_raster_index:
	.byte 0	;  currently drawn raster
multiplex_count:
	.byte 0	; number of sprite splits
multiplex_rasters:        
	.res MAXSPR/8	; enough for MAXSPR sprites

; sprite frame colours
colour_explosion:
	.res YELLOW,6	; explosion
	.res ORANGE,2
	.res RED,2
	.res DGREY,2
colour_player:
	.res CYAN,15 	; player ship
colour_player_shadow:
	.res DGREY,6	; ship shadow
colour_player_laser:
	.res CYAN,6
colour_ufo_1:
	.res YELLOW,6
colour_ufo_2:
	.res LRED,6
colour_ufo_shadow:
	.res DGREY,4	; shares 2 with player
colour_ufo_cannon:
	.res RED,6
	
	
	
	