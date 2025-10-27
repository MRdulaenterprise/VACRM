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
    @State private var claimNumber = ""
    @State private var claimType = ""
    @State private var claimStatus = ""
    @State private var primaryCondition = ""
    @State private var secondaryConditions = ""
    @State private var previousStatus = ""
    
    init(claim: Claim) {
        self.claim = claim
    }
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Claim Number", text: $claimNumber)
                TextField("Claim Type", text: $claimType)
                TextField("Status", text: $claimStatus)
            }
            
            Section("Conditions") {
                TextField("Primary Condition", text: $primaryCondition)
                TextField("Secondary Conditions", text: $secondaryConditions)
            }
            
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    saveClaim()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            loadClaimData()
        }
    }
    
    private func loadClaimData() {
        claimNumber = claim.claimNumber
        claimType = claim.claimType
        claimStatus = claim.claimStatus
        primaryCondition = claim.primaryCondition
        secondaryConditions = claim.secondaryConditions
        previousStatus = claim.claimStatus
    }
    
    private func saveClaim() {
        let statusChanged = previousStatus != claimStatus
        
        claim.claimNumber = claimNumber
        claim.claimType = claimType
        claim.claimStatus = claimStatus
        claim.primaryCondition = primaryCondition
        claim.secondaryConditions = secondaryConditions
        
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
            print("Error saving claim: \(error)")
        }
    }
}

#Preview {
    Text("EditClaimView Preview")
}
