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
                self?.keyboardHeight = keyboardHeight
            }
            .store(in: &cancellables)
    }
    
    func updateKeyboardOffset(
        keyboardHeight: CGFloat,
        inputFieldFrame: CGRect,
        lastResponseBubbleHeight: CGFloat
    ) {
        let targetOffset = calculateKeyboardOffset(
            keyboardHeight: keyboardHeight,
            inputFieldFrame: inputFieldFrame,
            lastResponseBubbleHeight: lastResponseBubbleHeight
        )
        
        if targetOffset > 0 && keyboardHeight > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.animatedKeyboardOffset = targetOffset
            }
        }
    }
    
    func resetKeyboardOffset() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.animatedKeyboardOffset = 0
        }
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
    
    // Get the height of the last response bubble for additional context
    let viewableAreaDiff = viewableArea - inputFieldMaxY

    if viewableAreaDiff < 0 {
        let offset = viewableArea - keyboardHeight + lastResponseBubbleHeight + 24 //padding
//        print("OFFSET: \(offset) ///viewableArea \(viewableArea) - keyboardHeight \(keyboardHeight) + lastResponseBubbleHeight \(lastResponseBubbleHeight) + 24")
        return offset
    } else {
        return 0
    }
}

