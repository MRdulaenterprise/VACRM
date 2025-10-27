//
//  AddVeteranView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct AddVeteranView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Form state
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var middleName = ""
    @State private var suffix = ""
    @State private var preferredName = ""
    @State private var email = ""
    @State private var emailSecondary = ""
    @State private var phone = ""
    @State private var phoneSecondary = ""
    @State private var phoneType = "Mobile"
    @State private var dateOfBirth = Date()
    @State private var gender = "Not Specified"
    @State private var maritalStatus = "Not Specified"
    @State private var serviceBranch = "Army"
    @State private var serviceComponent = "Active Duty"
    @State private var serviceStartDate = Date()
    @State private var serviceEndDate = Date()
    @State private var dischargeType = "Honorable"
    @State private var dischargeDate = Date()
    @State private var rankAtSeparation = ""
    @State private var militaryOccupation = ""
    @State private var socialSecurityNumber = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var county = ""
    @State private var homelessStatus = "Stable Housing"
    @State private var preferredContactMethod = "Email"
    @State private var preferredContactTime = "Business Hours"
    @State private var languagePrimary = "English"
    @State private var interpreterNeeded = false
    @State private var emergencyContact = ""
    @State private var emergencyPhone = ""
    @State private var notes = ""
    @State private var combatVeteran = false
    @State private var purpleHeartRecipient = false
    @State private var powStatus = "No"
    @State private var agentOrangeExposure = false
    @State private var radiationExposure = false
    @State private var burnPitExposure = false
    @State private var gulfWarService = false
    @State private var campLejeuneExposure = false
    @State private var pactActEligible = false
    @State private var currentDisabilityRating = 0
    @State private var vaHealthcareEnrolled = false
    @State private var educationBenefits = ""
    @State private var homeLoanCoeIssued = false
    @State private var pensionBenefits = false
    @State private var aidAndAttendance = false
    @State private var burialBenefits = false
    @State private var monthlyCompensation = 0.0
    @State private var hasDependents = false
    @State private var numberOfChildren = 0
    @State private var caseStatus = "New"
    @State private var assignedVso = ""
    @State private var assignedCounselor = ""
    @State private var casePriority = "Normal"
    @State private var terminalIllness = false
    @State private var financialHardship = false
    @State private var homelessVeteran = false
    @State private var incarcerated = false
    @State private var mentalHealthCrisis = false
    @State private var substanceAbuse = false
    @State private var mstSurvivor = false
    @State private var womenVeteran = false
    @State private var minorityVeteran = false
    @State private var lgbtqVeteran = false
    @State private var elderlyVeteran = false
    @State private var disabledVeteran = false
    @State private var unemployed = false
    @State private var portalAccountCreated = false
    @State private var idMeVerified = false
    @State private var hipaaConsentSigned = false
    
    // Collapsible sections state
    @State private var personalInfoExpanded = true
    @State private var contactInfoExpanded = true
    @State private var addressInfoExpanded = true
    @State private var militaryServiceExpanded = true
    @State private var emergencyContactExpanded = true
    @State private var additionalInfoExpanded = false
    @State private var vaBenefitsExpanded = false
    @State private var caseManagementExpanded = false
    @State private var notesExpanded = false
    
    // Additional missing fields
    @State private var yearsOfService = 0
    @State private var dischargeUpgradeSought = false
    @State private var unitAssignments = ""
    @State private var deploymentLocations = ""
    @State private var combatTheaters = ""
    @State private var medalsAndAwards = ""
    @State private var healthcareEnrollmentDate: Date? = nil
    @State private var priorityGroup = ""
    @State private var vaMedicalCenter = ""
    @State private var vaClinic = ""
    @State private var primaryCareProvider = ""
    @State private var patientAdvocateContact = ""
    @State private var giBillStartDate: Date? = nil
    @State private var educationEntitlementMonths = 0
    @State private var percentEligible = 0
    @State private var yellowRibbon = false
    @State private var currentSchool = ""
    @State private var degreeProgram = ""
    @State private var graduationDate: Date? = nil
    @State private var vrAndEEnrolled = false
    @State private var vrAndECounselor = ""
    @State private var homeLoanCoeDate: Date? = nil
    @State private var homeLoanEntitlementRemaining = 0
    @State private var homeLoanUsedCount = 0
    @State private var currentVaLoanActive = false
    @State private var homeLoanDefault = false
    @State private var irrrlEligible = false
    @State private var sgliActive = false
    @State private var vgliEnrolled = false
    @State private var vgliCoverageAmount = 0
    @State private var vmliEligible = false
    @State private var houseboundBenefit = false
    @State private var compensationStartDate: Date? = nil
    @State private var backPayOwed = 0.0
    @State private var backPayReceived = 0.0
    @State private var backPayDate: Date? = nil
    @State private var paymentMethod = ""
    @State private var bankAccountOnFile = false
    @State private var paymentHeld = false
    @State private var paymentHoldReason = ""
    @State private var overpaymentDebt = false
    @State private var debtAmount = 0.0
    @State private var debtRepaymentPlan = ""
    @State private var offsetActive = false
    @State private var spouseDependent = false
    @State private var numberOfDisabledChildren = 0
    @State private var dependentParent = false
    @State private var derivativeBenefits = false
    @State private var intakeDate = Date()
    @State private var caseOpenedDate = Date()
    @State private var vsoOrganization = ""
    @State private var priorityReason = ""
    @State private var nextActionItem = ""
    @State private var nextActionOwner = ""
    @State private var nextFollowupDate: Date? = nil
    @State private var lastContactDate: Date? = nil
    @State private var lastContactMethod = ""
    @State private var contactAttempts = 0
    @State private var veteranResponsive = ""
    @State private var barriersToClaim = ""
    @State private var requiresLegalAssistance = false
    @State private var attorneyName = ""
    @State private var powerOfAttorney = false
    @State private var poaOrganization = ""
    @State private var fiduciaryNeeded = false
    @State private var fiduciaryAppointed = false
    @State private var successLikelihood = ""
    @State private var confidenceReasoning = ""
    @State private var estimatedCompletionDate: Date? = nil
    @State private var caseClosedDate: Date? = nil
    @State private var caseOutcome = ""
    @State private var satisfactionRating = 0
    @State private var testimonialProvided = false
    @State private var referralSource = ""
    @State private var wouldRecommend = false
    @State private var homelessVeteranCoordinator = ""
    @State private var suicideRisk = false
    @State private var crisisLineContacted = false
    @State private var mstCoordinatorContact = ""
    @State private var formerGuardReserve = false
    @State private var blueWaterNavy = false
    @State private var socialSecurityDisability = false
    @State private var underemployed = false
    @State private var portalRegistrationDate: Date? = nil
    @State private var portalLastLogin: Date? = nil
    @State private var portalLoginCount = 0
    @State private var idMeVerificationDate: Date? = nil
    @State private var loginGovVerified = false
    @State private var twoFactorEnabled = false
    @State private var documentUploads = 0
    @State private var portalMessagesSent = 0
    @State private var emailNotificationsEnabled = false
    @State private var smsNotificationsEnabled = false
    @State private var optInMarketing = false
    @State private var newsletterSubscriber = false
    @State private var webinarInvitations = false
    @State private var surveyParticipation = false
    @State private var communityForumMember = false
    @State private var advocacyVolunteer = false
    @State private var vaGovApiSynced = false
    @State private var vaProfileId = ""
    @State private var ebenefitsSynced = false
    @State private var myhealthevetConnected = false
    @State private var lastApiSync: Date? = nil
    @State private var apiSyncStatus = ""
    @State private var recordCreatedBy = ""
    @State private var recordModifiedBy = ""
    @State private var hipaaConsentDate: Date? = nil
    @State private var privacyNoticeAcknowledged = false
    @State private var termsOfServiceAccepted = false
    @State private var gdprDataRequest = false
    @State private var recordRetentionDate: Date? = nil
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Enhanced Header
            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add New Veteran")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Complete the form below to add a new veteran")
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
                    .controlSize(.large)
                    
                    Button("Save Veteran") {
                        saveVeteran()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid)
                }
            }
            .padding(20)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Personal Information Section
                    CollapsibleSection(
                        title: "Personal Information",
                        icon: "person.circle.fill",
                        isExpanded: $personalInfoExpanded
                    ) {
                        personalInformationContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            personalInfoExpanded.toggle()
                        }
                    }
                    
                    // Contact Information Section
                    CollapsibleSection(
                        title: "Contact Information",
                        icon: "envelope.circle.fill",
                        isExpanded: $contactInfoExpanded
                    ) {
                        contactInformationContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contactInfoExpanded.toggle()
                        }
                    }
                    
                    // Address Information Section
                    CollapsibleSection(
                        title: "Address Information",
                        icon: "house.circle.fill",
                        isExpanded: $addressInfoExpanded
                    ) {
                        addressInformationContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            addressInfoExpanded.toggle()
                        }
                    }
                    
                    // Military Service Section
                    CollapsibleSection(
                        title: "Military Service",
                        icon: "star.circle.fill",
                        isExpanded: $militaryServiceExpanded
                    ) {
                        militaryServiceContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            militaryServiceExpanded.toggle()
                        }
                    }
                    
                    // Emergency Contact Section
                    CollapsibleSection(
                        title: "Emergency Contact",
                        icon: "phone.circle.fill",
                        isExpanded: $emergencyContactExpanded
                    ) {
                        emergencyContactContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            emergencyContactExpanded.toggle()
                        }
                    }
                    
                    // Additional Information Section
                    CollapsibleSection(
                        title: "Additional Information",
                        icon: "info.circle.fill",
                        isExpanded: $additionalInfoExpanded
                    ) {
                        additionalInformationContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            additionalInfoExpanded.toggle()
                        }
                    }
                    
                    // VA Benefits Section
                    CollapsibleSection(
                        title: "VA Benefits & Services",
                        icon: "heart.circle.fill",
                        isExpanded: $vaBenefitsExpanded
                    ) {
                        vaBenefitsContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            vaBenefitsExpanded.toggle()
                        }
                    }
                    
                    // Case Management Section
                    CollapsibleSection(
                        title: "Case Management",
                        icon: "briefcase.circle.fill",
                        isExpanded: $caseManagementExpanded
                    ) {
                        caseManagementContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            caseManagementExpanded.toggle()
                        }
                    }
                    
                    // Notes Section
                    CollapsibleSection(
                        title: "Additional Notes",
                        icon: "note.text",
                        isExpanded: $notesExpanded
                    ) {
                        notesContent
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            notesExpanded.toggle()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    
    // MARK: - Section Content Views
    private var personalInformationContent: some View {
        VStack(spacing: 16) {
            // Name fields
            HStack(spacing: 16) {
                FormField(label: "First Name", isRequired: true) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "Last Name", isRequired: true) {
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(.modern)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Middle Name") {
                    TextField("Middle Name", text: $middleName)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "Suffix") {
                    TextField("Suffix", text: $suffix)
                        .textFieldStyle(.modern)
                }
            }
            
            FormField(label: "Preferred Name") {
                TextField("Preferred Name", text: $preferredName)
                    .textFieldStyle(.modern)
            }
            
            // Demographics
            HStack(spacing: 16) {
                FormField(label: "Gender") {
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender).tag(gender)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                FormField(label: "Marital Status") {
                    Picker("Marital Status", selection: $maritalStatus) {
                        ForEach(maritalStatuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Date of Birth", isRequired: true) {
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                FormField(label: "Social Security Number") {
                    TextField("Social Security Number", text: $socialSecurityNumber)
                        .textFieldStyle(.modern)
                }
            }
        }
    }
    
    private var contactInformationContent: some View {
        VStack(spacing: 16) {
            FormField(label: "Primary Email", isRequired: true) {
                TextField("Primary Email", text: $email)
                    .textFieldStyle(.modern)
            }
            
            FormField(label: "Secondary Email") {
                TextField("Secondary Email", text: $emailSecondary)
                    .textFieldStyle(.modern)
            }
            
            HStack(spacing: 16) {
                FormField(label: "Primary Phone") {
                    TextField("Primary Phone", text: $phone)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "Phone Type") {
                    Picker("Phone Type", selection: $phoneType) {
                        ForEach(phoneTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            FormField(label: "Secondary Phone") {
                TextField("Secondary Phone", text: $phoneSecondary)
                    .textFieldStyle(.modern)
            }
            
            HStack(spacing: 16) {
                FormField(label: "Preferred Contact Method") {
                    Picker("Preferred Contact Method", selection: $preferredContactMethod) {
                        ForEach(contactMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                FormField(label: "Preferred Contact Time") {
                    Picker("Preferred Contact Time", selection: $preferredContactTime) {
                        ForEach(contactTimes, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
    
    private var addressInformationContent: some View {
        VStack(spacing: 16) {
            FormField(label: "Address") {
                TextField("Address", text: $address)
                    .textFieldStyle(.modern)
            }
            
            HStack(spacing: 16) {
                FormField(label: "City") {
                    TextField("City", text: $city)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "State") {
                    TextField("State", text: $state)
                        .textFieldStyle(.modern)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "ZIP Code") {
                    TextField("ZIP Code", text: $zipCode)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "County") {
                    TextField("County", text: $county)
                        .textFieldStyle(.modern)
                }
            }
            
            FormField(label: "Homeless Status") {
                Picker("Homeless Status", selection: $homelessStatus) {
                    ForEach(homelessStatuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private var militaryServiceContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FormField(label: "Service Branch") {
                    Picker("Service Branch", selection: $serviceBranch) {
                        ForEach(serviceBranches, id: \.self) { branch in
                            Text(branch).tag(branch)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                FormField(label: "Service Component") {
                    Picker("Service Component", selection: $serviceComponent) {
                        ForEach(serviceComponents, id: \.self) { component in
                            Text(component).tag(component)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Service Start Date") {
                    DatePicker("Service Start Date", selection: $serviceStartDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                FormField(label: "Service End Date") {
                    DatePicker("Service End Date", selection: $serviceEndDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Discharge Type") {
                    Picker("Discharge Type", selection: $dischargeType) {
                        ForEach(dischargeTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                FormField(label: "Discharge Date") {
                    DatePicker("Discharge Date", selection: $dischargeDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Rank at Separation") {
                    TextField("Rank at Separation", text: $rankAtSeparation)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "Military Occupation") {
                    TextField("Military Occupation", text: $militaryOccupation)
                        .textFieldStyle(.modern)
                }
            }
        }
    }
    
    private var emergencyContactContent: some View {
        VStack(spacing: 16) {
            FormField(label: "Emergency Contact Name") {
                TextField("Emergency Contact Name", text: $emergencyContact)
                    .textFieldStyle(.modern)
            }
            
            FormField(label: "Emergency Contact Phone") {
                TextField("Emergency Contact Phone", text: $emergencyPhone)
                    .textFieldStyle(.modern)
            }
        }
    }
    
    private var additionalInformationContent: some View {
        VStack(spacing: 16) {
            // Combat and service-related checkboxes
            VStack(alignment: .leading, spacing: 12) {
                Text("Service History")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    Toggle("Combat Veteran", isOn: $combatVeteran)
                        .toggleStyle(.modern)
                    
                    Toggle("Purple Heart Recipient", isOn: $purpleHeartRecipient)
                        .toggleStyle(.modern)
                    
                    Toggle("Agent Orange Exposure", isOn: $agentOrangeExposure)
                        .toggleStyle(.modern)
                    
                    Toggle("Burn Pit Exposure", isOn: $burnPitExposure)
                        .toggleStyle(.modern)
                    
                    Toggle("Gulf War Service", isOn: $gulfWarService)
                        .toggleStyle(.modern)
                    
                    Toggle("PACT Act Eligible", isOn: $pactActEligible)
                        .toggleStyle(.modern)
                }
            }
            
            FormField(label: "POW Status") {
                Picker("POW Status", selection: $powStatus) {
                    ForEach(powStatuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private var vaBenefitsContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FormField(label: "Current Disability Rating") {
                    Stepper("\(currentDisabilityRating)%", value: $currentDisabilityRating, in: 0...100)
                }
                
                Toggle("VA Healthcare Enrolled", isOn: $vaHealthcareEnrolled)
                    .toggleStyle(.modern)
            }
            
            FormField(label: "Education Benefits") {
                TextField("Education Benefits", text: $educationBenefits)
                    .textFieldStyle(.modern)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                Toggle("Home Loan COE Issued", isOn: $homeLoanCoeIssued)
                    .toggleStyle(.modern)
                
                Toggle("Pension Benefits", isOn: $pensionBenefits)
                    .toggleStyle(.modern)
                
                Toggle("Aid and Attendance", isOn: $aidAndAttendance)
                    .toggleStyle(.modern)
                
                Toggle("Burial Benefits", isOn: $burialBenefits)
                    .toggleStyle(.modern)
            }
        }
    }
    
    private var caseManagementContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                FormField(label: "Case Status") {
                    Picker("Case Status", selection: $caseStatus) {
                        ForEach(caseStatuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                FormField(label: "Case Priority") {
                    Picker("Case Priority", selection: $casePriority) {
                        ForEach(casePriorities, id: \.self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            HStack(spacing: 16) {
                FormField(label: "Assigned VSO") {
                    TextField("Assigned VSO", text: $assignedVso)
                        .textFieldStyle(.modern)
                }
                
                FormField(label: "Assigned Counselor") {
                    TextField("Assigned Counselor", text: $assignedCounselor)
                        .textFieldStyle(.modern)
                }
            }
        }
    }
    
    private var notesContent: some View {
        VStack(spacing: 16) {
            FormField(label: "Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Methods
    private func saveVeteran() {
        let veteran = Veteran(
            veteranId: UUID().uuidString,
            ssnLastFour: socialSecurityNumber,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            suffix: suffix,
            preferredName: preferredName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            maritalStatus: maritalStatus,
            emailPrimary: email,
            emailSecondary: emailSecondary,
            phonePrimary: phone,
            phoneSecondary: phoneSecondary,
            phoneType: phoneType,
            addressStreet: address,
            addressCity: city.isEmpty ? nil : city,
            addressState: state.isEmpty ? nil : state,
            addressZip: zipCode,
            county: county,
            mailingAddressDifferent: false,
            homelessStatus: homelessStatus,
            preferredContactMethod: preferredContactMethod,
            preferredContactTime: preferredContactTime,
            languagePrimary: languagePrimary,
            interpreterNeeded: interpreterNeeded,
            serviceBranch: serviceBranch,
            serviceComponent: serviceComponent,
            serviceStartDate: serviceStartDate,
            serviceEndDate: serviceEndDate,
            yearsOfService: yearsOfService,
            dischargeDate: dischargeDate,
            dischargeStatus: dischargeType,
            dischargeUpgradeSought: dischargeUpgradeSought,
            rankAtSeparation: rankAtSeparation,
            militaryOccupation: militaryOccupation,
            unitAssignments: unitAssignments,
            deploymentLocations: deploymentLocations,
            combatVeteran: combatVeteran,
            combatTheaters: combatTheaters,
            purpleHeartRecipient: purpleHeartRecipient,
            medalsAndAwards: medalsAndAwards,
            powStatus: powStatus,
            agentOrangeExposure: agentOrangeExposure,
            radiationExposure: radiationExposure,
            burnPitExposure: burnPitExposure,
            gulfWarService: gulfWarService,
            campLejeuneExposure: campLejeuneExposure,
            pactActEligible: pactActEligible,
            currentDisabilityRating: currentDisabilityRating,
            vaHealthcareEnrolled: vaHealthcareEnrolled,
            healthcareEnrollmentDate: healthcareEnrollmentDate,
            priorityGroup: priorityGroup,
            vaMedicalCenter: vaMedicalCenter,
            vaClinic: vaClinic,
            primaryCareProvider: primaryCareProvider,
            patientAdvocateContact: patientAdvocateContact,
            educationBenefits: educationBenefits,
            giBillStartDate: giBillStartDate,
            educationEntitlementMonths: educationEntitlementMonths,
            percentEligible: percentEligible,
            yellowRibbon: yellowRibbon,
            currentSchool: currentSchool,
            degreeProgram: degreeProgram,
            graduationDate: graduationDate,
            vrAndEEnrolled: vrAndEEnrolled,
            vrAndECounselor: vrAndECounselor,
            homeLoanCoeIssued: homeLoanCoeIssued,
            homeLoanCoeDate: homeLoanCoeDate,
            homeLoanEntitlementRemaining: homeLoanEntitlementRemaining,
            homeLoanUsedCount: homeLoanUsedCount,
            currentVaLoanActive: currentVaLoanActive,
            homeLoanDefault: homeLoanDefault,
            irrrlEligible: irrrlEligible,
            sgliActive: sgliActive,
            vgliEnrolled: vgliEnrolled,
            vgliCoverageAmount: vgliCoverageAmount,
            vmliEligible: vmliEligible,
            pensionBenefits: pensionBenefits,
            aidAndAttendance: aidAndAttendance,
            houseboundBenefit: houseboundBenefit,
            burialBenefits: burialBenefits,
            monthlyCompensation: monthlyCompensation,
            compensationStartDate: compensationStartDate,
            backPayOwed: backPayOwed,
            backPayReceived: backPayReceived,
            backPayDate: backPayDate,
            paymentMethod: paymentMethod,
            bankAccountOnFile: bankAccountOnFile,
            paymentHeld: paymentHeld,
            paymentHoldReason: paymentHoldReason,
            overpaymentDebt: overpaymentDebt,
            debtAmount: debtAmount,
            debtRepaymentPlan: debtRepaymentPlan,
            offsetActive: offsetActive,
            hasDependents: hasDependents,
            spouseDependent: spouseDependent,
            numberOfChildren: numberOfChildren,
            numberOfDisabledChildren: numberOfDisabledChildren,
            dependentParent: dependentParent,
            derivativeBenefits: derivativeBenefits,
            intakeDate: intakeDate,
            caseOpenedDate: caseOpenedDate,
            caseStatus: caseStatus,
            assignedVso: assignedVso,
            vsoOrganization: vsoOrganization,
            assignedCounselor: assignedCounselor,
            counselorNotes: notes,
            casePriority: casePriority,
            priorityReason: priorityReason,
            nextActionItem: nextActionItem,
            nextActionOwner: nextActionOwner,
            nextFollowupDate: nextFollowupDate,
            lastContactDate: lastContactDate,
            lastContactMethod: lastContactMethod,
            contactAttempts: contactAttempts,
            veteranResponsive: veteranResponsive,
            barriersToClaim: barriersToClaim,
            requiresLegalAssistance: requiresLegalAssistance,
            attorneyName: attorneyName,
            powerOfAttorney: powerOfAttorney,
            poaOrganization: poaOrganization,
            fiduciaryNeeded: fiduciaryNeeded,
            fiduciaryAppointed: fiduciaryAppointed,
            successLikelihood: successLikelihood,
            confidenceReasoning: confidenceReasoning,
            estimatedCompletionDate: estimatedCompletionDate,
            caseClosedDate: caseClosedDate,
            caseOutcome: caseOutcome,
            satisfactionRating: satisfactionRating,
            testimonialProvided: testimonialProvided,
            referralSource: referralSource,
            wouldRecommend: wouldRecommend,
            terminalIllness: terminalIllness,
            financialHardship: financialHardship,
            homelessVeteran: homelessVeteran,
            homelessVeteranCoordinator: homelessVeteranCoordinator,
            incarcerated: incarcerated,
            mentalHealthCrisis: mentalHealthCrisis,
            suicideRisk: suicideRisk,
            crisisLineContacted: crisisLineContacted,
            substanceAbuse: substanceAbuse,
            mstSurvivor: mstSurvivor,
            mstCoordinatorContact: mstCoordinatorContact,
            womenVeteran: womenVeteran,
            minorityVeteran: minorityVeteran,
            lgbtqVeteran: lgbtqVeteran,
            elderlyVeteran: elderlyVeteran,
            formerGuardReserve: formerGuardReserve,
            blueWaterNavy: blueWaterNavy,
            disabledVeteran: disabledVeteran,
            socialSecurityDisability: socialSecurityDisability,
            unemployed: unemployed,
            underemployed: underemployed,
            portalAccountCreated: portalAccountCreated,
            portalRegistrationDate: portalRegistrationDate,
            portalLastLogin: portalLastLogin,
            portalLoginCount: portalLoginCount,
            idMeVerified: idMeVerified,
            idMeVerificationDate: idMeVerificationDate,
            loginGovVerified: loginGovVerified,
            twoFactorEnabled: twoFactorEnabled,
            documentUploads: documentUploads,
            portalMessagesSent: portalMessagesSent,
            emailNotificationsEnabled: emailNotificationsEnabled,
            smsNotificationsEnabled: smsNotificationsEnabled,
            optInMarketing: optInMarketing,
            newsletterSubscriber: newsletterSubscriber,
            webinarInvitations: webinarInvitations,
            surveyParticipation: surveyParticipation,
            communityForumMember: communityForumMember,
            advocacyVolunteer: advocacyVolunteer,
            vaGovApiSynced: vaGovApiSynced,
            vaProfileId: vaProfileId,
            ebenefitsSynced: ebenefitsSynced,
            myhealthevetConnected: myhealthevetConnected,
            lastApiSync: lastApiSync,
            apiSyncStatus: apiSyncStatus,
            recordCreatedBy: recordCreatedBy,
            recordModifiedBy: recordModifiedBy,
            hipaaConsentSigned: hipaaConsentSigned,
            hipaaConsentDate: hipaaConsentDate,
            privacyNoticeAcknowledged: privacyNoticeAcknowledged,
            termsOfServiceAccepted: termsOfServiceAccepted,
            gdprDataRequest: gdprDataRequest,
            recordRetentionDate: recordRetentionDate
        )
        
        modelContext.insert(veteran)
        
        // Log the activity
        // ActivityLogger().logVeteranCreated(veteran: veteran)
        
        dismiss()
    }
}

// MARK: - Collapsible Section
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let content: Content
    
    init(title: String, icon: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(20)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            // Content
            if isExpanded {
                VStack(spacing: 20) {
                    content
                }
                .padding(24)
                .background(Color.white)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Form Field
struct FormField<Content: View>: View {
    let label: String
    let isRequired: Bool
    let content: Content
    
    init(label: String, isRequired: Bool = false, @ViewBuilder content: () -> Content) {
        self.label = label
        self.isRequired = isRequired
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            
            content
        }
    }
}

// MARK: - Modern Text Field Style
extension TextFieldStyle where Self == ModernTextFieldStyle {
    static var modern: ModernTextFieldStyle {
        ModernTextFieldStyle()
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.primary.opacity(0.2), lineWidth: 1)
            )
            .font(.system(size: 14))
            .textFieldStyle(.plain)
    }
}

// MARK: - Modern Toggle Style
extension ToggleStyle where Self == ModernToggleStyle {
    static var modern: ModernToggleStyle {
        ModernToggleStyle()
    }
}

struct ModernToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.label
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { configuration.isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? .blue : .secondary.opacity(0.3))
                    .frame(width: 32, height: 20)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .offset(x: configuration.isOn ? 6 : -6)
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    AddVeteranView()
        .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}