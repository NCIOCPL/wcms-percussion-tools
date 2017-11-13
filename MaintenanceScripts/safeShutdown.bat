@echo off
call E:\Rhythmyx\jetty\service\install-jetty-service.bat stop
echo.
echo.
echo If the RhythmyxJettyService service did not stop successfully,
echo you will need to kill the Java instance listed below:
echo.
rem Filter for java.exe using more than 1 GB of memory.
tasklist /fi "imagename eq java.exe" /fi "memusage gt 1000000"
echo.
pause