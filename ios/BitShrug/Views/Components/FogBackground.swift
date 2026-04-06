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
                        let baseOpacity: Double = colorScheme == .dark ? 0.18 : 0.10

                        let blob1 = Path(ellipseIn: CGRect(
                            x: -size.width * 0.2,
                            y: -size.height * 0.08,
                            width: size.width * 0.8,
                            height: size.height * 0.5
                        ))
                        context.fill(blob1, with: .color(fogColor.opacity(baseOpacity)))

                        let blob2 = Path(ellipseIn: CGRect(
                            x: size.width * 0.45,
                            y: size.height * 0.3,
                            width: size.width * 0.7,
                            height: size.height * 0.45
                        ))
                        context.fill(blob2, with: .color(fogColor.opacity(baseOpacity * 0.7)))

                        let blob3 = Path(ellipseIn: CGRect(
                            x: size.width * 0.05,
                            y: size.height * 0.65,
                            width: size.width * 0.6,
                            height: size.height * 0.4
                        ))
                        context.fill(blob3, with: .color(fogColor.opacity(baseOpacity * 0.55)))

                        let blob4 = Path(ellipseIn: CGRect(
                            x: size.width * 0.3,
                            y: size.height * 0.1,
                            width: size.width * 0.5,
                            height: size.height * 0.3
                        ))
                        context.fill(blob4, with: .color(fogColor.opacity(baseOpacity * 0.4)))
                    }
                    .blur(radius: 50)
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
