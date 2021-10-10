//
//  Model.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import Foundation

enum VaccineType: String {
    case covaxin = "COVAXIN"
    case covishield = "COVISHIELD"
    case none = ""
}

struct VaccineResponse: Codable {
    let sessions: [Session]
}

struct District {
    var id: Int
    var alarm: Bool
    
    init(_ id: Int, alarm: Bool = true) {
        self.id = id
        self.alarm = alarm
    }
}

// MARK: - Session
struct Session: Codable, Identifiable {
    var id = UUID()
    let centerID: Int
    let name, address, stateName, districtName: String
    let blockName: String
    let pincode: Int
    let from, to: String
    let lat, long: Int
    let feeType, sessionID, date: String
    let availableCapacityDose1, availableCapacityDose2, availableCapacity: Int
    let fee: String
    let minAgeLimit: Int
    let vaccine: String
    let slots: [String]
    var alarm: Bool = true
    
    static let example = Session(centerID: 0, name: "MAX MULTISPECIALITY CENTRE", address: "ArtoniMathura RoadNH 2Agra", stateName: "UP", districtName: "Agra", blockName: "", pincode: 110052, from: "", to: "", lat: 0, long: 0, feeType: "Free", sessionID: "", date: "", availableCapacityDose1: 10, availableCapacityDose2: 0, availableCapacity: 10, fee: "100", minAgeLimit: 18, vaccine: "COVISHIELD", slots: [String]())
    
    var vaccineType: VaccineType {
        return VaccineType(rawValue: vaccine) ?? .none
    }
    
    enum CodingKeys: String, CodingKey {
        case centerID = "center_id"
        case name, address
        case stateName = "state_name"
        case districtName = "district_name"
        case blockName = "block_name"
        case pincode, from, to, lat, long
        case feeType = "fee_type"
        case sessionID = "session_id"
        case date
        case availableCapacityDose1 = "available_capacity_dose1"
        case availableCapacityDose2 = "available_capacity_dose2"
        case availableCapacity = "available_capacity"
        case fee
        case minAgeLimit = "min_age_limit"
        case vaccine, slots
    }
}
