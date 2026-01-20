import Foundation

enum SeedData {
    
    // MARK: - Tracks
    
    static let tracks: [Track] = [
        Track(
            id: TrackID.focus.rawValue,
            title: "Focus",
            subtitle: "Attention & Impulse Control",
            description: "Train your ability to concentrate, resist distractions, and maintain deep focus for longer periods. Perfect for improving work sessions and reducing scattered thinking.",
            icon: "eye.fill",
            accentColorName: "AccentA",
            secondaryAccentColorName: "AccentB",
            recommendedDrillIDs: ["focus_grid_basic", "focus_grid_advanced"]
        ),
        Track(
            id: TrackID.body.rawValue,
            title: "Body",
            subtitle: "Physical Discipline & Energy",
            description: "Build habits around movement, posture, and physical awareness. These drills help you stay energized and maintain body-mind connection throughout the day.",
            icon: "figure.run",
            accentColorName: "AccentB",
            secondaryAccentColorName: "Success",
            recommendedDrillIDs: ["plan_sprint_body", "focus_grid_basic"]
        ),
        Track(
            id: TrackID.mind.rawValue,
            title: "Mind",
            subtitle: "Mental Clarity & Planning",
            description: "Strengthen your planning abilities, decision-making, and mental organization. Learn to prioritize effectively and think clearly under pressure.",
            icon: "brain.head.profile.fill",
            accentColorName: "AccentC",
            secondaryAccentColorName: "AccentA",
            recommendedDrillIDs: ["plan_sprint_mind", "plan_sprint_advanced"]
        ),
        Track(
            id: TrackID.order.rawValue,
            title: "Order",
            subtitle: "Consistency & Systems",
            description: "Master the art of routine and systematic thinking. Build reliable habits and create order in your daily life through consistent practice.",
            icon: "square.stack.3d.up.fill",
            accentColorName: "Success",
            secondaryAccentColorName: "AccentB",
            recommendedDrillIDs: ["plan_sprint_order", "focus_grid_advanced"]
        )
    ]
    
    // MARK: - Drills
    
    static let drills: [Drill] = [
        // Focus Grid Drills
        Drill(
            id: "focus_grid_basic",
            title: "Focus Grid",
            trackID: TrackID.focus.rawValue,
            gameType: .focusGrid,
            durationOptions: [2, 3, 5],
            difficultyLevels: [.easy, .medium, .hard],
            shortDescription: "Remember and repeat visual sequences",
            longDescription: "Focus Grid challenges your visual memory and attention control. Watch tiles light up in sequence, then repeat the pattern. As you progress, sequences get longer and faster, training your brain to hold more information while resisting the urge to guess.",
            howItHelps: [
                "Improves working memory capacity",
                "Builds impulse control by requiring patience",
                "Trains sustained attention over short bursts",
                "Reduces mental wandering during tasks"
            ],
            levels: generateFocusGridLevels(),
            icon: "square.grid.3x3.fill"
        ),
        Drill(
            id: "focus_grid_advanced",
            title: "Focus Grid Pro",
            trackID: TrackID.focus.rawValue,
            gameType: .focusGrid,
            durationOptions: [3, 5],
            difficultyLevels: [.medium, .hard],
            shortDescription: "Advanced pattern recognition",
            longDescription: "A more challenging version of Focus Grid with larger grids, faster sequences, and stricter timing. Designed for those who have mastered the basics and want to push their focus limits.",
            howItHelps: [
                "Expands visual processing speed",
                "Develops expert-level pattern recognition",
                "Builds confidence under time pressure",
                "Creates mental resilience"
            ],
            levels: generateFocusGridLevels(advanced: true),
            icon: "square.grid.4x3.fill"
        ),
        
        // Plan Sprint Drills
        Drill(
            id: "plan_sprint_mind",
            title: "Plan Sprint",
            trackID: TrackID.mind.rawValue,
            gameType: .planSprint,
            durationOptions: [2, 3, 5],
            difficultyLevels: [.easy, .medium, .hard],
            shortDescription: "Organize tasks by priority",
            longDescription: "Plan Sprint trains your ability to sequence activities effectively. Given a list of micro-tasks and ordering rules, arrange them in the optimal order before time runs out. Learn to think systematically about task dependencies and energy management.",
            howItHelps: [
                "Develops systematic thinking",
                "Improves decision-making speed",
                "Builds intuition for task prioritization",
                "Reduces overwhelm when facing multiple tasks"
            ],
            levels: generatePlanSprintLevels(),
            icon: "list.bullet.rectangle.fill"
        ),
        Drill(
            id: "plan_sprint_body",
            title: "Body Planner",
            trackID: TrackID.body.rawValue,
            gameType: .planSprint,
            durationOptions: [2, 3],
            difficultyLevels: [.easy, .medium],
            shortDescription: "Sequence physical activities",
            longDescription: "Apply planning skills to physical routines. Arrange warm-ups, exercises, and cool-downs in the right order. Learn how proper sequencing maximizes energy and prevents injury.",
            howItHelps: [
                "Teaches proper workout sequencing",
                "Builds awareness of body preparation",
                "Connects mental planning to physical action",
                "Creates sustainable exercise habits"
            ],
            levels: generatePlanSprintLevels(theme: .body),
            icon: "figure.walk"
        ),
        Drill(
            id: "plan_sprint_order",
            title: "Order Builder",
            trackID: TrackID.order.rawValue,
            gameType: .planSprint,
            durationOptions: [3, 5],
            difficultyLevels: [.medium, .hard],
            shortDescription: "Create optimal daily routines",
            longDescription: "Master the art of daily routine design. Arrange morning, afternoon, and evening tasks considering energy levels, dependencies, and efficiency. Build the mental framework for consistent daily systems.",
            howItHelps: [
                "Strengthens routine-building skills",
                "Develops time-blocking intuition",
                "Teaches energy management principles",
                "Creates foundation for lasting habits"
            ],
            levels: generatePlanSprintLevels(theme: .order),
            icon: "calendar.badge.clock"
        ),
        Drill(
            id: "plan_sprint_advanced",
            title: "Sprint Master",
            trackID: TrackID.mind.rawValue,
            gameType: .planSprint,
            durationOptions: [5],
            difficultyLevels: [.hard],
            shortDescription: "Complex multi-constraint planning",
            longDescription: "The ultimate planning challenge. Handle multiple simultaneous constraints, longer task lists, and tighter time limits. For those who want to develop elite-level planning abilities.",
            howItHelps: [
                "Builds expert-level sequencing skills",
                "Develops multi-constraint reasoning",
                "Creates calm under planning pressure",
                "Prepares for complex real-world decisions"
            ],
            levels: generatePlanSprintLevels(advanced: true),
            icon: "bolt.fill"
        )
    ]
    
    // MARK: - Badges
    
    static let badges: [Badge] = [
        Badge(
            id: "first_spark",
            title: "First Spark",
            description: "Complete your first drill and begin your discipline journey",
            icon: "sparkle",
            criteria: BadgeCriteria(type: .completeDrills, value: 1),
            rarity: .common
        ),
        Badge(
            id: "two_day_temper",
            title: "Two-Day Temper",
            description: "Maintain a 2-day practice streak",
            icon: "flame",
            criteria: BadgeCriteria(type: .streakDays, value: 2),
            rarity: .common
        ),
        Badge(
            id: "seven_day_steel",
            title: "Seven-Day Steel",
            description: "Maintain a 7-day practice streak",
            icon: "flame.fill",
            criteria: BadgeCriteria(type: .streakDays, value: 7),
            rarity: .rare
        ),
        Badge(
            id: "fourteen_day_iron",
            title: "Fourteen-Day Iron",
            description: "Maintain a 14-day practice streak",
            icon: "bolt.shield.fill",
            criteria: BadgeCriteria(type: .streakDays, value: 14),
            rarity: .epic
        ),
        Badge(
            id: "thirty_day_diamond",
            title: "Thirty-Day Diamond",
            description: "Maintain a 30-day practice streak",
            icon: "crown.fill",
            criteria: BadgeCriteria(type: .streakDays, value: 30),
            rarity: .legendary
        ),
        Badge(
            id: "focused_hands",
            title: "Focused Hands",
            description: "Score 80+ points in Focus Grid",
            icon: "hand.raised.fill",
            criteria: BadgeCriteria(type: .scoreInDrill, value: 80, drillID: "focus_grid_basic"),
            rarity: .uncommon
        ),
        Badge(
            id: "eagle_eye",
            title: "Eagle Eye",
            description: "Score 150+ points in Focus Grid Pro",
            icon: "eye.circle.fill",
            criteria: BadgeCriteria(type: .scoreInDrill, value: 150, drillID: "focus_grid_advanced"),
            rarity: .rare
        ),
        Badge(
            id: "planners_pulse",
            title: "Planner's Pulse",
            description: "Complete level 5 in Plan Sprint",
            icon: "heart.circle.fill",
            criteria: BadgeCriteria(type: .completeLevelInGame, value: 5, gameType: "planSprint"),
            rarity: .uncommon
        ),
        Badge(
            id: "master_planner",
            title: "Master Planner",
            description: "Complete level 10 in Plan Sprint",
            icon: "star.circle.fill",
            criteria: BadgeCriteria(type: .completeLevelInGame, value: 10, gameType: "planSprint"),
            rarity: .epic
        ),
        Badge(
            id: "consistency_core",
            title: "Consistency Core",
            description: "Complete 20 drills total",
            icon: "arrow.triangle.2.circlepath",
            criteria: BadgeCriteria(type: .completeDrills, value: 20),
            rarity: .uncommon
        ),
        Badge(
            id: "drill_devotee",
            title: "Drill Devotee",
            description: "Complete 50 drills total",
            icon: "arrow.triangle.2.circlepath.circle.fill",
            criteria: BadgeCriteria(type: .completeDrills, value: 50),
            rarity: .rare
        ),
        Badge(
            id: "heat_keeper",
            title: "Heat Keeper",
            description: "Practice on 5 different days in a single week",
            icon: "thermometer.sun.fill",
            criteria: BadgeCriteria(type: .weeklyDays, value: 5),
            rarity: .uncommon
        ),
        Badge(
            id: "perfect_week",
            title: "Perfect Week",
            description: "Practice every day for a full week",
            icon: "checkmark.seal.fill",
            criteria: BadgeCriteria(type: .weeklyDays, value: 7),
            rarity: .rare
        ),
        Badge(
            id: "calm_under_timer",
            title: "Calm Under Timer",
            description: "Complete a timed level with zero mistakes",
            icon: "timer.circle.fill",
            criteria: BadgeCriteria(type: .perfectLevel, value: 1),
            rarity: .uncommon
        ),
        Badge(
            id: "ritual_level_5",
            title: "Ritual Adept",
            description: "Reach Ritual Level 5",
            icon: "5.circle.fill",
            criteria: BadgeCriteria(type: .ritualLevel, value: 5),
            rarity: .uncommon
        ),
        Badge(
            id: "ritual_level_10",
            title: "Ritual Master",
            description: "Reach Ritual Level 10",
            icon: "10.circle.fill",
            criteria: BadgeCriteria(type: .ritualLevel, value: 10),
            rarity: .rare
        ),
        Badge(
            id: "hour_invested",
            title: "Hour Invested",
            description: "Spend 60 minutes total in training",
            icon: "clock.fill",
            criteria: BadgeCriteria(type: .totalMinutes, value: 60),
            rarity: .uncommon
        ),
        Badge(
            id: "time_master",
            title: "Time Master",
            description: "Spend 300 minutes total in training",
            icon: "clock.badge.checkmark.fill",
            criteria: BadgeCriteria(type: .totalMinutes, value: 300),
            rarity: .epic
        )
    ]
    
    // MARK: - Level Generators
    
    private static func generateFocusGridLevels(advanced: Bool = false) -> [DrillLevel] {
        var levels: [DrillLevel] = []
        let baseGrid = advanced ? 5 : 4
        let baseSequence = advanced ? 4 : 3
        
        for i in 1...10 {
            let gridIncrease = (i - 1) / 4
            let sequenceIncrease = (i - 1) / 2
            
            levels.append(DrillLevel(
                id: i,
                number: i,
                target: 100 + (i * 20),
                timeLimit: max(8, 15 - i),
                allowedMistakes: max(0, 2 - (i / 4)),
                difficultyMultiplier: 1.0 + (Double(i - 1) * 0.15),
                sequenceLength: min(8, baseSequence + sequenceIncrease),
                gridSize: min(6, baseGrid + gridIncrease)
            ))
        }
        
        return levels
    }
    
    private static func generatePlanSprintLevels(theme: PlanSprintTheme = .general, advanced: Bool = false) -> [DrillLevel] {
        var levels: [DrillLevel] = []
        let baseTaskCount = advanced ? 8 : 6
        
        for i in 1...10 {
            let taskIncrease = (i - 1) / 2
            
            levels.append(DrillLevel(
                id: i,
                number: i,
                target: min(14, baseTaskCount + taskIncrease),
                timeLimit: max(20, 45 - (i * 2)),
                allowedMistakes: 0,
                difficultyMultiplier: 1.0 + (Double(i - 1) * 0.1),
                sequenceLength: 1 + (i / 4),
                gridSize: 0
            ))
        }
        
        return levels
    }
    
    enum PlanSprintTheme {
        case general
        case body
        case order
    }
    
    // MARK: - Plan Sprint Tasks
    
    static let planSprintTasks: [String: [PlanSprintTask]] = [
        "general": [
            PlanSprintTask(id: "check_email", title: "Check email", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "write_notes", title: "Write 3 key notes", category: .mental, energyLevel: .medium, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "clear_desk", title: "Clear desk", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "deep_work", title: "Deep work session", category: .mental, energyLevel: .high, duration: .long, prerequisites: ["clear_desk"]),
            PlanSprintTask(id: "quick_stretch", title: "Quick stretch", category: .physical, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "review_goals", title: "Review daily goals", category: .mental, energyLevel: .medium, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "plan_tomorrow", title: "Plan tomorrow", category: .organizational, energyLevel: .low, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "creative_brainstorm", title: "Creative brainstorm", category: .creative, energyLevel: .high, duration: .medium, prerequisites: ["review_goals"]),
            PlanSprintTask(id: "file_documents", title: "File documents", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "focus_break", title: "Focus break", category: .physical, energyLevel: .low, duration: .quick, prerequisites: ["deep_work"]),
            PlanSprintTask(id: "reply_messages", title: "Reply to messages", category: .organizational, energyLevel: .medium, duration: .medium, prerequisites: ["check_email"]),
            PlanSprintTask(id: "learn_something", title: "Learn something new", category: .mental, energyLevel: .high, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "water_plants", title: "Water plants", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "meditate", title: "5-min meditation", category: .mental, energyLevel: .low, duration: .quick, prerequisites: [])
        ],
        "body": [
            PlanSprintTask(id: "warmup", title: "Warm up joints", category: .physical, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "cardio", title: "Cardio burst", category: .physical, energyLevel: .high, duration: .medium, prerequisites: ["warmup"]),
            PlanSprintTask(id: "strength", title: "Strength set", category: .physical, energyLevel: .high, duration: .medium, prerequisites: ["warmup"]),
            PlanSprintTask(id: "cooldown", title: "Cool down stretch", category: .physical, energyLevel: .low, duration: .quick, prerequisites: ["cardio", "strength"]),
            PlanSprintTask(id: "hydrate", title: "Hydrate well", category: .physical, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "posture_check", title: "Posture check", category: .physical, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "walk", title: "10-min walk", category: .physical, energyLevel: .medium, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "balance", title: "Balance exercise", category: .physical, energyLevel: .medium, duration: .quick, prerequisites: ["warmup"]),
            PlanSprintTask(id: "breathing", title: "Deep breathing", category: .physical, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "foam_roll", title: "Foam rolling", category: .physical, energyLevel: .low, duration: .medium, prerequisites: ["cooldown"])
        ],
        "order": [
            PlanSprintTask(id: "morning_routine", title: "Morning routine", category: .organizational, energyLevel: .medium, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "inbox_zero", title: "Inbox zero", category: .organizational, energyLevel: .medium, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "meal_prep", title: "Meal prep", category: .organizational, energyLevel: .medium, duration: .long, prerequisites: []),
            PlanSprintTask(id: "weekly_review", title: "Weekly review", category: .organizational, energyLevel: .high, duration: .long, prerequisites: []),
            PlanSprintTask(id: "tidy_space", title: "Tidy workspace", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "backup_files", title: "Backup files", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "update_calendar", title: "Update calendar", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: []),
            PlanSprintTask(id: "declutter", title: "Declutter drawer", category: .organizational, energyLevel: .medium, duration: .medium, prerequisites: []),
            PlanSprintTask(id: "set_reminders", title: "Set reminders", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: ["update_calendar"]),
            PlanSprintTask(id: "evening_review", title: "Evening review", category: .organizational, energyLevel: .low, duration: .quick, prerequisites: [])
        ]
    ]
    
    // MARK: - Plan Sprint Rules
    
    static func getPlanSprintRules(forLevel level: Int) -> [PlanSprintRule] {
        var rules: [PlanSprintRule] = []
        
        rules.append(PlanSprintRule(
            id: "quick_first",
            title: "Quick Wins First",
            description: "Start with quick tasks to build momentum",
            icon: "bolt.fill"
        ) { tasks in
            guard tasks.count >= 2 else { return 1.0 }
            let firstThird = tasks.prefix(tasks.count / 3 + 1)
            let quickCount = firstThird.filter { $0.duration == .quick }.count
            return Double(quickCount) / Double(firstThird.count)
        })
        
        if level >= 3 {
            rules.append(PlanSprintRule(
                id: "prerequisites",
                title: "Follow Prerequisites",
                description: "Complete required tasks before dependent ones",
                icon: "arrow.right.circle.fill"
            ) { tasks in
                var completed: Set<String> = []
                var violations = 0
                for task in tasks {
                    for prereq in task.prerequisites {
                        if !completed.contains(prereq) {
                            violations += 1
                        }
                    }
                    completed.insert(task.id)
                }
                let maxViolations = tasks.flatMap { $0.prerequisites }.count
                return maxViolations > 0 ? 1.0 - (Double(violations) / Double(maxViolations)) : 1.0
            })
        }
        
        if level >= 5 {
            rules.append(PlanSprintRule(
                id: "energy_curve",
                title: "Energy Management",
                description: "High energy tasks in the middle, low at ends",
                icon: "waveform.path.ecg"
            ) { tasks in
                guard tasks.count >= 4 else { return 1.0 }
                let middleStart = tasks.count / 3
                let middleEnd = tasks.count * 2 / 3
                let middleTasks = Array(tasks[middleStart..<middleEnd])
                let highEnergyInMiddle = middleTasks.filter { $0.energyLevel == .high }.count
                let totalHighEnergy = tasks.filter { $0.energyLevel == .high }.count
                return totalHighEnergy > 0 ? Double(highEnergyInMiddle) / Double(totalHighEnergy) : 1.0
            })
        }
        
        if level >= 7 {
            rules.append(PlanSprintRule(
                id: "group_similar",
                title: "Group Similar",
                description: "Keep same-category tasks together",
                icon: "square.stack.3d.up.fill"
            ) { tasks in
                guard tasks.count >= 3 else { return 1.0 }
                var switches = 0
                for i in 1..<tasks.count {
                    if tasks[i].category != tasks[i-1].category {
                        switches += 1
                    }
                }
                let minSwitches = Set(tasks.map { $0.category }).count - 1
                let maxSwitches = tasks.count - 1
                let range = maxSwitches - minSwitches
                return range > 0 ? 1.0 - (Double(switches - minSwitches) / Double(range)) : 1.0
            })
        }
        
        return rules
    }
}
