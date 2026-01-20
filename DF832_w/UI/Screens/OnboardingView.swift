import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var progressService: ProgressService
    @State private var currentPage = 0
    @State private var selectedTrackID: String? = nil
    @Binding var showOnboarding: Bool
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            AppBackground(style: .onboarding)
            FloatingShapes()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color("AccentA") : Color("SurfaceCard"))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            selectedTrackID: $selectedTrackID,
                            showTrackSelection: index == 1
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        PrimaryButton("Start Your Journey", icon: "arrow.right") {
                            completeOnboarding()
                        }
                    } else {
                        PrimaryButton("Continue", icon: "arrow.right") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                    
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        if let trackID = selectedTrackID {
            progressService.selectTrack(trackID)
        } else {
            progressService.selectTrack(TrackID.focus.rawValue)
        }
        progressService.completeOnboarding()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showOnboarding = false
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var selectedTrackID: String?
    var showTrackSelection: Bool = false
    
    @State private var appeared = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Icon/Illustration
                ZStack {
                    Circle()
                        .fill(Color(page.accentColor).opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color(page.accentColor).opacity(0.1))
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(Color(page.accentColor))
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
                
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
                    
                    Text(page.description)
                        .font(.system(size: 17))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .offset(y: appeared ? 0 : 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
                }
                .padding(.horizontal, 32)
                
                if showTrackSelection {
                    trackSelectionView
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
                }
                
                if !page.features.isEmpty {
                    featuresView
                        .offset(y: appeared ? 0 : 30)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            appeared = true
        }
        .onDisappear {
            appeared = false
        }
    }
    
    private var trackSelectionView: some View {
        VStack(spacing: 12) {
            ForEach(SeedData.tracks) { track in
                TrackCard(
                    track: track,
                    isSelected: selectedTrackID == track.id
                ) {
                    selectedTrackID = track.id
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var featuresView: some View {
        VStack(spacing: 16) {
            ForEach(page.features, id: \.title) { feature in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(page.accentColor).opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: feature.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(page.accentColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))
                        
                        Text(feature.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color("SurfaceCard"))
                )
            }
        }
        .padding(.horizontal, 24)
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: String
    let features: [OnboardingFeature]
    
    struct OnboardingFeature {
        let icon: String
        let title: String
        let description: String
    }
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "flame.fill",
            title: "Discipline Is Trained,\nNot Wished",
            description: "Build lasting habits through short, focused practice sessions. No magic tricks—just science-backed methods that work.",
            accentColor: "AccentC",
            features: []
        ),
        OnboardingPage(
            icon: "arrow.triangle.branch",
            title: "Choose Your Path",
            description: "Select a track that matches your goals. You can always switch later.",
            accentColor: "AccentA",
            features: []
        ),
        OnboardingPage(
            icon: "timer",
            title: "Quick Daily Drills",
            description: "Each drill takes just 2-5 minutes. Complete them daily to build your discipline muscle.",
            accentColor: "AccentB",
            features: [
                OnboardingFeature(
                    icon: "square.grid.3x3.fill",
                    title: "Focus Grid",
                    description: "Train attention and impulse control"
                ),
                OnboardingFeature(
                    icon: "list.bullet.rectangle.fill",
                    title: "Plan Sprint",
                    description: "Build planning and prioritization skills"
                )
            ]
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Track Your Growth",
            description: "Watch your streak heat rise, earn badges, and level up your ritual practice over time.",
            accentColor: "AccentC",
            features: [
                OnboardingFeature(
                    icon: "flame.fill",
                    title: "Streak Heat",
                    description: "Keep your daily practice going"
                ),
                OnboardingFeature(
                    icon: "star.fill",
                    title: "Badges & Titles",
                    description: "Unlock rewards as you progress"
                ),
                OnboardingFeature(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Ritual Level",
                    description: "See your discipline grow over time"
                )
            ]
        )
    ]
}
