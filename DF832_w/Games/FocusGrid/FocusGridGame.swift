import SwiftUI
import Combine

struct FocusGridGame: View {
    let difficulty: DifficultyLevel
    @Binding var currentLevel: Int
    @Binding var totalScore: Int
    @Binding var perfectLevels: Int
    @Binding var gameState: GameContainerView.GameState
    let maxLevel: Int
    let accentColor: String
    
    @State private var gridSize: Int
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var highlightedTile: Int? = nil
    @State private var mistakes = 0
    @State private var timeRemaining: Int = 0
    @State private var isShowingSequence = true
    @State private var isTimerRunning = false
    @State private var roundScore = 0
    @State private var showLevelComplete = false
    @State private var showGameOver = false
    @State private var wrongTile: Int? = nil
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(difficulty: DifficultyLevel, currentLevel: Binding<Int>, totalScore: Binding<Int>, perfectLevels: Binding<Int>, gameState: Binding<GameContainerView.GameState>, maxLevel: Int, accentColor: String) {
        self.difficulty = difficulty
        self._currentLevel = currentLevel
        self._totalScore = totalScore
        self._perfectLevels = perfectLevels
        self._gameState = gameState
        self.maxLevel = maxLevel
        self.accentColor = accentColor
        
        let baseGrid = difficulty.gridSize
        let levelIncrease = (currentLevel.wrappedValue - 1) / 4
        self._gridSize = State(initialValue: min(6, baseGrid + levelIncrease))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer and progress
            HStack {
                // Mistakes indicator
                HStack(spacing: 4) {
                    ForEach(0..<difficulty.allowedMistakes + 1, id: \.self) { i in
                        Circle()
                            .fill(i < (difficulty.allowedMistakes + 1 - mistakes) ? Color("Danger") : Color("SurfaceElevated"))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Spacer()
                
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                    Text("\(timeRemaining)s")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(timeRemaining <= 5 ? Color("Danger") : Color("TextPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("SurfaceCard"))
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Grid
            GeometryReader { geo in
                let spacing: CGFloat = 8
                let availableWidth = geo.size.width - 40
                let tileSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)
                
                VStack(spacing: spacing) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                let index = row * gridSize + col
                                GridTile(
                                    index: index,
                                    isHighlighted: highlightedTile == index,
                                    isCorrect: playerSequence.contains(index) && wrongTile != index,
                                    isWrong: wrongTile == index,
                                    accentColor: accentColor,
                                    size: tileSize
                                ) {
                                    handleTileTap(index)
                                }
                                .disabled(isShowingSequence || showLevelComplete || showGameOver)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Status text
            Text(statusText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
                .padding(.bottom, 40)
        }
        .overlay {
            if showLevelComplete {
                levelCompleteOverlay
            }
            
            if showGameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            startRound()
        }
        .onReceive(timer) { _ in
            // Only tick if timer is explicitly running
            guard isTimerRunning else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isTimerRunning = false
                handleTimeUp()
            }
        }
    }
    
    private var statusText: String {
        if isShowingSequence {
            return "Watch carefully..."
        } else if showLevelComplete || showGameOver {
            return ""
        } else {
            return "Tap the tiles in order (\(playerSequence.count)/\(sequence.count))"
        }
    }
    
    private func startRound() {
        // Reset state
        isTimerRunning = false
        isShowingSequence = true
        playerSequence = []
        mistakes = 0
        wrongTile = nil
        highlightedTile = nil
        
        // Calculate sequence length based on level
        let levelAdjust = (currentLevel - 1) / 3  // Increase every 3 levels
        let seqLength = min(7, difficulty.sequenceLength.min + levelAdjust)
        
        sequence = generateSequence(length: seqLength)
        
        // Calculate time: base time + extra time per tile
        // Easy: 20 + 3*tiles, Medium: 15 + 2*tiles, Hard: 12 + 1.5*tiles
        let extraTimePerTile: Double
        switch difficulty {
        case .easy: extraTimePerTile = 3.0
        case .medium: extraTimePerTile = 2.5
        case .hard: extraTimePerTile = 2.0
        }
        timeRemaining = difficulty.timeLimit + Int(Double(seqLength) * extraTimePerTile)
        
        // Start showing sequence after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSequence()
        }
    }
    
    private func generateSequence(length: Int) -> [Int] {
        var seq: [Int] = []
        let totalTiles = gridSize * gridSize
        
        while seq.count < length {
            let tile = Int.random(in: 0..<totalTiles)
            if !seq.contains(tile) {
                seq.append(tile)
            }
        }
        
        return seq
    }
    
    private func showSequence() {
        // Preview duration based on difficulty
        let previewDuration: Double
        switch difficulty {
        case .easy: previewDuration = 0.8
        case .medium: previewDuration = 0.6
        case .hard: previewDuration = 0.5
        }
        
        for (index, tile) in sequence.enumerated() {
            let showTime = previewDuration * Double(index)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + showTime) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    highlightedTile = tile
                }
                HapticService.light()
            }
            
            // Hide tile after showing
            DispatchQueue.main.asyncAfter(deadline: .now() + showTime + previewDuration * 0.7) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    if highlightedTile == tile {
                        highlightedTile = nil
                    }
                }
            }
        }
        
        // After all tiles shown, enable input and start timer
        let totalShowTime = previewDuration * Double(sequence.count) + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalShowTime) {
            highlightedTile = nil
            isShowingSequence = false
            isTimerRunning = true  // NOW start the timer
        }
    }
    
    private func handleTileTap(_ index: Int) {
        guard !isShowingSequence && isTimerRunning else { return }
        
        let expectedIndex = playerSequence.count
        guard expectedIndex < sequence.count else { return }
        
        if index == sequence[expectedIndex] {
            // Correct tap
            HapticService.light()
            withAnimation(.spring(response: 0.3)) {
                playerSequence.append(index)
            }
            
            if playerSequence.count == sequence.count {
                // Round complete - stop timer first
                isTimerRunning = false
                calculateScore()
                
                if mistakes == 0 {
                    perfectLevels += 1
                }
                
                HapticService.success()
                
                if currentLevel >= maxLevel {
                    showGameOver = true
                    gameState = .gameOver
                } else {
                    showLevelComplete = true
                    gameState = .levelComplete
                }
            }
        } else {
            // Wrong tap
            HapticService.warning()
            mistakes += 1
            
            withAnimation(.easeInOut(duration: 0.1)) {
                wrongTile = index
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                wrongTile = nil
            }
            
            if mistakes > difficulty.allowedMistakes {
                isTimerRunning = false
                calculateScore()
                showGameOver = true
                gameState = .gameOver
            }
        }
    }
    
    private func handleTimeUp() {
        HapticService.error()
        calculateScore()
        showGameOver = true
        gameState = .gameOver
    }
    
    private func calculateScore() {
        let correctTaps = playerSequence.count
        let basePoints = correctTaps * 15
        let completionBonus = playerSequence.count == sequence.count ? 50 : 0
        let timeBonus = timeRemaining * 3
        let mistakePenalty = mistakes * 10
        let levelBonus = currentLevel * 10
        
        roundScore = max(0, basePoints + completionBonus + timeBonus - mistakePenalty + levelBonus)
        roundScore = Int(Double(roundScore) * difficulty.scoreMultiplier)
        totalScore += roundScore
    }
    
    private var levelCompleteOverlay: some View {
        VStack(spacing: 24) {
            SuccessCheckmark()
            
            Text("Level \(currentLevel) Complete!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text("+\(roundScore) points")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(accentColor))
            
            PrimaryButton("Next Level", icon: "arrow.right", accentColor: accentColor) {
                HapticService.success()
                currentLevel += 1
                showLevelComplete = false
                gameState = .playing
                
                let levelIncrease = (currentLevel - 1) / 4
                gridSize = min(6, difficulty.gridSize + levelIncrease)
                
                startRound()
            }
            .frame(width: 200)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("SurfaceCard"))
                .shadow(color: Color.black.opacity(0.3), radius: 20)
        )
        .padding(24)
    }
    
    private var gameOverOverlay: some View {
        VStack(spacing: 24) {
            if currentLevel >= maxLevel {
                SuccessCheckmark()
                Text("All Levels Complete!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            } else {
                FailureX()
                Text("Game Over")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            VStack(spacing: 8) {
                Text("Level Reached: \(currentLevel)")
                    .font(.system(size: 17))
                    .foregroundColor(Color("TextSecondary"))
                
                Text("Total Score: \(totalScore)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(accentColor))
            }
            
            PrimaryButton("See Results", icon: "chart.bar.fill", accentColor: accentColor) {
                HapticService.success()
                gameState = .results
            }
            .frame(width: 200)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("SurfaceCard"))
                .shadow(color: Color.black.opacity(0.3), radius: 20)
        )
        .padding(24)
    }
}

struct GridTile: View {
    let index: Int
    let isHighlighted: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let accentColor: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor, lineWidth: isHighlighted || isCorrect ? 3 : 1)
                )
                .scaleEffect(isHighlighted ? 1.08 : (isWrong ? 0.92 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHighlighted)
        .animation(.spring(response: 0.15), value: isCorrect)
        .animation(.easeInOut(duration: 0.08).repeatCount(3, autoreverses: true), value: isWrong)
    }
    
    private var tileColor: Color {
        if isHighlighted {
            return Color(accentColor)
        } else if isCorrect {
            return Color("Success").opacity(0.6)
        } else if isWrong {
            return Color("Danger").opacity(0.6)
        } else {
            return Color("SurfaceElevated")
        }
    }
    
    private var strokeColor: Color {
        if isHighlighted {
            return Color(accentColor)
        } else if isCorrect {
            return Color("Success")
        } else if isWrong {
            return Color("Danger")
        } else {
            return Color("StrokeSoft").opacity(0.5)
        }
    }
}
