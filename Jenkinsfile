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
         stage('preamble') {
             steps {
                 script {
                     openshift.withCluster() {
                         openshift.withProject() {
                             echo "Using project: ${openshift.project()}"
                         }
                     }
                 }
             }
         }
         stage('Push image to Artifactory') {
           steps {
             withDockerRegistry([credentialsId: "docker-registry-default-svc", url: "https://docker-registry.default.svc:5000"]) {

               withDockerRegistry([credentialsId: "aio-home-io-ntls-creds", url: "https://aio.home.io:5000"]) {
                 sh """
                     oc image mirror --insecure=true docker-registry.default.svc:5000/jblaine/ntlsrepo:latest aio.home.io:5000/ntlsrepo/ntlsrepo-test:latest
                    """
                 }
               }
             } // steps
         } // stage
    } // stages
} // pipeline
