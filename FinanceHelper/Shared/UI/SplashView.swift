import SwiftUI
import SwiftData

struct SplashView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            FinanceTheme.background
                .ignoresSafeArea()

            VStack(spacing: FinanceSpacing.regular) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(FinanceTheme.accent)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("FinanceHelper")
                    .font(.title.weight(.bold))
                    .foregroundStyle(FinanceTheme.textPrimary)
                    .opacity(opacity)

                Text("Save Money = Make Money")
                    .font(.subheadline)
                    .foregroundStyle(FinanceTheme.textSecondary)
                    .opacity(opacity)
            }
            .padding(FinanceSpacing.large)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
        .modelContainer(PreviewSampleData.container)
}
