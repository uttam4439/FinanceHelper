//
//  FinanceTheme.swift
//  FinanceHelper
//
//  Created by Codex on 05/04/26.
//

import SwiftUI
import UIKit

enum FinanceTheme {
    static let background = Color(dynamicLight: UIColor(red: 0.98, green: 0.95, blue: 0.91, alpha: 1),
                                  dark: UIColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1))
    static let card = Color(dynamicLight: UIColor.white,
                            dark: UIColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1))
    static let secondaryCard = Color(dynamicLight: UIColor(red: 0.96, green: 0.91, blue: 0.85, alpha: 1),
                                     dark: UIColor(red: 0.19, green: 0.17, blue: 0.15, alpha: 1))
    static let accent = Color(dynamicLight: UIColor(red: 0.94, green: 0.53, blue: 0.25, alpha: 1),
                              dark: UIColor(red: 0.96, green: 0.58, blue: 0.30, alpha: 1))
    static let accentSoft = Color(dynamicLight: UIColor(red: 0.98, green: 0.89, blue: 0.78, alpha: 1),
                                  dark: UIColor(red: 0.29, green: 0.20, blue: 0.14, alpha: 1))
    static let textPrimary = Color(dynamicLight: UIColor(red: 0.14, green: 0.12, blue: 0.11, alpha: 1),
                                   dark: UIColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1))
    static let textSecondary = Color(dynamicLight: UIColor(red: 0.45, green: 0.39, blue: 0.34, alpha: 1),
                                     dark: UIColor(red: 0.73, green: 0.68, blue: 0.62, alpha: 1))
    static let success = Color(dynamicLight: UIColor(red: 0.46, green: 0.68, blue: 0.38, alpha: 1),
                               dark: UIColor(red: 0.52, green: 0.78, blue: 0.45, alpha: 1))
    static let stroke = Color(dynamicLight: UIColor.black.withAlphaComponent(0.03),
                              dark: UIColor.white.withAlphaComponent(0.06))
    static let shadow = Color(dynamicLight: UIColor.black.withAlphaComponent(0.06),
                              dark: UIColor.black.withAlphaComponent(0.22))
}

struct FinanceSurface<Content: View>: View {
    let padding: CGFloat
    @ViewBuilder var content: Content

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(FinanceTheme.card)
                .shadow(color: FinanceTheme.shadow, radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(FinanceTheme.stroke, lineWidth: 1)
        )
    }
}

struct FinancePillButtonStyle: ButtonStyle {
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(filled ? Color.white : FinanceTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(filled ? FinanceTheme.accent : FinanceTheme.secondaryCard)
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
    }
}

struct FinanceChip: View {
    let title: String
    let systemImage: String
    var filled = false

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(filled ? Color.white : FinanceTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(filled ? FinanceTheme.accent : FinanceTheme.secondaryCard)
            )
    }
}

private extension Color {
    init(dynamicLight light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
