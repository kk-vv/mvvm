//
//  Service.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import Combine
import Foundation

protocol AppStoreServiceType {
  func searchApp(term: String, country: String, limit: Int) -> AnyPublisher<[AppStoreApp], Error>
}

struct AppStoreService: AppStoreServiceType {
  
  private let baseURL = "https://itunes.apple.com/search"
  
  func searchApp(term: String, country: String = "us", limit: Int = 20) -> AnyPublisher<[AppStoreApp], Error> {
    guard let url = URL(string: "\(baseURL)?term=\(term)&media=software&country=\(country)&limit=\(limit)") else {
      return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    return URLSession.shared.dataTaskPublisher(for: url)
      .catch { error in
        return Fail(error: error)
      }
      .map { $0.data }
      .decode(type: AppStoreSearchResponse.self, decoder: JSONDecoder())
      .map { $0.results }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
