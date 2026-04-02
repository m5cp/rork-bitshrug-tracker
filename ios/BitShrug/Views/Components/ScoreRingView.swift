import SwiftUI

struct ScoreRingView: View {
    let progress: Double
    let label: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.1), lineWidth: size * 0.08)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.4), color],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * min(progress, 1.0))
                    ),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: progress)
                .shadow(color: color.opacity(0.3), radius: size * 0.06)

            VStack(spacing: 1) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text(label)
                    .font(.system(size: max(size * 0.1, 9), weight: .semibold))
                    .foregroundStyle(color)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .frame(width: size, height: size)
    }
}
