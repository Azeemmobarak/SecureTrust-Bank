@echo off
cd /d "D:\Microservices\SecureTrust Bank\configserver"
if errorlevel 1 goto build_failed
call mvn compile jib:dockerBuild > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.log" 2>&1
if errorlevel 1 goto build_failed
echo 0 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done.tmp"
move /y "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done.tmp" "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done" >nul
exit /b 0

:build_failed
echo 1 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done.tmp"
move /y "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done.tmp" "D:\Microservices\SecureTrust Bank\build-script\.build-logs\configserver.done" >nul
exit /b 1
