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
        NavigationView {
            VStack(spacing: 0) {
                // ───────── 検索バー ─────────
                SearchBar(text: $searchText)
                
                // ───────── 日記リスト ─────────
                List {
                    ForEach(
                        viewModel.diaryEntries.filter { entry in
                            searchText.isEmpty ||
                            entry.title.contains(searchText) ||
                            entry.content.contains(searchText)
                        }
                    ) { entry in
                        NavigationLink {
                            DiaryDetailView(viewModel: viewModel, entry: entry)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(entry.title)
                                    .font(headlineFont)        // ← カスタムに差し替え
                                
                                Text(entry.content)
                                    .lineLimit(3)
                                    .font(bodyFont)            // ← カスタムに差し替え
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteEntry)
                }
                .listStyle(.plain)
            }
            .navigationTitle("日記リスト")
            
        }
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
        TextField("検索", text: $text)
            .padding(7)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding([.top, .horizontal])
    }
}
