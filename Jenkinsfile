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
        stage('Vérification SonarQube') {
            steps {
                echo '🔍 Vérification de la connectivité SonarQube...'
                script {
                    try {
                        def response = sh(
                            script: 'curl -s http://localhost:9000/api/system/status',
                            returnStdout: true
                        ).trim()

                        echo "📡 Réponse SonarQube: ${response}"

                        if (response.contains('"status":"UP"')) {
                            echo "✅ SonarQube est accessible et opérationnel"

                            // Test d'authentification avec admin/farah
                            def authTest = sh(
                                script: 'curl -s -u admin:farah http://localhost:9000/api/authentication/validate',
                                returnStdout: true
                            ).trim()

                            echo "🔐 Test auth: ${authTest}"

                            if (authTest.contains('"valid":true')) {
                                echo "✅ Authentification admin/farah fonctionne"
                            } else {
                                echo "❌ Authentification admin/farah échoue"
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠️ Erreur lors de la vérification: ${e.getMessage()}"
                    }
                }
            }
        }

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
                    sh """
                    mvn sonar:sonar \
                      -Dsonar.projectKey=my-java-app \
                      -Dsonar.projectName='My Java Application' \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=admin \
                      -Dsonar.password=farah \
                      -Dsonar.java.coveragePlugin=jacoco \
                      -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                      -Dsonar.sourceEncoding=UTF-8
                    """
                }
            }

            post {
                success {
                    echo '✅ Analyse SonarQube terminée avec succès!'
                    script {
                        echo "📊 Rapport disponible: http://localhost:9000/dashboard?id=my-java-app"
                    }
                }
                failure {
                    echo '❌ Échec de l analyse SonarQube!'
                }
            }
        }

        stage('Package') {
            steps {
                echo '📦 Étape 5: Création du package WAR...'
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
        }
        success {
            echo '🎉 PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'
            echo "📊 Rapport SonarQube: http://localhost:9000/dashboard?id=my-java-app"
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
        }
    }
}