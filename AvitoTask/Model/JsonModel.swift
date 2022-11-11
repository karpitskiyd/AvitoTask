//
//  JsonModel.swift
//  AvitoTask
//
//  Created by Даниил Карпитский on 11/9/22.
//

import Foundation

struct RequestData: Codable {
    let company: Company
}

struct Company: Codable {
    let name: String
    let employees: [Employee]
}

struct Employee: Codable {
    let name, phoneNumber: String
    let skills: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case skills
    }
}

