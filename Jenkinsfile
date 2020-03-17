pipeline {
    agent any
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
           stage('Move Image') {
                steps {
                             sh """
                                   oc image mirror docker-registry.default.svc:5000/jblaine/ntlsrepo:latest aio.home.io:5000/ntlsrepo/ntlsrepo-test:latest --insecure
                                """
                        }
                     }
    } // stages
} // pipeline
