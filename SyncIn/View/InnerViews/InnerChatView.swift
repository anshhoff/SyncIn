//
//  InnerChatView.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/31.
//
import SwiftUI
import Firebase

struct InnerChatView: View {
    let contact: Contact
    @State private var messageText = ""
    @State private var messages: [Message] = []
    
    var currentUserID: String {
        Auth.auth().currentUser?.uid ?? "unknown_user"
    }
    
    var chatID: String {
        // Ensuring a unique and consistent chat ID
        return currentUserID < contact.userId ? "\(currentUserID)_\(contact.userId)" : "\(contact.userId)_\(currentUserID)"
    }
    
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(contact.name)
                            .font(.headline)
                        Text("Active now")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "phone")
                    Image(systemName: "video")
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            // Messages List
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack {
                Button(action: {}) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                
                TextField("Message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            fetchMessages()
        }
    }
    
    // Function to send a message (Two-way communication)
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let db = Firestore.firestore()
        
        let newMessage = Message(id: UUID().uuidString, text: messageText, senderId: currentUserID, receiverId: contact.userId, timestamp: Timestamp())
        
        let messageData: [String: Any] = [
            "id": newMessage.id,
            "text": newMessage.text,
            "senderId": newMessage.senderId,
            "receiverId": newMessage.receiverId,
            "timestamp": newMessage.timestamp
        ]
        
        // Add message to Firestore under the chat ID
        db.collection("chats").document(chatID).collection("messages").addDocument(data: messageData)
        
        // Update latest message for both users in their chat list
        db.collection("users").document(currentUserID).collection("chats").document(contact.userId).setData([
            "lastMessage": messageText,
            "timestamp": Timestamp(),
            "chatID": chatID
        ])
        
        db.collection("users").document(contact.userId).collection("chats").document(currentUserID).setData([
            "lastMessage": messageText,
            "timestamp": Timestamp(),
            "chatID": chatID
        ])
        
        messageText = ""
    }
    
    // Function to fetch messages in real-time
    func fetchMessages() {
        let db = Firestore.firestore()
        
        db.collection("chats").document(chatID).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                messages = documents.compactMap { doc in
                    let data = doc.data()
                    return Message(
                        id: data["id"] as? String ?? UUID().uuidString,
                        text: data["text"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        receiverId: data["receiverId"] as? String ?? "",
                        timestamp: data["timestamp"] as? Timestamp ?? Timestamp()
                    )
                }
            }
    }
}

// Message Model
struct Message: Identifiable {
    let id: String
    let text: String
    let senderId: String
    let receiverId: String
    let timestamp: Timestamp
    
    var isCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
}

// Message Bubble View
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                Spacer()
            }
        }
    }
}

#Preview {
    InnerChatView(contact: Contact(userId: "sarahJi", name: "Sarah Miller", lastMessage: "So What should we do for dinner tonight?", time: "9:15 PM"))
}
