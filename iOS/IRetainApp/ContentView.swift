//
//  ContentView.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import SwiftUI
class ContentViewModel: ObservableObject {
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var showLogin = true
    @Published
    var showAddClass = true
    @Published
    var course: Course?
}

struct ContentView: View {
    @StateObject
    var viewModel = ContentViewModel()
    var body: some View {
        ZStack {
            if viewModel.showLogin {
                LoginView()
            } else {
                MainView()
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.showLogin = viewModel.netID.isEmpty  
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
