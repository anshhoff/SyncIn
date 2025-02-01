///
//  HomeView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//
import SwiftUI
import SwiftUICore
import FirebaseFirestore
import SwiftUI

struct HomeView: View {
    // Sample users sorted by distance (closest first)
    let users: [User] = [
        User(name: "Maya Patel", bio: "Student", hobbies: "Cooking, Reading", likes: "Spicy Food, Mystery Novels", dislikes: "Cold Weather", photo: "https://example.com/photo1.jpg", distance: 150),
        User(name: "Sarah Miller", bio: "Software Developer", hobbies: "Photography, Traveling", likes: "Sunsets, Beaches", dislikes: "Crowded Places", photo: "https://example.com/photo2.jpg", distance: 200),
        User(name: "Alex Chen", bio: "Digital Artist", hobbies: "Sketching, Gaming", likes: "Sci-fi Movies, Pizza", dislikes: "Early Mornings", photo: "https://example.com/photo3.jpg", distance: 500)
    ].sorted { $0.distance < $1.distance } // Sort by distance

    @State private var selectedUser: User?
    @State private var isSheetPresented = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(users) { user in
                        Button {
                            selectedUser = user
                            isSheetPresented = true
                        } label: {
                            ProfileCard(user: user)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                //.padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemTeal).opacity(0.1), Color(.systemYellow).opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("People Near You")
            .sheet(item: $selectedUser) { user in
                UserDetailedCard(user: user)
            }
        }
    }
}

// Profile Card Component
struct ProfileCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Picture with Gradient Overlay
            ZStack {
                AsyncImage(url: URL(string: user.photo)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray
                            .overlay(ProgressView())
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .yellow]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }

            // User Info
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("\(user.distance) m away")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Text(user.bio)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
        .padding()
    }
}



#Preview {
    HomeView()
}
