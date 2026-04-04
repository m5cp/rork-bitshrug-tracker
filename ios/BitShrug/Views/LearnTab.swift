import SwiftUI

struct LearnTab: View {
    let viewModel: BitcoinViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.colorScheme) private var colorScheme

    @State private var showScrollToTop: Bool = false
    @State private var selectedTopic: LearnTopic?
    @State private var learnProgress = LearnProgressManager.shared

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 720 : .infinity }
    private var horizontalPadding: CGFloat { isRegular ? 32 : 20 }

    private var totalLessons: Int { 64 }
    private var completedTotal: Int { learnProgress.completedLessons.count }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Color.clear.frame(height: 0).id("top")

                        if let topic = selectedTopic {
                            backButton
                            topicDetail(topic)
                        } else {
                            progressHeader
                            didYouKnowCard
                            topicGrid
                        }

                        disclaimer
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 40)
                    .onGeometryChange(for: CGFloat.self) { geo in
                        geo.frame(in: .global).minY
                    } action: { value in
                        showScrollToTop = value < -200
                    }
                }
                .scrollIndicators(.hidden)
                .overlay(alignment: .bottomTrailing) {
                    FloatingScrollToTopButton(isVisible: showScrollToTop) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: totalLessons > 0 ? Double(completedTotal) / Double(totalLessons) : 0)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                Text("\(completedTotal)")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Your Progress")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                Text("\(completedTotal) of \(totalLessons) lessons completed")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if completedTotal == totalLessons {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .background(Color.orange.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.orange.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Did You Know

    private var didYouKnowCard: some View {
        let facts = didYouKnowFacts
        let index = Calendar.current.component(.hour, from: Date()) % facts.count

        return HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.yellow)
                .frame(width: 34, height: 34)
                .background(Color.yellow.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text("DID YOU KNOW?")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.yellow)
                    .tracking(1)

                Text(facts[index])
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.yellow.opacity(0.05))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.yellow.opacity(0.1), lineWidth: 1)
        )
    }

    private var didYouKnowFacts: [String] {
        [
            "Bitcoin processes over $30 billion in transactions daily — more than most payment networks.",
            "There will only ever be 21 million Bitcoin. Over 19.5 million have already been mined.",
            "The smallest unit of Bitcoin is called a 'satoshi' — there are 100 million in one Bitcoin.",
            "Bitcoin's creator, Satoshi Nakamoto, is estimated to hold about 1 million BTC.",
            "The first real-world Bitcoin transaction was 10,000 BTC for two pizzas in May 2010.",
            "Bitcoin has been declared 'dead' by media over 470 times since 2009.",
            "El Salvador became the first country to adopt Bitcoin as legal tender in 2021.",
            "About 20% of all Bitcoin is estimated to be permanently lost due to forgotten keys.",
            "Bitcoin's network has maintained 99.99% uptime since launching in January 2009.",
            "A Bitcoin block is mined roughly every 10 minutes — that's over 800,000 blocks so far.",
            "Bitcoin mining difficulty adjusts every 2,016 blocks to maintain the 10-minute target.",
            "The last Bitcoin is expected to be mined around the year 2140.",
        ]
    }

    private var backButton: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.35)) {
                    selectedTopic = nil
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                    Text("All Topics")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.orange)
            }
            Spacer()
        }
    }

    // MARK: - Topic Grid

    private var topicGrid: some View {
        VStack(spacing: 16) {
            heroTopicCard(
                topic: .howToRead,
                icon: "app.badge.checkmark",
                color: .orange,
                title: "How to Read BitShrug",
                subtitle: "Understand every feature of this app in under 3 minutes",
                lessonCount: 5
            )

            heroTopicCard(
                topic: .bitcoin,
                icon: "bitcoinsign.circle.fill",
                color: .orange,
                title: "What is Bitcoin?",
                subtitle: "Start here — understand the fundamentals in under 2 minutes",
                lessonCount: 12
            )

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                topicCard(
                    topic: .powerLaw,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue,
                    title: "Power Law",
                    subtitle: "The mathematical model",
                    lessonCount: 5
                )

                topicCard(
                    topic: .cycles,
                    icon: "arrow.triangle.2.circlepath",
                    color: .purple,
                    title: "4-Year Cycles",
                    subtitle: "Halvings & market patterns",
                    lessonCount: 7
                )

                topicCard(
                    topic: .indicators,
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    color: .cyan,
                    title: "Indicators",
                    subtitle: "On-chain & market signals",
                    lessonCount: 7
                )

                topicCard(
                    topic: .dcaStrategy,
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    title: "DCA & Strategy",
                    subtitle: "Long-term positioning",
                    lessonCount: 5
                )

                topicCard(
                    topic: .misconceptions,
                    icon: "questionmark.bubble.fill",
                    color: .red,
                    title: "Myth Busters",
                    subtitle: "Test your knowledge",
                    lessonCount: 7
                )

                topicCard(
                    topic: .glossary,
                    icon: "text.book.closed",
                    color: .indigo,
                    title: "Glossary",
                    subtitle: "Key terms explained",
                    lessonCount: 9
                )
            }

            heroTopicCard(
                topic: .btcVsDollars,
                icon: "arrow.left.arrow.right.circle.fill",
                color: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "Bitcoin vs Dollars",
                subtitle: "A side-by-side comparison of two monetary systems",
                lessonCount: 7
            )
        }
        .transition(.opacity)
    }

    private func progressBadge(for topic: LearnTopic) -> some View {
        let completed = learnProgress.completedCount(for: topic.progressKey)
        let total = topic.lessonCount

        return Group {
            if completed > 0 {
                if completed >= total {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.orange)
                } else {
                    Text("\(completed)/\(total)")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private func heroTopicCard(topic: LearnTopic, icon: String, color: Color, title: String, subtitle: String, lessonCount: Int) -> some View {
        Button {
            withAnimation(.spring(duration: 0.35)) {
                selectedTopic = topic
            }
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("\(lessonCount) lessons")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(color.opacity(0.12))
                            .clipShape(Capsule())

                        progressBadge(for: topic)
                    }

                    Text(title)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(color.opacity(0.8))
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.08), color.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(.rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTopic)
    }

    private func topicCard(topic: LearnTopic, icon: String, color: Color, title: String, subtitle: String, lessonCount: Int) -> some View {
        Button {
            withAnimation(.spring(duration: 0.35)) {
                selectedTopic = topic
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(color)
                        .frame(width: 40, height: 40)
                        .background(color.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 12))

                    Spacer()

                    progressBadge(for: topic)
                }

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Topic Detail

    @ViewBuilder
    private func topicDetail(_ topic: LearnTopic) -> some View {
        switch topic {
        case .bitcoin:
            bitcoinEducation
        case .powerLaw:
            powerLawEducation
        case .cycles:
            cycleEducation
        case .indicators:
            indicatorEducation
        case .misconceptions:
            misconceptionsEducation
        case .btcVsDollars:
            btcVsDollarsEducation
        case .howToRead:
            howToReadEducation
        case .glossary:
            glossaryEducation
        case .dcaStrategy:
            dcaStrategyEducation
        }
    }

    // MARK: - How to Read BitShrug

    private var howToReadEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "app.badge.checkmark",
                color: .orange,
                title: "How to Read BitShrug",
                subtitle: "Understand every feature of this app."
            )

            VStack(spacing: 12) {
                trackedLesson(
                    id: "howtoread_1",
                    number: 1,
                    color: .orange,
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    title: "The Environment Score",
                    summary: "A 0–100 composite of trend, momentum, positioning & volatility",
                    detail: "The Environment Score is a single number that summarizes Bitcoin's current macro conditions. It combines four drivers: Trend (are we above key moving averages?), Momentum (how fast is price moving?), Positioning (where are we relative to the 52-week range?), and Volatility (is risk elevated?). Higher scores suggest favorable conditions; lower scores suggest caution. It is not a buy/sell signal."
                )

                trackedLesson(
                    id: "howtoread_2",
                    number: 2,
                    color: .blue,
                    icon: "chart.line.uptrend.xyaxis",
                    title: "The Power Law Corridor",
                    summary: "A long-term mathematical channel for Bitcoin's price",
                    detail: "The Power Law chart shows a support line (historical floor) and resistance line (historical ceiling). When price is near support, conditions have historically been favorable for long-term holders. Near resistance, conditions have historically been overheated. The percentage shows where price sits within this corridor. The Rainbow Chart adds color bands for more granular context."
                )

                trackedLesson(
                    id: "howtoread_3",
                    number: 3,
                    color: .purple,
                    icon: "arrow.triangle.2.circlepath",
                    title: "The Cycle Ring",
                    summary: "Visual progress through the ~4-year halving cycle",
                    detail: "The cycle ring shows how far we are through the current halving cycle. The phase label (Accumulation, Early Bull, Acceleration, etc.) is determined by cycle progress and price behavior. This is an observed pattern, not a guarantee. The ring helps contextualize where we might be relative to historical patterns."
                )

                trackedLesson(
                    id: "howtoread_4",
                    number: 4,
                    color: .cyan,
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    title: "Indicators Explained",
                    summary: "Each indicator tells a piece of the story",
                    detail: "Fear & Greed measures market sentiment. MVRV Z-Score compares market cap to realized cap. Puell Multiple tracks miner revenue. 200-Day EMA and 200-Week MA show long-term trend. Stock-to-Flow models scarcity. Supply in Profit estimates how many holders are profitable. No single indicator is a signal — they work together as context."
                )

                trackedLesson(
                    id: "howtoread_5",
                    number: 5,
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    icon: "bell.badge.fill",
                    title: "Alerts & Notifications",
                    summary: "Stay informed without being overwhelmed",
                    detail: "Price Alerts let you set custom price targets or Power Law boundary alerts. The Daily Briefing sends one calm notification each morning with your score, price, and trend. Environment alerts notify you when conditions shift significantly. All alerts are informational — never financial advice."
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - Glossary

    private var glossaryEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "text.book.closed",
                color: .indigo,
                title: "Glossary",
                subtitle: "Key terms you'll encounter in BitShrug and beyond."
            )

            VStack(spacing: 12) {
                trackedLesson(
                    id: "glossary_1",
                    number: 1,
                    color: .orange,
                    icon: "bitcoinsign.circle",
                    title: "HODL",
                    summary: "Hold On for Dear Life — long-term holding strategy",
                    detail: "Originally a typo for 'hold' from a 2013 Bitcoin forum post, HODL has become a philosophy: buy Bitcoin and hold through volatility without panic-selling. It reflects the belief that long-term holding outperforms trading for most people."
                )

                trackedLesson(
                    id: "glossary_2",
                    number: 2,
                    color: .blue,
                    icon: "arrow.triangle.2.circlepath",
                    title: "DCA (Dollar Cost Averaging)",
                    summary: "Investing a fixed amount at regular intervals",
                    detail: "Instead of trying to time the market, DCA means buying a fixed dollar amount of Bitcoin on a regular schedule (e.g., $50/week). This smooths out volatility over time. Historically effective for assets with long-term upward trends."
                )

                trackedLesson(
                    id: "glossary_3",
                    number: 3,
                    color: .purple,
                    icon: "chart.line.uptrend.xyaxis",
                    title: "ATH (All-Time High)",
                    summary: "The highest price Bitcoin has ever reached",
                    detail: "ATH is the peak price Bitcoin has traded at. Each cycle has produced a new ATH. Breaking through the previous ATH often triggers increased media attention and new investor interest."
                )

                trackedLesson(
                    id: "glossary_4",
                    number: 4,
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    icon: "arrow.up.right",
                    title: "Bull Market / Bear Market",
                    summary: "Extended periods of rising or falling prices",
                    detail: "A bull market is a sustained period of rising prices with general optimism. A bear market is a sustained decline, usually 20%+ from the peak. Bitcoin has historically alternated between these in roughly 4-year cycles aligned with halvings."
                )

                trackedLesson(
                    id: "glossary_5",
                    number: 5,
                    color: .cyan,
                    icon: "chart.pie",
                    title: "Market Cap",
                    summary: "Total value of all Bitcoin in circulation",
                    detail: "Market cap = current price × circulating supply. With ~19.5M BTC in circulation, a $100K price means roughly a $1.95 trillion market cap. It's used to compare Bitcoin's size to other assets like gold (~$15T)."
                )

                trackedLesson(
                    id: "glossary_6",
                    number: 6,
                    color: .red,
                    icon: "server.rack",
                    title: "Hash Rate",
                    summary: "Total computing power securing the Bitcoin network",
                    detail: "Hash rate measures how much computing power miners contribute to the network. Higher hash rate = more secure network. It's measured in exahashes per second (EH/s). A rising hash rate generally signals confidence from miners."
                )

                trackedLesson(
                    id: "glossary_7",
                    number: 7,
                    color: .yellow,
                    icon: "scissors",
                    title: "Block Reward",
                    summary: "BTC given to miners for validating each block",
                    detail: "Miners receive newly created Bitcoin for each block they validate. This reward halves every 210,000 blocks (~4 years). Started at 50 BTC in 2009, currently 3.125 BTC. This is the only way new Bitcoin enters circulation."
                )

                trackedLesson(
                    id: "glossary_8",
                    number: 8,
                    color: .indigo,
                    icon: "atom",
                    title: "Satoshi (sat)",
                    summary: "The smallest unit of Bitcoin — 0.00000001 BTC",
                    detail: "Named after Bitcoin's creator, a satoshi is one hundred-millionth of a Bitcoin. With BTC at $100,000, one satoshi = $0.001. Many people 'stack sats' — accumulating small amounts over time. 100 million sats = 1 BTC."
                )

                trackedLesson(
                    id: "glossary_9",
                    number: 9,
                    color: .mint,
                    icon: "key.fill",
                    title: "Not Your Keys, Not Your Coins",
                    summary: "Self-custody principle for Bitcoin ownership",
                    detail: "If you hold Bitcoin on an exchange, the exchange controls the private keys. 'Not your keys, not your coins' means that true ownership requires holding your own private keys, typically via a hardware wallet. Exchange failures (like FTX) have reinforced this principle."
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - DCA & Strategy

    private var dcaStrategyEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "arrow.triangle.2.circlepath.circle.fill",
                color: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "DCA & Strategy",
                subtitle: "Long-term positioning concepts for Bitcoin holders."
            )

            VStack(spacing: 12) {
                trackedLesson(
                    id: "dca_1",
                    number: 1,
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    icon: "arrow.triangle.2.circlepath",
                    title: "What is Dollar Cost Averaging?",
                    summary: "A disciplined approach to buying over time",
                    detail: "Dollar Cost Averaging means investing a fixed amount at regular intervals regardless of price. When price is low, you buy more BTC. When price is high, you buy less. Over time, this averages out your cost basis and removes the pressure of timing the market. Studies show DCA has historically outperformed lump-sum timing attempts for most investors."
                )

                trackedLesson(
                    id: "dca_2",
                    number: 2,
                    color: .blue,
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Why DCA Works for Bitcoin",
                    summary: "Volatility is your friend with a consistent schedule",
                    detail: "Bitcoin's volatility makes timing nearly impossible. DCA turns that volatility into an advantage — you naturally buy more when prices drop and less when they spike. Over Bitcoin's history, consistent weekly DCA has produced positive returns over any 4-year period, regardless of when you started."
                )

                trackedLesson(
                    id: "dca_3",
                    number: 3,
                    color: .orange,
                    icon: "clock.fill",
                    title: "Time Preference",
                    summary: "Valuing the future over instant gratification",
                    detail: "Low time preference means prioritizing long-term outcomes over short-term consumption. Bitcoin encourages low time preference because its fixed supply and deflationary nature reward patience. This is fundamentally different from fiat currency, which loses purchasing power over time and encourages spending now."
                )

                trackedLesson(
                    id: "dca_4",
                    number: 4,
                    color: .purple,
                    icon: "exclamationmark.triangle",
                    title: "Why Timing the Market Fails",
                    summary: "Missing just a few of the best days destroys returns",
                    detail: "Bitcoin's biggest gains often come in sudden bursts. Missing the 10 best days in any given year can dramatically reduce annual returns. Staying invested consistently (or DCA'ing) ensures you capture those gains. The emotional toll of trying to time entries and exits also leads to poor decisions — selling low out of fear, buying high out of FOMO."
                )

                trackedLesson(
                    id: "dca_5",
                    number: 5,
                    color: .cyan,
                    icon: "shield.checkered",
                    title: "BitShrug's Philosophy",
                    summary: "Rise or Fall, we hold — positioning over prediction",
                    detail: "BitShrug is built for long-term holders, not traders. The Environment Score helps you understand conditions, not time trades. The Power Law and cycle data provide context, not crystal balls. The best strategy for most people is consistent accumulation with a multi-year horizon. The app is designed to keep you informed and grounded — not to create anxiety or FOMO."
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - What is Bitcoin

    private var bitcoinEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "bitcoinsign.circle.fill",
                color: .orange,
                title: "What is Bitcoin?",
                subtitle: "No hype, just fundamentals."
            )

            VStack(spacing: 12) {
                trackedLesson(id: "bitcoin_1", number: 1, color: .orange, icon: "bitcoinsign.circle.fill", title: "What is Bitcoin?", summary: "Decentralized digital money without banks or intermediaries", detail: "Bitcoin is a decentralized digital money system that allows people to send value directly to one another without a bank or intermediary. It operates on a global network with a fixed set of rules that anyone can verify.")
                trackedLesson(id: "bitcoin_2", number: 2, color: .purple, icon: "person.fill.questionmark", title: "Who Created Bitcoin?", summary: "Satoshi Nakamoto — identity still unknown", detail: "Bitcoin was created in 2008 by an individual or group using the name Satoshi Nakamoto. The identity of Satoshi remains unknown, and no central authority controls Bitcoin today.")
                trackedLesson(id: "bitcoin_3", number: 3, color: .yellow, icon: "lightbulb.fill", title: "Why Was Bitcoin Created?", summary: "Peer-to-peer money without trusted intermediaries", detail: "Bitcoin was created to enable peer-to-peer money that does not rely on trusted intermediaries. It allows transactions to be verified by a distributed network rather than a central institution.")
                trackedLesson(id: "bitcoin_4", number: 4, color: .blue, icon: "building.columns", title: "Different from Traditional Money?", summary: "No central authority, fixed supply of 21 million", detail: "Bitcoin operates without a central authority, meaning no government or company controls it. Its monetary policy is fixed, with a maximum supply of 21 million coins.")
                trackedLesson(id: "bitcoin_5", number: 5, color: .cyan, icon: "arrow.left.arrow.right", title: "Different from Digital Payments?", summary: "No banks or payment processors required", detail: "Most digital payments rely on banks or payment processors. Bitcoin allows value to be transferred directly between users without requiring permission.")
                trackedLesson(id: "bitcoin_6", number: 6, color: Color(red: 0.2, green: 0.85, blue: 0.5), icon: "lock.shield.fill", title: "How Does Bitcoin Stay Secure?", summary: "Global network with strong cryptographic rules", detail: "Bitcoin is secured by a global network of independent participants and strong cryptographic rules. Altering transaction history would require overwhelming network consensus.")
                trackedLesson(id: "bitcoin_7", number: 7, color: .orange, icon: "hammer.fill", title: "What Is Mining?", summary: "Validates transactions and secures the network", detail: "Mining is the process that validates transactions and secures the network. Participants contribute computing power and are rewarded with newly issued bitcoin.")
                trackedLesson(id: "bitcoin_8", number: 8, color: .mint, icon: "diamond.fill", title: "Why Is Bitcoin Scarce?", summary: "Fixed supply of 21 million coins", detail: "Bitcoin has a fixed supply of 21 million coins. New bitcoin is released on a predictable schedule that decreases over time.")
                trackedLesson(id: "bitcoin_9", number: 9, color: Color(red: 0.2, green: 0.85, blue: 0.5), icon: "chart.line.uptrend.xyaxis", title: "What Gives Bitcoin Value?", summary: "Scarcity, security, and global transferability", detail: "Bitcoin's value comes from its scarcity, security, and ability to transfer value globally without intermediaries.")
                trackedLesson(id: "bitcoin_10", number: 10, color: .blue, icon: "globe", title: "Can Bitcoin Be Controlled?", summary: "No single entity controls it", detail: "No single entity controls Bitcoin. Changes require broad agreement across the network.")
                trackedLesson(id: "bitcoin_11", number: 11, color: .purple, icon: "banknote.fill", title: "Is Bitcoin Mainly for Trading?", summary: "Payments, holding, or long-term monetary asset", detail: "Bitcoin can be used for payments or long-term holding. Many focus on its role as a long-term monetary asset.")
                trackedLesson(id: "bitcoin_12", number: 12, color: .yellow, icon: "trophy.fill", title: "Bitcoin vs Gold", summary: "Both are scarce and independent of central control", detail: "Bitcoin is often compared to gold because both are scarce and independent of central control. Bitcoin can be transferred instantly worldwide.")
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - Power Law Education

    private var powerLawEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "chart.line.uptrend.xyaxis",
                color: .blue,
                title: "The Power Law",
                subtitle: "A mathematical model for Bitcoin's growth."
            )

            VStack(spacing: 12) {
                ExpandableInfoCard(
                    icon: "person.fill",
                    iconColor: .orange,
                    title: "Who Created It?",
                    summary: "Harold Christopher Burger (2019) and Giovanni Santostasi",
                    detail: "Burger observed Bitcoin's price follows a linear relationship on a log-log chart. Santostasi extended this to hash rate and addresses, showing the power law holds across multiple network metrics."
                )

                ExpandableInfoCard(
                    icon: "function",
                    iconColor: .blue,
                    title: "What is a Power Law?",
                    summary: "A relationship where one quantity scales as a power of another",
                    detail: "Price ∝ Time⁵·⁸² — fundamentally different from exponential growth. The rate of growth slows over time but never stops. Many natural phenomena follow power laws: earthquake magnitudes, city sizes, and network effects."
                )

                ExpandableInfoCard(
                    icon: "chart.bar.fill",
                    iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                    title: "Reading the Corridor",
                    summary: "Below support, within corridor, or above resistance",
                    detail: "Below Support — historically the best long-term accumulation zone. Within Corridor — tracking the expected growth path. Above Resistance — historically coincides with cycle tops and euphoria."
                )

                ExpandableInfoCard(
                    icon: "rainbow",
                    iconColor: .purple,
                    title: "Rainbow Chart",
                    summary: "Colored bands from 'Fire Sale' to 'Maximum Bubble'",
                    detail: "Each band represents a standard deviation from the fair value regression line. It's a visual heuristic showing where price sits relative to its long-term trend — not a prediction."
                )

                formulaCard

                Text("Based on historical patterns. Past behavior does not guarantee future results. Rise or Fall, we hold.")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    private var formulaCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "function")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.orange)
                Text("The Formula")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }

            Text("log₁₀(price) = 5.82 × log₁₀(days) − k")
                .font(.system(.callout, design: .monospaced, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.orange.opacity(0.15), lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 10))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                formulaTile(label: "price", value: "BTC price in USD")
                formulaTile(label: "days", value: "Since genesis block")
                formulaTile(label: "5.82", value: "Power law exponent")
                formulaTile(label: "k", value: "Support/resistance offset")
            }
        }
        .premiumCard(.highlighted)
    }

    private func formulaTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .monospaced, weight: .heavy))
                .foregroundStyle(.orange)
            Text(value)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }

    // MARK: - Cycle Education

    private var cycleEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "arrow.triangle.2.circlepath",
                color: .purple,
                title: "4-Year Cycles",
                subtitle: "Halvings, epochs, and the market pattern theory."
            )

            VStack(spacing: 12) {
                conceptsExplainer
                whyCyclesSection
                couldCyclesEndSection
                strategySection

                ExpandableInfoCard(
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .orange,
                    title: "What is the Halving?",
                    summary: "Block reward cut in half every 210,000 blocks (~4 years)",
                    detail: "Started at 50 BTC per block in 2009. Now 3.125 BTC. Halvings reduce new supply entering circulation — a programmatic scarcity mechanism that continues until all 21M BTC are mined (~2140)."
                )

                ExpandableInfoCard(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
                    title: "The Cycle Pattern",
                    summary: "Tops and bottoms ~4 years apart since 2011",
                    detail: "Bull tops: Nov 2013, Dec 2017, Nov 2021. Bear lows: Jan 2015, Dec 2018, Nov 2022. A repeating cycle of accumulation, expansion, euphoria, and correction — driven by supply shocks and human psychology."
                )

                ExpandableInfoCard(
                    icon: "questionmark.diamond",
                    iconColor: .purple,
                    title: "Is It Guaranteed?",
                    summary: "No — only 4 halving events observed so far",
                    detail: "As Bitcoin matures, institutional adoption, regulation, macro conditions, and diminishing supply shocks may alter or dampen the cycle. Useful framework, but past patterns don't guarantee future behavior."
                )

                ExpandableInfoCard(
                    icon: "app.badge",
                    iconColor: .blue,
                    title: "How BitShrug Uses It",
                    summary: "One lens among many for understanding conditions",
                    detail: "The cycle phase is combined with momentum, trend, positioning, and volatility to create a composite picture. It's a context tool — not a timing tool."
                )
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    private var conceptsExplainer: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "book.closed", title: "KNOW THE DIFFERENCE")

            Text("These three terms are often used interchangeably, but they describe distinct concepts.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineSpacing(3)

            conceptCard(
                number: "1",
                color: .orange,
                term: "The Halving",
                icon: "scissors",
                definition: "A hard-coded event in Bitcoin's protocol",
                details: [
                    "Every 210,000 blocks (~4 years), the mining reward is cut in half",
                    "Reduces the rate of new BTC entering circulation",
                    "Completely predictable — next one is ~April 2028",
                    "4 halvings so far: 2012, 2016, 2020, 2024"
                ],
                takeaway: "A supply-side event. It's mechanical, not theoretical."
            )

            conceptCard(
                number: "2",
                color: .cyan,
                term: "The Epoch (Era)",
                icon: "square.stack.3d.up",
                definition: "The period between two consecutive halvings",
                details: [
                    "Epoch 1: Genesis → Nov 2012 (50 BTC reward)",
                    "Epoch 2: Nov 2012 → Jul 2016 (25 BTC reward)",
                    "Epoch 3: Jul 2016 → May 2020 (12.5 BTC reward)",
                    "Epoch 4: May 2020 → Apr 2024 (6.25 BTC reward)",
                    "Epoch 5: Apr 2024 → ~2028 (3.125 BTC reward)"
                ],
                takeaway: "A time period defined by a fixed block reward. We're in Epoch 5."
            )

            conceptCard(
                number: "3",
                color: .purple,
                term: "The 4-Year Cycle",
                icon: "arrow.triangle.2.circlepath",
                definition: "An observed market pattern, not a protocol rule",
                details: [
                    "Bull tops and bear bottoms have formed ~4 years apart",
                    "Driven by halvings, monetary policy, and psychology",
                    "Each cycle: accumulation → bull → euphoria → bear",
                    "Only 4 complete cycles observed — small sample size",
                    "May weaken or end as Bitcoin matures"
                ],
                takeaway: "A theory based on historical observation. Correlation, not causation."
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("How They Connect")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    connectionRow(left: "Halving", right: "triggers the start of each Epoch")
                    connectionRow(left: "Epoch", right: "provides the timeframe for each cycle")
                    connectionRow(left: "4-Year Cycle", right: "is the market behavior observed within epochs")
                }

                Text("The halving is a fact. The epoch is a measurement. The cycle is a theory.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 14))
        }
        .premiumCard(.highlighted)
    }

    private func conceptCard(number: String, color: Color, term: String, icon: String, definition: String, details: [String], takeaway: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(number)
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(color)
                    .clipShape(.rect(cornerRadius: 6))

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)

                Text(term)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                Spacer()
            }

            Text(definition)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color.opacity(0.9))

            VStack(alignment: .leading, spacing: 6) {
                ForEach(details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(color.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
                Text(takeaway)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [color.opacity(0.06), color.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.1), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private func connectionRow(left: String, right: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(left)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 90, alignment: .leading)
            Text(right)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var whyCyclesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "questionmark.circle", title: "WHY DO 4-YEAR CYCLES HAPPEN?")

            CompactFactCard(
                icon: "hammer.fill",
                iconColor: .orange,
                title: "Bitcoin Halvings",
                content: "Every ~4 years, mining rewards are cut in half — a programmatic supply shock. Each halving has coincided with the early stages of a new bull market. Next halving: ~2028."
            )

            CompactFactCard(
                icon: "building.columns.fill",
                iconColor: .blue,
                title: "Monetary Policy",
                content: "Crypto prices have tended to rise when the Fed cuts rates or injects liquidity. However, this correlation doesn't always hold — Bitcoin didn't rally on the Dec 2025 rate cut."
            )

            CompactFactCard(
                icon: "brain.head.profile",
                iconColor: .purple,
                title: "Investor Psychology",
                content: "The same boom-bust dynamics that drive most markets: optimism and greed push prices up, panic and fear push them down — playing out over roughly 4-year intervals."
            )
        }
        .premiumCard(.highlighted)
    }

    private var couldCyclesEndSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "exclamationmark.triangle", title: "COULD THE CYCLES BE OVER?")

            HStack(spacing: 10) {
                verdictPill(
                    color: Color(red: 0.2, green: 0.85, blue: 0.5),
                    title: "Bull Case",
                    points: [
                        "Institutional adoption changes dynamics",
                        "Spot ETFs absorb selling pressure",
                        "Possible \"supercycle\" scenario"
                    ]
                )

                verdictPill(
                    color: Color(red: 0.95, green: 0.3, blue: 0.3),
                    title: "Bear Case",
                    points: [
                        "Oct 2025 ATH followed by bear-like action",
                        "Pattern matches historical cycle behavior",
                        "Psychology hasn't changed"
                    ]
                )
            }

            HStack(spacing: 8) {
                ShrugBadge(size: .small, style: .inline)
                Text("Rise or Fall, we hold.")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .italic()
            }
        }
        .premiumCard()
    }

    private func verdictPill(color: Color, title: String, points: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 6) {
                        Circle()
                            .fill(color.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .padding(.top, 5)
                        Text(point)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.12), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(icon: "lightbulb", title: "USING CYCLES AS A REFERENCE")

            VStack(alignment: .leading, spacing: 10) {
                KeyPointRow(icon: "clock", iconColor: .orange, text: "Cycles are not precisely 4 years — they've varied each time")
                KeyPointRow(icon: "exclamationmark.triangle", iconColor: .orange, text: "No guarantee cycles will continue as before")
                KeyPointRow(icon: "chart.line.downtrend.xyaxis", iconColor: .orange, text: "Past patterns don't predict future behavior")
                KeyPointRow(icon: "lightbulb", iconColor: .orange, text: "Use as educational context, not as a timing tool")
            }

            Text("Crypto is high-risk. This is educational context, not a recommendation.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .italic()
        }
        .premiumCard()
    }

    // MARK: - Indicator Education

    private var indicatorEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "gauge.with.dots.needle.bottom.50percent",
                color: .cyan,
                title: "Indicators",
                subtitle: "On-chain and market signals explained."
            )

            VStack(spacing: 12) {
                ExpandableInfoCard(icon: "heart.text.square", iconColor: .orange, title: "Fear & Greed Index", summary: "Measures market sentiment from 0 (Extreme Fear) to 100 (Extreme Greed)", detail: "Aggregates volatility, market volume, social media, dominance, and trends. Extreme fear can signal buying opportunities; extreme greed can signal overextension. It's a contrarian indicator — be fearful when others are greedy.")
                ExpandableInfoCard(icon: "chart.xyaxis.line", iconColor: .blue, title: "200-Day EMA", summary: "Exponential moving average of the last 200 days", detail: "Gives more weight to recent prices than a simple moving average. When price is above the 200-Day EMA, the trend is considered bullish. Below it, bearish. It's the most widely watched long-term trend indicator.")
                ExpandableInfoCard(icon: "chart.line.flattrend.xyaxis", iconColor: Color(red: 0.2, green: 0.85, blue: 0.5), title: "200-Week MA", summary: "The long-term price floor Bitcoin has never closed below", detail: "Calculated from ~1,400 days of price history. Historically, Bitcoin has bounced off this level during every bear market. It represents the deepest value zone for long-term holders.")
                ExpandableInfoCard(icon: "waveform.path.ecg", iconColor: .purple, title: "MVRV Z-Score", summary: "Market Value to Realized Value ratio", detail: "Compares Bitcoin's market cap to its 'realized cap' (average cost basis of all coins). Z-Score above 7 has historically marked cycle tops. Below 0.1 has marked generational bottoms. Currently used to gauge overvaluation or undervaluation.")
                ExpandableInfoCard(icon: "pickaxe", iconColor: .cyan, title: "Puell Multiple", summary: "Daily miner revenue vs 365-day average", detail: "When miners earn much more than usual (Puell > 4), it often signals a top — miners sell to lock in profits. When miners earn much less (Puell < 0.5), it signals capitulation and potential bottoms.")
                ExpandableInfoCard(icon: "cube.box", iconColor: .yellow, title: "Stock-to-Flow", summary: "Scarcity model comparing existing supply to new production", detail: "S2F = Existing Supply / Annual Production. Higher ratio = more scarce. After each halving, S2F doubles as production is cut in half. The model predicts higher prices with increasing scarcity, though it has faced criticism for oversimplification.")
                ExpandableInfoCard(icon: "chart.pie", iconColor: Color(red: 0.2, green: 0.85, blue: 0.5), title: "Supply in Profit", summary: "Percentage of Bitcoin supply currently worth more than when last moved", detail: "When >95% of supply is in profit, it historically signals overheated conditions. When <50% is in profit, it signals deep bear territory and potential accumulation zones. Estimated from MVRV ratio.")
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - Myth Busters (Interactive Quiz)

    private var misconceptionsEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "questionmark.bubble.fill",
                color: .red,
                title: "Myth Busters",
                subtitle: "Tap to reveal the truth. Test your knowledge!"
            )

            VStack(spacing: 12) {
                InteractiveMythCard(id: "myth_1", icon: "eye.slash.fill", iconColor: .purple, myth: "Bitcoin is anonymous", reality: "Pseudonymous, not anonymous", detail: "Transactions are publicly visible, but identities are not directly attached. This makes Bitcoin pseudonymous.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_2", icon: "exclamationmark.shield.fill", iconColor: .red, myth: "Bitcoin is mainly for illegal activity", reality: "Most activity today is legitimate", detail: "Most Bitcoin activity today is legitimate. It is widely used for trading, payments, and long-term holding.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_3", icon: "lock.trianglebadge.exclamationmark.fill", iconColor: .orange, myth: "Bitcoin can be hacked", reality: "The network itself has never been hacked", detail: "The Bitcoin network itself has never been hacked. However, individual accounts or platforms can be compromised if not secured properly.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_4", icon: "chart.line.downtrend.xyaxis", iconColor: .cyan, myth: "Bitcoin is just a bubble", reality: "Multiple cycles of growth and decline", detail: "Bitcoin has gone through multiple cycles of growth and decline. It has continued operating and gaining adoption over time.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_5", icon: "questionmark.diamond.fill", iconColor: .yellow, myth: "Bitcoin isn't backed by anything", reality: "Value from scarcity, security, and adoption", detail: "Bitcoin is not backed by a physical asset or government. Its value comes from scarcity, security, and user adoption.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_6", icon: "building.columns.fill", iconColor: .blue, myth: "Governments can shut Bitcoin down", reality: "No single point of control", detail: "Bitcoin runs on a global decentralized network. There is no single point of control, making shutdown difficult.", learnProgress: learnProgress)
                InteractiveMythCard(id: "myth_7", icon: "leaf.fill", iconColor: Color(red: 0.2, green: 0.85, blue: 0.5), myth: "Bitcoin is bad for the environment", reality: "Energy use varies by source", detail: "Bitcoin uses energy, but impact varies by source. A growing share uses renewable or otherwise unused energy.", learnProgress: learnProgress)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    // MARK: - Bitcoin vs Dollars

    private var btcVsDollarsEducation: some View {
        VStack(spacing: 0) {
            topicHeader(
                icon: "arrow.left.arrow.right.circle.fill",
                color: Color(red: 0.2, green: 0.85, blue: 0.5),
                title: "Bitcoin vs Dollars",
                subtitle: "A side-by-side look at two monetary systems."
            )

            VStack(spacing: 12) {
                comparisonCard(icon: "person.2.fill", iconColor: .orange, title: "Who Controls It?", btcPoint: "No central authority", usdPoint: "Issued and managed by central banks")
                comparisonCard(icon: "number.circle.fill", iconColor: .purple, title: "Supply", btcPoint: "Fixed supply of 21 million", usdPoint: "Supply can expand over time")
                comparisonCard(icon: "arrow.left.arrow.right", iconColor: .cyan, title: "Transfer", btcPoint: "Peer-to-peer, global", usdPoint: "Typically requires intermediaries")
                comparisonCard(icon: "globe", iconColor: .blue, title: "Accessibility", btcPoint: "Accessible with internet", usdPoint: "Depends on banking access")
                comparisonCard(icon: "checkmark.seal.fill", iconColor: Color(red: 0.2, green: 0.85, blue: 0.5), title: "Settlement", btcPoint: "Final settlement on network", usdPoint: "Often involves delays and intermediaries")
                comparisonCard(icon: "eye.fill", iconColor: .yellow, title: "Transparency", btcPoint: "Public and verifiable", usdPoint: "Centrally managed")
                comparisonCard(icon: "waveform.path.ecg", iconColor: .red, title: "Volatility", btcPoint: "Can fluctuate significantly", usdPoint: "More stable short-term")
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }

    private func comparisonCard(icon: String, iconColor: Color, title: String, btcPoint: String, usdPoint: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconColor.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }

            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("BTC")
                        .font(.system(.caption2, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.orange)
                    Text(btcPoint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.orange.opacity(0.06))
                .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    Text("USD")
                        .font(.system(.caption2, design: .monospaced, weight: .heavy))
                        .foregroundStyle(.green)
                    Text(usdPoint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.green.opacity(0.06))
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Shared Components

    private func topicHeader(icon: String, color: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 64, height: 64)
                .background(color.opacity(0.1))
                .clipShape(.rect(cornerRadius: 18))

            Text(title)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.bottom, 8)
    }

    private func trackedLesson(id: String, number: Int, color: Color, icon: String, title: String, summary: String, detail: String) -> some View {
        TrackedLessonCard(
            id: id,
            number: number,
            color: color,
            icon: icon,
            title: title,
            summary: summary,
            detail: detail,
            learnProgress: learnProgress
        )
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        VStack(spacing: 4) {
            Text("For educational purposes only.")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            Text("This is not financial advice. Do not make financial decisions based on this app.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

// MARK: - Learn Topic Enum

enum LearnTopic: Hashable {
    case bitcoin
    case misconceptions
    case btcVsDollars
    case powerLaw
    case cycles
    case indicators
    case howToRead
    case glossary
    case dcaStrategy

    var progressKey: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .misconceptions: return "myth"
        case .btcVsDollars: return "btcvsusd"
        case .powerLaw: return "powerlaw"
        case .cycles: return "cycles"
        case .indicators: return "indicators"
        case .howToRead: return "howtoread"
        case .glossary: return "glossary"
        case .dcaStrategy: return "dca"
        }
    }

    var lessonCount: Int {
        switch self {
        case .bitcoin: return 12
        case .misconceptions: return 7
        case .btcVsDollars: return 7
        case .powerLaw: return 5
        case .cycles: return 7
        case .indicators: return 7
        case .howToRead: return 5
        case .glossary: return 9
        case .dcaStrategy: return 5
        }
    }
}

// MARK: - Tracked Lesson Card (with progress)

struct TrackedLessonCard: View {
    let id: String
    let number: Int
    let color: Color
    let icon: String
    let title: String
    let summary: String
    let detail: String
    let learnProgress: LearnProgressManager

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                isExpanded.toggle()
            }
            if isExpanded {
                learnProgress.markRead(id)
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    if learnProgress.isRead(id) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(number)")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(color)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(color)
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }

                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 1)

                    if isExpanded {
                        Divider()
                            .overlay(Color.primary.opacity(0.06))
                            .padding(.vertical, 8)

                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isExpanded ? color.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

// MARK: - Interactive Myth Card (Quiz Format)

struct InteractiveMythCard: View {
    let id: String
    let icon: String
    let iconColor: Color
    let myth: String
    let reality: String
    let detail: String
    let learnProgress: LearnProgressManager

    @State private var isRevealed: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                isRevealed.toggle()
            }
            if isRevealed {
                learnProgress.markRead(id)
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconColor)
                        .frame(width: 34, height: 34)
                        .background(iconColor.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(isRevealed ? "MYTH" : "TRUE OR FALSE?")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(isRevealed ? .red : .orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background((isRevealed ? Color.red : Color.orange).opacity(0.1))
                                .clipShape(Capsule())
                                .fixedSize()

                            if learnProgress.isRead(id) && !isRevealed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.orange)
                            }
                        }

                        Text("\"\(myth)\"")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if isRevealed {
                            HStack(spacing: 6) {
                                Text("FACT")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(Capsule())
                                    .fixedSize()
                                Text(reality)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }

                    Spacer(minLength: 0)

                    if !isRevealed {
                        Text("TAP")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                }

                if isRevealed {
                    Divider()
                        .overlay(Color.primary.opacity(0.06))
                        .padding(.vertical, 12)

                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 46)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isRevealed ? iconColor.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isRevealed)
    }
}

// MARK: - Numbered Lesson Card (kept for compatibility)

struct NumberedLessonCard: View {
    let number: Int
    let color: Color
    let icon: String
    let title: String
    let summary: String
    let detail: String

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Text("\(number)")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(color)
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }

                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 1)

                    if isExpanded {
                        Divider()
                            .overlay(Color.primary.opacity(0.06))
                            .padding(.vertical, 8)

                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(isExpanded ? color.opacity(0.2) : Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

// MARK: - Myth Buster Card (kept for compatibility)

struct MythBusterCard: View {
    let icon: String
    let iconColor: Color
    let myth: String
    let reality: String
    let detail: String

    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(iconColor)
                        .frame(width: 34, height: 34)
                        .background(iconColor.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
            Text("MYTH")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Capsule())
                                .fixedSize()
                            Text(myth)
                                .font(.caption)
                                .fontWeight(.heavy)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(spacing: 6) {
                            Text("FACT")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                                .fixedSize()
                            Text(reality)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded {
                    Divider()
                        .overlay(Color.primary.opacity(0.06))
                        .padding(.vertical, 12)

                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 46)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}
