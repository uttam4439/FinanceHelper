import SwiftUI
import SwiftData

struct MarketHubView: View {
    private let ideas: [MarketIdea] = [
        MarketIdea(title: "Quick Market Search", subtitle: "Find tickers, funds, or indices", systemImage: "magnifyingglass"),
        MarketIdea(title: "Watchlist", subtitle: "Track favorite stocks & ETFs", systemImage: "bookmark", comingSoon: true),
        MarketIdea(title: "Investment Insights", subtitle: "See daily movers and sector heat", systemImage: "chart.bar.doc.horizontal"),
        MarketIdea(title: "Learn Investing", subtitle: "Short guides for beginners", systemImage: "book.closed")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FinanceSpacing.sectionGap) {
                HStack(spacing: FinanceSpacing.small) {
                    Text("Market & Investing")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(FinanceTheme.textPrimary)

                    Spacer()

                    Text("Coming Soon")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FinanceTheme.accent)
                        .padding(.horizontal, FinanceSpacing.small)
                        .padding(.vertical, FinanceSpacing.xSmall)
                        .background(
                            Capsule(style: .continuous)
                                .fill(FinanceTheme.accent.opacity(0.15))
                        )
                }

                Text("Explore markets, track ideas, and keep an eye on investments. Coming soon: live data and watchlists.")
                    .font(.subheadline)
                    .foregroundStyle(FinanceTheme.textSecondary)

                FinanceSurface {
                    VStack(alignment: .leading, spacing: FinanceSpacing.cardGap) {
                        ForEach(ideas) { idea in
                            HStack(spacing: FinanceSpacing.medium) {
                                Image(systemName: idea.systemImage)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(FinanceTheme.accent)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: FinanceRadius.chip, style: .continuous)
                                            .fill(FinanceTheme.secondaryCard)
                                    )

                                VStack(alignment: .leading, spacing: FinanceSpacing.xSmall) {
                                    Text(idea.title + (idea.comingSoon ? " (Coming Soon)" : ""))
                                        .font(.headline)
                                        .foregroundStyle(FinanceTheme.textPrimary)
                                    Text(idea.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(FinanceTheme.textSecondary)
                                }

                                Spacer()

                                if idea.comingSoon {
                                    Text("Later")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(FinanceTheme.textSecondary)
                                        .padding(.horizontal, FinanceSpacing.small)
                                        .padding(.vertical, FinanceSpacing.xSmall)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(FinanceTheme.secondaryCard.opacity(0.9))
                                        )
                                } else {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(FinanceTheme.textSecondary)
                                }
                            }
                            .padding(.vertical, FinanceSpacing.xSmall)
                        }
                    }
                }
            }
            .padding(.horizontal, FinanceSpacing.screenHorizontal)
            .padding(.vertical, FinanceSpacing.screenVertical)
        }
        .background(FinanceTheme.background.ignoresSafeArea())
        .navigationTitle("Markets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MarketIdea: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    var comingSoon: Bool = false
}

#Preview {
    NavigationStack {
        MarketHubView()
    }
    .modelContainer(PreviewSampleData.container)
}
