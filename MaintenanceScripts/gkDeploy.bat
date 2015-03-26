@echo off
powershell -ExecutionPolicy RemoteSigned ./gkDeploy.ps1 %1
pause