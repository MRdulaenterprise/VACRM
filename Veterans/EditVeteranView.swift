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
    
    // MARK: - State for Collapsible Sections
    @State private var isPersonalInfoExpanded = true
    @State private var isContactInfoExpanded = true
    @State private var isServiceInfoExpanded = true
    @State private var isMedicalInfoExpanded = true
    @State private var isFinancialInfoExpanded = true
    @State private var isLegalInfoExpanded = true
    @State private var isNotesExpanded = true
    
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
        _address = State(initialValue: veteran.addressStreet)
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
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ZIP")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("ZIP", text: $zipCode)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Notes Section
                    CollapsibleSection(title: "Notes & Additional Information", icon: "note.text", isExpanded: $isNotesExpanded) {
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
        veteran.preferredContactMethod = emergencyContact
        veteran.phoneSecondary = emergencyPhone
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
