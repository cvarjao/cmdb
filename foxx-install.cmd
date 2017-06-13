@REM https://github.com/arangodb/arangodb/issues/772
@echo off
@setlocal 
cd %~dp0\services\cvarjao-cmdb
zip -r ..\cvarjao-cmdb.zip .
@endlocal 

FOR /F "tokens=* USEBACKQ" %%F IN (`docker-machine ip default`) DO (
SET SERVICE_IP=%%F
)
SET "ARANGODB_URL=http://%SERVICE_IP%:8529"

ECHO %SERVICE_IP%

call curl -s -u root:r00t -X POST "%ARANGODB_URL%/_db/_system/_api/upload" -H "Content-Type: application/x-zip-compressed" --data-binary "@%~dp0\services\cvarjao-cmdb.zip" -o "%~dp0\services\cvarjao-cmdb.upload.out"
type "%~dp0\services\cvarjao-cmdb.upload.out" | call jq --compact-output ". | {zipFile:.filename}" > "%~dp0\services\cvarjao-cmdb.service.input"
type "%~dp0\services\cvarjao-cmdb.service.input" | curl -s -u root:r00t -X PUT "%ARANGODB_URL%/_db/_system/_admin/aardvark/foxxes/zip?mount=%%2Fcmdb&upgrade=true" -H "Pragma: no-cache" -H "Accept-Encoding: gzip, deflate, sdch" -H "Content-Type: application/json" -H "Accept: */*" -d "@-" --compressed
