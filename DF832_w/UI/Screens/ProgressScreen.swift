import SwiftUI

struct ProgressScreen: View {
    @EnvironmentObject var progressService: ProgressService
    @State private var showBadgeDetail: Badge? = nil
    
    var body: some View {
        ZStack {
            AppBackground(style: .primary)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    weeklyHeatmapSection
                    statsSection
                    badgesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $showBadgeDetail) { badge in
            BadgeDetailSheet(badge: badge)
        }
    }
    
    private var weeklyHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\(progressService.progress.weeklyTotal()) min")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("AccentA"))
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - dayOffset), to: Date()) ?? Date()
                    let minutes = progressService.progress.heatmapValue(for: date)
                    
                    VStack(spacing: 8) {
                        HeatmapCell(minutes: minutes)
                        
                        Text(dayLabel(for: date))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Calendar.current.isDateInToday(date) ? Color("AccentA") : Color("TextMuted"))
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HeatLegendItem(color: Color("SurfaceElevated"), label: "0 min")
                HeatLegendItem(color: Color("AccentA").opacity(0.3), label: "1-5")
                HeatLegendItem(color: Color("AccentA").opacity(0.6), label: "6-10")
                HeatLegendItem(color: Color("AccentA"), label: "10+")
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                LargeStatTile(
                    title: "Current Streak",
                    value: "\(progressService.progress.streakDays)",
                    subtitle: "days in a row",
                    icon: "flame.fill",
                    accentColor: "AccentC"
                )
            }
            
            HStack(spacing: 12) {
                StatTile(
                    title: "Best Streak",
                    value: "\(progressService.progress.bestStreak)",
                    icon: "trophy.fill",
                    accentColor: "AccentC"
                )
                
                StatTile(
                    title: "Total Minutes",
                    value: "\(progressService.progress.totalMinutes)",
                    icon: "clock.fill",
                    accentColor: "AccentB"
                )
            }
            
            HStack(spacing: 12) {
                StatTile(
                    title: "Drills Done",
                    value: "\(progressService.progress.totalDrills)",
                    icon: "checkmark.circle.fill",
                    accentColor: "Success"
                )
                
                StatTile(
                    title: "Ritual Level",
                    value: "\(progressService.progress.ritualLevel)",
                    icon: "star.fill",
                    accentColor: "AccentA"
                )
            }
        }
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("\(progressService.unlockedBadges.count)/\(progressService.badges.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }
            
            // Unlocked badges
            if !progressService.unlockedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Unlocked")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(progressService.unlockedBadges) { badge in
                            Button(action: { showBadgeDetail = badge }) {
                                BadgeCard(badge: badge)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
            }
            
            // Locked badges
            if !progressService.lockedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Locked")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("TextMuted"))
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(progressService.lockedBadges) { badge in
                            Button(action: { showBadgeDetail = badge }) {
                                BadgeCard(badge: badge)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
}

struct HeatmapCell: View {
    let minutes: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(cellColor)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }
    
    private var cellColor: Color {
        if minutes == 0 {
            return Color("SurfaceElevated")
        } else if minutes <= 5 {
            return Color("AccentA").opacity(0.3)
        } else if minutes <= 10 {
            return Color("AccentA").opacity(0.6)
        } else {
            return Color("AccentA")
        }
    }
}

struct HeatLegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("TextMuted"))
        }
    }
}

struct BadgeDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let badge: Badge
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Badge icon
                    ZStack {
                        Circle()
                            .fill(badge.isUnlocked ? Color(badge.rarity.colorName).opacity(0.2) : Color("SurfaceElevated"))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: badge.icon)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(badge.isUnlocked ? Color(badge.rarity.colorName) : Color("TextMuted"))
                        
                        if !badge.isUnlocked {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "lock.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color("TextMuted"))
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text(badge.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text(badge.rarity.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(badge.rarity.colorName))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(badge.rarity.colorName).opacity(0.2))
                            )
                    }
                    
                    Text(badge.description)
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    if badge.isUnlocked, let unlockedAt = badge.unlockedAt {
                        Text("Unlocked \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextMuted"))
                    }
                    
                    Spacer()
                    
                    if badge.isUnlocked {
                        PrimaryButton("Awesome!", accentColor: badge.rarity.colorName) {
                            dismiss()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        SecondaryButton("Keep Going", accentColor: "AccentA") {
                            dismiss()
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color("SurfaceCard")))
                    }
                }
            }
        }
    }
}
