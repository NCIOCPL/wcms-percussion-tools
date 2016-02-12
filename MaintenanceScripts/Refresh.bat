@Echo off
REM Sanity Check - Does the old folder exist?
if not exist E:\Rhythmyx (
  echo Cannot locate folder E:\Rhythmyx -- Aborting.
  goto exit
)
echo Found E:\Rhythmyx


REM Sanity Check - Does the replacement folder exist?
if not exist E:\Rhythmyx.new (
  echo Cannot locate folder E:\Rhythmyx.new -- Aborting.
  goto exit
)
echo Found E:\Rhythmyx.new


REM Sanity Check - Do the server-specific files exist?
if not exist E:\Deployments\preserved-files\rx-ds.xml (
  echo Cannot locate E:\Deployments\preserved-files\rx-ds.xml -- Aborting.
  goto exit
)
if not exist E:\Deployments\preserved-files\syndication-delivery-handler-0.4.0.jar (
  echo Cannot locate E:\Deployments\preserved-files\syndication-delivery-handler-0.4.0.jar -- Aborting.
  goto exit
)
echo Found server-specific backup files.



echo Refreshing.
echo .
echo .


REM Delete the old backup
echo Remove E:\Rhythmyx.bak
rd E:\Rhythmyx.bak /s/q

REM Backup the structure
echo .
echo .
echo Renaming E:\Rhythmyx to E:\Rhythmyx.bak
ren E:\Rhythmyx Rhythmyx.bak

REM Rename the new structure
echo .
echo .
echo Renaming E:\Rhythmyx to E:\Rhythmyx.bak
ren E:\Rhythmyx.new Rhythmyx

REM Restore connection file and syndication code.
echo .
echo .
echo Restoring connection file and syndication code.
@echo on
copy E:\Deployments\preserved-files\rx-ds.xml		E:\Rhythmyx\AppServer\server\rx\deploy\*.*
copy E:\Deployments\preserved-files\syndication-delivery-handler-0.4.0.jar		E:\Rhythmyx\AppServer\server\rx\deploy\rxapp.ear\rxapp.war\WEB-INF\lib\*.*

@echo off
echo Success

:exit
pause