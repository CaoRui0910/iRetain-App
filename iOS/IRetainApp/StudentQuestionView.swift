//
//  StudentQuestionView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/31.
//

import SwiftUI
import ExytePopupView
import FirebaseCore
import FirebaseFirestore
class StudentQuestionViewModel: ObservableObject {
    let question: QuestionDetail
    @Published
    var selectIndex: Int?
    @Published
    var showPop: Bool = false
    @Published
    var popText: String = ""
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    init(question: QuestionDetail) {
        self.question = question
    }
    func sumbmitAction() {
        if let selectIndex {
            let str = "\(selectIndex)"
            popText = "You answer has been submitted!"
            let db = Firestore.firestore()
            if  str == question.choiceCorrect {
                db.collection("questions").document(question.questionID).updateData(["correct_count": question.correctCount+1, "answer_student": FieldValue.arrayUnion([netID])])
                
            } else {
                db.collection("questions").document(question.questionID).updateData(["wrong_count": question.wrongCount+1, "answer_student": FieldValue.arrayUnion([netID])])
            }
            showPop = true
            
        } else {
            popText = "You already answered this question!"
            showPop = true
        }
    }
}
struct StudentQuestionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject
    var viewModel: StudentQuestionViewModel
    var body: some View {
        Form {
            Section {
                Text(viewModel.question.question)
            }
            .frame(minHeight: 100,alignment: .top)
            Section {
                ForEach(0..<4) { index in
                    choiceItemView(index)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                viewModel.sumbmitAction()
            }label: {
                Text("submit")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(.blue)
                    .clipShape(Capsule())
                    
            }
        }
        .popup(isPresented: $viewModel.showPop) {
            popView
        } customize: {
            $0.closeOnTapOutside(false)
                .closeOnTap(false)
        }
    }
    var popView: some View {
        VStack {
            Text(viewModel.popText)
                .padding(.top, 20)
            Button {
                viewModel.showPop = false
                dismiss()
            } label: {
                Text("back")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.blue)
            .clipShape(Capsule())
            .padding(.bottom,20)
            .padding(.top,30)
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.yellow)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    @ViewBuilder
    func choiceItemView(_ index: Int) -> some View {
        let isSelect = viewModel.selectIndex == index
        HStack {
            Button {
                viewModel.selectIndex = index
            } label: {
                Group {
                    if isSelect {
                        Image("Checkbox")
                            .resizable()
                    } else {
                        Image("UnCheckbox")
                            .resizable()
                    }
                }
                .frame(width: 20, height: 20)
            }
           Text(getChoiceStr(index))
                .frame(maxWidth: .infinity,alignment: .leading)
        }
    }
    
    func getChoiceStr(_ index: Int) -> String{
        switch index {
        case 0:
            return viewModel.question.choice1
        case 1:
            return viewModel.question.choice2
        case 2:
            return viewModel.question.choice3
        case 3:
            return viewModel.question.choice4
        default:
            return ""
            
        }
    }
}
