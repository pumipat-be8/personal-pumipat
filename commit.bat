@echo off
rem retrieve all changes
ant -v retrieveUnpackaged
cd retrieveUnpackaged
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
rem add all to stage
git add *
rem commit to stage
git commit -m "Automated Sync %mydate%_%mytime%"
rem Push them up to the repo
git push -u origin master

pause

rem pre-setup
rem git push that avoid username/password need to store them with wincred
rem git config --global credential.helper wincred
rem for more information:http://www.tilcode.com/push-github-without-entering-username-password-windows-git-bash/

