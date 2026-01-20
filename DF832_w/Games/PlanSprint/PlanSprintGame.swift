import SwiftUI
import Combine
import UniformTypeIdentifiers

struct PlanSprintGame: View {
    let difficulty: DifficultyLevel
    @Binding var currentLevel: Int
    @Binding var totalScore: Int
    @Binding var perfectLevels: Int
    @Binding var gameState: GameContainerView.GameState
    let maxLevel: Int
    let trackID: String
    let accentColor: String
    
    @State private var tasks: [PlanSprintTask] = []
    @State private var rules: [PlanSprintRule] = []
    @State private var timeRemaining: Int = 60
    @State private var isTimerRunning = false
    @State private var roundScore = 0
    @State private var showLevelComplete = false
    @State private var showGameOver = false
    @State private var ruleResults: [(rule: PlanSprintRule, score: Double)] = []
    @State private var draggedTask: PlanSprintTask?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(difficulty: DifficultyLevel, currentLevel: Binding<Int>, totalScore: Binding<Int>, perfectLevels: Binding<Int>, gameState: Binding<GameContainerView.GameState>, maxLevel: Int, trackID: String, accentColor: String) {
        self.difficulty = difficulty
        self._currentLevel = currentLevel
        self._totalScore = totalScore
        self._perfectLevels = perfectLevels
        self._gameState = gameState
        self.maxLevel = maxLevel
        self.trackID = trackID
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Timer bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                    Text("\(timeRemaining)s")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(timeRemaining <= 10 ? Color("Danger") : Color("TextPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("SurfaceCard"))
                )
                
                Spacer()
                
                Text("Level \(currentLevel)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(accentColor))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(accentColor).opacity(0.15))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Rules section
            VStack(alignment: .leading, spacing: 8) {
                Text("Rules to Follow")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
                
                ForEach(rules) { rule in
                    HStack(spacing: 10) {
                        Image(systemName: rule.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(accentColor))
                            .frame(width: 24)
                        
                        Text(rule.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("SurfaceCard"))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Task list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        TaskCard(
                            task: task,
                            index: index,
                            accentColor: accentColor,
                            isDragging: draggedTask?.id == task.id
                        )
                        .onDrag {
                            draggedTask = task
                            return NSItemProvider(object: task.id as NSString)
                        }
                        .onDrop(of: [.text], delegate: TaskDropDelegate(
                            task: task,
                            tasks: $tasks,
                            draggedTask: $draggedTask
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Commit button
            VStack(spacing: 8) {
                PrimaryButton("Commit Order", icon: "checkmark.circle.fill", accentColor: accentColor) {
                    isTimerRunning = false
                    evaluateOrder()
                }
                .padding(.horizontal, 20)
                
                Text("Arrange tasks according to the rules above")
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextMuted"))
            }
            .padding(.vertical, 16)
            .background(
                Rectangle()
                    .fill(Color("BackgroundPrimary"))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, y: -5)
            )
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
            setupLevel()
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isTimerRunning = false
                evaluateOrder()
            }
        }
    }
    
    private func setupLevel() {
        isTimerRunning = false
        showLevelComplete = false
        showGameOver = false
        ruleResults = []
        
        rules = SeedData.getPlanSprintRules(forLevel: currentLevel)
        
        let taskTheme: String
        switch trackID {
        case TrackID.body.rawValue:
            taskTheme = "body"
        case TrackID.order.rawValue:
            taskTheme = "order"
        default:
            taskTheme = "general"
        }
        
        let allTasks = SeedData.planSprintTasks[taskTheme] ?? SeedData.planSprintTasks["general"]!
        
        // Task count: start with 4, add 1 every 2 levels, max 8
        let taskCount = min(allTasks.count, min(8, 4 + (currentLevel / 2)))
        tasks = Array(allTasks.shuffled().prefix(taskCount))
        
        // Time calculation: base time depends on difficulty and scales with tasks/rules
        let baseTime: Int
        switch difficulty {
        case .easy: baseTime = 90
        case .medium: baseTime = 70
        case .hard: baseTime = 50
        }
        
        // Add time for tasks and rules complexity
        let taskBonus = tasks.count * 5
        let ruleBonus = rules.count * 8
        let levelPenalty = currentLevel * 2
        
        timeRemaining = max(30, baseTime + taskBonus + ruleBonus - levelPenalty)
        
        // Start timer after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isTimerRunning = true
        }
    }
    
    private func evaluateOrder() {
        ruleResults = []
        var totalRuleScore: Double = 0
        
        for rule in rules {
            let score = rule.evaluate(tasks)
            ruleResults.append((rule: rule, score: score))
            totalRuleScore += score
        }
        
        let averageScore = rules.isEmpty ? 1.0 : totalRuleScore / Double(rules.count)
        
        // Score calculation
        let accuracyPoints = Int(averageScore * 100)
        let timeBonus = timeRemaining * 2
        let levelBonus = currentLevel * 15
        
        roundScore = Int(Double(accuracyPoints + timeBonus + levelBonus) * difficulty.scoreMultiplier)
        totalScore += roundScore
        
        if averageScore >= 0.95 {
            perfectLevels += 1
        }
        
        // Determine outcome
        if averageScore >= 0.5 {  // Pass threshold: 50%
            HapticService.success()
            if currentLevel >= maxLevel {
                showGameOver = true
                gameState = .gameOver
            } else {
                showLevelComplete = true
                gameState = .levelComplete
            }
        } else {
            HapticService.error()
            showGameOver = true
            gameState = .gameOver
        }
    }
    
    private var levelCompleteOverlay: some View {
        VStack(spacing: 20) {
            SuccessCheckmark()
            
            Text("Level \(currentLevel) Complete!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            // Rule breakdown
            VStack(spacing: 8) {
                ForEach(ruleResults, id: \.rule.id) { result in
                    HStack {
                        Image(systemName: result.rule.icon)
                            .foregroundColor(Color(accentColor))
                            .frame(width: 20)
                        Text(result.rule.title)
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                        Spacer()
                        Text("\(Int(result.score * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(result.score >= 0.8 ? Color("Success") : (result.score >= 0.5 ? Color("AccentC") : Color("Danger")))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("SurfaceElevated"))
            )
            
            Text("+\(roundScore) points")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(accentColor))
            
            PrimaryButton("Next Level", icon: "arrow.right", accentColor: accentColor) {
                HapticService.success()
                currentLevel += 1
                showLevelComplete = false
                gameState = .playing
                setupLevel()
            }
            .frame(width: 200)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("SurfaceCard"))
                .shadow(color: Color.black.opacity(0.3), radius: 20)
        )
        .padding(24)
    }
    
    private var gameOverOverlay: some View {
        VStack(spacing: 20) {
            let avgScore = ruleResults.isEmpty ? 0 : ruleResults.reduce(0) { $0 + $1.score } / Double(ruleResults.count)
            
            if currentLevel >= maxLevel && avgScore >= 0.5 {
                SuccessCheckmark()
                Text("All Levels Complete!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            } else if avgScore >= 0.5 {
                SuccessCheckmark()
                Text("Good Job!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            } else {
                FailureX()
                Text("Try Again")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            // Rule breakdown
            if !ruleResults.isEmpty {
                VStack(spacing: 8) {
                    ForEach(ruleResults, id: \.rule.id) { result in
                        HStack {
                            Image(systemName: result.rule.icon)
                                .foregroundColor(Color(accentColor))
                                .frame(width: 20)
                            Text(result.rule.title)
                                .font(.system(size: 14))
                                .foregroundColor(Color("TextSecondary"))
                            Spacer()
                            Text("\(Int(result.score * 100))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(result.score >= 0.8 ? Color("Success") : (result.score >= 0.5 ? Color("AccentC") : Color("Danger")))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("SurfaceElevated"))
                )
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
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("SurfaceCard"))
                .shadow(color: Color.black.opacity(0.3), radius: 20)
        )
        .padding(24)
    }
}

struct TaskCard: View {
    let task: PlanSprintTask
    let index: Int
    let accentColor: String
    var isDragging: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Position indicator
            Text("\(index + 1)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(accentColor))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color(accentColor).opacity(0.2))
                )
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                HStack(spacing: 8) {
                    Label(task.category.rawValue.capitalized, systemImage: categoryIcon)
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextMuted"))
                    
                    Label(energyLabel, systemImage: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundColor(energyColor)
                }
            }
            
            Spacer()
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextMuted"))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("SurfaceCard"))
                .shadow(color: isDragging ? Color.black.opacity(0.2) : Color.clear, radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDragging ? Color(accentColor) : Color("StrokeSoft").opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(isDragging ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isDragging)
    }
    
    private var categoryIcon: String {
        switch task.category {
        case .physical: return "figure.walk"
        case .mental: return "brain.head.profile"
        case .creative: return "lightbulb"
        case .organizational: return "folder"
        }
    }
    
    private var energyLabel: String {
        switch task.energyLevel {
        case .low: return "Low"
        case .medium: return "Med"
        case .high: return "High"
        }
    }
    
    private var energyColor: Color {
        switch task.energyLevel {
        case .low: return Color("Success")
        case .medium: return Color("AccentC")
        case .high: return Color("Danger")
        }
    }
}

struct TaskDropDelegate: DropDelegate {
    let task: PlanSprintTask
    @Binding var tasks: [PlanSprintTask]
    @Binding var draggedTask: PlanSprintTask?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedTask = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedTask = draggedTask,
              draggedTask.id != task.id,
              let fromIndex = tasks.firstIndex(where: { $0.id == draggedTask.id }),
              let toIndex = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        HapticService.selection()
        withAnimation(.easeInOut(duration: 0.2)) {
            tasks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
