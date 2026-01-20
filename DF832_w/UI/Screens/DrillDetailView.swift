import SwiftUI

struct DrillDetailView: View {
    @EnvironmentObject var progressService: ProgressService
    let drill: Drill
    @Binding var navigationPath: NavigationPath
    
    @State private var selectedDuration: Int
    @State private var selectedDifficulty: DifficultyLevel
    
    private var track: Track? {
        SeedData.tracks.first { $0.id == drill.trackID }
    }
    
    init(drill: Drill, navigationPath: Binding<NavigationPath>) {
        self.drill = drill
        self._navigationPath = navigationPath
        self._selectedDuration = State(initialValue: drill.durationOptions.first ?? 3)
        self._selectedDifficulty = State(initialValue: drill.difficultyLevels.first ?? .easy)
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .from(trackID: drill.trackID))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    descriptionSection
                    configSection
                    howItHelpsSection
                    startSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(drill.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: drill.icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
            }
            
            VStack(spacing: 8) {
                if let track = track {
                    HStack(spacing: 6) {
                        Image(systemName: track.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(track.title)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(track.accentColorName))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(track.accentColorName).opacity(0.15))
                    )
                }
                
                Text(drill.shortDescription)
                    .font(.system(size: 16))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
            
            if let bestScore = progressService.bestScore(for: drill.id) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Color("AccentC"))
                    Text("Best Score: \(bestScore)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("AccentC"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color("AccentC").opacity(0.15))
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Drill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(drill.longDescription)
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
    
    private var configSection: some View {
        VStack(spacing: 16) {
            // Duration selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Duration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                HStack(spacing: 12) {
                    ForEach(drill.durationOptions, id: \.self) { duration in
                        ConfigButton(
                            title: "\(duration) min",
                            isSelected: selectedDuration == duration,
                            accentColor: track?.accentColorName ?? "AccentA"
                        ) {
                            selectedDuration = duration
                        }
                    }
                }
            }
            
            // Difficulty selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Difficulty")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                HStack(spacing: 12) {
                    ForEach(drill.difficultyLevels, id: \.rawValue) { difficulty in
                        ConfigButton(
                            title: difficulty.displayName,
                            isSelected: selectedDifficulty == difficulty,
                            accentColor: difficultyColor(difficulty)
                        ) {
                            selectedDifficulty = difficulty
                        }
                    }
                }
            }
            
            // Preview info
            HStack(spacing: 16) {
                InfoPill(icon: "square.grid.3x3", value: "\(selectedDifficulty.gridSize)x\(selectedDifficulty.gridSize)", label: "Grid")
                InfoPill(icon: "number", value: "\(selectedDifficulty.sequenceLength.min)-\(selectedDifficulty.sequenceLength.max)", label: "Sequence")
                InfoPill(icon: "clock", value: "\(selectedDifficulty.timeLimit)s", label: "Per Round")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private func difficultyColor(_ difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .easy: return "Success"
        case .medium: return "AccentC"
        case .hard: return "Danger"
        }
    }
    
    private var howItHelpsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How It Helps")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            VStack(spacing: 10) {
                ForEach(drill.howItHelps, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("Success"))
                        
                        Text(benefit)
                            .font(.system(size: 15))
                            .foregroundColor(Color("TextSecondary"))
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("SurfaceCard"))
        )
    }
    
    private var startSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                "Start Drill",
                icon: "play.fill",
                accentColor: track?.accentColorName ?? "AccentA"
            ) {
                let destination = GameDestination(
                    drill: drill,
                    difficulty: selectedDifficulty,
                    duration: selectedDuration
                )
                navigationPath.append(destination)
            }
            
            Text("Complete drills to build your streak and unlock badges")
                .font(.system(size: 13))
                .foregroundColor(Color("TextMuted"))
                .multilineTextAlignment(.center)
        }
    }
}

struct ConfigButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? Color("TextPrimary") : Color("TextSecondary"))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(accentColor) : Color("SurfaceElevated"))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct InfoPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(Color("TextPrimary"))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("TextMuted"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("SurfaceElevated"))
        )
    }
}
