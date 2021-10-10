//
//  SearchOperation.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import Foundation


class SearchOperation: Operation {
    
    weak var delegate: ViewModel?
    var district: District!
    var date: String!
    
    private var state = State.ready
    
    private enum State {
        case ready
        case executing
        case finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        state = .executing
        
        ServiceRequest.sharedInstance.fetchVaccineDetails(districtId: district.id, date: "\(date!)") { [weak self] (sessions) in
            
            guard let self = self else { return }
            
            var items = [Session]()
            for item in sessions {
                var newItem = item
                newItem.alarm = self.district.alarm
                items.append(newItem)
                print("\(item.vaccine) : \(item.districtName) : \(item.name) : \(item.availableCapacityDose2) : \(item.date) : \(item.pincode)" )
            }
            self.delegate?.appendCenters(centers: items)
            self.willChangeValue(forKey: "isFinished")
            self.state = .finished
            self.didChangeValue(forKey: "isFinished")
        }
    }
}
