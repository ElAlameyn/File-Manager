//
//  DropboxURLs.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.02.2022.
//

import Foundation

extension AuthViewController {
  struct DropboxURL {
    static let authURL = "https://www.dropbox.com/oauth2/authorize?"
    static let clientID = "688rvrlb7upz9jb"
    static let clientSecret = "2zb3cvcxd9e7a2s"
    static let tokenURL = "https://api.dropboxapi.com/oauth2/token"
    static let redirectURI = "https://github.com"
  }
}
