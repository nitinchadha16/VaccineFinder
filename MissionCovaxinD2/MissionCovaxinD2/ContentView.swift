//
//  ContentView.swift
//  MissionCovaxinD2
//
//  Created by Nitin Chadha on 05/06/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State var countView: String = " - "
    @State var timeRemaining: Int = 30
    @State var player: AVAudioPlayer?
    
    @State var presentingModal = false
    @State var callApi = false
    @State var clearScreen: Bool = false {
        didSet {
            if self.clearScreen == true {
                clearData()
                clearScreen = false
            }
        }
    }
    @State var filers: [Filters]
    @State var districtNames: [String] = []
    @State var selectedDistrict : [String] = [String]()
    @State var filteredCenters: [Session] = []
    @State var sirenState: SirenState = SirenState.start
    
    let viewModel = ViewModel.sharedInstance
    
    @State var timer: Timer? = nil
    @State var isSirenPlaying: Bool = false
    @State var isApiTimerStopped: Bool = false
    
    var kRefreshTimeout: Int {
        return filers.contains(.timer10) ? 10 : (filers.contains(.timer15) ? 15 : ((filers.contains(.timer30) ? 30 : ((filers.contains(.timer45) ? 45 : ((filers.contains(.timer60) ? 60 : 90)))))))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: .topLeading, endPoint: .bottomTrailing)
            GearView(presentModel: self.$presentingModal)
            VStack {
                HeaderView(shouldRefreshData: self.$callApi, countView: $countView)
                if filteredCenters.isEmpty == false {
                    List(filteredCenters) { item in
                        CenterView(center: item)
                    }
                    .listRowBackground(Color.white)
                }
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.getDifferentDistrictName(), id: \.self) { district in
                                ButtonView(isSelected: selectedDistrict.contains(district), title: district) {
                                    if selectedDistrict.contains(district) == false {
                                        selectedDistrict.append(district)
                                    } else {
                                        selectedDistrict = selectedDistrict.filter { $0 != district }
                                    }
                                    filteredCenters = viewModel.filterOnBasisOfDistrict(district: selectedDistrict)
                                }
                                if district != viewModel.getDifferentDistrictName().last {
                                    Spacer()
                                }
                            }
                        }.padding(.horizontal, 20)
                    }
                
                
                
                FooterView(clearScreen: self.$clearScreen, siren: $sirenState, apiTimer: $isApiTimerStopped, nextApiCountDown: self.$timeRemaining)
            }
            .padding(.top, 60)
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            refreshData()
        })
        .sheet(isPresented: $presentingModal) { NewSettingsView(presentingModel: $presentingModal, appliedFilters: $filers) }
        .onChange(of: callApi) { (_) in
            if callApi {
                refreshData()
                self.callApi = false
            }
        }.onChange(of: isApiTimerStopped) { (_) in
            if isApiTimerStopped == true {
                stopTimer()
            }
        }.onChange(of: sirenState, perform: { value in
            if self.sirenState == .start {
                startSiren(force: true)
            } else {
                stopSiren()
            }
        })
    }
    
    func clearData() {
        filteredCenters.removeAll()
        countView = "-"
    }
    
    func refreshData() {
        clearData()
        stopSiren()
        stopTimer()
        countView = "Searching...."
        DispatchQueue.global().async {
            viewModel.filters = filers
            let (count, _) = viewModel.searchVaccine()
            DispatchQueue.main.async {
                countView = count
                selectedDistrict.removeAll()
                filteredCenters = viewModel.filterOnBasisOfDistrict(district: selectedDistrict)
                districtNames = viewModel.getDifferentDistrictName()
                
                if checkIfSirenRequired() == false, isApiTimerStopped == false {
                    stopTimer()
                    startTimer()
                } else {
                    if filers.contains(.keepRecursive) {
                        stopTimer()
                        startTimer()
                    }
                }
            }
        }
    }
    
    func getDosesCount(sessions: [Session], isDelhi: Bool = true) -> Int {
        let covax_centers = isDelhi ? sessions.filter({$0.alarm}) : sessions.filter({$0.alarm == false })
        let delhi_count = covax_centers.reduce(0) { (value, session) -> Int in
            if filers.contains(.dose1Available) != filers.contains(.dose2Available) {
                if filers.contains(.dose1Available) {
                    return (value > session.availableCapacityDose1 ? value : session.availableCapacityDose1)
                } else {
                    return (value > session.availableCapacityDose2 ? value : session.availableCapacityDose2)
                }
            } else {
                return (value > session.availableCapacity ? value : session.availableCapacity)
            }
        }
        return delhi_count
    }
    
    func checkIfSirenRequired() -> Bool {
        let covax_centers = viewModel.centersFound.filter({ $0.vaccineType == .covaxin})
        let delhi_count = getDosesCount(sessions: covax_centers)
        let n_delhi_count = getDosesCount(sessions: covax_centers, isDelhi: false)
        if covax_centers.isEmpty == false {
            let delhiCenters = covax_centers.filter({$0.alarm})
            if delhiCenters.count > 0 {
                isSirenPlaying = true
                startSiren(isShort: false, delhi_count: delhi_count, n_delhi_count: n_delhi_count)
                return true
            } else {
                startSiren(isShort: true, delhi_count: 0, n_delhi_count: n_delhi_count)
            }
        }
        return false
    }
    
    func startTimer() {
        
        if isApiTimerStopped {
            return
        }
        
        timeRemaining = kRefreshTimeout
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            print("Next Api in \(timeRemaining)")
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                refreshData()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = kRefreshTimeout
    }
    
    func startSiren(isShort: Bool = false, delhi_count: Int = -1, n_delhi_count: Int = -1, force: Bool = false) {
        stopSiren()
        
        if force == false {
        if isShort, filers.contains(.isBellOff) {
            return
        }
        
        if isShort == false, filers.contains(.isSirenOff) {
            return
        }
        
        var override = false
        if isShort == true && ( filers.contains(.notification20Only) ||
                                    filers.contains(.notification50Only) ||
                                    filers.contains(.notification100Only) ||
                                    filers.contains(.notification200Only)) {
            
            if (n_delhi_count > 19 && filers.contains(.notification20Only))
                || (n_delhi_count > 49 && filers.contains(.notification50Only))
                || (n_delhi_count > 99 && filers.contains(.notification100Only))
                || (n_delhi_count > 199 && filers.contains(.notification200Only)) {
                override = true
            } else {
                return
            }
        }
        
        
        if isShort == false && override == false && ( filers.contains(.alarmFor10Only) ||
                                                        filers.contains(.alarmFor50Only) ||
                                                        filers.contains(.alarmFor100Only) ||
                                                        filers.contains(.alarmFor200Only)) {
            
            if (delhi_count > 9 && filers.contains(.alarmFor10Only))
                || (delhi_count > 49 && filers.contains(.alarmFor50Only))
                || (delhi_count > 99 && filers.contains(.alarmFor100Only))
                || (delhi_count > 199 && filers.contains(.alarmFor200Only)) {
                
            } else {
                return
            }
        }
        }
        
        
        let fileName = isShort ? "bell_short" : "bell"
        if let path = Bundle.main.path(forResource: fileName, ofType: ".mp3") {
            
            self.player = AVAudioPlayer()
            let url = URL(fileURLWithPath: path)
            
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                if isShort == false {
                    self.player?.numberOfLoops = -1
                }
                self.player?.prepareToPlay()
                self.player?.play()
            }catch {
                print("Error")
            }
        }
    }
    
    func stopSiren() {
        self.player?.stop()
        self.player = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView( filers: [.isAge18])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
