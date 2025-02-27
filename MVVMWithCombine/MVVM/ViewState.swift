//
//  ViewState.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import Foundation

struct ViewState: Equatable {

  private(set) var apps = [AppStoreApp]()
  private(set) var markList = [Int: Bool]()
  
  func isMarked(with trackId: Int) -> Bool {
    guard let result = markList[trackId] else {
      return false
    }
    return result
  }
  
  mutating func reloadApps(_ apps: [AppStoreApp]) {
    self.apps = apps
  }
  
  mutating func toggleMarked(by trackId: Int) {
    markList[trackId] = !(markList[trackId] ?? false)
  }
  
}
