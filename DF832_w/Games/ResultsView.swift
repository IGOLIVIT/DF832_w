import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var progressService: ProgressService
    @EnvironmentObject var dailyPlanService: DailyPlanService
    
    let drill: Drill
    let score: Int
    let levelReached: Int
    let duration: Int
    let difficulty: DifficultyLevel
    let perfectLevels: Int
    let onDismiss: () -> Void
    
    @State private var appeared = false
    @State private var showConfetti = false
    @State private var newBadges: [Badge] = []
    @State private var isNewBestScore = false
    
    private var track: Track? {
        SeedData.tracks.first { $0.id == drill.trackID }
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .from(trackID: drill.trackID))
            
            if showConfetti {
                ConfettiView()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                        }
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        
                        Text("Training Complete!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                            .opacity(appeared ? 1 : 0)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)
                    
                    // Score card
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("Score")
                                .font(.system(size: 16))
                                .foregroundColor(Color("TextSecondary"))
                            
                            Text("\(score)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                            
                            if isNewBestScore {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                    Text("New Best!")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color("AccentC"))
                            }
                        }
                        
                        Divider()
                            .background(Color("StrokeSoft"))
                        
                        HStack(spacing: 0) {
                            ResultStat(title: "Level", value: "\(levelReached)", icon: "chart.bar.fill")
                            
                            Divider()
                                .frame(height: 40)
                                .background(Color("StrokeSoft"))
                            
                            ResultStat(title: "Time", value: "\(max(1, duration))m", icon: "clock.fill")
                            
                            Divider()
                                .frame(height: 40)
                                .background(Color("StrokeSoft"))
                            
                            ResultStat(title: "Perfect", value: "\(perfectLevels)", icon: "checkmark.circle.fill")
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("SurfaceCard"))
                    )
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
                    
                    // XP and level progress
                    xpSection
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
                    
                    // New badges
                    if !newBadges.isEmpty {
                        badgesSection
                            .offset(y: appeared ? 0 : 30)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
                    }
                    
                    // Next recommendation
                    nextRecommendation
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
                    
                    // Done button
                    PrimaryButton("Done", icon: "checkmark", accentColor: track?.accentColorName ?? "AccentA") {
                        onDismiss()
                    }
                    .padding(.top, 8)
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.6), value: appeared)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 100)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            saveProgress()
            appeared = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !newBadges.isEmpty || isNewBestScore {
                    showConfetti = true
                    HapticService.success()
                }
            }
        }
    }
    
    private func saveProgress() {
        let previousBadgeCount = progressService.unlockedBadges.count
        let previousBestScore = progressService.bestScore(for: drill.id)
        
        progressService.completeDrill(
            drillID: drill.id,
            score: score,
            duration: max(1, duration),
            difficulty: difficulty.displayName,
            levelReached: levelReached,
            perfectLevel: perfectLevels > 0
        )
        
        dailyPlanService.markDrillCompleted(drill.id)
        dailyPlanService.generateTodayPlan()
        
        // Check for new badges
        let currentBadgeCount = progressService.unlockedBadges.count
        if currentBadgeCount > previousBadgeCount {
            newBadges = Array(progressService.unlockedBadges.suffix(currentBadgeCount - previousBadgeCount))
        }
        
        // Check for new best score
        if let prev = previousBestScore {
            isNewBestScore = score > prev
        } else {
            isNewBestScore = true
        }
    }
    
    private var xpSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Ritual Progress")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                Text("Level \(progressService.progress.ritualLevel)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("AccentA"))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("SurfaceElevated"))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color("AccentA"), Color("AccentB")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progressService.progress.levelProgress, height: 12)
                }
            }
            .frame(height: 12)
            
            Text("\(progressService.progress.xpToNextLevel) XP to next level")
                .font(.system(size: 13))
                .foregroundColor(Color("TextMuted"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color("AccentC"))
                Text("New Badges Unlocked!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            ForEach(newBadges) { badge in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(badge.rarity.colorName).opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: badge.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(badge.rarity.colorName))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(badge.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text(badge.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color("SurfaceElevated"))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private var nextRecommendation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Recommended")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
            
            if let nextDrill = getNextRecommendedDrill() {
                let nextTrack = SeedData.tracks.first { $0.id == nextDrill.trackID }
                
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(nextTrack?.accentColorName ?? "AccentA").opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: nextDrill.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(nextTrack?.accentColorName ?? "AccentA"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nextDrill.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text(nextDrill.shortDescription)
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("TextMuted"))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private func getNextRecommendedDrill() -> Drill? {
        let otherDrills = SeedData.drills.filter { $0.id != drill.id }
        if let trackDrill = otherDrills.first(where: { $0.trackID == drill.trackID }) {
            return trackDrill
        }
        return otherDrills.first
    }
}

struct ResultStat: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("TextMuted"))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }
}
