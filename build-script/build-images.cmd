
@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem SecureTrust Bank - Docker Image Build Script
rem Parallel builds, sequential builds and Docker Hub push.
rem ============================================================

rem ---------------- CONFIGURATION -----------------------------

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fI"

set "DOCKER_NAMESPACE=azeem650"
set "IMAGE_TAG=v2"

set "SERVICES=configserver eurekaserver accounts loans cards"

set "PARALLEL=0"
set "PUSH=0"
set "ARGS="

rem Maximum worker wait time: 60 minutes
set "MAX_WAIT=1800"
set "WAIT_COUNT=0"

rem ------------------------------------------------------------
rem Parse arguments
rem ------------------------------------------------------------

for %%A in (%*) do (
    if /I "%%A"=="-p" (
        set "PARALLEL=1"
    ) else if /I "%%A"=="--parallel" (
        set "PARALLEL=1"
    ) else if /I "%%A"=="--push" (
        set "PUSH=1"
    ) else (
        set "ARGS=!ARGS! %%A"
    )
)

if not "!ARGS!"=="" (
    set "SERVICES=!ARGS!"
)

set "ACTION=built"
if "!PUSH!"=="1" set "ACTION=built and pushed"

echo.
echo ============================================================
echo SecureTrust Bank - Docker Image Builder
echo ============================================================
echo Project root : %PROJECT_ROOT%
echo Docker Hub   : %DOCKER_NAMESPACE%
echo Image tag    : %IMAGE_TAG%
echo Services     : %SERVICES%
echo Parallel     : %PARALLEL%
echo Push         : %PUSH%
echo ============================================================
echo.

rem ------------------------------------------------------------
rem Validate configuration and service directories
rem ------------------------------------------------------------

if not defined IMAGE_TAG (
    echo ERROR: IMAGE_TAG is not configured.
    exit /b 1
)

if not defined DOCKER_NAMESPACE (
    echo ERROR: DOCKER_NAMESPACE is not configured.
    exit /b 1
)

for %%S in (%SERVICES%) do (
    if not exist "%PROJECT_ROOT%\%%S\pom.xml" (
        echo ERROR: POM not found for service %%S
        exit /b 1
    )
)

rem ------------------------------------------------------------
rem Start build
rem ------------------------------------------------------------

if "!PARALLEL!"=="1" (
    call :build_parallel
) else (
    call :build_sequential
)

exit /b !errorlevel!


rem ============================================================
rem IMAGE REFERENCE
rem ============================================================

:image_ref

set "IMAGE_REF=%DOCKER_NAMESPACE%/%~1:%IMAGE_TAG%"

exit /b 0


rem ============================================================
rem SEQUENTIAL BUILD
rem ============================================================

:build_sequential

set "FAILED="

for %%S in (%SERVICES%) do (

    echo.
    echo ============================================================
    echo Building image for %%S
    echo ============================================================

    pushd "%PROJECT_ROOT%\%%S"

    if errorlevel 1 (
        echo ERROR: Cannot access %%S directory.
        set "FAILED=!FAILED! %%S"
        exit /b 1
    )

    call mvn compile jib:dockerBuild

    if errorlevel 1 (
        popd
        echo ERROR: Build failed for %%S
        exit /b 1
    )

    popd

    if "!PUSH!"=="1" (

        call :image_ref %%S

        echo.
        echo Pushing image: !IMAGE_REF!

        docker push "!IMAGE_REF!"

        if errorlevel 1 (
            echo ERROR: Docker push failed for %%S
            exit /b 1
        )
    )

    echo [OK] %%S
)

call :success_summary
exit /b 0


rem ============================================================
rem PARALLEL BUILD
rem ============================================================

:build_parallel

set "LOG_DIR=%SCRIPT_DIR%.build-logs"

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)

if not exist "%LOG_DIR%" (
    echo ERROR: Could not create log directory.
    exit /b 1
)

rem ------------------------------------------------------------
rem Remove old completion markers and worker files
rem ------------------------------------------------------------

for %%S in (%SERVICES%) do (
    if exist "%LOG_DIR%\%%S.done" del /q "%LOG_DIR%\%%S.done"
    if exist "%LOG_DIR%\%%S.done.tmp" del /q "%LOG_DIR%\%%S.done.tmp"
    if exist "%LOG_DIR%\%%S.worker.cmd" del /q "%LOG_DIR%\%%S.worker.cmd"
)

rem ------------------------------------------------------------
rem Generate and launch workers
rem ------------------------------------------------------------

for %%S in (%SERVICES%) do (

    set "WORKER_IMAGE=%DOCKER_NAMESPACE%/%%S:%IMAGE_TAG%"

    if "!PUSH!"=="1" (

        > "%LOG_DIR%\%%S.worker.cmd" (
            echo @echo off
            echo cd /d "%PROJECT_ROOT%\%%S"
            echo if errorlevel 1 goto build_failed
            echo call mvn compile jib:dockerBuild ^> "%LOG_DIR%\%%S.log" 2^>^&1
            echo if errorlevel 1 goto build_failed
            echo docker push "!WORKER_IMAGE!" ^>^> "%LOG_DIR%\%%S.log" 2^>^&1
            echo if errorlevel 1 goto push_failed
            echo echo 0 ^> "%LOG_DIR%\%%S.done.tmp"
            echo move /y "%LOG_DIR%\%%S.done.tmp" "%LOG_DIR%\%%S.done" ^>nul
            echo exit /b 0
            echo.
            echo :build_failed
            echo echo 1 ^> "%LOG_DIR%\%%S.done.tmp"
            echo move /y "%LOG_DIR%\%%S.done.tmp" "%LOG_DIR%\%%S.done" ^>nul
            echo exit /b 1
            echo.
            echo :push_failed
            echo echo 1 ^> "%LOG_DIR%\%%S.done.tmp"
            echo move /y "%LOG_DIR%\%%S.done.tmp" "%LOG_DIR%\%%S.done" ^>nul
            echo exit /b 1
        )

    ) else (

        > "%LOG_DIR%\%%S.worker.cmd" (
            echo @echo off
            echo cd /d "%PROJECT_ROOT%\%%S"
            echo if errorlevel 1 goto build_failed
            echo call mvn compile jib:dockerBuild ^> "%LOG_DIR%\%%S.log" 2^>^&1
            echo if errorlevel 1 goto build_failed
            echo echo 0 ^> "%LOG_DIR%\%%S.done.tmp"
            echo move /y "%LOG_DIR%\%%S.done.tmp" "%LOG_DIR%\%%S.done" ^>nul
            echo exit /b 0
            echo.
            echo :build_failed
            echo echo 1 ^> "%LOG_DIR%\%%S.done.tmp"
            echo move /y "%LOG_DIR%\%%S.done.tmp" "%LOG_DIR%\%%S.done" ^>nul
            echo exit /b 1
        )
    )

    if not exist "%LOG_DIR%\%%S.worker.cmd" (
        echo ERROR: Could not generate worker for %%S
        exit /b 1
    )

    echo.
    echo Starting build for %%S
    echo Image: !WORKER_IMAGE!
    echo Log: .build-logs\%%S.log

    set "WORKER=%LOG_DIR%\%%S.worker.cmd"

    start "build-%%S" /B "%ComSpec%" /D /C ""!WORKER!""

    if errorlevel 1 (
        echo ERROR: Could not start worker for %%S
        exit /b 1
    )
)

rem ------------------------------------------------------------
rem Wait for workers to finish
rem ------------------------------------------------------------

:waitloop

set "PENDING=0"

for %%S in (%SERVICES%) do (
    if not exist "%LOG_DIR%\%%S.done" (
        set "PENDING=1"
    )
)

if "!PENDING!"=="1" (

    set /a WAIT_COUNT+=1

    if !WAIT_COUNT! GEQ %MAX_WAIT% (
        echo.
        echo ERROR: Worker timeout after 60 minutes.
        echo Check logs in:
        echo "%LOG_DIR%"
        exit /b 1
    )

    timeout /t 2 /nobreak >nul
    goto waitloop
)

rem ------------------------------------------------------------
rem Check worker results
rem ------------------------------------------------------------

set "FAILED="
set "SUCCEEDED="

for %%S in (%SERVICES%) do (

    set "RESULT="

    if exist "%LOG_DIR%\%%S.done" (

        for /f "usebackq delims=" %%R in ("%LOG_DIR%\%%S.done") do (
            set "RESULT=%%R"
        )

    )

    if "!RESULT!"=="0" (
        set "SUCCEEDED=!SUCCEEDED! %%S"
    ) else (
        set "FAILED=!FAILED! %%S"
    )
)

rem ------------------------------------------------------------
rem Display final result
rem ------------------------------------------------------------

if defined FAILED (

    echo.
    echo ============================================================
    echo                    BUILD FAILED
    echo ============================================================
    echo.
    echo Successful services:!SUCCEEDED!
    echo Failed services:!FAILED!
    echo.
    echo Check individual logs:
    echo "%LOG_DIR%"
    echo.

    exit /b 1
)

call :success_summary
exit /b 0


rem ============================================================
rem SUCCESS SUMMARY
rem ============================================================

:success_summary

echo.
echo ============================================================
echo       ALL IMAGE OPERATIONS COMPLETED SUCCESSFULLY
echo ============================================================
echo.

for %%S in (%SERVICES%) do (
    echo [OK] %%S
)

echo.
echo Docker namespace : %DOCKER_NAMESPACE%
echo Image tag        : %IMAGE_TAG%

if "%PARALLEL%"=="1" (
    echo Build mode       : Parallel
) else (
    echo Build mode       : Sequential
)

if "%PUSH%"=="1" (
    echo Push status      : Completed
) else (
    echo Push status      : Skipped
)

echo.
echo BUILD SUCCESS
echo.

exit /b 0
