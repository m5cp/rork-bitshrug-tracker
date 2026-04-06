import SwiftUI

struct FogBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    private var fogColor: Color {
        Color(red: 0.3, green: 0.75, blue: 0.45)
    }

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Color(.systemBackground)

                    Canvas { context, size in
                        let baseOpacity: Double = colorScheme == .dark ? 0.06 : 0.045

                        let blob1 = Path(ellipseIn: CGRect(
                            x: -size.width * 0.15,
                            y: -size.height * 0.1,
                            width: size.width * 0.7,
                            height: size.height * 0.45
                        ))
                        context.fill(blob1, with: .color(fogColor.opacity(baseOpacity)))

                        let blob2 = Path(ellipseIn: CGRect(
                            x: size.width * 0.5,
                            y: size.height * 0.35,
                            width: size.width * 0.65,
                            height: size.height * 0.4
                        ))
                        context.fill(blob2, with: .color(fogColor.opacity(baseOpacity * 0.7)))

                        let blob3 = Path(ellipseIn: CGRect(
                            x: size.width * 0.1,
                            y: size.height * 0.7,
                            width: size.width * 0.5,
                            height: size.height * 0.35
                        ))
                        context.fill(blob3, with: .color(fogColor.opacity(baseOpacity * 0.5)))
                    }
                    .blur(radius: 60)
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func fogBackground() -> some View {
        modifier(FogBackground())
    }
}
