//
//  ThemeSettings.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

final class ThemeSettings: ObservableObject {
    
    enum Theme: String, CaseIterable, Identifiable {
        case system, light, dark, sepia
        var id: String { rawValue }
        
        var label: String {
            switch self {
            case .system: return "システム"
            case .light:  return "ライト"
            case .dark:   return "ダーク"
            case .sepia:  return "セピア"
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .system, .light:
                return .white
            case .dark:
                return .black
            case .sepia:
                return Color("SepiaBackground") // Assetsに登録されていることが前提
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .system, .light:
                return .black
            case .dark:
                return .white
            case .sepia:
                return Color("SepiaText")
            }
        }
        
        var accentColor: Color {
            switch self {
            case .system, .light:
                return .blue
            case .dark:
                return .yellow
            case .sepia:
                return Color("SepiaAccent")
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system, .sepia: return nil
            }
        }
        /// ボタン上の文字色（背景とのコントラスト用）
        var buttonTextColor: Color {          // ← ★ これを追加
            switch self {
            case .system, .light: return .white          // 青ボタンには白文字
            case .dark, .sepia:   return .white          // 黄/セピアボタンでも白が読みやすい
            }
        }
    }
    @AppStorage("appTheme") var selected: Theme = .system {
        didSet { applyTabAppearance() }             // SwiftUI 再描画通知
    }
    init() { applyTabAppearance() }
    /// テーマに合わせて UITabBar の見た目を更新
    private func applyTabAppearance() {
        let a = UITabBarAppearance()
        a.configureWithDefaultBackground()
        UITabBar.appearance().tintColor  =
            selected == .dark ? .yellow : .systemBlue

        UITabBar.appearance().standardAppearance   = a
        UITabBar.appearance().scrollEdgeAppearance = a
    }
}
