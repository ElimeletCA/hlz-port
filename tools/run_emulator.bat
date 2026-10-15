@echo off
REM Launcher para ejecutar Heroes Lore Zero en FreeJ2ME-Plus con resolucion 360x640 y codificacion correcta
set JAR_PATH=%~dp0..\input\Heroes Lore Zero 360x640 Spanish.jar
set EMU_PATH=%~dp0freej2me-plus\freej2me_plus.jar

echo Iniciando Heroes Lore: Zero en FreeJ2ME-Plus (360x640)...
java -Dfile.encoding=ISO_8859_1 -jar "%EMU_PATH%" "%JAR_PATH%" 360 640
