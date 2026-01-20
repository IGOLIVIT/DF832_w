import SwiftUI

struct AppBackground: View {
    var style: BackgroundStyle = .primary
    
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()
            
            switch style {
            case .primary:
                primaryBackground
            case .focus:
                focusBackground
            case .body:
                bodyBackground
            case .mind:
                mindBackground
            case .order:
                orderBackground
            case .onboarding:
                onboardingBackground
            }
        }
    }
    
    private var primaryBackground: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentA").opacity(0.15),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentB").opacity(0.1),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 50,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    private var focusBackground: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentA").opacity(0.2),
                    Color.clear
                ]),
                center: .top,
                startRadius: 50,
                endRadius: 350
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentB").opacity(0.1),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 100,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    private var bodyBackground: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentB").opacity(0.2),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 350
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("Success").opacity(0.15),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 100,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    private var mindBackground: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentC").opacity(0.2),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 50,
                endRadius: 350
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentA").opacity(0.1),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    private var orderBackground: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("Success").opacity(0.2),
                    Color.clear
                ]),
                center: .top,
                startRadius: 50,
                endRadius: 350
            )
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("AccentB").opacity(0.1),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 100,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
    
    private var onboardingBackground: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundPrimary"),
                    Color("BackgroundSecondary")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Static decorative circles instead of random positions
            Circle()
                .fill(Color("AccentA").opacity(0.08))
                .frame(width: 300)
                .offset(x: -100, y: -200)
                .blur(radius: 50)
            
            Circle()
                .fill(Color("AccentB").opacity(0.06))
                .frame(width: 250)
                .offset(x: 150, y: 100)
                .blur(radius: 40)
            
            Circle()
                .fill(Color("AccentC").opacity(0.05))
                .frame(width: 200)
                .offset(x: -50, y: 300)
                .blur(radius: 35)
        }
        .ignoresSafeArea()
    }
}

enum BackgroundStyle {
    case primary
    case focus
    case body
    case mind
    case order
    case onboarding
    
    static func from(trackID: String) -> BackgroundStyle {
        switch trackID {
        case TrackID.focus.rawValue: return .focus
        case TrackID.body.rawValue: return .body
        case TrackID.mind.rawValue: return .mind
        case TrackID.order.rawValue: return .order
        default: return .primary
        }
    }
}

struct FloatingShapes: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color("AccentA").opacity(0.05))
                        .frame(width: 100 + CGFloat(i * 50))
                        .offset(
                            x: animate ? 20 : -20,
                            y: animate ? -30 : 30
                        )
                        .offset(x: CGFloat(i * 80) - 50, y: geo.size.height * 0.2 + CGFloat(i * 100))
                        .blur(radius: 30)
                }
                
                ForEach(0..<2) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("AccentB").opacity(0.05))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(animate ? 45 : 0))
                        .offset(
                            x: geo.size.width - 100 + (animate ? -20 : 20),
                            y: geo.size.height * 0.4 + CGFloat(i * 150)
                        )
                        .blur(radius: 20)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
