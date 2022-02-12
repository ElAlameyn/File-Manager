//
//  FishOperator.swift
//  File_Manager
//
//  Created by Артем Калинкин on 06.02.2022.
//

import ImageIO

precedencegroup Fish {
  associativity: left
}

infix operator <>: Fish
  
func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}
