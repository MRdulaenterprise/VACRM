//
//  KanbanBoardView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct KanbanBoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var claims: [Claim]
    @State private var draggedClaim: Claim?
    @State private var showingEditClaim = false
    @State private var selectedClaim: Claim?
    
    private let columns = [
        KanbanColumn(title: "New", status: .new, color: .blue),
        KanbanColumn(title: "In Progress", status: .inProgress, color: .orange),
        KanbanColumn(title: "Under Review", status: .underReview, color: .yellow),
        KanbanColumn(title: "Review of Evidence", status: .reviewOfEvidence, color: .purple),
        KanbanColumn(title: "Approved", status: .approved, color: .green),
        KanbanColumn(title: "Denied", status: .denied, color: .red),
        KanbanColumn(title: "Appealed", status: .appealed, color: .pink),
        KanbanColumn(title: "Closed", status: .closed, color: .gray)
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 20) {
                ForEach(columns, id: \.status) { column in
                    KanbanColumnView(
                        column: column,
                        claims: claimsForStatus(column.status),
                        onClaimMoved: moveClaim,
                        onClaimSelected: { claim in
                            selectedClaim = claim
                            showingEditClaim = true
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingEditClaim) {
            if let claim = selectedClaim {
                EditClaimView(claim: claim)
                    .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                    .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
            }
        }
    }
    
    private func claimsForStatus(_ status: ClaimStatus) -> [Claim] {
        return claims.filter { $0.claimStatus == status.rawValue }
    }
    
    private func moveClaim(_ claim: Claim, to newStatus: ClaimStatus) {
        claim.claimStatus = newStatus.rawValue
        
        do {
            try modelContext.save()
        } catch {
            print("Error updating claim status: \(error)")
        }
    }
}

struct KanbanColumn {
    let title: String
    let status: ClaimStatus
    let color: Color
}

struct KanbanColumnView: View {
    let column: KanbanColumn
    let claims: [Claim]
    let onClaimMoved: (Claim, ClaimStatus) -> Void
    let onClaimSelected: (Claim) -> Void
    
    @State private var draggedClaim: Claim?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                Text(column.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(claims.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(column.color.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(column.color.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(column.color.opacity(0.3), lineWidth: 1)
            )
            
            // Claims List
            LazyVStack(spacing: 8) {
                ForEach(claims, id: \.id) { claim in
                    ClaimCard(claim: claim)
                        .onTapGesture {
                            onClaimSelected(claim)
                        }
                }
            }
            .frame(minHeight: 200)
            .padding(.vertical, 8)
        }
        .frame(width: 300)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

struct ClaimCard: View {
    let claim: Claim
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Claim Header
            HStack {
                Text(claim.claimNumber)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                StatusBadge(status: claim.claimStatus)
            }
            
            // Claim Type
            Text(claim.claimType)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Claim Description
            Text(claim.primaryCondition)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Veteran Name
            if let veteran = claim.veteran {
                Text("Veteran: \(veteran.fullName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Priority and Date in one row
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption2)
                    
                    Text("Normal")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("\(claim.claimFiledDate, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Veteran.self, Claim.self, Document.self, ClaimActivity.self, MedicalCondition.self, MedicalConditionCategory.self, ConditionRelationship.self, configurations: config)
    
    return KanbanBoardView()
        .modelContainer(container)
}
