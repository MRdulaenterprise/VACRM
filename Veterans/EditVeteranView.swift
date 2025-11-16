//
//  EditVeteranView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct EditVeteranView: View {
    let veteran: Veteran
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var middleName: String
    @State private var suffix: String
    @State private var preferredName: String
    @State private var email: String
    @State private var emailSecondary: String
    @State private var phone: String
    @State private var phoneSecondary: String
    @State private var phoneType: String
    @State private var dateOfBirth: Date
    @State private var gender: String
    @State private var maritalStatus: String
    @State private var serviceBranch: String
    @State private var serviceComponent: String
    @State private var serviceStartDate: Date
    @State private var serviceEndDate: Date
    @State private var dischargeType: String
    @State private var dischargeDate: Date
    @State private var rankAtSeparation: String
    @State private var militaryOccupation: String
    @State private var socialSecurityNumber: String
    @State private var address: String
    @State private var city: String
    @State private var state: String
    @State private var zipCode: String
    @State private var county: String
    @State private var homelessStatus: String
    @State private var preferredContactMethod: String
    @State private var preferredContactTime: String
    @State private var languagePrimary: String
    @State private var interpreterNeeded: Bool
    @State private var emergencyContact: String
    @State private var emergencyPhone: String
    @State private var notes: String
    @State private var combatVeteran: Bool
    @State private var purpleHeartRecipient: Bool
    @State private var powStatus: String
    @State private var agentOrangeExposure: Bool
    @State private var radiationExposure: Bool
    @State private var burnPitExposure: Bool
    @State private var gulfWarService: Bool
    @State private var campLejeuneExposure: Bool
    @State private var pactActEligible: Bool
    @State private var currentDisabilityRating: Int
    @State private var vaHealthcareEnrolled: Bool
    @State private var educationBenefits: String
    @State private var homeLoanCoeIssued: Bool
    @State private var pensionBenefits: Bool
    @State private var aidAndAttendance: Bool
    @State private var burialBenefits: Bool
    @State private var monthlyCompensation: Double
    @State private var hasDependents: Bool
    @State private var numberOfChildren: Int
    @State private var caseStatus: String
    @State private var assignedVso: String
    @State private var assignedCounselor: String
    @State private var casePriority: String
    @State private var terminalIllness: Bool
    @State private var financialHardship: Bool
    @State private var homelessVeteran: Bool
    @State private var incarcerated: Bool
    @State private var mentalHealthCrisis: Bool
    @State private var substanceAbuse: Bool
    @State private var mstSurvivor: Bool
    @State private var womenVeteran: Bool
    @State private var minorityVeteran: Bool
    @State private var lgbtqVeteran: Bool
    @State private var elderlyVeteran: Bool
    @State private var disabledVeteran: Bool
    @State private var unemployed: Bool
    @State private var portalAccountCreated: Bool
    @State private var idMeVerified: Bool
    @State private var hipaaConsentSigned: Bool
    
    // Additional missing fields
    @State private var yearsOfService: Int
    @State private var dischargeUpgradeSought: Bool
    @State private var unitAssignments: String
    @State private var deploymentLocations: String
    @State private var combatTheaters: String
    @State private var medalsAndAwards: String
    @State private var healthcareEnrollmentDate: Date?
    @State private var priorityGroup: String
    @State private var vaMedicalCenter: String
    @State private var vaClinic: String
    @State private var primaryCareProvider: String
    @State private var patientAdvocateContact: String
    @State private var giBillStartDate: Date?
    @State private var educationEntitlementMonths: Int
    @State private var percentEligible: Int
    @State private var yellowRibbon: Bool
    @State private var currentSchool: String
    @State private var degreeProgram: String
    @State private var graduationDate: Date?
    @State private var vrAndEEnrolled: Bool
    @State private var vrAndECounselor: String
    @State private var homeLoanCoeDate: Date?
    @State private var homeLoanEntitlementRemaining: Int
    @State private var homeLoanUsedCount: Int
    @State private var currentVaLoanActive: Bool
    @State private var homeLoanDefault: Bool
    @State private var irrrlEligible: Bool
    @State private var sgliActive: Bool
    @State private var vgliEnrolled: Bool
    @State private var vgliCoverageAmount: Int
    @State private var vmliEligible: Bool
    @State private var houseboundBenefit: Bool
    @State private var compensationStartDate: Date?
    @State private var backPayOwed: Double
    @State private var backPayReceived: Double
    @State private var backPayDate: Date?
    @State private var paymentMethod: String
    @State private var bankAccountOnFile: Bool
    @State private var paymentHeld: Bool
    @State private var paymentHoldReason: String
    @State private var overpaymentDebt: Bool
    @State private var debtAmount: Double
    @State private var debtRepaymentPlan: String
    @State private var offsetActive: Bool
    @State private var spouseDependent: Bool
    @State private var numberOfDisabledChildren: Int
    @State private var dependentParent: Bool
    @State private var derivativeBenefits: Bool
    @State private var intakeDate: Date
    @State private var caseOpenedDate: Date
    @State private var vsoOrganization: String
    @State private var priorityReason: String
    @State private var nextActionItem: String
    @State private var nextActionOwner: String
    @State private var nextFollowupDate: Date?
    @State private var lastContactDate: Date?
    @State private var lastContactMethod: String
    @State private var contactAttempts: Int
    @State private var veteranResponsive: String
    @State private var barriersToClaim: String
    @State private var requiresLegalAssistance: Bool
    @State private var attorneyName: String
    @State private var powerOfAttorney: Bool
    @State private var poaOrganization: String
    @State private var fiduciaryNeeded: Bool
    @State private var fiduciaryAppointed: Bool
    @State private var successLikelihood: String
    @State private var confidenceReasoning: String
    @State private var estimatedCompletionDate: Date?
    @State private var caseClosedDate: Date?
    @State private var caseOutcome: String
    @State private var satisfactionRating: Int
    @State private var testimonialProvided: Bool
    @State private var referralSource: String
    @State private var wouldRecommend: Bool
    @State private var homelessVeteranCoordinator: String
    @State private var suicideRisk: Bool
    @State private var crisisLineContacted: Bool
    @State private var mstCoordinatorContact: String
    @State private var formerGuardReserve: Bool
    @State private var blueWaterNavy: Bool
    @State private var socialSecurityDisability: Bool
    @State private var underemployed: Bool
    @State private var mailingAddressDifferent: Bool
    @State private var secondaryPhone: String
    
    // MARK: - State for Collapsible Sections
    @State private var isPersonalInfoExpanded = true
    @State private var isContactInfoExpanded = true
    @State private var isAddressInfoExpanded = true
    @State private var isServiceInfoExpanded = true
    @State private var isEmergencyContactExpanded = false
    @State private var isAdditionalInfoExpanded = false
    @State private var isVABenefitsExpanded = false
    @State private var isCaseManagementExpanded = false
    @State private var isNotesExpanded = false
    
    private let serviceBranches = ["Army", "Navy", "Air Force", "Marines", "Coast Guard", "Space Force"]
    private let serviceComponents = ["Active Duty", "Reserve", "National Guard", "Veteran"]
    private let dischargeTypes = ["Honorable", "General", "Other Than Honorable", "Bad Conduct", "Dishonorable"]
    private let genders = ["Male", "Female", "Non-binary", "Not Specified"]
    private let maritalStatuses = ["Single", "Married", "Divorced", "Widowed", "Separated", "Not Specified"]
    private let phoneTypes = ["Mobile", "Home", "Work", "Other"]
    private let homelessStatuses = ["Stable Housing", "At Risk", "Homeless", "Shelter", "Unsheltered"]
    private let contactMethods = ["Email", "Phone", "Text", "Mail", "In Person"]
    private let contactTimes = ["Business Hours", "Evenings", "Weekends", "Any Time"]
    private let languages = ["English", "Spanish", "French", "German", "Other"]
    private let powStatuses = ["No", "Yes", "Unknown"]
    private let caseStatuses = ["New", "Active", "Pending", "Closed", "On Hold"]
    private let casePriorities = ["Low", "Normal", "High", "Urgent", "Critical"]
    
    init(veteran: Veteran) {
        self.veteran = veteran
        _firstName = State(initialValue: veteran.firstName)
        _lastName = State(initialValue: veteran.lastName)
        _middleName = State(initialValue: veteran.middleName)
        _suffix = State(initialValue: veteran.suffix)
        _preferredName = State(initialValue: veteran.preferredName)
        _email = State(initialValue: veteran.emailPrimary)
        _emailSecondary = State(initialValue: veteran.emailSecondary)
        _phone = State(initialValue: veteran.phonePrimary)
        _phoneSecondary = State(initialValue: veteran.phoneSecondary)
        _phoneType = State(initialValue: veteran.phoneType)
        _dateOfBirth = State(initialValue: veteran.dateOfBirth)
        _gender = State(initialValue: veteran.gender)
        _maritalStatus = State(initialValue: veteran.maritalStatus)
        _serviceBranch = State(initialValue: veteran.serviceBranch)
        _serviceComponent = State(initialValue: veteran.serviceComponent)
        _serviceStartDate = State(initialValue: veteran.serviceStartDate)
        _serviceEndDate = State(initialValue: veteran.serviceEndDate)
        _dischargeType = State(initialValue: veteran.dischargeStatus)
        _dischargeDate = State(initialValue: veteran.dischargeDate)
        _rankAtSeparation = State(initialValue: veteran.rankAtSeparation)
        _militaryOccupation = State(initialValue: veteran.militaryOccupation)
        _socialSecurityNumber = State(initialValue: veteran.ssnLastFour)
        _address = State(initialValue: veteran.addressStreet ?? "")
        _city = State(initialValue: veteran.addressCity ?? "")
        _state = State(initialValue: veteran.addressState ?? "")
        _zipCode = State(initialValue: veteran.addressZip)
        _county = State(initialValue: veteran.county)
        _homelessStatus = State(initialValue: veteran.homelessStatus)
        _preferredContactMethod = State(initialValue: veteran.preferredContactMethod)
        _preferredContactTime = State(initialValue: veteran.preferredContactTime)
        _languagePrimary = State(initialValue: veteran.languagePrimary)
        _interpreterNeeded = State(initialValue: veteran.interpreterNeeded)
        _emergencyContact = State(initialValue: veteran.preferredContactMethod)
        _emergencyPhone = State(initialValue: veteran.phoneSecondary)
        _notes = State(initialValue: veteran.counselorNotes)
        _combatVeteran = State(initialValue: veteran.combatVeteran)
        _purpleHeartRecipient = State(initialValue: veteran.purpleHeartRecipient)
        _powStatus = State(initialValue: veteran.powStatus)
        _agentOrangeExposure = State(initialValue: veteran.agentOrangeExposure)
        _radiationExposure = State(initialValue: veteran.radiationExposure)
        _burnPitExposure = State(initialValue: veteran.burnPitExposure)
        _gulfWarService = State(initialValue: veteran.gulfWarService)
        _campLejeuneExposure = State(initialValue: veteran.campLejeuneExposure)
        _pactActEligible = State(initialValue: veteran.pactActEligible)
        _currentDisabilityRating = State(initialValue: veteran.currentDisabilityRating)
        _vaHealthcareEnrolled = State(initialValue: veteran.vaHealthcareEnrolled)
        _educationBenefits = State(initialValue: veteran.educationBenefits)
        _homeLoanCoeIssued = State(initialValue: veteran.homeLoanCoeIssued)
        _pensionBenefits = State(initialValue: veteran.pensionBenefits)
        _aidAndAttendance = State(initialValue: veteran.aidAndAttendance)
        _burialBenefits = State(initialValue: veteran.burialBenefits)
        _monthlyCompensation = State(initialValue: veteran.monthlyCompensation)
        _hasDependents = State(initialValue: veteran.hasDependents)
        _numberOfChildren = State(initialValue: veteran.numberOfChildren)
        _caseStatus = State(initialValue: veteran.caseStatus)
        _assignedVso = State(initialValue: veteran.assignedVso)
        _assignedCounselor = State(initialValue: veteran.assignedCounselor)
        _casePriority = State(initialValue: veteran.casePriority)
        _terminalIllness = State(initialValue: veteran.terminalIllness)
        _financialHardship = State(initialValue: veteran.financialHardship)
        _homelessVeteran = State(initialValue: veteran.homelessVeteran)
        _incarcerated = State(initialValue: veteran.incarcerated)
        _mentalHealthCrisis = State(initialValue: veteran.mentalHealthCrisis)
        _substanceAbuse = State(initialValue: veteran.substanceAbuse)
        _mstSurvivor = State(initialValue: veteran.mstSurvivor)
        _womenVeteran = State(initialValue: veteran.womenVeteran)
        _minorityVeteran = State(initialValue: veteran.minorityVeteran)
        _lgbtqVeteran = State(initialValue: veteran.lgbtqVeteran)
        _elderlyVeteran = State(initialValue: veteran.elderlyVeteran)
        _disabledVeteran = State(initialValue: veteran.disabledVeteran)
        _unemployed = State(initialValue: veteran.unemployed)
        _portalAccountCreated = State(initialValue: veteran.portalAccountCreated)
        _idMeVerified = State(initialValue: veteran.idMeVerified)
        _hipaaConsentSigned = State(initialValue: veteran.hipaaConsentSigned)
        _yearsOfService = State(initialValue: veteran.yearsOfService)
        _dischargeUpgradeSought = State(initialValue: veteran.dischargeUpgradeSought)
        _unitAssignments = State(initialValue: veteran.unitAssignments)
        _deploymentLocations = State(initialValue: veteran.deploymentLocations)
        _combatTheaters = State(initialValue: veteran.combatTheaters)
        _medalsAndAwards = State(initialValue: veteran.medalsAndAwards)
        _healthcareEnrollmentDate = State(initialValue: veteran.healthcareEnrollmentDate)
        _priorityGroup = State(initialValue: veteran.priorityGroup)
        _vaMedicalCenter = State(initialValue: veteran.vaMedicalCenter)
        _vaClinic = State(initialValue: veteran.vaClinic)
        _primaryCareProvider = State(initialValue: veteran.primaryCareProvider)
        _patientAdvocateContact = State(initialValue: veteran.patientAdvocateContact)
        _giBillStartDate = State(initialValue: veteran.giBillStartDate)
        _educationEntitlementMonths = State(initialValue: veteran.educationEntitlementMonths)
        _percentEligible = State(initialValue: veteran.percentEligible)
        _yellowRibbon = State(initialValue: veteran.yellowRibbon)
        _currentSchool = State(initialValue: veteran.currentSchool)
        _degreeProgram = State(initialValue: veteran.degreeProgram)
        _graduationDate = State(initialValue: veteran.graduationDate)
        _vrAndEEnrolled = State(initialValue: veteran.vrAndEEnrolled)
        _vrAndECounselor = State(initialValue: veteran.vrAndECounselor)
        _homeLoanCoeDate = State(initialValue: veteran.homeLoanCoeDate)
        _homeLoanEntitlementRemaining = State(initialValue: veteran.homeLoanEntitlementRemaining)
        _homeLoanUsedCount = State(initialValue: veteran.homeLoanUsedCount)
        _currentVaLoanActive = State(initialValue: veteran.currentVaLoanActive)
        _homeLoanDefault = State(initialValue: veteran.homeLoanDefault)
        _irrrlEligible = State(initialValue: veteran.irrrlEligible)
        _sgliActive = State(initialValue: veteran.sgliActive)
        _vgliEnrolled = State(initialValue: veteran.vgliEnrolled)
        _vgliCoverageAmount = State(initialValue: veteran.vgliCoverageAmount)
        _vmliEligible = State(initialValue: veteran.vmliEligible)
        _houseboundBenefit = State(initialValue: veteran.houseboundBenefit)
        _compensationStartDate = State(initialValue: veteran.compensationStartDate)
        _backPayOwed = State(initialValue: veteran.backPayOwed)
        _backPayReceived = State(initialValue: veteran.backPayReceived)
        _backPayDate = State(initialValue: veteran.backPayDate)
        _paymentMethod = State(initialValue: veteran.paymentMethod)
        _bankAccountOnFile = State(initialValue: veteran.bankAccountOnFile)
        _paymentHeld = State(initialValue: veteran.paymentHeld)
        _paymentHoldReason = State(initialValue: veteran.paymentHoldReason)
        _overpaymentDebt = State(initialValue: veteran.overpaymentDebt)
        _debtAmount = State(initialValue: veteran.debtAmount)
        _debtRepaymentPlan = State(initialValue: veteran.debtRepaymentPlan)
        _offsetActive = State(initialValue: veteran.offsetActive)
        _spouseDependent = State(initialValue: veteran.spouseDependent)
        _numberOfDisabledChildren = State(initialValue: veteran.numberOfDisabledChildren)
        _dependentParent = State(initialValue: veteran.dependentParent)
        _derivativeBenefits = State(initialValue: veteran.derivativeBenefits)
        _intakeDate = State(initialValue: veteran.intakeDate)
        _caseOpenedDate = State(initialValue: veteran.caseOpenedDate)
        _vsoOrganization = State(initialValue: veteran.vsoOrganization)
        _priorityReason = State(initialValue: veteran.priorityReason)
        _nextActionItem = State(initialValue: veteran.nextActionItem)
        _nextActionOwner = State(initialValue: veteran.nextActionOwner)
        _nextFollowupDate = State(initialValue: veteran.nextFollowupDate)
        _lastContactDate = State(initialValue: veteran.lastContactDate)
        _lastContactMethod = State(initialValue: veteran.lastContactMethod)
        _contactAttempts = State(initialValue: veteran.contactAttempts)
        _veteranResponsive = State(initialValue: veteran.veteranResponsive)
        _barriersToClaim = State(initialValue: veteran.barriersToClaim)
        _requiresLegalAssistance = State(initialValue: veteran.requiresLegalAssistance)
        _attorneyName = State(initialValue: veteran.attorneyName)
        _powerOfAttorney = State(initialValue: veteran.powerOfAttorney)
        _poaOrganization = State(initialValue: veteran.poaOrganization)
        _fiduciaryNeeded = State(initialValue: veteran.fiduciaryNeeded)
        _fiduciaryAppointed = State(initialValue: veteran.fiduciaryAppointed)
        _successLikelihood = State(initialValue: veteran.successLikelihood)
        _confidenceReasoning = State(initialValue: veteran.confidenceReasoning)
        _estimatedCompletionDate = State(initialValue: veteran.estimatedCompletionDate)
        _caseClosedDate = State(initialValue: veteran.caseClosedDate)
        _caseOutcome = State(initialValue: veteran.caseOutcome)
        _satisfactionRating = State(initialValue: veteran.satisfactionRating)
        _testimonialProvided = State(initialValue: veteran.testimonialProvided)
        _referralSource = State(initialValue: veteran.referralSource)
        _wouldRecommend = State(initialValue: veteran.wouldRecommend)
        _homelessVeteranCoordinator = State(initialValue: veteran.homelessVeteranCoordinator)
        _suicideRisk = State(initialValue: veteran.suicideRisk)
        _crisisLineContacted = State(initialValue: veteran.crisisLineContacted)
        _mstCoordinatorContact = State(initialValue: veteran.mstCoordinatorContact)
        _formerGuardReserve = State(initialValue: veteran.formerGuardReserve)
        _blueWaterNavy = State(initialValue: veteran.blueWaterNavy)
        _socialSecurityDisability = State(initialValue: veteran.socialSecurityDisability)
        _underemployed = State(initialValue: veteran.underemployed)
        _mailingAddressDifferent = State(initialValue: veteran.mailingAddressDifferent)
        _secondaryPhone = State(initialValue: veteran.phoneSecondary)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Edit Veteran")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(veteran.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save Changes") {
                        saveVeteran()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    // Personal Information Section
                    CollapsibleSection(title: "Personal Information", icon: "person.fill", isExpanded: $isPersonalInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("First Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("First Name", text: $firstName)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Last Name", text: $lastName)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Middle Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Middle Name", text: $middleName)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Suffix")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Suffix", text: $suffix)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preferred Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Preferred Name", text: $preferredName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Gender")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Gender", selection: $gender) {
                                        ForEach(genders, id: \.self) { gender in
                                            Text(gender).tag(gender)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Marital Status")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Marital Status", selection: $maritalStatus) {
                                        ForEach(maritalStatuses, id: \.self) { status in
                                            Text(status).tag(status)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date of Birth")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Social Security Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Social Security Number", text: $socialSecurityNumber)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Service Information Section
                    CollapsibleSection(title: "Service Information", icon: "shield.fill", isExpanded: $isServiceInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Branch")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Service Branch", selection: $serviceBranch) {
                                        ForEach(serviceBranches, id: \.self) { branch in
                                            Text(branch).tag(branch)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Component")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Service Component", selection: $serviceComponent) {
                                        ForEach(serviceComponents, id: \.self) { component in
                                            Text(component).tag(component)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Start Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Service Start Date", selection: $serviceStartDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service End Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Service End Date", selection: $serviceEndDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Discharge Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Discharge Type", selection: $dischargeType) {
                                        ForEach(dischargeTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Discharge Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Discharge Date", selection: $dischargeDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rank at Separation")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Rank at Separation", text: $rankAtSeparation)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Military Occupation")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Military Occupation", text: $militaryOccupation)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Years of Service")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Stepper("\(yearsOfService) years", value: $yearsOfService, in: 0...50)
                            }
                            
                            Toggle("Discharge Upgrade Sought", isOn: $dischargeUpgradeSought)
                                .font(.subheadline)
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Contact Information Section
                    CollapsibleSection(title: "Contact Information", icon: "envelope.fill", isExpanded: $isContactInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Primary Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Primary Email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Secondary Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Secondary Email", text: $emailSecondary)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Primary Phone")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Primary Phone", text: $phone)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Phone Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Phone Type", selection: $phoneType) {
                                        ForEach(phoneTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Secondary Phone")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Secondary Phone", text: $phoneSecondary)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Preferred Contact Method")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Preferred Contact Method", selection: $preferredContactMethod) {
                                        ForEach(contactMethods, id: \.self) { method in
                                            Text(method).tag(method)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Preferred Contact Time")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Preferred Contact Time", selection: $preferredContactTime) {
                                        ForEach(contactTimes, id: \.self) { time in
                                            Text(time).tag(time)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Primary Language")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Primary Language", selection: $languagePrimary) {
                                        ForEach(languages, id: \.self) { language in
                                            Text(language).tag(language)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                Toggle("Interpreter Needed", isOn: $interpreterNeeded)
                                    .padding(.top, 24)
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Address Information Section
                    CollapsibleSection(title: "Address Information", icon: "house.fill", isExpanded: $isAddressInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Address")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Address", text: $address)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("City")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("City", text: $city)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("State")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("State", text: $state)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ZIP")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("ZIP", text: $zipCode)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("County")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("County", text: $county)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Homeless Status")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("Homeless Status", selection: $homelessStatus) {
                                    ForEach(homelessStatuses, id: \.self) { status in
                                        Text(status).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            Toggle("Mailing Address Different", isOn: $mailingAddressDifferent)
                                .font(.subheadline)
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Emergency Contact Section
                    CollapsibleSection(title: "Emergency Contact", icon: "phone.fill", isExpanded: $isEmergencyContactExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Emergency Contact Name")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Emergency Contact Name", text: $emergencyContact)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Emergency Contact Phone")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Emergency Contact Phone", text: $emergencyPhone)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Additional Information Section
                    CollapsibleSection(title: "Additional Information", icon: "info.circle.fill", isExpanded: $isAdditionalInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Service History")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                Toggle("Combat Veteran", isOn: $combatVeteran)
                                Toggle("Purple Heart Recipient", isOn: $purpleHeartRecipient)
                                Toggle("Agent Orange Exposure", isOn: $agentOrangeExposure)
                                Toggle("Radiation Exposure", isOn: $radiationExposure)
                                Toggle("Burn Pit Exposure", isOn: $burnPitExposure)
                                Toggle("Gulf War Service", isOn: $gulfWarService)
                                Toggle("Camp Lejeune Exposure", isOn: $campLejeuneExposure)
                                Toggle("PACT Act Eligible", isOn: $pactActEligible)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("POW Status")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Picker("POW Status", selection: $powStatus) {
                                    ForEach(powStatuses, id: \.self) { status in
                                        Text(status).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit Assignments")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Unit Assignments", text: $unitAssignments)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Deployment Locations")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Deployment Locations", text: $deploymentLocations)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Combat Theaters")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Combat Theaters", text: $combatTheaters)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Medals and Awards")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Medals and Awards", text: $medalsAndAwards)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Text("Special Circumstances")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                Toggle("Terminal Illness", isOn: $terminalIllness)
                                Toggle("Financial Hardship", isOn: $financialHardship)
                                Toggle("Homeless Veteran", isOn: $homelessVeteran)
                                Toggle("Incarcerated", isOn: $incarcerated)
                                Toggle("Mental Health Crisis", isOn: $mentalHealthCrisis)
                                Toggle("Substance Abuse", isOn: $substanceAbuse)
                                Toggle("MST Survivor", isOn: $mstSurvivor)
                                Toggle("Women Veteran", isOn: $womenVeteran)
                                Toggle("Minority Veteran", isOn: $minorityVeteran)
                                Toggle("LGBTQ Veteran", isOn: $lgbtqVeteran)
                                Toggle("Elderly Veteran", isOn: $elderlyVeteran)
                                Toggle("Disabled Veteran", isOn: $disabledVeteran)
                                Toggle("Unemployed", isOn: $unemployed)
                                Toggle("Underemployed", isOn: $underemployed)
                                Toggle("Former Guard/Reserve", isOn: $formerGuardReserve)
                                Toggle("Blue Water Navy", isOn: $blueWaterNavy)
                                Toggle("Social Security Disability", isOn: $socialSecurityDisability)
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // VA Benefits & Services Section
                    CollapsibleSection(title: "VA Benefits & Services", icon: "heart.fill", isExpanded: $isVABenefitsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Current Disability Rating")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Stepper("\(currentDisabilityRating)%", value: $currentDisabilityRating, in: 0...100)
                                }
                                
                                Toggle("VA Healthcare Enrolled", isOn: $vaHealthcareEnrolled)
                            }
                            
                            if vaHealthcareEnrolled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Healthcare Enrollment Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    if let enrollmentDate = healthcareEnrollmentDate {
                                        DatePicker("", selection: Binding(
                                            get: { enrollmentDate },
                                            set: { healthcareEnrollmentDate = $0 }
                                        ), displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                    } else {
                                        Button("Set Date") {
                                            healthcareEnrollmentDate = Date()
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority Group")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Priority Group", text: $priorityGroup)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Medical Center")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("VA Medical Center", text: $vaMedicalCenter)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Clinic")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("VA Clinic", text: $vaClinic)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Primary Care Provider")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Primary Care Provider", text: $primaryCareProvider)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Patient Advocate Contact")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Patient Advocate Contact", text: $patientAdvocateContact)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Education Benefits")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Education Benefits", text: $educationBenefits)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                Toggle("Home Loan COE Issued", isOn: $homeLoanCoeIssued)
                                Toggle("Pension Benefits", isOn: $pensionBenefits)
                                Toggle("Aid and Attendance", isOn: $aidAndAttendance)
                                Toggle("Housebound Benefit", isOn: $houseboundBenefit)
                                Toggle("Burial Benefits", isOn: $burialBenefits)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Monthly Compensation")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Monthly Compensation", value: $monthlyCompensation, format: .currency(code: "USD"))
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Case Management Section
                    CollapsibleSection(title: "Case Management", icon: "briefcase.fill", isExpanded: $isCaseManagementExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Case Status")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Case Status", selection: $caseStatus) {
                                        ForEach(caseStatuses, id: \.self) { status in
                                            Text(status).tag(status)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Case Priority")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Case Priority", selection: $casePriority) {
                                        ForEach(casePriorities, id: \.self) { priority in
                                            Text(priority).tag(priority)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Assigned VSO")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Assigned VSO", text: $assignedVso)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VSO Organization")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("VSO Organization", text: $vsoOrganization)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Assigned Counselor")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Assigned Counselor", text: $assignedCounselor)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next Action Item")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Next Action Item", text: $nextActionItem)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next Action Owner")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Next Action Owner", text: $nextActionOwner)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority Reason")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Priority Reason", text: $priorityReason)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Notes Section
                    CollapsibleSection(title: "Additional Notes", icon: "note.text", isExpanded: $isNotesExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional Notes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $notes)
                                    .frame(minHeight: 100, maxHeight: 200)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.regularMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.primary.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                }
                .padding()
            }
        }
    }
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.primary.opacity(0.1), lineWidth: 1)
            )
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        !socialSecurityNumber.isEmpty &&
        !address.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zipCode.isEmpty &&
        !emergencyContact.isEmpty &&
        !emergencyPhone.isEmpty
    }
    
    private func saveVeteran() {
        veteran.firstName = firstName
        veteran.lastName = lastName
        veteran.middleName = middleName
        veteran.suffix = suffix
        veteran.preferredName = preferredName
        veteran.emailPrimary = email
        veteran.emailSecondary = emailSecondary
        veteran.phonePrimary = phone
        veteran.phoneSecondary = phoneSecondary
        veteran.phoneType = phoneType
        veteran.dateOfBirth = dateOfBirth
        veteran.gender = gender
        veteran.maritalStatus = maritalStatus
        veteran.serviceBranch = serviceBranch
        veteran.serviceComponent = serviceComponent
        veteran.serviceStartDate = serviceStartDate
        veteran.serviceEndDate = serviceEndDate
        veteran.dischargeStatus = dischargeType
        veteran.dischargeDate = dischargeDate
        veteran.rankAtSeparation = rankAtSeparation
        veteran.militaryOccupation = militaryOccupation
        veteran.ssnLastFour = socialSecurityNumber
        veteran.addressStreet = address
        veteran.addressCity = city.isEmpty ? nil : city
        veteran.addressState = state.isEmpty ? nil : state
        veteran.addressZip = zipCode
        veteran.county = county
        veteran.homelessStatus = homelessStatus
        veteran.preferredContactMethod = preferredContactMethod
        veteran.preferredContactTime = preferredContactTime
        veteran.languagePrimary = languagePrimary
        veteran.interpreterNeeded = interpreterNeeded
        veteran.mailingAddressDifferent = mailingAddressDifferent
        veteran.yearsOfService = yearsOfService
        veteran.dischargeUpgradeSought = dischargeUpgradeSought
        veteran.unitAssignments = unitAssignments
        veteran.deploymentLocations = deploymentLocations
        veteran.combatTheaters = combatTheaters
        veteran.medalsAndAwards = medalsAndAwards
        veteran.healthcareEnrollmentDate = healthcareEnrollmentDate
        veteran.priorityGroup = priorityGroup
        veteran.vaMedicalCenter = vaMedicalCenter
        veteran.vaClinic = vaClinic
        veteran.primaryCareProvider = primaryCareProvider
        veteran.patientAdvocateContact = patientAdvocateContact
        veteran.giBillStartDate = giBillStartDate
        veteran.educationEntitlementMonths = educationEntitlementMonths
        veteran.percentEligible = percentEligible
        veteran.yellowRibbon = yellowRibbon
        veteran.currentSchool = currentSchool
        veteran.degreeProgram = degreeProgram
        veteran.graduationDate = graduationDate
        veteran.vrAndEEnrolled = vrAndEEnrolled
        veteran.vrAndECounselor = vrAndECounselor
        veteran.homeLoanCoeDate = homeLoanCoeDate
        veteran.homeLoanEntitlementRemaining = homeLoanEntitlementRemaining
        veteran.homeLoanUsedCount = homeLoanUsedCount
        veteran.currentVaLoanActive = currentVaLoanActive
        veteran.homeLoanDefault = homeLoanDefault
        veteran.irrrlEligible = irrrlEligible
        veteran.sgliActive = sgliActive
        veteran.vgliEnrolled = vgliEnrolled
        veteran.vgliCoverageAmount = vgliCoverageAmount
        veteran.vmliEligible = vmliEligible
        veteran.houseboundBenefit = houseboundBenefit
        veteran.compensationStartDate = compensationStartDate
        veteran.backPayOwed = backPayOwed
        veteran.backPayReceived = backPayReceived
        veteran.backPayDate = backPayDate
        veteran.paymentMethod = paymentMethod
        veteran.bankAccountOnFile = bankAccountOnFile
        veteran.paymentHeld = paymentHeld
        veteran.paymentHoldReason = paymentHoldReason
        veteran.overpaymentDebt = overpaymentDebt
        veteran.debtAmount = debtAmount
        veteran.debtRepaymentPlan = debtRepaymentPlan
        veteran.offsetActive = offsetActive
        veteran.spouseDependent = spouseDependent
        veteran.numberOfDisabledChildren = numberOfDisabledChildren
        veteran.dependentParent = dependentParent
        veteran.derivativeBenefits = derivativeBenefits
        veteran.intakeDate = intakeDate
        veteran.caseOpenedDate = caseOpenedDate
        veteran.vsoOrganization = vsoOrganization
        veteran.priorityReason = priorityReason
        veteran.nextActionItem = nextActionItem
        veteran.nextActionOwner = nextActionOwner
        veteran.nextFollowupDate = nextFollowupDate
        veteran.lastContactDate = lastContactDate
        veteran.lastContactMethod = lastContactMethod
        veteran.contactAttempts = contactAttempts
        veteran.veteranResponsive = veteranResponsive
        veteran.barriersToClaim = barriersToClaim
        veteran.requiresLegalAssistance = requiresLegalAssistance
        veteran.attorneyName = attorneyName
        veteran.powerOfAttorney = powerOfAttorney
        veteran.poaOrganization = poaOrganization
        veteran.fiduciaryNeeded = fiduciaryNeeded
        veteran.fiduciaryAppointed = fiduciaryAppointed
        veteran.successLikelihood = successLikelihood
        veteran.confidenceReasoning = confidenceReasoning
        veteran.estimatedCompletionDate = estimatedCompletionDate
        veteran.caseClosedDate = caseClosedDate
        veteran.caseOutcome = caseOutcome
        veteran.satisfactionRating = satisfactionRating
        veteran.testimonialProvided = testimonialProvided
        veteran.referralSource = referralSource
        veteran.wouldRecommend = wouldRecommend
        veteran.homelessVeteranCoordinator = homelessVeteranCoordinator
        veteran.suicideRisk = suicideRisk
        veteran.crisisLineContacted = crisisLineContacted
        veteran.mstCoordinatorContact = mstCoordinatorContact
        veteran.formerGuardReserve = formerGuardReserve
        veteran.blueWaterNavy = blueWaterNavy
        veteran.socialSecurityDisability = socialSecurityDisability
        veteran.underemployed = underemployed
        veteran.counselorNotes = notes
        veteran.combatVeteran = combatVeteran
        veteran.purpleHeartRecipient = purpleHeartRecipient
        veteran.powStatus = powStatus
        veteran.agentOrangeExposure = agentOrangeExposure
        veteran.radiationExposure = radiationExposure
        veteran.burnPitExposure = burnPitExposure
        veteran.gulfWarService = gulfWarService
        veteran.campLejeuneExposure = campLejeuneExposure
        veteran.pactActEligible = pactActEligible
        veteran.currentDisabilityRating = currentDisabilityRating
        veteran.vaHealthcareEnrolled = vaHealthcareEnrolled
        veteran.educationBenefits = educationBenefits
        veteran.homeLoanCoeIssued = homeLoanCoeIssued
        veteran.pensionBenefits = pensionBenefits
        veteran.aidAndAttendance = aidAndAttendance
        veteran.burialBenefits = burialBenefits
        veteran.monthlyCompensation = monthlyCompensation
        veteran.hasDependents = hasDependents
        veteran.numberOfChildren = numberOfChildren
        veteran.caseStatus = caseStatus
        veteran.assignedVso = assignedVso
        veteran.assignedCounselor = assignedCounselor
        veteran.casePriority = casePriority
        veteran.terminalIllness = terminalIllness
        veteran.financialHardship = financialHardship
        veteran.homelessVeteran = homelessVeteran
        veteran.incarcerated = incarcerated
        veteran.mentalHealthCrisis = mentalHealthCrisis
        veteran.substanceAbuse = substanceAbuse
        veteran.mstSurvivor = mstSurvivor
        veteran.womenVeteran = womenVeteran
        veteran.minorityVeteran = minorityVeteran
        veteran.lgbtqVeteran = lgbtqVeteran
        veteran.elderlyVeteran = elderlyVeteran
        veteran.disabledVeteran = disabledVeteran
        veteran.unemployed = unemployed
        veteran.portalAccountCreated = portalAccountCreated
        veteran.idMeVerified = idMeVerified
        veteran.hipaaConsentSigned = hipaaConsentSigned
        veteran.recordModifiedDate = Date()
        
        do {
            try modelContext.save()
            
            // Log the activity
            let activityLogger = ActivityLogger(modelContext: modelContext)
            activityLogger.logVeteranUpdated(veteran: veteran, performedBy: "System", changes: ["Profile updated"])
            
            dismiss()
        } catch {
            print("Error saving veteran: \(error)")
        }
    }
}

#Preview {
    let veteran = Veteran(
        veteranId: "VET001",
        ssnLastFour: "1234",
        firstName: "John",
        middleName: "",
        lastName: "Doe",
        suffix: "",
        preferredName: "John",
        dateOfBirth: Date(),
        gender: "Male",
        maritalStatus: "Single",
        emailPrimary: "john.doe@example.com",
        emailSecondary: "",
        phonePrimary: "(555) 123-4567",
        phoneSecondary: "(555) 987-6543",
        phoneType: "Mobile",
        addressStreet: "123 Main St",
        addressCity: "Anytown",
        addressState: "CA",
        addressZip: "12345",
        county: "Los Angeles",
        mailingAddressDifferent: false,
        homelessStatus: "No",
        preferredContactMethod: "Email",
        preferredContactTime: "Morning",
        languagePrimary: "English",
        interpreterNeeded: false,
        serviceBranch: "Army",
        serviceComponent: "Active Duty",
        serviceStartDate: Date(),
        serviceEndDate: Date(),
        yearsOfService: 4,
        dischargeDate: Date(),
        dischargeStatus: "Honorable",
        dischargeUpgradeSought: false,
        rankAtSeparation: "E-4",
        militaryOccupation: "Infantry",
        unitAssignments: "1st Infantry Division",
        deploymentLocations: "Afghanistan",
        combatVeteran: true,
        combatTheaters: "Afghanistan",
        purpleHeartRecipient: false,
        medalsAndAwards: "Army Commendation Medal",
        powStatus: "No",
        agentOrangeExposure: false,
        radiationExposure: false,
        burnPitExposure: true,
        gulfWarService: false,
        campLejeuneExposure: false,
        pactActEligible: true,
        currentDisabilityRating: 0,
        vaHealthcareEnrolled: false,
        healthcareEnrollmentDate: nil,
        priorityGroup: "Group 1",
        vaMedicalCenter: "Los Angeles VA",
        vaClinic: "West LA VA",
        primaryCareProvider: "Dr. Smith",
        patientAdvocateContact: "Jane Doe",
        educationBenefits: "Post-9/11 GI Bill",
        giBillStartDate: nil,
        educationEntitlementMonths: 36,
        percentEligible: 100,
        yellowRibbon: false,
        currentSchool: "",
        degreeProgram: "",
        graduationDate: nil,
        vrAndEEnrolled: false,
        vrAndECounselor: "",
        homeLoanCoeIssued: false,
        homeLoanCoeDate: nil,
        homeLoanEntitlementRemaining: 0,
        homeLoanUsedCount: 0,
        currentVaLoanActive: false,
        homeLoanDefault: false,
        irrrlEligible: false,
        sgliActive: false,
        vgliEnrolled: false,
        vgliCoverageAmount: 0,
        vmliEligible: false,
        pensionBenefits: false,
        aidAndAttendance: false,
        houseboundBenefit: false,
        burialBenefits: false,
        monthlyCompensation: 0.0,
        compensationStartDate: nil,
        backPayOwed: 0.0,
        backPayReceived: 0.0,
        backPayDate: nil,
        paymentMethod: "Direct Deposit",
        bankAccountOnFile: false,
        paymentHeld: false,
        paymentHoldReason: "",
        overpaymentDebt: false,
        debtAmount: 0.0,
        debtRepaymentPlan: "",
        offsetActive: false,
        hasDependents: false,
        spouseDependent: false,
        numberOfChildren: 0,
        numberOfDisabledChildren: 0,
        dependentParent: false,
        derivativeBenefits: false,
        intakeDate: Date(),
        caseOpenedDate: Date(),
        caseStatus: "Active",
        assignedVso: "John Smith",
        vsoOrganization: "VFW",
        assignedCounselor: "Jane Doe",
        counselorNotes: "Initial case notes",
        casePriority: "Medium",
        priorityReason: "Standard processing",
        nextActionItem: "Gather medical records",
        nextActionOwner: "Jane Doe",
        nextFollowupDate: nil,
        lastContactDate: nil,
        lastContactMethod: "Phone",
        contactAttempts: 0,
        veteranResponsive: "Yes",
        barriersToClaim: "None",
        requiresLegalAssistance: false,
        attorneyName: "",
        powerOfAttorney: false,
        poaOrganization: "",
        fiduciaryNeeded: false,
        fiduciaryAppointed: false,
        successLikelihood: "High",
        confidenceReasoning: "Strong case",
        estimatedCompletionDate: nil,
        caseClosedDate: nil,
        caseOutcome: "",
        satisfactionRating: 0,
        testimonialProvided: false,
        referralSource: "Website",
        wouldRecommend: false,
        terminalIllness: false,
        financialHardship: false,
        homelessVeteran: false,
        homelessVeteranCoordinator: "",
        incarcerated: false,
        mentalHealthCrisis: false,
        suicideRisk: false,
        crisisLineContacted: false,
        substanceAbuse: false,
        mstSurvivor: false,
        mstCoordinatorContact: "",
        womenVeteran: false,
        minorityVeteran: false,
        lgbtqVeteran: false,
        elderlyVeteran: false,
        formerGuardReserve: false,
        blueWaterNavy: false,
        disabledVeteran: false,
        socialSecurityDisability: false,
        unemployed: false,
        underemployed: false,
        portalAccountCreated: false,
        portalRegistrationDate: nil,
        portalLastLogin: nil,
        portalLoginCount: 0,
        idMeVerified: false,
        idMeVerificationDate: nil,
        loginGovVerified: false,
        twoFactorEnabled: false,
        documentUploads: 0,
        portalMessagesSent: 0,
        emailNotificationsEnabled: true,
        smsNotificationsEnabled: false,
        optInMarketing: false,
        newsletterSubscriber: false,
        webinarInvitations: false,
        surveyParticipation: false,
        communityForumMember: false,
        advocacyVolunteer: false,
        vaGovApiSynced: false,
        vaProfileId: "",
        ebenefitsSynced: false,
        myhealthevetConnected: false,
        lastApiSync: nil,
        apiSyncStatus: "Not Synced",
        recordCreatedBy: "System",
        recordModifiedBy: "System",
        hipaaConsentSigned: false,
        hipaaConsentDate: nil,
        privacyNoticeAcknowledged: false,
        termsOfServiceAccepted: false,
        gdprDataRequest: false,
        recordRetentionDate: nil
    )
    
    EditVeteranView(veteran: veteran)
        .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}
