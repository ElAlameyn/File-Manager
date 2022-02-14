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
  
  struct DropboxURL {
    static let authURL = "https://www.dropbox.com/oauth2/authorize?"
    static let clientID = "688rvrlb7upz9jb"
    static let redirectURI = "http://localhost"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.navigationDelegate = self
    view.addSubview(webView)
    let url = URL(string: DropboxURL.authURL +
                  "client_id=\(DropboxURL.clientID)" +
                  "&response_type=code" +
                  "&redirect_uri=\(DropboxURL.redirectURI)")
    webView.load(URLRequest(url: url!))
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    webView.frame = view.bounds
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    guard let url = webView.url else { return }
    print("CURRENT URL: \(url.absoluteString)")
    
    let components = URLComponents(string: url.absoluteString)
    guard let code = components?.queryItems?
            .first(where: {$0.name == "code"})?.value
    else { return }
    
    print("CODE ACESS TO DROPBOX: \(code)")
    
    guard let tokenRequest = createTokenRequest(code: code) else { return }
    subscriber = URLSession.shared.dataTaskPublisher  (
      for: tokenRequest)
      .map { $0.data }
      .decode(type: TokenResponse.self, decoder: JSONDecoder())
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
      .sink { completion in
        switch completion {
        case .finished:
          print("Token achieved")
        case .failure(let error):
          print("Error in token request due to: \(error.localizedDescription)")
        }
      } receiveValue: {[weak self] tokenResponse in
        print("ACESS TOKEN : \(tokenResponse.accessToken)")
        if let data = try? JSONEncoder().encode(tokenResponse) {
          KeychainSwift().set(data, forKey: "\(TokenResponse.self)", withAccess: .accessibleWhenUnlocked)
        }
       self?.dismiss(animated: true)
      }
  }
  
  private func createTokenRequest(code: String) -> URLRequest? {
    let responseConfig = ResponseConfig.token(code)
    guard let tokenURL = URL(string: responseConfig.configuredURL) else { return nil}
    var tokenRequest = URLRequest(url: tokenURL)
    tokenRequest.httpMethod = responseConfig.method.rawValue
    responseConfig.setHeaders(for: &tokenRequest)
    var requestComponents = URLComponents()
    requestComponents.queryItems = responseConfig.components?.compactMap({ (key, value) in
      URLQueryItem(name: key, value: value)
    })
    tokenRequest.httpBody = requestComponents.query?.data(using: .utf8)
    return tokenRequest
  }
 
}

