pipeline {
  agent {
      label 'base'
  }
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    } //options
    environment {
        DEV_NS      = "jblaine"
        APP_NAME    = "ruby-ex"
        BUILD_IMG   = "openshift/ruby:2.5"        
        GIT_REPO    = "ssh://git@github.com/jfblaine/ruby-ex.git"
        GIT_BRANCH  = "master"
        JFROG_URL   = "aio.home.io:5000"
        JFROG_REPO  = "ntlsrepo"
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
                 echo "Sample Build stage using project ${DEV_NS}"
                 script {
                     openshift.withCluster() {
                         openshift.withProject("${DEV_NS}")
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
                                 echo "No proevious BuildConfig. Creating new BuildConfig."
                                 def myNewApp = openshift.newApp (
                                     "${BUILD_IMG}~${GIT_REPO}#${GIT_BRANCH}", 
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

               withDockerRegistry([credentialsId: "aio-home-io-ntls-creds", url: ${JFROG_URL}]) {
                 sh """
                     oc image mirror --insecure=true docker-registry.default.svc:5000/"${DEV_NS}"/${APP_NAME}:v${BUILD_NUMBER} ${JFROG_URL}/${JFROG_REPO}/${APP_NAME}:v${BUILD_NUMBER}
                    """
                 }
               }
             } // steps
         } // stage
    } // stages
} // pipeline
