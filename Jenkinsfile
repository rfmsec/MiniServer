pipeline {
    environment { 
        imageName = "sec911/miniserver" 
        registryCredential = 'docker-credentials' 
        dockerImage = ''
    }
    agent { dockerfile true }
    stages { 
        stage('Cloning MiniServer repo') { 
            steps { 
                git 'https://github.com/rfmsec/MiniServer.git' 
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
                  dockerImage.inside {
                     sh curl -s -o /dev/null -I -w "%{http_code}" http://localhost:8080/
                }
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
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        } 
    }
}
