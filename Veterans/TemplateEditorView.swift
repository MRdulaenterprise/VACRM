//
//  TemplateEditorView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Template editor for creating and editing prompt templates
struct TemplateEditorView: View {
    
    // MARK: - Properties
    let template: PromptTemplate?
    let onSave: (PromptTemplate) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var content = ""
    @State private var category = PromptCategory.general
    @State private var variables: [String] = []
    @State private var newVariable = ""
    @State private var showingVariableInput = false
    
    @State private var validationResult: TemplateValidationResult?
    @State private var showingValidationAlert = false
    
    // MARK: - Computed Properties
    
    private var isEditing: Bool {
        return template != nil
    }
    
    private var canSave: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Template" : "New Template")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .font(.system(size: 12))
                    
                    Button("Save") {
                        saveTemplate()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .font(.system(size: 12))
                    .disabled(!canSave)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            
            Divider()
            
            // Content with scrolling
            ScrollView {
                VStack(spacing: 20) {
                    // Basic Information Section
                    basicInformationSection
                    
                    // Content Section
                    contentSection
                    
                    // Variables Section
                    variablesSection
                    
                    // Preview Section
                    previewSection
                    
                    // Validation Section
                    if let validation = validationResult {
                        validationSection(validation)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800)
        .frame(minHeight: 500, idealHeight: 600, maxHeight: 700)
        .onAppear {
            loadTemplate()
        }
        .alert("Validation Issues", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            if let validation = validationResult {
                let message = validation.errors.joined(separator: "\n") + 
                             (validation.warnings.isEmpty ? "" : "\n\nWarnings:\n" + validation.warnings.joined(separator: "\n"))
                Text(message)
            }
        }
    }
    
    // MARK: - Basic Information Section
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Template name...", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Template description...", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Picker("Category", selection: $category) {
                        ForEach(PromptCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 14))
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Template Content")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Validate") {
                    validateTemplate()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $content)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(minHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.blue.opacity(0.2), lineWidth: 1)
                    )
                
                Text("Use [VARIABLE_NAME] to create variables that can be filled in when using the template.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Variables Section
    
    private var variablesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Template Variables")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Add Variable") {
                    showingVariableInput = true
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 12))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if variables.isEmpty {
                    Text("No variables defined")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(variables, id: \.self) { variable in
                            VariableEditorChipView(
                                variable: variable,
                                onDelete: { removeVariable(variable) }
                            )
                        }
                    }
                }
                
                Text("Variables are automatically detected from the content, but you can also add them manually.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingVariableInput) {
            variableInputSheet
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Template Preview")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(content.isEmpty ? "Enter template content to see preview..." : content)
                    .font(.system(size: 13))
                    .foregroundColor(content.isEmpty ? .secondary : .primary)
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .lineLimit(nil)
                
                if !variables.isEmpty {
                    Text("Variables: \(variables.joined(separator: ", "))")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Validation Section
    
    private func validationSection(_ validation: TemplateValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: validation.isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(validation.isValid ? .green : .orange)
                
                Text(validation.isValid ? "Template is valid" : "Template has issues")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(validation.isValid ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if !validation.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Errors:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                        
                        ForEach(validation.errors, id: \.self) { error in
                            Text("• \(error)")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                if !validation.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Warnings:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.orange)
                        
                        ForEach(validation.warnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Variable Input Sheet
    
    private var variableInputSheet: some View {
        VStack(spacing: 20) {
            Text("Add Variable")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Variable Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("VARIABLE_NAME", text: $newVariable)
                    .textFieldStyle(.roundedBorder)
                
                Text("Variable names should be uppercase and contain only letters and underscores.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    showingVariableInput = false
                    newVariable = ""
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Add") {
                    addVariable()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newVariable.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    // MARK: - Helper Methods
    
    private func loadTemplate() {
        if let template = template {
            name = template.name
            description = template.templateDescription
            content = template.content
            category = template.category
            variables = template.variables
        }
    }
    
    private func saveTemplate() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let templateToSave: PromptTemplate
        
        if let existingTemplate = template {
            // Update existing template
            existingTemplate.name = trimmedName
            existingTemplate.templateDescription = trimmedDescription
            existingTemplate.content = trimmedContent
            existingTemplate.category = category
            existingTemplate.variables = variables
            templateToSave = existingTemplate
        } else {
            // Create new template
            templateToSave = PromptTemplate(
                name: trimmedName,
                templateDescription: trimmedDescription,
                content: trimmedContent,
                category: category,
                variables: variables
            )
        }
        
        onSave(templateToSave)
        dismiss()
    }
    
    private func validateTemplate() {
        let templateToValidate = PromptTemplate(
            name: name,
            templateDescription: description,
            content: content,
            category: category,
            variables: variables
        )
        
        validationResult = PromptTemplates.validateTemplate(templateToValidate)
        
        if let validation = validationResult, !validation.errors.isEmpty {
            showingValidationAlert = true
        }
    }
    
    private func addVariable() {
        let trimmedVariable = newVariable.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard !trimmedVariable.isEmpty else { return }
        guard TemplateVariableManager.validateVariableName(trimmedVariable) else { return }
        guard !variables.contains(trimmedVariable) else { return }
        
        variables.append(trimmedVariable)
        newVariable = ""
        showingVariableInput = false
    }
    
    private func removeVariable(_ variable: String) {
        variables.removeAll { $0 == variable }
    }
}

// MARK: - Variable Editor Chip View

struct VariableEditorChipView: View {
    let variable: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text("[\(variable)]")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
            
            Text(TemplateVariableManager.getVariableDescription(variable))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Preview

#Preview {
    TemplateEditorView(
        template: nil,
        onSave: { _ in }
    )
}
