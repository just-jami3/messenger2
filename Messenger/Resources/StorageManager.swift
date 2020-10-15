//
//  StirageManager.swift
//  Messenger
//
//  Created by Jamie French on 09/10/2020.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/jamiefrench2003-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// uploads pic to firebase storage and returns completion with download url
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //failed
                print("failed to upload data to firebase for pic")
                completion(.failure(storageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("failed to get download url")
                    completion(.failure(storageErrors.failedToGetDowloadUrl))
                    return
                    
                }
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum storageErrors: Error {
        case failedToUpload
        case failedToGetDowloadUrl
    }
    //returns download url
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(storageErrors.failedToGetDowloadUrl))
                return
            }
            completion(.success(url))
            
        })
    }
    
}
