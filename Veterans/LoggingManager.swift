//
//  LoggingManager.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData
import SwiftUI

/// Centralized logging manager for HIPAA-compliant audit trails
/// Coordinates ActivityLogger (business activities) and CopilotAuditLogger (audit events)
class LoggingManager {
    
    // MARK: - Singleton
    static let shared = LoggingManager()
    
    // MARK: - Properties
    private let auditLogger = CopilotAuditLogger()
    private var activityLogger: ActivityLogger?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Setup
    func setupActivityLogger(modelContext: ModelContext) {
        self.activityLogger = ActivityLogger(modelContext: modelContext)
    }
    
    // MARK: - Helper Methods
    
    /// Ensures activityLogger is initialized, setting it up with modelContext if needed
    private func ensureActivityLogger(modelContext: ModelContext?) -> ActivityLogger? {
        if activityLogger == nil, let modelContext = modelContext {
            setupActivityLogger(modelContext: modelContext)
        }
        return activityLogger
    }
    
    // MARK: - Veteran Activities
    
    func logVeteranCreated(veteran: Veteran, performedBy: String, modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logVeteranCreated(veteran: veteran, performedBy: performedBy)
        
        // Send email notification
        Task {
            await logger.sendVeteranCreatedEmail(veteran: veteran)
        }
    }
    
    func logVeteranUpdated(veteran: Veteran, performedBy: String, changes: [String], modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logVeteranUpdated(veteran: veteran, performedBy: performedBy, changes: changes)
    }
    
    // MARK: - Claim Activities
    
    func logClaimCreated(claim: Claim, performedBy: String, modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logClaimCreated(claim: claim, performedBy: performedBy)
        
        // Send email notification
        if let veteran = claim.veteran {
            Task {
                await logger.sendClaimCreatedEmail(claim: claim, veteran: veteran)
            }
        }
    }
    
    func logClaimUpdated(claim: Claim, performedBy: String, changes: [String], modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logClaimUpdated(claim: claim, performedBy: performedBy, changes: changes)
    }
    
    func logClaimStatusChanged(claim: Claim, oldStatus: String, newStatus: String, performedBy: String, modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logClaimStatusChanged(claim: claim, oldStatus: oldStatus, newStatus: newStatus, performedBy: performedBy)
        
        // Send email notification
        if let veteran = claim.veteran {
            Task {
                await logger.sendClaimStatusUpdateEmail(
                    claim: claim,
                    veteran: veteran,
                    previousStatus: ClaimStatus(rawValue: oldStatus) ?? .new
                )
            }
        }
    }
    
    // MARK: - Document Activities
    
    func logDocumentUploaded(document: Document, performedBy: String, modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        
        logger.logDocumentUploaded(document: document, performedBy: performedBy)
        
        // Send email notification
        if let veteran = document.veteran {
            Task {
                await logger.sendDocumentUploadedEmail(document: document, veteran: veteran)
            }
        }
        
        // Audit log (HIPAA-compliant, no PHI)
        Task {
            await auditLogger.logDocumentUploaded(
                sessionId: UUID(), // Document uploads don't have session IDs
                documentId: document.id,
                fileName: document.fileName,
                fileSize: document.fileSize,
                fileType: document.fileType
            )
        }
    }
    
    // MARK: - Communication Activities
    
    func logPhoneCall(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logPhoneCall(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    func logEmail(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logEmail(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    func logMeeting(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logMeeting(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    // MARK: - Medical Activities
    
    func logCAndPExam(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logCAndPExam(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    func logNexusLetter(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logNexusLetter(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    // MARK: - Appeal Activities
    
    func logAppeal(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logAppeal(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    func logHearing(claim: Claim, performedBy: String, notes: String = "", modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logHearing(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    // MARK: - General Activities
    
    func logNote(claim: Claim, performedBy: String, notes: String, modelContext: ModelContext? = nil) {
        guard let logger = ensureActivityLogger(modelContext: modelContext) else { return }
        logger.logNote(claim: claim, performedBy: performedBy, notes: notes)
    }
    
    // MARK: - Copilot Audit Logging (HIPAA-Compliant)
    
    func logSessionCreated(sessionId: UUID, title: String, veteranId: String? = nil) {
        Task {
            await auditLogger.logSessionCreated(sessionId: sessionId, title: title, veteranId: veteranId)
        }
    }
    
    func logSessionDeleted(sessionId: UUID, messageCount: Int) {
        Task {
            await auditLogger.logSessionDeleted(sessionId: sessionId, messageCount: messageCount)
        }
    }
    
    func logSessionRenamed(sessionId: UUID, oldTitle: String, newTitle: String) {
        Task {
            await auditLogger.logSessionRenamed(sessionId: sessionId, oldTitle: oldTitle, newTitle: newTitle)
        }
    }
    
    func logMessageSent(sessionId: UUID, messageId: UUID, isDeidentified: Bool, tokenCount: Int) {
        Task {
            await auditLogger.logMessageSent(
                sessionId: sessionId,
                messageId: messageId,
                isDeidentified: isDeidentified,
                tokenCount: tokenCount
            )
        }
    }
    
    func logMessageReceived(sessionId: UUID, messageId: UUID, modelUsed: String, tokenCount: Int, processingTime: Double) {
        Task {
            await auditLogger.logMessageReceived(
                sessionId: sessionId,
                messageId: messageId,
                modelUsed: modelUsed,
                tokenCount: tokenCount,
                processingTime: processingTime
            )
        }
    }
    
    func logAPIRequest(model: String, messageCount: Int, temperature: Double, maxTokens: Int, streaming: Bool = false) {
        Task {
            await auditLogger.logAPIRequest(
                model: model,
                messageCount: messageCount,
                temperature: temperature,
                maxTokens: maxTokens,
                streaming: streaming
            )
        }
    }
    
    func logAPIResponse(model: String, tokenCount: Int, success: Bool, error: String? = nil) {
        Task {
            await auditLogger.logAPIResponse(
                model: model,
                tokenCount: tokenCount,
                success: success,
                error: error
            )
        }
    }
    
    func logDocumentProcessed(sessionId: UUID, documentId: UUID, success: Bool, extractedTextLength: Int, error: String? = nil) {
        Task { @MainActor in
            await auditLogger.logDocumentProcessed(
                sessionId: sessionId,
                documentId: documentId,
                success: success,
                extractedTextLength: extractedTextLength,
                error: error
            )
        }
    }
    
    func logDeidentificationPerformed(sessionId: UUID?, originalTextLength: Int, redactedItems: [RedactedItem]) {
        Task {
            await auditLogger.logDeidentificationPerformed(
                sessionId: sessionId,
                originalTextLength: originalTextLength,
                redactedItems: redactedItems
            )
        }
    }
    
    func logPDFExported(sessionId: UUID, fileName: String, messageCount: Int, veteranId: String? = nil) {
        Task {
            await auditLogger.logPDFExported(
                sessionId: sessionId,
                fileName: fileName,
                messageCount: messageCount,
                veteranId: veteranId
            )
        }
    }
    
    func logSecurityEvent(eventType: SecurityEventType, details: [String: String]) {
        Task {
            await auditLogger.logSecurityEvent(eventType: eventType, details: details)
        }
    }
    
    func logAPIKeyStored() {
        Task {
            await auditLogger.logAPIKeyStored()
        }
    }
    
    // MARK: - Data Export/Import Logging (HIPAA-Compliant)
    
    func logDataExported(veteranCount: Int, exportedBy: String, modelContext: ModelContext? = nil) {
        guard let context = modelContext else { 
            // If no context provided, still log to audit (HIPAA requirement)
            Task {
                await auditLogger.logSecurityEvent(
                    eventType: .dataExported,
                    details: [
                        "veteranCount": "\(veteranCount)",
                        "exportedBy": exportedBy,
                        "timestamp": ISO8601DateFormatter().string(from: Date())
                    ]
                )
            }
            return 
        }
        
        // Log as activity
        let activity = ClaimActivity(
            activityType: .other,
            claimDescription: "Data export: \(veteranCount) veteran(s) exported",
            performedBy: exportedBy,
            notes: "Export operation completed"
        )
        context.insert(activity)
        
        do {
            try context.save()
        } catch {
            print("Error logging data export: \(error)")
        }
        
        // Audit log (HIPAA-compliant)
        Task {
            await auditLogger.logSecurityEvent(
                eventType: .dataExported,
                details: [
                    "veteranCount": "\(veteranCount)",
                    "exportedBy": exportedBy,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        }
    }
    
    func logDataImported(veteranCount: Int, claimCount: Int, documentCount: Int, importedBy: String, modelContext: ModelContext? = nil) {
        guard let context = modelContext else {
            // If no context provided, still log to audit (HIPAA requirement)
            Task {
                await auditLogger.logSecurityEvent(
                    eventType: .dataImported,
                    details: [
                        "veteranCount": "\(veteranCount)",
                        "claimCount": "\(claimCount)",
                        "documentCount": "\(documentCount)",
                        "importedBy": importedBy,
                        "timestamp": ISO8601DateFormatter().string(from: Date())
                    ]
                )
            }
            return
        }
        
        // Log as activity
        let activity = ClaimActivity(
            activityType: .other,
            claimDescription: "Data import: \(veteranCount) veteran(s), \(claimCount) claim(s), \(documentCount) document(s) imported",
            performedBy: importedBy,
            notes: "Import operation completed"
        )
        context.insert(activity)
        
        do {
            try context.save()
        } catch {
            print("Error logging data import: \(error)")
        }
        
        // Audit log (HIPAA-compliant)
        Task {
            await auditLogger.logSecurityEvent(
                eventType: .dataImported,
                details: [
                    "veteranCount": "\(veteranCount)",
                    "claimCount": "\(claimCount)",
                    "documentCount": "\(documentCount)",
                    "importedBy": importedBy,
                    "timestamp": ISO8601DateFormatter().string(from: Date())
                ]
            )
        }
    }
}

