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
         stage('Build') {
             steps {
                 echo "Sample Build stage using project ${CICD_DEV}"
                 script {
                     openshift.withCluster() {
                         openshift.withProject("${CICD_DEV}")
                         {

                             if (openshift.selector("bc",APP_NAME).exists()) {
                                 echo "Using existing BuildConfig. Running new Build"
                                 def bc = openshift.startBuild(APP_NAME)
                                 openshift.set("env dc/${APP_NAME} BUILD_NUMBER=${BUILD_NUMBER}")
                                 // output build logs to the Jenkins conosole
                                 echo "Logs from build"
                                 def result = bc.logs('-f')
                                 // actions that took place
                                 echo "The logs operation require ${result.actions.size()} 'oc' interactions"
                                 // see exactly what oc command was executed.
                                 echo "Logs executed: ${result.actions[0].cmd}"
                             } else {
                                 echo "No previous BuildConfig. Creating new BuildConfig."
                                 def myNewApp = openshift.newApp (
                                     "${GIT_REPO}#${GIT_BRANCH}", 
                                     "--name=${APP_NAME}", 
                                     "-e BUILD_NUMBER=${BUILD_NUMBER}", 
                                     "-e BUILD_ENV=${openshift.project()}"
                                     )
                                 echo "new-app myNewApp ${myNewApp.count()} objects named: ${myNewApp.names()}"
                                 myNewApp.describe()
                                 // selects the build config 
                                 def bc = myNewApp.narrow('bc')
                                 // output build logs to the Jenkins conosole
                                 echo "Logs from build"
                                 def result = bc.logs('-f')
                                 // actions that took place
                                 echo "The logs operation require ${result.actions.size()} 'oc' interactions"
                                 // see exactly what oc command was executed.
                                 echo "Logs executed: ${result.actions[0].cmd}"
                             } //else

                             echo "Tag Container image with 'build number' as version"
                             openshift.tag("${APP_NAME}:latest", "${APP_NAME}:v${BUILD_NUMBER}")

                             echo "Validating Route for Service exist, if Not create Route"
                             if (!openshift.selector("route",APP_NAME).exists()) {
                                 openshift.selector("svc",APP_NAME).expose()
                             }

                         } // project
                     } // cluster
                 } // script
             } // steps
         } //stage-build
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
