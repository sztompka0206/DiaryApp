//
//  AccountView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI
import PDFKit                                 // PDF 生成用（iOS 11+）

struct AccountView: View {
    // 端末に永続化されるユーザー名
    @AppStorage("userName") private var userName: String = "User"
    
    @EnvironmentObject var viewModel: DiaryViewModel      // Tab 共通で渡しておく
    
    // PDF 生成後の URL（ShareLink 用）
    @State private var pdfURL: URL?
    @State private var showAlert = false                  // 生成失敗時
    
    var body: some View {
        Form {
            // ───────── プロフィール ─────────
            Section(header: Text("プロフィール")) {
                TextField("お名前を入力", text: $userName)
                    .textInputAutocapitalization(.words)
            }
            
            // ───────── PDF 出力 ─────────
            Section(header: Text("エクスポート")) {
                Button {
                    do {
                        pdfURL = try viewModel.exportPDF(userName: userName)
                    } catch {
                        showAlert = true
                    }
                } label: {
                    Label("日記を PDF に出力", systemImage: "doc.richtext")
                }
            }
            
            // PDF が生成されたら共有シートを表示
            if let url = pdfURL {
                Section {
                    ShareLink(item: url, preview: SharePreview("Diary.pdf", image: Image(systemName: "doc.richtext")))
                }
            }
        }
        .navigationTitle("マイページ")
        .alert("PDF 生成に失敗しました", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
