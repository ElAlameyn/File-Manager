//
//  CurrentAccountViewModel.swift
//  File_Manager
//
//  Created by Артем Калинкин on 22.03.2022.
//

import Combine
import UIKit

final class CurrentAccountViewModel {
  var subject = CurrentValueSubject<CurrentAccountResponse?, APIError>(nil)
  var cancellables = Set<AnyCancellable>()
}
