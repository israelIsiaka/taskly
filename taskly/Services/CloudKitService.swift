//
//  CloudKitService.swift
//  taskly
//
//  CloudKit sync service for monitoring and managing CloudKit operations
//

import Foundation
import SwiftData
import CloudKit
import Combine

/// Service for monitoring CloudKit sync status
@MainActor
class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    @Published var userName: String?
    @Published var userProfileImage: Data?
    
    private init() {}
    
    /// Check CloudKit account status
    func checkAccountStatus() async -> CKAccountStatus {
        let container = CKContainer(identifier: "iCloud.com.nickels.taskly")
        do {
            return try await container.accountStatus()
        } catch {
            print("Error checking CloudKit account status: \(error)")
            return .couldNotDetermine
        }
    }
    
    /// Get CloudKit container
    var container: CKContainer {
        CKContainer(identifier: "iCloud.com.nickels.taskly")
    }
    
    /// Verify CloudKit is available
    func verifyCloudKitAvailable() async -> Bool {
        let status = await checkAccountStatus()
        return status == .available
    }
    
    /// Fetch the current iCloud user's information directly from CloudKit
    func fetchUserInfo() async {
        do {
            // Get the user's CloudKit record ID
            let userRecordID = try await container.userRecordID()
            print("✅ Got user record ID: \(userRecordID.recordName)")
            
            // Fetch user identity for name information
            let userIdentity = try await container.userIdentity(forUserRecordID: userRecordID)
            print("✅ Got user identity")
            
            // Debug: Log what's in userIdentity
            if let identity = userIdentity {
                print("📋 UserIdentity details:")
                print("   - nameComponents: \(identity.nameComponents?.debugDescription ?? "nil")")
                print("   - lookupInfo: \(identity.lookupInfo?.debugDescription ?? "nil")")
                if let lookupInfo = identity.lookupInfo {
                    print("   - emailAddress: \(lookupInfo.emailAddress ?? "nil")")
                    print("   - phoneNumber: \(lookupInfo.phoneNumber ?? "nil")")
                    print("   - userRecordName: \(lookupInfo.className ?? "nil")")
                }
            } else {
                print("⚠️ userIdentity is nil")
            }
            
            // Extract name from user identity
            if let nameComponents = userIdentity?.nameComponents {
                let formatter = PersonNameComponentsFormatter()
                formatter.style = .long
                userName = formatter.string(from: nameComponents)
                print("✅ Set userName from nameComponents: \(userName ?? "nil")")
            } else if let email = userIdentity?.lookupInfo?.emailAddress {
                // Use email as fallback (extract name part before @)
                let emailName = email.components(separatedBy: "@").first ?? email
                userName = emailName.capitalized
                print("✅ Set userName from email (extracted): \(userName ?? "nil")")
            } else {
                // Try to get name from user record
                print("🔍 Trying to fetch name from user record...")
                await fetchNameFromUserRecord(userRecordID: userRecordID)
            }
            
            // Try to fetch profile picture from user record
            await fetchUserProfileImage(userRecordID: userRecordID)
            
            // If we still don't have a name, try system username as last resort
            if userName == nil || userName?.isEmpty == true {
                // Try to get system username
                let systemUsername = NSUserName()
                if !systemUsername.isEmpty && systemUsername != "root" {
                    userName = systemUsername.capitalized
                    print("✅ Using system username: \(userName ?? "nil")")
                } else {
                    userName = "User"
                    print("⚠️ No name found, using default 'User'")
                    print("💡 Note: In sandbox/development, CloudKit may not have access to user's name.")
                    print("   This is normal behavior. In production, the name should be available.")
                }
            }
            
        } catch {
            print("❌ Error fetching user info from CloudKit: \(error.localizedDescription)")
            userName = "User"
        }
    }
    
    /// Fetch name from CloudKit user record
    private func fetchNameFromUserRecord(userRecordID: CKRecord.ID) async {
        do {
            // Try private database first (user's own record)
            let privateDatabase = container.privateCloudDatabase
            print("🔍 Fetching user record from private database...")
            let record = try await privateDatabase.record(for: userRecordID)
            
            // Debug: Log all available fields in the record
            print("📋 User record fields available:")
            for (key, value) in record.allKeys().compactMap({ ($0, record[$0]) }) {
                print("   - \(key): \(String(describing: value))")
            }
            
            // Check common name fields in user record
            if let firstName = record["firstName"] as? String,
               let lastName = record["lastName"] as? String {
                userName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                print("✅ Set userName from user record (firstName/lastName): \(userName ?? "nil")")
            } else if let fullName = record["fullName"] as? String {
                userName = fullName
                print("✅ Set userName from user record (fullName): \(userName ?? "nil")")
            } else if let displayName = record["displayName"] as? String {
                userName = displayName
                print("✅ Set userName from user record (displayName): \(userName ?? "nil")")
            } else if let name = record["name"] as? String {
                userName = name
                print("✅ Set userName from user record (name): \(userName ?? "nil")")
            } else {
                // Try to get from record metadata or system fields
                print("⚠️ No standard name fields found in user record")
               
            }
        } catch {
            print("⚠️ Could not fetch name from user record: \(error.localizedDescription)")
            print("   Error details: \(error)")
            
            // Try public database as last resort (unlikely to have user info, but worth trying)
            do {
                print("🔍 Trying public database as last resort...")
                let publicDatabase = container.publicCloudDatabase
                let record = try await publicDatabase.record(for: userRecordID)
                print("📋 Public database record fields:")
                for (key, value) in record.allKeys().compactMap({ ($0, record[$0]) }) {
                    print("   - \(key): \(String(describing: value))")
                }
            } catch {
                print("⚠️ Could not fetch from public database either: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetch user profile image from CloudKit user record
    private func fetchUserProfileImage(userRecordID: CKRecord.ID) async {
        do {
            // Try private database first (user's own record)
            let privateDatabase = container.privateCloudDatabase
            let record = try await privateDatabase.record(for: userRecordID)
            
            // Check common avatar/image fields
            if let avatarAsset = record["avatar"] as? CKAsset,
               let fileURL = avatarAsset.fileURL,
               let imageData = try? Data(contentsOf: fileURL) {
                userProfileImage = imageData
                print("✅ Found profile image in user record (avatar)")
                return
            }
            
            if let photoAsset = record["photo"] as? CKAsset,
               let fileURL = photoAsset.fileURL,
               let imageData = try? Data(contentsOf: fileURL) {
                userProfileImage = imageData
                print("✅ Found profile image in user record (photo)")
                return
            }
            
            if let imageAsset = record["image"] as? CKAsset,
               let fileURL = imageAsset.fileURL,
               let imageData = try? Data(contentsOf: fileURL) {
                userProfileImage = imageData
                print("✅ Found profile image in user record (image)")
                return
            }
            
            if let thumbnailAsset = record["thumbnail"] as? CKAsset,
               let fileURL = thumbnailAsset.fileURL,
               let imageData = try? Data(contentsOf: fileURL) {
                userProfileImage = imageData
                print("✅ Found profile image in user record (thumbnail)")
                return
            }
            
            print("⚠️ No profile image found in user record")
        } catch {
            print("⚠️ Could not fetch profile image from user record: \(error.localizedDescription)")
        }
    }
    
    /// Get user initials from name
    var userInitials: String {
        guard let name = userName else { return "U" }
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[components.count - 1].prefix(1))
            return "\(first)\(last)".uppercased()
        } else if let first = components.first, !first.isEmpty {
            return String(first.prefix(2)).uppercased()
        }
        return "U"
    }
}
