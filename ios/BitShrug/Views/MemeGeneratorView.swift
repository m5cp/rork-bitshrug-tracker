import SwiftUI

struct MemeGeneratorView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: MemeTemplate = MemeTemplate.templates[0]
    @State private var topText: String = ""
    @State private var bottomText: String = ""
    @State private var isEditing: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var renderedImage: UIImage?
    @State private var showLiveData: Bool = true
    @State private var showImagePreview: Bool = false
    @State private var premium = PremiumManager.shared
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    memePreview
                        .padding(.top, 8)

                    templatePicker

                    editControls

                    liveDataToggle

                    renderButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Meme Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { isTextFieldFocused = false }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image])
                }
            }
            .fullScreenCover(isPresented: $showImagePreview) {
                if let image = renderedImage {
                    MemePreviewView(image: image)
                }
            }
            .onAppear {
                topText = selectedTemplate.topText
                bottomText = selectedTemplate.bottomText
            }
        }
    }

    private var memePreview: some View {
        MemeCardView(
            template: selectedTemplate,
            topText: topText,
            bottomText: bottomText,
            showLiveData: showLiveData,
            price: viewModel.formattedPrice,
            score: viewModel.environmentScore,
            scoreLabel: viewModel.environmentScoreLabel,
            change: viewModel.formattedChange,
            isPositive: viewModel.change24h >= 0
        )
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
    }

    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TEMPLATE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MemeTemplate.templates) { template in
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedTemplate = template
                                topText = template.topText
                                bottomText = template.bottomText
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: template.icon)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(selectedTemplate.id == template.id ? .orange : .secondary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        selectedTemplate.id == template.id
                                            ? Color.orange.opacity(0.15)
                                            : Color.primary.opacity(0.05)
                                    )
                                    .clipShape(Circle())

                                Text(template.name)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(selectedTemplate.id == template.id ? .primary : .secondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                        .sensoryFeedback(.selection, trigger: selectedTemplate.id)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private var editControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EDIT TEXT")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)

            VStack(spacing: 10) {
                TextField("Top text", text: $topText, axis: .vertical)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(.rect(cornerRadius: 12))
                    .lineLimit(1...3)
                    .focused($isTextFieldFocused)

                TextField("Bottom text", text: $bottomText, axis: .vertical)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(.rect(cornerRadius: 12))
                    .lineLimit(1...3)
                    .focused($isTextFieldFocused)
            }
        }
    }

    private var liveDataToggle: some View {
        Toggle(isOn: $showLiveData) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show Live Data")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Include price, score, and change on meme")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(.orange)
        .padding(14)
        .background(Color.primary.opacity(0.05))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var renderButton: some View {
        Button {
            renderMeme()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "eye")
                    .font(.system(size: 14, weight: .bold))
                Text("Preview & Share")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
        }
        .sensoryFeedback(.success, trigger: showImagePreview)
    }

    @MainActor
    private func renderMeme() {
        isTextFieldFocused = false
        let renderer = ImageRenderer(content:
            MemeCardView(
                template: selectedTemplate,
                topText: topText,
                bottomText: bottomText,
                showLiveData: showLiveData,
                price: viewModel.formattedPrice,
                score: viewModel.environmentScore,
                scoreLabel: viewModel.environmentScoreLabel,
                change: viewModel.formattedChange,
                isPositive: viewModel.change24h >= 0
            )
            .frame(width: 1080)
            .environment(\.colorScheme, .dark)
        )
        renderer.scale = 1.0
        if let image = renderer.uiImage {
            renderedImage = image
            showImagePreview = true
        }
    }
}

struct MemePreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: 24, y: 10)
                    .padding(.horizontal, 24)

                Spacer()

                Button {
                    showShareSheet = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                        Text("Share")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Your Meme")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [image])
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
