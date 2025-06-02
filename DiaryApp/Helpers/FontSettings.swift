//
//  FontSettings.swift
//  DiaryApp
//
//  Updated: 2025-06-02 – navigationTitle まで含めて
//

import SwiftUI
import Combine
import UIKit

/// アプリ共通フォントを管理
final class FontSettings: ObservableObject {
    
    // MARK: - Persistent value
    private static let key = "selectedFontPostScript"
    
    /// 選択中フォント（システム＝空文字）
    @AppStorage(FontSettings.key) var selectedFontName: String = "" {
        didSet { applyFont() }
    }
    
    // MARK: - Font candidates  —— 表示名と PostScript 名のペア
    let fontCandidates: [(display: String, postScript: String)] = [
        ("System",             ""),
        ("Hannotate SC",       "HannotateSC-W5"),        // ← やわらかく自然な手書き感
        ("HanziPen SC",        "HanziPenSC-W5"),         // ← もっと丸っこい手書き
        ("Hiragino Sans",      "HiraginoSans-W3"),       // ← モダンで読みやすい
        ("Hiragino Mincho",    "HiraMinProN-W3"),        // ← 落ち着いた明朝体
        ("Yu Mincho",          "YuMin-Medium"),          // ← クラシックな日記にも
        ("Noto Sans CJK JP",  "NotoSansCJKjp-Regular"), // ← Google フォント
        ("Noto Serif CJK JP", "NotoSerifCJKjp-Regular"), // ← Google フォント
        ("HiraKakuProN-W3", "HiraKakuProN-W3"), // ← 角ゴシック
        ("HiraMaruProN-W4", "HiraMaruProN-W4"), // ← 丸ゴシック
        ("Kaiti SC", "KaitiSC-Regular"), // ← 楷書体
        ("PingFang SC", "PingFangSC-Regular"), // ← 微軟正黑體
        
    ]
    
    // MARK: - Init
    init() { applyFont() }   // アプリ起動時に反映
    
    // MARK: - Apply to UIKit / SwiftUI
    private func applyFont() {
        // 1) SwiftUI 側を再描画
        objectWillChange.send()
        
        // 2) NavigationBar の Large / Inline Title 用フォントを用意
        let ps = selectedFontName
        let inlineUIFont: UIFont = {
            if ps.isEmpty { return UIFont.preferredFont(forTextStyle: .headline) }
            return UIFont(name: ps,
                          size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
                   ?? UIFont.preferredFont(forTextStyle: .headline)
        }()
        
        let baseLarge = UIFont.preferredFont(forTextStyle: .largeTitle)
        let largeUIFont: UIFont = {
            if ps.isEmpty {                      // システムフォント
                return UIFontMetrics(forTextStyle: .largeTitle)
                       .scaledFont(for: baseLarge.withSize(baseLarge.pointSize * 0.7))
            }
            // カスタムフォント
            let size = baseLarge.pointSize * 0.7
            return UIFont(name: ps, size: size)
                   ?? baseLarge
        }()

        
        // 3) UINavigationBarAppearance を構築（Large / Inline 共通）
        var appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes      = [.font: inlineUIFont]   // Inline
        appearance.largeTitleTextAttributes = [.font: largeUIFont]    // Large
        
        // 4) 4 種類すべてに同じ Appearance を反映
        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance           = appearance
        navBar.scrollEdgeAppearance         = appearance   // Large Title 用
        navBar.compactAppearance            = appearance
        if #available(iOS 15.0, *) {
            navBar.compactScrollEdgeAppearance = appearance
        }
        
        // 5) すでに表示中のタイトルも即更新（NavigationStack 用）
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .forEach { $0.rootViewController?.view.setNeedsLayout() }
        }
    }
}
