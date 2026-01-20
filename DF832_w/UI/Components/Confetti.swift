import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [String] = ["AccentA", "AccentB", "AccentC", "Success"]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        for i in 0..<50 {
            let particle = ConfettiParticle(
                id: i,
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                targetY: size.height + 50,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                colorName: colors.randomElement() ?? "AccentA",
                delay: Double(i) * 0.02,
                duration: Double.random(in: 2...3)
            )
            particles.append(particle)
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let targetY: CGFloat
    let rotation: Double
    let scale: CGFloat
    let colorName: String
    let delay: Double
    let duration: Double
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    @State private var animate = false
    
    var body: some View {
        let shape = Int.random(in: 0...2)
        
        Group {
            if shape == 0 {
                Circle()
                    .fill(Color(particle.colorName))
                    .frame(width: 8 * particle.scale, height: 8 * particle.scale)
            } else if shape == 1 {
                Rectangle()
                    .fill(Color(particle.colorName))
                    .frame(width: 6 * particle.scale, height: 10 * particle.scale)
            } else {
                Capsule()
                    .fill(Color(particle.colorName))
                    .frame(width: 4 * particle.scale, height: 12 * particle.scale)
            }
        }
        .rotationEffect(.degrees(animate ? particle.rotation + 360 : particle.rotation))
        .offset(
            x: particle.x + (animate ? CGFloat.random(in: -30...30) : 0),
            y: animate ? particle.targetY : particle.y
        )
        .opacity(animate ? 0 : 1)
        .onAppear {
            withAnimation(.easeOut(duration: particle.duration).delay(particle.delay)) {
                animate = true
            }
        }
    }
}

struct SuccessCheckmark: View {
    @State private var showCheck = false
    @State private var showRing = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("Success").opacity(0.3), lineWidth: 4)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: showRing ? 1 : 0)
                .stroke(Color("Success"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color("Success"))
                .scaleEffect(showCheck ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showRing = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                showCheck = true
            }
        }
    }
}

struct FailureX: View {
    @State private var showX = false
    @State private var showRing = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("Danger").opacity(0.3), lineWidth: 4)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: showRing ? 1 : 0)
                .stroke(Color("Danger"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: "xmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color("Danger"))
                .scaleEffect(showX ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showRing = true
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
                showX = true
            }
        }
    }
}
