//
//  TimerDemoApp.swift
//  TimerDemo
//
//  Created by 최하진 on 1/24/25.
//

import SwiftUI

@available(macOS 15.0, *)
@main
struct TimerDemoApp: App {
    
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @State var isRunning : Bool = false
    @State var isSoundOn : Bool = true
    @State var timeRemaining : Int = 60
    @State var title : String = ""
    var body: some Scene {
        
        WindowGroup {
            ContentView(isRunning: $isRunning, timeRemaining: $timeRemaining, title: $title, isSoundOn: $isSoundOn)
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.level = .floating
                    }
                }
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra(
                    "App Menu Bar Extra", systemImage: isRunning ? "door.left.hand.closed" : "door.left.hand.open",
                    isInserted: $showMenuBarExtra)
                {
                    ContentView(isRunning: $isRunning, timeRemaining: $timeRemaining, title: $title, isSoundOn: $isSoundOn)
                }
                .menuBarExtraStyle(.window)
        
    }
}
