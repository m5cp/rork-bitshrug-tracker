import Foundation

nonisolated struct DailyQuestion: Identifiable, Sendable {
    let id: String
    let question: String
    let choices: [String]
    let correctIndex: Int
    let explanation: String
    let category: QuestionCategory
    let difficulty: QuestionDifficulty

    nonisolated enum QuestionCategory: String, Sendable {
        case whitepaper = "Satoshi's White Paper"
        case history = "Bitcoin History"
        case technical = "How Bitcoin Works"
        case economics = "Bitcoin Economics"
        case security = "Security & Self-Custody"
        case culture = "Bitcoin Culture"
        case cycles = "Cycles & Halvings"
        case onChain = "On-Chain Analysis"
    }

    nonisolated enum QuestionDifficulty: String, Sendable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

extension DailyQuestion {
    static let bank: [DailyQuestion] = [
        // MARK: - Satoshi's White Paper
        DailyQuestion(
            id: "wp_1",
            question: "What is the title of Satoshi Nakamoto's white paper?",
            choices: [
                "Bitcoin: A Peer-to-Peer Electronic Cash System",
                "Bitcoin: A Decentralized Digital Currency",
                "Bitcoin: The Future of Money",
                "Bitcoin: A Trustless Payment Network"
            ],
            correctIndex: 0,
            explanation: "The full title is 'Bitcoin: A Peer-to-Peer Electronic Cash System,' published on October 31, 2008.",
            category: .whitepaper,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "wp_2",
            question: "According to the white paper, what problem does Bitcoin solve?",
            choices: [
                "The speed of international transfers",
                "The double-spending problem without a trusted third party",
                "The volatility of fiat currencies",
                "The energy consumption of banks"
            ],
            correctIndex: 1,
            explanation: "Satoshi's key innovation was solving double-spending — ensuring digital money can't be copied — without relying on a central authority.",
            category: .whitepaper,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "wp_3",
            question: "What does the white paper call the chain of digital signatures?",
            choices: [
                "A smart contract",
                "A merkle tree",
                "A chain of ownership",
                "An electronic coin"
            ],
            correctIndex: 3,
            explanation: "Satoshi defined an electronic coin as 'a chain of digital signatures' where each owner transfers the coin by signing a hash of the previous transaction.",
            category: .whitepaper,
            difficulty: .advanced
        ),
        DailyQuestion(
            id: "wp_4",
            question: "How many pages is the original Bitcoin white paper?",
            choices: ["5 pages", "9 pages", "12 pages", "21 pages"],
            correctIndex: 1,
            explanation: "The Bitcoin white paper is a concise 9 pages — remarkably short for a document that launched a trillion-dollar asset class.",
            category: .whitepaper,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "wp_5",
            question: "What consensus mechanism does the white paper describe?",
            choices: [
                "Proof of Stake",
                "Delegated Proof of Stake",
                "Proof of Work",
                "Proof of Authority"
            ],
            correctIndex: 2,
            explanation: "The white paper describes Proof of Work — nodes expend CPU power to find a hash that meets a difficulty target, securing the network.",
            category: .whitepaper,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "wp_6",
            question: "What year was the Bitcoin white paper published?",
            choices: ["2007", "2008", "2009", "2010"],
            correctIndex: 1,
            explanation: "The white paper was published on October 31, 2008. The Bitcoin network launched on January 3, 2009.",
            category: .whitepaper,
            difficulty: .beginner
        ),

        // MARK: - Bitcoin History
        DailyQuestion(
            id: "hist_1",
            question: "What message did Satoshi embed in the Genesis Block?",
            choices: [
                "Hello World",
                "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks",
                "In code we trust",
                "Vires in numeris"
            ],
            correctIndex: 1,
            explanation: "This headline from The Times newspaper served as both a timestamp and a commentary on the financial system Bitcoin was designed to challenge.",
            category: .history,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "hist_2",
            question: "How much Bitcoin was paid for two pizzas on Bitcoin Pizza Day?",
            choices: ["100 BTC", "1,000 BTC", "10,000 BTC", "50,000 BTC"],
            correctIndex: 2,
            explanation: "On May 22, 2010, Laszlo Hanyecz paid 10,000 BTC for two Papa John's pizzas — the first known real-world Bitcoin transaction.",
            category: .history,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "hist_3",
            question: "Which exchange collapsed in 2014 after losing 850,000 BTC?",
            choices: ["Binance", "FTX", "Mt. Gox", "Coinbase"],
            correctIndex: 2,
            explanation: "Mt. Gox handled over 70% of all BTC trades before collapsing in February 2014, cementing the 'not your keys, not your coins' mantra.",
            category: .history,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "hist_4",
            question: "Which country first adopted Bitcoin as legal tender?",
            choices: ["Panama", "El Salvador", "Paraguay", "Ukraine"],
            correctIndex: 1,
            explanation: "El Salvador became the first country to adopt Bitcoin as legal tender on September 7, 2021, under President Nayib Bukele.",
            category: .history,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "hist_5",
            question: "What event in 2017 led to the creation of Bitcoin Cash (BCH)?",
            choices: [
                "A security breach",
                "The Blocksize Wars — a hard fork over scaling",
                "Government regulation",
                "A mining pool attack"
            ],
            correctIndex: 1,
            explanation: "The community split over whether to increase block size or build Layer 2 solutions. Bitcoin kept small blocks; the fork created Bitcoin Cash.",
            category: .history,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "hist_6",
            question: "When did Bitcoin first reach $1?",
            choices: ["2009", "2010", "2011", "2012"],
            correctIndex: 2,
            explanation: "Bitcoin first reached $1 in February 2011, roughly two years after the Genesis Block was mined.",
            category: .history,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "hist_7",
            question: "In what month and year were spot Bitcoin ETFs approved in the US?",
            choices: ["October 2023", "January 2024", "March 2024", "June 2023"],
            correctIndex: 1,
            explanation: "The SEC approved spot Bitcoin ETFs in January 2024, allowing institutional investors easy access to Bitcoin through traditional brokerage accounts.",
            category: .history,
            difficulty: .intermediate
        ),

        // MARK: - How Bitcoin Works
        DailyQuestion(
            id: "tech_1",
            question: "Approximately how often is a new Bitcoin block mined?",
            choices: ["Every 1 minute", "Every 5 minutes", "Every 10 minutes", "Every 30 minutes"],
            correctIndex: 2,
            explanation: "Bitcoin's difficulty adjustment targets a 10-minute block interval. The difficulty recalibrates every 2,016 blocks to maintain this pace.",
            category: .technical,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "tech_2",
            question: "What is the maximum supply of Bitcoin?",
            choices: [
                "18 million",
                "21 million",
                "100 million",
                "There is no maximum"
            ],
            correctIndex: 1,
            explanation: "Bitcoin has a hard cap of 21 million coins. This fixed supply is enforced by the protocol and is one of Bitcoin's core value propositions.",
            category: .technical,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "tech_3",
            question: "How often does Bitcoin's mining difficulty adjust?",
            choices: [
                "Every 100 blocks",
                "Every 1,000 blocks",
                "Every 2,016 blocks",
                "Every 10,000 blocks"
            ],
            correctIndex: 2,
            explanation: "Mining difficulty adjusts every 2,016 blocks (roughly every two weeks) to maintain the 10-minute block target regardless of total hash rate.",
            category: .technical,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "tech_4",
            question: "What is the smallest unit of Bitcoin called?",
            choices: ["A bit", "A satoshi", "A wei", "A nano"],
            correctIndex: 1,
            explanation: "A satoshi (sat) is one hundred-millionth of a Bitcoin (0.00000001 BTC), named after Bitcoin's pseudonymous creator.",
            category: .technical,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "tech_5",
            question: "What is the Lightning Network?",
            choices: [
                "A faster blockchain",
                "A Layer 2 protocol for instant, cheap payments",
                "A mining pool network",
                "A Bitcoin wallet app"
            ],
            correctIndex: 1,
            explanation: "Lightning is a Layer 2 built on top of Bitcoin enabling near-instant payments with minimal fees via payment channels.",
            category: .technical,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "tech_6",
            question: "What is a Bitcoin node?",
            choices: [
                "A mining machine",
                "A computer running Bitcoin software that validates transactions",
                "A Bitcoin wallet",
                "A cryptocurrency exchange"
            ],
            correctIndex: 1,
            explanation: "Nodes independently verify every transaction and block against Bitcoin's consensus rules. Anyone can run a node, ensuring decentralization.",
            category: .technical,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "tech_7",
            question: "What cryptographic function secures Bitcoin transactions?",
            choices: ["MD5", "SHA-256", "RSA", "AES-128"],
            correctIndex: 1,
            explanation: "Bitcoin uses SHA-256 (Secure Hash Algorithm 256-bit) for its Proof of Work mining and transaction verification.",
            category: .technical,
            difficulty: .advanced
        ),

        // MARK: - Bitcoin Economics
        DailyQuestion(
            id: "econ_1",
            question: "What is Dollar Cost Averaging (DCA)?",
            choices: [
                "Buying Bitcoin all at once",
                "Investing a fixed amount at regular intervals",
                "Selling when the price drops",
                "Trading based on technical analysis"
            ],
            correctIndex: 1,
            explanation: "DCA removes the pressure of market timing by investing a fixed amount regularly, averaging out your cost basis over time.",
            category: .economics,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "econ_2",
            question: "What does 'HODL' stand for in Bitcoin culture?",
            choices: [
                "Hold On for Dear Life",
                "Holders Of Digital Ledgers",
                "High Output Digital Lending",
                "It was originally a typo for 'hold'"
            ],
            correctIndex: 3,
            explanation: "HODL originated from a typo in a 2013 Bitcoin forum post. It's since become a philosophy meaning: buy and hold through volatility.",
            category: .economics,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "econ_3",
            question: "What is Bitcoin's Stock-to-Flow ratio measuring?",
            choices: [
                "Market cap to trading volume",
                "Existing supply to annual new production",
                "Price to earnings",
                "Network fees to miner revenue"
            ],
            correctIndex: 1,
            explanation: "Stock-to-Flow compares existing supply to new production. Higher ratio = more scarce. After each halving, S2F doubles.",
            category: .economics,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "econ_4",
            question: "Approximately what percentage of all Bitcoin is estimated to be permanently lost?",
            choices: ["5%", "10%", "20%", "40%"],
            correctIndex: 2,
            explanation: "Roughly 20% of all Bitcoin (about 3.7 million BTC) is estimated to be permanently lost due to forgotten keys, lost wallets, or deceased holders.",
            category: .economics,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "econ_5",
            question: "What is Bitcoin's market cap compared to gold's?",
            choices: [
                "Bitcoin is larger than gold",
                "About equal",
                "Bitcoin is roughly 1/7th of gold",
                "Bitcoin is 1/100th of gold"
            ],
            correctIndex: 2,
            explanation: "Bitcoin's market cap (~$2T) is roughly 1/7th of gold's (~$15T). If Bitcoin captured more store-of-value use, significant upside remains.",
            category: .economics,
            difficulty: .intermediate
        ),

        // MARK: - Security & Self-Custody
        DailyQuestion(
            id: "sec_1",
            question: "What does 'Not your keys, not your coins' mean?",
            choices: [
                "You need a physical key to access Bitcoin",
                "Exchanges always keep your Bitcoin safe",
                "True ownership requires holding your own private keys",
                "Bitcoin can only be stored on hardware"
            ],
            correctIndex: 2,
            explanation: "If you hold Bitcoin on an exchange, they control the keys. Self-custody — holding your own private keys — gives you true ownership.",
            category: .security,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "sec_2",
            question: "What is a seed phrase?",
            choices: [
                "A password for your exchange account",
                "12 or 24 words that serve as your master wallet backup",
                "A code to speed up transactions",
                "An encryption key for messages"
            ],
            correctIndex: 1,
            explanation: "A seed phrase (12 or 24 words) is your master backup. Lose it and you lose access. Share it and someone else can steal your Bitcoin.",
            category: .security,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "sec_3",
            question: "What is the difference between a hot wallet and a cold wallet?",
            choices: [
                "Hot wallets are faster, cold wallets are slower",
                "Hot wallets are online, cold wallets are offline",
                "Hot wallets are free, cold wallets cost money",
                "There is no difference"
            ],
            correctIndex: 1,
            explanation: "Hot wallets are internet-connected (convenient for daily use). Cold wallets store keys offline (more secure for long-term storage).",
            category: .security,
            difficulty: .beginner
        ),

        // MARK: - Cycles & Halvings
        DailyQuestion(
            id: "cycle_1",
            question: "How many blocks between each Bitcoin halving?",
            choices: ["100,000", "150,000", "210,000", "500,000"],
            correctIndex: 2,
            explanation: "Every 210,000 blocks (~4 years), the mining reward is cut in half. This is hard-coded into Bitcoin's protocol.",
            category: .cycles,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "cycle_2",
            question: "What was the block reward when Bitcoin launched in 2009?",
            choices: ["100 BTC", "50 BTC", "25 BTC", "12.5 BTC"],
            correctIndex: 1,
            explanation: "The initial block reward was 50 BTC. It has halved four times: to 25, 12.5, 6.25, and currently 3.125 BTC.",
            category: .cycles,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "cycle_3",
            question: "What is the current Bitcoin block reward (after the 2024 halving)?",
            choices: ["6.25 BTC", "3.125 BTC", "1.5625 BTC", "12.5 BTC"],
            correctIndex: 1,
            explanation: "After the April 2024 halving, the block reward dropped from 6.25 to 3.125 BTC per block.",
            category: .cycles,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "cycle_4",
            question: "Approximately when is the last Bitcoin expected to be mined?",
            choices: ["2050", "2080", "2100", "2140"],
            correctIndex: 3,
            explanation: "The last Bitcoin is expected to be mined around the year 2140, when all 21 million coins will have been issued.",
            category: .cycles,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "cycle_5",
            question: "How many Bitcoin halvings have occurred as of 2024?",
            choices: ["2", "3", "4", "5"],
            correctIndex: 2,
            explanation: "Four halvings: November 2012, July 2016, May 2020, and April 2024. We are now in Epoch 5.",
            category: .cycles,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "cycle_6",
            question: "What is the Power Law model for Bitcoin?",
            choices: [
                "A model predicting Bitcoin will replace all currencies",
                "A mathematical relationship where price scales as a power of time",
                "A law requiring miners to use renewable energy",
                "A trading strategy based on momentum"
            ],
            correctIndex: 1,
            explanation: "The Power Law shows Bitcoin's price follows a linear relationship on a log-log chart: log₁₀(price) = 5.82 × log₁₀(days) − k.",
            category: .cycles,
            difficulty: .advanced
        ),

        // MARK: - On-Chain Analysis
        DailyQuestion(
            id: "onchain_1",
            question: "What does the Fear & Greed Index measure?",
            choices: [
                "Bitcoin's transaction speed",
                "Market sentiment from 0 (Extreme Fear) to 100 (Extreme Greed)",
                "Mining profitability",
                "Exchange withdrawal rates"
            ],
            correctIndex: 1,
            explanation: "The Fear & Greed Index aggregates volatility, volume, social media, dominance, and trends into a single sentiment score.",
            category: .onChain,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "onchain_2",
            question: "What does the MVRV Z-Score compare?",
            choices: [
                "Mining cost to electricity price",
                "Market value to realized value (aggregate cost basis)",
                "Volume to volatility",
                "Hash rate to difficulty"
            ],
            correctIndex: 1,
            explanation: "MVRV Z-Score compares Bitcoin's market cap to its realized cap (average cost basis). Extreme highs signal tops; extreme lows signal bottoms.",
            category: .onChain,
            difficulty: .advanced
        ),
        DailyQuestion(
            id: "onchain_3",
            question: "What does the Puell Multiple track?",
            choices: [
                "The number of active wallets",
                "Daily miner revenue compared to the 365-day average",
                "The speed of transaction confirmations",
                "Exchange reserves"
            ],
            correctIndex: 1,
            explanation: "When miners earn much more than usual (Puell > 4), it often signals a top. Below 0.5 signals capitulation and potential bottoms.",
            category: .onChain,
            difficulty: .advanced
        ),

        // MARK: - Bitcoin Culture
        DailyQuestion(
            id: "culture_1",
            question: "What date is celebrated as Bitcoin Pizza Day?",
            choices: ["January 3", "March 14", "May 22", "October 31"],
            correctIndex: 2,
            explanation: "May 22 commemorates the first real-world Bitcoin transaction in 2010 when 10,000 BTC was paid for two pizzas.",
            category: .culture,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "culture_2",
            question: "How many times has Bitcoin been declared 'dead' by media since 2009?",
            choices: ["About 50", "About 150", "About 300", "Over 470"],
            correctIndex: 3,
            explanation: "Bitcoin has been declared 'dead' by media over 470 times since 2009 — yet it continues to reach new all-time highs.",
            category: .culture,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "culture_3",
            question: "What does 'stacking sats' mean?",
            choices: [
                "Building satellite dishes for mining",
                "Accumulating small amounts of Bitcoin over time",
                "Stacking blocks in the blockchain",
                "A type of Bitcoin trading strategy"
            ],
            correctIndex: 1,
            explanation: "Stacking sats means accumulating satoshis (the smallest unit of Bitcoin) over time, typically through DCA.",
            category: .culture,
            difficulty: .beginner
        ),
        DailyQuestion(
            id: "culture_4",
            question: "What is Bitcoin's 'Genesis Day'?",
            choices: [
                "October 31, 2008",
                "January 3, 2009",
                "May 22, 2010",
                "November 28, 2012"
            ],
            correctIndex: 1,
            explanation: "January 3, 2009 is when the Genesis Block (Block 0) was mined — Bitcoin's birthday.",
            category: .culture,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "culture_5",
            question: "What does 'Vires in Numeris' mean?",
            choices: [
                "Victory in numbers",
                "Virtue in numbers",
                "Strength in numbers",
                "Value in numbers"
            ],
            correctIndex: 2,
            explanation: "'Vires in Numeris' (Strength in Numbers) is a popular Bitcoin motto reflecting the mathematical and cryptographic foundation of Bitcoin.",
            category: .culture,
            difficulty: .intermediate
        ),
        DailyQuestion(
            id: "culture_6",
            question: "What was the approximate date of Bitcoin's white paper release?",
            choices: [
                "July 4, 2008",
                "October 31, 2008",
                "January 3, 2009",
                "December 25, 2008"
            ],
            correctIndex: 1,
            explanation: "The Bitcoin white paper was published on Halloween — October 31, 2008 — on the cryptography mailing list.",
            category: .culture,
            difficulty: .beginner
        ),
    ]
}
