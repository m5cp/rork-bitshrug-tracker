import SwiftUI

struct StyledDisclaimer: View {
    var showLastUpdated: Date? = nil

    var body: some View {
        VStack(spacing: 10) {
            if let updated = showLastUpdated {
                Text("Price updated \(updated.formatted(.relative(presentation: .named)))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange.opacity(0.5))

                Text("For educational purposes only. Not financial advice.")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            Text("Do not make financial decisions based on this app.")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.orange.opacity(0.04))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.orange.opacity(0.08), lineWidth: 1)
        )
        .padding(.top, 8)
    }
}
