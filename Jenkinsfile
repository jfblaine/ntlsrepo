pipeline {
  agent {
      label 'base'
  }
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    } //options
    environment {
        CICD_DEV    = "jblaine"
        APP_NAME    = "ntlsrepo"
        GIT_REPO    = "ssh://git@github.com/jfblaine/ruby-ex.git"
    }
    stages {
         stage('Push image to Artifactory') {
           steps {
             withDockerRegistry([credentialsId: "0655008f-aa54-4a16-9484-421b55390dbb", url: "docker-registry.default.svc:5000"]) {
     
               withDockerRegistry([credentialsId: "4ca833b5-a2a6-4500-9a31-c241ff35e680", url: "aio.home.io:5000"]) {
                 sh """
                     oc image mirror --insecure=true docker-registry.default.svc:5000/jblaine/ntlsrepo:latest aio.home.io:5000/ntlsrepo/ntlsrepo-test:latest 
                    """     
                 }
               }
             } // steps
         } // stage
    } // stages
} // pipeline
