@echo off
chcp 65001 >nul
cd /d "C:\Users\ASUS\Downloads\QLDACNTT"
echo ================================================================ >> "C:\Users\ASUS\Downloads\QLDACNTT\tools\auto_publish_history.log"
echo [RUN] %DATE% %TIME% >> "C:\Users\ASUS\Downloads\QLDACNTT\tools\auto_publish_history.log"
"C:\Program Files\nodejs\node.exe" "C:\Users\ASUS\Downloads\QLDACNTT\tools\auto_publish_social.mjs" --next >> "C:\Users\ASUS\Downloads\QLDACNTT\tools\auto_publish_history.log" 2>&1
echo [DONE] %DATE% %TIME% >> "C:\Users\ASUS\Downloads\QLDACNTT\tools\auto_publish_history.log"

