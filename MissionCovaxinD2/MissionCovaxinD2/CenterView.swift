//
//  CenterView.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import SwiftUI

struct CenterView: View {
    
    @State var center: Session
    
    var body: some View {
        VStack {
            HStack {
                Text(center.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "99d6ea"))
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                Spacer()
                Text(center.vaccine)
                    .font(.system(size: 13, weight: .bold))
            }
            HStack {
                Text(center.address)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "fffdf7"))
                    .padding(.top, 5)
                Spacer()
                Text(center.feeType == "Free" ? "Free" : "Rs \(center.fee)")
                    .font(.system(size: 13, weight: .regular))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color(hex: "43aa8b"))
                    .foregroundColor(.white)
                    .cornerRadius(3.0)
            }
            HStack {
                Text(verbatim: "\(center.pincode) : \(center.date)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: "fffdf7"))
                Spacer()
            }
            .padding(.top, 1)
            HStack {
                Text("Age \(center.minAgeLimit)+")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1a535c"))
                    .cornerRadius(3.0)
                    .padding(.top, 5)
                    
                Spacer()
                
                HStack {
                    Text("Dose 1")
                        .font(.system(size: 13, weight: .regular))
                    let color = center.availableCapacityDose1 > 0 ? Color(hex: "55a630") : Color.red
                    Text(verbatim: "\(center.availableCapacityDose1)")
                            .font(.system(size: 13, weight: .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(color)
                        .foregroundColor(Color.white)
                        .cornerRadius(5.0)
                }
                
                Spacer()
                
                HStack {
                    Text("Dose 2")
                        .font(.system(size: 13, weight: .regular))
                    let color = center.availableCapacityDose2 > 0 ? Color(hex: "55a630") : Color(hex: "ee4266")
                    Text(verbatim: "\(center.availableCapacityDose2)")
                            .font(.system(size: 13, weight: .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 2)
                            .background(color)
                        .foregroundColor(Color.white)
                        .cornerRadius(5.0)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct CenterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CenterView(center: Session.example)
        }
    }
}
