//
//  KeyboardUtils.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Centralized Keyboard Manager
class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var animatedKeyboardOffset: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupKeyboardPublisher()
    }
    
    private func setupKeyboardPublisher() {
        Publishers.keyboardHeight
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyboardHeight in
                // #region agent log
                let logData: [String: Any] = [
                    "keyboardHeight": keyboardHeight,
                    "previousHeight": self?.keyboardHeight ?? 0
                ]
                if let logUrl = URL(string: "http://127.0.0.1:7242/ingest/c677de8d-2119-4520-a566-f1ce6300614d") {
                    Task {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: ["location": "Keyboard.swift:27", "message": "keyboardHeight changed", "data": logData, "timestamp": Int(Date().timeIntervalSince1970 * 1000), "sessionId": "debug-session", "runId": "run1", "hypothesisId": "C"])
                            var request = URLRequest(url: logUrl)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.httpBody = jsonData
                            _ = try? await URLSession.shared.data(for: request)
                        } catch {}
                    }
                }
                // #endregion
                self?.keyboardHeight = keyboardHeight
            }
            .store(in: &cancellables)
    }
    
    func updateKeyboardOffset(
        keyboardHeight: CGFloat,
        inputFieldFrame: CGRect,
        lastResponseBubbleHeight: CGFloat
    ) {
        // #region agent log
        let logData: [String: Any] = [
            "keyboardHeight": keyboardHeight,
            "currentOffset": animatedKeyboardOffset,
            "inputFieldFrame": ["x": inputFieldFrame.minX, "y": inputFieldFrame.minY, "width": inputFieldFrame.width, "height": inputFieldFrame.height],
            "lastResponseBubbleHeight": lastResponseBubbleHeight
        ]
        if let logUrl = URL(string: "http://127.0.0.1:7242/ingest/c677de8d-2119-4520-a566-f1ce6300614d") {
            Task {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: ["location": "Keyboard.swift:32", "message": "updateKeyboardOffset called", "data": logData, "timestamp": Int(Date().timeIntervalSince1970 * 1000), "sessionId": "debug-session", "runId": "run1", "hypothesisId": "A"])
                    var request = URLRequest(url: logUrl)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    _ = try? await URLSession.shared.data(for: request)
                } catch {}
            }
        }
        // #endregion
        
        let targetOffset = calculateKeyboardOffset(
            keyboardHeight: keyboardHeight,
            inputFieldFrame: inputFieldFrame,
            lastResponseBubbleHeight: lastResponseBubbleHeight
        )
        
        // #region agent log
        let logData2: [String: Any] = [
            "targetOffset": targetOffset,
            "currentOffset": animatedKeyboardOffset,
            "willAnimate": targetOffset > 0 && keyboardHeight > 0 || keyboardHeight == 0
        ]
        if let logUrl = URL(string: "http://127.0.0.1:7242/ingest/c677de8d-2119-4520-a566-f1ce6300614d") {
            Task {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: ["location": "Keyboard.swift:42", "message": "updateKeyboardOffset calculated target", "data": logData2, "timestamp": Int(Date().timeIntervalSince1970 * 1000), "sessionId": "debug-session", "runId": "run1", "hypothesisId": "B"])
                    var request = URLRequest(url: logUrl)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = jsonData
                    _ = try? await URLSession.shared.data(for: request)
                } catch {}
            }
        }
        // #endregion
        
        if targetOffset > 0 && keyboardHeight > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.animatedKeyboardOffset = targetOffset
            }
            print("🔧 Keyboard offset set to: \(targetOffset)")
        } else if keyboardHeight == 0 {
            // Reset offset when keyboard is hidden
            withAnimation(.easeInOut(duration: 0.3)) {
                self.animatedKeyboardOffset = 0
            }
            print("🔧 Keyboard offset reset to 0 (keyboard hidden)")
        }
    }
    
    func resetKeyboardOffset() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.animatedKeyboardOffset = 0
        }
        print("🔧 Keyboard offset reset to 0")
    }
}

// MARK: - Keyboard Adaptive View Modifier
struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                self.keyboardHeight = keyboardHeight
            }
    }
}

// MARK: - View Extensions
extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptive())
    }
}

// MARK: - Publishers Extensions
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

// MARK: - Keyboard Utility Functions
func getCurrentKeyboardHeight() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
        return 0
    }
    
    let keyboardFrame = window.frame.intersection(window.safeAreaInsets.bottom > 0 ? 
        CGRect(x: 0, y: window.frame.height - window.safeAreaInsets.bottom, width: window.frame.width, height: window.safeAreaInsets.bottom) : 
        CGRect.zero)
    
    return keyboardFrame.height
}

func calculateKeyboardOffset(
    keyboardHeight: CGFloat,
    inputFieldFrame: CGRect,
    lastResponseBubbleHeight: CGFloat
) -> CGFloat {
    guard keyboardHeight > 0 else { return 0 }
    
    let screenHeight = UIScreen.main.bounds.height
    let viewableArea = screenHeight - keyboardHeight
    let inputFieldMaxY = inputFieldFrame.maxY
    
    // Calculate offset to ensure exactly 8px between bottom of answer chat bubble and top of keyboard
    let targetSpacing: CGFloat = 8.0
    let requiredOffset = inputFieldMaxY - (viewableArea - targetSpacing)
    
    if requiredOffset > 0 {
        print("🔧 Keyboard offset calculation: inputFieldMaxY=\(inputFieldMaxY), viewableArea=\(viewableArea), requiredOffset=\(requiredOffset)")
        return requiredOffset
    } else {
        return 0
    }
}

