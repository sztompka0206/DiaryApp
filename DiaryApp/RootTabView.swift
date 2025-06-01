//
//  RootTabView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

struct RootTabView: View {
    @StateObject private var vm    = DiaryViewModel()
    @StateObject private var fs    = FontSettings()
    @StateObject private var theme = ThemeSettings()
    
    var body: some View {
        TabView {
            // ───────── 1) ホーム ─────────
            NavigationStack {
                HomeContentView(viewModel: vm)
            }
            .tabItem {
                Image(systemName: "house")
                    .accessibilityLabel("Home")
            }
            
            // ───────── 2) カレンダー ─────────
            NavigationStack {
                CalendarView(
                    viewModel: vm,
                    selectedDate: .constant(Date())
                )
            }
            .tabItem {
                Image(systemName: "calendar")
                    .accessibilityLabel("Calendar")
            }
            
            // ───────── 3) 新規作成 ─────────
            NavigationStack {
                DiaryCreationView(viewModel: vm)
            }
            .tabItem {
                Image(systemName: "plus")
                    .accessibilityLabel("New Entry")
            }
            
            // ───────── 4) アカウント ─────────
            NavigationStack {
                AccountView()
                    .environmentObject(vm)
            }
            .tabItem {
                Image(systemName: "person")
                    .accessibilityLabel("Account")
            }
        }
        .environmentObject(vm)
        .environmentObject(fs)
        .environmentObject(theme)
        // ★ 追加：Picker で選んだフォントを全ビューへ流す
        .environment(\.font, globalFont(for: fs))
        // 既存のテーマ切り替え
        .preferredColorScheme(theme.selected.colorScheme)
    }
    
    /// 選択フォント → SwiftUI.Font へ変換
    private func globalFont(for fs: FontSettings) -> Font {
        if fs.selectedFontName.isEmpty {
            return .body                       // システムフォント
        } else {
            return .custom(
                fs.selectedFontName,
                size: UIFont.preferredFont(forTextStyle: .body).pointSize,
                relativeTo: .body              // Dynamic Type 対応
            )
        }
    }
}
