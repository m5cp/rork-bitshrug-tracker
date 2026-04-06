# Fog of Bitcoin — Bitcoin Macro Environment Tracker

## Overview

Fog of Bitcoin is a premium Bitcoin macro analysis app that helps users understand the current market environment through a single Environment Score, interactive charts, on-chain indicators, and educational content about the 4-year cycle and Power Law theories. Designed for long-term positioning, not short-term trading.

## Features

### Home Dashboard (Tab 1)
- **Live Bitcoin price** with 24h change, market cap, volume, and 7d change
- **Interactive price chart** with 1W/1M/3M/6M/1Y range selector, touch-to-inspect crosshair, and 200 EMA overlay
- **Environment Score** — hero card with animated ring (0–100), color-coded status, and market context summary
- **"What Changed" insight** — daily narrative explaining score movement with expansion detail
- **Score Breakdown** — 4 drivers (Trend, Momentum, Positioning, Volatility) with progress bars and status badges
- **Weekly Summary** — direction (Improving/Weakening/Unchanged), score change, and weekly narrative
- **Market Context** — 1–2 sentence summary connecting cycle phase, positioning, and environment
- **Settings & About** accessible from toolbar

### Indicators (Tab 2)
- **Fear & Greed Index** — circular gauge with sentiment label and description
- **200-Day EMA** — bull/bear status with % distance
- **200-Week MA** — calculated from 1,400 days of real price history, shows price vs long-term floor
- **MVRV Z-Score** — market value vs realized value with zone labels (Deep Value → Euphoria)
- **Puell Multiple** — miner revenue vs 365-day average
- **Stock-to-Flow** — scarcity model ratio
- **Supply in Profit** — estimated % based on MVRV
- **Freemium gating** — 3 indicators free, remaining locked behind Premium
- **Premium upsell card** — contextual upgrade prompt for free users

### Power Law (Tab 3)
- **Power Law corridor chart** — interactive Swift Charts visualization showing price vs support/resistance bands
- **Position indicator** — visual slider with percentage through corridor
- **Price range** — support, current, and resistance prices
- **Rainbow Chart** — 10-band visualization with "You Are Here" indicator
- **Educational content** — Power Law theory, corridor reading guide, Rainbow Chart explanation

### Cycle (Tab 4)
- **Halving Cycle Ring** — animated angular gradient showing progress through current 4-year cycle
- **Phase Timeline** — 7-phase visual timeline with current position
- **Halving Stats** — days since/until halving, block reward
- **Historical Halvings** — all 4 eras with dates, rewards, and cycle peaks
- **Educational content** — halving mechanics, cycle theory, and how Fog of Bitcoin uses it

### Onboarding
- **4-page onboarding flow** — Welcome, Environment Score, Power Law & Cycle, Daily Insights
- **Animated page indicators** — capsule-style with spring animations
- **First-time only** — stored in UserDefaults, never shown again

### Freemium Model
- **Free tier**: Environment Score, price + chart, 3 core indicators, cycle info, Power Law basics
- **Premium tier**: All 6+ indicators, daily insights, weekly summaries, smart notifications, Power Law charts
- **Paywall**: Feature comparison table, monthly ($4.99), yearly ($39.99), and lifetime ($49.99) plans
- **PremiumManager** — centralized gating logic with UserDefaults persistence

### Notifications
- **Environment change alerts** — when score moves ≥5 points
- **Component change alerts** — when Trend/Momentum/Positioning/Volatility shifts category
- **Indicator alerts** — when key indicators change direction
- **Max 1 notification per day** — calm, no hype, no financial advice language

### Settings & About
- **About Fog of Bitcoin** — Environment Score explanation, score ranges, data sources, disclaimer
- **Privacy section** — no personal data collected, no tracking
- **Notification settings** — granular toggle for each alert type
- **Data sources** — Finnhub, CryptoCompare, Alternative.me, Blockchain.info, calculated indicators

## Design

- **Dark theme** — deep black background with subtle white-opacity card surfaces (0.04)
- **Orange accent** — Bitcoin-branded orange tint for tab bar and interactive elements
- **Monospaced typography** — financial terminal feel for numeric values
- **Color-coded status badges** — green/orange/red capsule badges on all indicators
- **Animated score ring** — angular gradient with glow shadow effect
- **Interactive charts** — Swift Charts with touch-to-inspect, range selection, MA overlays
- **Power Law chart** — support/resistance corridor with price overlay
- **Consistent card radius** — 18pt rounded corners throughout
- **iPad adaptive** — responsive layouts with size class detection
- **Entrance animations** — fade + slide on Home tab sections
- **Haptic feedback** — success on data refresh, selection on range picker, impact on interactions

## Data Sources

- **Finnhub API** — real-time BTC price and 24h change (requires API key via `EXPO_PUBLIC_FINNHUB_API_KEY`)
- **CryptoCompare API** — market cap, volume, circulating supply, 365-day daily history, 1400-day history for 200-Week MA calculation (free, no key)
- **Alternative.me API** — Fear & Greed Index (free, no key)
- **Blockchain.info API** — hash rate, block height (free, no key)
- **Calculated indicators** — Environment Score (Trend/Momentum/Positioning/Volatility), MVRV Z-Score, Puell Multiple, S2F (using real supply data), Power Law corridor, Rainbow Chart, 200-Day EMA, 50/200-Day SMA (all computed from real historical price data)

## Architecture

- **MVVM** — BitcoinViewModel handles all data + scoring logic
- **@Observable** — modern observation for reactive UI
- **PremiumManager** — singleton for freemium gating
- **NotificationManager** — singleton for alert evaluation and scheduling
- **BitcoinService** — nonisolated Sendable service for API + calculations

## App Icon

- Dark background with the Bitcoin "₿" symbol rendered in a glowing orange/amber gradient, with a subtle shrug emoticon (¯\\\_(ツ)\_/¯) motif incorporated — playful yet clean
