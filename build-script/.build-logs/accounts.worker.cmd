@echo off
cd /d "D:\Microservices\SecureTrust Bank\accounts"
if errorlevel 1 goto build_failed
call mvn compile jib:dockerBuild > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\accounts.log" 2>&1
if errorlevel 1 goto build_failed
docker push "azeem650/accounts:v2" >> "D:\Microservices\SecureTrust Bank\build-script\.build-logs\accounts.log" 2>&1
if errorlevel 1 goto push_failed
echo 0 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\accounts.done"
exit /b 0

:build_failed
echo 1 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\accounts.done"
exit /b 1

:push_failed
echo 1 > "D:\Microservices\SecureTrust Bank\build-script\.build-logs\accounts.done"
exit /b 1
