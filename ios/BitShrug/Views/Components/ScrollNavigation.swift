import SwiftUI

struct SectionAnchor: Hashable, Sendable {
    let id: String
    let icon: String
    let label: String
}

struct SectionJumpBar: View {
    let sections: [SectionAnchor]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sections, id: \.id) { section in
                    Button {
                        onSelect(section.id)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: section.icon)
                                .font(.system(size: 10, weight: .bold))
                            Text(section.label)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .sensoryFeedback(.selection, trigger: section.id)
                }
            }
        }
        .contentMargins(.horizontal, 20)
    }
}

struct FloatingScrollToTopButton: View {
    let isVisible: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 44, height: 44)
                        .background(.orange.opacity(0.85))
                        .clipShape(Circle())
                        .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 16)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.6)
        .animation(.spring(duration: 0.3), value: isVisible)
        .allowsHitTesting(isVisible)
    }
}
