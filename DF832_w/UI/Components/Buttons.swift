import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDisabled: Bool = false
    var accentColor: String = "AccentA"
    
    init(_ title: String, icon: String? = nil, accentColor: String = "AccentA", isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticService.light()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(isDisabled ? Color("TextMuted") : Color("TextPrimary"))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDisabled ? Color("SurfaceCard") : Color(accentColor))
            )
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var accentColor: String = "AccentA"
    
    init(_ title: String, icon: String? = nil, accentColor: String = "AccentA", action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticService.light()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color(accentColor))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(accentColor).opacity(0.5), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(accentColor).opacity(0.1))
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var backgroundColor: String = "SurfaceCard"
    
    var body: some View {
        Button(action: {
            HapticService.selection()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color(backgroundColor))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    var accentColor: String = "AccentA"
    let action: () -> Void
    
    init(title: String, isSelected: Bool, accentColor: String = "AccentA", action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticService.selection()
            action()
        }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Color("TextPrimary") : Color("TextSecondary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(accentColor) : Color("SurfaceCard"))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DangerButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.warning()
            action()
        }) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("Danger"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("Danger").opacity(0.3), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Danger").opacity(0.1))
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
