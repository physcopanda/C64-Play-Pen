lda src_row_HI+0
sta ptr1+1
lda src_row_LO+0
sta ptr1
ldy #0
lda dest_row_HI+0
sta ptr2+1
lda dest_row_LO+0
sta ptr2
:
lda (ptr1),y
iny
sta $4318
cpy #20
bne :-
lda src_row_HI+1
sta ptr1+1
lda src_row_LO+1
sta ptr1
ldy #0
lda dest_row_HI+1
sta ptr2+1
lda dest_row_LO+1
sta ptr2
:
lda (ptr1),y
iny
sta $4319
cpy #20
bne :-
lda src_row_HI+2
sta ptr1+1
lda src_row_LO+2
sta ptr1
ldy #0
lda dest_row_HI+2
sta ptr2+1
lda dest_row_LO+2
sta ptr2
:
lda (ptr1),y
iny
sta $431a
cpy #20
bne :-
lda src_row_HI+3
sta ptr1+1
lda src_row_LO+3
sta ptr1
ldy #0
lda dest_row_HI+3
sta ptr2+1
lda dest_row_LO+3
sta ptr2
:
lda (ptr1),y
iny
sta $431b
cpy #20
bne :-
lda src_row_HI+4
sta ptr1+1
lda src_row_LO+4
sta ptr1
ldy #0
lda dest_row_HI+4
sta ptr2+1
lda dest_row_LO+4
sta ptr2
:
lda (ptr1),y
iny
sta $431c
cpy #20
bne :-
lda src_row_HI+5
sta ptr1+1
lda src_row_LO+5
sta ptr1
ldy #0
lda dest_row_HI+5
sta ptr2+1
lda dest_row_LO+5
sta ptr2
:
lda (ptr1),y
iny
sta $431d
cpy #20
bne :-
lda src_row_HI+6
sta ptr1+1
lda src_row_LO+6
sta ptr1
ldy #0
lda dest_row_HI+6
sta ptr2+1
lda dest_row_LO+6
sta ptr2
:
lda (ptr1),y
iny
sta $431e
cpy #20
bne :-
lda src_row_HI+7
sta ptr1+1
lda src_row_LO+7
sta ptr1
ldy #0
lda dest_row_HI+7
sta ptr2+1
lda dest_row_LO+7
sta ptr2
:
lda (ptr1),y
iny
sta $431f
cpy #20
bne :-
lda src_row_HI+8
sta ptr1+1
lda src_row_LO+8
sta ptr1
ldy #0
lda dest_row_HI+8
sta ptr2+1
lda dest_row_LO+8
sta ptr2
:
lda (ptr1),y
iny
sta $43b8
cpy #20
bne :-
lda src_row_HI+9
sta ptr1+1
lda src_row_LO+9
sta ptr1
ldy #0
lda dest_row_HI+9
sta ptr2+1
lda dest_row_LO+9
sta ptr2
:
lda (ptr1),y
iny
sta $43b9
cpy #20
bne :-
lda src_row_HI+10
sta ptr1+1
lda src_row_LO+10
sta ptr1
ldy #0
lda dest_row_HI+10
sta ptr2+1
lda dest_row_LO+10
sta ptr2
:
lda (ptr1),y
iny
sta $43ba
cpy #20
bne :-
lda src_row_HI+11
sta ptr1+1
lda src_row_LO+11
sta ptr1
ldy #0
lda dest_row_HI+11
sta ptr2+1
lda dest_row_LO+11
sta ptr2
:
lda (ptr1),y
iny
sta $43bb
cpy #20
bne :-
lda src_row_HI+12
sta ptr1+1
lda src_row_LO+12
sta ptr1
ldy #0
lda dest_row_HI+12
sta ptr2+1
lda dest_row_LO+12
sta ptr2
:
lda (ptr1),y
iny
sta $43bc
cpy #20
bne :-
lda src_row_HI+13
sta ptr1+1
lda src_row_LO+13
sta ptr1
ldy #0
lda dest_row_HI+13
sta ptr2+1
lda dest_row_LO+13
sta ptr2
:
lda (ptr1),y
iny
sta $43bd
cpy #20
bne :-
lda src_row_HI+14
sta ptr1+1
lda src_row_LO+14
sta ptr1
ldy #0
lda dest_row_HI+14
sta ptr2+1
lda dest_row_LO+14
sta ptr2
:
lda (ptr1),y
iny
sta $43be
cpy #20
bne :-
lda src_row_HI+15
sta ptr1+1
lda src_row_LO+15
sta ptr1
ldy #0
lda dest_row_HI+15
sta ptr2+1
lda dest_row_LO+15
sta ptr2
:
lda (ptr1),y
iny
sta $43bf
cpy #20
bne :-
lda src_row_HI+16
sta ptr1+1
lda src_row_LO+16
sta ptr1
ldy #0
lda dest_row_HI+16
sta ptr2+1
lda dest_row_LO+16
sta ptr2
:
lda (ptr1),y
iny
sta $4458
cpy #20
bne :-
lda src_row_HI+17
sta ptr1+1
lda src_row_LO+17
sta ptr1
ldy #0
lda dest_row_HI+17
sta ptr2+1
lda dest_row_LO+17
sta ptr2
:
lda (ptr1),y
iny
sta $4459
cpy #20
bne :-
lda src_row_HI+18
sta ptr1+1
lda src_row_LO+18
sta ptr1
ldy #0
lda dest_row_HI+18
sta ptr2+1
lda dest_row_LO+18
sta ptr2
:
lda (ptr1),y
iny
sta $445a
cpy #20
bne :-
lda src_row_HI+19
sta ptr1+1
lda src_row_LO+19
sta ptr1
ldy #0
lda dest_row_HI+19
sta ptr2+1
lda dest_row_LO+19
sta ptr2
:
lda (ptr1),y
iny
sta $445b
cpy #20
bne :-
lda src_row_HI+20
sta ptr1+1
lda src_row_LO+20
sta ptr1
ldy #0
lda dest_row_HI+20
sta ptr2+1
lda dest_row_LO+20
sta ptr2
:
lda (ptr1),y
iny
sta $445c
cpy #20
bne :-
lda src_row_HI+21
sta ptr1+1
lda src_row_LO+21
sta ptr1
ldy #0
lda dest_row_HI+21
sta ptr2+1
lda dest_row_LO+21
sta ptr2
:
lda (ptr1),y
iny
sta $445d
cpy #20
bne :-
lda src_row_HI+22
sta ptr1+1
lda src_row_LO+22
sta ptr1
ldy #0
lda dest_row_HI+22
sta ptr2+1
lda dest_row_LO+22
sta ptr2
:
lda (ptr1),y
iny
sta $445e
cpy #20
bne :-
lda src_row_HI+23
sta ptr1+1
lda src_row_LO+23
sta ptr1
ldy #0
lda dest_row_HI+23
sta ptr2+1
lda dest_row_LO+23
sta ptr2
:
lda (ptr1),y
iny
sta $445f
cpy #20
bne :-
lda src_row_HI+24
sta ptr1+1
lda src_row_LO+24
sta ptr1
ldy #0
lda dest_row_HI+24
sta ptr2+1
lda dest_row_LO+24
sta ptr2
:
lda (ptr1),y
iny
sta $44f8
cpy #20
bne :-
lda src_row_HI+25
sta ptr1+1
lda src_row_LO+25
sta ptr1
ldy #0
lda dest_row_HI+25
sta ptr2+1
lda dest_row_LO+25
sta ptr2
:
lda (ptr1),y
iny
sta $44f9
cpy #20
bne :-
lda src_row_HI+26
sta ptr1+1
lda src_row_LO+26
sta ptr1
ldy #0
lda dest_row_HI+26
sta ptr2+1
lda dest_row_LO+26
sta ptr2
:
lda (ptr1),y
iny
sta $44fa
cpy #20
bne :-
lda src_row_HI+27
sta ptr1+1
lda src_row_LO+27
sta ptr1
ldy #0
lda dest_row_HI+27
sta ptr2+1
lda dest_row_LO+27
sta ptr2
:
lda (ptr1),y
iny
sta $44fb
cpy #20
bne :-
lda src_row_HI+28
sta ptr1+1
lda src_row_LO+28
sta ptr1
ldy #0
lda dest_row_HI+28
sta ptr2+1
lda dest_row_LO+28
sta ptr2
:
lda (ptr1),y
iny
sta $44fc
cpy #20
bne :-
lda src_row_HI+29
sta ptr1+1
lda src_row_LO+29
sta ptr1
ldy #0
lda dest_row_HI+29
sta ptr2+1
lda dest_row_LO+29
sta ptr2
:
lda (ptr1),y
iny
sta $44fd
cpy #20
bne :-
lda src_row_HI+30
sta ptr1+1
lda src_row_LO+30
sta ptr1
ldy #0
lda dest_row_HI+30
sta ptr2+1
lda dest_row_LO+30
sta ptr2
:
lda (ptr1),y
iny
sta $44fe
cpy #20
bne :-
lda src_row_HI+31
sta ptr1+1
lda src_row_LO+31
sta ptr1
ldy #0
lda dest_row_HI+31
sta ptr2+1
lda dest_row_LO+31
sta ptr2
:
lda (ptr1),y
iny
sta $44ff
cpy #20
bne :-
lda src_row_HI+32
sta ptr1+1
lda src_row_LO+32
sta ptr1
ldy #0
lda dest_row_HI+32
sta ptr2+1
lda dest_row_LO+32
sta ptr2
:
lda (ptr1),y
iny
sta $4598
cpy #20
bne :-
lda src_row_HI+33
sta ptr1+1
lda src_row_LO+33
sta ptr1
ldy #0
lda dest_row_HI+33
sta ptr2+1
lda dest_row_LO+33
sta ptr2
:
lda (ptr1),y
iny
sta $4599
cpy #20
bne :-
lda src_row_HI+34
sta ptr1+1
lda src_row_LO+34
sta ptr1
ldy #0
lda dest_row_HI+34
sta ptr2+1
lda dest_row_LO+34
sta ptr2
:
lda (ptr1),y
iny
sta $459a
cpy #20
bne :-
lda src_row_HI+35
sta ptr1+1
lda src_row_LO+35
sta ptr1
ldy #0
lda dest_row_HI+35
sta ptr2+1
lda dest_row_LO+35
sta ptr2
:
lda (ptr1),y
iny
sta $459b
cpy #20
bne :-
lda src_row_HI+36
sta ptr1+1
lda src_row_LO+36
sta ptr1
ldy #0
lda dest_row_HI+36
sta ptr2+1
lda dest_row_LO+36
sta ptr2
:
lda (ptr1),y
iny
sta $459c
cpy #20
bne :-
lda src_row_HI+37
sta ptr1+1
lda src_row_LO+37
sta ptr1
ldy #0
lda dest_row_HI+37
sta ptr2+1
lda dest_row_LO+37
sta ptr2
:
lda (ptr1),y
iny
sta $459d
cpy #20
bne :-
lda src_row_HI+38
sta ptr1+1
lda src_row_LO+38
sta ptr1
ldy #0
lda dest_row_HI+38
sta ptr2+1
lda dest_row_LO+38
sta ptr2
:
lda (ptr1),y
iny
sta $459e
cpy #20
bne :-
lda src_row_HI+39
sta ptr1+1
lda src_row_LO+39
sta ptr1
ldy #0
lda dest_row_HI+39
sta ptr2+1
lda dest_row_LO+39
sta ptr2
:
lda (ptr1),y
iny
sta $459f
cpy #20
bne :-
lda src_row_HI+40
sta ptr1+1
lda src_row_LO+40
sta ptr1
ldy #0
lda dest_row_HI+40
sta ptr2+1
lda dest_row_LO+40
sta ptr2
:
lda (ptr1),y
iny
sta $4638
cpy #20
bne :-
lda src_row_HI+41
sta ptr1+1
lda src_row_LO+41
sta ptr1
ldy #0
lda dest_row_HI+41
sta ptr2+1
lda dest_row_LO+41
sta ptr2
:
lda (ptr1),y
iny
sta $4639
cpy #20
bne :-
lda src_row_HI+42
sta ptr1+1
lda src_row_LO+42
sta ptr1
ldy #0
lda dest_row_HI+42
sta ptr2+1
lda dest_row_LO+42
sta ptr2
:
lda (ptr1),y
iny
sta $463a
cpy #20
bne :-
lda src_row_HI+43
sta ptr1+1
lda src_row_LO+43
sta ptr1
ldy #0
lda dest_row_HI+43
sta ptr2+1
lda dest_row_LO+43
sta ptr2
:
lda (ptr1),y
iny
sta $463b
cpy #20
bne :-
lda src_row_HI+44
sta ptr1+1
lda src_row_LO+44
sta ptr1
ldy #0
lda dest_row_HI+44
sta ptr2+1
lda dest_row_LO+44
sta ptr2
:
lda (ptr1),y
iny
sta $463c
cpy #20
bne :-
lda src_row_HI+45
sta ptr1+1
lda src_row_LO+45
sta ptr1
ldy #0
lda dest_row_HI+45
sta ptr2+1
lda dest_row_LO+45
sta ptr2
:
lda (ptr1),y
iny
sta $463d
cpy #20
bne :-
lda src_row_HI+46
sta ptr1+1
lda src_row_LO+46
sta ptr1
ldy #0
lda dest_row_HI+46
sta ptr2+1
lda dest_row_LO+46
sta ptr2
:
lda (ptr1),y
iny
sta $463e
cpy #20
bne :-
lda src_row_HI+47
sta ptr1+1
lda src_row_LO+47
sta ptr1
ldy #0
lda dest_row_HI+47
sta ptr2+1
lda dest_row_LO+47
sta ptr2
:
lda (ptr1),y
iny
sta $463f
cpy #20
bne :-
lda src_row_HI+48
sta ptr1+1
lda src_row_LO+48
sta ptr1
ldy #0
lda dest_row_HI+48
sta ptr2+1
lda dest_row_LO+48
sta ptr2
:
lda (ptr1),y
iny
sta $4b18
cpy #20
bne :-
lda src_row_HI+49
sta ptr1+1
lda src_row_LO+49
sta ptr1
ldy #0
lda dest_row_HI+49
sta ptr2+1
lda dest_row_LO+49
sta ptr2
:
lda (ptr1),y
iny
sta $4b19
cpy #20
bne :-
lda src_row_HI+50
sta ptr1+1
lda src_row_LO+50
sta ptr1
ldy #0
lda dest_row_HI+50
sta ptr2+1
lda dest_row_LO+50
sta ptr2
:
lda (ptr1),y
iny
sta $4b1a
cpy #20
bne :-
lda src_row_HI+51
sta ptr1+1
lda src_row_LO+51
sta ptr1
ldy #0
lda dest_row_HI+51
sta ptr2+1
lda dest_row_LO+51
sta ptr2
:
lda (ptr1),y
iny
sta $4b1b
cpy #20
bne :-
lda src_row_HI+52
sta ptr1+1
lda src_row_LO+52
sta ptr1
ldy #0
lda dest_row_HI+52
sta ptr2+1
lda dest_row_LO+52
sta ptr2
:
lda (ptr1),y
iny
sta $4b1c
cpy #20
bne :-
lda src_row_HI+53
sta ptr1+1
lda src_row_LO+53
sta ptr1
ldy #0
lda dest_row_HI+53
sta ptr2+1
lda dest_row_LO+53
sta ptr2
:
lda (ptr1),y
iny
sta $4b1d
cpy #20
bne :-
lda src_row_HI+54
sta ptr1+1
lda src_row_LO+54
sta ptr1
ldy #0
lda dest_row_HI+54
sta ptr2+1
lda dest_row_LO+54
sta ptr2
:
lda (ptr1),y
iny
sta $4b1e
cpy #20
bne :-
lda src_row_HI+55
sta ptr1+1
lda src_row_LO+55
sta ptr1
ldy #0
lda dest_row_HI+55
sta ptr2+1
lda dest_row_LO+55
sta ptr2
:
lda (ptr1),y
iny
sta $4b1f
cpy #20
bne :-
lda src_row_HI+56
sta ptr1+1
lda src_row_LO+56
sta ptr1
ldy #0
lda dest_row_HI+56
sta ptr2+1
lda dest_row_LO+56
sta ptr2
:
lda (ptr1),y
iny
sta $4bb8
cpy #20
bne :-
lda src_row_HI+57
sta ptr1+1
lda src_row_LO+57
sta ptr1
ldy #0
lda dest_row_HI+57
sta ptr2+1
lda dest_row_LO+57
sta ptr2
:
lda (ptr1),y
iny
sta $4bb9
cpy #20
bne :-
lda src_row_HI+58
sta ptr1+1
lda src_row_LO+58
sta ptr1
ldy #0
lda dest_row_HI+58
sta ptr2+1
lda dest_row_LO+58
sta ptr2
:
lda (ptr1),y
iny
sta $4bba
cpy #20
bne :-
lda src_row_HI+59
sta ptr1+1
lda src_row_LO+59
sta ptr1
ldy #0
lda dest_row_HI+59
sta ptr2+1
lda dest_row_LO+59
sta ptr2
:
lda (ptr1),y
iny
sta $4bbb
cpy #20
bne :-
lda src_row_HI+60
sta ptr1+1
lda src_row_LO+60
sta ptr1
ldy #0
lda dest_row_HI+60
sta ptr2+1
lda dest_row_LO+60
sta ptr2
:
lda (ptr1),y
iny
sta $4bbc
cpy #20
bne :-
lda src_row_HI+61
sta ptr1+1
lda src_row_LO+61
sta ptr1
ldy #0
lda dest_row_HI+61
sta ptr2+1
lda dest_row_LO+61
sta ptr2
:
lda (ptr1),y
iny
sta $4bbd
cpy #20
bne :-
lda src_row_HI+62
sta ptr1+1
lda src_row_LO+62
sta ptr1
ldy #0
lda dest_row_HI+62
sta ptr2+1
lda dest_row_LO+62
sta ptr2
:
lda (ptr1),y
iny
sta $4bbe
cpy #20
bne :-
lda src_row_HI+63
sta ptr1+1
lda src_row_LO+63
sta ptr1
ldy #0
lda dest_row_HI+63
sta ptr2+1
lda dest_row_LO+63
sta ptr2
:
lda (ptr1),y
iny
sta $4bbf
cpy #20
bne :-
lda src_row_HI+64
sta ptr1+1
lda src_row_LO+64
sta ptr1
ldy #0
lda dest_row_HI+64
sta ptr2+1
lda dest_row_LO+64
sta ptr2
:
lda (ptr1),y
iny
sta $4c58
cpy #20
bne :-
lda src_row_HI+65
sta ptr1+1
lda src_row_LO+65
sta ptr1
ldy #0
lda dest_row_HI+65
sta ptr2+1
lda dest_row_LO+65
sta ptr2
:
lda (ptr1),y
iny
sta $4c59
cpy #20
bne :-
lda src_row_HI+66
sta ptr1+1
lda src_row_LO+66
sta ptr1
ldy #0
lda dest_row_HI+66
sta ptr2+1
lda dest_row_LO+66
sta ptr2
:
lda (ptr1),y
iny
sta $4c5a
cpy #20
bne :-
lda src_row_HI+67
sta ptr1+1
lda src_row_LO+67
sta ptr1
ldy #0
lda dest_row_HI+67
sta ptr2+1
lda dest_row_LO+67
sta ptr2
:
lda (ptr1),y
iny
sta $4c5b
cpy #20
bne :-
lda src_row_HI+68
sta ptr1+1
lda src_row_LO+68
sta ptr1
ldy #0
lda dest_row_HI+68
sta ptr2+1
lda dest_row_LO+68
sta ptr2
:
lda (ptr1),y
iny
sta $4c5c
cpy #20
bne :-
lda src_row_HI+69
sta ptr1+1
lda src_row_LO+69
sta ptr1
ldy #0
lda dest_row_HI+69
sta ptr2+1
lda dest_row_LO+69
sta ptr2
:
lda (ptr1),y
iny
sta $4c5d
cpy #20
bne :-
lda src_row_HI+70
sta ptr1+1
lda src_row_LO+70
sta ptr1
ldy #0
lda dest_row_HI+70
sta ptr2+1
lda dest_row_LO+70
sta ptr2
:
lda (ptr1),y
iny
sta $4c5e
cpy #20
bne :-
lda src_row_HI+71
sta ptr1+1
lda src_row_LO+71
sta ptr1
ldy #0
lda dest_row_HI+71
sta ptr2+1
lda dest_row_LO+71
sta ptr2
:
lda (ptr1),y
iny
sta $4c5f
cpy #20
bne :-
lda src_row_HI+72
sta ptr1+1
lda src_row_LO+72
sta ptr1
ldy #0
lda dest_row_HI+72
sta ptr2+1
lda dest_row_LO+72
sta ptr2
:
lda (ptr1),y
iny
sta $4cf8
cpy #20
bne :-
lda src_row_HI+73
sta ptr1+1
lda src_row_LO+73
sta ptr1
ldy #0
lda dest_row_HI+73
sta ptr2+1
lda dest_row_LO+73
sta ptr2
:
lda (ptr1),y
iny
sta $4cf9
cpy #20
bne :-
lda src_row_HI+74
sta ptr1+1
lda src_row_LO+74
sta ptr1
ldy #0
lda dest_row_HI+74
sta ptr2+1
lda dest_row_LO+74
sta ptr2
:
lda (ptr1),y
iny
sta $4cfa
cpy #20
bne :-
lda src_row_HI+75
sta ptr1+1
lda src_row_LO+75
sta ptr1
ldy #0
lda dest_row_HI+75
sta ptr2+1
lda dest_row_LO+75
sta ptr2
:
lda (ptr1),y
iny
sta $4cfb
cpy #20
bne :-
lda src_row_HI+76
sta ptr1+1
lda src_row_LO+76
sta ptr1
ldy #0
lda dest_row_HI+76
sta ptr2+1
lda dest_row_LO+76
sta ptr2
:
lda (ptr1),y
iny
sta $4cfc
cpy #20
bne :-
lda src_row_HI+77
sta ptr1+1
lda src_row_LO+77
sta ptr1
ldy #0
lda dest_row_HI+77
sta ptr2+1
lda dest_row_LO+77
sta ptr2
:
lda (ptr1),y
iny
sta $4cfd
cpy #20
bne :-
lda src_row_HI+78
sta ptr1+1
lda src_row_LO+78
sta ptr1
ldy #0
lda dest_row_HI+78
sta ptr2+1
lda dest_row_LO+78
sta ptr2
:
lda (ptr1),y
iny
sta $4cfe
cpy #20
bne :-
lda src_row_HI+79
sta ptr1+1
lda src_row_LO+79
sta ptr1
ldy #0
lda dest_row_HI+79
sta ptr2+1
lda dest_row_LO+79
sta ptr2
:
lda (ptr1),y
iny
sta $4cff
cpy #20
bne :-
lda src_row_HI+80
sta ptr1+1
lda src_row_LO+80
sta ptr1
ldy #0
lda dest_row_HI+80
sta ptr2+1
lda dest_row_LO+80
sta ptr2
:
lda (ptr1),y
iny
sta $4d98
cpy #20
bne :-
lda src_row_HI+81
sta ptr1+1
lda src_row_LO+81
sta ptr1
ldy #0
lda dest_row_HI+81
sta ptr2+1
lda dest_row_LO+81
sta ptr2
:
lda (ptr1),y
iny
sta $4d99
cpy #20
bne :-
lda src_row_HI+82
sta ptr1+1
lda src_row_LO+82
sta ptr1
ldy #0
lda dest_row_HI+82
sta ptr2+1
lda dest_row_LO+82
sta ptr2
:
lda (ptr1),y
iny
sta $4d9a
cpy #20
bne :-
lda src_row_HI+83
sta ptr1+1
lda src_row_LO+83
sta ptr1
ldy #0
lda dest_row_HI+83
sta ptr2+1
lda dest_row_LO+83
sta ptr2
:
lda (ptr1),y
iny
sta $4d9b
cpy #20
bne :-
lda src_row_HI+84
sta ptr1+1
lda src_row_LO+84
sta ptr1
ldy #0
lda dest_row_HI+84
sta ptr2+1
lda dest_row_LO+84
sta ptr2
:
lda (ptr1),y
iny
sta $4d9c
cpy #20
bne :-
lda src_row_HI+85
sta ptr1+1
lda src_row_LO+85
sta ptr1
ldy #0
lda dest_row_HI+85
sta ptr2+1
lda dest_row_LO+85
sta ptr2
:
lda (ptr1),y
iny
sta $4d9d
cpy #20
bne :-
lda src_row_HI+86
sta ptr1+1
lda src_row_LO+86
sta ptr1
ldy #0
lda dest_row_HI+86
sta ptr2+1
lda dest_row_LO+86
sta ptr2
:
lda (ptr1),y
iny
sta $4d9e
cpy #20
bne :-
lda src_row_HI+87
sta ptr1+1
lda src_row_LO+87
sta ptr1
ldy #0
lda dest_row_HI+87
sta ptr2+1
lda dest_row_LO+87
sta ptr2
:
lda (ptr1),y
iny
sta $4d9f
cpy #20
bne :-
lda src_row_HI+88
sta ptr1+1
lda src_row_LO+88
sta ptr1
ldy #0
lda dest_row_HI+88
sta ptr2+1
lda dest_row_LO+88
sta ptr2
:
lda (ptr1),y
iny
sta $4e38
cpy #20
bne :-
lda src_row_HI+89
sta ptr1+1
lda src_row_LO+89
sta ptr1
ldy #0
lda dest_row_HI+89
sta ptr2+1
lda dest_row_LO+89
sta ptr2
:
lda (ptr1),y
iny
sta $4e39
cpy #20
bne :-
lda src_row_HI+90
sta ptr1+1
lda src_row_LO+90
sta ptr1
ldy #0
lda dest_row_HI+90
sta ptr2+1
lda dest_row_LO+90
sta ptr2
:
lda (ptr1),y
iny
sta $4e3a
cpy #20
bne :-
lda src_row_HI+91
sta ptr1+1
lda src_row_LO+91
sta ptr1
ldy #0
lda dest_row_HI+91
sta ptr2+1
lda dest_row_LO+91
sta ptr2
:
lda (ptr1),y
iny
sta $4e3b
cpy #20
bne :-
lda src_row_HI+92
sta ptr1+1
lda src_row_LO+92
sta ptr1
ldy #0
lda dest_row_HI+92
sta ptr2+1
lda dest_row_LO+92
sta ptr2
:
lda (ptr1),y
iny
sta $4e3c
cpy #20
bne :-
lda src_row_HI+93
sta ptr1+1
lda src_row_LO+93
sta ptr1
ldy #0
lda dest_row_HI+93
sta ptr2+1
lda dest_row_LO+93
sta ptr2
:
lda (ptr1),y
iny
sta $4e3d
cpy #20
bne :-
lda src_row_HI+94
sta ptr1+1
lda src_row_LO+94
sta ptr1
ldy #0
lda dest_row_HI+94
sta ptr2+1
lda dest_row_LO+94
sta ptr2
:
lda (ptr1),y
iny
sta $4e3e
cpy #20
bne :-
lda src_row_HI+95
sta ptr1+1
lda src_row_LO+95
sta ptr1
ldy #0
lda dest_row_HI+95
sta ptr2+1
lda dest_row_LO+95
sta ptr2
:
lda (ptr1),y
iny
sta $4e3f
cpy #20
bne :-
