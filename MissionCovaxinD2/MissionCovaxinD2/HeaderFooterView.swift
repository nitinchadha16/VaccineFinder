//
//  HeaderFooterView.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 06/06/21.
//

import SwiftUI

struct GearView: View {
    
    @Binding var presentModel: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 25, height: 25, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .padding(.top, 20)
                    .onTapGesture {
                        presentModel = true
                    }
            }
            Spacer()
        }
    }
}

struct HeaderView: View {
    
    @Binding var shouldRefreshData: Bool
    @Binding var countView: String
    
    var body: some View {
        VStack {
            Button(action: {
                shouldRefreshData = true
            }, label: {
                Text("Search Vaccine")
                    .foregroundColor(.white)
                    .font(.body)
            })
            .padding()
            .font(.headline)
            .border(Color.white)
            
            
            Text("\(countView)")
                .padding(.vertical, 10)
                .padding(.horizontal)
                .foregroundColor(.white)
                .font(.system(.body))
                .multilineTextAlignment(.center)
        }
    }
}

struct FooterView: View {
    
    @Binding var clearScreen: Bool
    @Binding var siren: SirenState
    @Binding var apiTimer: Bool
    
    @Binding var nextApiCountDown: Int
    
    var body: some View {
        HStack {
            Button(action: {
                clearScreen = true
            }, label: {
                Text("Clear")
                    .foregroundColor(Color.white)
            })
            .padding()
            Spacer()
            
            Button(action: {
                siren.toggle()
            }, label: {
                Text("Siren")
                    .foregroundColor(Color.white)
            })
            Spacer()
            
            Text("\("Refresh in") \(nextApiCountDown)s")
                .font(.body)
                .foregroundColor(Color.white)
                .padding(10)
                .border(Color.white)
                .cornerRadius(2.0)
                .padding(10)
                .onTapGesture {
                    apiTimer.toggle()
                }
        }
    }
}
