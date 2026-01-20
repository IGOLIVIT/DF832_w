import SwiftUI

@main
struct DF832_wApp: App {
    @StateObject private var progressService = ProgressService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressService)
                .preferredColorScheme(.dark)
        }
    }
}
