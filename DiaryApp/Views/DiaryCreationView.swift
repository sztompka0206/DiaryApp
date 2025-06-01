//
//  DiaryCreationView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import SwiftUI
import UIKit

// ❶ SwiftUI → UIKit の対応表を Extension で用意
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

struct DiaryCreationView: View {
    // -----------------------------
    // MARK: - Dependencies & State
    // -----------------------------
    @ObservedObject var viewModel: DiaryViewModel
    @EnvironmentObject private var fontSettings: FontSettings    // ← 追加

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var errorMessage: String? = nil
    @State private var showAlert: Bool = false

    // -----------------------------
    // MARK: - Body
    // -----------------------------
    var body: some View {
        VStack {
            // ───── タイトル入力 ─────
            TextField("今日の日記", text: $title)
                .font(inputFont(for: .headline))          // ← 追加
                .textFieldStyle(.roundedBorder)
                .padding()
                .onAppear { title = formattedDate() }

            // ───── 本文入力 ─────
            TextEditor(text: $content)
                .font(inputFont(for: .body))              // ← 追加
                .padding()
                .border(Color.gray, width: 1)

            // ───── エラー表示 ─────
            if let msg = errorMessage {
                Text(msg)
                    .font(inputFont(for: .footnote))      // ここも揃える
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            // ───── 保存ボタン ─────
            Button(action: saveEntry) {
                Text("保存")
                    .font(inputFont(for: .headline).bold())   // フォント統一
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .padding()
            .alert("完了",
                   isPresented: $showAlert,
                   actions: { Button("OK", role: .cancel) { } },
                   message: { Text("日記が保存されました！") })

            Spacer()
        }
        .navigationBarTitle("日記を作成", displayMode: .inline)
    }

    // -----------------------------
    // MARK: - Helpers
    // -----------------------------
    /// 選択フォントに合わせて `Font` を生成（Dynamic Type 対応）
    private func inputFont(for style: Font.TextStyle) -> Font {
        let ps = fontSettings.selectedFontName
        
        // システムフォントの場合はそのまま
        guard !ps.isEmpty else { return Font.system(style) }
        
        // ベースサイズだけ UIKit から取得して Dynamic Type を維持
        let baseSize = UIFont.preferredFont(forTextStyle: style.uiKit).pointSize
        
        return Font.custom(ps, size: baseSize, relativeTo: style)
    }

    private func saveEntry() {
        // 空チェック
        let trimmedTitle   = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
            errorMessage = "コンテンツを入力してください"
            return
        }
        errorMessage = nil

        // 保存
        viewModel.addDiaryEntry(title: trimmedTitle, content: trimmedContent)
        title = ""; content = ""; showAlert = true
    }

    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df.string(from: Date())
    }
}
