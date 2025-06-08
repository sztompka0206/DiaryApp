//
//  DiaryDetail.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI
import UIKit

// ────────────────────────────────────────────
// MARK: - UIFont ⇄ Font 変換
// ────────────────────────────────────────────
private extension Font.TextStyle {
    var uiKit: UIFont.TextStyle {
        switch self {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
}

// ────────────────────────────────────────────
// MARK: - テーマ連動 Filled ボタンスタイル
// ────────────────────────────────────────────
struct FilledThemedButton: ButtonStyle {
    @EnvironmentObject var theme: ThemeSettings
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(theme.selected.buttonTextColor)
            .padding(.vertical, 10)
            .padding(.horizontal, 32)
            .background(
                theme.selected.accentColor.opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .cornerRadius(12)
    }
}

// ────────────────────────────────────────────
// MARK: - DiaryDetailView
// ────────────────────────────────────────────
struct DiaryDetailView: View {
    // 依存
    @ObservedObject var viewModel: DiaryViewModel
    @State var entry: DiaryEntry                 // 編集用コピー
    
    @EnvironmentObject private var fontSettings: FontSettings
    @EnvironmentObject private var theme: ThemeSettings
    
    // UI 状態
    @State private var isEditing = false
    @State private var draft: DiaryEntry? = nil  // キャンセル用バックアップ
    @State private var showSaved = false         // 保存完了アラート
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ───── タイトル ─────
            TextField("タイトル（例: 2025/06/09）", text: $entry.title)
                .font(inputFont(for: .headline).weight(.bold))
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 16)
                .disabled(!isEditing)
            
            // ───── 本文 ─────
            if isEditing {
                TextEditor(text: $entry.content)
                    .font(inputFont(for: .body))
                    .padding(.horizontal)
                    .frame(minHeight: 240)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            } else {
                ScrollView {
                    Text(entry.content)
                        .font(inputFont(for: .body))
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // ───── 保存ボタン ─────
            if isEditing {
                HStack {
                    Spacer()
                    Button("保存", action: saveEntry)
                        .buttonStyle(FilledThemedButton())
                    Spacer()
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .background(theme.selected.backgroundColor.ignoresSafeArea())
        .navigationTitle("日記詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("キャンセル", action: cancelEdit)
                        .font(inputFont(for: .body))
                } else {
                    Button("編集", action: startEdit)
                        .font(inputFont(for: .body))
                }
            }
        }
        .alert("完了", isPresented: $showSaved) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("日記を保存しました！")
        }
    }
    
    // ────────────────────────────
    // MARK: - 編集モード制御
    // ────────────────────────────
    private func startEdit() {
        draft = entry                               // バックアップ
        isEditing = true
    }
    
    private func saveEntry() {
        viewModel.saveDiaryEntry(entry)
        isEditing = false
        showSaved = true
    }
    
    private func cancelEdit() {
        if let draft { entry = draft }              // 元に戻す
        isEditing = false
    }
    
    // ────────────────────────────
    // MARK: - Font Helper
    // ────────────────────────────
    private func inputFont(for style: Font.TextStyle) -> Font {
        let ps = fontSettings.selectedFontName
        guard !ps.isEmpty else { return .system(style) }
        let size = UIFont.preferredFont(forTextStyle: style.uiKit).pointSize
        return .custom(ps, size: size, relativeTo: style)
    }
}
