//
//  DocumentUploadView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DocumentUploadView: View {
    let veteran: Veteran?
    let claim: Claim?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFiles: [URL] = []
    @State private var documentType: DocumentType = .other
    @State private var documentDescription = ""
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0.0
    @State private var showingFilePicker = false
    
    private let documentTypes = DocumentType.allCases
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            formContentView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: true
        ) { result in
            handleFileSelection(result)
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "folder.badge.plus")
                .font(.title2)
                .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upload Documents")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let veteran = veteran {
                        Text("for \(veteran.fullName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Upload") {
                    uploadDocuments()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedFiles.isEmpty || isUploading)
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
    }
    
    private var formContentView: some View {
        VStack(spacing: 0) {
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    // File Selection Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "folder")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("Select Files")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 16) {
                            // Drag and Drop Area
                            VStack(spacing: 16) {
                                Image(systemName: "cloud.upload")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundColor(.blue.opacity(0.6))
                                
                                VStack(spacing: 8) {
                                    Text("Drag & Drop Files Here")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("or click to browse")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: selectFiles) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Choose Files")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(.blue, in: Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.blue.opacity(0.3), lineWidth: 2)
                                            .stroke(.blue.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                                handleDrop(providers: providers)
                            }
                            
                            if !selectedFiles.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Selected Files (\(selectedFiles.count))")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Button("Clear All") {
                                            selectedFiles.removeAll()
                                        }
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                    }
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.adaptive(minimum: 200), spacing: 12)
                                    ], spacing: 12) {
                                        ForEach(selectedFiles, id: \.self) { file in
                                            DocumentPreviewCard(file: file) {
                                                removeFile(file)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Document Information Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Document Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Document Type")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Document Type", selection: $documentType) {
                                ForEach(documentTypes, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Document description...", text: $documentDescription, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("Add tag...", text: $newTag)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button("Add") {
                                    addTag()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .disabled(newTag.isEmpty)
                            }
                            
                            if !tags.isEmpty {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100))
                                ], spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack {
                                            Text(tag)
                                                .font(.caption)
                                            Button(action: { removeTag(tag) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Upload Progress
                    if isUploading {
                        VStack(spacing: 12) {
                            ProgressView(value: uploadProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("Uploading documents... \(Int(uploadProgress * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
    }
    
    private func selectFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .pdf,
            .text,
            .rtf,
            .plainText,
            .image,
            .jpeg,
            .png,
            .gif,
            .bmp,
            .tiff,
            .heic,
            .heif
        ]
        
        if panel.runModal() == .OK {
            selectedFiles = panel.urls
        }
    }
    
    private func removeFile(_ file: URL) {
        selectedFiles.removeAll { $0 == file }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func uploadDocuments() {
        guard !selectedFiles.isEmpty else { return }
        
        isUploading = true
        uploadProgress = 0.0
        
        // Simulate upload progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            uploadProgress += 0.1
            if uploadProgress >= 1.0 {
                timer.invalidate()
                processDocuments()
            }
        }
    }
    
    private func processDocuments() {
        var createdDocuments: [Document] = []
        
        for file in selectedFiles {
            let document = Document(
                fileName: file.lastPathComponent,
                fileType: file.pathExtension,
                fileSize: getFileSize(url: file),
                documentType: documentType,
                documentDescription: documentDescription,
                filePath: file.path
            )
            
            // Associate with veteran and/or claim
            document.veteran = veteran
            document.claim = claim
            
            // Add tags as part of description
            if !tags.isEmpty {
                let tagString = tags.joined(separator: ", ")
                document.documentDescription = "\(documentDescription) [Tags: \(tagString)]"
            }
            
            modelContext.insert(document)
            createdDocuments.append(document)
            
            // Add to veteran's documents if veteran is provided
            if let veteran = veteran {
                veteran.documents.append(document)
            }
            
            // Add to claim's documents if claim is provided
            if let claim = claim {
                claim.documents.append(document)
            }
        }
        
        do {
            try modelContext.save()
            
            // Log the activity for each created document
            let activityLogger = ActivityLogger(modelContext: modelContext)
            for document in createdDocuments {
                activityLogger.logDocumentUploaded(document: document, performedBy: "System")
                
                // Send email notification for each document
                if let veteran = document.veteran {
                    Task {
                        await activityLogger.sendDocumentUploadedEmail(document: document, veteran: veteran)
                    }
                }
            }
            
            isUploading = false
            dismiss()
        } catch {
            print("Error saving documents: \(error)")
            isUploading = false
        }
    }
    
    private func getFileSize(url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
}

#Preview {
    let veteran = Veteran(
        veteranId: "12345678",
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
    
    return DocumentUploadView(veteran: veteran, claim: nil)
        .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}

// MARK: - Document Preview Card
struct DocumentPreviewCard: View {
    let file: URL
    let onRemove: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            // File Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(fileIconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: fileIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(fileIconColor)
            }
            
            // File Info
            VStack(spacing: 4) {
                Text(file.lastPathComponent)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(fileSize)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Remove Button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovered ? 1 : 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .shadow(color: .black.opacity(0.05), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var fileIcon: String {
        let ext = file.pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "jpg", "jpeg", "png", "gif": return "photo.fill"
        case "mp4", "mov", "avi": return "video.fill"
        case "mp3", "wav", "m4a": return "music.note"
        default: return "doc.fill"
        }
    }
    
    private var fileIconColor: Color {
        let ext = file.pathExtension.lowercased()
        switch ext {
        case "pdf": return .red
        case "doc", "docx": return .blue
        case "jpg", "jpeg", "png", "gif": return .green
        case "mp4", "mov", "avi": return .purple
        case "mp3", "wav", "m4a": return .orange
        default: return .gray
        }
    }
    
    private var fileSize: String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
            if let size = attributes[.size] as? Int64 {
                return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return "Unknown size"
    }
}

// MARK: - Helper Functions
extension DocumentUploadView {
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        DispatchQueue.main.async {
                            if !selectedFiles.contains(url) {
                                selectedFiles.append(url)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                if !selectedFiles.contains(url) {
                    selectedFiles.append(url)
                }
            }
        case .failure(let error):
            print("File picker error: \(error)")
        }
    }
}
