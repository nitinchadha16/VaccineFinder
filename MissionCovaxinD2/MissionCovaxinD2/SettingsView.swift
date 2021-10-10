//
//  SettingsView.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 05/06/21.
//

import SwiftUI

enum Filters : String, CaseIterable {
    case isAge18 = "Age 18+"
    case isAge45 = "Age 45+"
    case isFree = "Free"
    case isPaid = "Paid"
    case isCovaxin = "Covaxin"
    case isCovishield = "Covishield"
    case isBellOff = "Notification Off"
    case isBellOn = "Notification On"
    case isSirenOff = "Siren Off"
    case isSirenOn = "Siren On"
    case timer10 = "Timer 10s"
    case timer15 = "Timer 15s"
    case timer45 = "Timer 45s"
    case timer30 = "Timer 30s"
    case timer60 = "Timer 60s"
    case timer90 = "Timer 90s"
    case dose1Available = "Dose 1 Available"
    case dose2Available = "Dose 2 Available"
    case alarmFor10Only = "Siren >10"
    case alarmFor50Only = "Siren >50"
    case alarmFor100Only = "Siren >100"
    case alarmFor200Only = "Siren >200"
    case notification20Only = "Notification >20"
    case notification50Only = "Notification >50"
    case notification100Only = "Notification >100"
    case notification200Only = "Notification >200"
    case keepRecursive = "Api Refresh"
    case keepRecursiveOff = "Api Refresh Off"
    
    func getTitle() -> String {
        switch self {
        case .isAge18: return "Age 18+"
        case .isAge45: return "Age 45+"
        case .isFree: return "Free"
        case .isPaid: return "Paid"
        case .isCovaxin: return "Covaxin"
        case .isCovishield: return "Covishield"
        case .isBellOff: return "Off"
        case .isBellOn: return "On"
        case .isSirenOff: return "Off"
        case .isSirenOn: return "On"
        case .timer10: return "10s"
        case .timer15: return "15s"
        case .timer45: return "45s"
        case .timer30: return "30s"
        case .timer60: return "60s"
        case .timer90: return "90s"
        case .dose1Available: return "Dose 1"
        case .dose2Available: return "Dose 2"
        case .alarmFor10Only: return ">10"
        case .alarmFor50Only: return ">50"
        case .alarmFor100Only: return ">100"
        case .alarmFor200Only: return ">200"
        case .notification20Only: return ">20"
        case .notification50Only: return ">50"
        case .notification100Only: return ">100"
        case .notification200Only: return ">200"
        case .keepRecursive: return "On"
        case .keepRecursiveOff: return "Off"
        }
    }
}

struct SettingsView: View {
    
    @Binding var filters: [Filters]
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .padding()
        .padding(.top, 30)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Filters.allCases, id: \.self) { platform in
                self.item(for: platform)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if platform.rawValue == Filters.allCases.last!.rawValue {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if platform.rawValue == Filters.allCases.last!.rawValue {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for text: Filters) -> some View {
        
        let isSelected = filters.contains(text)
        
        return ButtonView(isSelected: isSelected, title: text.rawValue) {
            if filters.contains(text) {
                filters = filters.filter({ $0.rawValue != text.rawValue })
            } else {
                filters.append(text)
            }
            UserDefaults.standard.setValue(filters.map({$0.rawValue}), forKey: "Filters")
            UserDefaults.standard.synchronize()
        }
    }
}


struct SmallButtonView: View {
    
    @Binding var appliedFilters: [Filters]
    @State var filter: Filters
    @State var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }, label: {
            Text(filter.getTitle())
        })
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(appliedFilters.contains(filter) ? Color(hex: "80ffdb") : Color(hex:"003049"))
        .foregroundColor(appliedFilters.contains(filter) ? Color.black : Color.white)
        .cornerRadius(5.0)
        .border(appliedFilters.contains(filter) ? .black : Color.blue)
    }
}

struct ButtonView: View {
    
    @State var isSelected: Bool
    @State var title: String
    @State var onTap: () -> Void
    
    var body: some View {
        return Button(title) {
            onTap()
            isSelected.toggle()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(isSelected ? Color(hex: "80ffdb") : Color(hex:"003049"))
        .foregroundColor(isSelected ? Color.black : Color.white)
        .cornerRadius(3.0)
        .border(isSelected ? .clear : Color.blue)
    }
}

struct NewSettingsView_Previews: PreviewProvider {
    @State static var value = false
    @State static var filters = [Filters.alarmFor100Only]
    static var previews: some View {
        NewSettingsView(presentingModel: $value, appliedFilters: $filters)
    }
}

public struct FilterRow: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var title: String
    @State var filters: [[Filters]]
    @Binding var appliedFilters: [Filters]
    @State var isMultiSelect: Bool = false
    @State var canDeselected: Bool = false
    @State var breakAt: Int = -1
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.title3)
            Spacer()
            VStack {
                ForEach(filters, id: \.self) { filterGroup in
                    HStack {
                        ForEach(filterGroup, id: \.self) { filter in
                            SmallButtonView(appliedFilters: $appliedFilters, filter: filter) {
                                updateFilter(selectedFilter: filter)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke( colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
        )
    }
    
    func updateFilter(selectedFilter: Filters) {
        if isMultiSelect {
            if appliedFilters.contains(selectedFilter) {
                appliedFilters = appliedFilters.filter { $0 != selectedFilter }
            } else {
                appliedFilters.append(selectedFilter)
            }
        } else {
            for i in 0..<filters.count {
                for item in filters[i] {
                    appliedFilters = appliedFilters.filter( { $0 != item })
                }
            }
            appliedFilters.append(selectedFilter)
        }
    }
}

struct NewSettingsView: View {
    
    @Binding var presentingModel: Bool
    @Binding var appliedFilters: [Filters]
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .padding()
                    .padding(.top, 10)
                Spacer()
                Button("Done") {
                    presentingModel = false
                }
            }
        ScrollView(showsIndicators: false) {
                VStack {
                FilterRow(title: "Age", filters: [[.isAge18, .isAge45]], appliedFilters: $appliedFilters, isMultiSelect: true)
                FilterRow(title: "Vaccine", filters: [[.isCovaxin, .isCovishield]], appliedFilters: $appliedFilters, isMultiSelect: true)
                FilterRow(title: "Dose Availablity", filters: [[.dose1Available, .dose2Available]], appliedFilters: $appliedFilters, isMultiSelect: true)
                FilterRow(title: "Type", filters: [[.isFree, .isPaid]], appliedFilters: $appliedFilters, isMultiSelect: true)
                FilterRow(title: "Alarm", filters: [[.isSirenOff, .isSirenOn]], appliedFilters: $appliedFilters, isMultiSelect: false)
                FilterRow(title: "Notification", filters: [[.isBellOff, .isBellOn]], appliedFilters: $appliedFilters, isMultiSelect: false)
                FilterRow(title: "Auto Refresh", filters: [[.keepRecursiveOff, .keepRecursive]], appliedFilters: $appliedFilters, isMultiSelect: false)
                FilterRow(title: "Refresh Timeout", filters: [[.timer10, .timer15, .timer30], [.timer45, .timer60, .timer90]], appliedFilters: $appliedFilters, isMultiSelect: false)
                FilterRow(title: "Alarm on \nMinimum Vaccine", filters: [[.alarmFor10Only, .alarmFor50Only], [.alarmFor100Only, .alarmFor200Only]], appliedFilters: $appliedFilters, isMultiSelect: false, canDeselected: true)
                }
                VStack {
                    FilterRow(title: "Notification on \nMinimum Vaccine", filters: [[.notification20Only, .notification50Only], [.notification100Only, .notification200Only]], appliedFilters: $appliedFilters, isMultiSelect: false, canDeselected: true)
                }
            }.padding(.horizontal, 10)
            
        }
    }
}


