//
//  ActivityDetailModal.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct ActivityDetailModal: View {
    let activity: ClaimActivity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: activityIcon)
                                .font(.title2)
                                .foregroundColor(activityColor)
                                .frame(width: 32, height: 32)
                                .background(activityColor.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.activityType.rawValue)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(activity.claimDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Date and Performer Info
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Date & Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                                .frame(height: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Performed By")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(activity.performedBy)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    
                    // Notes Section
                    if !activity.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(activity.notes)
                                .font(.body)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                    }
                    
                    // Claim Information
                    if let claim = activity.claim {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Claim")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Claim Number:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(claim.claimNumber)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Claim Type:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(claim.claimType)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Status:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    StatusBadge(status: claim.claimStatus)
                                }
                                
                                if let veteran = claim.veteran {
                                    HStack {
                                        Text("Veteran:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(veteran.fullName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Activity Timeline Context
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Context")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("Activity ID: \(activity.id.uuidString.prefix(8))...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.orange)
                                Text("Type: \(activity.activityType.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let claim = activity.claim {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.green)
                                    Text("Associated with claim: \(claim.claimNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Activity Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: 1000)
        .frame(minHeight: 400, idealHeight: 600, maxHeight: 800)
    }
    
    // MARK: - Computed Properties
    
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
    let activity = ClaimActivity(
        activityType: .phoneCall,
        claimDescription: "Phone call with veteran regarding C&P exam",
        performedBy: "Jennifer Smith",
        notes: "Discussed upcoming C&P exam scheduled for next week. Veteran expressed concerns about the process. Provided reassurance and detailed explanation of what to expect. Veteran feels more confident now."
    )
    
    return ActivityDetailModal(activity: activity)
}
