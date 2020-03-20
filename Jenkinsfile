pipeline {
  agent none
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    } //options
    environment {
        DEV_NS          = "jblaine"
        APP_NAME        = "py-helloworld"
        APP_GIT_REPO    = "ssh://git@github.com/jfblaine/py-helloworld.git"
        GIT_BRANCH      = "master"
        JFROG_URL       = "aio.home.io:5000"
        JFROG_REPO      = "ntlsrepo"
        HELM_CHART_DIR  = "helm-deploy"
        HELM_REPO       = "ssh://git@github.com/jfblaine/${HELM_CHART_DIR}.git"
    }
    stages {
         stage('Build') {
            agent { base }
            steps {
                 script {
                     openshift.withCluster() {
                         openshift.withProject() {
                             echo "Using project: ${openshift.project()}"
                         }
                     }
                 }                
                 echo "Sample Build stage using project ${DEV_NS}"
                 echo "Sample Build running on node: ${NODE_NAME}"
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
                                 echo "No previous BuildConfig. Creating new BuildConfig."
                                 def myNewApp = openshift.newApp (
                                     "${APP_GIT_REPO}#${GIT_BRANCH}",
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
           agent { base }
           steps {
             withDockerRegistry([credentialsId: "docker-registry-default-svc", url: "https://docker-registry.default.svc:5000"]) {
               withDockerRegistry([credentialsId: "aio-home-io-ntls-creds", url: "https://${JFROG_URL}"]) {
                 sh """
                     oc image mirror --insecure=true "docker-registry.default.svc:5000/${DEV_NS}/${APP_NAME}:v${BUILD_NUMBER}" "${JFROG_URL}/${JFROG_REPO}/${APP_NAME}:v${BUILD_NUMBER}"
                    """
                 }
               }
             } // steps
         } // stage
         stage('Deploy image with helm') {
           agent { helm }             
           steps {
                 sh """
                     git clone ${HELM_REPO}
                    """
                 sh """
                     helm install --debug ./${HELM_CHART_DIR}/ --set image_url="${JFROG_URL}/${JFROG_REPO}/${APP_NAME}:v${BUILD_NUMBER}"
                    """
             } // steps
         } // stage         
    } // stages
} // pipeline
