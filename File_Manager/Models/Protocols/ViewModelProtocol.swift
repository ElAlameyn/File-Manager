//
//  ViewModelProtocol.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Combine

protocol BaseProtocol: AnyObject{}

protocol ViewModelProtocol: BaseProtocol {
  associatedtype T: Hashable, Decodable
  
  func fetch()
  var subscriber: AnyCancellable? { get }
  var value: T { get }
}

