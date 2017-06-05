@ECHO off
setlocal

:: Debug|Release
SET CONFIGURATION=Release

:: strlen("\scripts\") => 9
SET APP_HOME=%~dp0
SET APP_HOME=%APP_HOME:~0,-9%
cd %APP_HOME%

:: Check dependencies
nuget > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO MISSING_NUGET
msbuild /version > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO MISSING_MSBUILD

:: Restore nuget packages and compile the application
call nuget restore
IF %ERRORLEVEL% NEQ 0 GOTO FAIL
call msbuild /m /p:Configuration=%CONFIGURATION%;Platform="Any CPU"
IF %ERRORLEVEL% NEQ 0 GOTO FAIL

:: Run with elevated privileges
copy .\scripts\run.vbs .\WebService\bin\%CONFIGURATION%
cd WebService\bin\%CONFIGURATION%
call cscript run.vbs "Microsoft.Azure.IoTSolutions.DeviceSimulation.WebService.exe --background"

copy .\scripts\run.vbs .\SimulationAgent\bin\%CONFIGURATION%
cd SimulationAgent\bin\%CONFIGURATION%
call cscript run.vbs "Microsoft.Azure.IoTSolutions.DeviceSimulation.SimulationAgent.exe"

:: - - - - - - - - - - - - - -
goto :END

:MISSING_NUGET
    echo ERROR: 'nuget' command not found.
    echo Install Nuget CLI and make sure the 'nuget' command is in the PATH.
    echo Nuget installation: https://docs.microsoft.com/en-us/nuget/guides/install-nuget
    exit /B 1

:MISSING_MSBUILD
    echo ERROR: 'msbuild' command not found.
    echo Install Visual Studio IDE and make sure the 'msbuild' command is in the PATH.
    echo Visual Studio installation: https://docs.microsoft.com/visualstudio/install
    echo MSBuild installation without Visual Studio: http://stackoverflow.com/questions/42696948
    exit /B 1

:FAIL
    echo Command failed
    endlocal
    exit /B 1

:END
endlocal