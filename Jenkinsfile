pipeline {
    environment { 
        imageName = "sec911/miniserver" 
        registryCredential = 'docker-credentials' 
        dockerImage = ''
    }
    stages { 
        stage('Building') { 
            steps { 
                script { 
                    dockerfile = 'Dockerfile'
                    dockerImage = docker.build('192.168.99.100:30802/artifactory/miniserver-virtual/' + imageName + ":$BUILD_NUMBER", "-f ${dockerfile} .") 
                }
            } 
        }
        stage('Testing the build') {
           steps {   
               script {
                  dockerImage.inside() {
                     'curl -s -o /dev/null -I -w "%{http_code}" http://localhost:8080/'
                }
              }
           }
        }
        stage('Deploy our image') { 
            steps { 
                rtServer (
                    id: 'Artifactory-1',
                    url: 'http://192.168.99.100:30802/artifactory',
                    credentialsId: 'my-credentials-id',
                )
                
                rtDockerPush(
                    serverId: "Artifactory-1"
                    image: "192.168.99.100:30802/miniserver-virtual/" + imageName + ":$BUILD_NUMBER"
                    targetRepo: 'miniserver'
                ) 
            }
        } 
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $imageName:$BUILD_NUMBER" 
            }
        } 
    }
}
