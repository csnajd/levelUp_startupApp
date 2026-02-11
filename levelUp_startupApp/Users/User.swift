//
//  User.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//

import Foundation
import CloudKit
import UIKit

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer not to say"
    
    var displayName: String {
        return self.rawValue
    }
}

struct User: Identifiable {
    var id: String
    var givenName: String
    var familyName: String
    var gender: Gender
    var email: String
    var phoneNumber: String
    var profilePhotoAsset: CKAsset?
    var appleUserID: String
    var createdAt: Date
    var updatedAt: Date
    
    var profileImage: UIImage?
    
    var fullName: String {
        return "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
    }
    
    // ✅ FIXED - Added phoneNumber parameter
    init(givenName: String = "", familyName: String = "", gender: Gender = .preferNotToSay, email: String = "", phoneNumber: String = "", appleUserID: String = "") {
        self.id = UUID().uuidString
        self.givenName = givenName
        self.familyName = familyName
        self.gender = gender
        self.email = email
        self.phoneNumber = phoneNumber  // ✅ Initialize phoneNumber
        self.appleUserID = appleUserID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // ✅ FIXED - Added phoneNumber from CloudKit record
    init(from record: CKRecord) throws {
        self.id = record.recordID.recordName
        self.givenName = record["givenName"] as? String ?? ""
        self.familyName = record["familyName"] as? String ?? ""
        
        let genderString = record["gender"] as? String ?? "Prefer not to say"
        self.gender = Gender(rawValue: genderString) ?? .preferNotToSay
        
        self.email = record["email"] as? String ?? ""
        self.phoneNumber = record["phoneNumber"] as? String ?? ""  // ✅ Initialize phoneNumber
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
        let record = CKRecord(recordType: "UserProfile")
        record["givenName"] = givenName
        record["familyName"] = familyName
        record["gender"] = gender.rawValue
        record["email"] = email
        record["phoneNumber"] = phoneNumber  // ✅ Save phoneNumber
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
