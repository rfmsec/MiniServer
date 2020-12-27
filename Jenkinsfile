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
                rtDockerPush(
                    serverId: "Art01"
                    image: "192.168.99.100:30802/artifactory/miniserver-virtual/" + imageName + ":$BUILD_NUMBER"
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
