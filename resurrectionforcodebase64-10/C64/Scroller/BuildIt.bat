@echo off
del Scroller.prg
..\acme.exe -v3 --msvc ScrollEntry.a
if not exist Scroller.prg goto error
..\bin\LZMPi.exe -c64b Scroller.prg Scroller.prg 1024 >t.txt
if not exist Scroller.prg goto error
goto end
:error
echo Scroller.prg not created!
:end
