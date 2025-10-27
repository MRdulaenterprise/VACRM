//
//  MedicalConditionManager.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct MedicalConditionManager: View {
    @Environment(\.modelContext) private var modelContext
    @State private var conditions: [MedicalCondition] = []
    @State private var categories: [MedicalConditionCategory] = []
    @State private var showingAddCondition = false
    @State private var selectedCondition: MedicalCondition?
    @State private var showingConditionDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Medical Conditions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Add Condition") {
                    showingAddCondition = true
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding()
            
            // Conditions List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(conditions) { condition in
                        ConditionCard(
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
            AddConditionView(conditions: $conditions)
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
        .onAppear {
            loadCategories()
        }
    }
    
    private func loadCategories() {
        // Load default categories if none exist
        if categories.isEmpty {
            let defaultCategories = [
                MedicalConditionCategory(name: "Mental Health", description: "PTSD, Depression, Anxiety, etc.", color: "blue"),
                MedicalConditionCategory(name: "Physical Injury", description: "Back, Knee, Shoulder injuries", color: "red"),
                MedicalConditionCategory(name: "Toxic Exposure", description: "Agent Orange, Burn Pits, etc.", color: "orange"),
                MedicalConditionCategory(name: "Hearing Loss", description: "Tinnitus, Hearing impairment", color: "purple"),
                MedicalConditionCategory(name: "Respiratory", description: "Asthma, COPD, etc.", color: "green"),
                MedicalConditionCategory(name: "Cardiovascular", description: "Heart conditions", color: "pink"),
                MedicalConditionCategory(name: "Neurological", description: "TBI, Migraines, etc.", color: "indigo"),
                MedicalConditionCategory(name: "Other", description: "Other conditions", color: "gray")
            ]
            
            for category in defaultCategories {
                modelContext.insert(category)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving categories: \(error)")
            }
        }
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

// MARK: - Condition Card
struct ConditionCard: View {
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
                    Text(condition.statusText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(condition.statusColor).opacity(0.2))
                        .foregroundColor(Color(condition.statusColor))
                        .cornerRadius(8)
                    
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
            
            HStack {
                if condition.isBilateral {
                    Label("Bilateral", systemImage: "arrow.left.arrow.right")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if condition.nexusLetterObtained {
                    Label("Nexus", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if condition.cAndPExamCompleted {
                    Label("C&P", systemImage: "stethoscope")
                        .font(.caption)
                        .foregroundColor(.blue)
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

// MARK: - Add Condition View
struct AddConditionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var conditions: [MedicalCondition]
    
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
                Text("Add Medical Condition")
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
                    
                    // Medical Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Medical Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Symptoms")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Describe symptoms", text: $symptoms, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Treatment History")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Describe treatment history", text: $treatmentHistory, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Effective Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker("", selection: $effectiveDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Diagnosis Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker("", selection: $diagnosisDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medical Records")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Toggle("Medical Records On File", isOn: $medicalRecordsOnFile)
                            Toggle("Private Medical Records", isOn: $privateMedicalRecords)
                            Toggle("VA Medical Records", isOn: $vaMedicalRecords)
                            Toggle("Service Treatment Records", isOn: $serviceTreatmentRecords)
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

// MARK: - Condition Detail View
struct ConditionDetailView: View {
    let condition: MedicalCondition
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Condition Details")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Basic Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(label: "Condition Name", value: condition.conditionName)
                        InfoRow(label: "Category", value: condition.category?.name ?? "No Category")
                        InfoRow(label: "Status", value: condition.statusText)
                        InfoRow(label: "Rating", value: "\(condition.ratingPercentage)%")
                        InfoRow(label: "Description", value: condition.conditionDescription)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Medical Information
                    if !condition.symptoms.isEmpty || !condition.treatmentHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Medical Information")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if !condition.symptoms.isEmpty {
                                InfoRow(label: "Symptoms", value: condition.symptoms)
                            }
                            
                            if !condition.treatmentHistory.isEmpty {
                                InfoRow(label: "Treatment History", value: condition.treatmentHistory)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    // Evidence Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Evidence Status")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        InfoRow(label: "Nexus Letter", value: condition.nexusLetterObtained ? "Obtained" : "Not Obtained")
                        InfoRow(label: "DBQ Completed", value: condition.dbqCompleted ? "Yes" : "No")
                        InfoRow(label: "C&P Exam", value: condition.cAndPExamCompleted ? "Completed" : "Not Completed")
                        InfoRow(label: "Buddy Statement", value: condition.buddyStatementProvided ? "Provided" : "Not Provided")
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Notes
                    if !condition.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(condition.notes)
                                .font(.body)
                                .foregroundColor(.primary)
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
}

// MARK: - Info Row Helper
// InfoRow is defined in VeteranDetailView.swift
