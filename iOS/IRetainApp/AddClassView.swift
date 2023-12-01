//
//  AddClassView.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI
import FirebaseMessaging
enum PermissionStatus {
    case nomarl
    case success
    case fail
    case aready
    var str: String {
        switch self {
        case .nomarl:
            return "Please enter your permission code"
        case .fail:
            return "Sorry, Your permission code is wrong"
        case .success:
            return "You have successfully added the class"
        case .aready:
            return "You already added this class ealier"
        }
    }
}
class AddClaseeViewModel: ObservableObject {
//    var courses = ["ECE560 Security", "ECE590 Algprithm", "ECE651 Software Engineering"]
    
    @Published
    var courses = [Course]()
    @Published
    var searchStr: String = ""
    @Published
    var selectCourse: Course?
    var allCourse = [Course]()
    var showAlert = false
    @Published
    var permissionCode = ""
    @Published
    var permissionStatus = PermissionStatus.nomarl
    @AppStorage("role") var role = 0
    @AppStorage("netID") var netID = ""
    @Published
    var showpermissionCodeView = false
    @Published
    var selectPermissionCode = ""
    
    @MainActor
    func fetchcourses() {
        let db = Firestore.firestore()
        courses = [Course]()

        let query = db.collection("courses")

        query.getDocuments { [self] querySnapshot, err in
            if let err = err {
                print("No documents")
                return
            } else {
                allCourse = querySnapshot?.documents.map { document in
                    let data = document.data()
                    let name = data["courseName"] as? String ?? ""
                    let id = data["courseID"] as? String ?? ""
                    return Course(CourseName: name, CourseID: id, EnrolledYear: 0)
                } ?? []
                
                courses = allCourse
            }
        }
    }

    func searchBar() {
        courses = allCourse.filter { $0.CourseID.lowercased().prefix(searchStr.count) == searchStr.lowercased() }
    }
    @MainActor
    func checkifclassadded() {
        guard let selectCourse else {
            return
        }
        let db = Firestore.firestore()
        let query = db.collection(role == 0 ? "courses_add" : "student_courses_add").whereField("netID", isEqualTo: netID).whereField("courseID", isEqualTo: selectCourse.CourseID).limit(to: 1)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                } else {
                    var isAready = false
                    if let querySnapshot {
                        
                        for document in querySnapshot.documents {
                            if(document.exists){
                                selectPermissionCode = document.data()["permission_code"] as? String ?? ""
                                isAready = true
                            }
                            
                        }
                        
                    }
                    addaaa(isAready)
                        
                    
                }
                
            }

    }
    func getpermissioncode() {
        let db = Firestore.firestore()
        let query = db.collection("courses_add").whereField("courseID", isEqualTo: selectCourse?.CourseID ?? "").limit(to: 1)
        query.getDocuments { [self](querySnapshot, error) in
                if error != nil {
                    print("Document Error: ", error!)
                    permissionStatus = .fail
                } else {
                    if let querySnapshot {
                        for document in querySnapshot.documents {
                            if(document.exists){
                                print("document exists")
                                let documentID = document.documentID
                                let data = document.data()
                                let permissioncode = data["permission_code"] as? String ?? ""
                                let totalcount = (data["total_count"] as? Int)!
                                if self.permissionCode == permissioncode {
                                    db.collection("courses_add").document(documentID).updateData(["total_count": totalcount+1])
                                }
                                let docData: [String: Any] = [
                                    "netID": netID,
                                    "courseName": selectCourse?.CourseName ?? "",
                                    "courseID": selectCourse?.CourseID ?? "",
                                    "role": 1,
                                    "enrolled_year": Calendar.current.component(.year, from: Date()),
                                ]
                                let docRef = db.collection("student_courses_add").document()
                                docRef.setData(docData) { error in
                                    if let error = error {
                                        print("Error writing document: \(error)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                                }
                                if let courseID = selectCourse?.CourseID {
                                    let topic = "\(courseID)"
                                    Messaging.messaging().subscribe(toTopic: topic) { error in
                                        if let error = error {
                                            print("Error subscribing to topic: \(topic), error: \(error)")
                                        } else {
                                            print("Subscribed to topic: \(topic)")
                                        }
                                    }
                                }
                                permissionStatus = .success
                            } else {
                                permissionStatus = .fail
                            }
                            
                        }
                    } else {
                        permissionStatus = .fail
                    }
                    
                }
                
            }
    }
    func addaaa(_ alreadyadd: Bool) {
        
        let db = Firestore.firestore()
        if !alreadyadd {
            if role == 0 {
                let permissionCode = self.getRandomStringWithNum()
                let docData: [String: Any] = [
                    "netID": self.netID,
                    "courseID": selectCourse?.CourseID ?? "",
                    "courseName": selectCourse?.CourseName ?? "",
                    "role": role,
                    "total_count": 0,
                    "permission_code": permissionCode,
                    "enrolled_year": Calendar.current.component(.year, from: Date()),
                ]
                
                let docRef = db.collection("courses_add").document()
                
                docRef.setData(docData) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                permissionStatus = .success
            } else {
                permissionStatus = .nomarl
            }
            
        } else {

            permissionStatus = .nomarl
        }
        showpermissionCodeView = true
    }
    

    func getRandomStringWithNum() -> String {
        var string = ""
        var i = 0
        while i < 6 {
            i += 1
            let number = arc4random() % 36
            if number < 10 {
                let figure = arc4random() % 10
                let tempString = String(figure)
                string = string + tempString
            } else {
                let figure = (arc4random() % 26) + 97
                let character = Character(UnicodeScalar(figure)!)
                let tempString = String(character)
                string = string + tempString
            }
        }
        return string
    }
}

struct AddClassView: View {
    @Environment(\.dismiss) var dimiss
    @StateObject
    var viewModel = AddClaseeViewModel()
    @EnvironmentObject
    var contentModel: ContentViewModel
    var body: some View {
        VStack {
            SearchBarView
            ScrollView {
                ForEach(viewModel.courses, id: \.CourseID) { course in
                    VStack(alignment: .leading) {
                        Text(course.CourseName)
                        Text(course.CourseID)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 44)
                    .padding(.horizontal)
                    .contentShape(Rectangle())
                    .id(course.CourseID)
                    .onTapGesture {
                        viewModel.showAlert = true
                        viewModel.selectCourse = course
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            viewModel.fetchcourses()
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(""), message: Text("Are you sure you want to add \(viewModel.selectCourse?.CourseID ?? "")?"), primaryButton: .default(Text("sure"), action: {
                viewModel.checkifclassadded()
                
            }), secondaryButton: .cancel())
        }
        .onChange(of: viewModel.searchStr, perform: { _ in
            viewModel.searchBar()
        })
        .sheet(isPresented: $viewModel.showpermissionCodeView) {
            permissionCodeView
        }
        .navigationTitle("Add Class")
    }

    private var SearchBarView: some View {
        TextField("", text: $viewModel.searchStr)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            )
            .padding(.horizontal, 10)
    }
    var permissionCodeView: some View {
        VStack {
            Text("iRetain")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 60)
            Text(viewModel.permissionStatus.str)
                .font(.body)
            if [PermissionStatus.success, PermissionStatus.aready].contains(viewModel.permissionStatus) ,viewModel.role == 0 {

                Text("Here is your permission code")
                    .padding(.top, 10)
                Text(viewModel.selectPermissionCode)
                    .padding(.top, 10)
            }
            if viewModel.permissionStatus == .nomarl,viewModel.role == 1 {
                TextField("", text: $viewModel.permissionCode)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 30)
                    .padding(.top, 50)
                Button {
                    viewModel.getpermissioncode()
                } label: {
                    Text("Submit")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(width: 200)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.top, 80)
            }
            if [PermissionStatus.success, PermissionStatus.aready].contains(viewModel.permissionStatus) {
                Button {
                    if viewModel.permissionStatus == .aready {
                        dimiss()
                    } else {
                        viewModel.showpermissionCodeView = false
                    }
                    
                    
                } label: {
                    Text("Sure")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(width: 200)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.top, 80)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        .background(Color.yellow)
    }
}

struct AddClassView_Previews: PreviewProvider {
    static var previews: some View {
        AddClassView()
            .environmentObject(ContentViewModel())
    }
}
