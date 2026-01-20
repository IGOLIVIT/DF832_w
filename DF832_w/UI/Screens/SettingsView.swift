import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var progressService: ProgressService
    @State private var showResetAlert = false
    @State private var showAbout = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .primary)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    statisticsSummary
                    aboutSection
                    resetSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                progressService.resetProgress()
                HapticService.warning()
            }
        } message: {
            Text("This will permanently delete all your progress, badges, and statistics. This action cannot be undone.")
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet()
        }
    }
    
    private var statisticsSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Journey")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                LevelBadge(
                    level: progressService.progress.ritualLevel,
                    progress: progressService.progress.levelProgress
                )
            }
            
            VStack(spacing: 12) {
                SettingsStatRow(
                    icon: "clock.fill",
                    title: "Total Training Time",
                    value: formatMinutes(progressService.progress.totalMinutes),
                    accentColor: "AccentB"
                )
                
                SettingsStatRow(
                    icon: "checkmark.circle.fill",
                    title: "Drills Completed",
                    value: "\(progressService.progress.totalDrills)",
                    accentColor: "Success"
                )
                
                SettingsStatRow(
                    icon: "flame.fill",
                    title: "Best Streak",
                    value: "\(progressService.progress.bestStreak) days",
                    accentColor: "AccentC"
                )
                
                SettingsStatRow(
                    icon: "star.fill",
                    title: "Badges Earned",
                    value: "\(progressService.unlockedBadges.count) of \(progressService.badges.count)",
                    accentColor: "AccentA"
                )
                
                SettingsStatRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Ritual XP",
                    value: "\(progressService.progress.ritualXP)",
                    accentColor: "AccentA"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)h \(mins)m"
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Button(action: { showAbout = true }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("AccentA").opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("AccentA"))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("About the Method")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("Learn how discipline training works")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextMuted"))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color("SurfaceElevated"))
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            DangerButton(title: "Reset All Progress") {
                showResetAlert = true
            }
            
            Text("This will delete all your progress, badges, and statistics. You'll start fresh as if opening the app for the first time.")
                .font(.system(size: 13))
                .foregroundColor(Color("TextMuted"))
                .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
}

struct SettingsStatRow: View {
    let icon: String
    let title: String
    let value: String
    let accentColor: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(accentColor))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
        }
        .padding(.vertical, 4)
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color("AccentA").opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 44, weight: .semibold))
                                    .foregroundColor(Color("AccentA"))
                            }
                            
                            Text("The Science of Discipline")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("TextPrimary"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        // Content sections
                        AboutSection(
                            title: "Why Mini-Games Work",
                            content: "Discipline isn't about willpower—it's a skill that can be trained. Short, focused practice sessions create neural pathways that make self-control automatic over time. Just like physical exercise, consistency matters more than intensity."
                        )
                        
                        AboutSection(
                            title: "The Four Tracks",
                            content: "Each track targets a different aspect of discipline:\n\n• Focus: Train attention control and reduce distractibility\n• Body: Build physical awareness and movement habits\n• Mind: Develop planning and decision-making skills\n• Order: Create systems and consistent routines"
                        )
                        
                        AboutSection(
                            title: "Building Streaks",
                            content: "Maintaining a daily streak isn't just about numbers—it builds the habit of showing up. Research shows that consistency creates lasting behavior change. Even on busy days, completing just one short drill keeps your streak alive and your brain in training mode."
                        )
                        
                        AboutSection(
                            title: "Progressive Challenge",
                            content: "As you level up, drills become more challenging. This progressive overload keeps your brain engaged and prevents plateaus. Each level builds on the previous one, gradually expanding your capacity for focus and self-regulation."
                        )
                        
                        AboutSection(
                            title: "The Ritual Level",
                            content: "Your Ritual Level represents your overall discipline fitness. It increases with every completed drill, reflecting your cumulative training. Think of it as your discipline XP—a measure of the time and effort you've invested in becoming more focused and disciplined."
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentA"))
                }
            }
        }
    }
}

struct AboutSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
}
