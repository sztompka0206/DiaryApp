//
//  Login.swift
//  DiaryApp
//
//  Created by Masahiko Nakata on 2025/06/01.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // アプリ名
                Text("App name")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // アカウント作成フォーム
                Text("Create an account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                
                TextField("email@domain.com", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                
                Button(action: {
                    // ここにログイン処理を追加
                    isLoggedIn = true
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(8)
                        .padding(.top, 20)
                }
                .padding(.horizontal, 30)
                
                // "or"セパレータ
                Text("or")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                
                // サインイン方法
                Button(action: {
                    // Googleでサインイン処理を追加
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(.red)
                        Text("Continue with Google")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                Button(action: {
                    // Appleでサインイン処理を追加
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .foregroundColor(.black)
                        Text("Continue with Apple")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // 利用規約とプライバシーポリシー
                Spacer()
                HStack {
                    Text("By clicking continue, you agree to our")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Button(action: {
                        // 利用規約のページに遷移
                    }) {
                        Text("Terms of Service")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    Text("and")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Button(action: {
                        // プライバシーポリシーのページに遷移
                    }) {
                        Text("Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 30)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .onChange(of: isLoggedIn) { newValue in
                if newValue {
                    // ログイン後の遷移処理をここに追加
                    // 例えば、別の画面に遷移
                }
            }
        }
    }
}
