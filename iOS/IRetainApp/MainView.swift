//
//  MainView.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import SwiftUI
class MainViewModdel: ObservableObject {
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    @Published
    var currIndex = 0
    
}

struct MainView: View {
    @StateObject
    var viewModel = MainViewModdel()
    @EnvironmentObject
    var contentModel:ContentViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch viewModel.currIndex {
                case 0:
                    HomeView()
                case 1:
                    if viewModel.role == 0 {
                        FeedBackView()
                    } else {
                        SuggestionBoxView()
                    }
                    
                case 2:
                    StatisticsView()
                default:
                    Text("123")
                        .frame(maxHeight: .infinity)
                }
                toolBar
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle( navTile)
            .toolbar {
                if viewModel.currIndex == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            AddClassView()
                        } label: {
                            Text("Add Class")
                                .font(.body)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
            }
        }
        
    }
    var navTile: String {
        switch viewModel.currIndex {
        case 0:
            return "You Classes"
        case 1:
            if viewModel.role == 0 {
                return "Feedbacks"
            } else {
                return "Suggestion Box"
            }
            
        default:
            return ""
        }
    }

    private var toolBar: some View {
        HStack(alignment: .top,spacing: 0) {
            Button {
                viewModel.currIndex = 0
            } label: {
                VStack {
                    Image("tirenhuijianshiicon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.currIndex == 0 ? .white : .gray)
                        .frame(width: 30,height: 30)
                    Text("HomePage")
                        
                        .foregroundColor(viewModel.currIndex == 0 ? .blue : .white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
            if viewModel.role == 0 {
                Button {
                    viewModel.currIndex = 1
                } label: {
                    VStack(spacing: 0) {
                        Image("yewubanliicon")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30,height: 30)
                            .foregroundColor(viewModel.currIndex == 1 ? .white : .gray)
                        Text("FeedBack")
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                .foregroundColor(viewModel.currIndex == 1 ? .blue : .white)
                Button {
                    viewModel.currIndex = 2
                } label: {
                    VStack(spacing: 0) {
                        Image("a-waichuyuanyinicon1")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(viewModel.currIndex == 2 ? .white : .gray)
                            .frame(width: 30,height: 30)
                        Text("Statistics")
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .foregroundColor(viewModel.currIndex == 2 ? .blue : .white)
            } else {
                Button {
                    viewModel.currIndex = 1
                } label: {
                    VStack(spacing: 0) {
                        Image("dengjileixingicon")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(viewModel.currIndex == 1 ? .white : .gray)
                            .frame(width: 20,height: 20)
                        Text("Suggestion")
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .foregroundColor(viewModel.currIndex == 1 ? .blue : .white)
            }
            Button {
                contentModel.netID = ""
                contentModel.showLogin = true
            } label: {
                VStack(spacing: 0) {
                    Image("chusuoriqiicon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .frame(width: 30,height: 30)
                    Text("Logout")
                        
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        }
        .foregroundStyle(.white)
        .font(.system(size: 12))
        .padding(.horizontal, 20)
        .frame(height: 91)
        .background(Color(hex: "#030167"))
    }
}
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
