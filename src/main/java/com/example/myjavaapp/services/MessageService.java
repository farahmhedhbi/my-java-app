package com.example.myjavaapp.services;

public class MessageService {

    public String getWelcomeMessage() {
        return "Bienvenue dans notre application DevOps ISET K!";
    }

    public String getDevOpsMessage() {
        return "CI/CD avec Jenkins, SonarQube et Tomcat";
    }

    public String getCurrentTime() {
        return "Heure serveur: " + new java.util.Date();
    }
}
