@echo off

echo Removing old namespaces...
kubectl delete ns artifactory-jcr
REM kubectl delete ns bloody-jenkins

echo Recraeting the environment using the YAML files...
kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/artifactory-jcr.yaml
REM kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/bloody-jenkins.yaml

echo Creating variables with the JFrog and Jenkins pods names...
for /F "tokens=1" %%i in ('kubectl get pods -n artifactory-jcr ^| findstr /i "artifactory"') do set ART_POD_NAME=%%i
REM for /F "tokens=1" %%i in ('kubectl get pods -n bloody-jenkins ^| findstr /i "jenkins"') do set JEN_POD_NAME=%%i

echo Waiting for jfrog to start its web services...
:WaitforJfrogStart
curl http://192.168.99.100:30802/ 2>nul
if %ERRORLEVEL% == 7 ( timeout /t 20 >nul && goto :WaitforJfrogStart )

echo Waiting for jfrog to finish initialzing before pushing the configuration...
:WaitforJfrogInit
curl http://192.168.99.100:30802/ | grep -i "available shortly"
if %ERRORLEVEL% == 0 ( timeout /t 20 >nul && goto :WaitforJfrogInit )

echo Configuring artifactory using API calls...
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -XPOST -vu admin:password http://localhost:8082/artifactory/ui/jcr/eula/accept
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{\"username\":\"tomer\",\"password\":\"Aa123456\",\"custom_data\" : {\"artifactory_admin\" : {\"value\" : \"true\"}}}" http://localhost:8081/artifactory/api/access/api/v1/users
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{ \"userName\" : \"admin\", \"oldPassword\" : \"password\", \"newPassword1\" : \"Aa123456\", \"newPassword2\" : \"Aa123456\" }" http://localhost:8081/artifactory/api/security/users/authorization/changePassword
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- wget https://raw.githubusercontent.com/rfmsec/MiniServer/main/jfrog-config.yaml -P /tmp/
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:Aa123456 -XPATCH -H "Content-Type: application/yaml" -T /tmp/jfrog-config.yaml http://localhost:8081/artifactory/api/system/configuration
