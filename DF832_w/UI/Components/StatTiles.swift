import SwiftUI

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    var accentColor: String = "AccentA"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(accentColor))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color("TextPrimary"))
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(Color("TextSecondary"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("SurfaceCard"))
        )
    }
}

struct LargeStatTile: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    var accentColor: String = "AccentA"
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(accentColor).opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(accentColor))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextMuted"))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
}

struct HeatRing: View {
    let progress: Double
    let size: CGFloat
    var lineWidth: CGFloat = 8
    var accentColor: String = "AccentA"
    var secondaryColor: String = "AccentB"
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("SurfaceElevated"), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color(accentColor), Color(secondaryColor)]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            if progress >= 1.0 {
                Circle()
                    .fill(Color(accentColor))
                    .frame(width: lineWidth, height: lineWidth)
                    .offset(y: -size / 2 + lineWidth / 2)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

struct StreakIndicator: View {
    let days: Int
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isActive ? "flame.fill" : "flame")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isActive ? Color("AccentC") : Color("TextMuted"))
            
            Text("\(days)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isActive ? Color("TextPrimary") : Color("TextMuted"))
            
            Text("day streak")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color("SurfaceCard"))
        )
    }
}

struct LevelBadge: View {
    let level: Int
    let progress: Double
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color("AccentA").opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(level)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AccentA"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Ritual Level")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("SurfaceElevated"))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(Color("AccentA"))
                            .frame(width: geo.size.width * progress, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: 80)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color("SurfaceCard"))
        )
    }
}
