//
//  ViewModelProtocol.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Combine

protocol ViewModelProtocol {
  func fetch()
  var subscriber: AnyCancellable? { get }
}
