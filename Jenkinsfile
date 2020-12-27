pipeline {
    environment { 
        imageName = "sec911/miniserver" 
        registryCredential = 'docker-credentials' 
        dockerImage = ''
    }
    agent { dockerfile true }
    stages { 
        stage('Building') { 
            steps { 
                script { 
                    dockerImage = docker.build imageName + ":$BUILD_NUMBER" 
                }
            } 
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( '', registryCredential ) { 
                        dockerImage.push() 
                    }
                } 
            }
        } 
        stage('Testing the build') {
           steps {   
               script {
                  dockerImage.inside() {
                     curl -s -o /dev/null -I -w \"%{http_code}\" http://localhost:8080/
                }
              }
           }
        }
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $imageName:$BUILD_NUMBER" 
            }
        } 
    }
}
