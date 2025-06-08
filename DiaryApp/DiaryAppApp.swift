//
//  DiaryAppApp.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/04/28.
//

import SwiftUI

@main
struct DiaryApp: App {
    init() {
        // List を透明化 ── これは 1 度だけでよい
        let clear = UIColor.clear
        UITableView.appearance().backgroundColor     = clear
        UITableView.appearance().isOpaque            = false
        UITableViewCell.appearance().backgroundColor = clear
        let bg = UIView(); bg.backgroundColor = .clear
        UITableViewCell.appearance().selectedBackgroundView = bg
    }

    var body: some Scene {
        WindowGroup { RootTabView() }
    }
}
