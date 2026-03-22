@echo off
echo Pushing rmmz-save-editor-skill to GitHub...
echo.
cd /d %~dp0
git remote remove origin 2>nul
git remote add origin git@github.com:DSeaStar/rmmz-save-editor-skill.git
git branch -M main
git push -u origin main
echo.
pause
