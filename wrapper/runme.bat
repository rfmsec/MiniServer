@echo off

echo Removing old namespaces...
kubectl delete ns artifactory
kubectl delete ns jenkins

echo Recraeting the environment using the YAML files...
kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/artifactory.yaml
kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/jenkins.yaml

echo Creating variables with the JFrog and Jenkins pods names...
for /F "tokens=1" %%i in ('kubectl get pods -n artifactory ^| findstr /i "artifactory"') do set ART_POD_NAME=%%i
for /F "tokens=1" %%i in ('kubectl get pods -n jenkins ^| findstr /i "jenkins"') do set JEN_POD_NAME=%%i

echo Waiting for jfrog to start its web services...
:WaitforJfrogStart
curl http://192.168.99.100:30802/ 2>nul
if %ERRORLEVEL% == 7 ( timeout /t 20 >nul && goto :WaitforJfrogStart )

echo Waiting for jfrog to finish initialzing before pushing the configuration...
:WaitforJfrogInit
curl http://192.168.99.100:30802/ | grep -i "available shortly"
if %ERRORLEVEL% == 0 ( timeout /t 20 >nul && goto :WaitforJfrogInit )

echo Configuring artifactory webhooks...
kubectl exec -n artifactory %ART_POD_NAME% -- wget https://raw.githubusercontent.com/rfmsec/MiniServer/main/webhook.groovy -P /var/opt/jfrog/artifactory/etc/artifactory/plugins
kubectl exec -n artifactory %ART_POD_NAME% -- wget https://raw.githubusercontent.com/rfmsec/MiniServer/main/webhook.config.json -P /var/opt/jfrog/artifactory/etc/artifactory/plugins


echo Configuring artifactory using API calls...
kubectl exec -n artifactory %ART_POD_NAME% -- curl -XPOST -vu admin:password http://localhost:8082/artifactory/ui/jcr/eula/accept
kubectl exec -n artifactory %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{\"username\":\"tomer\",\"password\":\"Aa123456\",\"custom_data\" : {\"artifactory_admin\" : {\"value\" : \"true\"}}}" http://localhost:8081/artifactory/api/access/api/v1/users
kubectl exec -n artifactory %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{ \"userName\" : \"admin\", \"oldPassword\" : \"password\", \"newPassword1\" : \"Aa123456\", \"newPassword2\" : \"Aa123456\" }" http://localhost:8081/artifactory/api/security/users/authorization/changePassword
kubectl exec -n artifactory %ART_POD_NAME% -- curl -uadmin:Aa123456 -XPOST -H "Content-Type: application/json" -d "{ \"licenseKey\": \"cHJvZHVjdHM6CiAgYXJ0aWZhY3Rvcnk6CiAgICBwcm9kdWN0OiBaWGh3YVhKbGN6b2dNakF5TVMw\nd01TMHlOMVF4TWpvMU1qb3lOaTR3TWpCYUNtbGtPaUEzWXpWbU5tWmtNQzFsTlRBMkxUUmpObVF0\nT1RKbVlpMWpZek00TnpFNE5qUmxNaklLYjNkdVpYSTZJRWhQVFVVS2NISnZjR1Z5ZEdsbGN6b2dl\nMzBLYzJsbmJtRjBkWEpsT2lCdWRXeHNDblJ5YVdGc09pQjBjblZsQ25SNWNHVTZJRlJTU1VGTUNu\nWmhiR2xrUm5KdmJUb2dNakF5TUMweE1pMHlPRlF4TWpvMU1qb3lOaTR3TWpCYUNnPT0KICAgIHNp\nZ25hdHVyZTogVHhhYWNiQ290NzdEWVJjeGpxZTNlbTMwcmFJeklPaFptYnNNb0E2K2RCdWdVS3Rr\nSm54MW1zSGVKNGQyd0FDTURScERBTTkrNGlQOUdOK1ZzTEloUEpCT3JQS29taE9sYXl2TjkrZU9V\nSkVrdnJPbnFiMHBzY2VJRVo0c0ZyR1hoTmxiMW4ydG5EcExCNmJsS1Z6THNhak1zVHQxaUowcmps\nMXpteVR1cG94Q25VanpDdmxvQUFRUGFkUitZdlcxR0RaRGVFc01CT1ZPSVhDbjg0R2pGNDloT0JG\nbklwbDY1SjJUL0RvS1gxNTIwSmRWWSthRTVGeTd1S1FvaEVreG4vOGVIZG5UaXFYZkdrb0NxR0I5\nSXZWa2FNVnFaNVdRaUQ2cTBpWnJsbjNHNWVGTlZja1E4Mk5rL3J6bWdBK2JWRGxuSVJsNjJZVktj\nMldsd3luUkdBPT0KdmVyc2lvbjogMQo=\" }" http://localhost:8081/artifactory/api/system/licenses
kubectl exec -n artifactory %ART_POD_NAME% -- curl -uadmin:Aa123456 -XPUT -H "Content-Type: application/json" -d "{ \"key\": \"miniserver\", \"rclass\" : \"local\", \"packageType\": \"docker\" }" http://localhost:8081/artifactory/api/repositories/miniserver
kubectl exec -n artifactory %ART_POD_NAME% -- curl -uadmin:Aa123456 -XPOST http://localhost:8081/artifactory/api/plugins/execute/webhookReload