cd c:\tmp

if not exist "C:\tmp\AirWatchAgent.msi" (
	powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://packages.vmware.com/wsone/AirwatchAgent.msi', 'C:\tmp\AirWatchAgent.msi')" <NUL
)

rem Check if device is already registered with Workspace ONE, if not then proceed with installing Workspace ONE Intelligent Hub

for /f "delims=" %%i in ("reg query HKLM\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts /s") do set status=%%i

if not defined status goto INSTALL

:INSTALL
    rem Run the Workspace ONE Intelligent Hub Installer to Register Device with Staging Account
    rem msiexec /i "AirwatchAgent.msi" /quiet ENROLL=Y SERVER=uem.lab.pdotk.com LGName=customerog USERNAME=pk@lab.pdotk.com PASSWORD=P@ssw0rd0 ASSIGNTOLOGGEDINUSER=Y DOWNLOADWSBUNDLE=True /log <PATH TO LOG>

    msiexec /i C:\tmp\AirWatchAgent.msi /q ENROLL=Y SERVER=uem.lab.pdotk.com LGName=customerog USERNAME=pk@lab.pdotk.com PASSWORD=P@ssw0rd0 DOWNLOADWSBUNDLE=TRUE /LOG %temp%\WorkspaceONE.log