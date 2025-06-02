//
//  CalendarView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI
import UIKit

// ────────────────────────────────────────────
// MARK: - Font.TextStyle ↔︎ UIFont.TextStyle
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
// MARK: - CalendarView
// ────────────────────────────────────────────
struct CalendarView: View {
    // 依存関係
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var selectedDate: Date
    @EnvironmentObject private var fontSettings: FontSettings   // フォント設定共有
    
    // 日付処理
    private let cal = Calendar.current
    private let headerFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy/MM"; return f
    }()
    
    // 状態
    @State private var currentMonth: Date = Calendar.current.date(
        from: Calendar.current.dateComponents([.year, .month], from: Date())
    )!
    @State private var diaryDates: Set<Date> = []          // 日記が存在する日セット
    @State private var dailyEntries: [DiaryEntry] = []     // 選択日の一覧
    @State private var sheetEntry: DiaryEntry?             // 行タップでモーダル
    
    // レイアウト定数
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    private let listHeight: CGFloat = 220                  // 一覧用固定高さ
    
    // ─────────────────────────────
    // MARK: - Body
    // ─────────────────────────────
    var body: some View {
        VStack(spacing: 16) {
            // ───── 月ヘッダー ─────
            monthHeader
            
            // ───── カレンダー ─────
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    dayCell(for: date)
                }
            }
            .padding(.horizontal)
            .onAppear {
                diaryDates = Set(viewModel.diaryEntries
                                   .map { cal.startOfDay(for: $0.date) })
                updateDailyEntries(for: selectedDate)
            }
            
            // ───── 当日の日記一覧 ─────
            Group {
                if dailyEntries.isEmpty {
                    placeholder
                } else {
                    entryList
                }
            }
            .frame(height: listHeight)                     // ★ 固定高さ
            .animation(.default, value: dailyEntries.count)
        }
        .padding(.bottom, 8)
        .navigationTitle("カレンダー")
        .sheet(item: $sheetEntry) { entry in              // モーダル全文表示
            DiaryDetailView(viewModel: viewModel, entry: entry)
                .environmentObject(fontSettings)
                .presentationDetents([.fraction(0.40), .large])
        }
    }
    
    // ─────────────────────────────
    // MARK: - Header
    // ─────────────────────────────
    private var monthHeader: some View {
        HStack {
            Button { moveMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Text(headerFmt.string(from: currentMonth))
                .font(customFont(.headline))
                .frame(maxWidth: .infinity)
            Button { moveMonth(by:  1) } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    // ─────────────────────────────
    // MARK: - Day Cell
    // ─────────────────────────────
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let day   = cal.component(.day, from: date)
        let start = cal.startOfDay(for: date)
        
        let bg: Color =
            cal.isDateInToday(date) ? Color.orange.opacity(0.3) :
            (diaryDates.contains(start) ? Color.blue.opacity(0.3) : .clear)
        
        Text("\(day)")
            .font(customFont(.body))
            .frame(maxWidth: .infinity, minHeight: 32)
            .background(bg)
            .clipShape(Circle())
            .onTapGesture {
                selectedDate = date
                updateDailyEntries(for: date)
            }
    }
    
    // ─────────────────────────────
    // MARK: - Entry List & Placeholder
    // ─────────────────────────────
    private var entryList: some View {
        List {
            ForEach(dailyEntries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(customFont(.headline).bold())
                        .padding(.bottom, 1)
                    Text(entry.content)
                        .font(customFont(.body))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                .padding(.vertical, 6)
                .onTapGesture { sheetEntry = entry }   // 行タップでモーダル
            }
        }
        .listStyle(.plain)
        .clipped()
    }
    
    private var placeholder: some View {
        HStack {
            Text("この日には日記がありません")
                .font(customFont(.footnote))
                .foregroundColor(.secondary)
                .padding(.vertical, 4)
            Spacer()
        }
        .padding(.horizontal, 12)  // ← 左右インセット
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .topLeading)
    }
    
    // ─────────────────────────────
    // MARK: - Helpers
    // ─────────────────────────────
    /// FontSettings に合わせた Font 生成
    private func customFont(_ style: Font.TextStyle) -> Font {
        let ps = fontSettings.selectedFontName
        guard !ps.isEmpty else { return .system(style) }
        let size = UIFont.preferredFont(forTextStyle: style.uiKit).pointSize
        return .custom(ps, size: size, relativeTo: style)
    }
    
    /// 選択日の一覧を更新
    private func updateDailyEntries(for date: Date) {
        dailyEntries = viewModel.diaryEntries
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    /// 表示月の日付配列
    private func daysInMonth() -> [Date] {
        guard let r = cal.range(of: .day, in: .month, for: currentMonth) else { return [] }
        return r.compactMap { cal.date(bySetting: .day, value: $0, of: currentMonth) }
    }
    
    /// 月送り
    private func moveMonth(by value: Int) {
        if let new = cal.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = new
            updateDailyEntries(for: new)
        }
    }
}
