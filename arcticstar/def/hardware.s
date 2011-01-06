; C64 colour pallette
BLACK = 0
WHITE = 1
RED = 2
CYAN = 3
PURPLE = 4
DGREEN = 5
DBLUE = 6
YELLOW = 7
ORANGE = 8
BROWN = 9
LRED = 10
DGREY = 11
GREY = 12
LGREEN = 13
LBLUE = 14
LGREY = 15

; hardware registers
CIAPRA = $dc00
CIAPRB = $dc01
CIAICR = $dc0d
CI2ICR = $dd0d
CIA2 = $dd00
SPRITEX_HI = $d010
SPRITE_POS = $d000
SPRITE_COLOUR = $d027
MULTI_COLOUR1 = $d025
MULTI_COLOUR2 = $d026
SPRITES = $d015
COLOUR_RAM = $d800
VMCSB = $d018
SCROLY = $d011
SCROLX = $d016
SPBGPR = $d01b
IRQMSK = $d01a
VICIRQ = $d019
SPSPCL = $d01e
EXTCOL = $d020
BGRCOL = $d021
RASTER = $d012

FREHI3 = $d40f
FRELO3 = $d40e
VCREG3 = $d412

FRELO2 = $d408
FREHI2 = $d407
VCREG2 = $d40B 

FRELO1 = $d400
FREHI1 = $d401
VCREG1 = $d404

SIGVOL = $d418
RANDOM = $d41b

GETIN = $ffe4