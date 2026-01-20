import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SurfaceCard"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("StrokeSoft").opacity(0.5), lineWidth: 1)
            )
    }
}

struct ElevatedCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SurfaceElevated"))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
    }
}

struct TrackCard: View {
    let track: Track
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.medium()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(track.accentColorName).opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: track.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(track.accentColorName))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(track.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(track.accentColorName))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SurfaceCard"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(track.accentColorName) : Color("StrokeSoft").opacity(0.5),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DrillCard: View {
    let drill: Drill
    let track: Track?
    var showBestScore: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.light()
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: drill.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(drill.durationOptions, id: \.self) { duration in
                            Text("\(duration)m")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color("TextMuted"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color("BackgroundSecondary"))
                                )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(drill.shortDescription)
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                if let score = showBestScore {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("AccentC"))
                        Text("Best: \(score)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("AccentC"))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SurfaceCard"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("StrokeSoft").opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct BadgeCard: View {
    let badge: Badge
    var compact: Bool = false
    
    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? Color(badge.rarity.colorName).opacity(0.2) : Color("SurfaceElevated"))
                    .frame(width: compact ? 48 : 64, height: compact ? 48 : 64)
                
                Image(systemName: badge.icon)
                    .font(.system(size: compact ? 20 : 28, weight: .semibold))
                    .foregroundColor(badge.isUnlocked ? Color(badge.rarity.colorName) : Color("TextMuted"))
                
                if !badge.isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: compact ? 48 : 64, height: compact ? 48 : 64)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: compact ? 14 : 18))
                        .foregroundColor(Color("TextMuted"))
                }
            }
            
            if !compact {
                VStack(spacing: 4) {
                    Text(badge.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(badge.isUnlocked ? Color("TextPrimary") : Color("TextMuted"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text(badge.rarity.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(badge.rarity.colorName))
                }
            }
        }
        .frame(width: compact ? 60 : 90)
    }
}
