//
//  QuestionsListView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/31.
//

import SwiftUI
import ExytePopupView
import FirebaseCore
import FirebaseFirestore
class QuestionsListViewModel: ObservableObject {
    let courseId: String
    @Published
    var array: [QuestionDetail] = []
    @Published
    var goDetail = false
    @Published
    var selectItem: QuestionDetail?
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var showDrop = false
    
    init(courseId: String) {
        self.courseId = courseId
    }
    @MainActor
    func requestData() async {
        array = await QuestionDetail.findQuestion(courseId,netID: role == 0 ? nil : netID)
    }
    @MainActor
    func dropAction(_ dismiss: DismissAction) {
        let db = Firestore.firestore()
        let query = db.collection("student_courses_add").whereField("courseID", isEqualTo: courseId).whereField("netID", isEqualTo: netID)
        query.getDocuments { (querySnapshot, error) in
            if error != nil {
            } else {
                
                if let document = querySnapshot?.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting course: \(error)")
                        }else {
                            DispatchQueue.main.async {
                                dismiss()
                            }
                            
                        }
                    }
                    
                }
            }
            
        }
    }
}

struct QuestionsListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject
    var viewModel:QuestionsListViewModel
    var body: some View {
        List{
            ForEach (viewModel.array,id:\.questionID){ item in
                VStack(alignment: .leading) {
                    Text(item.question)
                    Text(item.releaseDate)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.goDetail = true
                    viewModel.selectItem = item
                }
            }
            
        }
        .task {
            await viewModel.requestData()
        }
        .navigationTitle("View Questions")
        .onChange(of: viewModel.goDetail, perform: { newValue in
            if !newValue {
                viewModel.selectItem = nil
            }
        })
        .navigationDestination(isPresented:$viewModel.goDetail) {
            if let model = viewModel.selectItem {
                if viewModel.role == 0 {
                    EditQuestionView(viewModel: .init(questionModel: model))
                } else {
                    StudentQuestionView(viewModel: .init(question: model))
                }
                
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.role == 1 {
                Button {
                    viewModel.showDrop = true
                } label: {
                    Text("DROP CLASS")
                        .foregroundColor(.white)
                        .frame(width: 200,height: 44)
                        .background(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .popup(isPresented: $viewModel.showDrop) {
            dorpView
        } customize: { 
            $0.closeOnTapOutside(false)
                .closeOnTap(false)
        }

    }
    var dorpView: some View {
        VStack {
            Text("Do you really want to add " + viewModel.courseId + " ?")
                .padding(.top, 20)
            HStack {
                Button {
                    viewModel.showDrop = false
                } label: {
                    Text("No")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue)
                .clipShape(Capsule())
                Button {
                    viewModel.dropAction(dismiss)
                    viewModel.showDrop = false
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
}

struct QuestionsListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsListView(viewModel: .init(courseId: "ECE588"))
    }
}
