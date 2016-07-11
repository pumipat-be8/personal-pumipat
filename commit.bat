@echo off
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
rem add all to stage
git add *
rem commit to stage
git commit -m "Automated Sync %mydate%_%mytime%"
rem Push them up to the repo
git push -u origin master

pause