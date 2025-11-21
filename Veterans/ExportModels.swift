//
//  ExportModels.swift
//  Veterans
//
//  Created for Import/Export Feature
//

import Foundation

// MARK: - Export Metadata
struct ExportMetadata: Codable {
    let version: String
    let exportDate: Date
    let exportedBy: String
    let appVersion: String
    let veteranCount: Int
    let claimCount: Int
    let documentCount: Int
    let activityCount: Int
    let medicalConditionCount: Int
    
    init(exportedBy: String, veteranCount: Int, claimCount: Int, documentCount: Int, activityCount: Int, medicalConditionCount: Int) {
        self.version = "1.0"
        self.exportDate = Date()
        self.exportedBy = exportedBy
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.veteranCount = veteranCount
        self.claimCount = claimCount
        self.documentCount = documentCount
        self.activityCount = activityCount
        self.medicalConditionCount = medicalConditionCount
    }
}

// MARK: - Export Data Container
struct ExportData: Codable {
    let metadata: ExportMetadata
    let veterans: [ExportedVeteran]
    let claims: [ExportedClaim]
    let documents: [ExportedDocument]
    let activities: [ExportedClaimActivity]
    let medicalConditions: [ExportedMedicalCondition]
    let medicalConditionCategories: [ExportedMedicalConditionCategory]
    let conditionRelationships: [ExportedConditionRelationship]
}

// MARK: - Exported Veteran
struct ExportedVeteran: Codable {
    let id: UUID
    let veteranId: String
    let ssnLastFour: String
    let firstName: String
    let middleName: String
    let lastName: String
    let suffix: String
    let preferredName: String
    let dateOfBirth: Date
    let gender: String
    let maritalStatus: String
    let emailPrimary: String
    let emailSecondary: String
    let phonePrimary: String
    let phoneSecondary: String
    let phoneType: String
    let addressStreet: String?
    let addressCity: String?
    let addressState: String?
    let addressZip: String
    let county: String
    let mailingAddressDifferent: Bool
    let homelessStatus: String
    let preferredContactMethod: String
    let preferredContactTime: String
    let languagePrimary: String
    let interpreterNeeded: Bool
    let serviceBranch: String
    let serviceComponent: String
    let serviceStartDate: Date
    let serviceEndDate: Date
    let yearsOfService: Int
    let dischargeDate: Date
    let dischargeStatus: String
    let dischargeUpgradeSought: Bool
    let rankAtSeparation: String
    let militaryOccupation: String
    let unitAssignments: String
    let deploymentLocations: String
    let combatVeteran: Bool
    let combatTheaters: String
    let purpleHeartRecipient: Bool
    let medalsAndAwards: String
    let powStatus: String
    let agentOrangeExposure: Bool
    let radiationExposure: Bool
    let burnPitExposure: Bool
    let gulfWarService: Bool
    let campLejeuneExposure: Bool
    let pactActEligible: Bool
    let currentDisabilityRating: Int
    let vaHealthcareEnrolled: Bool
    let healthcareEnrollmentDate: Date?
    let priorityGroup: String
    let vaMedicalCenter: String
    let vaClinic: String
    let primaryCareProvider: String
    let patientAdvocateContact: String
    let educationBenefits: String
    let giBillStartDate: Date?
    let educationEntitlementMonths: Int
    let percentEligible: Int
    let yellowRibbon: Bool
    let currentSchool: String
    let degreeProgram: String
    let graduationDate: Date?
    let vrAndEEnrolled: Bool
    let vrAndECounselor: String
    let homeLoanCoeIssued: Bool
    let homeLoanCoeDate: Date?
    let homeLoanEntitlementRemaining: Int
    let homeLoanUsedCount: Int
    let currentVaLoanActive: Bool
    let homeLoanDefault: Bool
    let irrrlEligible: Bool
    let sgliActive: Bool
    let vgliEnrolled: Bool
    let vgliCoverageAmount: Int
    let vmliEligible: Bool
    let pensionBenefits: Bool
    let aidAndAttendance: Bool
    let houseboundBenefit: Bool
    let burialBenefits: Bool
    let monthlyCompensation: Double
    let compensationStartDate: Date?
    let backPayOwed: Double
    let backPayReceived: Double
    let backPayDate: Date?
    let paymentMethod: String
    let bankAccountOnFile: Bool
    let paymentHeld: Bool
    let paymentHoldReason: String
    let overpaymentDebt: Bool
    let debtAmount: Double
    let debtRepaymentPlan: String
    let offsetActive: Bool
    let hasDependents: Bool
    let spouseDependent: Bool
    let numberOfChildren: Int
    let numberOfDisabledChildren: Int
    let dependentParent: Bool
    let derivativeBenefits: Bool
    let intakeDate: Date
    let caseOpenedDate: Date
    let caseStatus: String
    let assignedVso: String
    let vsoOrganization: String
    let assignedCounselor: String
    let counselorNotes: String
    let casePriority: String
    let priorityReason: String
    let nextActionItem: String
    let nextActionOwner: String
    let nextFollowupDate: Date?
    let lastContactDate: Date?
    let lastContactMethod: String
    let contactAttempts: Int
    let veteranResponsive: String
    let barriersToClaim: String
    let requiresLegalAssistance: Bool
    let attorneyName: String
    let powerOfAttorney: Bool
    let poaOrganization: String
    let fiduciaryNeeded: Bool
    let fiduciaryAppointed: Bool
    let successLikelihood: String
    let confidenceReasoning: String
    let estimatedCompletionDate: Date?
    let caseClosedDate: Date?
    let caseOutcome: String
    let satisfactionRating: Int
    let testimonialProvided: Bool
    let referralSource: String
    let wouldRecommend: Bool
    let terminalIllness: Bool
    let financialHardship: Bool
    let homelessVeteran: Bool
    let homelessVeteranCoordinator: String
    let incarcerated: Bool
    let mentalHealthCrisis: Bool
    let suicideRisk: Bool
    let crisisLineContacted: Bool
    let substanceAbuse: Bool
    let mstSurvivor: Bool
    let mstCoordinatorContact: String
    let womenVeteran: Bool
    let minorityVeteran: Bool
    let lgbtqVeteran: Bool
    let elderlyVeteran: Bool
    let formerGuardReserve: Bool
    let blueWaterNavy: Bool
    let disabledVeteran: Bool
    let socialSecurityDisability: Bool
    let unemployed: Bool
    let underemployed: Bool
    let portalAccountCreated: Bool
    let portalRegistrationDate: Date?
    let portalLastLogin: Date?
    let portalLoginCount: Int
    let idMeVerified: Bool
    let idMeVerificationDate: Date?
    let loginGovVerified: Bool
    let twoFactorEnabled: Bool
    let documentUploads: Int
    let portalMessagesSent: Int
    let emailNotificationsEnabled: Bool
    let smsNotificationsEnabled: Bool
    let optInMarketing: Bool
    let newsletterSubscriber: Bool
    let webinarInvitations: Bool
    let surveyParticipation: Bool
    let communityForumMember: Bool
    let advocacyVolunteer: Bool
    let vaGovApiSynced: Bool
    let vaProfileId: String
    let ebenefitsSynced: Bool
    let myhealthevetConnected: Bool
    let lastApiSync: Date?
    let apiSyncStatus: String
    let recordCreatedDate: Date
    let recordCreatedBy: String
    let recordModifiedDate: Date
    let recordModifiedBy: String
    let hipaaConsentSigned: Bool
    let hipaaConsentDate: Date?
    let privacyNoticeAcknowledged: Bool
    let termsOfServiceAccepted: Bool
    let gdprDataRequest: Bool
    let recordRetentionDate: Date?
    
    // Relationship IDs (for import)
    let claimIds: [UUID]
    let documentIds: [UUID]
    
    init(from veteran: Veteran) {
        self.id = veteran.id
        self.veteranId = veteran.veteranId
        self.ssnLastFour = veteran.ssnLastFour
        self.firstName = veteran.firstName
        self.middleName = veteran.middleName
        self.lastName = veteran.lastName
        self.suffix = veteran.suffix
        self.preferredName = veteran.preferredName
        self.dateOfBirth = veteran.dateOfBirth
        self.gender = veteran.gender
        self.maritalStatus = veteran.maritalStatus
        self.emailPrimary = veteran.emailPrimary
        self.emailSecondary = veteran.emailSecondary
        self.phonePrimary = veteran.phonePrimary
        self.phoneSecondary = veteran.phoneSecondary
        self.phoneType = veteran.phoneType
        self.addressStreet = veteran.addressStreet
        self.addressCity = veteran.addressCity
        self.addressState = veteran.addressState
        self.addressZip = veteran.addressZip
        self.county = veteran.county
        self.mailingAddressDifferent = veteran.mailingAddressDifferent
        self.homelessStatus = veteran.homelessStatus
        self.preferredContactMethod = veteran.preferredContactMethod
        self.preferredContactTime = veteran.preferredContactTime
        self.languagePrimary = veteran.languagePrimary
        self.interpreterNeeded = veteran.interpreterNeeded
        self.serviceBranch = veteran.serviceBranch
        self.serviceComponent = veteran.serviceComponent
        self.serviceStartDate = veteran.serviceStartDate
        self.serviceEndDate = veteran.serviceEndDate
        self.yearsOfService = veteran.yearsOfService
        self.dischargeDate = veteran.dischargeDate
        self.dischargeStatus = veteran.dischargeStatus
        self.dischargeUpgradeSought = veteran.dischargeUpgradeSought
        self.rankAtSeparation = veteran.rankAtSeparation
        self.militaryOccupation = veteran.militaryOccupation
        self.unitAssignments = veteran.unitAssignments
        self.deploymentLocations = veteran.deploymentLocations
        self.combatVeteran = veteran.combatVeteran
        self.combatTheaters = veteran.combatTheaters
        self.purpleHeartRecipient = veteran.purpleHeartRecipient
        self.medalsAndAwards = veteran.medalsAndAwards
        self.powStatus = veteran.powStatus
        self.agentOrangeExposure = veteran.agentOrangeExposure
        self.radiationExposure = veteran.radiationExposure
        self.burnPitExposure = veteran.burnPitExposure
        self.gulfWarService = veteran.gulfWarService
        self.campLejeuneExposure = veteran.campLejeuneExposure
        self.pactActEligible = veteran.pactActEligible
        self.currentDisabilityRating = veteran.currentDisabilityRating
        self.vaHealthcareEnrolled = veteran.vaHealthcareEnrolled
        self.healthcareEnrollmentDate = veteran.healthcareEnrollmentDate
        self.priorityGroup = veteran.priorityGroup
        self.vaMedicalCenter = veteran.vaMedicalCenter
        self.vaClinic = veteran.vaClinic
        self.primaryCareProvider = veteran.primaryCareProvider
        self.patientAdvocateContact = veteran.patientAdvocateContact
        self.educationBenefits = veteran.educationBenefits
        self.giBillStartDate = veteran.giBillStartDate
        self.educationEntitlementMonths = veteran.educationEntitlementMonths
        self.percentEligible = veteran.percentEligible
        self.yellowRibbon = veteran.yellowRibbon
        self.currentSchool = veteran.currentSchool
        self.degreeProgram = veteran.degreeProgram
        self.graduationDate = veteran.graduationDate
        self.vrAndEEnrolled = veteran.vrAndEEnrolled
        self.vrAndECounselor = veteran.vrAndECounselor
        self.homeLoanCoeIssued = veteran.homeLoanCoeIssued
        self.homeLoanCoeDate = veteran.homeLoanCoeDate
        self.homeLoanEntitlementRemaining = veteran.homeLoanEntitlementRemaining
        self.homeLoanUsedCount = veteran.homeLoanUsedCount
        self.currentVaLoanActive = veteran.currentVaLoanActive
        self.homeLoanDefault = veteran.homeLoanDefault
        self.irrrlEligible = veteran.irrrlEligible
        self.sgliActive = veteran.sgliActive
        self.vgliEnrolled = veteran.vgliEnrolled
        self.vgliCoverageAmount = veteran.vgliCoverageAmount
        self.vmliEligible = veteran.vmliEligible
        self.pensionBenefits = veteran.pensionBenefits
        self.aidAndAttendance = veteran.aidAndAttendance
        self.houseboundBenefit = veteran.houseboundBenefit
        self.burialBenefits = veteran.burialBenefits
        self.monthlyCompensation = veteran.monthlyCompensation
        self.compensationStartDate = veteran.compensationStartDate
        self.backPayOwed = veteran.backPayOwed
        self.backPayReceived = veteran.backPayReceived
        self.backPayDate = veteran.backPayDate
        self.paymentMethod = veteran.paymentMethod
        self.bankAccountOnFile = veteran.bankAccountOnFile
        self.paymentHeld = veteran.paymentHeld
        self.paymentHoldReason = veteran.paymentHoldReason
        self.overpaymentDebt = veteran.overpaymentDebt
        self.debtAmount = veteran.debtAmount
        self.debtRepaymentPlan = veteran.debtRepaymentPlan
        self.offsetActive = veteran.offsetActive
        self.hasDependents = veteran.hasDependents
        self.spouseDependent = veteran.spouseDependent
        self.numberOfChildren = veteran.numberOfChildren
        self.numberOfDisabledChildren = veteran.numberOfDisabledChildren
        self.dependentParent = veteran.dependentParent
        self.derivativeBenefits = veteran.derivativeBenefits
        self.intakeDate = veteran.intakeDate
        self.caseOpenedDate = veteran.caseOpenedDate
        self.caseStatus = veteran.caseStatus
        self.assignedVso = veteran.assignedVso
        self.vsoOrganization = veteran.vsoOrganization
        self.assignedCounselor = veteran.assignedCounselor
        self.counselorNotes = veteran.counselorNotes
        self.casePriority = veteran.casePriority
        self.priorityReason = veteran.priorityReason
        self.nextActionItem = veteran.nextActionItem
        self.nextActionOwner = veteran.nextActionOwner
        self.nextFollowupDate = veteran.nextFollowupDate
        self.lastContactDate = veteran.lastContactDate
        self.lastContactMethod = veteran.lastContactMethod
        self.contactAttempts = veteran.contactAttempts
        self.veteranResponsive = veteran.veteranResponsive
        self.barriersToClaim = veteran.barriersToClaim
        self.requiresLegalAssistance = veteran.requiresLegalAssistance
        self.attorneyName = veteran.attorneyName
        self.powerOfAttorney = veteran.powerOfAttorney
        self.poaOrganization = veteran.poaOrganization
        self.fiduciaryNeeded = veteran.fiduciaryNeeded
        self.fiduciaryAppointed = veteran.fiduciaryAppointed
        self.successLikelihood = veteran.successLikelihood
        self.confidenceReasoning = veteran.confidenceReasoning
        self.estimatedCompletionDate = veteran.estimatedCompletionDate
        self.caseClosedDate = veteran.caseClosedDate
        self.caseOutcome = veteran.caseOutcome
        self.satisfactionRating = veteran.satisfactionRating
        self.testimonialProvided = veteran.testimonialProvided
        self.referralSource = veteran.referralSource
        self.wouldRecommend = veteran.wouldRecommend
        self.terminalIllness = veteran.terminalIllness
        self.financialHardship = veteran.financialHardship
        self.homelessVeteran = veteran.homelessVeteran
        self.homelessVeteranCoordinator = veteran.homelessVeteranCoordinator
        self.incarcerated = veteran.incarcerated
        self.mentalHealthCrisis = veteran.mentalHealthCrisis
        self.suicideRisk = veteran.suicideRisk
        self.crisisLineContacted = veteran.crisisLineContacted
        self.substanceAbuse = veteran.substanceAbuse
        self.mstSurvivor = veteran.mstSurvivor
        self.mstCoordinatorContact = veteran.mstCoordinatorContact
        self.womenVeteran = veteran.womenVeteran
        self.minorityVeteran = veteran.minorityVeteran
        self.lgbtqVeteran = veteran.lgbtqVeteran
        self.elderlyVeteran = veteran.elderlyVeteran
        self.formerGuardReserve = veteran.formerGuardReserve
        self.blueWaterNavy = veteran.blueWaterNavy
        self.disabledVeteran = veteran.disabledVeteran
        self.socialSecurityDisability = veteran.socialSecurityDisability
        self.unemployed = veteran.unemployed
        self.underemployed = veteran.underemployed
        self.portalAccountCreated = veteran.portalAccountCreated
        self.portalRegistrationDate = veteran.portalRegistrationDate
        self.portalLastLogin = veteran.portalLastLogin
        self.portalLoginCount = veteran.portalLoginCount
        self.idMeVerified = veteran.idMeVerified
        self.idMeVerificationDate = veteran.idMeVerificationDate
        self.loginGovVerified = veteran.loginGovVerified
        self.twoFactorEnabled = veteran.twoFactorEnabled
        self.documentUploads = veteran.documentUploads
        self.portalMessagesSent = veteran.portalMessagesSent
        self.emailNotificationsEnabled = veteran.emailNotificationsEnabled
        self.smsNotificationsEnabled = veteran.smsNotificationsEnabled
        self.optInMarketing = veteran.optInMarketing
        self.newsletterSubscriber = veteran.newsletterSubscriber
        self.webinarInvitations = veteran.webinarInvitations
        self.surveyParticipation = veteran.surveyParticipation
        self.communityForumMember = veteran.communityForumMember
        self.advocacyVolunteer = veteran.advocacyVolunteer
        self.vaGovApiSynced = veteran.vaGovApiSynced
        self.vaProfileId = veteran.vaProfileId
        self.ebenefitsSynced = veteran.ebenefitsSynced
        self.myhealthevetConnected = veteran.myhealthevetConnected
        self.lastApiSync = veteran.lastApiSync
        self.apiSyncStatus = veteran.apiSyncStatus
        self.recordCreatedDate = veteran.recordCreatedDate
        self.recordCreatedBy = veteran.recordCreatedBy
        self.recordModifiedDate = veteran.recordModifiedDate
        self.recordModifiedBy = veteran.recordModifiedBy
        self.hipaaConsentSigned = veteran.hipaaConsentSigned
        self.hipaaConsentDate = veteran.hipaaConsentDate
        self.privacyNoticeAcknowledged = veteran.privacyNoticeAcknowledged
        self.termsOfServiceAccepted = veteran.termsOfServiceAccepted
        self.gdprDataRequest = veteran.gdprDataRequest
        self.recordRetentionDate = veteran.recordRetentionDate
        
        // Store relationship IDs
        self.claimIds = veteran.claims.map { $0.id }
        self.documentIds = veteran.documents.map { $0.id }
    }
}

// MARK: - Exported Claim
struct ExportedClaim: Codable {
    let id: UUID
    let claimNumber: String
    let claimType: String
    let claimStatus: String
    let claimFiledDate: Date
    let claimReceivedDate: Date?
    let claimDecisionDate: Date?
    let decisionNotificationDate: Date?
    let daysPending: Int
    let targetCompletionDate: Date?
    let actualCompletionDate: Date?
    let primaryCondition: String
    let primaryConditionCategory: String
    let secondaryConditions: String
    let totalConditionsClaimed: Int
    let serviceConnectedConditions: String
    let nonServiceConnected: String
    let bilateralFactor: Bool
    let individualUnemployability: Bool
    let specialMonthlyCompensation: Bool
    let nexusLetterRequired: Bool
    let nexusLetterObtained: Bool
    let nexusProviderName: String
    let nexusLetterDate: Date?
    let dbqCompleted: Bool
    let cAndPExamRequired: Bool
    let cAndPExamDate: Date?
    let cAndPExamType: String
    let cAndPExamCompleted: Bool
    let cAndPFavorable: Bool
    let buddyStatementProvided: Bool
    let numberBuddyStatements: Int
    let dd214OnFile: Bool
    let dd214UploadDate: Date?
    let dd214Type: String
    let serviceTreatmentRecords: Bool
    let strRequestDate: Date?
    let strReceivedDate: Date?
    let vaMedicalRecords: Bool
    let vaRecordsRequestDate: Date?
    let privateMedicalRecords: Bool
    let privateRecordsComplete: Bool
    let medicalReleaseSigned: Bool
    let intentToFileDate: Date?
    let itfConfirmationNumber: String
    let effectiveDate: Date?
    let vaForm21526ez: Bool
    let vaForm214142: Bool
    let vaForm21781: Bool
    let vaForm21781a: Bool
    let dependentVerification: Bool
    let marriageCertificate: Bool
    let birthCertificates: Bool
    let appealFiled: Bool
    let appealType: String
    let appealFiledDate: Date?
    let appealAcknowledgmentDate: Date?
    let appealStatus: String
    let appealDocketNumber: String
    let noticeOfDisagreementDate: Date?
    let statementOfCaseDate: Date?
    let ssocDate: Date?
    let form9Date: Date?
    let boardHearingRequested: Bool
    let boardHearingType: String
    let boardHearingDate: Date?
    let boardHearingCompleted: Bool
    let hearingTranscriptReceived: Bool
    let newEvidenceSubmitted: Bool
    let remandReason: String
    let appealDecisionDate: Date?
    let appealOutcome: String
    let cavcFilingDeadline: Date?
    
    // Relationship IDs
    let veteranId: UUID?
    let documentIds: [UUID]
    let activityIds: [UUID]
    let conditionIds: [UUID]
    
    init(from claim: Claim) {
        self.id = claim.id
        self.claimNumber = claim.claimNumber
        self.claimType = claim.claimType
        self.claimStatus = claim.claimStatus
        self.claimFiledDate = claim.claimFiledDate
        self.claimReceivedDate = claim.claimReceivedDate
        self.claimDecisionDate = claim.claimDecisionDate
        self.decisionNotificationDate = claim.decisionNotificationDate
        self.daysPending = claim.daysPending
        self.targetCompletionDate = claim.targetCompletionDate
        self.actualCompletionDate = claim.actualCompletionDate
        self.primaryCondition = claim.primaryCondition
        self.primaryConditionCategory = claim.primaryConditionCategory
        self.secondaryConditions = claim.secondaryConditions
        self.totalConditionsClaimed = claim.totalConditionsClaimed
        self.serviceConnectedConditions = claim.serviceConnectedConditions
        self.nonServiceConnected = claim.nonServiceConnected
        self.bilateralFactor = claim.bilateralFactor
        self.individualUnemployability = claim.individualUnemployability
        self.specialMonthlyCompensation = claim.specialMonthlyCompensation
        self.nexusLetterRequired = claim.nexusLetterRequired
        self.nexusLetterObtained = claim.nexusLetterObtained
        self.nexusProviderName = claim.nexusProviderName
        self.nexusLetterDate = claim.nexusLetterDate
        self.dbqCompleted = claim.dbqCompleted
        self.cAndPExamRequired = claim.cAndPExamRequired
        self.cAndPExamDate = claim.cAndPExamDate
        self.cAndPExamType = claim.cAndPExamType
        self.cAndPExamCompleted = claim.cAndPExamCompleted
        self.cAndPFavorable = claim.cAndPFavorable
        self.buddyStatementProvided = claim.buddyStatementProvided
        self.numberBuddyStatements = claim.numberBuddyStatements
        self.dd214OnFile = claim.dd214OnFile
        self.dd214UploadDate = claim.dd214UploadDate
        self.dd214Type = claim.dd214Type
        self.serviceTreatmentRecords = claim.serviceTreatmentRecords
        self.strRequestDate = claim.strRequestDate
        self.strReceivedDate = claim.strReceivedDate
        self.vaMedicalRecords = claim.vaMedicalRecords
        self.vaRecordsRequestDate = claim.vaRecordsRequestDate
        self.privateMedicalRecords = claim.privateMedicalRecords
        self.privateRecordsComplete = claim.privateRecordsComplete
        self.medicalReleaseSigned = claim.medicalReleaseSigned
        self.intentToFileDate = claim.intentToFileDate
        self.itfConfirmationNumber = claim.itfConfirmationNumber
        self.effectiveDate = claim.effectiveDate
        self.vaForm21526ez = claim.vaForm21526ez
        self.vaForm214142 = claim.vaForm214142
        self.vaForm21781 = claim.vaForm21781
        self.vaForm21781a = claim.vaForm21781a
        self.dependentVerification = claim.dependentVerification
        self.marriageCertificate = claim.marriageCertificate
        self.birthCertificates = claim.birthCertificates
        self.appealFiled = claim.appealFiled
        self.appealType = claim.appealType
        self.appealFiledDate = claim.appealFiledDate
        self.appealAcknowledgmentDate = claim.appealAcknowledgmentDate
        self.appealStatus = claim.appealStatus
        self.appealDocketNumber = claim.appealDocketNumber
        self.noticeOfDisagreementDate = claim.noticeOfDisagreementDate
        self.statementOfCaseDate = claim.statementOfCaseDate
        self.ssocDate = claim.ssocDate
        self.form9Date = claim.form9Date
        self.boardHearingRequested = claim.boardHearingRequested
        self.boardHearingType = claim.boardHearingType
        self.boardHearingDate = claim.boardHearingDate
        self.boardHearingCompleted = claim.boardHearingCompleted
        self.hearingTranscriptReceived = claim.hearingTranscriptReceived
        self.newEvidenceSubmitted = claim.newEvidenceSubmitted
        self.remandReason = claim.remandReason
        self.appealDecisionDate = claim.appealDecisionDate
        self.appealOutcome = claim.appealOutcome
        self.cavcFilingDeadline = claim.cavcFilingDeadline
        
        self.veteranId = claim.veteran?.id
        self.documentIds = claim.documents.map { $0.id }
        self.activityIds = claim.activities.map { $0.id }
        self.conditionIds = claim.conditions.map { $0.id }
    }
}

// MARK: - Exported Document
struct ExportedDocument: Codable {
    let id: UUID
    let fileName: String
    let fileType: String
    let fileSize: Int64
    let uploadDate: Date
    let documentType: String
    let documentDescription: String
    let filePath: String // Relative path in ZIP (documents/filename.ext)
    
    // Relationship IDs
    let veteranId: UUID?
    let claimId: UUID?
    
    init(from document: Document, relativePath: String) {
        self.id = document.id
        self.fileName = document.fileName
        self.fileType = document.fileType
        self.fileSize = document.fileSize
        self.uploadDate = document.uploadDate
        self.documentType = document.documentType.rawValue
        self.documentDescription = document.documentDescription
        self.filePath = relativePath
        self.veteranId = document.veteran?.id
        self.claimId = document.claim?.id
    }
}

// MARK: - Exported Claim Activity
struct ExportedClaimActivity: Codable {
    let id: UUID
    let activityType: String
    let claimDescription: String
    let date: Date
    let performedBy: String
    let notes: String
    
    // Relationship ID
    let claimId: UUID?
    
    init(from activity: ClaimActivity) {
        self.id = activity.id
        self.activityType = activity.activityType.rawValue
        self.claimDescription = activity.claimDescription
        self.date = activity.date
        self.performedBy = activity.performedBy
        self.notes = activity.notes
        self.claimId = activity.claim?.id
    }
}

// MARK: - Exported Medical Condition
struct ExportedMedicalCondition: Codable {
    let id: UUID
    let conditionName: String
    let isPrimary: Bool
    let isSecondary: Bool
    let isServiceConnected: Bool
    let isBilateral: Bool
    let ratingPercentage: Int
    let effectiveDate: Date?
    let diagnosisDate: Date?
    let conditionDescription: String
    let symptoms: String
    let treatmentHistory: String
    let nexusLetterRequired: Bool
    let nexusLetterObtained: Bool
    let nexusProviderName: String
    let nexusLetterDate: Date?
    let dbqCompleted: Bool
    let cAndPExamRequired: Bool
    let cAndPExamDate: Date?
    let cAndPExamCompleted: Bool
    let cAndPFavorable: Bool
    let buddyStatementProvided: Bool
    let medicalRecordsOnFile: Bool
    let privateMedicalRecords: Bool
    let vaMedicalRecords: Bool
    let serviceTreatmentRecords: Bool
    let notes: String
    let createdDate: Date
    let modifiedDate: Date
    
    // Relationship IDs
    let claimId: UUID?
    let categoryId: UUID?
    
    init(from condition: MedicalCondition) {
        self.id = condition.id
        self.conditionName = condition.conditionName
        self.isPrimary = condition.isPrimary
        self.isSecondary = condition.isSecondary
        self.isServiceConnected = condition.isServiceConnected
        self.isBilateral = condition.isBilateral
        self.ratingPercentage = condition.ratingPercentage
        self.effectiveDate = condition.effectiveDate
        self.diagnosisDate = condition.diagnosisDate
        self.conditionDescription = condition.conditionDescription
        self.symptoms = condition.symptoms
        self.treatmentHistory = condition.treatmentHistory
        self.nexusLetterRequired = condition.nexusLetterRequired
        self.nexusLetterObtained = condition.nexusLetterObtained
        self.nexusProviderName = condition.nexusProviderName
        self.nexusLetterDate = condition.nexusLetterDate
        self.dbqCompleted = condition.dbqCompleted
        self.cAndPExamRequired = condition.cAndPExamRequired
        self.cAndPExamDate = condition.cAndPExamDate
        self.cAndPExamCompleted = condition.cAndPExamCompleted
        self.cAndPFavorable = condition.cAndPFavorable
        self.buddyStatementProvided = condition.buddyStatementProvided
        self.medicalRecordsOnFile = condition.medicalRecordsOnFile
        self.privateMedicalRecords = condition.privateMedicalRecords
        self.vaMedicalRecords = condition.vaMedicalRecords
        self.serviceTreatmentRecords = condition.serviceTreatmentRecords
        self.notes = condition.notes
        self.createdDate = condition.createdDate
        self.modifiedDate = condition.modifiedDate
        self.claimId = condition.claim?.id
        self.categoryId = condition.category?.id
    }
}

// MARK: - Exported Medical Condition Category
struct ExportedMedicalConditionCategory: Codable {
    let id: UUID
    let name: String
    let conditionDescription: String
    let color: String
    let isActive: Bool
    
    init(from category: MedicalConditionCategory) {
        self.id = category.id
        self.name = category.name
        self.conditionDescription = category.conditionDescription
        self.color = category.color
        self.isActive = category.isActive
    }
}

// MARK: - Exported Condition Relationship
struct ExportedConditionRelationship: Codable {
    let id: UUID
    let relationshipType: String
    let conditionDescription: String
    let isServiceConnected: Bool
    let nexusRequired: Bool
    let nexusObtained: Bool
    let createdDate: Date
    
    // Relationship IDs
    let primaryConditionId: UUID?
    let secondaryConditionId: UUID?
    
    init(from relationship: ConditionRelationship) {
        self.id = relationship.id
        self.relationshipType = relationship.relationshipType.rawValue
        self.conditionDescription = relationship.conditionDescription
        self.isServiceConnected = relationship.isServiceConnected
        self.nexusRequired = relationship.nexusRequired
        self.nexusObtained = relationship.nexusObtained
        self.createdDate = relationship.createdDate
        self.primaryConditionId = relationship.primaryCondition?.id
        self.secondaryConditionId = relationship.secondaryCondition?.id
    }
}

