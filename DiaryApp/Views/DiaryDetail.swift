//
//  DiaryDetail.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

struct DiaryDetailView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @State var entry: DiaryEntry
    @State private var isEditing: Bool = false  // 編集モードのフラグ
    
    var body: some View {
        VStack {
            // タイトルを表示、編集モードでは変更可能
            TextField("タイトル", text: $entry.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .disabled(!isEditing)  // 編集モードでない場合は変更不可
            
            // コンテンツを表示、編集モードではTextEditorで変更可能
            if isEditing {
                TextEditor(text: $entry.content)
                    .padding()
                    .border(Color.gray, width: 1)
            } else {
                ScrollView {
                    Text(entry.content)
                        .font(.body)
                        .padding()
                }
            }
            
            // 保存ボタン
            if isEditing {
                Button(action: toggleEdit) {
                    Text("保存")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                }
                .padding(.horizontal, 50)
                .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle("日記詳細", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: toggleEdit) {
            Text(isEditing ? "キャンセル" : "編集")
                .font(.body)
                .foregroundColor(.blue)
        })
    }
    
    // 編集モードの切り替え
    private func toggleEdit() {
        if isEditing {
            // 編集が完了したら保存する
            viewModel.saveDiaryEntry(entry)  // ここで保存処理を行う
        }
        isEditing.toggle()
    }
}
