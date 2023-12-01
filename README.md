# iRetain-App
A cross-platform mobile app “iRetain” that allowed professors to post quizzes for student review

## Table of Contents
1. [Introduction](#introduction)
2. [Features & Demo](#features--demo)
   - [Video Demo](#video-demo)
   - [Features](#features)
3. [Prototype](#prototype)
4. [Installation](#installation)
   - [iOS](#ios)
   - [Android](#android)
5. [Technology Stack](#technology-stack)
6. [Build & Development](#build--development)
7. [Firebase](#firebase)
   - [Firebase Documents](#firebase-documents)
## Introduction

“iRetain” App is a cross-platform mobile application designed to allow professors to post quizzes for student review. This app is targeted towards Duke University professors and students. It supports both iOS and Android platforms.


## Features & Demo
### Video Demo
- iOS:
  - Student side:
  - Teacher side:
- Android:
  - Student side:
  - Teacher side:

### Features
- Student side:
  - 
- Teacher side:


## Prototype



## Installation

### iOS
Download the app from the Apple App Store [Provide link].

### Android
Download the app from the Google Play Store [Provide link].

For beta versions or direct installation files (like APKs), please follow [additional instructions if applicable].

## Technology Stack

- It uses Firebase as a real-time database and is built using Java and XML for Android, and Swift and SwiftUI for iOS.
- It enables real-time notifications for students in Android and iOS versions by utilizing Firebase Cloud Messaging (FCM) topic messaging and sending network requests to the server developed using Java and Spring Boot

## Build & Development

Instructions for setting up the development environment and building the app from source [Provide detailed steps].


## Firebase
[Firebase project link](https://console.firebase.google.com/project/nudge-ce02c/overview)

[Firbase official document for managing data](https://firebase.google.com/docs/firestore/manage-data/add-data)


### Firebase Documents

- courses:
  - store basic info of class: class ID and class name.

- courses_add:
  - store enrollment info of teachers: class ID, class name, teacher netID, role (teacher:0, student: 1), enrolled year, permission number, total count of enrolled students, feedback from students

- student_courses_add:
  - store enrollment info of students: class ID, class name, student netID, role (teacher:0, student: 1), enrolled year

- questions:
  - store question info: class ID, class name, netID of teacher, netID of answered students, question title, question, question choices, question answer (correct choice), count of students whose answer is correct, count of students whose answer is wrong
