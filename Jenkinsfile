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
                                export KUBECONFIG=\${kubeconfig}; export TILLER_NAMESPACE=jblaine
                                helm version
                                helm install --debug ./${HELM_CHART_DIR}/ --set image_url="${JFROG_URL}/${JFROG_REPO}/${APP_NAME}:v84"
                               """
                       }
                  }
            } // steps
        } // stage
    } // stages
} // pipeline
