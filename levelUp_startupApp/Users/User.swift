//
//  User.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import Foundation
import CloudKit
import UIKit

struct User: Identifiable {
    var id: String
    var givenName: String      // Changed from firstName
    var familyName: String     // Changed from lastName
    var gender: String
    var email: String
    var profilePhotoAsset: CKAsset?
    var appleUserID: String
    var createdAt: Date
    var updatedAt: Date
    
    var profileImage: UIImage?
    
    init(givenName: String = "", familyName: String = "", gender: String = "", email: String = "", appleUserID: String = "") {
        self.id = UUID().uuidString
        self.givenName = givenName
        self.familyName = familyName
        self.gender = gender
        self.email = email
        self.appleUserID = appleUserID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init(from record: CKRecord) throws {
        self.id = record.recordID.recordName
        self.givenName = record["givenName"] as? String ?? ""
        self.familyName = record["familyName"] as? String ?? ""
        self.gender = record["gender"] as? String ?? ""
        self.email = record["email"] as? String ?? ""
        self.profilePhotoAsset = record["profilePhoto"] as? CKAsset
        self.appleUserID = record["appleUserID"] as? String ?? ""
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.updatedAt = record["updatedAt"] as? Date ?? Date()
        
        if let asset = profilePhotoAsset,
           let imageData = try? Data(contentsOf: asset.fileURL!),
           let image = UIImage(data: imageData) {
            self.profileImage = image
        }
    }
    
    func toCKRecord() throws -> CKRecord {
        let record = CKRecord(recordType: "UserProfile")  // Changed to match your CloudKit
        record["givenName"] = givenName
        record["familyName"] = familyName
        record["gender"] = gender
        record["email"] = email
        record["appleUserID"] = appleUserID
        record["createdAt"] = createdAt
        record["updatedAt"] = Date()
        
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try imageData.write(to: tempURL)
            record["profilePhoto"] = CKAsset(fileURL: tempURL)
        }
        
        return record
    }
}