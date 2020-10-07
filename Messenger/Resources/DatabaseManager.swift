//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Jamie French on 07/10/2020.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared  = DatabaseManager()
    
    private let database = Database.database().reference()
    
  
    }

// MARK: - account Mgmt

extension DatabaseManager{
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    ///insers new user to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
    }
    
struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
   // let profilePictureUrl: string
}


