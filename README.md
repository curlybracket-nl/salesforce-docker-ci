# Simple docker CI container for Salesforce
Simple CI container that can be used in a CI/CD servers such as Jenkins to automate the deployment and test for Salesforce. 

> This images includes NodeJS and SFDX which can be used for the automation of mundane tasks on the Salesforce dpeloyment target

## Components
This image is based of Alpine linux 3.7 and includes the following components:
 * SFDX
 * Apache Ant
 * Java (OpenJDK 8)
 * NodeJS
 * Bash
 * Git

The container comes with an Ant `build.xml` file and a modified version of the `ant-salesforce.jar` which outputs JUnit compatible test results for easy integration into your build pipeline. Test results are written to the `testreports` folder relative to the base folder from which the ant deploy is executed.

## Sample Jenkinsfile
Below you will find a sample configuration that can be used in a scripted jenkins pipeline to automate testing and deployment of Salesforce.


```groovy
pipeline {
    agent {
        docker {
            image 'curlybracket/salesforce:latest'
        }
    }
    environment {
        CI_ENVIRONMENT = credentials('CI_ENVIRONMENT')
        CI_ENVIRONMENT_URL = 'https://test.salesforce.com'
    }
    stages {
        stage('Test') {
            steps {
                sh 'ant -buildfile /build/build.xml checkAndTest -Dbasedir=${WORKSPACE} -Dsfdc.username=${CI_ENVIRONMENT_USR} -Dsfdc.password=${CI_ENVIRONMENT_PSW} -Dsfdc.serverurl=${CI_ENVIRONMENT_URL}'
            }
            post {
                always {
                    junit 'testreports/*.xml'
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'ant -buildfile build/build.xml deployCode -Dsfdc.username=${CI_ENVIRONMENT_USR} -Dsfdc.password=${CI_ENVIRONMENT_PSW} -Dsfdc.serverurl=${CI_ENVIRONMENT_URL}'
            }
        }
    }
}
```
