//
//  ChatView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
import SwiftUI
import Firebase

struct ChatView: View {
    @State private var contacts: [Contact] = []
    @State private var currentUserID: String = ""

    var body: some View {
        NavigationView {
            List(contacts) { contact in
                NavigationLink(destination: InnerChatView(contact: contact)) {
                    ChatRow(contact: contact)
                }
            }
            .navigationTitle("Chats")
            .onAppear {
                fetchCurrentUser()
            }
        }
    }

    func fetchCurrentUser() {
        if let user = Auth.auth().currentUser {
            currentUserID = user.uid
            fetchChats(forUserID: currentUserID)
        }
    }

    func fetchChats(forUserID userID: String) {
        let db = Firestore.firestore()
        db.collection("chats")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching chats: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                var fetchedContacts: [Contact] = []

                for document in documents {
                    let chatID = document.documentID
                    let chatData = document.data()

                    // Extract other user ID from the chat document ID
                    let userIDs = chatID.split(separator: "_").map { String($0) }
                    guard userIDs.count == 2 else { continue }
                    
                    let otherUserID = userIDs[0] == userID ? userIDs[1] : userIDs[0]
                    if otherUserID == userID { continue }

                    if let lastMessage = chatData["lastMessage"] as? String,
                       let timestamp = chatData["timestamp"] as? Timestamp {
                        
                        let formattedTime = formatTimestamp(timestamp)

                        let contact = Contact(userId: otherUserID, name: "Loading...", lastMessage: lastMessage, time: formattedTime)
                        fetchedContacts.append(contact)
                    }
                }

                // Fetch names of other users
                fetchUserNames(forContacts: fetchedContacts) { updatedContacts in
                    self.contacts = updatedContacts
                }
            }
    }

    func fetchUserNames(forContacts contacts: [Contact], completion: @escaping ([Contact]) -> Void) {
        let db = Firestore.firestore()
        var updatedContacts = contacts
        var completedRequests = 0

        for index in contacts.indices {
            let userId = contacts[index].userId
            db.collection("users").document(userId).getDocument { document, error in
                if let data = document?.data(), let name = data["name"] as? String {
                    updatedContacts[index].name = name
                }
                completedRequests += 1
                if completedRequests == contacts.count {
                    completion(updatedContacts)
                }
            }
        }
    }

    func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct ChatRow: View {
    let contact: Contact

    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(contact.name)
                    .font(.headline)
                Text(contact.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(contact.time)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ChatView()
}

