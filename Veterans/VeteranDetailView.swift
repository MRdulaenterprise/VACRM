//
//  VeteranDetailView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Foundation

struct VeteranDetailView: View {
    let veteran: Veteran
    let initialTab: Int?
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddClaim = false
    @State private var showingEditVeteran = false
    @State private var showingDocumentUpload = false
    @State private var showingActivityDetail = false
    @State private var selectedActivity: ClaimActivity?
    @State private var selectedTab = 0
    @State private var showingEmailCompose = false
    @State private var showingEmailHistory = false
    
    init(veteran: Veteran, initialTab: Int? = nil) {
        self.veteran = veteran
        self.initialTab = initialTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            tabSelectionView
            contentView
        }
        .onAppear {
            if let initialTab = initialTab {
                selectedTab = initialTab
            }
        }
        .sheet(isPresented: $showingAddClaim) {
            AddClaimView(veteran: veteran)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingEditVeteran) {
            EditVeteranView(veteran: veteran)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingDocumentUpload) {
            DocumentUploadView(veteran: veteran, claim: nil)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingActivityDetail) {
            if let activity = selectedActivity {
                ActivityDetailModal(activity: activity)
            }
        }
        .sheet(isPresented: $showingEmailCompose) {
            EmailComposeView(veteran: veteran)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingEmailHistory) {
            EmailHistoryView(veteran: veteran)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                avatarView
                veteranInfoView
                Spacer()
                actionButtonsView
            }
            contactInfoView
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(.primary.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 3)
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text(veteran.fullName.prefix(1))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var veteranInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(veteran.fullName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                serviceBranchBadge
                ageInfo
                ratingInfo
            }
        }
    }
    
    private var serviceBranchBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            Text(veteran.serviceBranch)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.blue.opacity(0.1), in: Capsule())
        .overlay(
            Capsule()
                .stroke(.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var ageInfo: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text("Age \(veteran.age)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var ratingInfo: some View {
        HStack(spacing: 6) {
            Image(systemName: "percent")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
            Text("\(veteran.currentDisabilityRating)% Rating")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green)
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                emailButton
                historyButton
                editButton
            }
            
            HStack(spacing: 12) {
                uploadButton
                addClaimButton
            }
        }
    }
    
    private var emailButton: some View {
        Button(action: { showingEmailCompose = true }) {
            HStack(spacing: 6) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("Email")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.blue.gradient, in: Capsule())
            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var historyButton: some View {
        Button(action: { showingEmailHistory = true }) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("History")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.blue.opacity(0.1), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var editButton: some View {
        Button(action: { showingEditVeteran = true }) {
            HStack(spacing: 6) {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .medium))
                Text("Edit")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.orange.opacity(0.1), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var uploadButton: some View {
        Button(action: { showingDocumentUpload = true }) {
            HStack(spacing: 6) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                Text("Upload")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.green)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.green.opacity(0.1), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(.green.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var addClaimButton: some View {
        Button(action: { showingAddClaim = true }) {
            HStack(spacing: 6) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 14, weight: .medium))
                Text("Add Claim")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.purple.gradient, in: Capsule())
            .shadow(color: .purple.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var contactInfoView: some View {
        HStack(spacing: 16) {
            ContactInfoCard(
                icon: "envelope.fill", 
                text: veteran.emailPrimary, 
                color: .blue,
                action: { showingEmailCompose = true }
            )
            ContactInfoCard(
                icon: "phone.fill", 
                text: veteran.phonePrimary, 
                color: .green,
                action: openPhoneDialer
            )
            ContactInfoCard(
                icon: "location.fill", 
                text: "\(veteran.addressCity ?? ""), \(veteran.addressState ?? "")", 
                color: .orange,
                action: openMaps
            )
            ContactInfoCard(icon: "building.2.fill", text: veteran.vaMedicalCenter, color: .purple)
        }
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                tabButton(for: index)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func tabButton(for index: Int) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: tabIcon(for: index))
                    .font(.system(size: 16, weight: .medium))
                
                Text(tabTitle(for: index))
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(selectedTab == index ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(tabBackground(for: index))
            .shadow(
                color: selectedTab == index ? .blue.opacity(0.3) : .clear,
                radius: selectedTab == index ? 4 : 0,
                x: 0,
                y: selectedTab == index ? 2 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func tabBackground(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(selectedTab == index ? .blue : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedTab == index ? .clear : .primary.opacity(0.2), lineWidth: 1)
            )
    }
    
    // MARK: - Action Functions
    private func openPhoneDialer() {
        // Clean phone number for FaceTime
        let cleanPhone = veteran.phonePrimary.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "tel:\(cleanPhone)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openMaps() {
        let address = "\(veteran.addressStreet ?? ""), \(veteran.addressCity ?? ""), \(veteran.addressState ?? "") \(veteran.addressZip)"
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedAddress)") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openEmailComposer() {
        showingEmailCompose = true
    }
    
    private var contentView: some View {
        ScrollView {
            if selectedTab == 0 {
                VeteranOverviewView(veteran: veteran)
            } else if selectedTab == 1 {
                VeteranClaimsView(veteran: veteran)
            } else if selectedTab == 2 {
                VeteranDocumentsView(veteran: veteran)
            } else {
                VeteranActivityView(veteran: veteran)
            }
        }
    }
}

// MARK: - Contact Info Card
struct ContactInfoCard: View {
    let icon: String
    let text: String
    let color: Color
    let action: (() -> Void)?
    @State private var isHovered = false
    
    init(icon: String, text: String, color: Color, action: (() -> Void)? = nil) {
        self.icon = icon
        self.text = text
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(
                color: isHovered ? color.opacity(0.2) : .black.opacity(0.05),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Veteran Overview View
struct VeteranOverviewView: View {
    let veteran: Veteran
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Personal Information
            InfoSection(title: "Personal Information") {
                InfoRow(label: "Full Name", value: veteran.fullName)
                InfoRow(label: "Date of Birth", value: veteran.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Gender", value: veteran.gender)
                InfoRow(label: "Marital Status", value: veteran.maritalStatus)
                InfoRow(label: "SSN Last Four", value: veteran.ssnLastFour)
                InfoRow(label: "Address", value: "\(veteran.addressStreet ?? ""), \(veteran.addressCity ?? ""), \(veteran.addressState ?? "") \(veteran.addressZip)")
                InfoRow(label: "County", value: veteran.county)
                InfoRow(label: "Homeless Status", value: veteran.homelessStatus)
            }
            
            // Contact Information
            InfoSection(title: "Contact Information") {
                InfoRow(label: "Primary Email", value: veteran.emailPrimary)
                InfoRow(label: "Secondary Email", value: veteran.emailSecondary.isEmpty ? "None" : veteran.emailSecondary)
                InfoRow(label: "Primary Phone", value: veteran.phonePrimary)
                InfoRow(label: "Secondary Phone", value: veteran.phoneSecondary.isEmpty ? "None" : veteran.phoneSecondary)
                InfoRow(label: "Phone Type", value: veteran.phoneType)
                InfoRow(label: "Preferred Contact", value: veteran.preferredContactMethod)
                InfoRow(label: "Contact Time", value: veteran.preferredContactTime)
                InfoRow(label: "Language", value: veteran.languagePrimary)
                InfoRow(label: "Interpreter Needed", value: veteran.interpreterNeeded ? "Yes" : "No")
            }
            
            // Service Information
            InfoSection(title: "Service Information") {
                InfoRow(label: "Branch", value: veteran.serviceBranch)
                InfoRow(label: "Component", value: veteran.serviceComponent)
                InfoRow(label: "Service Period", value: "\(veteran.serviceStartDate.formatted(date: .abbreviated, time: .omitted)) - \(veteran.serviceEndDate.formatted(date: .abbreviated, time: .omitted))")
                InfoRow(label: "Years of Service", value: "\(veteran.yearsOfService)")
                InfoRow(label: "Discharge Date", value: veteran.dischargeDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Discharge Status", value: veteran.dischargeStatus)
                InfoRow(label: "Rank at Separation", value: veteran.rankAtSeparation)
                InfoRow(label: "Military Occupation", value: veteran.militaryOccupation)
                InfoRow(label: "Unit Assignments", value: veteran.unitAssignments)
                InfoRow(label: "Deployment Locations", value: veteran.deploymentLocations)
                InfoRow(label: "Combat Veteran", value: veteran.combatVeteran ? "Yes" : "No")
                InfoRow(label: "Combat Theaters", value: veteran.combatTheaters)
                InfoRow(label: "Purple Heart", value: veteran.purpleHeartRecipient ? "Yes" : "No")
                InfoRow(label: "Medals & Awards", value: veteran.medalsAndAwards)
                InfoRow(label: "POW Status", value: veteran.powStatus)
            }
            
            // Exposure Information
            InfoSection(title: "Exposure Information") {
                InfoRow(label: "Agent Orange", value: veteran.agentOrangeExposure ? "Yes" : "No")
                InfoRow(label: "Radiation", value: veteran.radiationExposure ? "Yes" : "No")
                InfoRow(label: "Burn Pit", value: veteran.burnPitExposure ? "Yes" : "No")
                InfoRow(label: "Gulf War Service", value: veteran.gulfWarService ? "Yes" : "No")
                InfoRow(label: "Camp Lejeune", value: veteran.campLejeuneExposure ? "Yes" : "No")
                InfoRow(label: "PACT Act Eligible", value: veteran.pactActEligible ? "Yes" : "No")
            }
            
            // VA Benefits Status
            InfoSection(title: "VA Benefits Status") {
                InfoRow(label: "Current Rating", value: "\(veteran.currentDisabilityRating)%")
                InfoRow(label: "VA Healthcare", value: veteran.vaHealthcareEnrolled ? "Yes" : "No")
                InfoRow(label: "Priority Group", value: veteran.priorityGroup)
                InfoRow(label: "VA Medical Center", value: veteran.vaMedicalCenter)
                InfoRow(label: "VA Clinic", value: veteran.vaClinic)
                InfoRow(label: "Primary Care", value: veteran.primaryCareProvider)
                InfoRow(label: "Patient Advocate", value: veteran.patientAdvocateContact)
            }
            
            // Education Benefits
            InfoSection(title: "Education Benefits") {
                InfoRow(label: "Education Benefits", value: veteran.educationBenefits)
                InfoRow(label: "GI Bill Start", value: veteran.giBillStartDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
                InfoRow(label: "Entitlement Months", value: "\(veteran.educationEntitlementMonths)")
                InfoRow(label: "Percent Eligible", value: "\(veteran.percentEligible)%")
                InfoRow(label: "Yellow Ribbon", value: veteran.yellowRibbon ? "Yes" : "No")
                InfoRow(label: "Current School", value: veteran.currentSchool)
                InfoRow(label: "Degree Program", value: veteran.degreeProgram)
                InfoRow(label: "Graduation Date", value: veteran.graduationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
            }
            
            // Home Loan Benefits
            InfoSection(title: "Home Loan Benefits") {
                InfoRow(label: "COE Issued", value: veteran.homeLoanCoeIssued ? "Yes" : "No")
                InfoRow(label: "COE Date", value: veteran.homeLoanCoeDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
                InfoRow(label: "Entitlement Remaining", value: "$\(veteran.homeLoanEntitlementRemaining)")
                InfoRow(label: "Loans Used", value: "\(veteran.homeLoanUsedCount)")
                InfoRow(label: "Current VA Loan", value: veteran.currentVaLoanActive ? "Yes" : "No")
                InfoRow(label: "Default Status", value: veteran.homeLoanDefault ? "Yes" : "No")
                InfoRow(label: "IRRRL Eligible", value: veteran.irrrlEligible ? "Yes" : "No")
            }
            
            // Insurance Benefits
            InfoSection(title: "Insurance Benefits") {
                InfoRow(label: "SGLI Active", value: veteran.sgliActive ? "Yes" : "No")
                InfoRow(label: "VGLI Enrolled", value: veteran.vgliEnrolled ? "Yes" : "No")
                InfoRow(label: "VGLI Coverage", value: "$\(veteran.vgliCoverageAmount)")
                InfoRow(label: "VMLI Eligible", value: veteran.vmliEligible ? "Yes" : "No")
            }
            
            // Pension & Compensation
            InfoSection(title: "Pension & Compensation") {
                InfoRow(label: "Pension Benefits", value: veteran.pensionBenefits ? "Yes" : "No")
                InfoRow(label: "Aid & Attendance", value: veteran.aidAndAttendance ? "Yes" : "No")
                InfoRow(label: "Housebound", value: veteran.houseboundBenefit ? "Yes" : "No")
                InfoRow(label: "Burial Benefits", value: veteran.burialBenefits ? "Yes" : "No")
                InfoRow(label: "Monthly Compensation", value: "$\(veteran.monthlyCompensation)")
                InfoRow(label: "Compensation Start", value: veteran.compensationStartDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not specified")
                InfoRow(label: "Back Pay Owed", value: "$\(veteran.backPayOwed)")
                InfoRow(label: "Back Pay Received", value: "$\(veteran.backPayReceived)")
                InfoRow(label: "Payment Method", value: veteran.paymentMethod)
            }
            
            // Dependents
            InfoSection(title: "Dependents") {
                InfoRow(label: "Has Dependents", value: veteran.hasDependents ? "Yes" : "No")
                InfoRow(label: "Spouse Dependent", value: veteran.spouseDependent ? "Yes" : "No")
                InfoRow(label: "Number of Children", value: "\(veteran.numberOfChildren)")
                InfoRow(label: "Disabled Children", value: "\(veteran.numberOfDisabledChildren)")
                InfoRow(label: "Dependent Parent", value: veteran.dependentParent ? "Yes" : "No")
                InfoRow(label: "Derivative Benefits", value: veteran.derivativeBenefits ? "Yes" : "No")
            }
            
            // Case Management
            InfoSection(title: "Case Management") {
                InfoRow(label: "Intake Date", value: veteran.intakeDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Case Opened", value: veteran.caseOpenedDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Case Status", value: veteran.caseStatus)
                InfoRow(label: "Assigned VSO", value: veteran.assignedVso)
                InfoRow(label: "VSO Organization", value: veteran.vsoOrganization)
                InfoRow(label: "Assigned Counselor", value: veteran.assignedCounselor)
                InfoRow(label: "Case Priority", value: veteran.casePriority)
                InfoRow(label: "Next Action", value: veteran.nextActionItem)
                InfoRow(label: "Next Owner", value: veteran.nextActionOwner)
                InfoRow(label: "Next Follow-up", value: veteran.nextFollowupDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not scheduled")
                InfoRow(label: "Last Contact", value: veteran.lastContactDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not contacted")
                InfoRow(label: "Contact Method", value: veteran.lastContactMethod)
                InfoRow(label: "Contact Attempts", value: "\(veteran.contactAttempts)")
                InfoRow(label: "Responsiveness", value: veteran.veteranResponsive)
            }
            
            // Special Circumstances
            InfoSection(title: "Special Circumstances") {
                InfoRow(label: "Terminal Illness", value: veteran.terminalIllness ? "Yes" : "No")
                InfoRow(label: "Financial Hardship", value: veteran.financialHardship ? "Yes" : "No")
                InfoRow(label: "Homeless Veteran", value: veteran.homelessVeteran ? "Yes" : "No")
                InfoRow(label: "Incarcerated", value: veteran.incarcerated ? "Yes" : "No")
                InfoRow(label: "Mental Health Crisis", value: veteran.mentalHealthCrisis ? "Yes" : "No")
                InfoRow(label: "Suicide Risk", value: veteran.suicideRisk ? "Yes" : "No")
                InfoRow(label: "Substance Abuse", value: veteran.substanceAbuse ? "Yes" : "No")
                InfoRow(label: "MST Survivor", value: veteran.mstSurvivor ? "Yes" : "No")
                InfoRow(label: "Women Veteran", value: veteran.womenVeteran ? "Yes" : "No")
                InfoRow(label: "Minority Veteran", value: veteran.minorityVeteran ? "Yes" : "No")
                InfoRow(label: "LGBTQ Veteran", value: veteran.lgbtqVeteran ? "Yes" : "No")
                InfoRow(label: "Elderly Veteran", value: veteran.elderlyVeteran ? "Yes" : "No")
                InfoRow(label: "Former Guard/Reserve", value: veteran.formerGuardReserve ? "Yes" : "No")
                InfoRow(label: "Blue Water Navy", value: veteran.blueWaterNavy ? "Yes" : "No")
            }
            
            // Portal & Technology
            InfoSection(title: "Portal & Technology") {
                InfoRow(label: "Portal Account", value: veteran.portalAccountCreated ? "Yes" : "No")
                InfoRow(label: "Portal Registration", value: veteran.portalRegistrationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not registered")
                InfoRow(label: "Last Login", value: veteran.portalLastLogin?.formatted(date: .abbreviated, time: .omitted) ?? "Never")
                InfoRow(label: "Login Count", value: "\(veteran.portalLoginCount)")
                InfoRow(label: "ID.me Verified", value: veteran.idMeVerified ? "Yes" : "No")
                InfoRow(label: "Login.gov Verified", value: veteran.loginGovVerified ? "Yes" : "No")
                InfoRow(label: "Two-Factor", value: veteran.twoFactorEnabled ? "Yes" : "No")
                InfoRow(label: "Document Uploads", value: "\(veteran.documentUploads)")
                InfoRow(label: "Portal Messages", value: "\(veteran.portalMessagesSent)")
            }
            
            // Notes
            if !veteran.counselorNotes.isEmpty {
                InfoSection(title: "Counselor Notes") {
                    Text(veteran.counselorNotes)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Enhanced Info Section
struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    @State private var isHovered = false
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isHovered ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(
            color: isHovered ? .black.opacity(0.1) : .black.opacity(0.05),
            radius: isHovered ? 12 : 6,
            x: 0,
            y: isHovered ? 6 : 3
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Enhanced Info Row
struct InfoRow: View {
    let label: String
    let value: String
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? .primary.opacity(0.05) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Veteran Claims View
struct VeteranClaimsView: View {
    let veteran: Veteran
    @State private var selectedClaim: Claim?
    @State private var showingClaimDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if veteran.claims.isEmpty {
                VStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No claims found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Add a claim to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(veteran.claims, id: \.id) { claim in
                    Button(action: {
                        selectedClaim = claim
                        showingClaimDetail = true
                    }) {
                        ClaimDetailCard(claim: claim)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .sheet(item: $selectedClaim) { claim in
            ClaimDetailModal(claim: claim)
        }
    }
}

// MARK: - Enhanced Claim Detail Card
struct ClaimDetailCard: View {
    let claim: Claim
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(claim.claimNumber)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(claim.claimType)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                StatusBadge(status: claim.claimStatus)
            }
            
            Text(claim.primaryCondition)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("Filed: \(claim.claimFiledDate, style: .date)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(claim.daysPending) days")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(
            color: isHovered ? .black.opacity(0.1) : .black.opacity(0.05),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}


// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Update Card
struct UpdateCard: View {
    let activity: ClaimActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.activityType.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1), in: Capsule())
                
                Spacer()
                
                Text(activity.date, style: .relative)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(activity.claimDescription)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Veteran Documents View
struct VeteranDocumentsView: View {
    let veteran: Veteran
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if veteran.documents.isEmpty {
                VStack {
                    Image(systemName: "doc")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No documents found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Upload documents to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(veteran.documents, id: \.id) { document in
                    DocumentCard(document: document)
                }
            }
        }
        .padding()
    }
}

// MARK: - Enhanced Document Card
struct DocumentCard: View {
    let document: Document
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Document Icon with Glass Effect
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(documentColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(documentColor.opacity(0.3), lineWidth: 2)
                    )
                
                Image(systemName: documentIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(documentColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(document.fileName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(document.documentType.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(documentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(documentColor.opacity(0.1), in: Capsule())
                
                if !document.documentDescription.isEmpty {
                    Text(document.documentDescription)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Uploaded: \(document.uploadDate, style: .date)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "doc")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(formatFileSize(document.fileSize))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: openDocument) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("View")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue.gradient, in: Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: downloadDocument) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("Download")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.green.opacity(0.1), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.green.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(
            color: isHovered ? .black.opacity(0.1) : .black.opacity(0.05),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var documentIcon: String {
        switch document.documentType {
        case .medicalRecord:
            return "cross.case.fill"
        case .serviceRecord:
            return "shield.fill"
        case .dischargeDocument:
            return "doc.text.fill"
        case .claimForm:
            return "doc.plaintext.fill"
        case .correspondence:
            return "envelope.fill"
        case .nexusLetter:
            return "stethoscope"
        case .dbq:
            return "list.clipboard.fill"
        case .buddyStatement:
            return "person.2.fill"
        case .dd214:
            return "flag.fill"
        case .vaForm:
            return "doc.text.magnifyingglass"
        case .other:
            return "doc.fill"
        }
    }
    
    private var documentColor: Color {
        switch document.documentType {
        case .medicalRecord:
            return .red
        case .serviceRecord:
            return .blue
        case .dischargeDocument:
            return .green
        case .claimForm:
            return .orange
        case .correspondence:
            return .purple
        case .nexusLetter:
            return .pink
        case .dbq:
            return .cyan
        case .buddyStatement:
            return .yellow
        case .dd214:
            return .indigo
        case .vaForm:
            return .brown
        case .other:
            return .gray
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func openDocument() {
        let url = URL(fileURLWithPath: document.filePath)
        NSWorkspace.shared.open(url)
    }
    
    private func downloadDocument() {
        let url = URL(fileURLWithPath: document.filePath)
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = document.fileName
        savePanel.allowedContentTypes = [UTType(filenameExtension: document.fileType) ?? .data]
        
        if savePanel.runModal() == .OK {
            do {
                try FileManager.default.copyItem(at: url, to: savePanel.url!)
            } catch {
                print("Error copying file: \(error)")
            }
        }
    }
}

// MARK: - Veteran Activity View
struct VeteranActivityView: View {
    let veteran: Veteran
    @State private var showingActivityDetail = false
    @State private var selectedActivity: ClaimActivity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Activity Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activity Timeline")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Recent activities for \(veteran.fullName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(allActivities.count) activities")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            .padding(.horizontal)
            
            if allActivities.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No Activities Yet")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Activities will appear here as you work with this veteran's claims.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(allActivities, id: \.id) { activity in
                        ActivityCard(activity: activity) {
                            selectedActivity = activity
                            showingActivityDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingActivityDetail) {
            if let activity = selectedActivity {
                ActivityDetailModal(activity: activity)
            }
        }
    }
    
    private var allActivities: [ClaimActivity] {
        var activities: [ClaimActivity] = []
        
        // Collect activities from all claims
        for claim in veteran.claims {
            activities.append(contentsOf: claim.activities)
        }
        
        // Sort by date (most recent first)
        return activities.sorted { $0.date > $1.date }
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let activity: ClaimActivity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Activity Icon
                Image(systemName: activityIcon)
                    .font(.title3)
                    .foregroundColor(activityColor)
                    .frame(width: 32, height: 32)
                    .background(activityColor.opacity(0.1))
                    .clipShape(Circle())
                
                // Activity Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(activity.activityType.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(activity.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(activity.claimDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if !activity.notes.isEmpty {
                        Text(activity.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Text("By: \(activity.performedBy)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let claim = activity.claim {
                            Text("Claim: \(claim.claimNumber)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var activityIcon: String {
        switch activity.activityType {
        case .phoneCall:
            return "phone.fill"
        case .email:
            return "envelope.fill"
        case .documentUpload:
            return "doc.badge.plus"
        case .statusChange:
            return "arrow.triangle.2.circlepath"
        case .note:
            return "note.text"
        case .meeting:
            return "person.2.fill"
        case .cAndPExam:
            return "stethoscope"
        case .nexusLetter:
            return "doc.text.magnifyingglass"
        case .appeal:
            return "gavel"
        case .hearing:
            return "building.2"
        case .other:
            return "questionmark.circle"
        }
    }
    
    private var activityColor: Color {
        switch activity.activityType {
        case .phoneCall:
            return .blue
        case .email:
            return .green
        case .documentUpload:
            return .orange
        case .statusChange:
            return .purple
        case .note:
            return .gray
        case .meeting:
            return .indigo
        case .cAndPExam:
            return .red
        case .nexusLetter:
            return .brown
        case .appeal:
            return .pink
        case .hearing:
            return .cyan
        case .other:
            return .secondary
        }
    }
}

#Preview {
    let veteran = Veteran(
        veteranId: "VET-12345678",
        ssnLastFour: "1234",
        firstName: "John",
        middleName: "Michael",
        lastName: "Doe",
        suffix: "Jr",
        preferredName: "John",
        dateOfBirth: Date(),
        gender: "Male",
        maritalStatus: "Married",
        emailPrimary: "john.doe@example.com",
        emailSecondary: "",
        phonePrimary: "(555) 123-4567",
        phoneSecondary: "",
        phoneType: "Mobile",
        addressStreet: "123 Main St",
        addressCity: "Anytown",
        addressState: "CA",
        addressZip: "12345",
        county: "Wake County",
        mailingAddressDifferent: false,
        homelessStatus: "Stable Housing",
        preferredContactMethod: "Email",
        preferredContactTime: "Morning (8-12)",
        languagePrimary: "English",
        interpreterNeeded: false,
        serviceBranch: "Army",
        serviceComponent: "Active Duty",
        serviceStartDate: Date(),
        serviceEndDate: Date(),
        yearsOfService: 8,
        dischargeDate: Date(),
        dischargeStatus: "Honorable",
        dischargeUpgradeSought: false,
        rankAtSeparation: "E-6",
        militaryOccupation: "0311 Rifleman",
        unitAssignments: "1st Battalion 5th Marines",
        deploymentLocations: "Iraq (2004, 2006), Afghanistan (2009)",
        combatVeteran: true,
        combatTheaters: "Iraq|Afghanistan",
        purpleHeartRecipient: false,
        medalsAndAwards: "Navy Achievement Medal, Combat Action Ribbon",
        powStatus: "No",
        agentOrangeExposure: false,
        radiationExposure: false,
        burnPitExposure: true,
        gulfWarService: true,
        campLejeuneExposure: false,
        pactActEligible: true,
        currentDisabilityRating: 70,
        vaHealthcareEnrolled: true,
        healthcareEnrollmentDate: Date(),
        priorityGroup: "1",
        vaMedicalCenter: "Durham VA Medical Center",
        vaClinic: "Durham CBOC",
        primaryCareProvider: "Dr. Emily Martinez",
        patientAdvocateContact: "John Smith (919) 286-0411",
        educationBenefits: "Post-9/11 GI Bill (Chapter 33)",
        giBillStartDate: Date(),
        educationEntitlementMonths: 18,
        percentEligible: 100,
        yellowRibbon: true,
        currentSchool: "North Carolina State University",
        degreeProgram: "Business Administration",
        graduationDate: Date(),
        vrAndEEnrolled: false,
        vrAndECounselor: "",
        homeLoanCoeIssued: true,
        homeLoanCoeDate: Date(),
        homeLoanEntitlementRemaining: 103500,
        homeLoanUsedCount: 1,
        currentVaLoanActive: true,
        homeLoanDefault: false,
        irrrlEligible: true,
        sgliActive: true,
        vgliEnrolled: true,
        vgliCoverageAmount: 400000,
        vmliEligible: true,
        pensionBenefits: false,
        aidAndAttendance: false,
        houseboundBenefit: false,
        burialBenefits: true,
        monthlyCompensation: 2845.50,
        compensationStartDate: Date(),
        backPayOwed: 28455.00,
        backPayReceived: 0,
        backPayDate: nil,
        paymentMethod: "Direct Deposit",
        bankAccountOnFile: true,
        paymentHeld: false,
        paymentHoldReason: "",
        overpaymentDebt: false,
        debtAmount: 0,
        debtRepaymentPlan: "",
        offsetActive: false,
        hasDependents: true,
        spouseDependent: true,
        numberOfChildren: 2,
        numberOfDisabledChildren: 0,
        dependentParent: false,
        derivativeBenefits: false,
        intakeDate: Date(),
        caseOpenedDate: Date(),
        caseStatus: "Active - Claim Filed",
        assignedVso: "Michael Rodriguez",
        vsoOrganization: "DAV",
        assignedCounselor: "Jennifer Smith (VA Copilot)",
        counselorNotes: "Working well with veteran. All evidence submitted. Waiting for C&P results.",
        casePriority: "Normal",
        priorityReason: "",
        nextActionItem: "Follow up after C&P exam results",
        nextActionOwner: "VA Copilot Staff",
        nextFollowupDate: Date(),
        lastContactDate: Date(),
        lastContactMethod: "Email",
        contactAttempts: 0,
        veteranResponsive: "Highly Responsive",
        barriersToClaim: "",
        requiresLegalAssistance: false,
        attorneyName: "",
        powerOfAttorney: true,
        poaOrganization: "DAV North Carolina",
        fiduciaryNeeded: false,
        fiduciaryAppointed: false,
        successLikelihood: "High",
        confidenceReasoning: "Strong nexus letter, positive C&P, clear service connection for PTSD",
        estimatedCompletionDate: Date(),
        caseClosedDate: nil,
        caseOutcome: "",
        satisfactionRating: 0,
        testimonialProvided: false,
        referralSource: "Web Search",
        wouldRecommend: true,
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
        disabledVeteran: true,
        socialSecurityDisability: false,
        unemployed: false,
        underemployed: false,
        portalAccountCreated: true,
        portalRegistrationDate: Date(),
        portalLastLogin: Date(),
        portalLoginCount: 47,
        idMeVerified: true,
        idMeVerificationDate: Date(),
        loginGovVerified: false,
        twoFactorEnabled: true,
        documentUploads: 12,
        portalMessagesSent: 8,
        emailNotificationsEnabled: true,
        smsNotificationsEnabled: true,
        optInMarketing: true,
        newsletterSubscriber: true,
        webinarInvitations: true,
        surveyParticipation: true,
        communityForumMember: true,
        advocacyVolunteer: true,
        vaGovApiSynced: true,
        vaProfileId: "VA-PROFILE-789456123",
        ebenefitsSynced: true,
        myhealthevetConnected: true,
        lastApiSync: Date(),
        apiSyncStatus: "Connected",
        recordCreatedBy: "System Admin",
        recordModifiedBy: "Jennifer Smith",
        hipaaConsentSigned: true,
        hipaaConsentDate: Date(),
        privacyNoticeAcknowledged: true,
        termsOfServiceAccepted: true,
        gdprDataRequest: false,
        recordRetentionDate: Date()
    )
    
    return VeteranDetailView(veteran: veteran)
        .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}

// MARK: - Helper Functions
extension VeteranDetailView {
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "chart.bar.fill"
        case 1: return "doc.text.fill"
        case 2: return "folder.fill"
        case 3: return "clock.fill"
        default: return "questionmark"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Overview"
        case 1: return "Claims"
        case 2: return "Documents"
        case 3: return "Activity"
        default: return "Unknown"
        }
    }
}

