//
//  URlRequest+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 13.03.2022.
//

import Foundation

extension URLRequest {
  mutating func set(token: String) {
    self.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  }

  mutating func set(contentType: ContentTypes) {
    self.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
  }

  mutating func setDropboxAPIArg(_ value: String) {
    self.setValue(value, forHTTPHeaderField: "Dropbox-API-Arg")
  }

  enum ContentTypes: String {
    case application_x_www_form_urlencoded = "application/x-www-form-urlencoded"
    case application_json = "application/json"
    case application_octet_stream = "application/octet-stream"
  }
}


