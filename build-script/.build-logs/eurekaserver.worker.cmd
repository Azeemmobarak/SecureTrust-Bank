@echo off
cd /d "D:\Microservices\SecureTrust Bank\eurekaserver"
if errorlevel 1 goto build_failed
call mvn compile jib:dockerBuild > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.log" 2>&1
if errorlevel 1 goto build_failed
echo 0 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done.tmp"
move /y "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done.tmp" "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done" >nul
exit /b 0

:build_failed
echo 1 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done.tmp"
move /y "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done.tmp" "D:\Microservices\SecureTrust Bank\build-script\.build-logs\eurekaserver.done" >nul
exit /b 1
