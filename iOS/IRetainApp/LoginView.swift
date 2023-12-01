//
//  LoginView.swift
//  IRetainApp
//
//  Created by Kaiburu Sinn on 2023/10/25.
//

import AppAuth
import SwiftUI

let kIssuer: String = "https://oauth.oit.duke.edu/oidc/"

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void

/**
 The OAuth client ID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
 */
let kClientID: String? = "20220711"

/**
 The OAuth redirect URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 */
let kRedirectURI: String = "nudge://oauth/callback"

/**
 NSCoding key for the authState property.
 */
let kAppAuthExampleAuthStateKey: String = "authState"

class LoginViewModel: NSObject, ObservableObject {
    var appDelegate: AppDelegate?
    @AppStorage("role")  var role = 0
    @AppStorage("netID")  var netID = ""
    private var authState: OIDAuthState?
    @Published
    var isPresent: Bool = false
    func setAuthState(_ authState: OIDAuthState?) {
        if self.authState == authState {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.stateChanged()
    }

    func stateChanged() {
        self.saveState()
    }

    func saveState() {
        var data: Data?

        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }

        if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
            userDefaults.set(data, forKey: kAppAuthExampleAuthStateKey)
            userDefaults.synchronize()
        }
    }

    func loadState() {
        guard let data = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }

        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
        }
    }

    func loginAction() {
        guard let issuer = URL(string: kIssuer) else {
            return
        }

        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, _ in

            guard let config = configuration else {
                self.setAuthState(nil)
                return
            }

            if let clientId = kClientID {
                let clientSecret = "ZDMXVGD_6SU9VgraxYKCX7nwrDdKVnZHy5U9AH6lqU9upjWIOMjdd51rvbklI8k-s7lqpU0bvvltHKccdOWNFg"
                self.doAuthWithAutoCodeExchange(configuration: config, clientID: clientId, clientSecret: clientSecret)
            } else {
                self.doClientRegistration(configuration: config) { configuration, response in

                    guard let configuration = configuration, let clientID = response?.clientID else {
                        return
                    }

                    self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                    clientID: clientID,
                                                    clientSecret: response?.clientSecret)
                }
            }
        }
    }

    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, clientID: String, clientSecret: String?) {
        guard let redirectURI = URL(string: kRedirectURI) else {
            return
        }

        guard let appDelegate else {
            return
        }

        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile],
                                              redirectURL: redirectURI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        // performs authentication request
        DispatchQueue.main.async {
            if let vc = UIApplication.shared.windows.first?.rootViewController {
                appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: vc) { authState, _ in

                    if let authState = authState {
                        self.setAuthState(authState)
                        self.userinfo()
                    } else {
                        self.setAuthState(nil)
                    }
                }
            }
        }

        // self.userinfo()
    }

    func userinfo() {
        guard let userinfoEndpoint = self.authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint else {
            return
        }

        let currentAccessToken: String? = self.authState?.lastTokenResponse?.accessToken

        self.authState?.performAction { accessToken, _, error in

            if error != nil {
                return
            }

            guard let accessToken = accessToken else {
                return
            }

            if currentAccessToken != accessToken {
            } else {}

            var urlRequest = URLRequest(url: userinfoEndpoint)
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]

            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

                DispatchQueue.main.async { [self] in
                    guard error == nil else {
                        return
                    }

                    guard let response = response as? HTTPURLResponse else {
                        return
                    }

                    guard let data = data else {
                        return
                    }

                    var json: [AnyHashable: Any]?

                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    } catch {}

                    if response.statusCode != 200 {
                        // server replied with an error
                        let responseText: String? = String(data: data, encoding: String.Encoding.utf8)
                        if response.statusCode == 401 {
                            // "401 Unauthorized" generally indicates there is an issue with the authorization
                            // grant. Puts OIDAuthState into an error state.
                            let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0,
                                                                                                errorResponse: json,
                                                                                                underlyingError: error)
                            self.authState?.update(withAuthorizationError: oauthError)
                        } else {}

                        return
                    }

                    if let json = json {
                        netID = json["dukeNetID"] as? String ?? ""
                        let affiliation = json["dukePrimaryAffiliation"] as? String
                        if affiliation == "student" {
                            role = 1
                        }
                        let defaults = UserDefaults.standard
                        defaults.set(netID, forKey: "netIDKey")
                        defaults.set(role, forKey: "roleKey")
//                        跳转
                        isPresent.toggle()
                    }
                }
            }

            task.resume()
        }
    }

    func doClientRegistration(configuration: OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        guard let redirectURI = URL(string: kRedirectURI) else {
            return
        }

        let request = OIDRegistrationRequest(configuration: configuration,
                                             redirectURIs: [redirectURI],
                                             responseTypes: nil,
                                             grantTypes: nil,
                                             subjectType: nil,
                                             tokenEndpointAuthMethod: "client_secret_post",
                                             additionalParameters: nil)

        // performs registration request

        OIDAuthorizationService.perform(request) { response, _ in

            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                callback(configuration, regResponse)
            } else {
                self.setAuthState(nil)
            }
        }
    }
}

extension LoginViewModel: OIDAuthStateChangeDelegate {
    func didChange(_ state: OIDAuthState) {
        self.stateChanged()
    }

    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {}
}

struct LoginView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var contentModel: ContentViewModel
    
    @StateObject
    var viewModel = LoginViewModel()
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to iRetain!")
                .font(.title)
            Image("note-taking")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
            Button {
                // teacher
//                viewModel.netID = "jp550"
//                viewModel.role = 0
                // student
                viewModel.netID = "xl340"
                viewModel.role = 1
                
                viewModel.isPresent.toggle()
            } label: {
                Text("Login with your Duke account")
                    .font(/*@START_MENU_TOKEN@*/ .body/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(.yellow)
                    .clipShape(Capsule())
                    .padding(.top, 200)
            }
        }
        .onAppear {
            viewModel.appDelegate = appDelegate
        }
        .onChange(of: viewModel.isPresent, perform: { _ in
            contentModel.showLogin = false
        })
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppDelegate())
            .environmentObject(ContentViewModel())
    }
}

