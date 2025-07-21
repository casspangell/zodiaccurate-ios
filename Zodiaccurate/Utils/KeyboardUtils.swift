//
//  KeyboardUtils.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import Foundation
import SwiftUI

// MARK: - Keyboard Utilities
/// Returns the current keyboard height
/// - Returns: The keyboard height as CGFloat, or 0 if keyboard is not visible
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

// MARK: - Keyboard Offset Utilities
/// Calculates the keyboard offset needed to keep the input field visible
/// - Parameters:
///   - keyboardHeight: The current keyboard height
///   - inputFieldFrame: The frame of the input field in global coordinates
///   - lastResponseBubbleHeight: The height of the last response bubble
/// - Returns: The calculated offset, or 0 if no offset is needed
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
        print("OFFSET: \(offset) ///viewableArea \(viewableArea) - keyboardHeight \(keyboardHeight) + lastResponseBubbleHeight \(lastResponseBubbleHeight) + 24")
        return offset
    } else {
        return 0
    }
}

