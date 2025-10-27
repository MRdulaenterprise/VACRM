//
//  ActivityLogger.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData

class ActivityLogger {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Veteran Activities
    
    func logVeteranCreated(veteran: Veteran, performedBy: String) {
        let activity = ClaimActivity(
            activityType: .note,
            claimDescription: "Veteran profile created for \(veteran.fullName)",
            performedBy: performedBy,
            notes: "New veteran added to the system"
        )
        
        // Associate with the first claim if available, otherwise create a general activity
        if let firstClaim = veteran.claims.first {
            activity.claim = firstClaim
            firstClaim.activities.append(activity)
        }
        
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging veteran creation: \(error)")
        }
    }
    
    func logVeteranUpdated(veteran: Veteran, performedBy: String, changes: [String]) {
        let activity = ClaimActivity(
            activityType: .note,
            claimDescription: "Veteran profile updated for \(veteran.fullName)",
            performedBy: performedBy,
            notes: "Changes made: \(changes.joined(separator: ", "))"
        )
        
        // Associate with the first claim if available
        if let firstClaim = veteran.claims.first {
            activity.claim = firstClaim
            firstClaim.activities.append(activity)
        }
        
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging veteran update: \(error)")
        }
    }
    
    // MARK: - Claim Activities
    
    func logClaimCreated(claim: Claim, performedBy: String) {
        let activity = ClaimActivity(
            activityType: .note,
            claimDescription: "New claim created: \(claim.claimNumber)",
            performedBy: performedBy,
            notes: "Claim type: \(claim.claimType), Status: \(claim.claimStatus)"
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging claim creation: \(error)")
        }
    }
    
    func logClaimStatusChanged(claim: Claim, oldStatus: String, newStatus: String, performedBy: String) {
        let activity = ClaimActivity(
            activityType: .statusChange,
            claimDescription: "Claim status changed from \(oldStatus) to \(newStatus)",
            performedBy: performedBy,
            notes: "Status update for claim \(claim.claimNumber)"
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging status change: \(error)")
        }
    }
    
    func logClaimUpdated(claim: Claim, performedBy: String, changes: [String]) {
        let activity = ClaimActivity(
            activityType: .note,
            claimDescription: "Claim \(claim.claimNumber) updated",
            performedBy: performedBy,
            notes: "Changes made: \(changes.joined(separator: ", "))"
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging claim update: \(error)")
        }
    }
    
    // MARK: - Document Activities
    
    func logDocumentUploaded(document: Document, performedBy: String) {
        let activity = ClaimActivity(
            activityType: .documentUpload,
            claimDescription: "Document uploaded: \(document.fileName)",
            performedBy: performedBy,
            notes: "Document type: \(document.documentType.rawValue), Size: \(formatFileSize(document.fileSize))"
        )
        
        if let claim = document.claim {
            activity.claim = claim
            claim.activities.append(activity)
        }
        
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging document upload: \(error)")
        }
    }
    
    // MARK: - Communication Activities
    
    func logPhoneCall(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .phoneCall,
            claimDescription: "Phone call with veteran",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging phone call: \(error)")
        }
    }
    
    func logEmail(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .email,
            claimDescription: "Email sent to veteran",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging email: \(error)")
        }
    }
    
    func logMeeting(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .meeting,
            claimDescription: "Meeting with veteran",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging meeting: \(error)")
        }
    }
    
    // MARK: - Medical Activities
    
    func logCAndPExam(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .cAndPExam,
            claimDescription: "C&P Exam scheduled/completed",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging C&P exam: \(error)")
        }
    }
    
    func logNexusLetter(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .nexusLetter,
            claimDescription: "Nexus letter obtained/requested",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging nexus letter: \(error)")
        }
    }
    
    // MARK: - Appeal Activities
    
    func logAppeal(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .appeal,
            claimDescription: "Appeal filed/processed",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging appeal: \(error)")
        }
    }
    
    func logHearing(claim: Claim, performedBy: String, notes: String = "") {
        let activity = ClaimActivity(
            activityType: .hearing,
            claimDescription: "Hearing scheduled/completed",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging hearing: \(error)")
        }
    }
    
    // MARK: - General Activities
    
    func logNote(claim: Claim, performedBy: String, notes: String) {
        let activity = ClaimActivity(
            activityType: .note,
            claimDescription: "Note added",
            performedBy: performedBy,
            notes: notes
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging note: \(error)")
        }
    }
    
    // MARK: - Email Notifications
    
    func sendVeteranCreatedEmail(veteran: Veteran) async {
        guard EmailSettingsManager.shared.shouldSendNotification(for: .teamAlert) else { return }
        
        let template = EmailTemplate.newVeteranAlert
        let variables: [String: String] = [
            "veteranName": veteran.fullName,
            "veteranId": veteran.veteranId,
            "serviceBranch": veteran.serviceBranch,
            "emailPrimary": veteran.emailPrimary,
            "addedBy": "System",
            "dateAdded": Date().formatted(date: .abbreviated, time: .shortened)
        ]
        
        do {
            let messageId = try await PaulBoxEmailService.shared.sendTemplateEmail(
                template: template,
                to: ["team@veteransclaims.org"], // Team notification email
                variables: variables
            )
            
            // Log the email
            await logEmailSent(
                messageId: messageId,
                template: template,
                recipients: ["team@veteransclaims.org"],
                subject: template.subject,
                veteran: veteran
            )
            
        } catch {
            print("Error sending veteran created email: \(error)")
        }
    }
    
    func sendActivityAlertEmail(activity: ClaimActivity, veteran: Veteran) async {
        guard EmailSettingsManager.shared.shouldSendNotification(for: .activityLogged) else { return }
        
        let template = EmailTemplate.urgentActivityAlert
        let variables: [String: String] = [
            "veteranName": veteran.fullName,
            "veteranId": veteran.veteranId,
            "activityType": activity.activityType.rawValue,
            "activityDescription": activity.claimDescription,
            "activityDate": activity.date.formatted(date: .abbreviated, time: .shortened),
            "performedBy": activity.performedBy,
            "priority": "High",
            "activityNotes": activity.notes
        ]
        
        do {
            let messageId = try await PaulBoxEmailService.shared.sendTemplateEmail(
                template: template,
                to: ["team@veteransclaims.org"], // Team notification email
                variables: variables
            )
            
            // Log the email
            await logEmailSent(
                messageId: messageId,
                template: template,
                recipients: ["team@veteransclaims.org"],
                subject: template.subject,
                veteran: veteran,
                claim: activity.claim
            )
            
        } catch {
            print("Error sending activity alert email: \(error)")
        }
    }
    
    func sendClaimCreatedEmail(claim: Claim, veteran: Veteran) async {
        guard EmailSettingsManager.shared.shouldSendNotification(for: .claimCreated) else { return }
        
        let template = EmailTemplate.claimCreated
        let variables: [String: String] = [
            "veteranName": veteran.fullName,
            "claimNumber": claim.claimNumber,
            "claimType": claim.claimType,
            "primaryCondition": claim.primaryCondition,
            "dateCreated": claim.claimFiledDate.formatted(date: .abbreviated, time: .shortened)
        ]
        
        do {
            let messageId = try await PaulBoxEmailService.shared.sendTemplateEmail(
                template: template,
                to: [veteran.emailPrimary],
                variables: variables
            )
            
            // Log the email
            await logEmailSent(
                messageId: messageId,
                template: template,
                recipients: [veteran.emailPrimary],
                subject: template.subject,
                veteran: veteran,
                claim: claim
            )
            
        } catch {
            print("Error sending claim created email: \(error)")
        }
    }
    
    func sendClaimStatusUpdateEmail(claim: Claim, veteran: Veteran, previousStatus: ClaimStatus) async {
        guard EmailSettingsManager.shared.shouldSendNotification(for: .claimUpdated) else { return }
        
        let template = EmailTemplate.claimApproved
        let variables: [String: String] = [
            "veteranName": veteran.fullName,
            "claimNumber": claim.claimNumber,
            "previousStatus": previousStatus.rawValue,
            "newStatus": claim.claimStatus,
            "dateUpdated": Date().formatted(date: .abbreviated, time: .shortened),
            "statusMessage": getStatusMessage(for: ClaimStatus(rawValue: claim.claimStatus) ?? .new)
        ]
        
        do {
            let messageId = try await PaulBoxEmailService.shared.sendTemplateEmail(
                template: template,
                to: [veteran.emailPrimary],
                variables: variables
            )
            
            // Log the email
            await logEmailSent(
                messageId: messageId,
                template: template,
                recipients: [veteran.emailPrimary],
                subject: template.subject,
                veteran: veteran,
                claim: claim
            )
            
        } catch {
            print("Error sending claim status update email: \(error)")
        }
    }
    
    func sendDocumentUploadedEmail(document: Document, veteran: Veteran) async {
        guard EmailSettingsManager.shared.shouldSendNotification(for: .documentUploaded) else { return }
        
        let template = EmailTemplate.documentUploaded
        let variables: [String: String] = [
            "veteranName": veteran.fullName,
            "documentName": document.fileName,
            "documentType": document.documentType.rawValue,
            "uploadDate": document.uploadDate.formatted(date: .abbreviated, time: .shortened),
            "fileSize": formatFileSize(Int64(document.fileSize))
        ]
        
        do {
            let messageId = try await PaulBoxEmailService.shared.sendTemplateEmail(
                template: template,
                to: [veteran.emailPrimary],
                variables: variables
            )
            
            // Log the email
            await logEmailSent(
                messageId: messageId,
                template: template,
                recipients: [veteran.emailPrimary],
                subject: template.subject,
                veteran: veteran
            )
            
        } catch {
            print("Error sending document uploaded email: \(error)")
        }
    }
    
    // MARK: - Email Logging
    
    private func logEmailSent(
        messageId: String,
        template: EmailTemplate,
        recipients: [String],
        subject: String,
        veteran: Veteran? = nil,
        claim: Claim? = nil
    ) async {
        let emailLog = EmailLog(
            messageId: messageId,
            recipients: recipients,
            subject: subject,
            status: .sent,
            templateId: template.id,
            htmlBody: template.htmlBody,
            textBody: template.textBody,
            veteran: veteran,
            claim: claim
        )
        
        modelContext.insert(emailLog)
        
        do {
            try modelContext.save()
        } catch {
            print("Error logging email: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func getStatusMessage(for status: ClaimStatus) -> String {
        switch status {
        case .new:
            return "Your claim has been submitted and is now under review by the VA."
        case .inProgress:
            return "Your claim is currently being processed by the VA."
        case .underReview:
            return "Your claim is currently being reviewed by the VA. We will keep you updated on any developments."
        case .reviewOfEvidence:
            return "Your claim is in the review of evidence phase. The VA is examining your supporting documentation."
        case .preparationForDecision:
            return "Your claim is in the preparation for decision phase. A decision will be made soon."
        case .pendingDecisionApproval:
            return "Your claim decision is pending approval from the VA."
        case .pendingNotification:
            return "Your claim decision is pending notification to you."
        case .complete:
            return "Congratulations! Your claim has been completed. You will receive additional information about your benefits."
        case .closed:
            return "Your claim has been closed. If you have any questions, please contact us."
        case .appealed:
            return "Your claim appeal has been filed. We will continue to track its progress."
        case .denied:
            return "We have received a decision on your claim. Our team will review this with you and discuss next steps."
        case .approved:
            return "Congratulations! Your claim has been approved. You will receive additional information about your benefits."
        }
    }
}
