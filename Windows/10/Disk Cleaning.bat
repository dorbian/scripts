@echo off
echo Delete Journal.
fsutil usn deletejournal /d /n c:

echo Checkdisk.
chkdsk /scan

echo WMI Repository check.
winmgmt /salvagerepository

echo Deleting TEMP folder contents.
del "%temp%\*" /s /f /q

echo Deleting System TEMP Folder contents.
del "%systemroot%\temp\*" /s /f /q

echo Deleting Shadow Copies.
vssadmin delete shadows /for=c: /all /quiet

echo Cleaning setup folder and resetting base image.
Dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase

echo Launching Advanced disk cleaning.
cleanmgr /sageset:65535
cleanmgr /sagerun:65535

pause