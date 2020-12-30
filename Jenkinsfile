pipeline {
    environment { 
        imageName = "miniserver/miniserver" 
        registryCredential = 'tomer'
        registryUrl = 'http://192.168.99.100:30802/miniserver/'
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
                   sh 'docker run --rm ' + imageName + ":$BUILD_NUMBER"
                   sh 'docker ps'
                   sh 'docker exec ' + imageName + ":$BUILD_NUMBER" + ' curl http://localhost:8080/'
              }
           }
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( registryUrl, registryCredential ) { 
                        dockerImage.push() 
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