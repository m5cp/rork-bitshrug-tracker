import SwiftUI

struct ScoreRingView: View {
    let progress: Double
    let label: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.08), lineWidth: size * 0.09)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.3), color, color],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * min(progress, 1.0))
                    ),
                    style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: progress)
                .shadow(color: color.opacity(0.4), radius: size * 0.08)
                .shadow(color: color.opacity(0.15), radius: size * 0.15)

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: size * 0.3, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text(label)
                    .font(.system(size: max(size * 0.1, 9), weight: .heavy))
                    .foregroundStyle(color)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
        }
        .frame(width: size, height: size)
    }
}
