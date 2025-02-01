//
//  SyncInApp.swift
//  SyncIn
//
//  Created by Ansh Hardaha on 2025/02/01.
//

import SwiftUI
import Firebase

@main
struct SyncInApp: App {
    
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
