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
    //같은 변수를 windowGroup과 MenuBarExtra에서 각각 한번씩, 총 두배로 타미어 시간을 감소 시킨것으로 되어버려서 타이머 시간 감소 속도가 두배로 빨라짐
    // 일단은  WindowGroup 또는 MenuBarExtra 둘 중 하나만 사용해야겠다.

    WindowGroup {
      ContentView(isRunning: $isRunning, timeRemaining: $timeRemaining, title: $title, isSoundOn: $isSoundOn)
        .onAppear {
          if let window = NSApplication.shared.windows.first {
            window.level = .floating
          }
        }
    }
    .windowResizability(.contentSize)

//    MenuBarExtra(
//      "App Menu Bar Extra", systemImage: isRunning ? "door.left.hand.closed" : "door.left.hand.open",
//      isInserted: $showMenuBarExtra)
//    {
//      ContentView(isRunning: $isRunning, timeRemaining: $timeRemaining, title: $title, isSoundOn: $isSoundOn)
//    }
//    .menuBarExtraStyle(.window)

  }
}
