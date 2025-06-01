//
//  DiaryViewModel.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import Foundation
import SwiftUI
import PDFKit
import UIKit     // 画像描画用


// MARK: - ViewModel
final class DiaryViewModel: ObservableObject {
    @Published var diaryEntries: [DiaryEntry] = []
    
    // -------- 保存ファイル --------
    private let fileName = "diaryEntries.json"
    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory,
                                 in: .userDomainMask).first?
        .appendingPathComponent(fileName)
    }
    
    // -------- 初期化 --------
    init() { loadDiaryEntries() }
    
    // MARK: - CRUD
    func addDiaryEntry(title: String, content: String) {
        diaryEntries.append(
            DiaryEntry(title: title, content: content, date: Date())
        )
        saveDiaryEntries()
    }
    
    func deleteDiaryEntry(at offsets: IndexSet) {
        diaryEntries.remove(atOffsets: offsets)
        saveDiaryEntries()
    }
    
    /// 編集済みエントリを上書き保存
    func saveDiaryEntry(_ entry: DiaryEntry) {
        if let idx = diaryEntries.firstIndex(where: { $0.id == entry.id }) {
            diaryEntries[idx] = entry
            saveDiaryEntries()
        }
    }
    
    // MARK: - Persistence
    private func saveDiaryEntries() {
        guard let url = fileURL else { return }
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        if let data = try? enc.encode(diaryEntries) {
            try? data.write(to: url)
        }
    }
    
    private func loadDiaryEntries() {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        diaryEntries = (try? dec.decode([DiaryEntry].self, from: data)) ?? []
    }
    
    // MARK: - PDF Export
    /// 全日記を 1 本の PDF に出力し一時ディレクトリへ書き出し
    func exportPDF(userName: String) throws -> URL {
        let pdf = PDFDocument()
        
        for (idx, entry) in diaryEntries.enumerated() {
            if let page = PDFPage(image: makePageImage(for: entry, userName: userName)) {
                pdf.insert(page, at: idx)
            }
        }
        
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Diary_\(UUID().uuidString.prefix(8)).pdf")
        guard pdf.write(to: url) else {
            throw NSError(domain: "DiaryApp",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "PDF 書き込みに失敗"])
        }
        return url
    }
    
    // A4 (72 dpi) に簡易レイアウト
    private func makePageImage(for entry: DiaryEntry,
                               userName: String) -> UIImage {
        let size = CGSize(width: 595, height: 842)            // A4 72dpi
        let r = UIGraphicsImageRenderer(size: size)
        return r.image { _ in
            // 共通属性
            let bodyAttr: [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 14)
            ]
            
            // タイトル
            entry.title.draw(at: CGPoint(x: 32, y: 32),
                             withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
            
            // 日付
            let df = DateFormatter(); df.dateStyle = .medium
            df.string(from: entry.date)
              .draw(at: CGPoint(x: 32, y: 70), withAttributes: bodyAttr)
            
            // 本文
            let rect = CGRect(x: 32, y: 100,
                              width: size.width - 64,
                              height: size.height - 160)
            entry.content.draw(in: rect, withAttributes: bodyAttr)
            
            // フッター (ユーザー名)
            let footer = "Written by \(userName)"
            let footerSize = footer.size(withAttributes: bodyAttr)
            footer.draw(at: CGPoint(x: size.width - 32 - footerSize.width,
                                    y: size.height - 32 - footerSize.height),
                        withAttributes: bodyAttr)
        }
    }
}
