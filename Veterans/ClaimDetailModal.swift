//
//  ClaimDetailModal.swift
//  Veterans
//
//  Created on 12/26/25.
//

import SwiftUI
import SwiftData

struct ClaimDetailModal: View {
    let claim: Claim
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditClaim = false
    @State private var newUpdateText = ""
    @State private var newUpdateType = "Note"
    @State private var showingAddUpdate = false
    @State private var showingVeteranDetail = false
    
    private let updateTypes = ["Note", "Status Change", "Document Received", "Appointment Scheduled", "Decision Made"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(claim.claimNumber)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(claim.claimType)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            StatusBadge(status: claim.claimStatus)
                        }
                        
                        if !claim.primaryCondition.isEmpty {
                            Text(claim.primaryCondition)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    // Veteran Information Section
                    if let veteran = claim.veteran {
                        VeteranInfoCard(veteran: veteran) {
                            showingVeteranDetail = true
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Veteran Information")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("No veteran associated with this claim")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Claim Information Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Claim Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Filed Date", value: claim.claimFiledDate.formatted(date: .abbreviated, time: .omitted))
                            InfoRow(label: "Days Pending", value: "\(claim.daysPending)")
                            InfoRow(label: "Total Conditions", value: "\(claim.totalConditionsClaimed)")
                            InfoRow(label: "Claim Status", value: claim.claimStatus)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    
                    // Updates & Notes Section
                    if !claim.activities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Updates & Notes")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddUpdate = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Add Update")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.blue, in: Capsule())
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(claim.activities.sorted(by: { $0.date > $1.date }), id: \.id) { activity in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(activity.activityType.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(activity.claimDescription)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                        
                                        if !activity.notes.isEmpty {
                                            Text(activity.notes)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                        }
                                        
                                        Text("By: \(activity.performedBy)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "note.text")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No updates yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Add the first update to track progress")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showingAddUpdate = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Add Update")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 8))
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    allClaimFieldsSection

                    Spacer(minLength: 20)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Claim Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEditClaim = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
        .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
        .sheet(isPresented: $showingEditClaim) {
            EditClaimView(claim: claim)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingAddUpdate) {
            addUpdateSheet
        }
        .sheet(isPresented: $showingVeteranDetail) {
            if let veteran = claim.veteran {
                VeteranDetailView(veteran: veteran, initialTab: nil)
                    .frame(minWidth: 1200, idealWidth: 1400, maxWidth: 1600)
                    .frame(minHeight: 800, idealHeight: 900, maxHeight: 1000)
            }
        }
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "—" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    // Split out the large fields grid to keep type-checking fast
    @ViewBuilder
    private var allClaimFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Claim Fields")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Basics
                InfoRow(label: "Claim Number", value: claim.claimNumber)
                InfoRow(label: "Claim Type", value: claim.claimType)
                InfoRow(label: "Status", value: claim.claimStatus)
                InfoRow(label: "Filed Date", value: claim.claimFiledDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Received Date", value: formatDate(claim.claimReceivedDate))
                InfoRow(label: "Decision Date", value: formatDate(claim.claimDecisionDate))
                InfoRow(label: "Notification Date", value: formatDate(claim.decisionNotificationDate))
                InfoRow(label: "Days Pending", value: String(claim.daysPending))
                InfoRow(label: "Target Completion", value: formatDate(claim.targetCompletionDate))
                InfoRow(label: "Actual Completion", value: formatDate(claim.actualCompletionDate))
                InfoRow(label: "Primary Condition", value: claim.primaryCondition)
                InfoRow(label: "Condition Category", value: claim.primaryConditionCategory)
                InfoRow(label: "Secondary Conditions", value: claim.secondaryConditions)
                InfoRow(label: "Total Conditions", value: String(claim.totalConditionsClaimed))
                
                // Service connection
                InfoRow(label: "Service Connected", value: claim.serviceConnectedConditions)
                InfoRow(label: "Non-Service Connected", value: claim.nonServiceConnected)
                InfoRow(label: "Bilateral Factor", value: claim.bilateralFactor ? "Yes" : "No")
                InfoRow(label: "Individual Unemployability", value: claim.individualUnemployability ? "Yes" : "No")
                InfoRow(label: "SMC", value: claim.specialMonthlyCompensation ? "Yes" : "No")
                
                // Nexus
                InfoRow(label: "Nexus Required", value: claim.nexusLetterRequired ? "Yes" : "No")
                InfoRow(label: "Nexus Obtained", value: claim.nexusLetterObtained ? "Yes" : "No")
                InfoRow(label: "Nexus Provider", value: claim.nexusProviderName)
                InfoRow(label: "Nexus Date", value: formatDate(claim.nexusLetterDate))
                
                // Exams
                InfoRow(label: "C&P Required", value: claim.cAndPExamRequired ? "Yes" : "No")
                InfoRow(label: "C&P Date", value: formatDate(claim.cAndPExamDate))
                InfoRow(label: "C&P Type", value: claim.cAndPExamType)
                InfoRow(label: "C&P Completed", value: claim.cAndPExamCompleted ? "Yes" : "No")
                InfoRow(label: "C&P Favorable", value: claim.cAndPFavorable ? "Yes" : "No")
                
                // Evidence
                InfoRow(label: "Buddy Statement", value: claim.buddyStatementProvided ? "Yes" : "No")
                InfoRow(label: "Buddy Statement Count", value: String(claim.numberBuddyStatements))
                InfoRow(label: "DD214 On File", value: claim.dd214OnFile ? "Yes" : "No")
                InfoRow(label: "DD214 Upload Date", value: formatDate(claim.dd214UploadDate))
                InfoRow(label: "DD214 Type", value: claim.dd214Type)
                InfoRow(label: "STR On File", value: claim.serviceTreatmentRecords ? "Yes" : "No")
                InfoRow(label: "STR Request Date", value: formatDate(claim.strRequestDate))
                InfoRow(label: "STR Received Date", value: formatDate(claim.strReceivedDate))
                InfoRow(label: "VA Medical Records", value: claim.vaMedicalRecords ? "Yes" : "No")
                InfoRow(label: "Private Medical Records", value: claim.privateMedicalRecords ? "Yes" : "No")
                InfoRow(label: "VA Records Request Date", value: formatDate(claim.vaRecordsRequestDate))
                InfoRow(label: "Private Records Complete", value: claim.privateRecordsComplete ? "Yes" : "No")
                
                // Appeals
                InfoRow(label: "Appeal Filed", value: claim.appealFiled ? "Yes" : "No")
                InfoRow(label: "Appeal Type", value: claim.appealType)
                InfoRow(label: "Appeal Status", value: claim.appealStatus)
                InfoRow(label: "Board Hearing Requested", value: claim.boardHearingRequested ? "Yes" : "No")
                InfoRow(label: "Board Hearing Type", value: claim.boardHearingType)
                InfoRow(label: "Board Hearing Date", value: formatDate(claim.boardHearingDate))
                InfoRow(label: "Board Hearing Completed", value: claim.boardHearingCompleted ? "Yes" : "No")
                InfoRow(label: "Hearing Transcript Received", value: claim.hearingTranscriptReceived ? "Yes" : "No")
                InfoRow(label: "New Evidence Submitted", value: claim.newEvidenceSubmitted ? "Yes" : "No")
                InfoRow(label: "Remand Reason", value: claim.remandReason)
                InfoRow(label: "Appeal Decision Date", value: formatDate(claim.appealDecisionDate))
                InfoRow(label: "Appeal Outcome", value: claim.appealOutcome)
                InfoRow(label: "CAVC Filing Deadline", value: formatDate(claim.cavcFilingDeadline))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper View
    struct InfoRow: View {
        let label: String
        let value: String
        
        var body: some View {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
    
    private var addUpdateSheet: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                Text("Add Update")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        showingAddUpdate = false
                        newUpdateText = ""
                        newUpdateType = "Note"
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        addUpdate()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newUpdateText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Update Type")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Picker("Update Type", selection: $newUpdateType) {
                            ForEach(updateTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Update Details")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("Enter update details...", text: $newUpdateText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .lineLimit(4...8)
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
        }
        .frame(width: 600, height: 400)
    }
    
    private func addUpdate() {
        let activityType = ActivityType(rawValue: newUpdateType) ?? .note
        let activity = ClaimActivity(
            activityType: activityType,
            claimDescription: newUpdateText,
            performedBy: "Current User"
        )
        
        activity.claim = claim
        claim.activities.append(activity)
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
            newUpdateText = ""
            newUpdateType = "Note"
            showingAddUpdate = false
        } catch {
            print("Error saving update: \(error)")
        }
    }
}

// MARK: - Veteran Info Card

struct VeteranInfoCard: View {
    let veteran: Veteran
    let onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Veteran Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Veteran Icon
                    ZStack {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Veteran Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(veteran.firstName) \(veteran.lastName)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            if !veteran.veteranId.isEmpty {
                                Label("ID: \(veteran.veteranId)", systemImage: "number")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            if !veteran.emailPrimary.isEmpty {
                                Label(veteran.emailPrimary, systemImage: "envelope")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            if !veteran.phonePrimary.isEmpty {
                                Label(veteran.phonePrimary, systemImage: "phone")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Arrow Icon
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovered ? .blue.opacity(0.5) : .blue.opacity(0.3), lineWidth: isHovered ? 2 : 1)
                )
                .shadow(color: isHovered ? .blue.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }
}

#Preview {
    Text("ClaimDetailModal Preview")
}

