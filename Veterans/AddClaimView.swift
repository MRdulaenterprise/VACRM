//
//  AddClaimView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct AddClaimView: View {
    let veteran: Veteran
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var claimNumber = ""
    @State private var claimType = ""
    @State private var status = ClaimStatus.new
    @State private var dateFiled = Date()
    @State private var claimDescription = ""
    @State private var priority = ClaimPriority.medium
    @State private var assignedTo = ""
    @State private var notes = ""
    
    // Additional comprehensive fields
    @State private var primaryConditions: [String] = [""]
    @State private var primaryConditionCategories: [String] = ["Mental Health"]
    @State private var secondaryConditions: [String] = [""]
    @State private var totalConditionsClaimed = 0
    @State private var serviceConnectedConditions = ""
    @State private var nonServiceConnected = ""
    @State private var bilateralFactor = false
    @State private var individualUnemployability = false
    @State private var specialMonthlyCompensation = false
    @State private var nexusLetterRequired = false
    @State private var nexusLetterObtained = false
    @State private var nexusProviderName = ""
    @State private var nexusLetterDate = Date()
    @State private var dbqCompleted = false
    @State private var cAndPExamRequired = false
    @State private var cAndPExamDate = Date()
    @State private var cAndPExamType = ""
    @State private var cAndPExamCompleted = false
    @State private var cAndPFavorable = false
    @State private var buddyStatementProvided = false
    @State private var numberBuddyStatements = 0
    @State private var dd214OnFile = false
    @State private var dd214UploadDate = Date()
    @State private var dd214Type = ""
    @State private var serviceTreatmentRecords = false
    @State private var strRequestDate = Date()
    @State private var strReceivedDate = Date()
    @State private var vaMedicalRecords = false
    @State private var vaRecordsRequestDate = Date()
    @State private var privateMedicalRecords = false
    @State private var privateRecordsComplete = false
    @State private var medicalReleaseSigned = false
    @State private var intentToFileDate = Date()
    @State private var itfConfirmationNumber = ""
    @State private var effectiveDate = Date()
    @State private var vaForm21526ez = false
    @State private var vaForm214142 = false
    @State private var vaForm21781 = false
    @State private var vaForm21781a = false
    @State private var dependentVerification = false
    @State private var marriageCertificate = false
    @State private var birthCertificates = false
    @State private var appealFiled = false
    @State private var appealType = ""
    @State private var appealFiledDate = Date()
    @State private var appealAcknowledgmentDate = Date()
    @State private var appealStatus = ""
    @State private var appealDocketNumber = ""
    @State private var noticeOfDisagreementDate = Date()
    @State private var statementOfCaseDate = Date()
    @State private var ssocDate = Date()
    @State private var form9Date = Date()
    @State private var boardHearingRequested = false
    @State private var boardHearingType = ""
    @State private var boardHearingDate = Date()
    @State private var boardHearingCompleted = false
    @State private var hearingTranscriptReceived = false
    @State private var newEvidenceSubmitted = false
    @State private var remandReason = ""
    @State private var appealDecisionDate = Date()
    @State private var appealOutcome = ""
    @State private var cavcFilingDeadline = Date()
    
    private let claimTypes = [
        "Disability Compensation",
        "Pension",
        "Survivors Benefits",
        "Education Benefits",
        "Vocational Rehabilitation",
        "Healthcare",
        "Burial Benefits",
        "Home Loan",
        "Life Insurance",
        "Appeal",
        "Supplemental Claim",
        "Higher-Level Review",
        "Board of Veterans Appeals",
        "Court of Appeals for Veterans Claims",
        "Other"
    ]
    
    private let conditionCategories = [
        "Mental Health",
        "Physical Injury",
        "Toxic Exposure",
        "Hearing Loss",
        "Vision Loss",
        "Respiratory",
        "Cardiovascular",
        "Neurological",
        "Musculoskeletal",
        "Skin Conditions",
        "Digestive",
        "Other"
    ]
    
    private let examTypes = [
        "General Medical",
        "Mental Health",
        "Audiology",
        "Ophthalmology",
        "Cardiology",
        "Neurology",
        "Orthopedic",
        "Dermatology",
        "Other"
    ]
    
    private let appealTypes = [
        "Notice of Disagreement (NOD)",
        "Supplemental Claim",
        "Higher-Level Review",
        "Board of Veterans Appeals",
        "Court of Appeals for Veterans Claims"
    ]
    
    private let hearingTypes = [
        "Video Conference",
        "In-Person",
        "Telephone",
        "Travel Board"
    ]
    
    // MARK: - State for Collapsible Sections
    @State private var isBasicInfoExpanded = true
    @State private var isMedicalConditionsExpanded = true
    @State private var isMedicalEvidenceExpanded = true
    @State private var isServiceRecordsExpanded = true
    @State private var isAppealsExpanded = true
    @State private var isNotesExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add New Claim")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("for \(veteran.fullName)")
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
                    
                    Button("Save Claim") {
                        saveClaim()
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
            
            // MARK: - Form Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Basic Claim Information Section
                    CollapsibleSection(title: "Basic Claim Information", icon: "doc.text.fill", isExpanded: $isBasicInfoExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Claim Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Claim Number", text: $claimNumber)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Claim Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Claim Type", selection: $claimType) {
                                        ForEach(claimTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Status")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Status", selection: $status) {
                                        ForEach(ClaimStatus.allCases, id: \.self) { status in
                                            Text(status.rawValue).tag(status)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Priority")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Priority", selection: $priority) {
                                        ForEach(ClaimPriority.allCases, id: \.self) { priority in
                                            Text(priority.rawValue).tag(priority)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date Filed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Date Filed", selection: $dateFiled, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Assigned To")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Assigned To", text: $assignedTo)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Medical Conditions Section
                    CollapsibleSection(title: "Medical Conditions", icon: "cross.fill", isExpanded: $isMedicalConditionsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            // Primary Conditions
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Primary Conditions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("+ Add Primary Condition") {
                                        primaryConditions.append("")
                                        primaryConditionCategories.append("Mental Health")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                ForEach(primaryConditions.indices, id: \.self) { index in
                                    HStack {
                                        TextField("Primary Condition \(index + 1)", text: $primaryConditions[index])
                                            .textFieldStyle(.roundedBorder)
                                        
                                        Picker("Category", selection: $primaryConditionCategories[index]) {
                                            ForEach(conditionCategories, id: \.self) { category in
                                                Text(category).tag(category)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 150)
                                        
                                        if primaryConditions.count > 1 {
                                            Button("-") {
                                                primaryConditions.remove(at: index)
                                                primaryConditionCategories.remove(at: index)
                                            }
                                            .buttonStyle(.bordered)
                                            .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Conditions Claimed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Total Conditions", value: $totalConditionsClaimed, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                Spacer()
                            }
                            
                            // Secondary Conditions
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Secondary Conditions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("+ Add Secondary Condition") {
                                        secondaryConditions.append("")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                ForEach(secondaryConditions.indices, id: \.self) { index in
                                    HStack {
                                        TextField("Secondary Condition \(index + 1)", text: $secondaryConditions[index])
                                            .textFieldStyle(.roundedBorder)
                                        
                                        if secondaryConditions.count > 1 {
                                            Button("-") {
                                                secondaryConditions.remove(at: index)
                                            }
                                            .buttonStyle(.bordered)
                                            .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Connected Conditions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Service Connected", text: $serviceConnectedConditions)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Non-Service Connected")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Non-Service Connected", text: $nonServiceConnected)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bilateral Factor")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $bilateralFactor)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Individual Unemployability")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $individualUnemployability)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Special Monthly Compensation")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $specialMonthlyCompensation)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Medical Evidence Section
                    CollapsibleSection(title: "Medical Evidence & Exams", icon: "stethoscope", isExpanded: $isMedicalEvidenceExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nexus Letter Required")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $nexusLetterRequired)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nexus Letter Obtained")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $nexusLetterObtained)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nexus Provider Name")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Provider Name", text: $nexusProviderName)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nexus Letter Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Nexus Letter Date", selection: $nexusLetterDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DBQ Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $dbqCompleted)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("C&P Exam Required")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $cAndPExamRequired)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("C&P Exam Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("C&P Exam Date", selection: $cAndPExamDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("C&P Exam Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Exam Type", selection: $cAndPExamType) {
                                        ForEach(examTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("C&P Exam Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $cAndPExamCompleted)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("C&P Exam Favorable")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $cAndPFavorable)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Service Records Section
                    CollapsibleSection(title: "Service Records & Documents", icon: "folder.fill", isExpanded: $isServiceRecordsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DD-214 On File")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $dd214OnFile)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DD-214 Upload Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("DD-214 Upload Date", selection: $dd214UploadDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Treatment Records")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $serviceTreatmentRecords)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Medical Records")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaMedicalRecords)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Private Medical Records")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $privateMedicalRecords)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Private Records Complete")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $privateRecordsComplete)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Medical Release Signed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $medicalReleaseSigned)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Buddy Statement Provided")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $buddyStatementProvided)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Number of Buddy Statements")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Number", value: $numberBuddyStatements, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Intent to File Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Intent to File Date", selection: $intentToFileDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Appeals Section
                    CollapsibleSection(title: "Appeals & Hearings", icon: "hammer.fill", isExpanded: $isAppealsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Filed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $appealFiled)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Appeal Type", selection: $appealType) {
                                        ForEach(appealTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Filed Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Appeal Filed Date", selection: $appealFiledDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Status")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Appeal Status", text: $appealStatus)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Board Hearing Requested")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $boardHearingRequested)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Board Hearing Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Hearing Type", selection: $boardHearingType) {
                                        ForEach(hearingTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Board Hearing Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Hearing Date", selection: $boardHearingDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Board Hearing Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $boardHearingCompleted)
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
                                Text("Claim Description")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Detailed claim description...", text: $claimDescription, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(4...8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Detailed Notes")
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
        !claimNumber.isEmpty &&
        !claimType.isEmpty &&
        !claimDescription.isEmpty &&
        !assignedTo.isEmpty &&
        !primaryConditions.filter { !$0.isEmpty }.isEmpty
    }
    
    private func saveClaim() {
        let newClaim = Claim(
            claimNumber: claimNumber,
            claimType: claimType,
            claimStatus: status.rawValue,
            claimFiledDate: dateFiled,
            claimReceivedDate: nil,
            claimDecisionDate: nil,
            decisionNotificationDate: nil,
            daysPending: 0,
            targetCompletionDate: nil,
            actualCompletionDate: nil,
            primaryCondition: primaryConditions.filter { !$0.isEmpty }.joined(separator: "; "),
            primaryConditionCategory: primaryConditionCategories.first ?? "Mental Health",
            secondaryConditions: secondaryConditions.filter { !$0.isEmpty }.joined(separator: "; "),
            totalConditionsClaimed: totalConditionsClaimed,
            serviceConnectedConditions: serviceConnectedConditions,
            nonServiceConnected: nonServiceConnected,
            bilateralFactor: bilateralFactor,
            individualUnemployability: individualUnemployability,
            specialMonthlyCompensation: specialMonthlyCompensation,
            nexusLetterRequired: nexusLetterRequired,
            nexusLetterObtained: nexusLetterObtained,
            nexusProviderName: nexusProviderName,
            nexusLetterDate: nexusLetterObtained ? nexusLetterDate : nil,
            dbqCompleted: dbqCompleted,
            cAndPExamRequired: cAndPExamRequired,
            cAndPExamDate: cAndPExamRequired ? cAndPExamDate : nil,
            cAndPExamType: cAndPExamType,
            cAndPExamCompleted: cAndPExamCompleted,
            cAndPFavorable: cAndPFavorable,
            buddyStatementProvided: buddyStatementProvided,
            numberBuddyStatements: numberBuddyStatements,
            dd214OnFile: dd214OnFile,
            dd214UploadDate: dd214OnFile ? dd214UploadDate : nil,
            dd214Type: dd214Type,
            serviceTreatmentRecords: serviceTreatmentRecords,
            strRequestDate: serviceTreatmentRecords ? strRequestDate : nil,
            strReceivedDate: serviceTreatmentRecords ? strReceivedDate : nil,
            vaMedicalRecords: vaMedicalRecords,
            vaRecordsRequestDate: vaMedicalRecords ? vaRecordsRequestDate : nil,
            privateMedicalRecords: privateMedicalRecords,
            privateRecordsComplete: privateRecordsComplete,
            medicalReleaseSigned: medicalReleaseSigned,
            intentToFileDate: intentToFileDate,
            itfConfirmationNumber: itfConfirmationNumber,
            effectiveDate: effectiveDate,
            vaForm21526ez: vaForm21526ez,
            vaForm214142: vaForm214142,
            vaForm21781: vaForm21781,
            vaForm21781a: vaForm21781a,
            dependentVerification: dependentVerification,
            marriageCertificate: marriageCertificate,
            birthCertificates: birthCertificates,
            appealFiled: appealFiled,
            appealType: appealType,
            appealFiledDate: appealFiled ? appealFiledDate : nil,
            appealAcknowledgmentDate: appealFiled ? appealAcknowledgmentDate : nil,
            appealStatus: appealStatus,
            appealDocketNumber: appealDocketNumber,
            noticeOfDisagreementDate: noticeOfDisagreementDate,
            statementOfCaseDate: statementOfCaseDate,
            ssocDate: ssocDate,
            form9Date: form9Date,
            boardHearingRequested: boardHearingRequested,
            boardHearingType: boardHearingType,
            boardHearingDate: boardHearingRequested ? boardHearingDate : nil,
            boardHearingCompleted: boardHearingCompleted,
            hearingTranscriptReceived: hearingTranscriptReceived,
            newEvidenceSubmitted: newEvidenceSubmitted,
            remandReason: remandReason,
            appealDecisionDate: appealDecisionDate,
            appealOutcome: appealOutcome,
            cavcFilingDeadline: cavcFilingDeadline
        )
        
        // Associate claim with veteran
        newClaim.veteran = veteran
        veteran.claims.append(newClaim)
        
        modelContext.insert(newClaim)
        
        do {
            try modelContext.save()
            
            // Log the activity
            let activityLogger = ActivityLogger(modelContext: modelContext)
            activityLogger.logClaimCreated(claim: newClaim, performedBy: "System")
            
            // Send email notification
            Task {
                await activityLogger.sendClaimCreatedEmail(claim: newClaim, veteran: veteran)
            }
            
            dismiss()
        } catch {
            print("Error saving claim: \(error)")
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
    
    return AddClaimView(veteran: veteran)
        .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}
