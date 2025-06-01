//
//  DiaryAppApp.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/04/28.
//

import SwiftUI

@main
struct DiaryApp: App {
    @StateObject private var viewModel = DiaryViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootTabView() // タブビューを使う場合はこちらを有効にする
        }
    }
}
