//
//  DiaryEntry.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import Foundation

struct DiaryEntry: Identifiable, Codable{
    var id = UUID()
    var title: String
    var content: String
    var date: Date
}
