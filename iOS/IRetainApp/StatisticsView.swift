//
//  StatisticsView.swift
//  IRetainApp
//
//  Created by hyq on 2023/10/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
class StatisticsViewModel: ObservableObject {
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var courses = [String]()
    @Published
    var statistics = [Statistic]()
    @Published
    var totalcount = [Int]()
    @Published
    var isLoaded = false
    @Published
    var selectIndex = 0
    @MainActor
    func requestData() {
        let db = Firestore.firestore()
        let query = db.collection("courses_add").whereField("netID", isEqualTo: netID)
        query.getDocuments { [self] (querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    courses =  []
                    totalcount = []
                    for document in querySnapshot!.documents {
                        if(document.exists){
                           
                            let data = document.data()
                            let courseID = data["courseID"] as? String ?? ""
                            let totalcount = (data["total_count"] as? Int)!
                            self.courses.append(courseID)
                            self.totalcount.append(totalcount)
                            isLoaded = true
                            if !courses.isEmpty {
                                getquestionstat()
                            }
                        }
                                
                    }
                }
                
        }
    }
    func getquestionstat() {
        let courseID = self.courses[selectIndex]
        let totalcount = self.totalcount[selectIndex]
        self.statistics = [Statistic]()
        let db = Firestore.firestore()
        //self.statistics.append(Statistic(ID: "", ReleaseDate: "realease date", Total: "total", Participants: "participants", CorrectPercentage: "correct%"))
        let query = db.collection("questions").whereField("courseID", isEqualTo: courseID).whereField("teacher_netID", isEqualTo: netID)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    statistics = []
                    for document in querySnapshot!.documents {
                        if(document.exists){
                           
                            let data = document.data()
                            let ID = document.documentID
                            let rdate = data["release_date"] as? String ?? ""
                            let correctcount = (data["correct_count"] as? Int)!
                            let wrongcount = (data["wrong_count"] as? Int)!
                            let participants = correctcount + wrongcount
                            var percentage : String!
                            if(participants == 0){
                                percentage = "N/A"
                            }else{
                                
                                let p = Double(correctcount)/Double(participants)
                                percentage = String(p * 100) + "%"
                            }
                            
                            self.statistics.append(Statistic(ID: ID, ReleaseDate: rdate, Total: String(totalcount), Participants: String(participants), CorrectPercentage: percentage))
                            
                        }
                        
                                
                    }
                    
                }
                
        }
    }
}
struct StatisticsView: View {
    @StateObject
    var viewModel = StatisticsViewModel()
    @State
    var selectIndex = 0
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoaded {
                if viewModel.courses.isEmpty {
                    Text("Please add class first")
                        .frame(maxHeight: .infinity)
                } else {
                    Group {
                        Text("Please select the class you want to View")
                            
                        
                        Picker(viewModel.courses[viewModel.selectIndex] , selection: $selectIndex) {
                            ForEach(0..<viewModel.courses.count,id: \.self) { item in
                                Text(viewModel.courses[item])
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectIndex) { newValue in
                            viewModel.selectIndex = selectIndex
                            viewModel.getquestionstat()
                        }
                        Text("Here are the feedbacks")
                    }
                    .padding(.top, 10)
                    HStack {
                        Text("ReleaseDate")
                            .frame(width: 170,alignment: .leading)
                        Text("total")
                            .frame(width: 40,alignment: .center)
                        Text("participants")
                            .frame(width: 40,alignment: .center)
                        Text("correct%")
                            .frame(maxWidth: .infinity,alignment: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    ScrollView {
                        ForEach(0..<viewModel.statistics.count,id: \.self) { index in
                            let item = viewModel.statistics[index]
                            HStack {
                                Text(item.ReleaseDate)
                                    .frame(width: 170,alignment: .leading)
                                Text("\(item.Total)")
                                    .frame(width: 40,alignment: .center)
                                Text("\(item.Participants)")
                                    .frame(width: 40,alignment: .center)
                                Text(item.CorrectPercentage)
                                    .frame(maxWidth: .infinity,alignment: .center)
                            }
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .frame(minHeight: 44)
                        }
                        .padding(.horizontal, 20)
                    }
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

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
