//
//  AuthViewController.swift
//  File_Manager
//
//  Created by Артем Калинкин on 08.02.2022.
//

import UIKit
import WebKit
import Combine
import KeychainSwift

class AuthViewController: UIViewController, WKNavigationDelegate {
  
  private var webView = WKWebView()
  
  private var subscriber: AnyCancellable?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.navigationDelegate = self
    view.addSubview(webView)
    let url = URL(string: DropboxURL.authURL + "client_id=\(DropboxURL.clientID)" + "&response_type=code" + "&redirect_uri=\(DropboxURL.redirectURI)")
    webView.load(URLRequest(url: url!))
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    webView.frame = view.bounds
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    guard let url = webView.url else { return }
    let components = URLComponents(string: url.absoluteString)
    
    guard let code = components?.queryItems?
            .first(where: {$0.name == "code"})?.value,
      let tokenURL = URL(string: DropboxURL.tokenURL)
    else { return }
    
    print("CODE ACESS TO DROPBOX: \(code)")

    subscriber = URLSession.shared.dataTaskPublisher  (
      for: createTokenRequest(
        url: tokenURL,
        code: code,
        clientID: DropboxURL.clientID,
        clientSecret: DropboxURL.clientSecret,
        redirectURI: DropboxURL.redirectURI))
      .map { $0.data }
      .decode(type: TokenResponse.self, decoder: JSONDecoder())
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
      .sink { completion in
        switch completion {
        case .finished:
          print("Token achieved")
        case .failure(_):
          print("Error in token request")
        }
      } receiveValue: { tokenResponse in
        print("ACESS TOKEN : \(tokenResponse.accessToken)")
        if let data = try? JSONEncoder().encode(tokenResponse) {
          KeychainSwift().set(data, forKey: TokenResponse.key, withAccess: .accessibleWhenUnlocked)
        }
      }
  }
  
  private func createTokenRequest(url: URL,
                                  code: String,
                                  clientID: String,
                                  clientSecret: String,
                                  redirectURI: String? = nil
  ) -> URLRequest {
    var tokenRequest = URLRequest(url: url)
    tokenRequest.httpMethod = "POST"
    tokenRequest.setValue("Basic \("\(clientID):\(clientSecret)".toBase64())", forHTTPHeaderField: "Authorization")
    tokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var tokenRequestComponents = URLComponents()
    tokenRequestComponents.queryItems = [
      URLQueryItem(name: "grant_type", value: "authorization_code"),
      URLQueryItem(name: "code", value: code),
      URLQueryItem(name: "redirect_uri", value: redirectURI),
      // For PCKE extension
      //      URLQueryItem(name: "client_id", value: AuthViewController.Const.clientID),
      //      URLQueryItem(name: "code_verifier", value: code)
    ]
    
    tokenRequest.httpBody = tokenRequestComponents.query?.data(using: .utf8)
    return tokenRequest
  }
}

extension AuthViewController {
  
  private struct DropboxURL {
    static let authURL = "https://www.dropbox.com/oauth2/authorize?"
    static let clientID = "688rvrlb7upz9jb"
    static let clientSecret = "2zb3cvcxd9e7a2s"
    static let tokenURL = "https://api.dropboxapi.com/oauth2/token"
    static let redirectURI = "https://github.com"
  }
  
  struct TokenResponse: Codable {
    static let key = "dropbox_token_response"
    
    var date = Date()
    let accessToken: String
    let expiresIn: Int
    let refresh_token: String?
    let tokenType: String
    
    var isValid: Bool {
      Date().timeIntervalSince(date) < TimeInterval(expiresIn)
    }
  }
 
}
