//
//  DiaryDetail.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI
import UIKit

//────────────────────────────────────────────
// MARK: - Font.TextStyle ↔︎ UIFont.TextStyle
//────────────────────────────────────────────
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

//────────────────────────────────────────────
// MARK: - DiaryDetailView
//────────────────────────────────────────────
struct DiaryDetailView: View {
    // 依存
    @ObservedObject var viewModel: DiaryViewModel
    @State var entry: DiaryEntry               // 編集用コピー
    @EnvironmentObject private var fontSettings: FontSettings
    @State private var isEditing = false
    
    //────────────────────────────────────────
    // MARK: - Body
    //────────────────────────────────────────
    var body: some View {
        VStack {
            // ───── タイトル ─────
            TextField("タイトル", text: $entry.title)
                .font(customFont(.title2).bold())
                .padding(.top, 20)
                .disabled(!isEditing)
            
            // ───── 本文 ─────
            if isEditing {
                TextEditor(text: $entry.content)
                    .font(customFont(.body))
                    .padding()
                    .border(Color.gray, width: 1)
            } else {
                ScrollView {
                    Text(entry.content)
                        .font(customFont(.body))
                        .padding()
                }
            }
            
            // ───── 保存ボタン (編集時のみ) ─────
            if isEditing {
                Button(action: toggleEdit) {
                    Text("保存")
                        .font(customFont(.headline).bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 32)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle("日記詳細", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: toggleEdit) {
            Text(isEditing ? "キャンセル" : "編集")
                .font(customFont(.body))
                .foregroundColor(.blue)
        })
    }
    
    //────────────────────────────────────────
    // MARK: - Helpers
    //────────────────────────────────────────
    /// FontSettings に合わせて Font を生成
    private func customFont(_ style: Font.TextStyle) -> Font {
        let ps = fontSettings.selectedFontName
        guard !ps.isEmpty else { return .system(style) }
        
        let size = UIFont.preferredFont(forTextStyle: style.uiKit).pointSize
        return .custom(ps, size: size, relativeTo: style)
    }
    
    /// 編集モード切替と保存
    private func toggleEdit() {
        if isEditing {
            viewModel.saveDiaryEntry(entry)       // 保存
        }
        isEditing.toggle()
    }
}
