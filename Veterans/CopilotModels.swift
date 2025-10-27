//
//  CopilotModels.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData
import CryptoKit

// MARK: - Chat Session Model
@Model
final class ChatSession {
    var id: UUID
    var title: String
    var createdAt: Date
    var lastMessageAt: Date
    var messageCount: Int
    var isPinned: Bool
    @Relationship(deleteRule: .nullify) var associatedVeteran: Veteran?
    @Relationship(deleteRule: .nullify) var promptTemplate: PromptTemplate?
    @Relationship(deleteRule: .cascade) var messages: [ChatMessage] = []
    @Relationship(deleteRule: .cascade) var documents: [ChatDocument] = []
    
    init(title: String, associatedVeteran: Veteran? = nil, promptTemplate: PromptTemplate? = nil) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.lastMessageAt = Date()
        self.messageCount = 0
        self.isPinned = false
        self.associatedVeteran = associatedVeteran
        self.promptTemplate = promptTemplate
        // Relationships are initialized as empty arrays by default
    }
    
    func updateLastMessage() {
        self.lastMessageAt = Date()
        self.messageCount = messages.count
    }
}

// MARK: - Chat Message Model
@Model
final class ChatMessage {
    var id: UUID
    @Relationship(deleteRule: .nullify) var session: ChatSession?
    var role: MessageRole
    var content: String
    var timestamp: Date
    var isDeidentified: Bool
    var deidentifiedContent: String?
    var tokenCount: Int
    var modelUsed: String?
    var processingTime: Double?
    @Relationship(deleteRule: .nullify) var associatedDocument: ChatDocument?
    
    init(role: MessageRole, content: String, isDeidentified: Bool = false, deidentifiedContent: String? = nil, associatedDocument: ChatDocument? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isDeidentified = isDeidentified
        self.deidentifiedContent = deidentifiedContent
        self.tokenCount = 0
        self.modelUsed = nil
        self.processingTime = nil
        self.associatedDocument = associatedDocument
    }
}

// MARK: - Chat Document Model
@Model
final class ChatDocument {
    var id: UUID
    @Relationship(deleteRule: .nullify) var session: ChatSession?
    var fileName: String
    var fileType: String
    var fileSize: Int64
    var uploadDate: Date
    var encryptedFilePath: String
    var extractedText: String?
    var deidentifiedText: String?
    var summary: String?
    var isProcessed: Bool
    var processingError: String?
    
    init(fileName: String, fileType: String, fileSize: Int64, encryptedFilePath: String) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.uploadDate = Date()
        self.encryptedFilePath = encryptedFilePath
        self.extractedText = nil
        self.deidentifiedText = nil
        self.summary = nil
        self.isProcessed = false
        self.processingError = nil
    }
}

// MARK: - Prompt Template Model
@Model
final class PromptTemplate: Codable {
    var id: UUID
    var name: String
    var templateDescription: String
    var content: String
    var category: PromptCategory
    var variables: [String] = [] // Array of variable names like ["CONDITION", "BRANCH", "DATES"]
    var isDefault: Bool
    var createdAt: Date
    var lastUsed: Date?
    var useCount: Int
    
    init(name: String, templateDescription: String, content: String, category: PromptCategory, variables: [String] = [], isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.templateDescription = templateDescription
        self.content = content
        self.category = category
        self.variables = variables
        self.isDefault = isDefault
        self.createdAt = Date()
        self.lastUsed = nil
        self.useCount = 0
    }
    
    func markAsUsed() {
        self.lastUsed = Date()
        self.useCount += 1
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, templateDescription, content, category, variables, isDefault, createdAt, lastUsed, useCount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        templateDescription = try container.decode(String.self, forKey: .templateDescription)
        content = try container.decode(String.self, forKey: .content)
        category = try container.decode(PromptCategory.self, forKey: .category)
        variables = try container.decode([String].self, forKey: .variables)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastUsed = try container.decodeIfPresent(Date.self, forKey: .lastUsed)
        useCount = try container.decode(Int.self, forKey: .useCount)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(templateDescription, forKey: .templateDescription)
        try container.encode(content, forKey: .content)
        try container.encode(category, forKey: .category)
        try container.encode(variables, forKey: .variables)
        try container.encode(isDefault, forKey: .isDefault)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(lastUsed, forKey: .lastUsed)
        try container.encode(useCount, forKey: .useCount)
    }
}

// MARK: - Enums
enum MessageRole: String, CaseIterable, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .user:
            return "You"
        case .assistant:
            return "Copilot"
        case .system:
            return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .user:
            return "person.circle.fill"
        case .assistant:
            return "brain.head.profile"
        case .system:
            return "gear.circle.fill"
        }
    }
}

enum PromptCategory: String, CaseIterable, Codable {
    case claimStatus = "Claim Status"
    case nexusLetter = "Nexus Letter"
    case appeals = "Appeals"
    case general = "General"
    case medical = "Medical"
    case legal = "Legal"
    
    var icon: String {
        switch self {
        case .claimStatus:
            return "doc.text.fill"
        case .nexusLetter:
            return "envelope.fill"
        case .appeals:
            return "hammer.fill"
        case .general:
            return "questionmark.circle.fill"
        case .medical:
            return "cross.fill"
        case .legal:
            return "scale.3d"
        }
    }
}

// MARK: - De-identification Types
struct DeidentifiedContent {
    let originalText: String
    let deidentifiedText: String
    let redactedItems: [RedactedItem]
    let timestamp: Date
    
    init(originalText: String, deidentifiedText: String, redactedItems: [RedactedItem]) {
        self.originalText = originalText
        self.deidentifiedText = deidentifiedText
        self.redactedItems = redactedItems
        self.timestamp = Date()
    }
}

struct RedactedItem {
    let type: RedactionType
    let originalValue: String
    let replacement: String
    let confidence: Double
    let range: Range<String.Index>
    
    init(type: RedactionType, originalValue: String, replacement: String, confidence: Double, range: Range<String.Index>) {
        self.type = type
        self.originalValue = originalValue
        self.replacement = replacement
        self.confidence = confidence
        self.range = range
    }
}

enum RedactionType: String, CaseIterable, Codable {
    case name = "Name"
    case ssn = "SSN"
    case dob = "Date of Birth"
    case phone = "Phone Number"
    case email = "Email Address"
    case address = "Address"
    case veteranId = "Veteran ID"
    case medicalRecordNumber = "Medical Record Number"
    case accountNumber = "Account Number"
    case certificateNumber = "Certificate Number"
    case vehicleIdentifier = "Vehicle Identifier"
    case deviceIdentifier = "Device Identifier"
    case biometricIdentifier = "Biometric Identifier"
    case fullFacePhoto = "Full Face Photo"
    case other = "Other"
    
    var replacementToken: String {
        switch self {
        case .name:
            return "[NAME]"
        case .ssn:
            return "[SSN-REDACTED]"
        case .dob:
            return "[DOB-REDACTED]"
        case .phone:
            return "[PHONE]"
        case .email:
            return "[EMAIL]"
        case .address:
            return "[ADDRESS]"
        case .veteranId:
            return "[VETERAN-ID]"
        case .medicalRecordNumber:
            return "[MEDICAL-RECORD-NUMBER]"
        case .accountNumber:
            return "[ACCOUNT-NUMBER]"
        case .certificateNumber:
            return "[CERTIFICATE-NUMBER]"
        case .vehicleIdentifier:
            return "[VEHICLE-ID]"
        case .deviceIdentifier:
            return "[DEVICE-ID]"
        case .biometricIdentifier:
            return "[BIOMETRIC-ID]"
        case .fullFacePhoto:
            return "[PHOTO]"
        case .other:
            return "[REDACTED]"
        }
    }
    
    var color: String {
        switch self {
        case .name, .ssn, .dob:
            return "red"
        case .phone, .email, .address:
            return "orange"
        case .veteranId, .medicalRecordNumber:
            return "blue"
        default:
            return "gray"
        }
    }
}

// MARK: - OpenAI API Types
struct OpenAIRequest {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
    
    init(model: String = "gpt-4", messages: [OpenAIMessage], temperature: Double = 0.7, maxTokens: Int = 2000, stream: Bool = true) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.stream = stream
    }
}

struct OpenAIMessage {
    let role: String
    let content: String
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

struct OpenAIResponse {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice {
    let index: Int
    let message: OpenAIMessage?
    let delta: OpenAIMessage?
    let finishReason: String?
}

struct OpenAIUsage {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}

// MARK: - PDF Export Types
struct ChatExportData {
    let session: ChatSession
    let messages: [ChatMessage]
    let exportDate: Date
    let exportedBy: String
    let veteranInfo: String?
    
    init(session: ChatSession, messages: [ChatMessage], exportedBy: String) {
        self.session = session
        self.messages = messages
        self.exportDate = Date()
        self.exportedBy = exportedBy
        self.veteranInfo = session.associatedVeteran?.fullName
    }
}
