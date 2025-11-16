//
//  EditClaimView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct EditClaimView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let claim: Claim
    
    // Basic Information
    @State private var claimNumber = ""
    @State private var claimType = ""
    @State private var claimStatus = ""
    @State private var claimFiledDate = Date()
    @State private var claimReceivedDate: Date? = nil
    @State private var claimDecisionDate: Date? = nil
    @State private var decisionNotificationDate: Date? = nil
    @State private var targetCompletionDate: Date? = nil
    @State private var actualCompletionDate: Date? = nil
    @State private var daysPending = 0
    @State private var previousStatus = ""
    
    // Conditions
    @State private var primaryCondition = ""
    @State private var primaryConditionCategory = ""
    @State private var secondaryConditions = ""
    @State private var totalConditionsClaimed = 0
    @State private var serviceConnectedConditions = ""
    @State private var nonServiceConnected = ""
    @State private var bilateralFactor = false
    @State private var individualUnemployability = false
    @State private var specialMonthlyCompensation = false
    
    // Nexus
    @State private var nexusLetterRequired = false
    @State private var nexusLetterObtained = false
    @State private var nexusProviderName = ""
    @State private var nexusLetterDate: Date? = nil
    
    // Exams
    @State private var dbqCompleted = false
    @State private var cAndPExamRequired = false
    @State private var cAndPExamDate: Date? = nil
    @State private var cAndPExamType = ""
    @State private var cAndPExamCompleted = false
    @State private var cAndPFavorable = false
    
    // Evidence
    @State private var buddyStatementProvided = false
    @State private var numberBuddyStatements = 0
    @State private var dd214OnFile = false
    @State private var dd214UploadDate: Date? = nil
    @State private var dd214Type = ""
    @State private var serviceTreatmentRecords = false
    @State private var strRequestDate: Date? = nil
    @State private var strReceivedDate: Date? = nil
    @State private var vaMedicalRecords = false
    @State private var vaRecordsRequestDate: Date? = nil
    @State private var privateMedicalRecords = false
    @State private var privateRecordsComplete = false
    @State private var medicalReleaseSigned = false
    
    // Forms & Dates
    @State private var intentToFileDate: Date? = nil
    @State private var itfConfirmationNumber = ""
    @State private var effectiveDate: Date? = nil
    @State private var vaForm21526ez = false
    @State private var vaForm214142 = false
    @State private var vaForm21781 = false
    @State private var vaForm21781a = false
    @State private var dependentVerification = false
    @State private var marriageCertificate = false
    @State private var birthCertificates = false
    
    // Appeals
    @State private var appealFiled = false
    @State private var appealType = ""
    @State private var appealFiledDate: Date? = nil
    @State private var appealAcknowledgmentDate: Date? = nil
    @State private var appealStatus = ""
    @State private var appealDocketNumber = ""
    @State private var noticeOfDisagreementDate: Date? = nil
    @State private var statementOfCaseDate: Date? = nil
    @State private var ssocDate: Date? = nil
    @State private var form9Date: Date? = nil
    @State private var boardHearingRequested = false
    @State private var boardHearingType = ""
    @State private var boardHearingDate: Date? = nil
    @State private var boardHearingCompleted = false
    @State private var hearingTranscriptReceived = false
    @State private var newEvidenceSubmitted = false
    @State private var remandReason = ""
    @State private var appealDecisionDate: Date? = nil
    @State private var appealOutcome = ""
    @State private var cavcFilingDeadline: Date? = nil
    
    // Collapsible sections
    @State private var isBasicInfoExpanded = true
    @State private var isConditionsExpanded = true
    @State private var isNexusExpanded = true
    @State private var isExamsExpanded = true
    @State private var isEvidenceExpanded = true
    @State private var isFormsExpanded = true
    @State private var isAppealsExpanded = true
    
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
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Edit Claim")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Claim #\(claim.claimNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
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
                VStack(alignment: .leading, spacing: 20) {
                    // Basic Information Section
                    CollapsibleSection(title: "Basic Information", icon: "doc.text.fill", isExpanded: $isBasicInfoExpanded) {
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
                                    Picker("Status", selection: $claimStatus) {
                                        ForEach(ClaimStatus.allCases, id: \.self) { status in
                                            Text(status.rawValue).tag(status.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Days Pending")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Days Pending", value: $daysPending, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Filed Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Filed Date", selection: $claimFiledDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Received Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Received Date", selection: Binding(
                                        get: { claimReceivedDate ?? Date() },
                                        set: { claimReceivedDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Decision Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Decision Date", selection: Binding(
                                        get: { claimDecisionDate ?? Date() },
                                        set: { claimDecisionDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notification Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Notification Date", selection: Binding(
                                        get: { decisionNotificationDate ?? Date() },
                                        set: { decisionNotificationDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Target Completion")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Target Completion", selection: Binding(
                                        get: { targetCompletionDate ?? Date() },
                                        set: { targetCompletionDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Actual Completion")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Actual Completion", selection: Binding(
                                        get: { actualCompletionDate ?? Date() },
                                        set: { actualCompletionDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Conditions Section
                    CollapsibleSection(title: "Conditions", icon: "cross.fill", isExpanded: $isConditionsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Primary Condition")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Primary Condition", text: $primaryCondition)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Condition Category")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Picker("Category", selection: $primaryConditionCategory) {
                                        ForEach(conditionCategories, id: \.self) { category in
                                            Text(category).tag(category)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Total Conditions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Total", value: $totalConditionsClaimed, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Secondary Conditions")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("Secondary Conditions", text: $secondaryConditions, axis: .vertical)
                                    .textFieldStyle(.roundedBorder)
                                    .lineLimit(3...6)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Service Connected")
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
                    
                    // Nexus Section
                    CollapsibleSection(title: "Nexus Letter", icon: "envelope.fill", isExpanded: $isNexusExpanded) {
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
                                    DatePicker("Nexus Date", selection: Binding(
                                        get: { nexusLetterDate ?? Date() },
                                        set: { nexusLetterDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Exams Section
                    CollapsibleSection(title: "C&P Exams", icon: "stethoscope", isExpanded: $isExamsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
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
                                    DatePicker("C&P Date", selection: Binding(
                                        get: { cAndPExamDate ?? Date() },
                                        set: { cAndPExamDate = $0 }
                                    ), displayedComponents: .date)
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
                    
                    // Evidence Section
                    CollapsibleSection(title: "Evidence & Records", icon: "folder.fill", isExpanded: $isEvidenceExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Buddy Statement Provided")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $buddyStatementProvided)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Number of Buddy Statements")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Count", value: $numberBuddyStatements, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DD214 On File")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $dd214OnFile)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DD214 Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("DD214 Type", text: $dd214Type)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("DD214 Upload Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("DD214 Date", selection: Binding(
                                        get: { dd214UploadDate ?? Date() },
                                        set: { dd214UploadDate = $0 }
                                    ), displayedComponents: .date)
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
                                    Text("STR Request Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("STR Request", selection: Binding(
                                        get: { strRequestDate ?? Date() },
                                        set: { strRequestDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("STR Received Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("STR Received", selection: Binding(
                                        get: { strReceivedDate ?? Date() },
                                        set: { strReceivedDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Medical Records")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaMedicalRecords)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Records Request Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("VA Request", selection: Binding(
                                        get: { vaRecordsRequestDate ?? Date() },
                                        set: { vaRecordsRequestDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
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
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Medical Release Signed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $medicalReleaseSigned)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Forms Section
                    CollapsibleSection(title: "Forms & Documentation", icon: "doc.text.fill", isExpanded: $isFormsExpanded) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Intent to File Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("ITF Date", selection: Binding(
                                        get: { intentToFileDate ?? Date() },
                                        set: { intentToFileDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ITF Confirmation Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("ITF Number", text: $itfConfirmationNumber)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Effective Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Effective Date", selection: Binding(
                                        get: { effectiveDate ?? Date() },
                                        set: { effectiveDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Form 21-526EZ")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaForm21526ez)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Form 21-4142")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaForm214142)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Form 21-781")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaForm21781)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("VA Form 21-781A")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $vaForm21781a)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Dependent Verification")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $dependentVerification)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Marriage Certificate")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $marriageCertificate)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Birth Certificates")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $birthCertificates)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                    
                    // Appeals Section
                    CollapsibleSection(title: "Appeals", icon: "scale.3d", isExpanded: $isAppealsExpanded) {
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
                                    Text("Appeal Filed Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Filed Date", selection: Binding(
                                        get: { appealFiledDate ?? Date() },
                                        set: { appealFiledDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Docket Number")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Docket Number", text: $appealDocketNumber)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Acknowledgment Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Acknowledgment", selection: Binding(
                                        get: { appealAcknowledgmentDate ?? Date() },
                                        set: { appealAcknowledgmentDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notice of Disagreement Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("NOD Date", selection: Binding(
                                        get: { noticeOfDisagreementDate ?? Date() },
                                        set: { noticeOfDisagreementDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Statement of Case Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("SOC Date", selection: Binding(
                                        get: { statementOfCaseDate ?? Date() },
                                        set: { statementOfCaseDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("SSOC Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("SSOC Date", selection: Binding(
                                        get: { ssocDate ?? Date() },
                                        set: { ssocDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Form 9 Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Form 9", selection: Binding(
                                        get: { form9Date ?? Date() },
                                        set: { form9Date = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
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
                                    DatePicker("Hearing Date", selection: Binding(
                                        get: { boardHearingDate ?? Date() },
                                        set: { boardHearingDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Board Hearing Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $boardHearingCompleted)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hearing Transcript Received")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $hearingTranscriptReceived)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("New Evidence Submitted")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Toggle("", isOn: $newEvidenceSubmitted)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Remand Reason")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Remand Reason", text: $remandReason)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Decision Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("Decision Date", selection: Binding(
                                        get: { appealDecisionDate ?? Date() },
                                        set: { appealDecisionDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Appeal Outcome")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextField("Appeal Outcome", text: $appealOutcome)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("CAVC Filing Deadline")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    DatePicker("CAVC Deadline", selection: Binding(
                                        get: { cavcFilingDeadline ?? Date() },
                                        set: { cavcFilingDeadline = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(sectionBackground)
                }
                .padding(20)
            }
            
            // Bottom Buttons
            HStack(spacing: 12) {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    saveClaim()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadClaimData()
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadClaimData() {
        // Basic Information
        claimNumber = claim.claimNumber
        claimType = claim.claimType
        claimStatus = claim.claimStatus
        claimFiledDate = claim.claimFiledDate
        claimReceivedDate = claim.claimReceivedDate
        claimDecisionDate = claim.claimDecisionDate
        decisionNotificationDate = claim.decisionNotificationDate
        targetCompletionDate = claim.targetCompletionDate
        actualCompletionDate = claim.actualCompletionDate
        daysPending = claim.daysPending
        previousStatus = claim.claimStatus
        
        // Conditions
        primaryCondition = claim.primaryCondition
        primaryConditionCategory = claim.primaryConditionCategory
        secondaryConditions = claim.secondaryConditions
        totalConditionsClaimed = claim.totalConditionsClaimed
        serviceConnectedConditions = claim.serviceConnectedConditions
        nonServiceConnected = claim.nonServiceConnected
        bilateralFactor = claim.bilateralFactor
        individualUnemployability = claim.individualUnemployability
        specialMonthlyCompensation = claim.specialMonthlyCompensation
        
        // Nexus
        nexusLetterRequired = claim.nexusLetterRequired
        nexusLetterObtained = claim.nexusLetterObtained
        nexusProviderName = claim.nexusProviderName
        nexusLetterDate = claim.nexusLetterDate
        
        // Exams
        dbqCompleted = claim.dbqCompleted
        cAndPExamRequired = claim.cAndPExamRequired
        cAndPExamDate = claim.cAndPExamDate
        cAndPExamType = claim.cAndPExamType
        cAndPExamCompleted = claim.cAndPExamCompleted
        cAndPFavorable = claim.cAndPFavorable
        
        // Evidence
        buddyStatementProvided = claim.buddyStatementProvided
        numberBuddyStatements = claim.numberBuddyStatements
        dd214OnFile = claim.dd214OnFile
        dd214UploadDate = claim.dd214UploadDate
        dd214Type = claim.dd214Type
        serviceTreatmentRecords = claim.serviceTreatmentRecords
        strRequestDate = claim.strRequestDate
        strReceivedDate = claim.strReceivedDate
        vaMedicalRecords = claim.vaMedicalRecords
        vaRecordsRequestDate = claim.vaRecordsRequestDate
        privateMedicalRecords = claim.privateMedicalRecords
        privateRecordsComplete = claim.privateRecordsComplete
        medicalReleaseSigned = claim.medicalReleaseSigned
        
        // Forms & Dates
        intentToFileDate = claim.intentToFileDate
        itfConfirmationNumber = claim.itfConfirmationNumber
        effectiveDate = claim.effectiveDate
        vaForm21526ez = claim.vaForm21526ez
        vaForm214142 = claim.vaForm214142
        vaForm21781 = claim.vaForm21781
        vaForm21781a = claim.vaForm21781a
        dependentVerification = claim.dependentVerification
        marriageCertificate = claim.marriageCertificate
        birthCertificates = claim.birthCertificates
        
        // Appeals
        appealFiled = claim.appealFiled
        appealType = claim.appealType
        appealFiledDate = claim.appealFiledDate
        appealAcknowledgmentDate = claim.appealAcknowledgmentDate
        appealStatus = claim.appealStatus
        appealDocketNumber = claim.appealDocketNumber
        noticeOfDisagreementDate = claim.noticeOfDisagreementDate
        statementOfCaseDate = claim.statementOfCaseDate
        ssocDate = claim.ssocDate
        form9Date = claim.form9Date
        boardHearingRequested = claim.boardHearingRequested
        boardHearingType = claim.boardHearingType
        boardHearingDate = claim.boardHearingDate
        boardHearingCompleted = claim.boardHearingCompleted
        hearingTranscriptReceived = claim.hearingTranscriptReceived
        newEvidenceSubmitted = claim.newEvidenceSubmitted
        remandReason = claim.remandReason
        appealDecisionDate = claim.appealDecisionDate
        appealOutcome = claim.appealOutcome
        cavcFilingDeadline = claim.cavcFilingDeadline
    }
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    private func saveClaim() {
        // Validate required fields
        guard !claimNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Claim number is required."
            showingErrorAlert = true
            return
        }
        
        guard !claimType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Claim type is required."
            showingErrorAlert = true
            return
        }
        
        let statusChanged = previousStatus != claimStatus
        
        // Basic Information
        claim.claimNumber = claimNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.claimType = claimType.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.claimStatus = claimStatus
        claim.claimFiledDate = claimFiledDate
        claim.claimReceivedDate = claimReceivedDate
        claim.claimDecisionDate = claimDecisionDate
        claim.decisionNotificationDate = decisionNotificationDate
        claim.targetCompletionDate = targetCompletionDate
        claim.actualCompletionDate = actualCompletionDate
        claim.daysPending = max(0, daysPending) // Ensure non-negative
        
        // Conditions
        claim.primaryCondition = primaryCondition.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.primaryConditionCategory = primaryConditionCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.secondaryConditions = secondaryConditions.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.totalConditionsClaimed = max(0, totalConditionsClaimed) // Ensure non-negative
        claim.serviceConnectedConditions = serviceConnectedConditions.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.nonServiceConnected = nonServiceConnected.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.bilateralFactor = bilateralFactor
        claim.individualUnemployability = individualUnemployability
        claim.specialMonthlyCompensation = specialMonthlyCompensation
        
        // Nexus
        claim.nexusLetterRequired = nexusLetterRequired
        claim.nexusLetterObtained = nexusLetterObtained
        claim.nexusProviderName = nexusProviderName.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.nexusLetterDate = nexusLetterDate
        
        // Exams
        claim.dbqCompleted = dbqCompleted
        claim.cAndPExamRequired = cAndPExamRequired
        claim.cAndPExamDate = cAndPExamDate
        claim.cAndPExamType = cAndPExamType.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.cAndPExamCompleted = cAndPExamCompleted
        claim.cAndPFavorable = cAndPFavorable
        
        // Evidence
        claim.buddyStatementProvided = buddyStatementProvided
        claim.numberBuddyStatements = max(0, numberBuddyStatements) // Ensure non-negative
        claim.dd214OnFile = dd214OnFile
        claim.dd214UploadDate = dd214UploadDate
        claim.dd214Type = dd214Type.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.serviceTreatmentRecords = serviceTreatmentRecords
        claim.strRequestDate = strRequestDate
        claim.strReceivedDate = strReceivedDate
        claim.vaMedicalRecords = vaMedicalRecords
        claim.vaRecordsRequestDate = vaRecordsRequestDate
        claim.privateMedicalRecords = privateMedicalRecords
        claim.privateRecordsComplete = privateRecordsComplete
        claim.medicalReleaseSigned = medicalReleaseSigned
        
        // Forms & Dates
        claim.intentToFileDate = intentToFileDate
        claim.itfConfirmationNumber = itfConfirmationNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.effectiveDate = effectiveDate
        claim.vaForm21526ez = vaForm21526ez
        claim.vaForm214142 = vaForm214142
        claim.vaForm21781 = vaForm21781
        claim.vaForm21781a = vaForm21781a
        claim.dependentVerification = dependentVerification
        claim.marriageCertificate = marriageCertificate
        claim.birthCertificates = birthCertificates
        
        // Appeals
        claim.appealFiled = appealFiled
        claim.appealType = appealType.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.appealFiledDate = appealFiledDate
        claim.appealAcknowledgmentDate = appealAcknowledgmentDate
        claim.appealStatus = appealStatus.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.appealDocketNumber = appealDocketNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.noticeOfDisagreementDate = noticeOfDisagreementDate
        claim.statementOfCaseDate = statementOfCaseDate
        claim.ssocDate = ssocDate
        claim.form9Date = form9Date
        claim.boardHearingRequested = boardHearingRequested
        claim.boardHearingType = boardHearingType.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.boardHearingDate = boardHearingDate
        claim.boardHearingCompleted = boardHearingCompleted
        claim.hearingTranscriptReceived = hearingTranscriptReceived
        claim.newEvidenceSubmitted = newEvidenceSubmitted
        claim.remandReason = remandReason.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.appealDecisionDate = appealDecisionDate
        claim.appealOutcome = appealOutcome.trimmingCharacters(in: .whitespacesAndNewlines)
        claim.cavcFilingDeadline = cavcFilingDeadline
        
        do {
            try modelContext.save()
            
            // Send email notification if status changed
            if statusChanged, let veteran = claim.veteran {
                let activityLogger = ActivityLogger(modelContext: modelContext)
                Task {
                    await activityLogger.sendClaimStatusUpdateEmail(
                        claim: claim,
                        veteran: veteran,
                        previousStatus: ClaimStatus(rawValue: previousStatus) ?? .new
                    )
                }
            }
            
            dismiss()
        } catch {
            errorMessage = "Failed to save claim: \(error.localizedDescription). Please try again."
            showingErrorAlert = true
        }
    }
}


#Preview {
    Text("EditClaimView Preview")
}
