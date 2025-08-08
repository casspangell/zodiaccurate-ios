//
//  ExpandedCard.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import SwiftUI

struct ExpandedCard: View {
    let title: String
    let content: String
    let onCollapse: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text(title)
                    .font(.dmSansSemibold(size: 32))
                    .foregroundColor(.whiteCustom)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                
                // Content
                ScrollView {
                    Text(content)
                        .font(.dmSansMedium(size: 18))
                        .foregroundColor(.whiteCustom.opacity(0.9))
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.deepSaphire.opacity(1.0))
            )
            
            // Collapse Button in upper right corner
            Button(action: {
                onCollapse()
                dismiss()
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.whiteCustom)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .opacity(0.8)
                    )
                    .scaleEffect(1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Collapse")
            .accessibilityHint("Tap to collapse content")
            .padding(.top, 60)
            .padding(.trailing, 24)
            .zIndex(1)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()
        
        ExpandedCard(
            title: "Parenting",
            content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
            onCollapse: {}
        )
    }
}

