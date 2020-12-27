pipeline {
    environment { 
        imageName = "miniserver" 
        dockerImage = ''
    }
    agent { dockerfile true }
    stages { 
        stage('Artifactory configuration') {
            steps {
                rtServer (
                    id: 'Artifactory-1',
                    url: 'http://192.168.99.100:30802/artifactory',
                    username: 'tomer',
                    password: 'Aa123456'
                )
            }
        }
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
                echo PATH Variable is: $PATH
                rtDockerPush(
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
