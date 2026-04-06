import SwiftUI

struct CycleTimeMachineView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCycleIndex: Int = 0
    @State private var dayOffset: Double = 0
    @State private var appeared: Bool = false

    private let cycles = CycleHistoryData.epochs

    private var selectedCycle: CycleEpoch { cycles[selectedCycleIndex] }

    private var maxDays: Int {
        let cycle = selectedCycle
        if cycle.isCurrent {
            return Calendar.current.dateComponents([.day], from: cycle.halvingDate, to: Date()).day ?? 365
        }
        let nextIndex = selectedCycleIndex + 1
        if nextIndex < cycles.count {
            return Calendar.current.dateComponents([.day], from: cycle.halvingDate, to: cycles[nextIndex].halvingDate).day ?? 1460
        }
        return 1460
    }

    private var currentDay: Int { Int(dayOffset) }

    private var dateAtOffset: Date {
        Calendar.current.date(byAdding: .day, value: currentDay, to: selectedCycle.halvingDate) ?? selectedCycle.halvingDate
    }

    private var cycleProgress: Double {
        min(1.0, Double(currentDay) / 1460.0)
    }

    private var simulatedPhase: CyclePhase {
        CyclePhase(progress: cycleProgress)
    }

    private var priceContext: String {
        let cycle = selectedCycle
        let totalDays = Calendar.current.dateComponents([.day], from: cycle.cycleLowDate, to: cycle.cycleHighDate).day ?? 1
        let daysSinceLow = Calendar.current.dateComponents([.day], from: cycle.cycleLowDate, to: dateAtOffset).day ?? 0

        if dateAtOffset < cycle.cycleLowDate {
            return "Pre-cycle low — accumulation territory"
        } else if daysSinceLow <= totalDays {
            let progressToHigh = Double(daysSinceLow) / Double(totalDays)
            if progressToHigh < 0.3 { return "Early in the move — price building from the cycle low" }
            if progressToHigh < 0.6 { return "Acceleration phase — price appreciating rapidly" }
            if progressToHigh < 0.9 { return "Approaching cycle peak — euphoria building" }
            return "Near the cycle high — maximum FOMO territory"
        } else {
            return "Post-peak — drawdown in progress"
        }
    }

    private var estimatedScore: Int {
        let cycle = selectedCycle
        let daysSinceLow = Calendar.current.dateComponents([.day], from: cycle.cycleLowDate, to: dateAtOffset).day ?? 0
        let totalDays = Calendar.current.dateComponents([.day], from: cycle.cycleLowDate, to: cycle.cycleHighDate).day ?? 1

        if dateAtOffset < cycle.cycleLowDate {
            let daysBeforeLow = Calendar.current.dateComponents([.day], from: dateAtOffset, to: cycle.cycleLowDate).day ?? 0
            if daysBeforeLow > 180 { return Int.random(in: 25...40) }
            return Int.random(in: 15...30)
        }

        let progressToHigh = Double(daysSinceLow) / Double(totalDays)

        if progressToHigh < 0.0 { return max(10, min(35, 20 + Int(progressToHigh * 20))) }
        if progressToHigh < 0.15 { return max(25, min(50, 30 + Int(progressToHigh * 100))) }
        if progressToHigh < 0.35 { return max(40, min(65, 45 + Int(progressToHigh * 50))) }
        if progressToHigh < 0.55 { return max(55, min(80, 55 + Int(progressToHigh * 40))) }
        if progressToHigh < 0.75 { return max(65, min(90, 65 + Int(progressToHigh * 30))) }
        if progressToHigh < 0.95 { return max(75, min(95, Int(80 + progressToHigh * 15))) }
        if progressToHigh <= 1.0 { return max(80, min(98, Int(85 + progressToHigh * 10))) }

        let postPeakDays = daysSinceLow - totalDays
        let decay = min(60, postPeakDays / 5)
        return max(10, 80 - decay)
    }

    private var scoreColor: Color {
        AppColors.scoreColor(for: estimatedScore)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    cyclePicker

                    scoreCard

                    scrubber

                    phaseCard

                    contextCard

                    whatHappenedCard

                    disclaimer
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Cycle Time Machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                dayOffset = Double(maxDays)
                withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            }
            .onChange(of: selectedCycleIndex) { _, _ in
                dayOffset = Double(min(Int(dayOffset), maxDays))
            }
        }
    }

    private var cyclePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SELECT CYCLE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)

            HStack(spacing: 8) {
                ForEach(Array(cycles.enumerated()), id: \.element.id) { index, cycle in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedCycleIndex = index
                            dayOffset = Double(maxDays / 2)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("Cycle \(cycle.id)")
                                .font(.system(size: 12, weight: .bold))
                            Text(cycle.halvingDateFormatted.prefix(4))
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedCycleIndex == index
                                ? Color.orange.opacity(0.15)
                                : Color.primary.opacity(0.05)
                        )
                        .foregroundStyle(selectedCycleIndex == index ? .orange : .primary)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    selectedCycleIndex == index ? Color.orange.opacity(0.4) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .sensoryFeedback(.selection, trigger: selectedCycleIndex)
                }
            }
        }
    }

    private var scoreCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.1), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: Double(estimatedScore) / 100.0)
                        .stroke(
                            AngularGradient(
                                colors: [scoreColor.opacity(0.3), scoreColor],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(-90 + 360 * Double(estimatedScore) / 100.0)
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.5), value: estimatedScore)

                    VStack(spacing: 2) {
                        Text("\(estimatedScore)")
                            .font(.system(size: 28, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("EST.")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                }
                .frame(width: 90, height: 90)

                VStack(alignment: .leading, spacing: 6) {
                    Text("ESTIMATED SCORE")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)

                    Text(dateAtOffset.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    Text(priceContext)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
        .premiumCard(.accent)
    }

    private var scrubber: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Day \(currentDay)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Text("of ~\(maxDays)")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            Slider(value: $dayOffset, in: 0...Double(maxDays), step: 1)
                .tint(.orange)
                .sensoryFeedback(.selection, trigger: Int(dayOffset / 30))

            HStack {
                Text("Halving")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(selectedCycle.isCurrent ? "Today" : "Next Halving")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.primary.opacity(0.05))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var phaseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "arrow.triangle.2.circlepath", title: "CYCLE PHASE")

            HStack(spacing: 12) {
                Image(systemName: simulatedPhase.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(simulatedPhase.color)
                    .frame(width: 36, height: 36)
                    .background(simulatedPhase.color.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(simulatedPhase.label)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text("\(Int(cycleProgress * 100))% through the cycle")
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(simulatedPhase.description)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .premiumCard(.highlighted)
    }

    private var contextCard: some View {
        let cycle = selectedCycle

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "chart.bar.doc.horizontal", title: "CYCLE STATS")

            VStack(spacing: 8) {
                statRow(label: "Cycle Low", value: "$\(Int(cycle.cycleLowPrice).formatted(.number))")
                statRow(label: "Cycle High", value: "$\(Int(cycle.cycleHighPrice).formatted(.number))")
                if let ret = cycle.returnPercent {
                    statRow(label: "Return", value: "\(Int(ret).formatted(.number))%")
                }
                statRow(label: "Max Drawdown", value: "\(String(format: "%.1f", cycle.drawdownPercent))%")
                statRow(label: "Low → High", value: "\(cycle.lowToHighDays) days")
            }
        }
        .premiumCard()
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

    private var whatHappenedCard: some View {
        let cycle = selectedCycle
        let peakDaysSinceHalving = Calendar.current.dateComponents([.day], from: cycle.halvingDate, to: cycle.cycleHighDate).day ?? 0
        let isBeforePeak = currentDay < peakDaysSinceHalving
        let daysUntilPeak = peakDaysSinceHalving - currentDay

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "clock.arrow.circlepath", iconColor: .blue, title: "WHAT HAPPENED NEXT")

            if isBeforePeak {
                Text("The cycle peak was \(daysUntilPeak) days away at $\(Int(cycle.cycleHighPrice).formatted(.number)).")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if !cycle.isCurrent {
                    Text("After the peak, the market drew down \(String(format: "%.0f", abs(cycle.drawdownPercent)))% over the following \(cycle.highToLowMonths ?? 0) months.")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                let daysSincePeak = currentDay - peakDaysSinceHalving
                Text("The cycle peaked \(daysSincePeak) days ago. The market was in a post-peak drawdown.")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                if !cycle.isCurrent {
                    Text("The drawdown eventually reached \(String(format: "%.0f", abs(cycle.drawdownPercent)))% before the next accumulation phase began.")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .premiumCard()
    }

    private var disclaimer: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
            Text("Estimated scores are simulated based on historical cycle patterns and are not actual Environment Scores. Past performance does not predict future results.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
                .lineSpacing(2)
        }
        .padding(14)
    }
}
