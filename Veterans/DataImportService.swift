//
//  DataImportService.swift
//  Veterans
//
//  Created for Import/Export Feature
//

import Foundation
import SwiftData

enum ImportError: Error, LocalizedError {
    case invalidFileFormat
    case decryptionFailed
    case zipExtractionFailed
    case jsonParsingFailed
    case invalidDataStructure
    case importFailed(String)
    case documentRestoreFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFileFormat:
            return "Invalid import file format."
        case .decryptionFailed:
            return "Failed to decrypt import file. Incorrect password or corrupted file."
        case .zipExtractionFailed:
            return "Failed to extract ZIP archive."
        case .jsonParsingFailed:
            return "Failed to parse JSON data."
        case .invalidDataStructure:
            return "Invalid data structure in import file."
        case .importFailed(let reason):
            return "Import failed: \(reason)"
        case .documentRestoreFailed(let reason):
            return "Failed to restore document: \(reason)"
        }
    }
}

enum ImportConflictResolution {
    case skip
    case replace
    case merge
}

struct ImportResult {
    let veteransImported: Int
    let claimsImported: Int
    let documentsImported: Int
    let activitiesImported: Int
    let medicalConditionsImported: Int
    let conflicts: [ImportConflict]
    let errors: [String]
}

struct ImportConflict {
    let type: String // "veteran", "claim", etc.
    let id: UUID
    let existingRecord: String
    let importedRecord: String
}

class DataImportService: ObservableObject {
    @Published var importProgress: Double = 0.0
    @Published var isImporting: Bool = false
    @Published var currentStep: String = ""
    
    private let fileManager = FileManager.default
    
    // MARK: - Main Import Function
    
    /// Import data from encrypted ZIP file
    func importData(
        from fileURL: URL,
        password: String,
        conflictResolution: ImportConflictResolution,
        context: ModelContext
    ) async throws -> ImportResult {
        await MainActor.run {
            isImporting = true
            importProgress = 0.0
            currentStep = "Validating import file..."
        }
        
        // Validate file
        guard fileURL.pathExtension == "zip" || fileURL.pathExtension == "encrypted" else {
            throw ImportError.invalidFileFormat
        }
        
        await MainActor.run {
            importProgress = 0.1
            currentStep = "Decrypting file..."
        }
        
        // Decrypt file
        let decryptedURL = try decryptImportFile(fileURL)
        defer {
            try? fileManager.removeItem(at: decryptedURL)
        }
        
        await MainActor.run {
            importProgress = 0.2
            currentStep = "Extracting archive..."
        }
        
        // Extract ZIP
        let extractDir = try extractZIPArchive(decryptedURL, password: password)
        defer {
            try? fileManager.removeItem(at: extractDir)
        }
        
        await MainActor.run {
            importProgress = 0.3
            currentStep = "Parsing data..."
        }
        
        // Parse JSON
        let exportData = try parseExportData(from: extractDir)
        
        await MainActor.run {
            importProgress = 0.4
            currentStep = "Importing data..."
        }
        
        // Import data
        let result = try await importExportData(
            exportData,
            conflictResolution: conflictResolution,
            context: context,
            extractDir: extractDir
        ) { progress, step in
            await MainActor.run {
                self.importProgress = 0.4 + (progress * 0.6)
                self.currentStep = step
            }
        }
        
        await MainActor.run {
            importProgress = 1.0
            currentStep = "Import complete!"
            isImporting = false
        }
        
        return result
    }
    
    // MARK: - Helper Functions
    
    private func decryptImportFile(_ fileURL: URL) throws -> URL {
        let encryptedData = try Data(contentsOf: fileURL)
        
        print("📦 Import file size: \(encryptedData.count) bytes")
        
        // Try to decrypt
        do {
            let decryptedData = try CopilotEncryption.decrypt(encryptedData: encryptedData)
            print("✅ File decrypted successfully: \(decryptedData.count) bytes")
            
            let decryptedURL = fileManager.temporaryDirectory
                .appendingPathComponent("import_\(UUID().uuidString).zip")
            try decryptedData.write(to: decryptedURL)
            
            // Verify the decrypted file is a valid ZIP
            let fileHandle = try FileHandle(forReadingFrom: decryptedURL)
            defer { try? fileHandle.close() }
            let magicBytes = try fileHandle.read(upToCount: 2)
            if let bytes = magicBytes, bytes.count >= 2 {
                let isZIP = bytes[0] == 0x50 && bytes[1] == 0x4B
                if !isZIP {
                    print("⚠️ Warning: Decrypted file doesn't appear to be a ZIP (magic bytes: \(bytes.map { String(format: "%02X", $0) }.joined(separator: " ")))")
                }
            }
            
            return decryptedURL
        } catch {
            // If decryption fails, check if it's already a ZIP file
            let fileHandle = try? FileHandle(forReadingFrom: fileURL)
            if let handle = fileHandle {
                defer { try? handle.close() }
                let magicBytes = try? handle.read(upToCount: 2)
                if let bytes = magicBytes, bytes.count >= 2, bytes[0] == 0x50 && bytes[1] == 0x4B {
                    // It's already a ZIP file (not encrypted)
                    print("ℹ️ File appears to be unencrypted ZIP, using directly")
                    return fileURL
                }
            }
            
            print("❌ Decryption failed: \(error.localizedDescription)")
            throw ImportError.decryptionFailed
        }
    }
    
    private func extractZIPArchive(_ zipURL: URL, password: String) throws -> URL {
        let extractDir = fileManager.temporaryDirectory
            .appendingPathComponent("import_extract_\(UUID().uuidString)")
        
        if fileManager.fileExists(atPath: extractDir.path) {
            try fileManager.removeItem(at: extractDir)
        }
        try fileManager.createDirectory(at: extractDir, withIntermediateDirectories: true)
        
        // Verify ZIP file exists and is readable
        guard fileManager.fileExists(atPath: zipURL.path) else {
            print("❌ ZIP file not found at: \(zipURL.path)")
            throw ImportError.zipExtractionFailed
        }
        
        // Verify file is actually a ZIP by checking magic bytes
        let fileHandle = try FileHandle(forReadingFrom: zipURL)
        defer { try? fileHandle.close() }
        let magicBytes = try fileHandle.read(upToCount: 4)
        guard let bytes = magicBytes, bytes.count >= 2 else {
            print("❌ File is too small or unreadable")
            throw ImportError.zipExtractionFailed
        }
        
        // ZIP files start with PK (0x50 0x4B)
        let isZIP = bytes[0] == 0x50 && bytes[1] == 0x4B
        guard isZIP else {
            print("❌ File is not a valid ZIP archive (magic bytes: \(bytes.map { String(format: "%02X", $0) }.joined(separator: " ")))")
            throw ImportError.zipExtractionFailed
        }
        
        // Extract ZIP (after decryption, it's a regular ZIP without password)
        // Note: The export creates a ZIP and then encrypts the whole file with CopilotEncryption
        // So after decryption, we have a regular ZIP file (not password-protected)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        
        // Use absolute paths to avoid any issues
        let zipPath = zipURL.path
        let extractPath = extractDir.path
        
        process.arguments = [
            "-q", // Quiet mode
            "-o", // Overwrite files without prompting
            zipPath, // Input ZIP file (absolute path)
            "-d", extractPath // Destination directory (absolute path)
        ]
        
        // Don't set currentDirectoryURL - use absolute paths instead
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            print("📦 Starting ZIP extraction...")
            print("   ZIP file: \(zipPath)")
            print("   Extract to: \(extractPath)")
            
            try process.run()
            process.waitUntilExit()
            
            // Read output/error after process completes
            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            if let outputString = String(data: outputData, encoding: .utf8), !outputString.isEmpty {
                print("📦 Unzip output: \(outputString)")
            }
            
            // Check termination status
            guard process.terminationStatus == 0 else {
                print("❌ Unzip failed with exit status: \(process.terminationStatus)")
                if let errorString = String(data: outputData, encoding: .utf8), !errorString.isEmpty {
                    print("❌ Error details: \(errorString)")
                }
                
                // Verify ZIP file is readable
                if !fileManager.isReadableFile(atPath: zipPath) {
                    print("❌ ZIP file is not readable")
                }
                
                // Check file size
                if let attributes = try? fileManager.attributesOfItem(atPath: zipPath),
                   let size = attributes[.size] as? Int64 {
                    print("📊 ZIP file size: \(size) bytes")
                    if size == 0 {
                        print("❌ ZIP file is empty!")
                    }
                }
                
                throw ImportError.zipExtractionFailed
            }
            
            print("✅ Unzip command completed successfully")
            
            // Verify extraction was successful by checking for expected files
            let dataURL = extractDir.appendingPathComponent("data.json")
            let metadataURL = extractDir.appendingPathComponent("export_metadata.json")
            
            // Check if files exist directly in extractDir
            if fileManager.fileExists(atPath: dataURL.path) || fileManager.fileExists(atPath: metadataURL.path) {
                print("✅ ZIP extracted successfully to: \(extractDir.path)")
                return extractDir
            }
            
            // Check if files are in a subdirectory (sometimes ZIPs contain a root folder)
            if let contents = try? fileManager.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
                for item in contents {
                    // Check if this item is a directory
                    let resourceValues = try? item.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues?.isDirectory == true {
                        let subDataURL = item.appendingPathComponent("data.json")
                        let subMetadataURL = item.appendingPathComponent("export_metadata.json")
                        if fileManager.fileExists(atPath: subDataURL.path) || fileManager.fileExists(atPath: subMetadataURL.path) {
                            print("✅ ZIP extracted successfully to subdirectory: \(item.path)")
                            return item
                        }
                    } else {
                        // Check if it's a file we're looking for
                        if item.lastPathComponent == "data.json" || item.lastPathComponent == "export_metadata.json" {
                            print("✅ ZIP extracted successfully to: \(extractDir.path)")
                            return extractDir
                        }
                    }
                }
            }
            
            // If we get here, extraction didn't produce expected files
            print("❌ ZIP extraction completed but expected files not found")
            print("📁 Contents of extract directory:")
            if let contents = try? fileManager.contentsOfDirectory(at: extractDir, includingPropertiesForKeys: nil, options: []) {
                for item in contents {
                    print("   - \(item.lastPathComponent)")
                }
            }
            throw ImportError.zipExtractionFailed
        } catch {
            print("❌ ZIP extraction failed: \(error.localizedDescription)")
            print("❌ ZIP file path: \(zipURL.path)")
            print("❌ Extract directory: \(extractDir.path)")
            throw ImportError.zipExtractionFailed
        }
    }
    
    private func parseExportData(from directory: URL) throws -> ExportData {
        let jsonURL = directory.appendingPathComponent("data.json")
        
        guard fileManager.fileExists(atPath: jsonURL.path) else {
            throw ImportError.invalidDataStructure
        }
        
        let jsonData = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(ExportData.self, from: jsonData)
        } catch {
            print("JSON parsing error: \(error)")
            throw ImportError.jsonParsingFailed
        }
    }
    
    private func importExportData(
        _ exportData: ExportData,
        conflictResolution: ImportConflictResolution,
        context: ModelContext,
        extractDir: URL,
        progress: @escaping (Double, String) async -> Void
    ) async throws -> ImportResult {
        var conflicts: [ImportConflict] = []
        var errors: [String] = []
        var importedCounts = (
            veterans: 0,
            claims: 0,
            documents: 0,
            activities: 0,
            medicalConditions: 0
        )
        
        // Import categories first (no dependencies)
        await progress(0.1, "Importing categories...")
        var categoryMapping: [UUID: MedicalConditionCategory] = [:]
        for exportedCategory in exportData.medicalConditionCategories {
            await MainActor.run {
                let category = MedicalConditionCategory(
                    name: exportedCategory.name,
                    description: exportedCategory.conditionDescription,
                    color: exportedCategory.color,
                    isActive: exportedCategory.isActive
                )
                context.insert(category)
                categoryMapping[exportedCategory.id] = category
            }
        }
        
        // Import veterans
        await progress(0.2, "Importing veterans...")
        var veteranMapping: [UUID: Veteran] = [:]
        for exportedVeteran in exportData.veterans {
            await MainActor.run {
                // Check for conflicts
                let existingDescriptor = FetchDescriptor<Veteran>(
                    predicate: #Predicate { $0.id == exportedVeteran.id }
                )
                let existing = try? context.fetch(existingDescriptor).first
                
                if let existing = existing {
                    switch conflictResolution {
                    case .skip:
                        conflicts.append(ImportConflict(
                            type: "veteran",
                            id: exportedVeteran.id,
                            existingRecord: existing.fullName,
                            importedRecord: "\(exportedVeteran.firstName) \(exportedVeteran.lastName)"
                        ))
                        return
                    case .replace:
                        context.delete(existing)
                        fallthrough
                    case .merge:
                        // For merge, update existing record
                        updateVeteran(existing, from: exportedVeteran)
                        veteranMapping[exportedVeteran.id] = existing
                        importedCounts.veterans += 1
                        return
                    }
                }
                
                // Create new veteran
                let veteran = createVeteran(from: exportedVeteran)
                veteran.id = exportedVeteran.id // Preserve UUID
                context.insert(veteran)
                veteranMapping[exportedVeteran.id] = veteran
                importedCounts.veterans += 1
            }
        }
        
        // Import claims
        await progress(0.4, "Importing claims...")
        var claimMapping: [UUID: Claim] = [:]
        for exportedClaim in exportData.claims {
            await MainActor.run {
                let existingDescriptor = FetchDescriptor<Claim>(
                    predicate: #Predicate { $0.id == exportedClaim.id }
                )
                let existing = try? context.fetch(existingDescriptor).first
                
                if let existing = existing {
                    switch conflictResolution {
                    case .skip:
                        conflicts.append(ImportConflict(
                            type: "claim",
                            id: exportedClaim.id,
                            existingRecord: existing.claimNumber,
                            importedRecord: exportedClaim.claimNumber
                        ))
                        return
                    case .replace:
                        context.delete(existing)
                        fallthrough
                    case .merge:
                        updateClaim(existing, from: exportedClaim, veteranMapping: veteranMapping)
                        claimMapping[exportedClaim.id] = existing
                        importedCounts.claims += 1
                        return
                    }
                }
                
                let claim = createClaim(from: exportedClaim, veteranMapping: veteranMapping)
                context.insert(claim)
                claimMapping[exportedClaim.id] = claim
                importedCounts.claims += 1
            }
        }
        
        // Import medical conditions
        await progress(0.5, "Importing medical conditions...")
        var conditionMapping: [UUID: MedicalCondition] = [:]
        for exportedCondition in exportData.medicalConditions {
            await MainActor.run {
                let condition = createMedicalCondition(
                    from: exportedCondition,
                    claimMapping: claimMapping,
                    categoryMapping: categoryMapping
                )
                condition.id = exportedCondition.id // Preserve UUID
                context.insert(condition)
                conditionMapping[exportedCondition.id] = condition
                importedCounts.medicalConditions += 1
            }
        }
        
        // Import condition relationships
        await progress(0.6, "Importing condition relationships...")
        for exportedRelationship in exportData.conditionRelationships {
            await MainActor.run {
                let relationship = createConditionRelationship(
                    from: exportedRelationship,
                    conditionMapping: conditionMapping
                )
                context.insert(relationship)
            }
        }
        
        // Import activities
        await progress(0.7, "Importing activities...")
        for exportedActivity in exportData.activities {
            await MainActor.run {
                let activity = createClaimActivity(
                    from: exportedActivity,
                    claimMapping: claimMapping
                )
                context.insert(activity)
                importedCounts.activities += 1
            }
        }
        
        // Import documents and restore files
        await progress(0.8, "Importing documents...")
        let documentsDir = extractDir.appendingPathComponent("documents", isDirectory: true)
        for exportedDocument in exportData.documents {
            do {
                let document = try await createDocument(
                    from: exportedDocument,
                    veteranMapping: veteranMapping,
                    claimMapping: claimMapping,
                    sourceDir: documentsDir
                )
                await MainActor.run {
                    context.insert(document)
                    importedCounts.documents += 1
                }
            } catch {
                errors.append("Failed to import document \(exportedDocument.fileName): \(error.localizedDescription)")
            }
        }
        
        // Save context
        await progress(0.9, "Saving changes...")
        try await MainActor.run {
            try context.save()
        }
        
        return ImportResult(
            veteransImported: importedCounts.veterans,
            claimsImported: importedCounts.claims,
            documentsImported: importedCounts.documents,
            activitiesImported: importedCounts.activities,
            medicalConditionsImported: importedCounts.medicalConditions,
            conflicts: conflicts,
            errors: errors
        )
    }
    
    // MARK: - Model Creation Helpers
    
    private func createVeteran(from exported: ExportedVeteran) -> Veteran {
        return Veteran(
            veteranId: exported.veteranId,
            ssnLastFour: exported.ssnLastFour,
            firstName: exported.firstName,
            middleName: exported.middleName,
            lastName: exported.lastName,
            suffix: exported.suffix,
            preferredName: exported.preferredName,
            dateOfBirth: exported.dateOfBirth,
            gender: exported.gender,
            maritalStatus: exported.maritalStatus,
            emailPrimary: exported.emailPrimary,
            emailSecondary: exported.emailSecondary,
            phonePrimary: exported.phonePrimary,
            phoneSecondary: exported.phoneSecondary,
            phoneType: exported.phoneType,
            addressStreet: exported.addressStreet,
            addressCity: exported.addressCity,
            addressState: exported.addressState,
            addressZip: exported.addressZip,
            county: exported.county,
            mailingAddressDifferent: exported.mailingAddressDifferent,
            homelessStatus: exported.homelessStatus,
            preferredContactMethod: exported.preferredContactMethod,
            preferredContactTime: exported.preferredContactTime,
            languagePrimary: exported.languagePrimary,
            interpreterNeeded: exported.interpreterNeeded,
            serviceBranch: exported.serviceBranch,
            serviceComponent: exported.serviceComponent,
            serviceStartDate: exported.serviceStartDate,
            serviceEndDate: exported.serviceEndDate,
            yearsOfService: exported.yearsOfService,
            dischargeDate: exported.dischargeDate,
            dischargeStatus: exported.dischargeStatus,
            dischargeUpgradeSought: exported.dischargeUpgradeSought,
            rankAtSeparation: exported.rankAtSeparation,
            militaryOccupation: exported.militaryOccupation,
            unitAssignments: exported.unitAssignments,
            deploymentLocations: exported.deploymentLocations,
            combatVeteran: exported.combatVeteran,
            combatTheaters: exported.combatTheaters,
            purpleHeartRecipient: exported.purpleHeartRecipient,
            medalsAndAwards: exported.medalsAndAwards,
            powStatus: exported.powStatus,
            agentOrangeExposure: exported.agentOrangeExposure,
            radiationExposure: exported.radiationExposure,
            burnPitExposure: exported.burnPitExposure,
            gulfWarService: exported.gulfWarService,
            campLejeuneExposure: exported.campLejeuneExposure,
            pactActEligible: exported.pactActEligible,
            currentDisabilityRating: exported.currentDisabilityRating,
            vaHealthcareEnrolled: exported.vaHealthcareEnrolled,
            healthcareEnrollmentDate: exported.healthcareEnrollmentDate,
            priorityGroup: exported.priorityGroup,
            vaMedicalCenter: exported.vaMedicalCenter,
            vaClinic: exported.vaClinic,
            primaryCareProvider: exported.primaryCareProvider,
            patientAdvocateContact: exported.patientAdvocateContact,
            educationBenefits: exported.educationBenefits,
            giBillStartDate: exported.giBillStartDate,
            educationEntitlementMonths: exported.educationEntitlementMonths,
            percentEligible: exported.percentEligible,
            yellowRibbon: exported.yellowRibbon,
            currentSchool: exported.currentSchool,
            degreeProgram: exported.degreeProgram,
            graduationDate: exported.graduationDate,
            vrAndEEnrolled: exported.vrAndEEnrolled,
            vrAndECounselor: exported.vrAndECounselor,
            homeLoanCoeIssued: exported.homeLoanCoeIssued,
            homeLoanCoeDate: exported.homeLoanCoeDate,
            homeLoanEntitlementRemaining: exported.homeLoanEntitlementRemaining,
            homeLoanUsedCount: exported.homeLoanUsedCount,
            currentVaLoanActive: exported.currentVaLoanActive,
            homeLoanDefault: exported.homeLoanDefault,
            irrrlEligible: exported.irrrlEligible,
            sgliActive: exported.sgliActive,
            vgliEnrolled: exported.vgliEnrolled,
            vgliCoverageAmount: exported.vgliCoverageAmount,
            vmliEligible: exported.vmliEligible,
            pensionBenefits: exported.pensionBenefits,
            aidAndAttendance: exported.aidAndAttendance,
            houseboundBenefit: exported.houseboundBenefit,
            burialBenefits: exported.burialBenefits,
            monthlyCompensation: exported.monthlyCompensation,
            compensationStartDate: exported.compensationStartDate,
            backPayOwed: exported.backPayOwed,
            backPayReceived: exported.backPayReceived,
            backPayDate: exported.backPayDate,
            paymentMethod: exported.paymentMethod,
            bankAccountOnFile: exported.bankAccountOnFile,
            paymentHeld: exported.paymentHeld,
            paymentHoldReason: exported.paymentHoldReason,
            overpaymentDebt: exported.overpaymentDebt,
            debtAmount: exported.debtAmount,
            debtRepaymentPlan: exported.debtRepaymentPlan,
            offsetActive: exported.offsetActive,
            hasDependents: exported.hasDependents,
            spouseDependent: exported.spouseDependent,
            numberOfChildren: exported.numberOfChildren,
            numberOfDisabledChildren: exported.numberOfDisabledChildren,
            dependentParent: exported.dependentParent,
            derivativeBenefits: exported.derivativeBenefits,
            intakeDate: exported.intakeDate,
            caseOpenedDate: exported.caseOpenedDate,
            caseStatus: exported.caseStatus,
            assignedVso: exported.assignedVso,
            vsoOrganization: exported.vsoOrganization,
            assignedCounselor: exported.assignedCounselor,
            counselorNotes: exported.counselorNotes,
            casePriority: exported.casePriority,
            priorityReason: exported.priorityReason,
            nextActionItem: exported.nextActionItem,
            nextActionOwner: exported.nextActionOwner,
            nextFollowupDate: exported.nextFollowupDate,
            lastContactDate: exported.lastContactDate,
            lastContactMethod: exported.lastContactMethod,
            contactAttempts: exported.contactAttempts,
            veteranResponsive: exported.veteranResponsive,
            barriersToClaim: exported.barriersToClaim,
            requiresLegalAssistance: exported.requiresLegalAssistance,
            attorneyName: exported.attorneyName,
            powerOfAttorney: exported.powerOfAttorney,
            poaOrganization: exported.poaOrganization,
            fiduciaryNeeded: exported.fiduciaryNeeded,
            fiduciaryAppointed: exported.fiduciaryAppointed,
            successLikelihood: exported.successLikelihood,
            confidenceReasoning: exported.confidenceReasoning,
            estimatedCompletionDate: exported.estimatedCompletionDate,
            caseClosedDate: exported.caseClosedDate,
            caseOutcome: exported.caseOutcome,
            satisfactionRating: exported.satisfactionRating,
            testimonialProvided: exported.testimonialProvided,
            referralSource: exported.referralSource,
            wouldRecommend: exported.wouldRecommend,
            terminalIllness: exported.terminalIllness,
            financialHardship: exported.financialHardship,
            homelessVeteran: exported.homelessVeteran,
            homelessVeteranCoordinator: exported.homelessVeteranCoordinator,
            incarcerated: exported.incarcerated,
            mentalHealthCrisis: exported.mentalHealthCrisis,
            suicideRisk: exported.suicideRisk,
            crisisLineContacted: exported.crisisLineContacted,
            substanceAbuse: exported.substanceAbuse,
            mstSurvivor: exported.mstSurvivor,
            mstCoordinatorContact: exported.mstCoordinatorContact,
            womenVeteran: exported.womenVeteran,
            minorityVeteran: exported.minorityVeteran,
            lgbtqVeteran: exported.lgbtqVeteran,
            elderlyVeteran: exported.elderlyVeteran,
            formerGuardReserve: exported.formerGuardReserve,
            blueWaterNavy: exported.blueWaterNavy,
            disabledVeteran: exported.disabledVeteran,
            socialSecurityDisability: exported.socialSecurityDisability,
            unemployed: exported.unemployed,
            underemployed: exported.underemployed,
            portalAccountCreated: exported.portalAccountCreated,
            portalRegistrationDate: exported.portalRegistrationDate,
            portalLastLogin: exported.portalLastLogin,
            portalLoginCount: exported.portalLoginCount,
            idMeVerified: exported.idMeVerified,
            idMeVerificationDate: exported.idMeVerificationDate,
            loginGovVerified: exported.loginGovVerified,
            twoFactorEnabled: exported.twoFactorEnabled,
            documentUploads: exported.documentUploads,
            portalMessagesSent: exported.portalMessagesSent,
            emailNotificationsEnabled: exported.emailNotificationsEnabled,
            smsNotificationsEnabled: exported.smsNotificationsEnabled,
            optInMarketing: exported.optInMarketing,
            newsletterSubscriber: exported.newsletterSubscriber,
            webinarInvitations: exported.webinarInvitations,
            surveyParticipation: exported.surveyParticipation,
            communityForumMember: exported.communityForumMember,
            advocacyVolunteer: exported.advocacyVolunteer,
            vaGovApiSynced: exported.vaGovApiSynced,
            vaProfileId: exported.vaProfileId,
            ebenefitsSynced: exported.ebenefitsSynced,
            myhealthevetConnected: exported.myhealthevetConnected,
            lastApiSync: exported.lastApiSync,
            apiSyncStatus: exported.apiSyncStatus,
            recordCreatedBy: exported.recordCreatedBy,
            recordModifiedBy: exported.recordModifiedBy,
            hipaaConsentSigned: exported.hipaaConsentSigned,
            hipaaConsentDate: exported.hipaaConsentDate,
            privacyNoticeAcknowledged: exported.privacyNoticeAcknowledged,
            termsOfServiceAccepted: exported.termsOfServiceAccepted,
            gdprDataRequest: exported.gdprDataRequest,
            recordRetentionDate: exported.recordRetentionDate
        )
    }
    
    private func updateVeteran(_ veteran: Veteran, from exported: ExportedVeteran) {
        // Update all fields from exported data
        // This is a simplified version - in production, you might want selective updates
        veteran.recordModifiedDate = Date()
        veteran.recordModifiedBy = exported.recordModifiedBy
        // Add more field updates as needed
    }
    
    private func createClaim(from exported: ExportedClaim, veteranMapping: [UUID: Veteran]) -> Claim {
        let claim = Claim(
            claimNumber: exported.claimNumber,
            claimType: exported.claimType,
            claimStatus: exported.claimStatus,
            claimFiledDate: exported.claimFiledDate,
            claimReceivedDate: exported.claimReceivedDate,
            claimDecisionDate: exported.claimDecisionDate,
            decisionNotificationDate: exported.decisionNotificationDate,
            daysPending: exported.daysPending,
            targetCompletionDate: exported.targetCompletionDate,
            actualCompletionDate: exported.actualCompletionDate,
            primaryCondition: exported.primaryCondition,
            primaryConditionCategory: exported.primaryConditionCategory,
            secondaryConditions: exported.secondaryConditions,
            totalConditionsClaimed: exported.totalConditionsClaimed,
            serviceConnectedConditions: exported.serviceConnectedConditions,
            nonServiceConnected: exported.nonServiceConnected,
            bilateralFactor: exported.bilateralFactor,
            individualUnemployability: exported.individualUnemployability,
            specialMonthlyCompensation: exported.specialMonthlyCompensation,
            nexusLetterRequired: exported.nexusLetterRequired,
            nexusLetterObtained: exported.nexusLetterObtained,
            nexusProviderName: exported.nexusProviderName,
            nexusLetterDate: exported.nexusLetterDate,
            dbqCompleted: exported.dbqCompleted,
            cAndPExamRequired: exported.cAndPExamRequired,
            cAndPExamDate: exported.cAndPExamDate,
            cAndPExamType: exported.cAndPExamType,
            cAndPExamCompleted: exported.cAndPExamCompleted,
            cAndPFavorable: exported.cAndPFavorable,
            buddyStatementProvided: exported.buddyStatementProvided,
            numberBuddyStatements: exported.numberBuddyStatements,
            dd214OnFile: exported.dd214OnFile,
            dd214UploadDate: exported.dd214UploadDate,
            dd214Type: exported.dd214Type,
            serviceTreatmentRecords: exported.serviceTreatmentRecords,
            strRequestDate: exported.strRequestDate,
            strReceivedDate: exported.strReceivedDate,
            vaMedicalRecords: exported.vaMedicalRecords,
            vaRecordsRequestDate: exported.vaRecordsRequestDate,
            privateMedicalRecords: exported.privateMedicalRecords,
            privateRecordsComplete: exported.privateRecordsComplete,
            medicalReleaseSigned: exported.medicalReleaseSigned,
            intentToFileDate: exported.intentToFileDate,
            itfConfirmationNumber: exported.itfConfirmationNumber,
            effectiveDate: exported.effectiveDate,
            vaForm21526ez: exported.vaForm21526ez,
            vaForm214142: exported.vaForm214142,
            vaForm21781: exported.vaForm21781,
            vaForm21781a: exported.vaForm21781a,
            dependentVerification: exported.dependentVerification,
            marriageCertificate: exported.marriageCertificate,
            birthCertificates: exported.birthCertificates,
            appealFiled: exported.appealFiled,
            appealType: exported.appealType,
            appealFiledDate: exported.appealFiledDate,
            appealAcknowledgmentDate: exported.appealAcknowledgmentDate,
            appealStatus: exported.appealStatus,
            appealDocketNumber: exported.appealDocketNumber,
            noticeOfDisagreementDate: exported.noticeOfDisagreementDate,
            statementOfCaseDate: exported.statementOfCaseDate,
            ssocDate: exported.ssocDate,
            form9Date: exported.form9Date,
            boardHearingRequested: exported.boardHearingRequested,
            boardHearingType: exported.boardHearingType,
            boardHearingDate: exported.boardHearingDate,
            boardHearingCompleted: exported.boardHearingCompleted,
            hearingTranscriptReceived: exported.hearingTranscriptReceived,
            newEvidenceSubmitted: exported.newEvidenceSubmitted,
            remandReason: exported.remandReason,
            appealDecisionDate: exported.appealDecisionDate,
            appealOutcome: exported.appealOutcome,
            cavcFilingDeadline: exported.cavcFilingDeadline
        )
        claim.id = exported.id // Preserve UUID
        claim.veteran = exported.veteranId.flatMap { veteranMapping[$0] }
        return claim
    }
    
    private func updateClaim(_ claim: Claim, from exported: ExportedClaim, veteranMapping: [UUID: Veteran]) {
        claim.veteran = exported.veteranId.flatMap { veteranMapping[$0] }
        // Add more field updates as needed
    }
    
    private func createMedicalCondition(
        from exported: ExportedMedicalCondition,
        claimMapping: [UUID: Claim],
        categoryMapping: [UUID: MedicalConditionCategory]
    ) -> MedicalCondition {
        let condition = MedicalCondition(
            conditionName: exported.conditionName,
            category: exported.categoryId.flatMap { categoryMapping[$0] },
            isPrimary: exported.isPrimary,
            isSecondary: exported.isSecondary,
            isServiceConnected: exported.isServiceConnected,
            isBilateral: exported.isBilateral,
            ratingPercentage: exported.ratingPercentage,
            effectiveDate: exported.effectiveDate,
            diagnosisDate: exported.diagnosisDate,
            description: exported.conditionDescription,
            symptoms: exported.symptoms,
            treatmentHistory: exported.treatmentHistory,
            nexusLetterRequired: exported.nexusLetterRequired,
            nexusLetterObtained: exported.nexusLetterObtained,
            nexusProviderName: exported.nexusProviderName,
            nexusLetterDate: exported.nexusLetterDate,
            dbqCompleted: exported.dbqCompleted,
            cAndPExamRequired: exported.cAndPExamRequired,
            cAndPExamDate: exported.cAndPExamDate,
            cAndPExamCompleted: exported.cAndPExamCompleted,
            cAndPFavorable: exported.cAndPFavorable,
            buddyStatementProvided: exported.buddyStatementProvided,
            medicalRecordsOnFile: exported.medicalRecordsOnFile,
            privateMedicalRecords: exported.privateMedicalRecords,
            vaMedicalRecords: exported.vaMedicalRecords,
            serviceTreatmentRecords: exported.serviceTreatmentRecords,
            notes: exported.notes
        )
        condition.id = exported.id // Preserve UUID
        condition.claim = exported.claimId.flatMap { claimMapping[$0] }
        return condition
    }
    
    private func createConditionRelationship(
        from exported: ExportedConditionRelationship,
        conditionMapping: [UUID: MedicalCondition]
    ) -> ConditionRelationship {
        let relationship = ConditionRelationship(
            primaryCondition: exported.primaryConditionId.flatMap { conditionMapping[$0] },
            secondaryCondition: exported.secondaryConditionId.flatMap { conditionMapping[$0] },
            relationshipType: RelationshipType(rawValue: exported.relationshipType) ?? .independent,
            description: exported.conditionDescription,
            isServiceConnected: exported.isServiceConnected,
            nexusRequired: exported.nexusRequired,
            nexusObtained: exported.nexusObtained
        )
        relationship.id = exported.id // Preserve UUID
        relationship.createdDate = exported.createdDate
        return relationship
    }
    
    private func createClaimActivity(
        from exported: ExportedClaimActivity,
        claimMapping: [UUID: Claim]
    ) -> ClaimActivity {
        let activity = ClaimActivity(
            activityType: ActivityType(rawValue: exported.activityType) ?? .other,
            claimDescription: exported.claimDescription,
            performedBy: exported.performedBy,
            notes: exported.notes
        )
        activity.id = exported.id // Preserve UUID
        activity.date = exported.date
        activity.claim = exported.claimId.flatMap { claimMapping[$0] }
        return activity
    }
    
    private func createDocument(
        from exported: ExportedDocument,
        veteranMapping: [UUID: Veteran],
        claimMapping: [UUID: Claim],
        sourceDir: URL
    ) async throws -> Document {
        // Find source file in documents directory
        let sourceFileURL = sourceDir.appendingPathComponent(exported.filePath.replacingOccurrences(of: "documents/", with: ""))
        
        // Determine destination for document file
        // Use applicationSupportDirectory with proper error handling
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw ImportError.documentRestoreFailed("Could not access application support directory")
        }
        
        let documentsDir = appSupportDir.appendingPathComponent("VeteransDocuments", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: documentsDir.path) {
            do {
                try fileManager.createDirectory(at: documentsDir, withIntermediateDirectories: true, attributes: nil)
                print("📁 Created documents directory: \(documentsDir.path)")
            } catch {
                print("❌ Failed to create documents directory: \(error.localizedDescription)")
                throw ImportError.documentRestoreFailed("Could not create documents directory: \(error.localizedDescription)")
            }
        }
        
        // Verify directory is writable
        guard fileManager.isWritableFile(atPath: documentsDir.path) else {
            print("❌ Documents directory is not writable: \(documentsDir.path)")
            throw ImportError.documentRestoreFailed("Documents directory is not writable")
        }
        
        let destFileURL = documentsDir.appendingPathComponent("\(exported.id.uuidString)_\(exported.fileName)")
        
        // Copy file if it exists
        if fileManager.fileExists(atPath: sourceFileURL.path) {
            // Remove existing file if present
            if fileManager.fileExists(atPath: destFileURL.path) {
                do {
                    try fileManager.removeItem(at: destFileURL)
                } catch {
                    print("⚠️ Warning: Could not remove existing file: \(error.localizedDescription)")
                }
            }
            
            do {
                try fileManager.copyItem(at: sourceFileURL, to: destFileURL)
                print("✅ Copied document: \(exported.fileName) to \(destFileURL.path)")
            } catch {
                print("❌ Failed to copy document file: \(error.localizedDescription)")
                print("   Source: \(sourceFileURL.path)")
                print("   Destination: \(destFileURL.path)")
                throw ImportError.documentRestoreFailed("Failed to copy file: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ Warning: Source document file not found: \(sourceFileURL.path)")
            // Continue with metadata import even if file is missing
        }
        
        // Create document record
        let documentType = DocumentType(rawValue: exported.documentType) ?? .other
        let document = Document(
            fileName: exported.fileName,
            fileType: exported.fileType,
            fileSize: exported.fileSize,
            documentType: documentType,
            documentDescription: exported.documentDescription,
            filePath: destFileURL.path
        )
        document.id = exported.id // Preserve UUID
        document.veteran = exported.veteranId.flatMap { veteranMapping[$0] }
        document.claim = exported.claimId.flatMap { claimMapping[$0] }
        document.uploadDate = exported.uploadDate
        
        return document
    }
}

