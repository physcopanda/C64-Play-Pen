# Microsoft Developer Studio Project File - Name="MusicPlayerTest" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=MusicPlayerTest - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "MusicPlayerTest.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "MusicPlayerTest.mak" CFG="MusicPlayerTest - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "MusicPlayerTest - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName "MusicPlayerTest"
# PROP Scc_LocalPath "."
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f MusicPlayerTest.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "MusicPlayerTest.exe"
# PROP BASE Bsc_Name "MusicPlayerTest.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "..\acme.exe -v3 --msvc MusicPlayerTest.a"
# PROP Rebuild_Opt ""
# PROP Target_File "MusicPlayerTest.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""
# Begin Target

# Name "MusicPlayerTest - Win32 Release"

!IF  "$(CFG)" == "MusicPlayerTest - Win32 Release"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\MusicPlayerTest.a
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\stdlib\BASICEntry80d.a
# End Source File
# Begin Source File

SOURCE=..\stdlib\Initialise.a
# End Source File
# Begin Source File

SOURCE=..\MusicEditor\MusicPlayer.a
# End Source File
# Begin Source File

SOURCE=..\stdlib\stdlib.a
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\TestMusic.prg
# End Source File
# Begin Source File

SOURCE=.\TestMusic2.prg
# End Source File
# Begin Source File

SOURCE=.\TestMusic3.prg
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
