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
  @State var isRunning : Bool = false
  @State var isSoundOn : Bool = false
  @State var timeRemaining : Int = 60
  @State var title : String = ""

  @State private var min: Int = 7
  @State private var sec: Int = 0
  @State private var isOnTop = false
  @State private var isSetting = false
  @State private var isFinished = false
  @State private var endTime: Date?
  @State private var urlError: String? = nil

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let soundManager = SoundManager.instance

  var body: some View {
    ZStack {
      VStack(spacing: 10) {
        timerControlSection
        timerDisplaySection
        endTimeSection
        titleSection
      }
    }
    .padding()
    .background(AlwaysOnTopView(window: NSApplication.shared.windows.first!, isAlwaysOnTop: isOnTop))
    .onReceive(timer, perform: handleTimer)
  }

  // MARK: - View Components
  private var timerControlSection: some View {
    HStack {
      timerButton
      controlButtons
    }
  }

  private var timerButton: some View {
    Image(systemName: isRunning ? "door.left.hand.closed" : "door.left.hand.open")
      .resizable()
      .frame(width: 80, height: 80)
      .onTapGesture(perform: toggleTimer)
  }

  private var timeInputView: some View {
    Group {
      if isSetting {
        HStack {
          TextField("00", value: $min, formatter: NumberFormatter())
            .frame(width: 25, height: 40)
          Text(":")
          TextField("00", value: $sec, formatter: NumberFormatter())
            .frame(width: 25, height: 40)
        }
      } else {
        Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
          .font(.system(size: 20, weight: .bold))
          .onTapGesture(perform: autoSetting)
      }
    }
  }

  private var controlButtons: some View {
    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
      GridRow {
        Image(systemName: isOnTop ? "pin.fill" : "pin.slash.fill")
          .onTapGesture { isOnTop.toggle() }
        Image(systemName: "gear")
          .onTapGesture(perform: toggleSetting)
      }
      GridRow {
        Image(systemName: isSoundOn ? "speaker.wave.1.fill" : "speaker.slash.fill")
          .onTapGesture { isSoundOn.toggle() }
        Image(systemName: isRunning ? "stop.fill" : "stopwatch.fill")
          .onTapGesture(perform: toggleTimer)
      }
    }
    .font(.system(size: 20, weight: .bold))
  }

  private var timerDisplaySection: some View {
    HStack {
      if !isSetting {
        Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
          .font(.system(size: 24, weight: .bold))
          .foregroundColor(timeRemaining <= 5 ? .red : .primary)
      } else {
        timeInputView
      }
    }
  }

  private var titleSection: some View {
    Group {
      if isSetting {
        VStack(alignment: .leading, spacing: 4) {
          TextField("title", text: $title)
            .onChange(of: title) { _, newValue in
              urlError = nil  // 새로운 입력이 있을 때 에러 초기화
              if let url = extractURL(from: newValue) {
                fetchWebPageTitle(from: url)
              }
            }
          if let error = urlError {
            Text(error)
              .font(.caption)
              .foregroundColor(.red)
          }
        }
      } else {
        Text(title)
          .font(.system(size: 15, weight: .bold))
      }
    }
  }

  private var endTimeSection: some View {
    Group {
      if let endTime = endTime {
        Text("\(endTime, formatter: DateFormatter.shortTime)까지")
          .font(.system(size: 15, weight: .bold))
      }
    }
  }

  // MARK: - Methods
  private func toggleTimer() {
    isRunning.toggle()
    if isSetting {
      isSetting = false
    }
    isOnTop = isRunning
    timeRemaining = min * 60 + sec
    endTime = isRunning ? Date().addingTimeInterval(TimeInterval(timeRemaining)) : nil
  }

  private func toggleSetting() {
    isSetting.toggle()
    timeRemaining = min * 60 + sec
  }

  private func handleTimer(_ time: Date) {
    guard isRunning else { return }

    if timeRemaining > 0 {
      timeRemaining -= 1
      if timeRemaining <= 5 && isSoundOn {
        NSSound.beep()
      }
    } else {
      if isSoundOn { soundManager.playSound() }
      isFinished = true
      isRunning = false
      endTime = nil
      isOnTop = false
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

  // MARK: - URL Processing Methods
  private func extractURL(from string: String) -> URL? {
    guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
    let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

    if let match = matches.first, let range = Range(match.range, in: string) {
      let urlString = String(string[range])
      return URL(string: urlString)
    }
    return nil
  }

  private func fetchWebPageTitle(from url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          // 네트워크 에러 처리
          if (error as NSError).domain == NSURLErrorDomain {
            switch (error as NSError).code {
            case -1003:  // 호스트를 찾을 수 없음
              self.urlError = "웹사이트를 찾을 수 없습니다"
            case -1009:  // 인터넷 연결 없음
              self.urlError = "인터넷 연결을 확인해주세요"
            default:
              self.urlError = "URL을 확인할 수 없습니다"
            }
          }
          return
        }

        guard let data = data,
              let html = String(data: data, encoding: .utf8) else {
          self.urlError = "웹페이지 내용을 읽을 수 없습니다"
          return
        }

        if let titleRange = html.range(of: "<title>(.+?)</title>", options: .regularExpression) {
          let fullTitle = html[titleRange]
            .replacingOccurrences(of: "<title>", with: "")
            .replacingOccurrences(of: "</title>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

          // 첫 번째 부분만 추출 (구분자 · 기준)
          if let firstPart = fullTitle.components(separatedBy: " · ").first {
            self.title = firstPart
          } else {
            self.title = fullTitle
          }
        } else {
          self.urlError = "페이지 제목을 찾을 수 없습니다"
        }
      }
    }.resume()
  }

}

extension DateFormatter {
  static let shortTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
  }()
}

#Preview {
  ContentView()
}
