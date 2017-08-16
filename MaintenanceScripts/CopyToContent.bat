@echo off
setlocal 

REM Set SOURCE to the location where the new content files are located.  E.g. \\SERVERNAME\SHARE\OCPL\OCE_CBIIT_Prodchange\Content
set SOURCE=YOU MUST SET THIS TO THE FILE SOURCE AND REMOVE THE NEXT LINE
goto usage

REM Target location. Always E:\Content
set DEST=E:\Content

REM List of sites
set SITE_LIST=CancerGov TCGA DCEG

REM Preview and Live
set SUB_SITES=Preview Live
for %%a in (%SITE_LIST%) do ( 
	for %%b in (%SUB_SITES%) do (
		C:\Windows\System32\robocopy "%SOURCE%\PercussionSites\CDESites\%%a\%%b\PublishedContent" "%DEST%\PercussionSites\CDESites\%%a\%%b\PublishedContent" /copy:DAT /DCOPY:T /MIR
	)
)

goto end
:USAGE

echo.
echo ERROR
echo.
echo Before use, you must set the SOURCE variable on line 5 and remove line 6.
echo.

:END
pause