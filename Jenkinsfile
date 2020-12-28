pipeline {
    environment { 
        imageName = "MiniServer" 

        dockerImage = ''
    }
    agent any
    stages { 
        stage('Building') { 
            steps { 
                script { 
                    dockerImage = docker.build imageName + ":$BUILD_NUMBER"
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
                dockerImage.withRegistry("http://192.168.99.100:30802/"
                    serverId: "Artifactory-1",
                    image: "192.168.99.100:30802/miniserver-virtual/" + imageName + ":$BUILD_NUMBER",
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
