//
//  Model.swift
//  MVVMWithCombine
//
//  Created by Felix Hu on 2025/2/27.
//

import Foundation

struct AppStoreSearchResponse: Codable {
  let resultCount: Int
  let results: [AppStoreApp]
}

struct AppStoreApp: Codable, Hashable {
  let trackId: Int
  let trackName: String
  let bundleId: String?
  let primaryGenreName: String?
  let averageUserRating: Double?
  let userRatingCount: Int?
  let version: String?
  let releaseNotes: String?
  let artworkUrl512: String?
  let trackViewUrl: String?
}
