import SwiftUI

struct SectionCardView<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        FinanceSurface {
            VStack(alignment: .leading, spacing: FinanceSpacing.regular) {
                VStack(alignment: .leading, spacing: FinanceSpacing.xxSmall) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(FinanceTheme.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(FinanceTheme.textSecondary)
                    }
                }

                content
            }
        }
    }
}
