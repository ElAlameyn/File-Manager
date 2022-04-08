//
//  String+Extension.swift
//  File_Manager
//
//  Created by Артем Калинкин on 09.02.2022.
//

import Foundation

extension String {

  func fromBase64() -> String? {
      guard let data = Data(base64Encoded: self) else {
          return nil
      }
      return String(data: data, encoding: .utf8)
  }
  
  func toBase64() -> String {
      return Data(self.utf8).base64EncodedString()
  }
  
  func toDate(dateFormat: String) -> Date? {

     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = dateFormat

     let date: Date? = dateFormatter.date(from: self)
     return date
  }
  
  

}
