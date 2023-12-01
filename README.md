# iRetain-App
A cross-platform mobile app “iRetain” that allowed professors to post quizzes for student review

## Table of Contents
1. [Introduction](#introduction)
2. [Features & Demo](#features--demo)
   - [Video Demo](#video-demo)
   - [Features](#features)
3. [Prototype & Video Demo](#prototype--video-demo)
4. [Installation](#installation)
   - [iOS](#ios)
   - [Android](#android)
5. [Technology Stack](#technology-stack)
6. [Build & Development](#build--development)
7. [Firebase](#firebase)
   - [Firebase Documents](#firebase-documents)

## Introduction

- The app's goal is to periodically send questions to the students about certain important topics after they learn them in class. This way, the information stays fresh in their mind and students retain it for much longer.
- This app is targeted towards Duke University professors and students.
- It supports both iOS and Android platforms.

## Features & Demo
Will be updated in the future...

### Video Demo
- iOS:
  - Student side:
  - Teacher side:
- Android:
  - Student side:
  - Teacher side:

### Features
- Student side:
  - Log in with duke netid.
  - Log out.
  - View all the classes the student ever enrolled in.
  - Enroll in new class with permission number.
  - Answer released questions for classes they enrolled this year.
  - Submit feedback for enrolled classes.
- Teacher side:
  - Log in with duke netid:
  - Log out:
  - Home page: view all the classes the teacher enrolled in:
  - Add new class and get a permission number for students' enrollment:
  - Release questions for added classes:
  - View previous questions in early semesters and reuse them:
  - Check the feedback from students:
  - Check the statistic of released questions:
  

## Prototype & Video Demo
We built the prototype via Figma.
- iOS:
  - Video Demo: 
  - Figma prototype for [Student side](https://www.figma.com/file/pKnh4sojIYBgg5ieAkLPhC/iRetain-App-0?type=design&node-id=0%3A1&mode=design&t=Pv6U3MUn34HR94jG-1)
  - Figma prototype for [Teacher side](https://www.figma.com/file/qCpTMNDFPCnBDE2SyO13sn/iRetain-App-1?type=design&node-id=0%3A1&mode=design&t=3WqsBbikyEgFKmmg-1)


## Installation
We plan to release it in the app store during the Spring semester of 2024. Therefore, this section is to be updated...

### iOS
- Download the app from the Apple App Store.

### Android
- Download the app from the Google Play Store.

- For beta versions or direct installation files (like APKs), please follow ...

## Technology Stack

- It uses Firebase as a real-time database and is built using Java and XML for Android, and Swift and SwiftUI for iOS.
- It enables real-time notifications for students in Android and iOS versions by utilizing Firebase Cloud Messaging (FCM) topic messaging and sending network requests to the server developed using Java and Spring Boot

## Build & Development
- iOS:
  - download Xcode app in mac App Store
  - download [iOS code](https://github.com/CaoRui0910/iRetain-App/tree/main/iOS)
  - run with `pod install` to install the pods. You can also install the Firebase, SideMenu, DropDown dependencies via swift package manager. For the installation of Firebase by swift package manager, please check [Add Firebase to your Apple project](https://firebase.google.com/docs/ios/setup#add-sdks)
  - open your .xcworkspace file to see the project in Xcode.
  - If you want to use the notification feature, you need to enroll in the [Apple Developer Program](https://developer.apple.com/programs/enroll/). The Apple Developer Program is 99 USD per membership year.
- Android
  - Will be updated in the future...

## Firebase
- [Firebase project link](https://console.firebase.google.com/project/nudge-ce02c/overview)

- [Firbase official document for managing data](https://firebase.google.com/docs/firestore/manage-data/add-data)


### Firebase Documents

- courses:
  - store basic info of class: class ID and class name.

- courses_add:
  - store enrollment info of teachers: class ID, class name, teacher netID, role (teacher:0, student: 1), enrolled year, permission number, total count of enrolled students, feedback from students

- student_courses_add:
  - store enrollment info of students: class ID, class name, student netID, role (teacher:0, student: 1), enrolled year

- questions:
  - store question info: class ID, class name, netID of teacher, netID of answered students, question title, question, question choices, question answer (correct choice), count of students whose answer is correct, count of students whose answer is wrong
