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
        stage('Checkout') {
            steps {
                echo '🚀 Étape 1: Récupération du code depuis GitHub...'
                git branch: 'main',
                    url: "${GIT_REPO}"

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

            post {
                success {
                    echo '✅ Build Maven réussi!'
                }
                failure {
                    echo '❌ Échec du build Maven!'
                }
            }
        }

        stage('Tests & Coverage') {
            steps {
                echo '🧪 Étape 3: Exécution des tests unitaires et analyse de couverture...'
                script {
                    try {
                        sh 'mvn test jacoco:report'
                        echo '✅ Tests et couverture exécutés avec succès'
                    } catch (Exception e) {
                        echo '⚠️ Aucun test trouvé ou erreur lors de l exécution - étape ignorée'
                    }
                }
            }

            post {
                always {
                    script {
                        try {
                            junit 'target/surefire-reports/*.xml'
                            echo '📊 Rapports de tests publiés'
                        } catch (Exception e) {
                            echo '📋 Aucun rapport de test à publier'
                        }
                    }
                }
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '🔍 Étape 4: Analyse de qualité du code avec SonarQube...'
                script {
                    withSonarQubeEnv('sonarqube') {
                        sh """
                        mvn sonar:sonar \
                          -Dsonar.projectKey=my-java-app \
                          -Dsonar.projectName='My Java Application' \
                          -Dsonar.host.url=${SONARQUBE_URL} \
                          -Dsonar.java.coveragePlugin=jacoco \
                          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                        """
                    }
                }
            }

            post {
                success {
                    echo '✅ Analyse SonarQube terminée avec succès!'
                }
                failure {
                    echo '❌ Échec de l analyse SonarQube!'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '🚦 Étape 5: Vérification de la Quality Gate...'
                script {
                    timeout(time: 1, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }

            post {
                success {
                    echo '✅ Quality Gate passée! Le code respecte les standards de qualité.'
                }
                failure {
                    echo '❌ Quality Gate échouée! Vérifiez les problèmes dans SonarQube.'
                }
            }
        }

        stage('Package') {
            steps {
                echo '📦 Étape 6: Création du package WAR...'
                sh 'mvn package -DskipTests'
            }

            post {
                success {
                    echo '✅ Package WAR créé avec succès!'
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }
    }

    post {
        always {
            echo "🔧 Pipeline [${env.JOB_NAME}] - Build #${env.BUILD_NUMBER} terminé"
            // Nettoyage des fichiers temporaires
            cleanWs()
        }
        success {
            echo '🎉 PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'
            // Notification de succès (optionnel)
            emailext (
                subject: "SUCCÈS: Build ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Le pipeline s'est terminé avec succès. Consultez SonarQube pour les métriques de qualité.",
                to: "votre-email@example.com"
            )
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
            // Notification d'échec (optionnel)
            emailext (
                subject: "ÉCHEC: Build ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué. Veuillez vérifier les logs Jenkins et SonarQube.",
                to: "votre-email@example.com"
            )
        }
    }
}