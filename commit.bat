rem @echo off
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
rem add all to stage
git add *
rem commit to stage
git commit -m "Automated Sync %mydate%"
rem Push them up to the repo
git push -u origin master