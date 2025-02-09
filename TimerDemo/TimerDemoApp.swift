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
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          if let window = NSApplication.shared.windows.first {
            window.level = .floating
          }
        }
    }
    .windowResizability(.contentSize)
  }
}
