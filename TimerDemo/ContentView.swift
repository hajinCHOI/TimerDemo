//
//  ContentView.swift
//  TimerDemo
//
//  Created by 최하진 on 1/24/25.
//

import SwiftUI
import AVFoundation

struct AlwaysOnTopView: NSViewRepresentable {
    let window: NSWindow
    let isAlwaysOnTop: Bool
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if isAlwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
}

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Bell1", withExtension: ".wav") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("재생하는데 오류가 발생했습니다. \(error.localizedDescription)")
        }
    }
}


struct ContentView: View {
    
    @Binding var isRunning: Bool
    @Binding var timeRemaining : Int
    @Binding var title : String
    @Binding var isSoundOn : Bool
    
    @State private var min : Int = 0
    @State private var sec : Int = 0
    
    @State private var isOnTop = true
    @State private var isSetting : Bool = false
    @State private var isFinished: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let soundManager = SoundManager.instance
    
    var body: some View {
        ZStack(alignment: .center){
            VStack{
                HStack {
                    Image(systemName: isRunning ? "door.left.hand.closed" : "door.left.hand.open" )
                        .resizable()
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            isRunning.toggle()
                            if isSetting { isSetting = false }
                            timeRemaining = min * 60 + sec
                        }
                    HStack {
                        if isSetting {
                            TextField("00", value: $min, formatter: NumberFormatter())
                                .frame(width: 25, height: 40)
                            Text(":")
                            TextField("00", value: $sec, formatter: NumberFormatter())
                                .frame(width: 25, height: 40)
                        }
                        else {
                            Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    autoSetting()
                                }
                        }
                        Image(systemName: "stopwatch.fill")
                            .onTapGesture {
                                isSetting.toggle()
                                timeRemaining = min * 60 + sec
                            }
                        Image(systemName: isSoundOn ? "speaker.wave.1.fill" : "speaker.slash.fill")
                            .onTapGesture {
                                isSoundOn.toggle()
                            }
                    }
                }
                if isSetting {
                    TextField("title", text: $title)
                } else {
                    Text("\(title)")
                        .font(.system(size: 15, weight: .bold))
                }
                
            }
        }
        .padding()
        .onChange(of: isRunning) {
            isOnTop = isRunning
        }
        .background(AlwaysOnTopView(window: NSApplication.shared.windows.first!, isAlwaysOnTop: isOnTop))
        .onReceive(timer) { t in
                if isRunning && timeRemaining > 0 {
                    timeRemaining -= 1
                    if timeRemaining <= 5 && isSoundOn {
                        NSSound.beep()
                    }
                }else if isRunning && timeRemaining == 0 {
                    if isSoundOn { soundManager.playSound() }
                    isFinished = true
                    isRunning = false
                }
        }
    }
    
    func autoSetting() {
        if timeRemaining < 60 {
            timeRemaining = 100
        } else if timeRemaining < 180 {
            timeRemaining = 180
        } else if timeRemaining < 300 {
            timeRemaining = 300
        } else if timeRemaining < 600 {
            timeRemaining = 600
        } else {
            timeRemaining = 60
        }
    }
    
}

//#Preview {
//    ContentView(isRunning: $)
//}
