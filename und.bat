@echo off
setlocal

set ORIGINAL=%CD%
cd %~dp0

@lua cli/und.lua %ORIGINAL% %*

endlocal