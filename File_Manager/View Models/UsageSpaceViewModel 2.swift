//
//  UsageSpaceViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 15.02.2022.
//

import Foundation
import Combine

final class UsageSpaceViewModel: ObservableObject, ViewModelProtocol {
  var failedRequest: (() -> Void)?
  var cancellables = Set<AnyCancellable>()
  var subject = CurrentValueSubject<UsageSpaceResponse?, APIError>(nil)
}
