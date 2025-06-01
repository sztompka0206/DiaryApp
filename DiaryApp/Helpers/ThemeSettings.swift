//
//  ThemeSettings.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

final class ThemeSettings: ObservableObject {
    
    enum Theme: String, CaseIterable, Identifiable {
        case system, light, dark
        
        var id: String { rawValue }
        
        /// SwiftUI に渡す ColorScheme
        var colorScheme: ColorScheme? {
            switch self {
            case .system: nil
            case .light:  .light
            case .dark:   .dark
            }
        }
        
        /// アカウント画面に表示する名称
        var label: String {
            switch self {
            case .system: "システム"
            case .light:  "ライト"
            case .dark:   "ダーク"
            }
        }
        
        /// アイコン名（お好みで）
        var symbolName: String {
            switch self {
            case .system: "iphone"
            case .light:  "sun.max"
            case .dark:   "moon"
            }
        }
    }
    
    @AppStorage("appTheme") var selected: Theme = .system {
        didSet { objectWillChange.send() }             // SwiftUI 再描画通知
    }
}
