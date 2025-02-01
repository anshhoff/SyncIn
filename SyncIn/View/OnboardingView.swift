//
//  OnboardingView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//
import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var isAnimating = false
    @State private var navigateToJoinCommunity = false
    @State private var navigateToLogin = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.yellow.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // App Logo and Title
                VStack {
                    Image(systemName: "link.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.yellow)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                    Text("SyncIN")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    Text("THE VIRTUAL TOUCH")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 5)
                }
                .padding(.top, 50)
                .onAppear {
                    self.isAnimating = true
                }

                Spacer()

                // Buttons
                VStack(spacing: 20) {
                    // Join the Community Button
                    NavigationLink(destination: JoinCommunityView()) {
                        HStack {
                            Text("Join the Community")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    }

                    // Already a Member? Log In Button
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Text("Already a Member? Log In")
                                .font(.headline)
                                .foregroundColor(.yellow)
                            Spacer()
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView(showOnboarding: .constant(true))
    }
}
