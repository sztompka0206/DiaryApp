//
//  CalendarView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Binding var selectedDate: Date
    
    private let cal = Calendar.current
    private let headerFmt: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy/MM"; return f
    }()
    
    // 状態
    @State private var currentMonth: Date = Calendar.current.date(
        from: Calendar.current.dateComponents([.year, .month], from: Date())
    )!
    @State private var diaryDates: Set<Date> = []
    @State private var bottomEntry: DiaryEntry?            // ← ボトムシート用
    
    // ------------------------------------
    // MARK: - Body
    // ------------------------------------
    var body: some View {
        VStack {
            monthHeader
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    dayCell(date)
                }
            }
            .padding(.horizontal)
            .onAppear {
                diaryDates = Set(viewModel.diaryEntries
                                    .map { cal.startOfDay(for: $0.date) })
            }
        }
        .navigationTitle("カレンダー")
        // ---- ボトムシート ----
        .sheet(item: $bottomEntry) { entry in
            DiaryDetailView(viewModel: viewModel, entry: entry)
                .presentationDetents([.fraction(0.40), .large])  // 下 40% → スワイプで全画面
        }
    }
    
    // ------------------------------------
    // MARK: - Header
    // ------------------------------------
    private var monthHeader: some View {
        HStack {
            Button { moveMonth(by: -1) } label: { Image(systemName: "chevron.left") }
            Text(headerFmt.string(from: currentMonth))
                .font(.headline).frame(maxWidth: .infinity)
            Button { moveMonth(by:  1) } label: { Image(systemName: "chevron.right") }
        }
        .padding(.horizontal)
    }
    
    // ------------------------------------
    // MARK: - Day Cell
    // ------------------------------------
    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let day = cal.component(.day, from: date)
        let start = cal.startOfDay(for: date)
        
        let bg: Color = cal.isDateInToday(date) ?
                        Color.orange.opacity(0.3) :
                        (diaryDates.contains(start) ? Color.blue.opacity(0.3) : .clear)
        
        Text("\(day)")
            .frame(maxWidth: .infinity, minHeight: 32)
            .background(bg).clipShape(Circle())
            .onTapGesture {
                selectedDate = date
                // 該当日の日記があればボトムシート表示
                if let hit = viewModel.diaryEntries.first(where: {
                    cal.isDate($0.date, inSameDayAs: date)
                }) {
                    bottomEntry = hit       // <- sheet をトリガ
                }
            }
    }
    
    // ------------------------------------
    // MARK: - Helpers
    // ------------------------------------
    private func daysInMonth() -> [Date] {
        guard let r = cal.range(of: .day, in: .month, for: currentMonth) else { return [] }
        return r.compactMap { cal.date(bySetting: .day, value: $0, of: currentMonth) }
    }
    
    private func moveMonth(by v: Int) {
        if let new = cal.date(byAdding: .month, value: v, to: currentMonth) {
            currentMonth = new
        }
    }
}
