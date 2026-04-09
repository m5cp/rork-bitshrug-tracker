import SwiftUI

struct MemeGeneratorView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate: MemeTemplate = MemeTemplate.templates[0]
    @State private var topText: String = ""
    @State private var bottomText: String = ""
    @State private var showLiveData: Bool = true
    @State private var showImagePreview: Bool = false
    @State private var renderedImage: UIImage?
    @State private var selectedCategory: MemeTemplate.MemeCategory?
    @FocusState private var focusedField: MemeField?

    private enum MemeField: Hashable {
        case top, bottom
    }

    private var filteredTemplates: [MemeTemplate] {
        guard let cat = selectedCategory else { return MemeTemplate.templates }
        return MemeTemplate.templates.filter { $0.category == cat }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    memePreview

                    categoryFilter

                    templateGrid

                    editSection

                    liveDataToggle

                    previewButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .fogBackground()
            .navigationTitle("Meme Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { focusedField = nil }
                            .fontWeight(.semibold)
                    }
                }
            }
            .fullScreenCover(isPresented: $showImagePreview) {
                if let image = renderedImage {
                    MemePreviewView(image: image)
                }
            }
            .onChange(of: selectedTemplate) { _, newValue in
                topText = newValue.topText
                bottomText = newValue.bottomText
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
        .shadow(color: selectedTemplate.background.primaryColor.opacity(0.4), radius: 24, y: 8)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryPill(nil, label: "All")
                ForEach(MemeTemplate.MemeCategory.allCases, id: \.rawValue) { cat in
                    categoryPill(cat, label: cat.rawValue)
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private func categoryPill(_ category: MemeTemplate.MemeCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(duration: 0.25)) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.orange : Color.primary.opacity(0.06))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    private var templateGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 90), spacing: 10)
        ], spacing: 10) {
            ForEach(filteredTemplates) { template in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedTemplate = template
                    }
                } label: {
                    templateCell(template)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func templateCell(_ template: MemeTemplate) -> some View {
        let isSelected = selectedTemplate.id == template.id
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: template.background.colors.prefix(2).map { $0 },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected ? Color.orange : Color.clear,
                                lineWidth: 2
                            )
                    )

                Text(template.emoji)
                    .font(.system(size: 22))
            }

            Text(template.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isSelected ? .orange : .secondary)
                .lineLimit(1)
        }
    }

    private var editSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EDIT TEXT")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)

            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "text.aligncenter")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                    TextField("Top text", text: $topText, axis: .vertical)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1...4)
                        .focused($focusedField, equals: .top)
                }
                .padding(12)
                .background(Color.primary.opacity(0.05))
                .clipShape(.rect(cornerRadius: 12))

                HStack(spacing: 10) {
                    Image(systemName: "text.aligncenter")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                    TextField("Bottom text", text: $bottomText, axis: .vertical)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1...4)
                        .focused($focusedField, equals: .bottom)
                }
                .padding(12)
                .background(Color.primary.opacity(0.05))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var liveDataToggle: some View {
        Toggle(isOn: $showLiveData) {
            HStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 32, height: 32)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Live Data Overlay")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Price, change, and score on meme")
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

    private var previewButton: some View {
        Button {
            renderMeme()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                Text("Preview & Share")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
        }
        .sensoryFeedback(.success, trigger: showImagePreview)
    }

    @MainActor
    private func renderMeme() {
        focusedField = nil
        let renderSize: CGFloat = 360
        let card = MemeCardView(
            template: selectedTemplate,
            topText: topText,
            bottomText: bottomText,
            showLiveData: showLiveData,
            price: viewModel.formattedPrice,
            score: viewModel.environmentScore,
            scoreLabel: viewModel.environmentScoreLabel,
            change: viewModel.formattedChange,
            isPositive: viewModel.change24h >= 0,
            isRenderMode: false
        )
        .frame(width: renderSize, height: renderSize)
        .environment(\.colorScheme, .dark)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        renderer.proposedSize = .init(width: renderSize, height: renderSize)
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
    @State private var saved: Bool = false
    @State private var cardAppeared: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Your Meme")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        saveToPhotos()
                    } label: {
                        Image(systemName: saved ? "checkmark" : "arrow.down.to.line")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(saved ? .green : .white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .sensoryFeedback(.success, trigger: saved)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: .orange.opacity(0.2), radius: 30, y: 10)
                    .padding(.horizontal, 8)
                    .scaleEffect(cardAppeared ? 1.0 : 0.9)
                    .opacity(cardAppeared ? 1 : 0)

                Spacer(minLength: 12)

                HStack(spacing: 12) {
                    Button {
                        saveToPhotos()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: saved ? "checkmark.circle.fill" : "photo.on.rectangle")
                                .font(.system(size: 14, weight: .bold))
                            Text(saved ? "Saved" : "Save")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 14))
                    }

                    Button {
                        showShareSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .bold))
                            Text("Share")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.2)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [image])
        }
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                cardAppeared = true
            }
        }
    }

    private func saveToPhotos() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        withAnimation(.spring(duration: 0.3)) {
            saved = true
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
