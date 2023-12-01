//
//  FeedBackView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
class FeedBackViewModel: ObservableObject {
    @Published
    var feedbacks = [String]()
    var courses = [String]()
    @Published
    var selectCourse: String?
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var isLoaded = false
    func getfeedbacks() {
        guard let selectCourse else{
            return
        }
        let courseID = selectCourse

        let db = Firestore.firestore()
        //self.statistics.append(Statistic(ID: "", ReleaseDate: "realease date", Total: "total", Participants: "participants", CorrectPercentage: "correct%"))
        let query = db.collection("courses_add").whereField("courseID", isEqualTo: courseID).whereField("netID", isEqualTo: netID)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    for document in querySnapshot!.documents {
                        if(document.exists){
                           
                            let data = document.data()
                            feedbacks = data["feedbacks"] as? [String] ?? []
                            print("feedbacks:\(self.feedbacks)")
                        }
                        
                                
                    }
                    
                }
                
        }
    }
    func requestData() {
        let db = Firestore.firestore()
        let query = db.collection("courses_add").whereField("netID", isEqualTo: netID)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    courses = querySnapshot?.documents.map {document in
                        let data = document.data()
                        return data["courseID"] as? String ?? ""
                        
                    } ?? []
                    isLoaded = true
                    selectCourse = courses.first
                    if !courses.isEmpty {
                        self.getfeedbacks()
                    }
                        
                }
                
        }
    }
}
struct FeedBackView: View {
    @StateObject
    var viewModel = FeedBackViewModel()
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
                        Text("Please select the class you want to View")
                            
                        
                        Picker(viewModel.selectCourse ?? "", selection: $selectStr) {
                            ForEach(viewModel.courses,id: \.self) { item in
                                Text(item)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectStr) { newValue in
                            viewModel.selectCourse = selectStr
                            viewModel.getfeedbacks()
                        }
                        Text("Here are the feedbacks")
                    }
                    .padding(.top, 10)
                    
                    List {
                        ForEach(viewModel.feedbacks,id: \.self) { item in
                            VStack(alignment: .leading) {
                                Text(item)
                            }
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .frame(minHeight: 44)
                        }
                        .padding(.horizontal, 20)
                    }
                    .listStyle(.plain)
                    
                }
            } else {
                Rectangle()
                    .fill(Color.clear)
            }
            
            
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            viewModel.requestData()
        }
        
    }
}

struct FeedBackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedBackView()
    }
}
