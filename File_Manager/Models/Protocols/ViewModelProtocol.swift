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
  var value: T { get }
  var subscriber: AnyCancellable? { get }
  
  func fetch()
}



