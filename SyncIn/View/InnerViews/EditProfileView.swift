//
//  EditProfileView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//
import SwiftUI
import Firebase

struct EditProfileView: View {
    @Binding var isEditingProfile: Bool
    @State private var name: String = "John Doe"
    @State private var email: String = "johndoe@example.com"
    @State private var bio: String = "iOS Developer | Coffee Lover ☕ | Swift Enthusiast"
    @State private var hobbies: String = "Coding, Reading, Traveling" // Added hobbies field
    @State private var isKeyboardVisible = false // Track keyboard visibility

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Edit Profile")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 20)
                .foregroundColor(.primary)

            // Profile Picture
            Button(action: {
                // Add image picker action
            }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }

            // Form Fields
            VStack(spacing: 16) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Hobbies", text: $hobbies) // Added hobbies field
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            Spacer()

            // Save Changes Button (moves up when keyboard is visible)
            Button(action: saveProfile) {
                Text("Save Changes")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, isKeyboardVisible ? 20 : 40) // Move up when keyboard appears
            
            Button(action: {
                isEditingProfile = false
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            observeKeyboard()
        }
    }

    // Function to save profile data to Firebase
    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        let profileData: [String: Any] = [
            "name": name,
            "email": email,
            "bio": bio,
            "hobbies": hobbies
        ]

        userRef.setData(profileData, merge: true) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully")
                isEditingProfile = false
            }
        }
    }

    // Observe keyboard visibility to move UI up
    func observeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isKeyboardVisible = true
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                isKeyboardVisible = false
            }
        }
    }
}

#Preview {
    EditProfileView(isEditingProfile: .constant(true))
}

