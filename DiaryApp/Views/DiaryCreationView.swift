//
//  DiaryCreationView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import SwiftUI
import UIKit

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
    @ObservedObject var viewModel: DiaryViewModel
    @EnvironmentObject private var fontSettings: FontSettings
    @EnvironmentObject private var theme: ThemeSettings

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var errorMessage: String? = nil
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ───── タイトル ─────
            TextField("タイトル（例: 2025/06/08）", text: $title)
                .font(inputFont(for: .headline).weight(.bold))
                .textFieldStyle(PlainTextFieldStyle())      // ボーダー無し
                .padding(.horizontal)
                .padding(.top, 16)
                .onAppear {
                    title = formattedDate()
                }

            // ───── 本文入力 ─────
            TextEditor(text: $content)
                .font(inputFont(for: .body))
                .padding(.horizontal)
                .padding(.top, 4)
                .frame(minHeight: 240)
                .background(Color.clear)
                .scrollContentBackground(.hidden)           // iOS 16+ 白背景を削除

            // ───── エラー表示 ─────
            if let msg = errorMessage {
                Text(msg)
                    .font(inputFont(for: .footnote))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            // ───── 保存ボタン ─────
            HStack {
                Spacer()
                Button(action: saveEntry) {
                    Text("保存")
                        .font(inputFont(for: .headline).bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 32)
                        .background(theme.selected.accentColor)
                        .cornerRadius(12)
//                        .shadow(radius: 4)
                }
                Spacer()
            }
            .padding(.top, 8)

            Spacer()
        }
        .navigationTitle("日記を作成")
        .navigationBarTitleDisplayMode(.inline)
        .alert("完了", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text("日記が保存されました！")
        })
    }

    private func inputFont(for style: Font.TextStyle) -> Font {
        let ps = fontSettings.selectedFontName
        guard !ps.isEmpty else { return .system(style) }
        let size = UIFont.preferredFont(forTextStyle: style.uiKit).pointSize
        return .custom(ps, size: size, relativeTo: style)
    }

    private func saveEntry() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
            errorMessage = "コンテンツを入力してください"
            return
        }

        errorMessage = nil
        viewModel.addDiaryEntry(title: trimmedTitle, content: trimmedContent)
        title = ""; content = ""; showAlert = true
    }

    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df.string(from: Date())
    }
}
