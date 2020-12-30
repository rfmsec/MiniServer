pipeline {
    environment { 
        imageName = "miniserver/miniserver" 
        registryCredential = 'tomer'
        registryUrl = 'http://192.168.99.100:30802/miniserver/'
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
        stage('Testing the build') {
           steps {   
               script {
                  dockerImage.inside() {
                     sh 'if [[ \'curl -s -o /dev/null -I -w "%{http_code}" http://localhost:8080/\' == 000 ]]; then return 1; else return 0; fi'
                }
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