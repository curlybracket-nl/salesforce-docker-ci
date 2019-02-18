# Simple docker CI container for Salesforce
Simple CI container image that can be used in build servers such as Jenkins to automate the deployment and test to Salesforce.

> This images includes NodeJS which can be used in your build configuration for the automation of mundane tasks using JorceJS.

## Components
This image is based of Alpine linux 3.7 and includes the following components:
 * Apache Ant
 * Java (OpenJDK 8)
 * NodeJS
 * Bash
 * Git

By default the container comes with an Ant `build.xml` file and a modified version of the `ant-salesforce.jar` which outputs JUnit compatible test results for easy integration into your build pipeline. By default test result output is written to the `build\testreports` folder.

## Sample Jenkinsfile
Below you will find a sample configuration that can be used in a pipeline scripted jenkins setup to automate testing and deployment using this Docker CI image.


```groovy
pipeline {
    agent {
        docker { 
			image 'curlybracket/salesforce:latest' 
			// By default Jenkins passes it's own UID which does not exist in the container
			// so instead we override that with the container root user
			// this is a reported issue on Jenkins and is being worked on but for now this is a good work around
			args '-u root'
		}
    }
    environment { 
        CI_ENVIRONMENT = credentials('CI_ENVIRONMENT')
        CI_ENVIRONMENT_URL = 'https://test.salesforce.com'
    }
    stages {
		stage('Prepare') {
            steps {
                dir ('vlocity') {
                    sh 'npm install'
                }
			}
        }
        stage('Test') {
            stages {
                stage('Salesforce') {
                    when { changeset "src/*" }
                    steps {
                        sh 'ant -buildfile build/build.xml checkAndTest -Dsfdc.username=${CI_ENVIRONMENT_USR} -Dsfdc.password=${CI_ENVIRONMENT_PSW} -Dsfdc.serverurl=${CI_ENVIRONMENT_URL}'
                    }
                    post {
                        always {
                            junit 'build/testreports/*.xml'
                        }
                    }					
                }
            }
        }
		stage('Deploy') {
            stages {
                stage('Salesforce') {
                    when { changeset "src/*" }
                    steps {
                        sh 'ant -buildfile build/build.xml deployCode -Dsfdc.username=${CI_ENVIRONMENT_USR} -Dsfdc.password=${CI_ENVIRONMENT_PSW} -Dsfdc.serverurl=${CI_ENVIRONMENT_URL}'
                    }
                }
            }
        }
    }
}
```
