//
//  CurrentAccountResponse.swift
//  File_Manager
//
//  Created by Артем Калинкин on 22.03.2022.
//

import Foundation

struct CurrentAccountResponse {
  let accountId: String
  let name: Name
  let email: String
  let profilePhotoURL: String?
  let referralLink: String

  enum CodingKeys: String, CodingKey {
    case accountId = "account_id"
    case name
    case email
    case profilePhotoURL = "profile_photo_url"
    case referralLink = "referral_link"
  }
}

extension CurrentAccountResponse {
  struct Name: Decodable & Hashable {
    let givenName: String
    let surname: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
      case givenName = "given_name"
      case surname
      case displayName = "display_name"
    }
  }
}

extension CurrentAccountResponse: Hashable & Decodable {
  static func == (lhs: CurrentAccountResponse, rhs: CurrentAccountResponse) -> Bool {
    lhs.name.displayName == rhs.name.displayName
  }
}

