<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application DevOps - Version 1.0</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .info-box {
            background: #e8f4fc;
            padding: 15px;
            border-left: 4px solid #3498db;
            margin: 20px 0;
        }
        .feature-list {
            list-style-type: none;
            padding: 0;
        }
        .feature-list li {
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .feature-list li:before {
            content: "✅ ";
            margin-right: 10px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>🚀 Application DevOps - ISET Kairouan</h1>

    <div class="info-box">
        <strong>Informations du projet :</strong><br>
        <strong>Nom :</strong> My Java Application<br>
        <strong>Version :</strong> 1.0.0<br>
        <strong>Date :</strong> <%= new java.util.Date() %><br>
        <strong>Serveur :</strong> <%= application.getServerInfo() %>
    </div>

    <h2>Fonctionnalités implémentées :</h2>
    <ul class="feature-list">
        <li>Pipeline CI/CD complet</li>
        <li>Intégration GitHub + Jenkins</li>
        <li>Tests automatisés JUnit</li>
        <li>Analyse qualité avec SonarQube</li>
        <li>Déploiement automatique Tomcat</li>
        <li>Gestion des branches Git</li>
    </ul>

    <h2>Calculatrice DevOps :</h2>
    <%
        com.example.myjavaapp.utils.Calculator calc = new com.example.myjavaapp.utils.Calculator();
        int resultAdd = calc.add(15, 25);
        int resultMultiply = calc.multiply(6, 7);
    %>
    <p>15 + 25 = <strong><%= resultAdd %></strong></p>
    <p>6 × 7 = <strong><%= resultMultiply %></strong></p>

    <div style="margin-top: 30px; padding: 15px; background: #f8f9fa; border-radius: 5px;">
        <small>
            <strong>Étudiant :</strong> Votre Nom<br>
            <strong>Classe :</strong> RS131/DS131<br>
            <strong>Année :</strong> 2024-2025
        </small>
    </div>
</div>
</body>
</html>