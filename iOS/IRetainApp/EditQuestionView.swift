//
//  EditQuestionView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/30.
//

import SwiftUI
import ExytePopupView

class EditQuestionViewModel: ObservableObject {
    let courseId: String
    var questionModel: QuestionDetail?
    @AppStorage("netID")  var netID = ""
    @Published
    var questionTitle:String = ""
    @Published
    var questioContent: String = ""
    @Published
    var choice1 = ""
    @Published
    var choice2 = ""
    @Published
    var choice3 = ""
    @Published
    var choice4 = ""
    @Published
    var choiceCorrect = ""
    @Published
    var releaseDate = Date.now
    @Published
    var erroStr=""
    @Published
    var suerPop = false
    @Published
    var goList = false
    init(courseId: String) {
        self.courseId = courseId
    }
    init(questionModel: QuestionDetail) {
        self.questionModel = questionModel
        courseId = questionModel.courseID
    }
    @MainActor
    func requestData() {
        if let questionModel {
            questionTitle = questionModel.questionTitle
            questioContent = questionModel.question
            choice1 = questionModel.choice1
            choice2 = questionModel.choice2
            choice3 = questionModel.choice3
            choice4 = questionModel.choice4
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            choiceCorrect = questionModel.choiceCorrect
            releaseDate = dateFormatter.date(from: questionModel.releaseDate) ?? .now
        }
    }
    @MainActor
    func releaseBtnAction() {
        if  questionTitle.isEmpty{
            erroStr = "Sorry, please enter your question title first"
        }else if questioContent.isEmpty{
            erroStr = "Sorry, please enter your question title first"
        }else if(choice1.isEmpty || choice2.isEmpty ||
                 choice3.isEmpty || choice4.isEmpty){
            erroStr = "Sorry, please set all 4 choices first"
        } else if choiceCorrect.isEmpty {
            erroStr = "Sorry, please pick a correct choice"
        } else {
            questionModel?.questionTitle = questionTitle
            questionModel?.question = questioContent
            questionModel?.choice1 = choice1
            questionModel?.choice2 = choice2
            questionModel?.choice3 = choice3
            questionModel?.choice4 = choice4
            questionModel?.choiceCorrect = choiceCorrect
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            questionModel?.releaseDate = dateFormatter.string(from: releaseDate)
            suerPop = true
        }
    }

}
struct EditQuestionView: View {
    @StateObject
    var viewModel: EditQuestionViewModel
    var body: some View {
        
        Form {
            Section {
                TextField("Please enter the question here", text: $viewModel.questionTitle)
            }
            Section {
                ZStack(alignment: .topLeading) {
                    if viewModel.questioContent.isEmpty {
                        Text("Please enter the question here")
                            .padding(.top, 8)
                            .padding(.leading,4)
                            .foregroundColor(Color.gray)
                    }
                    TextEditor(text: $viewModel.questioContent)
                        .background(.clear)
                }
                .frame(height: 100)
                
            }
            Section {
                ForEach(0..<4) { index in
                    choiceItemView(index)
                }
            }
            DatePicker("", selection: $viewModel.releaseDate)
                .labelsHidden()
            Button {
                viewModel.releaseBtnAction()
            } label: {
                Text("Release")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            
        }
        .formStyle(.grouped)
        .task {
            viewModel.requestData()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                viewModel.goList = true
            } label: {
                Text("reuse previous questions")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
        }
        .navigationDestination(isPresented: $viewModel.goList, destination: {
            QuestionsListView(viewModel: .init(courseId: viewModel.courseId))
            
        })
        .popup(isPresented: .init(get: {
            !viewModel.erroStr.isEmpty
        }, set: { _ in
            viewModel.erroStr = ""
        })) {
            errorView
        } customize: {
            $0.closeOnTapOutside(false)
                .closeOnTap(false)
        }
        .popup(isPresented: $viewModel.suerPop) {
            surePopView
        } customize: {
            $0.closeOnTapOutside(false)
                .closeOnTap(false)
        }


    }
    @ViewBuilder
    var surePopView: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        let str = "Are you sure to set the release date to \n" + dateFormatter.string(from: viewModel.releaseDate) + " EST?"
        return VStack {
            Text(str)
                .padding(.top, 20)
            HStack {
                Button {
                    viewModel.suerPop = false
                } label: {
                    Text("No")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue)
                .clipShape(Capsule())
                Button {
                    
                    Task {
                        _ = await viewModel.questionModel?.changeQuestion()
                        viewModel.questionTitle = ""
                        viewModel.questioContent = ""
                        viewModel.choiceCorrect = ""
                        viewModel.choice1 = ""
                        viewModel.choice2 = ""
                        viewModel.choice3 = ""
                        viewModel.choice4 = ""
                        viewModel.suerPop = false
                    }
                    
                } label: {
                    Text("Yes")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue)
                .clipShape(Capsule())
               
            }
            .padding(.bottom,20)
            .padding(.top,30)
            
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.yellow)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    var errorView: some View {
        VStack {
            Text(viewModel.erroStr)
                .padding(.top, 20)
            Button {
                viewModel.erroStr = ""
            } label: {
                Text("Back")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 20)
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
        let indexStr = "\(index + 1)"
        let isSelect = viewModel.choiceCorrect == indexStr
        HStack {
            Button {
                viewModel.choiceCorrect = indexStr
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
            TextField("", text: getChoiceStr(index))
        }
    }
    
    func getChoiceStr(_ index: Int) -> Binding<String>{
        switch index {
        case 0:
            return $viewModel.choice1
        case 1:
            return $viewModel.choice2
        case 2:
            return $viewModel.choice3
        case 3:
            return $viewModel.choice4
        default:
            return .constant("")
            
        }
    }
}
