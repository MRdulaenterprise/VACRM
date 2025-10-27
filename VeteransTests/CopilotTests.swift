//
//  CopilotTests.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import XCTest
import SwiftData
@testable import Veterans

/// Unit tests for Copilot functionality
/// Tests de-identification, encryption, and core functionality
final class CopilotTests: XCTestCase {
    
    var deidentificationService: DeIdentificationService!
    var encryptionService: CopilotEncryption!
    
    override func setUpWithError() throws {
        deidentificationService = DeIdentificationService()
        encryptionService = CopilotEncryption()
    }
    
    override func tearDownWithError() throws {
        deidentificationService = nil
        encryptionService = nil
    }
    
    // MARK: - De-identification Tests
    
    func testSSNRedaction() throws {
        let text = "My SSN is 123-45-6789 and my other SSN is 987654321"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[SSN-REDACTED]"))
        XCTAssertFalse(result.deidentifiedText.contains("123-45-6789"))
        XCTAssertFalse(result.deidentifiedText.contains("987654321"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testDateOfBirthRedaction() throws {
        let text = "I was born on 01/15/1980 and my friend was born on 12-25-1975"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[DOB-REDACTED]"))
        XCTAssertFalse(result.deidentifiedText.contains("01/15/1980"))
        XCTAssertFalse(result.deidentifiedText.contains("12-25-1975"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testPhoneNumberRedaction() throws {
        let text = "Call me at (555) 123-4567 or 555.987.6543"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[PHONE]"))
        XCTAssertFalse(result.deidentifiedText.contains("(555) 123-4567"))
        XCTAssertFalse(result.deidentifiedText.contains("555.987.6543"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testEmailRedaction() throws {
        let text = "Contact me at john.doe@example.com or jane_smith@company.org"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[EMAIL]"))
        XCTAssertFalse(result.deidentifiedText.contains("john.doe@example.com"))
        XCTAssertFalse(result.deidentifiedText.contains("jane_smith@company.org"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testNameRedaction() throws {
        let text = "John Smith and Jane Doe are veterans"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[NAME]"))
        XCTAssertFalse(result.deidentifiedText.contains("John Smith"))
        XCTAssertFalse(result.deidentifiedText.contains("Jane Doe"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testVeteranIDRedaction() throws {
        let text = "VA File Number: 123456789 and Veteran ID: 987654321"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[VETERAN-ID]"))
        XCTAssertFalse(result.deidentifiedText.contains("123456789"))
        XCTAssertFalse(result.deidentifiedText.contains("987654321"))
        XCTAssertEqual(result.redactedItems.count, 2)
    }
    
    func testMultiplePHITypes() throws {
        let text = """
        Veteran John Smith (SSN: 123-45-6789, DOB: 01/15/1980)
        Contact: john.smith@email.com, Phone: (555) 123-4567
        VA File Number: 123456789
        """
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertTrue(result.deidentifiedText.contains("[NAME]"))
        XCTAssertTrue(result.deidentifiedText.contains("[SSN-REDACTED]"))
        XCTAssertTrue(result.deidentifiedText.contains("[DOB-REDACTED]"))
        XCTAssertTrue(result.deidentifiedText.contains("[EMAIL]"))
        XCTAssertTrue(result.deidentifiedText.contains("[PHONE]"))
        XCTAssertTrue(result.deidentifiedText.contains("[VETERAN-ID]"))
        
        XCTAssertEqual(result.redactedItems.count, 6)
    }
    
    func testNoPHIDetection() throws {
        let text = "This is a normal message with no personal information"
        let result = deidentificationService.deidentifyText(text)
        
        XCTAssertEqual(result.deidentifiedText, text)
        XCTAssertEqual(result.redactedItems.count, 0)
    }
    
    func testPHIContainsCheck() throws {
        let textWithPHI = "My SSN is 123-45-6789"
        let textWithoutPHI = "This is a normal message"
        
        XCTAssertTrue(deidentificationService.containsPHI(textWithPHI))
        XCTAssertFalse(deidentificationService.containsPHI(textWithoutPHI))
    }
    
    // MARK: - Encryption Tests
    
    func testMessageEncryption() throws {
        let originalMessage = "This is a test message for encryption"
        
        let encryptedMessage = try encryptionService.encryptMessage(originalMessage)
        let decryptedMessage = try encryptionService.decryptMessage(encryptedMessage)
        
        XCTAssertEqual(decryptedMessage, originalMessage)
    }
    
    func testDocumentEncryption() throws {
        let originalData = "Test document content".data(using: .utf8)!
        
        let encryptedDocument = try encryptionService.encryptDocument(originalData)
        let decryptedData = try encryptionService.decryptDocument(encryptedDocument)
        
        XCTAssertEqual(decryptedData, originalData)
    }
    
    func testEncryptionValidation() throws {
        let isValid = try encryptionService.validateEncryption()
        XCTAssertTrue(isValid)
    }
    
    func testSecureMemoryClear() throws {
        var sensitiveData = "Sensitive information".data(using: .utf8)!
        var sensitiveString = "Sensitive string"
        
        encryptionService.secureClear(&sensitiveData)
        encryptionService.secureClear(&sensitiveString)
        
        XCTAssertTrue(sensitiveData.isEmpty)
        XCTAssertTrue(sensitiveString.isEmpty)
    }
    
    // MARK: - Prompt Template Tests
    
    func testPromptTemplateValidation() throws {
        let validTemplate = PromptTemplate(
            name: "Test Template",
            description: "A test template",
            content: "Hello [NAME], your [CONDITION] claim status is [STATUS]",
            category: .claimStatus,
            variables: ["NAME", "CONDITION", "STATUS"]
        )
        
        let validation = PromptTemplates.validateTemplate(validTemplate)
        XCTAssertTrue(validation.isValid)
        XCTAssertTrue(validation.errors.isEmpty)
    }
    
    func testPromptTemplateWithErrors() throws {
        let invalidTemplate = PromptTemplate(
            name: "", // Empty name
            description: "", // Empty description
            content: "", // Empty content
            category: .general,
            variables: []
        )
        
        let validation = PromptTemplates.validateTemplate(invalidTemplate)
        XCTAssertFalse(validation.isValid)
        XCTAssertFalse(validation.errors.isEmpty)
    }
    
    func testPromptTemplateVariableConsistency() throws {
        let template = PromptTemplate(
            name: "Test Template",
            description: "A test template",
            content: "Hello [NAME], your [CONDITION] claim status is [STATUS]",
            category: .claimStatus,
            variables: ["NAME", "CONDITION"] // Missing STATUS variable
        )
        
        let validation = PromptTemplates.validateTemplate(template)
        XCTAssertTrue(validation.isValid) // Should be valid but with warnings
        XCTAssertFalse(validation.warnings.isEmpty)
    }
    
    func testPromptTemplateProcessing() throws {
        let template = PromptTemplate(
            name: "Test Template",
            description: "A test template",
            content: "Hello [NAME], your [CONDITION] claim status is [STATUS]",
            category: .claimStatus,
            variables: ["NAME", "CONDITION", "STATUS"]
        )
        
        let variables = [
            "NAME": "John Doe",
            "CONDITION": "PTSD",
            "STATUS": "Under Review"
        ]
        
        let processedContent = PromptTemplates.processTemplate(template, variables: variables)
        
        XCTAssertTrue(processedContent.contains("John Doe"))
        XCTAssertTrue(processedContent.contains("PTSD"))
        XCTAssertTrue(processedContent.contains("Under Review"))
        XCTAssertFalse(processedContent.contains("[NAME]"))
        XCTAssertFalse(processedContent.contains("[CONDITION]"))
        XCTAssertFalse(processedContent.contains("[STATUS]"))
    }
    
    // MARK: - Chat Message Tests
    
    func testChatMessageCreation() throws {
        let message = ChatMessage(
            role: .user,
            content: "Test message"
        )
        
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content, "Test message")
        XCTAssertFalse(message.isDeidentified)
        XCTAssertNil(message.deidentifiedContent)
    }
    
    func testChatMessageDeidentification() throws {
        let message = ChatMessage(
            role: .user,
            content: "My SSN is 123-45-6789"
        )
        
        message.isDeidentified = true
        message.deidentifiedContent = "My SSN is [SSN-REDACTED]"
        
        XCTAssertTrue(message.isDeidentified)
        XCTAssertEqual(message.deidentifiedContent, "My SSN is [SSN-REDACTED]")
        XCTAssertEqual(message.displayContent, "My SSN is [SSN-REDACTED]")
    }
    
    func testChatSessionCreation() throws {
        let session = ChatSession(title: "Test Session")
        
        XCTAssertEqual(session.title, "Test Session")
        XCTAssertEqual(session.messageCount, 0)
        XCTAssertFalse(session.isPinned)
        XCTAssertNil(session.associatedVeteran)
        XCTAssertNil(session.promptTemplate)
    }
    
    func testChatSessionUpdate() throws {
        let session = ChatSession(title: "Test Session")
        
        // Simulate adding messages
        session.messages.append(ChatMessage(role: .user, content: "Hello"))
        session.messages.append(ChatMessage(role: .assistant, content: "Hi there"))
        
        session.updateLastMessage()
        
        XCTAssertEqual(session.messageCount, 2)
        XCTAssertNotNil(session.lastMessageAt)
    }
    
    // MARK: - Document Tests
    
    func testChatDocumentCreation() throws {
        let document = ChatDocument(
            fileName: "test.pdf",
            fileType: "pdf",
            fileSize: 1024,
            encryptedFilePath: "/path/to/encrypted/file"
        )
        
        XCTAssertEqual(document.fileName, "test.pdf")
        XCTAssertEqual(document.fileType, "pdf")
        XCTAssertEqual(document.fileSize, 1024)
        XCTAssertEqual(document.encryptedFilePath, "/path/to/encrypted/file")
        XCTAssertFalse(document.isProcessed)
        XCTAssertNil(document.processingError)
    }
    
    func testChatDocumentFileSizeString() throws {
        let document = ChatDocument(
            fileName: "test.pdf",
            fileType: "pdf",
            fileSize: 1024,
            encryptedFilePath: "/path/to/encrypted/file"
        )
        
        XCTAssertEqual(document.fileSizeString, "1 KB")
    }
    
    func testChatDocumentReadyStatus() throws {
        let document = ChatDocument(
            fileName: "test.pdf",
            fileType: "pdf",
            fileSize: 1024,
            encryptedFilePath: "/path/to/encrypted/file"
        )
        
        XCTAssertFalse(document.isReady)
        
        document.isProcessed = true
        XCTAssertTrue(document.isReady)
        
        document.processingError = "Some error"
        XCTAssertFalse(document.isReady)
    }
    
    // MARK: - Performance Tests
    
    func testDeidentificationPerformance() throws {
        let largeText = String(repeating: "My SSN is 123-45-6789 and my name is John Smith. ", count: 1000)
        
        measure {
            _ = deidentificationService.deidentifyText(largeText)
        }
    }
    
    func testEncryptionPerformance() throws {
        let largeMessage = String(repeating: "This is a test message. ", count: 1000)
        
        measure {
            do {
                let encrypted = try encryptionService.encryptMessage(largeMessage)
                _ = try encryptionService.decryptMessage(encrypted)
            } catch {
                XCTFail("Encryption/decryption failed: \(error)")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testFullDeidentificationWorkflow() throws {
        let originalText = """
        Veteran John Smith (SSN: 123-45-6789, DOB: 01/15/1980)
        Contact: john.smith@email.com, Phone: (555) 123-4567
        VA File Number: 123456789
        Address: 123 Main St, Anytown, ST 12345
        """
        
        let deidentifiedContent = deidentificationService.deidentifyText(originalText)
        
        // Verify all PHI types are redacted
        let redactionTypes = Set(deidentifiedContent.redactedItems.map { $0.type })
        let expectedTypes: Set<RedactionType> = [.name, .ssn, .dob, .email, .phone, .veteranId, .address]
        
        XCTAssertTrue(expectedTypes.isSubset(of: redactionTypes))
        
        // Verify original text is preserved
        XCTAssertEqual(deidentifiedContent.originalText, originalText)
        
        // Verify de-identified text doesn't contain original PHI
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("John Smith"))
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("123-45-6789"))
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("01/15/1980"))
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("john.smith@email.com"))
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("(555) 123-4567"))
        XCTAssertFalse(deidentifiedContent.deidentifiedText.contains("123456789"))
    }
    
    func testEncryptionWithDeidentification() throws {
        let originalMessage = "My SSN is 123-45-6789 and my name is John Smith"
        
        // First de-identify
        let deidentifiedContent = deidentificationService.deidentifyText(originalMessage)
        
        // Then encrypt the de-identified content
        let encryptedMessage = try encryptionService.encryptMessage(deidentifiedContent.deidentifiedText)
        let decryptedMessage = try encryptionService.decryptMessage(encryptedMessage)
        
        XCTAssertEqual(decryptedMessage, deidentifiedContent.deidentifiedText)
        XCTAssertTrue(decryptedMessage.contains("[SSN-REDACTED]"))
        XCTAssertTrue(decryptedMessage.contains("[NAME]"))
        XCTAssertFalse(decryptedMessage.contains("123-45-6789"))
        XCTAssertFalse(decryptedMessage.contains("John Smith"))
    }
}

// MARK: - Test Extensions

extension CopilotTests {
    
    /// Helper method to create test data
    func createTestChatSession() -> ChatSession {
        let session = ChatSession(title: "Test Session")
        
        let userMessage = ChatMessage(role: .user, content: "Hello, I need help with my VA claim")
        let assistantMessage = ChatMessage(role: .assistant, content: "I'd be happy to help you with your VA claim")
        
        session.messages.append(userMessage)
        session.messages.append(assistantMessage)
        session.updateLastMessage()
        
        return session
    }
    
    /// Helper method to create test prompt template
    func createTestPromptTemplate() -> PromptTemplate {
        return PromptTemplate(
            name: "Test Template",
            description: "A test template for unit testing",
            content: "Hello [NAME], your [CONDITION] claim status is [STATUS]",
            category: .claimStatus,
            variables: ["NAME", "CONDITION", "STATUS"]
        )
    }
    
    /// Helper method to create test document
    func createTestDocument() -> ChatDocument {
        return ChatDocument(
            fileName: "test.pdf",
            fileType: "pdf",
            fileSize: 1024,
            encryptedFilePath: "/test/path/encrypted"
        )
    }
}
