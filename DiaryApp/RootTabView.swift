//
//  RootTabView.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/02.
//

import SwiftUI

struct RootTabView: View {
    @StateObject private var vm = DiaryViewModel()      // 全タブ共通の ViewModel
    
    var body: some View {
        TabView {
            // ───────── 1) ホーム ─────────
            NavigationStack {
                HomeContentView(viewModel: vm)           // ← 旧 HomeView のリスト部分
            }
            .tabItem {
                Image(systemName: "house")
                    .accessibilityLabel("Home")
            }
            
            // ───────── 2) カレンダー ─────────
            NavigationStack {
                CalendarView(
                    viewModel: vm,
                    selectedDate: .constant(Date())
                )
            }
            .tabItem {
                Image(systemName: "calendar")
                    .accessibilityLabel("Calendar")
            }
            
            // ───────── 3) 新規作成 ─────────
            NavigationStack {
                DiaryCreationView(viewModel: vm)
            }
            .tabItem {
                Image(systemName: "plus")
                    .accessibilityLabel("New Entry")
            }
            
            // ───────── 4) アカウント ─────────
            NavigationStack {
                AccountView()
                    .environmentObject(vm)
            }
            .tabItem {
                Image(systemName: "person")
                    .accessibilityLabel("Account")
            }
        }
    }
}

