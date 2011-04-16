# Microsoft Developer Studio Project File - Name="C64MusicEditor" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=C64MusicEditor - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "C64MusicEditor.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "C64MusicEditor.mak" CFG="C64MusicEditor - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "C64MusicEditor - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "C64MusicEditor"
# PROP Scc_LocalPath "."
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f C64MusicEditor.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "C64MusicEditor.exe"
# PROP BASE Bsc_Name "C64MusicEditor.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "..\acme.exe -v3 --msvc MusicEditor.a"
# PROP Rebuild_Opt ""
# PROP Target_File "MusicEditor.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""
# Begin Target

# Name "C64MusicEditor - Win32 Release"

!IF  "$(CFG)" == "C64MusicEditor - Win32 Release"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "ToolsEtc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\ScreenEdit.a
# End Source File
# End Group
# Begin Source File

SOURCE=.\BlockEdit.a
# End Source File
# Begin Source File

SOURCE=.\Directory.a
# End Source File
# Begin Source File

SOURCE=.\GetKey.a
# End Source File
# Begin Source File

SOURCE=.\MainScreen.a
# End Source File
# Begin Source File

SOURCE=.\MusicEditor.a
# End Source File
# Begin Source File

SOURCE=.\MusicPlayer.a
# End Source File
# Begin Source File

SOURCE=.\MusicPlayerIRQ.a
# End Source File
# Begin Source File

SOURCE=.\RelocateMusic.a
# End Source File
# Begin Source File

SOURCE=.\Storage.a
# End Source File
# Begin Source File

SOURCE=.\TrackEdit.a
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\stdlib\BASICEntry900.a
# End Source File
# Begin Source File

SOURCE=..\stdlib\Initialise.a
# End Source File
# Begin Source File

SOURCE=..\stdlib\stdlib.a
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\114MUSDATA.bin
# End Source File
# Begin Source File

SOURCE=.\MusicFiles.d64
# End Source File
# Begin Source File

SOURCE=.\SCREEN1.bin
# End Source File
# Begin Source File

SOURCE=.\SCREEN2.bin
# End Source File
# Begin Source File

SOURCE=.\SCREEN3.bin
# End Source File
# Begin Source File

SOURCE=.\SCREEN4.bin
# End Source File
# Begin Source File

SOURCE=.\SCREEN5.bin
# End Source File
# End Group
# Begin Source File

SOURCE=..\CleanProject.bat
# End Source File
# Begin Source File

SOURCE=..\CleanProjectFully.bat
# End Source File
# Begin Source File

SOURCE=..\CleanProjectFullyWithAttrib.bat
# End Source File
# Begin Source File

SOURCE=..\DoBackup.bat
# End Source File
# End Target
# End Project
