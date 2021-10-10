//
//  ViewModel.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import Foundation

enum SirenState {
    case start
    case stop
    
    mutating func toggle() {
        if self == .start {
            self = .stop
        } else {
            self = .start
        }
    }
}

class ViewModel {
    
    var centersFound = [Session]()
    var filters = [Filters]()
    
    private init() {
        operationQueue.maxConcurrentOperationCount = 5
    }
    
    var districtIds: [District] {
        var ids = [District]()
        
        for id in 140..<151 {
            ids.append(District(id))
        }
        /*ids.append(District(622, alarm: false)) //AGRA
        ids.append(District(631, alarm: false)) //BAGHPAT
        ids.append(District(650)) //GAUTAM BUDH NAGAR
        ids.append(District(651)) //GHAZIABAD
        ids.append(District(652)) //Ghazipur
        ids.append(District(666)) //Kaushambi
        ids.append(District(193, alarm: false)) //AMBALA
        ids.append(District(199)) //FARIDABAD
        ids.append(District(188)) //GURGAON
        ids.append(District(191, alarm: false)) //HISAR
        
        ids.append(District(189, alarm: false)) //JHAJHAR
        ids.append(District(203, alarm: false)) //KARNAL
        ids.append(District(195, alarm: false)) //PANIPAT
        ids.append(District(192)) //ROHTAK
        ids.append(District(198)) //SONIPAT
        */
        return ids
    }
    
    
    private var operationQueue = OperationQueue()
    let serialQueue = DispatchQueue(label: "ABC")
    
    static var sharedInstance: ViewModel = {
        return ViewModel()
    }()
    
    func getDifferentDistrictName() -> [String] {
        var set = Set<String>()
        for item in centersFound {
            set.insert(item.districtName)
        }
        return Array(set).sorted()
    }
    
    func filterOnBasisOfDistrict(district: [String]) -> [Session] {
        guard district.isEmpty == false else {
            return centersFound
        }
        return centersFound.filter { district.contains($0.districtName) }
    }
    
    func searchVaccine() -> (String, [Session]) {
        operationQueue.cancelAllOperations()
        centersFound.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let startDate = dateFormatter.string(from: Date())
        
        for item in districtIds {
            for date in (Int(startDate)!) ..< ((Int(Int(startDate)!) + 3)) {
                let newOp = SearchOperation()
                newOp.delegate = self
                newOp.district = item
                newOp.date = "\(date)-06-2021"
                operationQueue.addOperation(newOp)
            }
        }
        operationQueue.waitUntilAllOperationsAreFinished()
        
        centersFound = filterResponse(response: centersFound)
        
        var string = ""
        
        let covishieldV = centersFound.filter({ $0.vaccineType == .covishield})
        let covaxV = centersFound.filter({ $0.vaccineType == .covaxin})
        
        string += "\(VaccineType.covishield.rawValue) : " + "\(covishieldV.count) | "
        string += "\(VaccineType.covaxin.rawValue) : " + "\(covaxV.count)"
        return (string, covaxV + covishieldV)
    }
    
    func appendCenters(centers: [Session]) {
        serialQueue.sync {
            centersFound.append(contentsOf: centers)
        }
    }
    
    func cancel() {
        centersFound.removeAll()
        operationQueue.cancelAllOperations()
    }
    
    func filterResponse(response: [Session]) -> [Session] {
        var items = response
        
        if filters.contains(.isAge18) != filters.contains(.isAge45) {
            if filters.contains(.isAge18) {
                items = items.filter({ $0.minAgeLimit == 18 })
            } else {
                items = items.filter({ $0.minAgeLimit == 45 })
            }
        }
        
        if filters.contains(.isFree) != filters.contains(.isPaid) {
            if filters.contains(.isFree) {
                items = items.filter({ $0.feeType == "Free" })
            } else {
                items = items.filter({ Int($0.fee) ?? 0 > 0 })
            }
        }
        
        if filters.contains(.isCovaxin) != filters.contains(.isCovishield) {
            if filters.contains(.isCovishield) {
                items = items.filter({ $0.vaccineType == .covishield })
            } else {
                items = items.filter({ $0.vaccineType == .covaxin })
            }
        }
        
        if filters.contains(.dose2Available) {
            items = items.filter({ $0.availableCapacityDose2 > 0 })
            
            var delhiCenters = items.filter{ $0.alarm == true }
            var ndelhiCenters = items.filter{ $0.alarm == false }
            
            delhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacityDose2 > session2.availableCapacityDose2
            }
            
            ndelhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacityDose2 > session2.availableCapacityDose2
            }
            
            items = delhiCenters + ndelhiCenters
            
        } else if filters.contains(.dose1Available) {
            items = items.filter({ $0.availableCapacityDose1 > 0 })
            
            var delhiCenters = items.filter{ $0.alarm == true }
            var ndelhiCenters = items.filter{ $0.alarm == false }
            
            delhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacityDose1 > session2.availableCapacityDose1
            }
            
            ndelhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacityDose1 > session2.availableCapacityDose1
            }
            
            items = delhiCenters + ndelhiCenters
            
        } else {
            items = items.filter({ $0.availableCapacity > 0 })
            
            var delhiCenters = items.filter{ $0.alarm == true }
            var ndelhiCenters = items.filter{ $0.alarm == false }
            
            delhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacity > session2.availableCapacity
            }
            
            ndelhiCenters.sort { (session1, session2) -> Bool in
                return session1.availableCapacity > session2.availableCapacity
            }
            
            items = delhiCenters + ndelhiCenters
        }
        
        return items
    }
}
