import SwiftUI

struct ContentView: View {
    @EnvironmentObject var progressService: ProgressService
    @State private var showOnboarding: Bool = true
    
    var body: some View {
        Group {
            if showOnboarding && !progressService.progress.hasCompletedOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                MainTabView(progressService: progressService)
            }
        }
        .onAppear {
            showOnboarding = !progressService.progress.hasCompletedOnboarding
        }
    }
}
