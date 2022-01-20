chcp 65001

cd /d %~dp0
call Env.bat

StartMpvWithLog.bat "%videoFile%"