cd ..
del TTTTC64.zip
rmdir /S /Q TTTTC64
mkdir TTTTC64
xcopy C64\*.* TTTTC64\C64\ /S /E
cd TTTTC64
cd C64
call CleanProjectFullyWithAttrib.bat
