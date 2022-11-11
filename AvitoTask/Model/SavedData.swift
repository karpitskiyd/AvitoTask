//
//  SavedData.swift
//  AvitoTask
//
//  Created by Даниил Карпитский on 11/10/22.
//

import Foundation

struct SavedData: Codable {
    let time: String?
    let array: [Employee]
}
