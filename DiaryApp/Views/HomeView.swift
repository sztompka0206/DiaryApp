//
//  HomeContentView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import SwiftUI

struct HomeContentView: View {
    // 画面全体で共有する ViewModel
    @ObservedObject var viewModel: DiaryViewModel
    // 選択フォントに応じて動的に Font を返すために参照
    @EnvironmentObject private var fontSettings: FontSettings
    
    // --- UI State ---
    @State private var searchText: String = ""
    @State private var selectedDate: Date = Date()      // カレンダーとのバインディング
    
    // ------------------------------------
    // MARK: - Body
    // ------------------------------------
    var body: some View {
        VStack(spacing: 0) {
            // ───────── 検索バー ─────────
            SearchBar(text: $searchText)
                .padding(.bottom, 12)
                
            // ───────── 日記リスト ─────────
            List {
                ForEach(
                    viewModel.diaryEntries.filter { entry in
                        let keyword = searchText.lowercased()
                        return keyword.isEmpty ||
                        entry.title.lowercased().contains(keyword) ||
                        entry.content.lowercased().contains(keyword)
                    }
                ) { entry in
                    NavigationLink {
                        DiaryDetailView(viewModel: viewModel, entry: entry)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(entry.title)
                                .font(headlineFont)        // ← カスタムに差し替え
                                .bold()
                                .padding(.bottom, 1)
                                
                            Text(entry.content)
                                .lineLimit(3)
                                .font(bodyFont)            // ← カスタムに差し替え
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete(perform: deleteEntry)
            }
            .listStyle(.plain)
        }
        .navigationTitle("日記リスト")
    }
    
    // ------------------------------------
    // MARK: - Delete Helper
    // ------------------------------------
    private func deleteEntry(at offsets: IndexSet) {
        viewModel.deleteDiaryEntry(at: offsets)
    }
    
    // ------------------------------------
    // MARK: - Font Helpers
    // ------------------------------------
    /// `headline` サイズ相当でファミリーだけ置換
    private var headlineFont: Font {
        fontSettings.selectedFontName.isEmpty
        ? .headline
        : .custom(
            fontSettings.selectedFontName,
            size: UIFont.preferredFont(forTextStyle: .headline).pointSize,
            relativeTo: .headline
          )
    }
    
    /// `body` サイズ相当でファミリーだけ置換
    private var bodyFont: Font {
        fontSettings.selectedFontName.isEmpty
        ? .body
        : .custom(
            fontSettings.selectedFontName,
            size: UIFont.preferredFont(forTextStyle: .body).pointSize,
            relativeTo: .body
          )
    }
}

// ------------------------------------
// MARK: - SearchBar
// ------------------------------------
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("", text: $text)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
        .padding(8)                                   // 内側余白
        .background(Color.gray.opacity(0.12))         // 背景色
        .cornerRadius(12)                             // 角丸
        .padding([.top,.horizontal])
    }
}
