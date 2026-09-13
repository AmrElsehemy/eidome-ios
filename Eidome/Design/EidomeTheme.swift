import SwiftUI

enum EidomeTheme {
    static let background = Color(red: 0.015, green: 0.035, blue: 0.04)
    static let panel = Color.white.opacity(0.07)
    static let panelStrong = Color.white.opacity(0.11)
    static let violet = Color(red: 0.36, green: 0.52, blue: 1.0)
    static let cyan = Color(red: 0.35, green: 0.94, blue: 0.72)
    static let secondaryText = Color.white.opacity(0.62)
    static let line = Color.white.opacity(0.12)

    static let backgroundGradient = LinearGradient(
        colors: [background, Color(red: 0.035, green: 0.11, blue: 0.105)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct EidomePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [EidomeTheme.violet, EidomeTheme.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(EidomeTheme.panel, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(EidomeTheme.line, lineWidth: 1)
            }
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassCard()) }
}

struct EidomeWordmark: View {
    var compact = false

    var body: some View {
        Text("EIDOME")
            .font(compact ? .caption.weight(.bold) : .system(size: 40, weight: .semibold, design: .rounded))
            .tracking(compact ? 2.5 : 7)
            .foregroundStyle(.white)
            .accessibilityLabel("Eidome")
    }
}

struct OrbitalTwinMark: View {
    var animated = false
    @State private var orbitRotation = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(EidomeTheme.cyan.opacity(0.28), lineWidth: 1)

            Ellipse()
                .stroke(
                    LinearGradient(colors: [EidomeTheme.violet, EidomeTheme.cyan], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1.2
                )
                .frame(height: 92)
                .rotationEffect(.degrees(14 + orbitRotation))

            Ellipse()
                .stroke(EidomeTheme.cyan.opacity(0.55), lineWidth: 1)
                .frame(height: 118)
                .rotationEffect(.degrees(-64 - orbitRotation * 0.72))

            Circle()
                .fill(EidomeTheme.violet.opacity(0.16))
                .frame(width: 150, height: 150)
                .blur(radius: 12)

            Image(systemName: "figure.stand")
                .font(.system(size: 104, weight: .ultraLight))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, EidomeTheme.cyan)
        }
        .onAppear {
            guard animated else { return }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                orbitRotation = 360
            }
        }
        .accessibilityHidden(true)
    }
}
