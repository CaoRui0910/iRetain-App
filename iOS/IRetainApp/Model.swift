//
//  Model.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

struct Course: Hashable {
    var CourseName: String
    var CourseID: String
    var EnrolledYear: Int
}

struct Question {
    var ID: String
    var QuestionTitle: String
    var ReleaseDate: String
}

struct Statistic {
    var ID: String
    var ReleaseDate: String
    var Total: String
    var Participants: String
    var CorrectPercentage: String
}
struct QuestionDetail: Hashable {
    var questionID: String
    var teacherNetID: String
    var courseName: String
    var courseID:String
    var questionTitle: String
    var question: String
    var choice1: String
    var choice2: String
    var choice3: String
    var choice4: String
    var choiceCorrect: String
    var releaseDate: String
    var correctCount = 0
    var wrongCount = 0
    var answerStudent:[String] = []
    static func findQuestion(_ courseID: String, netID: String? = nil) async -> [QuestionDetail] {
        let db = Firestore.firestore()
        
        let query = db.collection("questions").whereField("courseID", isEqualTo: courseID).order(by: "release_date", descending: true)
        return await withCheckedContinuation { continuation in
            query.getDocuments() { (querySnapshot, err) in
                let array = querySnapshot?.documents.map {document in
                    let data = document.data()
                    return QuestionDetail.init(
                        questionID: document.documentID,
                        teacherNetID: data["teacher_netID"] as? String ?? "",
                        courseName: data["courseName"] as? String ?? "",
                        courseID: data["courseID"] as? String ?? "",
                        questionTitle: data["teacher_question_title"] as? String ?? "",
                        question: data["teacher_question"] as? String ?? "",
                        choice1: data["choice1"] as? String ?? "",
                        choice2: data["choice2"] as? String ?? "",
                        choice3: data["choice3"] as? String ?? "",
                        choice4: data["choice4"] as? String ?? "",
                        choiceCorrect: data["choice_correct"] as? String ?? "",
                        releaseDate: data["release_date"] as? String ??  "",
                        correctCount: data["correct_count"] as? Int ?? 0,
                        wrongCount: data["wrong_count"] as? Int ?? 0,
                        answerStudent: data["answer_student"] as? [String] ?? []
                    )
                }
                if let array {
                    if let netID {
                        continuation.resume(returning: array.filter({!$0.answerStudent.contains(netID)}))
                    } else {
                        continuation.resume(returning: array)
                    }
                    
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    func changeQuestion() async -> Bool{
        let docData: [String: Any] = [
            "teacher_netID": teacherNetID,
            "courseName": courseName,
            "courseID": courseID,
            "teacher_question_title": questionTitle,
            "teacher_question": question,
            "choice1": choice1,
            "choice2": choice2,
            "choice3": choice3,
            "choice4": choice4,
            "choice_correct": choiceCorrect,
            "release_date": releaseDate,
            "correct_count": correctCount,
            "wrong_count": wrongCount,
            
        ]
        let db = Firestore.firestore()
        
        let docRef = db.collection("questions").document()
        return await withCheckedContinuation { continuation in
            docRef.setData(docData) { error in
                if let _ = error {
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: true	)
                }
            }
        }
    }
    static func findQuestion(_ id: String) async -> QuestionDetail? {
        let db = Firestore.firestore()
        
        let docRef = db.collection("questions").document(id)
        
        return await  withCheckedContinuation { continuation in
            docRef.getDocument { (document, error) in
                if let document = document ,document.exists,let data = document.data() {
                    let aa = QuestionDetail.init(
                        questionID: document.documentID,
                        teacherNetID: data["teacher_netID"] as? String ?? "",
                        courseName: data["courseName"] as? String ?? "",
                        courseID: data["courseID"] as? String ?? "",
                        questionTitle: data["teacher_question_title"] as? String ?? "",
                        question: data["teacher_question"] as? String ?? "",
                        choice1: data["choice1"] as? String ?? "",
                        choice2: data["choice2"] as? String ?? "",
                        choice3: data["choice3"] as? String ?? "",
                        choice4: data["choice4"] as? String ?? "",
                        choiceCorrect: data["correct_count"] as? String ?? "",
                        releaseDate: data["release_date"] as? String ??  "",
                        correctCount: data["correct_count"] as? Int ?? 0,
                        wrongCount: data["wrong_count"] as? Int ?? 0
                    )
                    continuation.resume(returning:aa)
                }else {
                    continuation.resume(returning:nil)
                }
            }
            
        }
    }
    
}
