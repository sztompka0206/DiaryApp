//
//  AccountView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var viewModel: DiaryViewModel
    @EnvironmentObject var fontSettings: FontSettings
    @EnvironmentObject var theme: ThemeSettings
    
    @AppStorage("userName") private var userName = "User"
    @State private var pdfURL: URL?
    @State private var showAlert = false
    
    var body: some View {
        Form {
            // ── プロフィール ──
            Section(header: Text("プロフィール")) {
                TextField("お名前を入力", text: $userName)
                    .textInputAutocapitalization(.words)
            }
            
            // ── フォント選択 ──
            Section(header: Text("フォント")) {
                Picker("Font", selection: $fontSettings.selectedFontName) {
                    ForEach(fontSettings.fontCandidates, id: \.postScript) { cand in
                        FontRow(candidate: cand)             // ← ↓ で定義
                            .tag(cand.postScript)            // 保存値は PostScript 名
                    }
                }
                .pickerStyle(.inline)
            }
            // ── テーマ切替 ──
            Section(header: Text("テーマ")) {
                Picker("App Theme", selection: $theme.selected) {
                    ForEach(ThemeSettings.Theme.allCases) { mode in
                        ThemeRowView(mode: mode)         // ★ サブビュー
                            .tag(mode)
                    }
                }
                .pickerStyle(.inline)
            }
            
            // ── PDF 出力 ──
            Section(header: Text("エクスポート")) {
                Button {
                    do {
                        pdfURL = try viewModel.exportPDF(userName: userName)
                    } catch { showAlert = true }
                } label: {
                    Label("日記を PDF に出力", systemImage: "doc.richtext")
                }
            }
            
            if let url = pdfURL {
                Section {
                    ShareLink(item: url,
                              preview: SharePreview("Diary.pdf",
                                                    image: Image(systemName: "doc.richtext")))
                }
            }
        }
        .if(theme.selected == .sepia) { view in        // ◎ セピアのときだけ
            view
                .scrollContentBackground(.hidden)      //  Form 背景を透過
                .background(                           //  自前のセピア色を敷く
                    theme.selected.backgroundColor
                        .ignoresSafeArea()
                )
        }
        .navigationBarTitle("マイページ")
        .alert("PDF 生成に失敗しました", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

// MARK: - 行ごとに切り出した軽量サブビュー

/// フォント候補 1 行
struct FontRow: View {
    let candidate: (display: String, postScript: String)
    
    var body: some View {
        Text(candidate.display.isEmpty ? "System" : candidate.display)
            .font(candidate.postScript.isEmpty
                  ? .body                      // システムフォント
                  : .custom(
                        candidate.postScript,
                        size: UIFont.preferredFont(forTextStyle: .body).pointSize,
                        relativeTo: .body      // Dynamic Type 対応
                    )
            )
    }
}

/// テーマ候補 1 行
private struct ThemeRowView: View {
    let mode: ThemeSettings.Theme
    
    var body: some View {
        let icon = switch mode {
        case .system: "iphone"
        case .light:  "sun.max"
        case .dark:   "moon"
        case .sepia:  "book.closed"  // ← 追加：クラシックテーマ用アイコン
        }
        Label(mode.label, systemImage: icon)
    }
}

extension View {
    @ViewBuilder
    func `if`<V: View>(_ cond: Bool,
                       transform: (Self) -> V) -> some View {
        cond ? AnyView(transform(self)) : AnyView(self)
    }
}
