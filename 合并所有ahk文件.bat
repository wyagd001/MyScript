@echo off
dir /a-d/s/b *.ahk >>new.temp
for /f "delims=" %%a in ('dir /a-d/s/b *.ahk') do (
(
echo,&echo %%~a
echo,
type "%%~a"&echo,
)>>new.temp)
ren new.temp new.txt
pause