//
//  JoinCommunityView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import SwiftUI
import FirebaseAuth

struct JoinCommunityView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isSignedUp: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.yellow.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // App Logo and Title
                    VStack {
                        Image(systemName: "person.badge.plus.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.yellow)

                        Text("Join the Community")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(.top, 50)

                    // Full Name Field
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)

                    // Email Field
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    // Password Field
                    ZStack(alignment: .trailing) {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)

                    Spacer()

                    // Sign Up Button
                    Button(action: {
                        signUpUser()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    .disabled(isLoading)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sign-Up Failed"),
                        message: Text(errorMessage ?? "Unknown error"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationDestination(isPresented: $isSignedUp) {
                CustomTabView(isLoggedOut: $isSignedUp)
            }
        }
    }

    // MARK: - Firebase Authentication
    func signUpUser() {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                isSignedUp = true
            }
        }
    }
}

#Preview {
    JoinCommunityView()
}
