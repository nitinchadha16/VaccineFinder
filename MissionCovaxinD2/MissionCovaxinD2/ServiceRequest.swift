//
//  ServiceRequest.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import Foundation

class ServiceRequest {
    
    static let sharedInstance = ServiceRequest()
    
    func fetchVaccineDetails(districtId: Int, date: String, completion: @escaping ([Session]) -> (Void)) {
        
        guard let url = URL(string: "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=\(districtId)&date=\(date)") else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let _ = self, let data = data else {
                print("SOMETHING WENT WRONG")
                return
            }
            
            do {
                let responseModel = try JSONDecoder().decode(VaccineResponse.self, from: data)
                completion(responseModel.sessions)
            } catch {
                print("SOMETHING WENT WRONG")
            }
        }.resume()
    }
}
