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
             withDockerRegistry([credentialsId: "0c93063a-e537-425b-ab22-4d3d46380613", url: "docker-registry.default.svc:5000"]) {
     
               withDockerRegistry([credentialsId: "9eeeb014-801b-4df1-8788-9158f6c20863", url: "aio.home.io:5000"]) {
                 sh """
                     oc image mirror --insecure=true docker-registry.default.svc:5000/jblaine/ntlsrepo:latest aio.home.io:5000/ntlsrepo/ntlsrepo-test:latest 
                    """     
                 }
               }
             } // steps
         } // stage
    } // stages
} // pipeline
