import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var progressService: ProgressService
    @ObservedObject var dailyPlanService: DailyPlanService
    @Binding var navigationPath: NavigationPath
    
    @State private var showTrackPicker = false
    
    private var currentTrack: Track? {
        SeedData.tracks.first { $0.id == progressService.progress.selectedTrackID }
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .from(trackID: progressService.progress.selectedTrackID))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    statsSection
                    todayPlanSection
                    quickActionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                trackButton
            }
        }
        .sheet(isPresented: $showTrackPicker) {
            TrackPickerSheet(selectedTrackID: progressService.progress.selectedTrackID) { trackID in
                progressService.selectTrack(trackID)
                dailyPlanService.generateTodayPlan()
            }
        }
    }
    
    private var trackButton: some View {
        Button(action: { showTrackPicker = true }) {
            HStack(spacing: 8) {
                if let track = currentTrack {
                    Image(systemName: track.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(track.accentColorName))
                    
                    Text(track.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
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
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Heat ring with streak
            HStack(spacing: 24) {
                ZStack {
                    HeatRing(
                        progress: dailyPlanService.completionPercentage,
                        size: 100,
                        lineWidth: 10,
                        accentColor: currentTrack?.accentColorName ?? "AccentA",
                        secondaryColor: currentTrack?.secondaryAccentColorName ?? "AccentB"
                    )
                    
                    VStack(spacing: 2) {
                        Text("\(dailyPlanService.completedCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text("of \(dailyPlanService.totalCount)")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                        
                        Text(motivationalMessage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                    }
                    
                    StreakIndicator(
                        days: progressService.progress.streakDays,
                        isActive: isStreakActiveToday
                    )
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("SurfaceCard"))
            )
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
    
    private var motivationalMessage: String {
        let completed = dailyPlanService.completedCount
        let total = dailyPlanService.totalCount
        
        if completed == 0 {
            return "Ready to train?"
        } else if completed < total {
            return "Keep the momentum!"
        } else {
            return "Today's training complete!"
        }
    }
    
    private var isStreakActiveToday: Bool {
        guard let lastDate = progressService.progress.lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatTile(
                title: "Minutes",
                value: "\(progressService.progress.totalMinutes)",
                icon: "clock.fill",
                accentColor: "AccentB"
            )
            
            StatTile(
                title: "Best Streak",
                value: "\(progressService.progress.bestStreak)",
                icon: "flame.fill",
                accentColor: "AccentC"
            )
        }
    }
    
    private var todayPlanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Plan")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                LevelBadge(
                    level: progressService.progress.ritualLevel,
                    progress: progressService.progress.levelProgress
                )
            }
            
            if let plan = dailyPlanService.todayPlan {
                VStack(spacing: 12) {
                    ForEach(plan.drills) { plannedDrill in
                        TodayDrillCard(
                            plannedDrill: plannedDrill,
                            track: SeedData.tracks.first { $0.id == plannedDrill.drill.trackID }
                        ) {
                            navigationPath.append(DrillDestination(drill: plannedDrill.drill))
                        }
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            HStack(spacing: 12) {
                QuickActionCard(
                    title: "2 min",
                    subtitle: "Quick drill",
                    icon: "bolt.fill",
                    accentColor: "AccentC"
                ) {
                    if let drill = SeedData.drills.first(where: { $0.durationOptions.contains(2) }) {
                        navigationPath.append(DrillDestination(drill: drill))
                    }
                }
                
                QuickActionCard(
                    title: "5 min",
                    subtitle: "Full session",
                    icon: "flame.fill",
                    accentColor: "AccentA"
                ) {
                    if let drill = SeedData.drills.first(where: { $0.durationOptions.contains(5) }) {
                        navigationPath.append(DrillDestination(drill: drill))
                    }
                }
            }
        }
    }
}

struct TodayDrillCard: View {
    let plannedDrill: DailyPlan.PlannedDrill
    let track: Track?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    if plannedDrill.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("Success"))
                    } else {
                        Image(systemName: plannedDrill.drill.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plannedDrill.drill.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(plannedDrill.isCompleted ? Color("TextMuted") : Color("TextPrimary"))
                    
                    Text(plannedDrill.reason.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }
                
                Spacer()
                
                if !plannedDrill.isCompleted {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextMuted"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(plannedDrill.isCompleted ? Color("SurfaceCard").opacity(0.5) : Color("SurfaceCard"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        plannedDrill.isCompleted ? Color("Success").opacity(0.3) : Color("StrokeSoft").opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(plannedDrill.isCompleted)
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(accentColor).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(accentColor))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SurfaceCard"))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct TrackPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    var selectedTrackID: String
    var onSelect: (String) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(SeedData.tracks) { track in
                            TrackCard(
                                track: track,
                                isSelected: track.id == selectedTrackID
                            ) {
                                onSelect(track.id)
                                dismiss()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Choose Track")
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
