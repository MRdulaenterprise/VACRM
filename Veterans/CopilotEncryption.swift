//
//  CopilotEncryption.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import CryptoKit
import Security

enum CopilotEncryptionError: Error, LocalizedError {
    case keyGenerationFailed
    case keychainError(OSStatus)
    case encryptionFailed(String)
    case decryptionFailed(String)
    case invalidData
    case authenticationTagMismatch

    var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:
            return "Failed to generate encryption key."
        case .keychainError(let status):
            return "Keychain operation failed with status: \(status)."
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        case .invalidData:
            return "Invalid data provided for encryption/decryption."
        case .authenticationTagMismatch:
            return "Authentication tag mismatch during decryption. Data may be tampered with or key is incorrect."
        }
    }
}

class CopilotEncryption {
    private static let serviceName = "com.veteransclaimsfoundation.copilot.encryptionKey"
    private static let keyTag = "com.veteransclaimsfoundation.copilot.aesKey"

    /// Retrieves or generates a symmetric encryption key from Keychain.
    /// - Returns: A `SymmetricKey` for AES-256.
    /// - Throws: `CopilotEncryptionError` if key generation or Keychain operations fail.
    static func getSymmetricKey() throws -> SymmetricKey {
        if let key = loadKeyFromKeychain() {
            return key
        } else {
            let newKey = SymmetricKey(size: .bits256)
            try saveKeyToKeychain(newKey)
            return newKey
        }
    }

    private static func saveKeyToKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        
        // First, try to delete existing item
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: keyTag
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Build save query - try without kSecUseDataProtectionKeychain first
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: keyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        // Try adding with data protection keychain (macOS 10.15+)
        if #available(macOS 10.15, *) {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        var status = SecItemAdd(query as CFDictionary, nil)
        
        // If that fails, try without data protection keychain
        if status != errSecSuccess {
            print("⚠️ Keychain save with data protection failed (status: \(status)), trying without...")
            query.removeValue(forKey: kSecUseDataProtectionKeychain as String)
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            print("❌ Keychain save failed with status: \(status) (errSecMissingEntitlement = -34018)")
            throw CopilotEncryptionError.keychainError(status)
        }
    }

    private static func loadKeyFromKeychain() -> SymmetricKey? {
        // Try with data protection keychain first
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if #available(macOS 10.15, *) {
            query[kSecUseDataProtectionKeychain as String] = true
        }

        var item: CFTypeRef?
        var status = SecItemCopyMatching(query as CFDictionary, &item)

        // If that fails, try without data protection keychain
        if status != errSecSuccess {
            query.removeValue(forKey: kSecUseDataProtectionKeychain as String)
            status = SecItemCopyMatching(query as CFDictionary, &item)
        }

        guard status == errSecSuccess, let keyData = item as? Data else {
            if status != errSecItemNotFound {
                print("⚠️ Keychain load failed with status: \(status)")
            }
            return nil
        }

        return SymmetricKey(data: keyData)
    }

    /// Encrypts data using AES-256-GCM.
    /// - Parameter data: The data to encrypt.
    /// - Returns: The encrypted data, including nonce and authentication tag.
    /// - Throws: `CopilotEncryptionError` if encryption fails.
    static func encrypt(data: Data) throws -> Data {
        let key = try getSymmetricKey()
        let sealedBox = try AES.GCM.seal(data, using: key)

        let ciphertext = sealedBox.ciphertext
        let tag = sealedBox.tag
        let nonce = sealedBox.nonce

        // Combine nonce, ciphertext, and tag for storage
        var encryptedData = Data()
        encryptedData.append(Data(nonce))
        encryptedData.append(ciphertext)
        encryptedData.append(tag)

        return encryptedData
    }

    /// Decrypts data using AES-256-GCM.
    /// - Parameter encryptedData: The data to decrypt (nonce + ciphertext + tag).
    /// - Returns: The decrypted original data.
    /// - Throws: `CopilotEncryptionError` if decryption fails or data is invalid/tampered.
    static func decrypt(encryptedData: Data) throws -> Data {
        let key = try getSymmetricKey()

        let nonceLength = 12 // AES-GCM nonce is 12 bytes
        let tagLength = 16 // AES-GCM tag is 16 bytes

        guard encryptedData.count >= nonceLength + tagLength else {
            throw CopilotEncryptionError.invalidData
        }

        let nonce = encryptedData.prefix(nonceLength)
        let ciphertext = encryptedData.dropFirst(nonceLength).dropLast(tagLength)
        let tag = encryptedData.suffix(tagLength)

        guard let aesNonce = try? AES.GCM.Nonce(data: nonce) else {
            throw CopilotEncryptionError.decryptionFailed("Invalid nonce format.")
        }

        let sealedBox = try AES.GCM.SealedBox(nonce: aesNonce, ciphertext: ciphertext, tag: tag)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        return decryptedData
    }
}

// MARK: - Encryption Errors

enum EncryptionError: Error, LocalizedError {
    case keychainStoreFailed(OSStatus)
    case keychainRetrieveFailed(OSStatus)
    case accessControlCreationFailed
    case encryptionFailed
    case decryptionFailed
    case invalidData
    case keyGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .keychainStoreFailed(let status):
            return "Failed to store encryption key in Keychain: \(status)"
        case .keychainRetrieveFailed(let status):
            return "Failed to retrieve encryption key from Keychain: \(status)"
        case .accessControlCreationFailed:
            return "Failed to create Keychain access control"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .invalidData:
            return "Invalid data provided for encryption/decryption"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        }
    }
}

// MARK: - Secure String Extension

extension String {
    /// Securely clear string from memory
    mutating func secureClear() {
        self.withUTF8 { utf8 in
            let mutableBytes = UnsafeMutableRawPointer(mutating: utf8.baseAddress!)
            memset_s(mutableBytes, utf8.count, 0, utf8.count)
        }
        self = ""
    }
}

// MARK: - Secure Data Extension

extension Data {
    /// Securely clear data from memory
    mutating func secureClear() {
        _ = self.withUnsafeMutableBytes { bytes in
            memset_s(bytes.baseAddress, bytes.count, 0, bytes.count)
        }
        self = Data()
    }
}