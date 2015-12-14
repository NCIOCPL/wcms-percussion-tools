@echo off
setLocal
rem Build up the source location from the current execution path and
rem an assumed DATA subdirectory.
set filepath=%~dp0DATA
powershell -ExecutionPolicy RemoteSigned ./cdeDeploy.ps1 %filepath%
pause