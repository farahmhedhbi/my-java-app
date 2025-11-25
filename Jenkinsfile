pipeline {
    agent any

    tools {
        maven 'maven-3.9'
        jdk 'openjdk-17'
    }

    environment {
        TOMCAT_URL = 'http://localhost:8080'
        GIT_REPO = 'https://github.com/farahmhedhbi/my-java-app.git'
        SONARQUBE_URL = 'http://localhost:9000'
    }

    stages {
        stage('Vérification Infrastructures') {
            steps {
                echo '🔍 Vérification des services...'
                script {
                    // Vérification SonarQube
                    def sonarResponse = sh(script: 'curl -s http://localhost:9000/api/system/status', returnStdout: true).trim()
                    if (sonarResponse.contains('"status":"UP"')) {
                        echo "✅ SonarQube: Opérationnel"
                    } else {
                        echo "❌ SonarQube: Hors service"
                    }

                    // Vérification Tomcat
                    def tomcatCode = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:8080', returnStdout: true).trim()
                    if (tomcatCode == "200") {
                        echo "✅ Tomcat: Opérationnel"
                    } else {
                        echo "❌ Tomcat: Hors service"
                    }
                }
            }
        }

        stage('Checkout') {
            steps {
                echo '🚀 Étape 1: Récupération du code depuis GitHub...'
                git branch: 'main', url: "${GIT_REPO}"
                script {
                    currentBuild.displayName = "BUILD #${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Étape 2: Construction de l application avec Maven...'
                sh 'mvn clean compile'
            }
        }

        stage('Tests & Coverage') {
            steps {
                echo '🧪 Étape 3: Exécution des tests unitaires et analyse de couverture...'
                sh 'mvn test jacoco:report'
            }

            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '🔍 Étape 4: Analyse de qualité du code avec SonarQube...'
                sh """
                mvn sonar:sonar \
                  -Dsonar.projectKey=my-java-app \
                  -Dsonar.projectName='My Java Application' \
                  -Dsonar.host.url=http://localhost:9000 \
                  -Dsonar.login=admin \
                  -Dsonar.password=farah \
                  -Dsonar.java.coveragePlugin=jacoco \
                  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                """
            }
        }

        stage('Package') {
            steps {
                echo '📦 Étape 5: Création du package WAR...'
                sh 'mvn package -DskipTests'
            }

            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo '🚀 Étape 6: Déploiement vers Tomcat...'
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'tomcat-credentials',
                        passwordVariable: 'TOMCAT_PASSWORD',
                        usernameVariable: 'TOMCAT_USER'
                    )]) {
                        sh """
                        echo "Déploiement de l'application sur Tomcat..."
                        curl -u ${TOMCAT_USER}:${TOMCAT_PASSWORD} \
                             -X PUT \
                             -F file=@target/my-java-app.war \
                             http://localhost:8080/manager/text/deploy?path=/myapp
                        """
                    }
                }
            }

            post {
                success {
                    echo '✅ Application déployée avec succès sur Tomcat!'
                    echo '🌐 Accédez à: http://localhost:8080/myapp'
                }
                failure {
                    echo '❌ Échec du déploiement Tomcat!'
                }
            }
        }
    }

    post {
        always {
            echo "🔧 Pipeline [${env.JOB_NAME}] - Build #${env.BUILD_NUMBER} terminé"
        }
        success {
            echo '🎉 PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'
            echo "📊 SonarQube: http://localhost:9000/dashboard?id=my-java-app"
            echo "🌐 Application: http://localhost:8080/myapp"
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
        }
    }
}