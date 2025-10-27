//
//  VeteransCRM.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData

// MARK: - Veteran Model
@Model
final class Veteran {
    var id: UUID
    var veteranId: String
    var ssnLastFour: String
    var firstName: String
    var middleName: String
    var lastName: String
    var suffix: String
    var preferredName: String
    var dateOfBirth: Date
    var gender: String
    var maritalStatus: String
    var emailPrimary: String
    var emailSecondary: String
    var phonePrimary: String
    var phoneSecondary: String
    var phoneType: String
    var addressStreet: String
    var addressCity: String?
    var addressState: String?
    var addressZip: String
    var county: String
    var mailingAddressDifferent: Bool
    var homelessStatus: String
    var preferredContactMethod: String
    var preferredContactTime: String
    var languagePrimary: String
    var interpreterNeeded: Bool
    var serviceBranch: String
    var serviceComponent: String
    var serviceStartDate: Date
    var serviceEndDate: Date
    var yearsOfService: Int
    var dischargeDate: Date
    var dischargeStatus: String
    var dischargeUpgradeSought: Bool
    var rankAtSeparation: String
    var militaryOccupation: String
    var unitAssignments: String
    var deploymentLocations: String
    var combatVeteran: Bool
    var combatTheaters: String
    var purpleHeartRecipient: Bool
    var medalsAndAwards: String
    var powStatus: String
    var agentOrangeExposure: Bool
    var radiationExposure: Bool
    var burnPitExposure: Bool
    var gulfWarService: Bool
    var campLejeuneExposure: Bool
    var pactActEligible: Bool
    var currentDisabilityRating: Int
    var vaHealthcareEnrolled: Bool
    var healthcareEnrollmentDate: Date?
    var priorityGroup: String
    var vaMedicalCenter: String
    var vaClinic: String
    var primaryCareProvider: String
    var patientAdvocateContact: String
    var educationBenefits: String
    var giBillStartDate: Date?
    var educationEntitlementMonths: Int
    var percentEligible: Int
    var yellowRibbon: Bool
    var currentSchool: String
    var degreeProgram: String
    var graduationDate: Date?
    var vrAndEEnrolled: Bool
    var vrAndECounselor: String
    var homeLoanCoeIssued: Bool
    var homeLoanCoeDate: Date?
    var homeLoanEntitlementRemaining: Int
    var homeLoanUsedCount: Int
    var currentVaLoanActive: Bool
    var homeLoanDefault: Bool
    var irrrlEligible: Bool
    var sgliActive: Bool
    var vgliEnrolled: Bool
    var vgliCoverageAmount: Int
    var vmliEligible: Bool
    var pensionBenefits: Bool
    var aidAndAttendance: Bool
    var houseboundBenefit: Bool
    var burialBenefits: Bool
    var monthlyCompensation: Double
    var compensationStartDate: Date?
    var backPayOwed: Double
    var backPayReceived: Double
    var backPayDate: Date?
    var paymentMethod: String
    var bankAccountOnFile: Bool
    var paymentHeld: Bool
    var paymentHoldReason: String
    var overpaymentDebt: Bool
    var debtAmount: Double
    var debtRepaymentPlan: String
    var offsetActive: Bool
    var hasDependents: Bool
    var spouseDependent: Bool
    var numberOfChildren: Int
    var numberOfDisabledChildren: Int
    var dependentParent: Bool
    var derivativeBenefits: Bool
    var intakeDate: Date
    var caseOpenedDate: Date
    var caseStatus: String
    var assignedVso: String
    var vsoOrganization: String
    var assignedCounselor: String
    var counselorNotes: String
    var casePriority: String
    var priorityReason: String
    var nextActionItem: String
    var nextActionOwner: String
    var nextFollowupDate: Date?
    var lastContactDate: Date?
    var lastContactMethod: String
    var contactAttempts: Int
    var veteranResponsive: String
    var barriersToClaim: String
    var requiresLegalAssistance: Bool
    var attorneyName: String
    var powerOfAttorney: Bool
    var poaOrganization: String
    var fiduciaryNeeded: Bool
    var fiduciaryAppointed: Bool
    var successLikelihood: String
    var confidenceReasoning: String
    var estimatedCompletionDate: Date?
    var caseClosedDate: Date?
    var caseOutcome: String
    var satisfactionRating: Int
    var testimonialProvided: Bool
    var referralSource: String
    var wouldRecommend: Bool
    var terminalIllness: Bool
    var financialHardship: Bool
    var homelessVeteran: Bool
    var homelessVeteranCoordinator: String
    var incarcerated: Bool
    var mentalHealthCrisis: Bool
    var suicideRisk: Bool
    var crisisLineContacted: Bool
    var substanceAbuse: Bool
    var mstSurvivor: Bool
    var mstCoordinatorContact: String
    var womenVeteran: Bool
    var minorityVeteran: Bool
    var lgbtqVeteran: Bool
    var elderlyVeteran: Bool
    var formerGuardReserve: Bool
    var blueWaterNavy: Bool
    var disabledVeteran: Bool
    var socialSecurityDisability: Bool
    var unemployed: Bool
    var underemployed: Bool
    var portalAccountCreated: Bool
    var portalRegistrationDate: Date?
    var portalLastLogin: Date?
    var portalLoginCount: Int
    var idMeVerified: Bool
    var idMeVerificationDate: Date?
    var loginGovVerified: Bool
    var twoFactorEnabled: Bool
    var documentUploads: Int
    var portalMessagesSent: Int
    var emailNotificationsEnabled: Bool
    var smsNotificationsEnabled: Bool
    var optInMarketing: Bool
    var newsletterSubscriber: Bool
    var webinarInvitations: Bool
    var surveyParticipation: Bool
    var communityForumMember: Bool
    var advocacyVolunteer: Bool
    var vaGovApiSynced: Bool
    var vaProfileId: String
    var ebenefitsSynced: Bool
    var myhealthevetConnected: Bool
    var lastApiSync: Date?
    var apiSyncStatus: String
    var recordCreatedDate: Date
    var recordCreatedBy: String
    var recordModifiedDate: Date
    var recordModifiedBy: String
    var hipaaConsentSigned: Bool
    var hipaaConsentDate: Date?
    var privacyNoticeAcknowledged: Bool
    var termsOfServiceAccepted: Bool
    var gdprDataRequest: Bool
    var recordRetentionDate: Date?
    var claims: [Claim]
    var documents: [Document]
    
    init(veteranId: String, ssnLastFour: String, firstName: String, middleName: String, lastName: String, suffix: String, preferredName: String, dateOfBirth: Date, gender: String, maritalStatus: String, emailPrimary: String, emailSecondary: String, phonePrimary: String, phoneSecondary: String, phoneType: String, addressStreet: String, addressCity: String?, addressState: String?, addressZip: String, county: String, mailingAddressDifferent: Bool, homelessStatus: String, preferredContactMethod: String, preferredContactTime: String, languagePrimary: String, interpreterNeeded: Bool, serviceBranch: String, serviceComponent: String, serviceStartDate: Date, serviceEndDate: Date, yearsOfService: Int, dischargeDate: Date, dischargeStatus: String, dischargeUpgradeSought: Bool, rankAtSeparation: String, militaryOccupation: String, unitAssignments: String, deploymentLocations: String, combatVeteran: Bool, combatTheaters: String, purpleHeartRecipient: Bool, medalsAndAwards: String, powStatus: String, agentOrangeExposure: Bool, radiationExposure: Bool, burnPitExposure: Bool, gulfWarService: Bool, campLejeuneExposure: Bool, pactActEligible: Bool, currentDisabilityRating: Int, vaHealthcareEnrolled: Bool, healthcareEnrollmentDate: Date?, priorityGroup: String, vaMedicalCenter: String, vaClinic: String, primaryCareProvider: String, patientAdvocateContact: String, educationBenefits: String, giBillStartDate: Date?, educationEntitlementMonths: Int, percentEligible: Int, yellowRibbon: Bool, currentSchool: String, degreeProgram: String, graduationDate: Date?, vrAndEEnrolled: Bool, vrAndECounselor: String, homeLoanCoeIssued: Bool, homeLoanCoeDate: Date?, homeLoanEntitlementRemaining: Int, homeLoanUsedCount: Int, currentVaLoanActive: Bool, homeLoanDefault: Bool, irrrlEligible: Bool, sgliActive: Bool, vgliEnrolled: Bool, vgliCoverageAmount: Int, vmliEligible: Bool, pensionBenefits: Bool, aidAndAttendance: Bool, houseboundBenefit: Bool, burialBenefits: Bool, monthlyCompensation: Double, compensationStartDate: Date?, backPayOwed: Double, backPayReceived: Double, backPayDate: Date?, paymentMethod: String, bankAccountOnFile: Bool, paymentHeld: Bool, paymentHoldReason: String, overpaymentDebt: Bool, debtAmount: Double, debtRepaymentPlan: String, offsetActive: Bool, hasDependents: Bool, spouseDependent: Bool, numberOfChildren: Int, numberOfDisabledChildren: Int, dependentParent: Bool, derivativeBenefits: Bool, intakeDate: Date, caseOpenedDate: Date, caseStatus: String, assignedVso: String, vsoOrganization: String, assignedCounselor: String, counselorNotes: String, casePriority: String, priorityReason: String, nextActionItem: String, nextActionOwner: String, nextFollowupDate: Date?, lastContactDate: Date?, lastContactMethod: String, contactAttempts: Int, veteranResponsive: String, barriersToClaim: String, requiresLegalAssistance: Bool, attorneyName: String, powerOfAttorney: Bool, poaOrganization: String, fiduciaryNeeded: Bool, fiduciaryAppointed: Bool, successLikelihood: String, confidenceReasoning: String, estimatedCompletionDate: Date?, caseClosedDate: Date?, caseOutcome: String, satisfactionRating: Int, testimonialProvided: Bool, referralSource: String, wouldRecommend: Bool, terminalIllness: Bool, financialHardship: Bool, homelessVeteran: Bool, homelessVeteranCoordinator: String, incarcerated: Bool, mentalHealthCrisis: Bool, suicideRisk: Bool, crisisLineContacted: Bool, substanceAbuse: Bool, mstSurvivor: Bool, mstCoordinatorContact: String, womenVeteran: Bool, minorityVeteran: Bool, lgbtqVeteran: Bool, elderlyVeteran: Bool, formerGuardReserve: Bool, blueWaterNavy: Bool, disabledVeteran: Bool, socialSecurityDisability: Bool, unemployed: Bool, underemployed: Bool, portalAccountCreated: Bool, portalRegistrationDate: Date?, portalLastLogin: Date?, portalLoginCount: Int, idMeVerified: Bool, idMeVerificationDate: Date?, loginGovVerified: Bool, twoFactorEnabled: Bool, documentUploads: Int, portalMessagesSent: Int, emailNotificationsEnabled: Bool, smsNotificationsEnabled: Bool, optInMarketing: Bool, newsletterSubscriber: Bool, webinarInvitations: Bool, surveyParticipation: Bool, communityForumMember: Bool, advocacyVolunteer: Bool, vaGovApiSynced: Bool, vaProfileId: String, ebenefitsSynced: Bool, myhealthevetConnected: Bool, lastApiSync: Date?, apiSyncStatus: String, recordCreatedBy: String, recordModifiedBy: String, hipaaConsentSigned: Bool, hipaaConsentDate: Date?, privacyNoticeAcknowledged: Bool, termsOfServiceAccepted: Bool, gdprDataRequest: Bool, recordRetentionDate: Date?) {
        self.id = UUID()
        self.veteranId = veteranId
        self.ssnLastFour = ssnLastFour
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.suffix = suffix
        self.preferredName = preferredName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.maritalStatus = maritalStatus
        self.emailPrimary = emailPrimary
        self.emailSecondary = emailSecondary
        self.phonePrimary = phonePrimary
        self.phoneSecondary = phoneSecondary
        self.phoneType = phoneType
        self.addressStreet = addressStreet
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressZip = addressZip
        self.county = county
        self.mailingAddressDifferent = mailingAddressDifferent
        self.homelessStatus = homelessStatus
        self.preferredContactMethod = preferredContactMethod
        self.preferredContactTime = preferredContactTime
        self.languagePrimary = languagePrimary
        self.interpreterNeeded = interpreterNeeded
        self.serviceBranch = serviceBranch
        self.serviceComponent = serviceComponent
        self.serviceStartDate = serviceStartDate
        self.serviceEndDate = serviceEndDate
        self.yearsOfService = yearsOfService
        self.dischargeDate = dischargeDate
        self.dischargeStatus = dischargeStatus
        self.dischargeUpgradeSought = dischargeUpgradeSought
        self.rankAtSeparation = rankAtSeparation
        self.militaryOccupation = militaryOccupation
        self.unitAssignments = unitAssignments
        self.deploymentLocations = deploymentLocations
        self.combatVeteran = combatVeteran
        self.combatTheaters = combatTheaters
        self.purpleHeartRecipient = purpleHeartRecipient
        self.medalsAndAwards = medalsAndAwards
        self.powStatus = powStatus
        self.agentOrangeExposure = agentOrangeExposure
        self.radiationExposure = radiationExposure
        self.burnPitExposure = burnPitExposure
        self.gulfWarService = gulfWarService
        self.campLejeuneExposure = campLejeuneExposure
        self.pactActEligible = pactActEligible
        self.currentDisabilityRating = currentDisabilityRating
        self.vaHealthcareEnrolled = vaHealthcareEnrolled
        self.healthcareEnrollmentDate = healthcareEnrollmentDate
        self.priorityGroup = priorityGroup
        self.vaMedicalCenter = vaMedicalCenter
        self.vaClinic = vaClinic
        self.primaryCareProvider = primaryCareProvider
        self.patientAdvocateContact = patientAdvocateContact
        self.educationBenefits = educationBenefits
        self.giBillStartDate = giBillStartDate
        self.educationEntitlementMonths = educationEntitlementMonths
        self.percentEligible = percentEligible
        self.yellowRibbon = yellowRibbon
        self.currentSchool = currentSchool
        self.degreeProgram = degreeProgram
        self.graduationDate = graduationDate
        self.vrAndEEnrolled = vrAndEEnrolled
        self.vrAndECounselor = vrAndECounselor
        self.homeLoanCoeIssued = homeLoanCoeIssued
        self.homeLoanCoeDate = homeLoanCoeDate
        self.homeLoanEntitlementRemaining = homeLoanEntitlementRemaining
        self.homeLoanUsedCount = homeLoanUsedCount
        self.currentVaLoanActive = currentVaLoanActive
        self.homeLoanDefault = homeLoanDefault
        self.irrrlEligible = irrrlEligible
        self.sgliActive = sgliActive
        self.vgliEnrolled = vgliEnrolled
        self.vgliCoverageAmount = vgliCoverageAmount
        self.vmliEligible = vmliEligible
        self.pensionBenefits = pensionBenefits
        self.aidAndAttendance = aidAndAttendance
        self.houseboundBenefit = houseboundBenefit
        self.burialBenefits = burialBenefits
        self.monthlyCompensation = monthlyCompensation
        self.compensationStartDate = compensationStartDate
        self.backPayOwed = backPayOwed
        self.backPayReceived = backPayReceived
        self.backPayDate = backPayDate
        self.paymentMethod = paymentMethod
        self.bankAccountOnFile = bankAccountOnFile
        self.paymentHeld = paymentHeld
        self.paymentHoldReason = paymentHoldReason
        self.overpaymentDebt = overpaymentDebt
        self.debtAmount = debtAmount
        self.debtRepaymentPlan = debtRepaymentPlan
        self.offsetActive = offsetActive
        self.hasDependents = hasDependents
        self.spouseDependent = spouseDependent
        self.numberOfChildren = numberOfChildren
        self.numberOfDisabledChildren = numberOfDisabledChildren
        self.dependentParent = dependentParent
        self.derivativeBenefits = derivativeBenefits
        self.intakeDate = intakeDate
        self.caseOpenedDate = caseOpenedDate
        self.caseStatus = caseStatus
        self.assignedVso = assignedVso
        self.vsoOrganization = vsoOrganization
        self.assignedCounselor = assignedCounselor
        self.counselorNotes = counselorNotes
        self.casePriority = casePriority
        self.priorityReason = priorityReason
        self.nextActionItem = nextActionItem
        self.nextActionOwner = nextActionOwner
        self.nextFollowupDate = nextFollowupDate
        self.lastContactDate = lastContactDate
        self.lastContactMethod = lastContactMethod
        self.contactAttempts = contactAttempts
        self.veteranResponsive = veteranResponsive
        self.barriersToClaim = barriersToClaim
        self.requiresLegalAssistance = requiresLegalAssistance
        self.attorneyName = attorneyName
        self.powerOfAttorney = powerOfAttorney
        self.poaOrganization = poaOrganization
        self.fiduciaryNeeded = fiduciaryNeeded
        self.fiduciaryAppointed = fiduciaryAppointed
        self.successLikelihood = successLikelihood
        self.confidenceReasoning = confidenceReasoning
        self.estimatedCompletionDate = estimatedCompletionDate
        self.caseClosedDate = caseClosedDate
        self.caseOutcome = caseOutcome
        self.satisfactionRating = satisfactionRating
        self.testimonialProvided = testimonialProvided
        self.referralSource = referralSource
        self.wouldRecommend = wouldRecommend
        self.terminalIllness = terminalIllness
        self.financialHardship = financialHardship
        self.homelessVeteran = homelessVeteran
        self.homelessVeteranCoordinator = homelessVeteranCoordinator
        self.incarcerated = incarcerated
        self.mentalHealthCrisis = mentalHealthCrisis
        self.suicideRisk = suicideRisk
        self.crisisLineContacted = crisisLineContacted
        self.substanceAbuse = substanceAbuse
        self.mstSurvivor = mstSurvivor
        self.mstCoordinatorContact = mstCoordinatorContact
        self.womenVeteran = womenVeteran
        self.minorityVeteran = minorityVeteran
        self.lgbtqVeteran = lgbtqVeteran
        self.elderlyVeteran = elderlyVeteran
        self.formerGuardReserve = formerGuardReserve
        self.blueWaterNavy = blueWaterNavy
        self.disabledVeteran = disabledVeteran
        self.socialSecurityDisability = socialSecurityDisability
        self.unemployed = unemployed
        self.underemployed = underemployed
        self.portalAccountCreated = portalAccountCreated
        self.portalRegistrationDate = portalRegistrationDate
        self.portalLastLogin = portalLastLogin
        self.portalLoginCount = portalLoginCount
        self.idMeVerified = idMeVerified
        self.idMeVerificationDate = idMeVerificationDate
        self.loginGovVerified = loginGovVerified
        self.twoFactorEnabled = twoFactorEnabled
        self.documentUploads = documentUploads
        self.portalMessagesSent = portalMessagesSent
        self.emailNotificationsEnabled = emailNotificationsEnabled
        self.smsNotificationsEnabled = smsNotificationsEnabled
        self.optInMarketing = optInMarketing
        self.newsletterSubscriber = newsletterSubscriber
        self.webinarInvitations = webinarInvitations
        self.surveyParticipation = surveyParticipation
        self.communityForumMember = communityForumMember
        self.advocacyVolunteer = advocacyVolunteer
        self.vaGovApiSynced = vaGovApiSynced
        self.vaProfileId = vaProfileId
        self.ebenefitsSynced = ebenefitsSynced
        self.myhealthevetConnected = myhealthevetConnected
        self.lastApiSync = lastApiSync
        self.apiSyncStatus = apiSyncStatus
        self.recordCreatedDate = Date()
        self.recordCreatedBy = recordCreatedBy
        self.recordModifiedDate = Date()
        self.recordModifiedBy = recordModifiedBy
        self.hipaaConsentSigned = hipaaConsentSigned
        self.hipaaConsentDate = hipaaConsentDate
        self.privacyNoticeAcknowledged = privacyNoticeAcknowledged
        self.termsOfServiceAccepted = termsOfServiceAccepted
        self.gdprDataRequest = gdprDataRequest
        self.recordRetentionDate = recordRetentionDate
        self.claims = []
        self.documents = []
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
}

// MARK: - Claim Model
@Model
final class Claim {
    var id: UUID
    var veteran: Veteran?
    var claimNumber: String
    var claimType: String
    var claimStatus: String
    var claimFiledDate: Date
    var claimReceivedDate: Date?
    var claimDecisionDate: Date?
    var decisionNotificationDate: Date?
    var daysPending: Int
    var targetCompletionDate: Date?
    var actualCompletionDate: Date?
    var primaryCondition: String
    var primaryConditionCategory: String
    var secondaryConditions: String
    var totalConditionsClaimed: Int
    var serviceConnectedConditions: String
    var nonServiceConnected: String
    var bilateralFactor: Bool
    var individualUnemployability: Bool
    var specialMonthlyCompensation: Bool
    var nexusLetterRequired: Bool
    var nexusLetterObtained: Bool
    var nexusProviderName: String
    var nexusLetterDate: Date?
    var dbqCompleted: Bool
    var cAndPExamRequired: Bool
    var cAndPExamDate: Date?
    var cAndPExamType: String
    var cAndPExamCompleted: Bool
    var cAndPFavorable: Bool
    var buddyStatementProvided: Bool
    var numberBuddyStatements: Int
    var dd214OnFile: Bool
    var dd214UploadDate: Date?
    var dd214Type: String
    var serviceTreatmentRecords: Bool
    var strRequestDate: Date?
    var strReceivedDate: Date?
    var vaMedicalRecords: Bool
    var vaRecordsRequestDate: Date?
    var privateMedicalRecords: Bool
    var privateRecordsComplete: Bool
    var medicalReleaseSigned: Bool
    var intentToFileDate: Date?
    var itfConfirmationNumber: String
    var effectiveDate: Date?
    var vaForm21526ez: Bool
    var vaForm214142: Bool
    var vaForm21781: Bool
    var vaForm21781a: Bool
    var dependentVerification: Bool
    var marriageCertificate: Bool
    var birthCertificates: Bool
    var appealFiled: Bool
    var appealType: String
    var appealFiledDate: Date?
    var appealAcknowledgmentDate: Date?
    var appealStatus: String
    var appealDocketNumber: String
    var noticeOfDisagreementDate: Date?
    var statementOfCaseDate: Date?
    var ssocDate: Date?
    var form9Date: Date?
    var boardHearingRequested: Bool
    var boardHearingType: String
    var boardHearingDate: Date?
    var boardHearingCompleted: Bool
    var hearingTranscriptReceived: Bool
    var newEvidenceSubmitted: Bool
    var remandReason: String
    var appealDecisionDate: Date?
    var appealOutcome: String
    var cavcFilingDeadline: Date?
    var documents: [Document]
    var activities: [ClaimActivity]
    var conditions: [MedicalCondition]
    
    init(claimNumber: String, claimType: String, claimStatus: String, claimFiledDate: Date, claimReceivedDate: Date?, claimDecisionDate: Date?, decisionNotificationDate: Date?, daysPending: Int, targetCompletionDate: Date?, actualCompletionDate: Date?, primaryCondition: String, primaryConditionCategory: String, secondaryConditions: String, totalConditionsClaimed: Int, serviceConnectedConditions: String, nonServiceConnected: String, bilateralFactor: Bool, individualUnemployability: Bool, specialMonthlyCompensation: Bool, nexusLetterRequired: Bool, nexusLetterObtained: Bool, nexusProviderName: String, nexusLetterDate: Date?, dbqCompleted: Bool, cAndPExamRequired: Bool, cAndPExamDate: Date?, cAndPExamType: String, cAndPExamCompleted: Bool, cAndPFavorable: Bool, buddyStatementProvided: Bool, numberBuddyStatements: Int, dd214OnFile: Bool, dd214UploadDate: Date?, dd214Type: String, serviceTreatmentRecords: Bool, strRequestDate: Date?, strReceivedDate: Date?, vaMedicalRecords: Bool, vaRecordsRequestDate: Date?, privateMedicalRecords: Bool, privateRecordsComplete: Bool, medicalReleaseSigned: Bool, intentToFileDate: Date?, itfConfirmationNumber: String, effectiveDate: Date?, vaForm21526ez: Bool, vaForm214142: Bool, vaForm21781: Bool, vaForm21781a: Bool, dependentVerification: Bool, marriageCertificate: Bool, birthCertificates: Bool, appealFiled: Bool, appealType: String, appealFiledDate: Date?, appealAcknowledgmentDate: Date?, appealStatus: String, appealDocketNumber: String, noticeOfDisagreementDate: Date?, statementOfCaseDate: Date?, ssocDate: Date?, form9Date: Date?, boardHearingRequested: Bool, boardHearingType: String, boardHearingDate: Date?, boardHearingCompleted: Bool, hearingTranscriptReceived: Bool, newEvidenceSubmitted: Bool, remandReason: String, appealDecisionDate: Date?, appealOutcome: String, cavcFilingDeadline: Date?) {
        self.id = UUID()
        self.claimNumber = claimNumber
        self.claimType = claimType
        self.claimStatus = claimStatus
        self.claimFiledDate = claimFiledDate
        self.claimReceivedDate = claimReceivedDate
        self.claimDecisionDate = claimDecisionDate
        self.decisionNotificationDate = decisionNotificationDate
        self.daysPending = daysPending
        self.targetCompletionDate = targetCompletionDate
        self.actualCompletionDate = actualCompletionDate
        self.primaryCondition = primaryCondition
        self.primaryConditionCategory = primaryConditionCategory
        self.secondaryConditions = secondaryConditions
        self.totalConditionsClaimed = totalConditionsClaimed
        self.serviceConnectedConditions = serviceConnectedConditions
        self.nonServiceConnected = nonServiceConnected
        self.bilateralFactor = bilateralFactor
        self.individualUnemployability = individualUnemployability
        self.specialMonthlyCompensation = specialMonthlyCompensation
        self.nexusLetterRequired = nexusLetterRequired
        self.nexusLetterObtained = nexusLetterObtained
        self.nexusProviderName = nexusProviderName
        self.nexusLetterDate = nexusLetterDate
        self.dbqCompleted = dbqCompleted
        self.cAndPExamRequired = cAndPExamRequired
        self.cAndPExamDate = cAndPExamDate
        self.cAndPExamType = cAndPExamType
        self.cAndPExamCompleted = cAndPExamCompleted
        self.cAndPFavorable = cAndPFavorable
        self.buddyStatementProvided = buddyStatementProvided
        self.numberBuddyStatements = numberBuddyStatements
        self.dd214OnFile = dd214OnFile
        self.dd214UploadDate = dd214UploadDate
        self.dd214Type = dd214Type
        self.serviceTreatmentRecords = serviceTreatmentRecords
        self.strRequestDate = strRequestDate
        self.strReceivedDate = strReceivedDate
        self.vaMedicalRecords = vaMedicalRecords
        self.vaRecordsRequestDate = vaRecordsRequestDate
        self.privateMedicalRecords = privateMedicalRecords
        self.privateRecordsComplete = privateRecordsComplete
        self.medicalReleaseSigned = medicalReleaseSigned
        self.intentToFileDate = intentToFileDate
        self.itfConfirmationNumber = itfConfirmationNumber
        self.effectiveDate = effectiveDate
        self.vaForm21526ez = vaForm21526ez
        self.vaForm214142 = vaForm214142
        self.vaForm21781 = vaForm21781
        self.vaForm21781a = vaForm21781a
        self.dependentVerification = dependentVerification
        self.marriageCertificate = marriageCertificate
        self.birthCertificates = birthCertificates
        self.appealFiled = appealFiled
        self.appealType = appealType
        self.appealFiledDate = appealFiledDate
        self.appealAcknowledgmentDate = appealAcknowledgmentDate
        self.appealStatus = appealStatus
        self.appealDocketNumber = appealDocketNumber
        self.noticeOfDisagreementDate = noticeOfDisagreementDate
        self.statementOfCaseDate = statementOfCaseDate
        self.ssocDate = ssocDate
        self.form9Date = form9Date
        self.boardHearingRequested = boardHearingRequested
        self.boardHearingType = boardHearingType
        self.boardHearingDate = boardHearingDate
        self.boardHearingCompleted = boardHearingCompleted
        self.hearingTranscriptReceived = hearingTranscriptReceived
        self.newEvidenceSubmitted = newEvidenceSubmitted
        self.remandReason = remandReason
        self.appealDecisionDate = appealDecisionDate
        self.appealOutcome = appealOutcome
        self.cavcFilingDeadline = cavcFilingDeadline
        self.documents = []
        self.activities = []
        self.conditions = []
    }
}

// MARK: - Document Model
@Model
final class Document {
    var id: UUID
    var veteran: Veteran?
    var claim: Claim?
    var fileName: String
    var fileType: String
    var fileSize: Int64
    var uploadDate: Date
    var documentType: DocumentType
    var documentDescription: String
    var filePath: String
    
    init(fileName: String, fileType: String, fileSize: Int64, documentType: DocumentType, documentDescription: String, filePath: String) {
        self.id = UUID()
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.uploadDate = Date()
        self.documentType = documentType
        self.documentDescription = documentDescription
        self.filePath = filePath
    }
}

// MARK: - Claim Activity Model
@Model
final class ClaimActivity {
    var id: UUID
    var claim: Claim?
    var activityType: ActivityType
    var claimDescription: String
    var date: Date
    var performedBy: String
    var notes: String
    
    init(activityType: ActivityType, claimDescription: String, performedBy: String, notes: String = "") {
        self.id = UUID()
        self.activityType = activityType
        self.claimDescription = claimDescription
        self.date = Date()
        self.performedBy = performedBy
        self.notes = notes
    }
}

// MARK: - Enums
enum ClaimStatus: String, CaseIterable, Codable {
    case new = "New"
    case inProgress = "In Progress"
    case underReview = "Under Review"
    case reviewOfEvidence = "Review of Evidence"
    case preparationForDecision = "Preparation for Decision"
    case pendingDecisionApproval = "Pending Decision Approval"
    case pendingNotification = "Pending Notification"
    case complete = "Complete"
    case closed = "Closed"
    case appealed = "Appealed"
    case denied = "Denied"
    case approved = "Approved"
}

enum ClaimPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    case critical = "Critical"
}

enum DocumentType: String, CaseIterable, Codable {
    case medicalRecord = "Medical Record"
    case serviceRecord = "Service Record"
    case dischargeDocument = "Discharge Document"
    case claimForm = "Claim Form"
    case correspondence = "Correspondence"
    case nexusLetter = "Nexus Letter"
    case dbq = "Disability Benefits Questionnaire"
    case buddyStatement = "Buddy Statement"
    case dd214 = "DD-214"
    case vaForm = "VA Form"
    case other = "Other"
}

enum ActivityType: String, CaseIterable, Codable {
    case phoneCall = "Phone Call"
    case email = "Email"
    case documentUpload = "Document Upload"
    case statusChange = "Status Change"
    case note = "Note"
    case meeting = "Meeting"
    case cAndPExam = "C&P Exam"
    case nexusLetter = "Nexus Letter"
    case appeal = "Appeal"
    case hearing = "Hearing"
    case other = "Other"
}

// MARK: - Email Log Model
@Model
final class EmailLog: Codable {
    var id: UUID
    var messageId: String
    var timestamp: Date
    var recipients: [String]
    var subject: String
    var status: EmailStatus
    var templateId: String?
    var htmlBody: String?
    var textBody: String?
    var replyTo: String?
    var errorMessage: String?
    
    // Relationships
    var veteran: Veteran?
    var claim: Claim?
    
    init(
        messageId: String,
        recipients: [String],
        subject: String,
        status: EmailStatus = .sent,
        templateId: String? = nil,
        htmlBody: String? = nil,
        textBody: String? = nil,
        replyTo: String? = nil,
        errorMessage: String? = nil,
        veteran: Veteran? = nil,
        claim: Claim? = nil
    ) {
        self.id = UUID()
        self.messageId = messageId
        self.timestamp = Date()
        self.recipients = recipients
        self.subject = subject
        self.status = status
        self.templateId = templateId
        self.htmlBody = htmlBody
        self.textBody = textBody
        self.replyTo = replyTo
        self.errorMessage = errorMessage
        self.veteran = veteran
        self.claim = claim
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, messageId, timestamp, recipients, subject, status, templateId, htmlBody, textBody, replyTo, errorMessage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        messageId = try container.decode(String.self, forKey: .messageId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        recipients = try container.decode([String].self, forKey: .recipients)
        subject = try container.decode(String.self, forKey: .subject)
        status = try container.decode(EmailStatus.self, forKey: .status)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        htmlBody = try container.decodeIfPresent(String.self, forKey: .htmlBody)
        textBody = try container.decodeIfPresent(String.self, forKey: .textBody)
        replyTo = try container.decodeIfPresent(String.self, forKey: .replyTo)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(recipients, forKey: .recipients)
        try container.encode(subject, forKey: .subject)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(templateId, forKey: .templateId)
        try container.encodeIfPresent(htmlBody, forKey: .htmlBody)
        try container.encodeIfPresent(textBody, forKey: .textBody)
        try container.encodeIfPresent(replyTo, forKey: .replyTo)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
    }
}

// MARK: - Email Status Enum
enum EmailStatus: String, CaseIterable, Codable {
    case sent = "Sent"
    case delivered = "Delivered"
    case opened = "Opened"
    case bounced = "Bounced"
    case failed = "Failed"
    case pending = "Pending"
    
    var color: String {
        switch self {
        case .sent, .delivered, .opened:
            return "green"
        case .bounced, .failed:
            return "red"
        case .pending:
            return "orange"
        }
    }
    
    var icon: String {
        switch self {
        case .sent:
            return "paperplane"
        case .delivered:
            return "checkmark.circle"
        case .opened:
            return "eye"
        case .bounced:
            return "arrow.uturn.backward"
        case .failed:
            return "xmark.circle"
        case .pending:
            return "clock"
        }
    }
}
