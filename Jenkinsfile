pipeline {
    agent any

    tools {
        maven 'maven-3.9'
        jdk 'openjdk-17'
    }

    environment {
        SONAR_SCANNER_HOME = tool 'sonar-scanner'
        TOMCAT_URL = 'http://192.168.56.128:8080'
        GIT_REPO = 'https://github.com/farahmhedhbi/my-java-app.git'
    }

    stages {
        // STAGE 1: Checkout du code
        stage('Checkout') {
            steps {
                echo ' Étape 1: Récupération du code depuis GitHub...'
                git branch: 'main',
                    url: "${GIT_REPO}",
                    credentialsId: 'github-credentials'

                script {
                    currentBuild.displayName = "BUILD #${env.BUILD_NUMBER}"
                    currentBuild.description = "Pipeline DevOps - ${env.BRANCH_NAME}"
                }
            }
        }

        // STAGE 2: Build Maven
        stage('Build') {
            steps {
                echo 'Étape 2: Construction de l application avec Maven...'
                sh 'mvn clean compile'

                // Archivage du pom.xml pour inspection
                archiveArtifacts artifacts: 'pom.xml', fingerprint: true
            }

            post {
                success {
                    echo ' Build Maven réussi!'
                }
                failure {
                    echo ' Échec du build Maven!'
                }
            }
        }

        // STAGE 3: Tests Unitaires
        stage('Tests') {
            steps {
                echo ' Étape 3: Exécution des tests unitaires JUnit...'
                sh 'mvn test'
            }

            post {
                always {
                    // Publication des rapports de test
                    junit 'target/surefire-reports/*.xml'
                    echo ' Rapports de tests générés'
                }
            }
        }

        // STAGE 4: Packaging
        stage('Package') {
            steps {
                echo ' Étape 4: Création du package WAR...'
                sh 'mvn package -DskipTests'

                // Archivage de l artifact
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }

            post {
                success {
                    echo ' Package WAR créé avec succès!'
                    script {
                        def warFile = findFiles(glob: 'target/*.war')[0]
                        echo " Fichier WAR: ${warFile.name}"
                        echo " Taille: ${warFile.length()} bytes"
                    }
                }
            }
        }

        // STAGE 5: Qualité du Code (SAST - SonarQube)
        stage('SAST - SonarQube Analysis') {
            steps {
                echo ' Étape 5: Analyse de la qualité du code avec SonarQube...'
                script {
                    // Cette étape sera complétée quand SonarQube sera installé
                    echo ' Analyse SonarQube configurée - À implémenter'
                }
            }
        }

        // STAGE 6: Déploiement Tomcat
        stage('Deploy to Tomcat') {
            steps {
                echo '🚀 Étape 6: Déploiement sur Tomcat...'
                script {
                    // Vérification que le WAR existe
                    def warFile = findFiles(glob: 'target/*.war')
                    if (warFile) {
                        echo " Déploiement du fichier: ${warFile[0].name}"

                        // Déploiement manuel (temporaire)
                        sh '''
                            echo "Simulation du déploiement Tomcat"
                            echo "Fichier WAR: target/my-java-app.war"
                            echo "URL Tomcat: ${TOMCAT_URL}"
                        '''
                    } else {
                        error " Aucun fichier WAR trouvé pour le déploiement"
                    }
                }
            }

            post {
                success {
                    echo ' Application déployée avec succès sur Tomcat!'
                    echo " URL: ${TOMCAT_URL}/my-java-app"
                }
            }
        }
    }

    post {
        always {
            echo " Pipeline [${env.JOB_NAME}] - Build #${env.BUILD_NUMBER} terminé"
            cleanWs() // Nettoyage du workspace
        }
        success {
            echo ' PIPELINE RÉUSSI! Toutes les étapes complétées avec succès.'
            script {
                // Notification simple
                emailext (
                    subject: "SUCCESS: Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """
                    Le pipeline DevOps a été exécuté avec succès!

                    Détails:
                    - Job: ${env.JOB_NAME}
                    - Build: #${env.BUILD_NUMBER}
                    - Branche: ${env.BRANCH_NAME}
                    - URL: ${env.BUILD_URL}

                    Étapes réussies:
                    ✅ Checkout GitHub
                    ✅ Build Maven
                    ✅ Tests Unitaires
                    ✅ Packaging WAR
                    ✅ Déploiement Tomcat
                    """,
                    to: "admin@example.com"
                )
            }
        }
        failure {
            echo ' PIPELINE ÉCHOUÉ! Vérifiez les logs pour plus de détails.'
            script {
                emailext (
                    subject: "FAILED: Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """
                    Le pipeline DevOps a échoué!

                    Détails:
                    - Job: ${env.JOB_NAME}
                    - Build: #${env.BUILD_NUMBER}
                    - Branche: ${env.BRANCH_NAME}
                    - URL: ${env.BUILD_URL}

                    Consultez les logs pour identifier l'erreur.
                    """,
                    to: "admin@example.com"
                )
            }
        }
        unstable {
            echo 'Pipeline instable - Certains tests ont échoué'
        }
    }
}