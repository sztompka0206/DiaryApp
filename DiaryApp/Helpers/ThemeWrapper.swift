//
//  ThemaWrapper.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/09.
//

import SwiftUI

struct ThemeWrapper: ViewModifier {
    @EnvironmentObject var theme: ThemeSettings

    func body(content: Content) -> some View {
        ZStack {
            theme.selected.backgroundColor
                .ignoresSafeArea() // SafeArea も含めて塗りつぶす

            content
                .foregroundColor(theme.selected.foregroundColor)
                .tint(theme.selected.accentColor)
        }
    }
}

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemeWrapper())
    }
}
