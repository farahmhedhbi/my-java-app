pipeline {
    agent any

    tools {
        maven 'maven 4.0'
        jdk 'openjdk version 17'
    }

    environment {
        TOMCAT_URL = 'http://192.168.56.128:8080'
        GIT_REPO = 'https://github.com/farahmhedhbi/my-java-app.git'
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

        stage('Tests') {
            steps {
                echo '🧪 Étape 3: Exécution des tests unitaires JUnit...'
                sh 'mvn test'
            }

            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    echo '📊 Rapports de tests générés'
                }
            }
        }

        stage('Package') {
            steps {
                echo '📦 Étape 4: Création du package WAR...'
                sh 'mvn package -DskipTests'
            }

            post {
                success {
                    echo '✅ Package WAR créé avec succès!'
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }

        // Stage SonarQube temporairement désactivé
        stage('SAST - SonarQube Analysis') {
            steps {
                echo '🔍 Étape 5: Analyse SonarQube (désactivée pour le moment)...'
                echo '📋 SonarQube sera configuré dans la prochaine étape'
            }
        }
    }

    post {
        always {
            echo "🔧 Pipeline [${env.JOB_NAME}] - Build #${env.BUILD_NUMBER} terminé"
            // cleanWs() RETIRÉ pour l'instant
        }
        success {
            echo '🎉 PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'
            script {
                echo "📧 Notification email configurée pour: admin@example.com"
                // Email temporairement désactivé
            }
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
        }
    }
}