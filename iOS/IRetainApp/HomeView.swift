//
//  HomeView.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
class HomeViewModel: ObservableObject {
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var array: [Course] = []
    @Published
    var selectCourseId: String?
    @MainActor
    func fetchstudentcourses() {
        let db = Firestore.firestore()
        
        let query = db.collection(role == 0 ? "courses_add" : "student_courses_add").whereField("netID", isEqualTo: netID)
        query.getDocuments() {[self] (querySnapshot, err) in
            if let err = err {
                return
            }else{
                array = querySnapshot?.documents.map { document in
                    let data = document.data()
                    let name = data["courseName"] as? String ?? ""
                    let id = data["courseID"] as? String ?? ""
                    let year = (data["enrolled_year"] as? Int)!
                    return Course(CourseName: name, CourseID: id, EnrolledYear: year)
                } ?? []
            }
            
        }
        
    }
    
}
struct HomeView: View {
    @StateObject
    var viewModel = HomeViewModel()
    @EnvironmentObject var contentModel: ContentViewModel
    var body: some View {
        List {
            Section {
                ForEach(viewModel.array,id: \.CourseID) { course in
                    VStack(alignment: .leading) {
                        Text(course.CourseName)
                            .font(.title3)
                        Text("\(course.CourseID)")
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .frame(minHeight: 44)
                    .onTapGesture {
                        viewModel.selectCourseId = course.CourseID
                    }
                }
                .padding(.horizontal, 20)
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: .init(get: {
            viewModel.selectCourseId != nil
        }, set: { _ in
            viewModel.selectCourseId = nil
        }), destination: {
            if viewModel.role == 0 {
                EditQuestionView(viewModel: .init(courseId: viewModel.selectCourseId ?? ""))
            } else  {
                QuestionsListView(viewModel: .init(courseId: viewModel.selectCourseId ?? ""))
            }
            
        })
        .onAppear {
            viewModel.fetchstudentcourses()
        }
    }
    
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserDefaults.standard.set("rc384", forKey: "netID")
        UserDefaults.standard.set("0", forKey: "role")
        UserDefaults.standard.synchronize()
        return HomeView()
            .environmentObject(ContentViewModel())
    }
}
