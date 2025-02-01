//
//  UserDetailedCard.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import SwiftUI

struct UserDetailedCard: View {
    let user: User
    @State private var isAnimating = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 16) {
            // Close Button
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
            }
            .padding()
            .accessibility(label: Text("Close"))

            // Profile Image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .yellow]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)

                if user.photo.isEmpty {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                } else {
                    Image(user.photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
            }

            // User Info
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title2).bold()

                Text("\(user.distance.formatted()) m away")
                    .foregroundColor(.secondary)
            }

            // User Details
            DetailSection(title: "Bio", content: user.bio)
            DetailSection(title: "Hobbies", content: user.hobbies)
            DetailSection(title: "Likes", content: user.likes)
            DetailSection(title: "Dislikes", content: user.dislikes)

            Spacer()
        }
        .padding()
        .background(BackgroundGradient())
        .onAppear { isAnimating = true }
        .onAppear(perform: triggerHaptic)
    }

    private func dismiss() {
        withAnimation { presentationMode.wrappedValue.dismiss() }
    }

    private func triggerHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Subviews
private struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

private struct BackgroundGradient: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview
#Preview {
    UserDetailedCard(user: User(
        name: "Maya Patel",
        bio: "Student at University of Tokyo\nLove to explore new cultures",
        hobbies: "Cooking international cuisine, reading mystery novels",
        likes: "Spicy food, jazz music, hiking",
        dislikes: "Cold weather, crowded places",
        photo: "person.crop.circle.fill",
        distance: 150
    ))
}
