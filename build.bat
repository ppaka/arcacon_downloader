@ECHO OFF
CD /d %~dp0
REM WIP

SET /P mode=Build All Platforms(1), Only Windows(2), Only Android(3) : 

IF "%mode%"=="1" GOTO BuildAll
IF "%mode%"=="2" GOTO Windows
IF "%mode%"=="3" GOTO Android

pause > nul

:BuildAll
GOTO Windows
GOTO Android

:Windows
flutter build windows
start "" "%~dp0build\windows\x64\runner\Release"

:Android
flutter build appbundle
start "" "%~dp0build\app\outputs\bundle\release"
