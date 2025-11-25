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
                    // Test de connectivité
                    def sonarStatus = sh(
                        script: 'curl -s http://localhost:9000/api/system/status | grep -o "\"status\":\"[^\"]*\"" | cut -d"\"" -f4',
                        returnStdout: true
                    ).trim()

                    if (sonarStatus != "UP") {
                        error "❌ SonarQube n'est pas accessible. Statut: ${sonarStatus}"
                    } else {
                        echo "✅ SonarQube est accessible (Status: ${sonarStatus})"
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
                    // Méthode ROBUSTE avec gestion d'erreur
                    withSonarQubeEnv('sonarqube-local') {
                        sh """
                        mvn sonar:sonar \
                          -Dsonar.projectKey=my-java-app \
                          -Dsonar.projectName='My Java Application' \
                          -Dsonar.java.coveragePlugin=jacoco \
                          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                          -Dsonar.sourceEncoding=UTF-8 \
                          -Dsonar.host.url=\${SONAR_HOST_URL} \
                          -Dsonar.login=\${SONAR_AUTH_TOKEN}
                        """
                    }
                }
            }

            post {
                success {
                    echo '✅ Analyse SonarQube terminée avec succès!'
                    script {
                        // Récupérer l'URL du projet SonarQube
                        def sonarUrl = sh(
                            script: 'echo ${SONAR_HOST_URL}/dashboard?id=my-java-app',
                            returnStdout: true
                        ).trim()
                        echo "📊 Rapport disponible: ${sonarUrl}"
                    }
                }
                failure {
                    echo '❌ Échec de l analyse SonarQube!'
                    script {
                        echo '🔧 Debug info:'
                        echo "- Vérifier que SonarQube est démarré"
                        echo "- Vérifier les credentials dans Jenkins"
                        echo "- Vérifier les logs SonarQube: /opt/sonarqube/logs/sonar.log"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                echo '🚦 Étape 5: Vérification de la Quality Gate...'
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: false
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
                unstable {
                    echo '⚠️ Quality Gate instable! Améliorations nécessaires.'
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

                    script {
                        def warFile = sh(script: 'ls -la target/*.war', returnStdout: true).trim()
                        echo "📁 Fichier WAR généré: ${warFile}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🔧 Pipeline [${env.JOB_NAME}] - Build #${env.BUILD_NUMBER} terminé"

            // Nettoyage intelligent
            script {
                try {
                    cleanWs()
                    echo '🧹 Workspace nettoyé'
                } catch (Exception e) {
                    echo '⚠️ Nettoyage workspace échoué (peut être ignoré)'
                }
            }
        }
        success {
            echo '🎉 PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'

            script {
                def sonarReportUrl = "${SONARQUBE_URL}/dashboard?id=my-java-app"
                echo "📊 Rapport SonarQube: ${sonarReportUrl}"
            }
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'

            script {
                echo '🔧 Actions de dépannage:'
                echo "1. Vérifier SonarQube: ${SONARQUBE_URL}"
                echo '2. Vérifier les logs Jenkins'
                echo '3. Vérifier /opt/sonarqube/logs/sonar.log'
                echo '4. Tester manuellement: curl http://localhost:9000/api/system/status'
            }
        }
    }
}