@echo off

REM Remove the old namespaces…
kubectl delete ns  artifactory-jcr
kubectl delete ns bloody-jenkins

REM Recreate the entire thing…
kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/artifactory-jcr.yaml
kubectl create -f https://github.com/rfmsec/MiniServer/raw/main/kubernetes_files/bloody-jenkins.yaml

REM Create variables for the pods names
for /F "tokens=1" %%i in ('kubectl get pods -n artifactory-jcr ^| findstr /i "artifactory"') do set ART_POD_NAME=%%i
for /F "tokens=1" %%i in ('kubectl get pods -n bloody-jenkins ^| findstr /i "jenkins"') do set JEN_POD_NAME=%%i

REM Wait for jfrog to finish initialization
:WaitforJfrogStart
curl http://192.168.99.100:30802/
if %ERRORLEVEL% == 7 ( timeout /t 5 && call :WaitforJfrogStart )
:WaitforJfrogInit
curl http://192.168.99.100:30802/ | grep -i "available shortly"
if %ERRORLEVEL% == 1 ( timeout /t 5 && call :WaitforJfrogInit )

REM Configure artifactory using the API
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{\"username\":\"tomer\",\"password\":\"Aa123456\",\"custom_data\" : {\"artifactory_admin\" : {\"value\" : \"true\"}}}" http://localhost:8081/artifactory/api/access/api/v1/users
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:password -XPOST -H "Content-Type: application/json" -d "{ \"userName\" : \"admin\", \"oldPassword\" : \"password\", \"newPassword1\" : \"Aa123456\", \"newPassword2\" : \"Aa123456\" }" http://localhost:8081/artifactory/api/security/users/authorization/changePassword
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl https://raw.githubusercontent.com/rfmsec/MiniServer/main/jfrog-config.yaml -o /tmp/jfrog-config.yaml
kubectl exec -n artifactory-jcr %ART_POD_NAME% -- curl -uadmin:Aa123456 -XPATCH -H "Content-Type: application/yaml" -T /tmp/jfrog-config.yaml http://localhost:8081/artifactory/api/system/configuration
