; This starts at $0801 so that doing a LOAD"*",8 will still work with the default $0801 BASIC start address.
*= BASICSTART
.byte $0c,$08,$0a,$00,$9e		; Line 10 SYS
scrcode "2304"					; Address for sys start in text
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00			; And a few more zeros for the sake of paranoia and safety.

BASICEntry = $900
