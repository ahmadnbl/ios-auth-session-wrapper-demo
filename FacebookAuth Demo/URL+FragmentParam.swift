//
//  URL+FragmentParam.swift
//  FacebookAuth Demo
//
//  Created by Ahmad Nabili on 01/06/20.
//  Copyright © 2020 Ahmad Nabili. All rights reserved.
//

import Foundation

extension URL {

  func getFragmentParam(key: String) -> String? {
    if let params = self.fragment?.components(separatedBy: "&") {
      for param in params {
        if let value = param.components(separatedBy: "=") as [String]? {
          if value[0] == key {
            return value[1]
          }
        }
      }
    }
        
    return nil
  }

}
