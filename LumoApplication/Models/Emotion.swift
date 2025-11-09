//
//  Emotion.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import Foundation
import SwiftUI

struct GridCoord: Codable, Hashable {
    let xIdx: Int
    let yIdx: Int
}

struct Emotion: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let coord: GridCoord
    let description: String?
    let vRaw: Double?
    let aRaw: Double?
}   
