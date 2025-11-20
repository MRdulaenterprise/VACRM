# HIPAA Compliance Guidelines for macOS Swift Development

**Version:** 2025.1  
**Last Updated:** November 20, 2025  
**Audience:** Development Team  
**Framework:** Swift 5.9+, macOS 14.0+, Xcode 15+

---

## Table of Contents

1. [Overview](#overview)
2. [HIPAA Requirements Summary](#hipaa-requirements-summary)
3. [Technical Safeguards](#technical-safeguards)
4. [Administrative Safeguards](#administrative-safeguards)
5. [Physical Safeguards](#physical-safeguards)
6. [Secure Coding Practices](#secure-coding-practices)
7. [Data Encryption Standards](#data-encryption-standards)
8. [Authentication & Access Control](#authentication--access-control)
9. [Audit Logging Requirements](#audit-logging-requirements)
10. [Network Security](#network-security)
11. [Data Leakage Prevention](#data-leakage-prevention)
12. [Testing & Validation](#testing--validation)
13. [Incident Response](#incident-response)
14. [Compliance Checklist](#compliance-checklist)

---

## Overview

This document provides comprehensive HIPAA compliance guidelines for developing macOS applications using Swift. All Protected Health Information (PHI) and electronic Protected Health Information (ePHI) must be secured according to HIPAA Security Rule standards.

### Key Definitions

- **PHI**: Protected Health Information - any health information that can identify an individual
- **ePHI**: Electronic Protected Health Information - PHI stored or transmitted electronically
- **Covered Entity**: Healthcare providers, health plans, healthcare clearinghouses
- **Business Associate**: Entities that handle PHI on behalf of covered entities

---

## HIPAA Requirements Summary

### Three Pillars of HIPAA Security

1. **Technical Safeguards** - Technology and processes protecting ePHI
2. **Administrative Safeguards** - Policies, procedures, and workforce training
3. **Physical Safeguards** - Physical access controls to systems containing ePHI

### 2025 HIPAA Security Amendments

**Effective Date:** 180 days from finalization  
**Key Changes:**
- Multi-Factor Authentication (MFA) is now **mandatory** (no longer addressable)
- Enhanced encryption requirements for data in transit and at rest
- Stricter audit logging and monitoring requirements
- Required implementation of all security controls (limited exceptions only)

---

## Technical Safeguards

### 1. Access Control (§164.312(a)(1))

#### Implementation Requirements

**REQUIRED: Unique User Identification**
```swift
// ❌ WRONG: Shared credentials
let sharedUsername = "admin"

// ✅ CORRECT: Individual user accounts
struct User {
    let userID: UUID
    let username: String
    let email: String
    let roles: [Role]
    let lastLogin: Date
}
```

**REQUIRED: Emergency Access Procedure**
```swift
// Implement break-glass emergency access
class EmergencyAccessManager {
    func grantEmergencyAccess(
        requester: User,
        reason: String,
        approver: User?
    ) async throws -> EmergencyAccessSession {
        // Log emergency access request
        await auditLogger.logEmergencyAccess(
            requester: requester,
            reason: reason,
            timestamp: Date()
        )
        
        // Grant temporary elevated privileges
        let session = EmergencyAccessSession(
            user: requester,
            expiresAt: Date().addingTimeInterval(3600), // 1 hour
            reason: reason
        )
        
        // Notify security team
        await notifySecurityTeam(session: session)
        
        return session
    }
}
```

**REQUIRED: Automatic Logoff**
```swift
// Implement session timeout
class SessionManager {
    private let sessionTimeout: TimeInterval = 900 // 15 minutes
    private var lastActivityTime: Date = Date()
    private var sessionTimer: Timer?
    
    func startSessionMonitoring() {
        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.checkSessionTimeout()
        }
    }
    
    private func checkSessionTimeout() {
        let timeSinceActivity = Date().timeIntervalSince(lastActivityTime)
        
        if timeSinceActivity >= sessionTimeout {
            logoutUser()
            showSessionExpiredAlert()
        }
    }
    
    func recordActivity() {
        lastActivityTime = Date()
    }
}
```

**REQUIRED: Encryption and Decryption**
```swift
import CryptoKit

// Use AES-256-GCM for encryption at rest
class EncryptionService {
    private let key: SymmetricKey
    
    init() throws {
        // Generate or retrieve encryption key from Keychain
        self.key = try KeychainManager.retrieveEncryptionKey() 
            ?? SymmetricKey(size: .bits256)
    }
    
    func encrypt(data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
    
    func decrypt(encryptedData: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
```

### 2. Audit Controls (§164.312(b))

**REQUIRED: Comprehensive Activity Logging**

```swift
// Audit log structure
struct AuditLogEntry: Codable {
    let id: UUID
    let timestamp: Date
    let userID: UUID
    let username: String
    let action: AuditAction
    let resource: String
    let patientID: String?
    let ipAddress: String
    let deviceID: String
    let success: Bool
    let failureReason: String?
    let metadata: [String: String]
}

enum AuditAction: String, Codable {
    case login
    case logout
    case phiAccess
    case phiCreated
    case phiModified
    case phiDeleted
    case phiExported
    case phiPrinted
    case emergencyAccess
    case configurationChange
    case securitySettingModified
    case unsuccessfulLoginAttempt
}

class AuditLogger {
    func logPHIAccess(
        user: User,
        patientID: String,
        resource: String,
        success: Bool
    ) async {
        let entry = AuditLogEntry(
            id: UUID(),
            timestamp: Date(),
            userID: user.userID,
            username: user.username,
            action: .phiAccess,
            resource: resource,
            patientID: patientID,
            ipAddress: getCurrentIPAddress(),
            deviceID: getDeviceIdentifier(),
            success: success,
            failureReason: nil,
            metadata: [:]
        )
        
        await persistAuditLog(entry)
    }
    
    private func persistAuditLog(_ entry: AuditLogEntry) async {
        // Store in tamper-proof, encrypted audit log
        // Use write-once storage with integrity verification
        do {
            let encryptedLog = try encryptAuditLog(entry)
            try await writeToSecureAuditLog(encryptedLog)
        } catch {
            // Critical: Audit log failures must be escalated
            await alertSecurityTeam(error: error)
        }
    }
}
```

### 3. Integrity Controls (§164.312(c)(1))

**REQUIRED: Data Integrity Verification**

```swift
import CryptoKit

class DataIntegrityManager {
    // Generate SHA-256 hash for data integrity
    func generateHash(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Verify data hasn't been tampered with
    func verifyIntegrity(data: Data, expectedHash: String) -> Bool {
        let actualHash = generateHash(for: data)
        return actualHash == expectedHash
    }
    
    // Digital signature for ePHI
    func signData(data: Data, privateKey: P256.Signing.PrivateKey) throws -> Data {
        let signature = try privateKey.signature(for: data)
        return signature.rawRepresentation
    }
    
    func verifySignature(
        data: Data,
        signature: Data,
        publicKey: P256.Signing.PublicKey
    ) -> Bool {
        do {
            let signatureObject = try P256.Signing.ECDSASignature(
                rawRepresentation: signature
            )
            return publicKey.isValidSignature(signatureObject, for: data)
        } catch {
            return false
        }
    }
}
```

### 4. Person or Entity Authentication (§164.312(d))

**REQUIRED: Multi-Factor Authentication (MFA)**

```swift
import LocalAuthentication

class MFAManager {
    func authenticateUser(
        username: String,
        password: String
    ) async throws -> AuthenticationResult {
        // Step 1: Verify username and password
        guard try await verifyCredentials(username: username, password: password) else {
            throw AuthenticationError.invalidCredentials
        }
        
        // Step 2: Require MFA (biometric or hardware token)
        let mfaPassed = try await performMFA()
        
        guard mfaPassed else {
            throw AuthenticationError.mfaFailed
        }
        
        return .success
    }
    
    private func performMFA() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check biometric availability
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            // Fallback to hardware token or authenticator app
            return try await useHardwareToken()
        }
        
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access patient records"
        )
    }
}
```

### 5. Transmission Security (§164.312(e))

**REQUIRED: Encryption of Data in Transit**

```swift
import Foundation

class NetworkSecurityManager {
    func configureSecureSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        // Enforce TLS 1.3 minimum
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        
        // Certificate pinning
        let delegate = SecureNetworkDelegate()
        
        return URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }
}

class SecureNetworkDelegate: NSObject, URLSessionDelegate {
    // Implement certificate pinning
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Verify certificate against pinned certificates
        let pinnedCertificates = loadPinnedCertificates()
        
        if verifyCertificate(serverTrust, against: pinnedCertificates) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    private func verifyCertificate(
        _ serverTrust: SecTrust,
        against pinnedCertificates: [SecCertificate]
    ) -> Bool {
        // Implementation of certificate pinning verification
        var result = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)
        
        guard result == .unspecified || result == .proceed else {
            return false
        }
        
        // Compare against pinned certificates
        // (Implementation details omitted for brevity)
        return true
    }
}
```

---

## Administrative Safeguards

### Security Management Process

**REQUIRED: Risk Analysis**
```swift
// Document and track security risks
struct SecurityRisk: Codable {
    let id: UUID
    let title: String
    let description: String
    let severity: RiskSeverity
    let likelihood: RiskLikelihood
    let affectedSystems: [String]
    let mitigationPlan: String
    let owner: String
    let dueDate: Date
    let status: RiskStatus
}

enum RiskSeverity: String, Codable {
    case critical
    case high
    case medium
    case low
}

enum RiskStatus: String, Codable {
    case identified
    case mitigating
    case resolved
    case accepted
}
```

**REQUIRED: Workforce Training Documentation**
```swift
struct TrainingRecord: Codable {
    let employeeID: UUID
    let trainingType: TrainingType
    let completedDate: Date
    let expirationDate: Date
    let certificateID: String
    let score: Int?
}

enum TrainingType: String, Codable {
    case hipaaBasics
    case phiHandling
    case securityAwareness
    case incidentResponse
    case annualRefresher
}
```

---

## Physical Safeguards

### Device and Media Controls

**REQUIRED: Secure Workstation Use**
```swift
class WorkstationSecurityManager {
    // Enforce secure workstation configuration
    func enforceSecurityPolicies() {
        // Require screen lock after inactivity
        enableAutoLock(timeout: 300) // 5 minutes
        
        // Disable screenshot capability for PHI screens
        preventScreenshots()
        
        // Enable full disk encryption
        verifyDiskEncryption()
    }
    
    private func preventScreenshots() {
        // Mark windows as secure content
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Prevent screen recording/screenshots
            NSApp.windows.forEach { window in
                window.sharingType = .none
            }
        }
    }
}
```

**REQUIRED: Device Disposal**
```swift
class DataDisposalManager {
    // Securely erase PHI before disposal
    func secureErase(filePath: String) throws {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // Overwrite file contents multiple times (DOD 5220.22-M standard)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        let fileSize = try fileHandle.seekToEnd()
        
        for _ in 0..<7 {
            try fileHandle.seek(toOffset: 0)
            let randomData = (0..<fileSize).map { _ in UInt8.random(in: 0...255) }
            try fileHandle.write(contentsOf: Data(randomData))
        }
        
        try fileHandle.close()
        try FileManager.default.removeItem(at: fileURL)
    }
}
```

---

## Secure Coding Practices

### 1. Keychain Storage (REQUIRED for sensitive data)

```swift
import Security

class KeychainManager {
    // ✅ CORRECT: Store PHI encryption keys in Keychain
    static func saveEncryptionKey(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.yourapp.encryption.key",
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecValueData as String: keyData,
            kSecAttrAccessControl as String: try createAccessControl()
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }
    
    static func retrieveEncryptionKey() throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.yourapp.encryption.key",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
    
    private static func createAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlocked,
            .userPresence,
            &error
        ) else {
            throw KeychainError.accessControlCreationFailed
        }
        
        return accessControl
    }
}
```

### 2. Input Validation (REQUIRED)

```swift
class InputValidator {
    // ❌ WRONG: No validation
    func savePatientName(_ name: String) {
        database.save(name: name)
    }
    
    // ✅ CORRECT: Validate and sanitize all inputs
    func savePatientName(_ name: String) throws {
        // Validate length
        guard name.count >= 1 && name.count <= 100 else {
            throw ValidationError.invalidLength
        }
        
        // Sanitize input - allow only letters, spaces, hyphens, apostrophes
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        guard name.unicodeScalars.allSatisfy({ 
            allowedCharacters.contains($0) 
        }) else {
            throw ValidationError.invalidCharacters
        }
        
        // Use parameterized queries (prevent SQL injection)
        database.saveWithParameters(name: name)
    }
}
```

### 3. Memory Management (REQUIRED)

```swift
// ❌ WRONG: Sensitive data remains in memory
var password = "patient123"
// password stays in memory even after use

// ✅ CORRECT: Securely clear sensitive data
class SecureString {
    private var buffer: UnsafeMutablePointer<CChar>
    private let length: Int
    
    init(string: String) {
        self.length = string.utf8.count
        self.buffer = UnsafeMutablePointer<CChar>.allocate(capacity: length + 1)
        string.withCString { source in
            buffer.initialize(from: source, count: length + 1)
        }
    }
    
    func clear() {
        // Overwrite memory with zeros
        memset_s(buffer, length, 0, length)
    }
    
    deinit {
        clear()
        buffer.deallocate()
    }
}
```

### 4. Error Handling (REQUIRED)

```swift
// ❌ WRONG: Exposing sensitive information in errors
throw NSError(
    domain: "Auth",
    code: 401,
    userInfo: ["message": "User john@example.com failed login with password abc123"]
)

// ✅ CORRECT: Generic error messages, detailed logging
enum AuthenticationError: Error {
    case invalidCredentials
    case accountLocked
    case mfaRequired
}

func authenticateUser(username: String, password: String) throws {
    guard let user = database.findUser(username: username) else {
        // Log detailed info securely
        auditLogger.log(
            level: .warning,
            message: "Login attempt for non-existent user",
            metadata: ["username": username]
        )
        // Return generic error to user
        throw AuthenticationError.invalidCredentials
    }
    
    // Continue authentication...
}
```

### 5. Prevent Data Leakage

```swift
class DataLeakagePreventionManager {
    // ✅ Disable copy/paste for PHI fields
    func disableCopyPaste(for textField: NSTextField) {
        textField.allowsEditingTextAttributes = false
        
        class SecureTextView: NSTextView {
            override func copy(_ sender: Any?) {
                // Prevent copying PHI
            }
            
            override func paste(_ sender: Any?) {
                // Prevent pasting into PHI fields
            }
        }
    }
    
    // ✅ Prevent screenshots of PHI screens
    func markWindowAsSecure(_ window: NSWindow) {
        window.sharingType = .none
    }
    
    // ✅ Clear clipboard after timeout
    func clearClipboardAfterTimeout(timeout: TimeInterval = 30) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            NSPasteboard.general.clearContents()
        }
    }
    
    // ✅ Sanitize crash logs
    func configureCrashReporting() {
        // Never include PHI in crash reports
        CrashReporter.configure { report in
            report.filterSensitiveData()
            report.redactPatientIdentifiers()
        }
    }
}
```

---

## Data Encryption Standards

### Encryption at Rest

**REQUIRED: AES-256 encryption for all ePHI**

```swift
import CryptoKit

class PHIEncryptionManager {
    private let key: SymmetricKey
    
    init() throws {
        // Use 256-bit encryption key
        self.key = try KeychainManager.retrieveEncryptionKey() 
            ?? SymmetricKey(size: .bits256)
    }
    
    // Encrypt PHI data
    func encryptPHI(_ phi: Data) throws -> EncryptedData {
        // Use AES-256-GCM (provides both confidentiality and integrity)
        let sealedBox = try AES.GCM.seal(phi, using: key)
        
        return EncryptedData(
            ciphertext: sealedBox.ciphertext,
            nonce: sealedBox.nonce,
            tag: sealedBox.tag
        )
    }
    
    // Decrypt PHI data
    func decryptPHI(_ encrypted: EncryptedData) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(
            nonce: encrypted.nonce,
            ciphertext: encrypted.ciphertext,
            tag: encrypted.tag
        )
        
        return try AES.GCM.open(sealedBox, using: key)
    }
}

struct EncryptedData: Codable {
    let ciphertext: Data
    let nonce: AES.GCM.Nonce
    let tag: Data
}
```

### Encryption in Transit

**REQUIRED: TLS 1.3 minimum for all network communications**

```swift
class SecureAPIClient {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        
        // ✅ REQUIRED: TLS 1.3 minimum
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        
        // ✅ REQUIRED: Certificate pinning
        let delegate = CertificatePinningDelegate()
        
        self.session = URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: nil
        )
    }
    
    func sendPHI(endpoint: URL, data: Data) async throws -> Data {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ✅ Add authentication headers
        request.setValue("Bearer \(try getAuthToken())", forHTTPHeaderField: "Authorization")
        
        // ✅ Encrypt PHI before transmission (defense in depth)
        let encryptedData = try encryptPHI(data)
        request.httpBody = encryptedData
        
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        return responseData
    }
}
```

---

## Authentication & Access Control

### Role-Based Access Control (RBAC)

```swift
enum Role: String, Codable {
    case physician
    case nurse
    case admin
    case receptionist
    case billingSpecialist
}

enum Permission: String, Codable {
    case viewPHI
    case createPHI
    case modifyPHI
    case deletePHI
    case exportPHI
    case manageUsers
    case viewAuditLogs
    case modifySecuritySettings
}

class AccessControlManager {
    private let rolePermissions: [Role: Set<Permission>] = [
        .physician: [.viewPHI, .createPHI, .modifyPHI],
        .nurse: [.viewPHI, .createPHI],
        .admin: [.viewPHI, .createPHI, .modifyPHI, .deletePHI, 
                 .exportPHI, .manageUsers, .viewAuditLogs, .modifySecuritySettings],
        .receptionist: [.viewPHI],
        .billingSpecialist: [.viewPHI, .exportPHI]
    ]
    
    func hasPermission(user: User, permission: Permission) -> Bool {
        guard let permissions = rolePermissions[user.role] else {
            return false
        }
        return permissions.contains(permission)
    }
    
    func checkAccess(user: User, action: Permission, resource: String) async throws {
        // Check if user has required permission
        guard hasPermission(user: user, permission: action) else {
            // Log unauthorized access attempt
            await auditLogger.logUnauthorizedAccess(
                user: user,
                action: action,
                resource: resource
            )
            throw AccessControlError.insufficientPermissions
        }
        
        // Log authorized access
        await auditLogger.logAuthorizedAccess(
            user: user,
            action: action,
            resource: resource
        )
    }
}
```

---

## Audit Logging Requirements

### Required Events to Log

**MUST log the following for HIPAA compliance:**

1. User authentication (login/logout, failed attempts)
2. PHI access (view, create, modify, delete)
3. PHI export/print operations
4. Emergency access usage
5. Security configuration changes
6. User account modifications
7. Encryption key access
8. Audit log access

```swift
class ComprehensiveAuditLogger {
    private let encryptionService: EncryptionService
    private let integrityManager: DataIntegrityManager
    
    func log(_ entry: AuditLogEntry) async throws {
        // 1. Add timestamp and sequence number
        var completeEntry = entry
        completeEntry.timestamp = Date()
        completeEntry.sequenceNumber = try await getNextSequenceNumber()
        
        // 2. Encrypt audit log entry
        let jsonData = try JSONEncoder().encode(completeEntry)
        let encryptedData = try encryptionService.encrypt(data: jsonData)
        
        // 3. Generate integrity hash
        let hash = integrityManager.generateHash(for: encryptedData)
        
        // 4. Store with tamper-proof mechanism
        try await storeAuditLog(
            data: encryptedData,
            hash: hash,
            sequenceNumber: completeEntry.sequenceNumber
        )
        
        // 5. Replicate to secure backup location
        try await replicateToBackup(data: encryptedData, hash: hash)
    }
    
    // ✅ REQUIRED: Retain audit logs for minimum 6 years
    func enforceRetentionPolicy() async throws {
        let retentionPeriod: TimeInterval = 6 * 365 * 24 * 60 * 60 // 6 years
        let cutoffDate = Date().addingTimeInterval(-retentionPeriod)
        
        // Archive old logs (don't delete - move to cold storage)
        try await archiveLogsOlderThan(date: cutoffDate)
    }
}
```

### Audit Log Structure

```swift
struct AuditLogEntry: Codable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var sequenceNumber: UInt64 = 0
    
    // User information
    let userID: UUID
    let username: String
    let userRole: Role
    
    // Action details
    let action: AuditAction
    let resource: String
    let resourceID: String?
    let patientID: String?
    
    // Technical details
    let ipAddress: String
    let deviceID: String
    let applicationVersion: String
    
    // Result
    let success: Bool
    let failureReason: String?
    
    // Additional metadata
    let metadata: [String: String]
    
    // Integrity
    var previousEntryHash: String?
}
```

---

## Network Security

### API Security Headers

```swift
extension URLRequest {
    mutating func addSecurityHeaders(authToken: String) {
        // Authentication
        setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Content type
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Security headers
        setValue("nosniff", forHTTPHeaderField: "X-Content-Type-Options")
        setValue("deny", forHTTPHeaderField: "X-Frame-Options")
        setValue("1; mode=block", forHTTPHeaderField: "X-XSS-Protection")
        setValue(
            "default-src 'self'",
            forHTTPHeaderField: "Content-Security-Policy"
        )
        
        // Cache control (prevent caching of PHI)
        setValue(
            "no-store, no-cache, must-revalidate, private",
            forHTTPHeaderField: "Cache-Control"
        )
        setValue("no-cache", forHTTPHeaderField: "Pragma")
    }
}
```

### Request Signing

```swift
class RequestSigner {
    private let privateKey: P256.Signing.PrivateKey
    
    func signRequest(_ request: URLRequest) throws -> URLRequest {
        var signedRequest = request
        
        // Create signature payload
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? ""
        let body = request.httpBody ?? Data()
        
        let payload = "\(method)\n\(path)\n\(timestamp)\n\(body.base64EncodedString())"
        let payloadData = Data(payload.utf8)
        
        // Sign the payload
        let signature = try privateKey.signature(for: payloadData)
        
        // Add signature headers
        signedRequest.setValue(timestamp, forHTTPHeaderField: "X-Timestamp")
        signedRequest.setValue(
            signature.rawRepresentation.base64EncodedString(),
            forHTTPHeaderField: "X-Signature"
        )
        
        return signedRequest
    }
}
```

---

## Data Leakage Prevention

### Application-Level Protections

```swift
class DataLeakageProtection {
    // 1. Prevent screenshots and screen recording
    static func protectWindow(_ window: NSWindow) {
        window.sharingType = .none
    }
    
    // 2. Clear pasteboard after copying PHI
    static func secureCopy(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Clear after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            pasteboard.clearContents()
        }
    }
    
    // 3. Sanitize application cache
    static func clearCaches() {
        URLCache.shared.removeAllCachedResponses()
        
        // Clear temporary files
        let tempDir = FileManager.default.temporaryDirectory
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    // 4. Prevent debugging in production
    static func preventDebugging() {
        #if !DEBUG
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        
        if result == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
            // Debugger detected - exit application
            exit(EXIT_FAILURE)
        }
        #endif
    }
}
```

### Code Obfuscation

```swift
// Use SwiftShield or similar tools for code obfuscation in release builds
// Add to build script:
// if [ "${CONFIGURATION}" == "Release" ]; then
//     swiftshield obfuscate
// fi
```

---

## Testing & Validation

### Security Test Checklist

```swift
class SecurityTestSuite: XCTestCase {
    // 1. Test encryption
    func testDataEncryption() throws {
        let phi = "Patient: John Doe, SSN: 123-45-6789".data(using: .utf8)!
        let encrypted = try encryptionService.encrypt(data: phi)
        
        // Verify encrypted data is different from original
        XCTAssertNotEqual(encrypted, phi)
        
        // Verify decryption restores original
        let decrypted = try encryptionService.decrypt(encryptedData: encrypted)
        XCTAssertEqual(decrypted, phi)
    }
    
    // 2. Test authentication
    func testMFARequired() async throws {
        // Verify MFA is enforced
        do {
            _ = try await authManager.authenticate(
                username: "test@example.com",
                password: "password123"
            )
            XCTFail("Should require MFA")
        } catch AuthenticationError.mfaRequired {
            // Expected
        }
    }
    
    // 3. Test access control
    func testUnauthorizedAccess() async {
        let receptionist = User(role: .receptionist)
        
        do {
            try await accessControl.checkAccess(
                user: receptionist,
                action: .deletePHI,
                resource: "patient/12345"
            )
            XCTFail("Should deny access")
        } catch AccessControlError.insufficientPermissions {
            // Expected
        }
    }
    
    // 4. Test audit logging
    func testAuditLogging() async throws {
        let entry = AuditLogEntry(/* ... */)
        try await auditLogger.log(entry)
        
        // Verify log was persisted
        let logs = try await auditLogger.retrieveLogs(for: entry.userID)
        XCTAssertTrue(logs.contains(where: { $0.id == entry.id }))
    }
    
    // 5. Test session timeout
    func testSessionTimeout() {
        let sessionManager = SessionManager()
        sessionManager.startSessionMonitoring()
        
        // Simulate 16 minutes of inactivity
        Thread.sleep(forTimeInterval: 960)
        
        XCTAssertFalse(sessionManager.isSessionActive)
    }
}
```

### Penetration Testing Requirements

**REQUIRED: Annual penetration testing**

Document and test:
- SQL injection vulnerabilities
- Authentication bypass attempts
- Session hijacking
- Man-in-the-middle attacks
- Unauthorized data access
- Encryption weaknesses

---

## Incident Response

### Breach Detection and Response

```swift
class IncidentResponseManager {
    func detectBreach(event: SecurityEvent) async {
        // Analyze security event
        let severity = analyzeSeverity(event)
        
        if severity >= .high {
            await initiateBreachProtocol(event: event)
        }
    }
    
    private func initiateBreachProtocol(event: SecurityEvent) async {
        // 1. Contain the breach
        await containBreach(event: event)
        
        // 2. Notify security team immediately
        await notifySecurityTeam(event: event)
        
        // 3. Document the incident
        let incident = SecurityIncident(
            id: UUID(),
            event: event,
            detectedAt: Date(),
            status: .investigating
        )
        try? await documentIncident(incident)
        
        // 4. Assess if PHI was compromised
        let phiCompromised = await assessPHICompromise(event: event)
        
        if phiCompromised {
            // REQUIRED: Notify affected individuals within 60 days
            await scheduleBreachNotification(incident: incident)
            
            // REQUIRED: Report to HHS if >500 individuals affected
            if incident.affectedIndividuals > 500 {
                await notifyHHS(incident: incident)
            }
        }
    }
    
    // REQUIRED: Breach notification within 60 days
    private func scheduleBreachNotification(incident: SecurityIncident) async {
        let notificationDeadline = Date().addingTimeInterval(60 * 24 * 60 * 60)
        
        await scheduler.schedule(
            task: .breachNotification(incident),
            deadline: notificationDeadline
        )
    }
}

struct SecurityIncident: Codable {
    let id: UUID
    let event: SecurityEvent
    let detectedAt: Date
    var status: IncidentStatus
    var affectedIndividuals: Int = 0
    var phiTypes: [PHIType] = []
    var mitigationSteps: [String] = []
}

enum IncidentStatus: String, Codable {
    case investigating
    case contained
    case mitigated
    case resolved
}
```

---

## Compliance Checklist

### Pre-Deployment Security Review

- [ ] **Encryption**
  - [ ] All PHI encrypted at rest using AES-256
  - [ ] All PHI encrypted in transit using TLS 1.3+
  - [ ] Encryption keys stored in Keychain with access controls
  - [ ] Key rotation policy implemented

- [ ] **Authentication & Access Control**
  - [ ] Multi-factor authentication (MFA) implemented and required
  - [ ] Role-based access control (RBAC) implemented
  - [ ] Unique user IDs for all users
  - [ ] Automatic session timeout (≤15 minutes)
  - [ ] Emergency access procedure documented

- [ ] **Audit Logging**
  - [ ] All PHI access logged
  - [ ] All authentication events logged
  - [ ] All security changes logged
  - [ ] Logs encrypted and tamper-proof
  - [ ] 6-year retention policy implemented
  - [ ] Regular log review process established

- [ ] **Data Protection**
  - [ ] No hardcoded credentials or API keys
  - [ ] Input validation on all user inputs
  - [ ] Output encoding to prevent injection attacks
  - [ ] Parameterized queries for database access
  - [ ] Secure memory management for sensitive data

- [ ] **Network Security**
  - [ ] Certificate pinning implemented
  - [ ] TLS 1.3 minimum enforced
  - [ ] Security headers implemented
  - [ ] Request signing implemented

- [ ] **Data Leakage Prevention**
  - [ ] Screenshots disabled for PHI screens
  - [ ] Copy/paste restricted for sensitive fields
  - [ ] Cache cleared on logout
  - [ ] No PHI in crash reports or logs

- [ ] **Physical Safeguards**
  - [ ] Screen lock enforced after inactivity
  - [ ] Full disk encryption verified
  - [ ] Secure disposal procedure documented

- [ ] **Administrative Controls**
  - [ ] Security policies documented
  - [ ] Workforce training records maintained
  - [ ] Risk analysis completed and documented
  - [ ] Incident response plan established
  - [ ] Business Associate Agreements (BAA) in place

- [ ] **Testing**
  - [ ] Security test suite passing
  - [ ] Penetration testing completed
  - [ ] Vulnerability scanning completed
  - [ ] Code review completed

- [ ] **Documentation**
  - [ ] Security procedures documented
  - [ ] Audit trail requirements documented
  - [ ] Encryption methods documented
  - [ ] Access control policies documented
  - [ ] Incident response procedures documented

---

## Code Examples Repository

### Complete Secure PHI Manager

```swift
import Foundation
import CryptoKit
import Security

/// Complete example of HIPAA-compliant PHI management
class SecurePHIManager {
    private let encryptionService: EncryptionService
    private let auditLogger: AuditLogger
    private let accessControl: AccessControlManager
    
    init() throws {
        self.encryptionService = try EncryptionService()
        self.auditLogger = AuditLogger()
        self.accessControl = AccessControlManager()
    }
    
    /// Securely store PHI
    func storePHI(
        _ phi: PatientHealthInformation,
        by user: User
    ) async throws {
        // 1. Check access permissions
        try await accessControl.checkAccess(
            user: user,
            action: .createPHI,
            resource: "phi/\(phi.id)"
        )
        
        // 2. Encrypt PHI
        let phiData = try JSONEncoder().encode(phi)
        let encrypted = try encryptionService.encrypt(data: phiData)
        
        // 3. Store encrypted data
        try await database.save(encrypted, id: phi.id)
        
        // 4. Log the action
        await auditLogger.logPHICreated(
            user: user,
            patientID: phi.patientID,
            phiID: phi.id.uuidString
        )
    }
    
    /// Securely retrieve PHI
    func retrievePHI(
        id: UUID,
        by user: User
    ) async throws -> PatientHealthInformation {
        // 1. Check access permissions
        try await accessControl.checkAccess(
            user: user,
            action: .viewPHI,
            resource: "phi/\(id)"
        )
        
        // 2. Retrieve encrypted data
        let encrypted = try await database.retrieve(id: id)
        
        // 3. Decrypt PHI
        let decrypted = try encryptionService.decrypt(encryptedData: encrypted)
        let phi = try JSONDecoder().decode(
            PatientHealthInformation.self,
            from: decrypted
        )
        
        // 4. Log the access
        await auditLogger.logPHIAccessed(
            user: user,
            patientID: phi.patientID,
            phiID: id.uuidString,
            success: true
        )
        
        return phi
    }
    
    /// Securely delete PHI
    func deletePHI(
        id: UUID,
        by user: User
    ) async throws {
        // 1. Check access permissions
        try await accessControl.checkAccess(
            user: user,
            action: .deletePHI,
            resource: "phi/\(id)"
        )
        
        // 2. Retrieve PHI for logging
        let phi = try await retrievePHI(id: id, by: user)
        
        // 3. Secure deletion (overwrite before delete)
        try await database.secureDelete(id: id)
        
        // 4. Log the deletion
        await auditLogger.logPHIDeleted(
            user: user,
            patientID: phi.patientID,
            phiID: id.uuidString
        )
    }
}

struct PatientHealthInformation: Codable {
    let id: UUID
    let patientID: String
    let patientName: String
    let dateOfBirth: Date
    let ssn: String
    let diagnoses: [String]
    let medications: [String]
    let createdAt: Date
    let createdBy: UUID
}
```

---

## Resources and References

### Official HIPAA Resources
- [HHS HIPAA for Professionals](https://www.hhs.gov/hipaa/for-professionals/index.html)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
- [NIST SP 800-111 - Guide to Storage Encryption Technologies](https://csrc.nist.gov/publications/detail/sp/800-111/final)
- [NIST SP 800-52 - Guidelines for TLS](https://csrc.nist.gov/publications/detail/sp/800-52/rev-2/final)

### Apple Security Documentation
- [Apple Security Framework](https://developer.apple.com/documentation/security)
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [CryptoKit](https://developer.apple.com/documentation/cryptokit)
- [Local Authentication](https://developer.apple.com/documentation/localauthentication)

### Third-Party Libraries (Use with caution - audit before use)
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift) - Keychain helper
- [SwiftSecurity](https://github.com/dm-zharov/swift-security) - Type-safe Security framework APIs

### Compliance Frameworks
- HITRUST CSF - Comprehensive security framework
- NIST Cybersecurity Framework
- ISO 27001 - Information Security Management

---

## Maintenance and Updates

**This document must be reviewed and updated:**
- Quarterly for general updates
- When HIPAA regulations change
- After security incidents
- When new features are added
- Before major releases

**Document Owner:** Security Officer  
**Last Review:** November 20, 2025  
**Next Review:** February 20, 2026

---

## Disclaimer

This document provides guidance for HIPAA compliance but does not constitute legal advice. Consult with qualified legal counsel and HIPAA compliance experts for your specific situation. Regular security audits and risk assessments are required to maintain compliance.

---

## Quick Start Guide

### Immediate Actions for New Developers

1. **Complete HIPAA training** within first week
2. **Review this entire document** before writing any code
3. **Never commit:**
   - Hardcoded credentials
   - API keys
   - PHI test data
   - Encryption keys
4. **Always:**
   - Encrypt PHI at rest and in transit
   - Log PHI access
   - Validate all inputs
   - Use Keychain for sensitive data
   - Enable MFA for development systems
5. **Ask before:**
   - Adding third-party libraries
   - Changing authentication logic
   - Modifying encryption methods
   - Exposing new API endpoints

### Code Review Requirements

All code touching PHI must be reviewed by security-cleared team member and must verify:
- [ ] Encryption implemented correctly
- [ ] Access control enforced
- [ ] Audit logging present
- [ ] Input validation complete
- [ ] No data leakage vectors
- [ ] No hardcoded secrets

---

**END OF DOCUMENT**