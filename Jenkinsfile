pipeline {
    environment { 
        imageName = "miniserver" 
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
                     'curl -s -o /dev/null -I -w "%{http_code}" http://localhost:8080/'
                }
              }
           }
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( registryUrl, registryCredential ) { 
                        dockerImage = docker.build imageName + ":$BUILD_NUMBER" 
                        dockerImage.push('latest') 
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