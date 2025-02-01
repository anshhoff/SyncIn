//
//  SettingsView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//
import SwiftUI
import Firebase

struct SettingsView: View {
    @Binding var isEditingProfile: Bool
    @Binding var isLoggedOut: Bool
    
    // State variables to hold fetched user data
    @State private var userName: String = "Loading..."
    @State private var userID: String = "Fetching ID..."
    @State private var userDetails: String = "Fetching details..."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // User Profile Section
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 16)
                    
                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(userID)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(userDetails)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                
                // Settings Options
                List {
                    Section {
                        NavigationLink(destination: EditProfileView(isEditingProfile: $isEditingProfile)) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Edit Profile").foregroundColor(.blue)
                            }
                        }
                        
                        Button(action: {
                            // Add account-related logic
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.green)
                                Text("Account Settings")
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            // Add privacy-related logic
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.orange)
                                Text("Privacy Settings")
                            }
                        }
                        
                        Button(action: {
                            // Add help-related logic
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.purple)
                                Text("Help & Support")
                            }
                        }
                    }
                    
                    Section {
                        Button(action: {
                            logOut()
                        }) {
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                    .foregroundColor(.red)
                                Text("Log Out")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchUserData()
            }
        }
    }
    
    // Function to fetch user data from Firestore
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("User document not found")
                return
            }
            
            let data = document.data()
            self.userName = data?["name"] as? String ?? "No Name"
            self.userID = userId
            self.userDetails = data?["bio"] as? String ?? "No Bio Available"
        }
    }
    
    // Function to log out the user
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView(isEditingProfile: .constant(false), isLoggedOut: .constant(false))
}
