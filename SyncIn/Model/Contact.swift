//
//  Contact.swift
//  SyncIn
//
//  Created by Ansh Hardaha on 2025/02/01.
//

import SwiftUI
import Firebase

struct Contact: Identifiable {
    let id = UUID()
    let userId: String
    var name: String
    let lastMessage: String
    let time: String
}

extension Contact {
    // Fetch contact details from Firebase
    static func fetchContacts(forUser userID: String, completion: @escaping ([Contact]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userID).collection("chats")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                // Fetch contacts from the documents retrieved
                var contacts: [Contact] = []
                
                for document in documents {
                    let data = document.data()
                    if let userId = document.documentID as? String,
                       let lastMessage = data["lastMessage"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp {
                        
                        let formattedTime = formatTimestamp(timestamp)
                        
                        let contact = Contact(userId: userId, name: "Loading...", lastMessage: lastMessage, time: formattedTime)
                        contacts.append(contact)
                    }
                }
                
                // Fetch user names for the contacts
                fetchUserNames(forContacts: contacts, completion: completion)
            }
    }
    
    // Fetch the user name for all contacts
    static func fetchUserNames(forContacts contacts: [Contact], completion: @escaping ([Contact]) -> Void) {
        let db = Firestore.firestore()
        
        var updatedContacts = contacts
        var contactsProcessed = 0
        
        for index in contacts.indices {
            let userId = contacts[index].userId
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user name: \(error.localizedDescription)")
                    return
                }
                
                if let data = document?.data(), let name = data["name"] as? String {
                    updatedContacts[index].name = name
                }
                
                contactsProcessed += 1
                if contactsProcessed == contacts.count {
                    completion(updatedContacts)
                }
            }
        }
    }
    
    // Format the Firebase timestamp to a readable time
    static func formatTimestamp(_ timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
