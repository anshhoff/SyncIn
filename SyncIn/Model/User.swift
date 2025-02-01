//
//  User.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/27.
//

import Foundation

struct User: Identifiable {
    let id = UUID()
    let name: String
    let bio: String
    let hobbies: String
    let likes: String
    let dislikes: String
    let photo: String
    let distance: Int
}

