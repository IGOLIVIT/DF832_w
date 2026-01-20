import SwiftUI

struct GameContainerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressService: ProgressService
    
    let drill: Drill
    let difficulty: DifficultyLevel
    let duration: Int
    @ObservedObject var dailyPlanService: DailyPlanService
    
    @State private var gameState: GameState = .tutorial
    @State private var currentLevel = 1
    @State private var totalScore = 0
    @State private var perfectLevels = 0
    @State private var startTime = Date()
    
    enum GameState {
        case tutorial
        case playing
        case levelComplete
        case gameOver
        case results
    }
    
    private var track: Track? {
        SeedData.tracks.first { $0.id == drill.trackID }
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .from(trackID: drill.trackID))
            
            switch gameState {
            case .tutorial:
                tutorialView
                
            case .playing, .levelComplete, .gameOver:
                gamePlayView
                
            case .results:
                ResultsView(
                    drill: drill,
                    score: totalScore,
                    levelReached: currentLevel,
                    duration: Int(Date().timeIntervalSince(startTime) / 60),
                    difficulty: difficulty,
                    perfectLevels: perfectLevels,
                    onDismiss: {
                        dismiss()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if gameState != .results {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextSecondary"))
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color("SurfaceCard")))
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if gameState == .playing {
                    Text("Level \(currentLevel)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if gameState == .playing {
                    Text("\(totalScore) pts")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(track?.accentColorName ?? "AccentA"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(track?.accentColorName ?? "AccentA").opacity(0.15))
                        )
                }
            }
        }
    }
    
    private var tutorialView: some View {
        TutorialOverlay(
            drill: drill,
            onStart: {
                let tutorialID = "\(drill.gameType.rawValue)_tutorial"
                progressService.markTutorialSeen(tutorialID)
                startTime = Date()
                withAnimation {
                    gameState = .playing
                }
            },
            skipTutorial: progressService.hasSeen(tutorial: "\(drill.gameType.rawValue)_tutorial")
        )
        .onAppear {
            let tutorialID = "\(drill.gameType.rawValue)_tutorial"
            if progressService.hasSeen(tutorial: tutorialID) {
                startTime = Date()
                gameState = .playing
            }
        }
    }
    
    @ViewBuilder
    private var gamePlayView: some View {
        switch drill.gameType {
        case .focusGrid:
            FocusGridGame(
                difficulty: difficulty,
                currentLevel: $currentLevel,
                totalScore: $totalScore,
                perfectLevels: $perfectLevels,
                gameState: $gameState,
                maxLevel: drill.levels.count,
                accentColor: track?.accentColorName ?? "AccentA"
            )
            
        case .planSprint:
            PlanSprintGame(
                difficulty: difficulty,
                currentLevel: $currentLevel,
                totalScore: $totalScore,
                perfectLevels: $perfectLevels,
                gameState: $gameState,
                maxLevel: drill.levels.count,
                trackID: drill.trackID,
                accentColor: track?.accentColorName ?? "AccentA"
            )
        }
    }
}

struct TutorialOverlay: View {
    let drill: Drill
    let onStart: () -> Void
    var skipTutorial: Bool = false
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color("AccentA").opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: drill.icon)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(Color("AccentA"))
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("How to Play")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(tutorialText)
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)
            }
            .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
            
            VStack(spacing: 16) {
                ForEach(tutorialSteps.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("AccentB").opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("AccentB"))
                        }
                        
                        Text(tutorialSteps[index])
                            .font(.system(size: 15))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("SurfaceCard"))
                    )
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.2 + Double(index) * 0.1), value: appeared)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton("Start", icon: "play.fill") {
                onStart()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)
        }
        .onAppear {
            appeared = true
        }
    }
    
    private var tutorialText: String {
        switch drill.gameType {
        case .focusGrid:
            return "Test your attention and memory by watching and repeating patterns."
        case .planSprint:
            return "Practice prioritization by arranging tasks in the optimal order."
        }
    }
    
    private var tutorialSteps: [String] {
        switch drill.gameType {
        case .focusGrid:
            return [
                "Watch the tiles light up in sequence",
                "Tap them in the same order",
                "Complete before time runs out"
            ]
        case .planSprint:
            return [
                "Read the rules at the top",
                "Drag tasks to reorder them",
                "Tap Commit when ready"
            ]
        }
    }
}
