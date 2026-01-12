import SwiftUI

/// App Icon Generator View
/// Run this in a SwiftUI preview to screenshot your app icon
struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.52, blue: 1.0),  // Bright blue
                    Color(red: 0.0, green: 0.4, blue: 0.8)      // Darker blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Circular route path
            Circle()
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 16,
                        lineCap: .round,
                        dash: [20, 12]
                    )
                )
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 700, height: 700)
            
            // Direction arrows
            ForEach(0..<4) { i in
                Image(systemName: "arrow.right")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(Double(i) * 90))
                    .offset(x: cos(Double(i) * .pi / 2 - .pi / 4) * 350,
                           y: sin(Double(i) * .pi / 2 - .pi / 4) * 350)
            }
            
            // Center runner icon
            ZStack {
                // White circle background for runner
                Circle()
                    .fill(.white)
                    .frame(width: 420, height: 420)
                
                // Runner icon
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 350))
                    .foregroundColor(Color(red: 0.04, green: 0.52, blue: 1.0))
            }
            
            // Green start indicator
            Circle()
                .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "location.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
                .offset(x: 0, y: -420)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Alternative Minimal Design

struct AppIconGeneratorMinimal: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.52, blue: 1.0),
                    Color(red: 0.0, green: 0.3, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Simple route circle
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.white.opacity(0.3))
                .frame(width: 800, height: 800)
            
            Circle()
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round,
                        dash: [40, 20]
                    )
                )
                .foregroundColor(.white)
                .frame(width: 800, height: 800)
                .rotationEffect(.degrees(-90))
            
            // Runner
            Image(systemName: "figure.run")
                .font(.system(size: 400, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Alternative Bold Design

struct AppIconGeneratorBold: View {
    var body: some View {
        ZStack {
            // Background - More vibrant
            RadialGradient(
                colors: [
                    Color(red: 0.1, green: 0.6, blue: 1.0),
                    Color(red: 0.0, green: 0.35, blue: 0.8)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
            // Route with glow effect
            Circle()
                .stroke(lineWidth: 40)
                .foregroundColor(.white.opacity(0.2))
                .frame(width: 650, height: 650)
            
            Circle()
                .stroke(lineWidth: 24)
                .foregroundColor(.white)
                .frame(width: 650, height: 650)
                .shadow(color: .white.opacity(0.5), radius: 20)
            
            // Arrows indicating direction
            ForEach([45.0, 135.0, 225.0, 315.0], id: \.self) { angle in
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    .rotationEffect(.degrees(angle))
                    .offset(
                        x: cos(angle * .pi / 180) * 325,
                        y: sin(angle * .pi / 180) * 325
                    )
            }
            
            // Bold runner
            Image(systemName: "figure.run")
                .font(.system(size: 450, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Preview

struct AppIconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppIconGenerator()
                .previewDisplayName("Main Design")
            
            AppIconGeneratorMinimal()
                .previewDisplayName("Minimal")
            
            AppIconGeneratorBold()
                .previewDisplayName("Bold")
        }
    }
}
