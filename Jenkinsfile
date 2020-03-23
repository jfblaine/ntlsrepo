pipeline {
  agent none
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    } //options
    environment {
        JFROG_URL_BASE   = "aio.home.io:5000"
        JFROG_REPO       = "ntlsrepo"
        DEV_NS           = "ntls-dev"
        APP_NAME         = "py-helloworld"
        APP_BLDR_IMG     = "${JFROG_URL_BASE}/${JFROG_REPO}/ubi7-python-36:1-63.1584463519"
        GIT_URL          = "ssh://git@github.com/jfblaine"
        APP_GIT_REPO     = "${GIT_URL}/py-helloworld.git"
        JFROG_OCP_SECRET = "artifactory-pull-secret"
        GIT_BRANCH       = "master"
        HELM_CHART_DIR   = "helm-deploy"
        HELM_REPO        = "${GIT_URL}/${HELM_CHART_DIR}.git"
        TILLER_NAMESPACE = "ntls-tiller"
    }
    parameters {
        choice(name: 'TARGET_NS', choices: ['ntls-qa', 'ntls-prod'], description: 'Choose target environment')
        choice(name: 'DB_TYPE', choices: ['mysql', 'oracle'], description: 'Choose database to be used')
    }
    stages {
         stage('Build') {
            agent {
                label 'base'
            }
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
                                 echo "Using existing BuildConfig. Running new Build."
                                 def bc = openshift.startBuild(APP_NAME)
                                 openshift.set("env dc/${APP_NAME} BUILD_NUMBER=${BUILD_NUMBER}")
                                 // output build logs to the Jenkins console
                                 echo "Logs from build"
                                 def result = bc.logs('-f')
                                 // actions that took place
                                 echo "The logs operation require ${result.actions.size()} 'oc' interactions"
                                 // see exactly what oc command was executed.
                                 echo "Logs executed: ${result.actions[0].cmd}"
                             } else {
                                 echo "No existing BuildConfig found. Creating new BuildConfig."
                                 def myNewApp = openshift.newApp (
                                     "--name=${APP_NAME}",
                                     "${APP_BLDR_IMG}~${APP_GIT_REPO}#${GIT_BRANCH}",
                                     "--strategy=docker",
                                     "--insecure-registry",
                                     "-e BUILD_NUMBER=${BUILD_NUMBER}",
                                     "-e BUILD_ENV=${openshift.project()}",
                                     "-e NAMESPACE=${DEV_NS}"
                                     )
                                 openshift.set("build-secret --pull bc/${APP_NAME} ${JFROG_OCP_SECRET}")
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

                             echo "Determining if Route for Service exists, if not create Route"
                             if (!openshift.selector("route",APP_NAME).exists()) {
                                 openshift.selector("svc",APP_NAME).expose()
                             }
                         } // project
                     } // cluster
                 } // script
                 // Push to Artifactory
                 echo "Pushing copy of image from OpenShift registry to Artifactory repo."
                 withDockerRegistry([credentialsId: "docker-registry-default-svc", url: "https://docker-registry.default.svc:5000"]) {
                   withDockerRegistry([credentialsId: "aio-home-io-ntls-creds", url: "https://${JFROG_URL_BASE}"]) {
                     sh """
                         oc image mirror --insecure=true "docker-registry.default.svc:5000/${DEV_NS}/${APP_NAME}:v${BUILD_NUMBER}" "${JFROG_URL_BASE}/${JFROG_REPO}/${APP_NAME}:v${BUILD_NUMBER}"
                        """
                     }
                   }
                 echo "Push to Artifactory complete."
             } // steps
         } //stage-build
         stage('Deploy image with helm') {
            agent {
                label 'helm'
            }
            steps {
                  script {
                       git credentialsId: 'helm-deploy-repo-at-github',
                           url: "${HELM_REPO}"
                       withCredentials([file(credentialsId: 'tiller-kubeconfig', variable: 'kubeconfig')]) {
                            sh """
                                export KUBECONFIG=\${kubeconfig}; export TILLER_NAMESPACE="${TILLER_NAMESPACE}"
                                helm upgrade --install --debug "${APP_NAME}-${TARGET_NS}" . \
                                    --tiller-namespace "${TILLER_NAMESPACE}" --namespace "${TARGET_NS}" \
                                    --set image_url="${JFROG_URL_BASE}/${JFROG_REPO}/${APP_NAME}:v${BUILD_NUMBER}" \
                                    --set name="${APP_NAME}" --set namespace="${TARGET_NS}" --set db_type="${DB_TYPE}"
                               """
                       }
                  } // script
            } // steps
        } // stage
    } // stages
} // pipeline
