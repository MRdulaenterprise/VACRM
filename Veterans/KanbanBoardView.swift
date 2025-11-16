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
    @State private var searchText = ""
    
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
        VStack(spacing: 0) {
            // Search Bar
            searchBarView
            
            // Kanban Board
            GeometryReader { geometry in
                let columnWidth = calculateColumnWidth(availableWidth: geometry.size.width)
                
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(columns, id: \.status) { column in
                            KanbanColumnView(
                                column: column,
                                claims: claimsForStatus(column.status),
                                onClaimMoved: moveClaim,
                                onClaimSelected: { claim in
                                    selectedClaim = claim
                                    showingEditClaim = true
                                },
                                columnWidth: columnWidth
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingEditClaim) {
            if let claim = selectedClaim {
                EditClaimView(claim: claim)
                    .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                    .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search claims by number, type, condition, or veteran...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    private func calculateColumnWidth(availableWidth: CGFloat) -> CGFloat {
        let columnCount = CGFloat(columns.count)
        let horizontalPadding: CGFloat = 32 // 16 * 2
        let spacing: CGFloat = 12 * (columnCount - 1) // spacing between columns
        let minColumnWidth: CGFloat = 200 // Reduced minimum for better fit
        let maxColumnWidth: CGFloat = 320 // Slightly reduced max
        
        let calculatedWidth = (availableWidth - horizontalPadding - spacing) / columnCount
        
        // Clamp between min and max, but allow smaller if screen is very narrow
        // This ensures columns fit on screen when possible
        if calculatedWidth < minColumnWidth {
            // If calculated is too small, use minimum but allow horizontal scroll
            return minColumnWidth
        }
        
        return min(maxColumnWidth, calculatedWidth)
    }
    
    private func claimsForStatus(_ status: ClaimStatus) -> [Claim] {
        let statusFiltered = claims.filter { $0.claimStatus == status.rawValue }
        
        // Apply search filter if search text is not empty
        guard !searchText.isEmpty else {
            return statusFiltered
        }
        
        let searchLower = searchText.lowercased()
        return statusFiltered.filter { claim in
            // Search by claim number
            claim.claimNumber.lowercased().contains(searchLower) ||
            // Search by claim type
            claim.claimType.lowercased().contains(searchLower) ||
            // Search by primary condition
            claim.primaryCondition.lowercased().contains(searchLower) ||
            // Search by secondary conditions
            claim.secondaryConditions.lowercased().contains(searchLower) ||
            // Search by veteran name
            (claim.veteran?.fullName.lowercased().contains(searchLower) ?? false) ||
            // Search by status
            claim.claimStatus.lowercased().contains(searchLower)
        }
    }
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    private func moveClaim(_ claim: Claim, to newStatus: ClaimStatus) {
        claim.claimStatus = newStatus.rawValue
        
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to update claim status: \(error.localizedDescription). Please try again."
            showingErrorAlert = true
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
    let columnWidth: CGFloat
    
    @State private var draggedClaim: Claim?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                Text(column.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text("\(claims.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(column.color.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(column.color.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(column.color.opacity(0.3), lineWidth: 1)
            )
            
            // Claims List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(claims, id: \.id) { claim in
                        ClaimCard(claim: claim)
                            .onTapGesture {
                                onClaimSelected(claim)
                            }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: columnWidth)
        .frame(maxHeight: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

struct ClaimCard: View {
    let claim: Claim
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Claim Header - Compact
            HStack(spacing: 6) {
                Text(claim.claimNumber)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                StatusBadge(status: claim.claimStatus)
            }
            
            // Claim Type
            Text(claim.claimType)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Claim Description - More compact
            if !claim.primaryCondition.isEmpty {
                Text(claim.primaryCondition)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Veteran Name - Compact
            if let veteran = claim.veteran {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(veteran.fullName)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Date - Compact
            Text("\(claim.claimFiledDate, style: .date)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(10)
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
