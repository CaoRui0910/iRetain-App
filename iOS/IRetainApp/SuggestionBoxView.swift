//
//  SuggestionBoxView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
class SuggestionBoxViewModel: ObservableObject {
    @Published
    var feedbacks = [String]()
    var courses = [String]()
    @Published
    var selectCourse: String?
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var isLoaded = false
    @Published
    var textStr = ""
    var showAlert = false
    func requestData() {
        let db = Firestore.firestore()
        let query = db.collection("student_courses_add").whereField("netID", isEqualTo: netID)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    courses = []
                    for document in querySnapshot!.documents {
                        if(document.exists){
                           
                            let data = document.data()
                            let courseID = data["courseID"] as? String ?? ""
                            
                            self.courses.append(courseID)

                            
                        }
                                
                    }
                    isLoaded = true
                    selectCourse = courses.first
                        
                }
                
        }
    }
    func insertfeedback() {
        let db = Firestore.firestore()
        let query = db.collection("courses_add").whereField("courseID", isEqualTo: selectCourse ?? "").limit(to: 1)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    
                        for document in querySnapshot!.documents {
                            if(document.exists){
                                document.reference.updateData(["feedbacks": FieldValue.arrayUnion([textStr])])

                                textStr = ""
                                showAlert = true
                            }
                            
                        }

                    
                }
                
            }
    }
}

struct SuggestionBoxView: View {
    @StateObject
    var viewModel = SuggestionBoxViewModel()
    @State
    var selectStr = ""
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoaded {
                if viewModel.courses.isEmpty{
                    Text("Please add class first")
                        .frame(maxHeight: .infinity)
                } else {
                    Group {
                        Text("Please select the class to give feedback")
                            
                        
                        Picker(viewModel.selectCourse ?? "", selection: $selectStr) {
                            ForEach(viewModel.courses,id: \.self) { item in
                                Text(item)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectStr) { newValue in
                            viewModel.selectCourse = selectStr
                        }
                        Text("Here are the feedbacks")
                    }
                    .padding(.top, 10)
                    
                    TextEditor(text: $viewModel.textStr)
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                        .padding(.top, 40)
                    
                    Spacer()
                    Button {
                        viewModel.insertfeedback()
                    } label: {
                         Text("Submit")
                            .frame(width: 200, height: 44)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 40)
                }
            } else {
                Rectangle()
                    .fill(Color.clear)
            }
            
            
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(Color(uiColor: .lightGray))
        .onAppear {
            viewModel.requestData()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("submit successfully"))
        }
        
    }
}

struct SuggestionBoxView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionBoxView()
    }
}
