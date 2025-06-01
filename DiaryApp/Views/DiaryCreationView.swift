//
//  DiaryCreationView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import SwiftUI

struct DiaryCreationView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var errorMessage: String? = nil  // エラーメッセージを保持する変数
    @State private var showAlert: Bool = false  // アラート表示フラグ
    
    var body: some View {
        VStack {
            TextField("今日の日記", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    title = formattedDate()  // 初期タイトルに日付を設定
                }
            
            TextEditor(text: $content)
                .padding()
                .border(Color.gray, width: 1)
            
            // エラーメッセージの表示
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            Button(action: saveEntry) {
                Text("保存")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)  // ボタンの背景色を変更
                    .foregroundColor(.white)  // 文字色を白に設定
                    .cornerRadius(12)  // 丸みを持たせる
                    .shadow(radius: 6)  // 影をつけて浮き上がる効果を持たせる
            }
            .padding(.horizontal, 50)  // 横の余白を広めに設定
            .padding()
            .alert(isPresented: $showAlert) {  // アラートの表示
                Alert(
                    title: Text("完了"),
                    message: Text("日記が保存されました！"),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Spacer()
        }
        .navigationBarTitle("日記を書こう", displayMode: .inline)
    }
    
    private func saveEntry() {
        // 空文字や空白文字だけのチェック
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty || trimmedContent.isEmpty {
            // エラーメッセージを設定
            errorMessage = "タイトルとコンテンツは必須です。"
            return
        }
        // エラーメッセージが表示されていれば非表示にする
        errorMessage = nil
        
        viewModel.addDiaryEntry(title: trimmedTitle, content: trimmedContent)
        title = ""
        content = ""
        
        // 保存完了のアラートを表示
        showAlert = true
    }
    
    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: Date())
    }
}

