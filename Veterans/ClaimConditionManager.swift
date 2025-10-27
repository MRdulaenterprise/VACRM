//
//  ClaimConditionManager.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct ClaimConditionManager: View {
    let claim: Claim
    @Environment(\.modelContext) private var modelContext
    @State private var conditions: [MedicalCondition] = []
    @State private var showingAddCondition = false
    @State private var selectedCondition: MedicalCondition?
    @State private var showingConditionDetail = false
    @State private var showingRelationshipManager = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Medical Conditions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Manage Relationships") {
                        showingRelationshipManager = true
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("Add Condition") {
                        showingAddCondition = true
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .padding()
            
            // Conditions Summary
            if !conditions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(conditions.count) conditions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "Primary",
                            count: conditions.filter { $0.isPrimary }.count,
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Secondary",
                            count: conditions.filter { $0.isSecondary }.count,
                            color: .orange
                        )
                        
                        SummaryCard(
                            title: "Service Connected",
                            count: conditions.filter { $0.isServiceConnected }.count,
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Bilateral",
                            count: conditions.filter { $0.isBilateral }.count,
                            color: .purple
                        )
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            // Conditions List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(conditions) { condition in
                        ClaimConditionCard(
                            condition: condition,
                            onTap: {
                                selectedCondition = condition
                                showingConditionDetail = true
                            },
                            onEdit: {
                                // Handle edit
                            },
                            onDelete: {
                                deleteCondition(condition)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddCondition) {
            AddConditionToClaimView(claim: claim, conditions: $conditions)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
        }
        .sheet(isPresented: $showingConditionDetail) {
            if let condition = selectedCondition {
                ConditionDetailView(condition: condition)
                    .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                    .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
            }
        }
        .sheet(isPresented: $showingRelationshipManager) {
            ConditionRelationshipManager(conditions: conditions)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
        }
        .onAppear {
            loadConditions()
        }
    }
    
    private func loadConditions() {
        // Load conditions associated with this claim
        conditions = claim.conditions
    }
    
    private func deleteCondition(_ condition: MedicalCondition) {
        modelContext.delete(condition)
        conditions.removeAll { $0.id == condition.id }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting condition: \(error)")
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Claim Condition Card
struct ClaimConditionCard: View {
    let condition: MedicalCondition
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(condition.conditionName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(condition.category?.name ?? "No Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        if condition.isPrimary {
                            Label("Primary", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if condition.isSecondary {
                            Label("Secondary", systemImage: "star")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if condition.isServiceConnected {
                            Label("SC", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        if condition.isBilateral {
                            Label("Bilateral", systemImage: "arrow.left.arrow.right")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    if condition.ratingPercentage > 0 {
                        Text("\(condition.ratingPercentage)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if !condition.conditionDescription.isEmpty {
                Text(condition.conditionDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            }
            
            // Evidence Status
            HStack {
                if condition.nexusLetterObtained {
                    Label("Nexus", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if condition.dbqCompleted {
                    Label("DBQ", systemImage: "list.clipboard")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if condition.cAndPExamCompleted {
                    Label("C&P", systemImage: "stethoscope")
                        .font(.caption)
                        .foregroundColor(.cyan)
                }
                
                if condition.buddyStatementProvided {
                    Label("Buddy", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Edit") {
                        onEdit()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .font(.caption)
                    
                    Button("Delete") {
                        onDelete()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .foregroundColor(.red)
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Add Condition to Claim View
struct AddConditionToClaimView: View {
    let claim: Claim
    @Binding var conditions: [MedicalCondition]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var conditionName = ""
    @State private var selectedCategory: MedicalConditionCategory?
    @State private var isPrimary = false
    @State private var isSecondary = false
    @State private var isServiceConnected = false
    @State private var isBilateral = false
    @State private var ratingPercentage = 0
    @State private var effectiveDate = Date()
    @State private var diagnosisDate = Date()
    @State private var description = ""
    @State private var symptoms = ""
    @State private var treatmentHistory = ""
    @State private var nexusLetterRequired = false
    @State private var nexusLetterObtained = false
    @State private var nexusProviderName = ""
    @State private var nexusLetterDate = Date()
    @State private var dbqCompleted = false
    @State private var cAndPExamRequired = false
    @State private var cAndPExamDate = Date()
    @State private var cAndPExamCompleted = false
    @State private var cAndPFavorable = false
    @State private var buddyStatementProvided = false
    @State private var medicalRecordsOnFile = false
    @State private var privateMedicalRecords = false
    @State private var vaMedicalRecords = false
    @State private var serviceTreatmentRecords = false
    @State private var notes = ""
    
    @Query private var categories: [MedicalConditionCategory]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Condition to Claim")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("Save") {
                        saveCondition()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(conditionName.isEmpty)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Condition Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Enter condition name", text: $conditionName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select Category").tag(nil as MedicalConditionCategory?)
                                ForEach(categories, id: \.id) { category in
                                    Text(category.name).tag(category as MedicalConditionCategory?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Condition description", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Classification
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Classification")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Primary Condition", isOn: $isPrimary)
                                Toggle("Secondary Condition", isOn: $isSecondary)
                                Toggle("Service Connected", isOn: $isServiceConnected)
                                Toggle("Bilateral", isOn: $isBilateral)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rating Percentage")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextField("0", value: $ratingPercentage, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Evidence and Documentation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Evidence and Documentation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Nexus Letter Required", isOn: $nexusLetterRequired)
                            if nexusLetterRequired {
                                HStack {
                                    Toggle("Nexus Letter Obtained", isOn: $nexusLetterObtained)
                                    if nexusLetterObtained {
                                        TextField("Provider Name", text: $nexusProviderName)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                            }
                            
                            Toggle("DBQ Completed", isOn: $dbqCompleted)
                            
                            Toggle("C&P Exam Required", isOn: $cAndPExamRequired)
                            if cAndPExamRequired {
                                HStack {
                                    Toggle("C&P Exam Completed", isOn: $cAndPExamCompleted)
                                    if cAndPExamCompleted {
                                        Toggle("C&P Exam Favorable", isOn: $cAndPFavorable)
                                    }
                                }
                            }
                            
                            Toggle("Buddy Statement Provided", isOn: $buddyStatementProvided)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Additional notes about this condition", text: $notes, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(4...8)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
    
    private func saveCondition() {
        let newCondition = MedicalCondition(
            conditionName: conditionName,
            category: selectedCategory,
            isPrimary: isPrimary,
            isSecondary: isSecondary,
            isServiceConnected: isServiceConnected,
            isBilateral: isBilateral,
            ratingPercentage: ratingPercentage,
            effectiveDate: effectiveDate,
            diagnosisDate: diagnosisDate,
            description: description,
            symptoms: symptoms,
            treatmentHistory: treatmentHistory,
            nexusLetterRequired: nexusLetterRequired,
            nexusLetterObtained: nexusLetterObtained,
            nexusProviderName: nexusProviderName,
            nexusLetterDate: nexusLetterObtained ? nexusLetterDate : nil,
            dbqCompleted: dbqCompleted,
            cAndPExamRequired: cAndPExamRequired,
            cAndPExamDate: cAndPExamRequired ? cAndPExamDate : nil,
            cAndPExamCompleted: cAndPExamCompleted,
            cAndPFavorable: cAndPFavorable,
            buddyStatementProvided: buddyStatementProvided,
            medicalRecordsOnFile: medicalRecordsOnFile,
            privateMedicalRecords: privateMedicalRecords,
            vaMedicalRecords: vaMedicalRecords,
            serviceTreatmentRecords: serviceTreatmentRecords,
            notes: notes
        )
        
        // Associate with claim
        newCondition.claim = claim
        claim.conditions.append(newCondition)
        
        modelContext.insert(newCondition)
        conditions.append(newCondition)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving condition: \(error)")
        }
    }
}

// MARK: - Condition Relationship Manager
struct ConditionRelationshipManager: View {
    let conditions: [MedicalCondition]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var relationships: [ConditionRelationship] = []
    @State private var showingAddRelationship = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Condition Relationships")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("Add Relationship") {
                        showingAddRelationship = true
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .padding()
            
            // Relationships List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(relationships) { relationship in
                        RelationshipCard(relationship: relationship)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddRelationship) {
            AddRelationshipView(conditions: conditions, relationships: $relationships)
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 500, idealHeight: 700, maxHeight: 900)
        }
        .onAppear {
            loadRelationships()
        }
    }
    
    private func loadRelationships() {
        // Load relationships for these conditions
        // This would typically involve a query to get all relationships
        // where either the primary or secondary condition is in the conditions array
    }
}

// MARK: - Relationship Card
struct RelationshipCard: View {
    let relationship: ConditionRelationship
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(relationship.primaryCondition?.conditionName ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(relationship.relationshipType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(relationship.secondaryCondition?.conditionName ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            if !relationship.conditionDescription.isEmpty {
                Text(relationship.conditionDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if relationship.isServiceConnected {
                    Label("Service Connected", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if relationship.nexusRequired {
                    Label("Nexus Required", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if relationship.nexusObtained {
                    Label("Nexus Obtained", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Add Relationship View
struct AddRelationshipView: View {
    let conditions: [MedicalCondition]
    @Binding var relationships: [ConditionRelationship]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPrimary: MedicalCondition?
    @State private var selectedSecondary: MedicalCondition?
    @State private var relationshipType = RelationshipType.causedBy
    @State private var description = ""
    @State private var isServiceConnected = false
    @State private var nexusRequired = false
    @State private var nexusObtained = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Condition Relationship")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button("Save") {
                        saveRelationship()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(selectedPrimary == nil || selectedSecondary == nil)
                }
            }
            .padding()
            
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Relationship Details")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Primary Condition")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Primary Condition", selection: $selectedPrimary) {
                                Text("Select Primary Condition").tag(nil as MedicalCondition?)
                                ForEach(conditions, id: \.id) { condition in
                                    Text(condition.conditionName).tag(condition as MedicalCondition?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Relationship Type")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Relationship Type", selection: $relationshipType) {
                                ForEach(RelationshipType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Secondary Condition")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Picker("Secondary Condition", selection: $selectedSecondary) {
                                Text("Select Secondary Condition").tag(nil as MedicalCondition?)
                                ForEach(conditions.filter { $0.id != selectedPrimary?.id }, id: \.id) { condition in
                                    Text(condition.conditionName).tag(condition as MedicalCondition?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Describe the relationship", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Service Connected", isOn: $isServiceConnected)
                            Toggle("Nexus Required", isOn: $nexusRequired)
                            if nexusRequired {
                                Toggle("Nexus Obtained", isOn: $nexusObtained)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
    
    private func saveRelationship() {
        guard let primary = selectedPrimary, let secondary = selectedSecondary else { return }
        
        let newRelationship = ConditionRelationship(
            primaryCondition: primary,
            secondaryCondition: secondary,
            relationshipType: relationshipType,
            description: description,
            isServiceConnected: isServiceConnected,
            nexusRequired: nexusRequired,
            nexusObtained: nexusObtained
        )
        
        modelContext.insert(newRelationship)
        relationships.append(newRelationship)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving relationship: \(error)")
        }
    }
}
