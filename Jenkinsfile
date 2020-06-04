#!/usr/bin/env groovy

@Library("texas-pipeline@master")
import texas.common.pipeline.aws.AWSSecretManager
import texas.common.pipeline.Pipeline
import texas.common.pipeline.PipelineEnvironment

// Use shared texas code to obtain secrets from AWS
AWSSecretManager texasSecretManager = new AWSSecretManager()
// Use shared texas code (currently the use of this class is for exporting AWS creds)
Pipeline texasPipeline = new Pipeline()
PipelineEnvironment texasPipelineEnv = new PipelineEnvironment()


// Load common code
shared = ''

pipeline {
  agent any
  options {
    disableConcurrentBuilds()
    timestamps()
  }
  parameters {
    string(
        Namespace: 'Namespace',
        description: 'Enter a name for the RDS Namespace',
    )
  }

  environment {
    // Live management account
    MGMT_ACCOUNT_ID = '461183108257'
    // Live nonprod k8s account
    K8S_ACCOUNT_ID = '730319765130'

    KUBECONFIG_BUCKET_NAME = 'nhsd-texasplatform-kubeconfig-lk8s-nonprod'
    KUBECONFIG_FILE_NAME = 'live-leks-cluster_kubeconfig'
    RDS_ENDPOINT_ID = ''
    DNS_ZONE_NAME = 'k8s-nonprod.texasplatform.uk'
    ALIAS_TARGET_HOSTED_ZONE_ID = 'Z32O12XQLNTSW2'
    HOSTED_ZONE_ID = 'Z2XTY6OZEUPIQ2'

    NAMESPACE = sh(returnStdout: true, script: 'echo "${GIT_BRANCH##*/}" | tr "[A-Z]" "[a-z]"|tr -d "\n" ')
    DEPLOY_CONFIG = 'live-nonprod'
    JENKINS_USER = sh(returnStdout: true, script: 'echo `id -u jenkins` |tr -d "\n" ')
    JENKINS_GROUP = sh(returnStdout: true, script: 'echo `id -g jenkins` |tr -d "\n" ')

    TAG = ''

    //SECRET_NAME_PREFIX = ''

    SECRET_DEPLOYMENT_KEY_ORDER = ''//change

    SECRET_TEST_VALUES = 'UNKNOWN'
    K8S_ACCOUNT_REGION = 'eu-west-2'
    ACCOUNT_ID = "${K8S_ACCOUNT_ID}"
    ROLE = 'jenkins_assume_role'
    ACCOUNT_SHORT_NAME = 'live-k8s-nonprod'
  }

  stages {
      stage('Prepare Pipeline') { //find shared code
        steps {
          //A block of scripted pipeline within the declarative pipeline
          script {
            echo 'Namespace : '${NAMESPACE}
            shared = load './resources/jenkins/shared_code.groovy'
            TAG = shared.getTag()
            //Note: the following uses the shared pipeline code to set vars.
            texasPipelineEnv.setEnvVariablesByAccountShortName(this)
            //common code to keep only last 5 builds
            texasPipeline.clearOldBuilds(this)

            // Note: the following sets the _AWS prefixed variables (secret, access and session) used later in this script
            // as well as being used internally with the getOrderedDeploymentSecretsList function
            texasPipeline.exportAWSCredentials(this)
          }
        }
      }

      stage('Create RDS Instance'){  //choose name
        //sh """
        //make create-instance INSTANCE_NAME=${params.Namespace}
        //"""
      }

      stage('Populate Database'){
        //sh """
        //make populate-database
        //"""
      }

      stage('Delete namespaces') {
      steps {
        sh 'echo Deleting namespaces'
        //sh """
        //kubectl delete namespace ${NAMESPACE}
        //"""
      }
    }

    }
}

