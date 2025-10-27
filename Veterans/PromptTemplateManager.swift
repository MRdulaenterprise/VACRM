//
//  PromptTemplateManager.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Template management interface for creating and editing prompt templates
struct PromptTemplateManager: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var templates: [PromptTemplate]
    
    @State private var selectedTemplate: PromptTemplate?
    @State private var showingCreateTemplate = false
    @State private var showingEditTemplate = false
    @State private var searchText = ""
    @State private var selectedCategory: PromptCategory?
    
    // MARK: - Computed Properties
    
    private var filteredTemplates: [PromptTemplate] {
        var filtered = templates
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.templateDescription.localizedCaseInsensitiveContains(searchText) ||
                template.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    private var groupedTemplates: [(PromptCategory, [PromptTemplate])] {
        let grouped = Dictionary(grouping: filteredTemplates) { $0.category }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Manage Prompt Templates")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { showingCreateTemplate = true }) {
                        Image(systemName: "plus")
                    }
                    .font(.system(size: 12))
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    .font(.system(size: 12, weight: .bold))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            
            Divider()
            
            // Content
            HStack(spacing: 0) {
                // Left Panel - Template List
                templateListView
                    .frame(width: 300)
                
                Divider()
                
                // Right Panel - Template Details
                templateDetailView
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showingCreateTemplate) {
            TemplateEditorView(
                template: nil,
                onSave: { template in
                    modelContext.insert(template)
                    try? modelContext.save()
                }
            )
        }
        .sheet(isPresented: $showingEditTemplate) {
            if let template = selectedTemplate {
                TemplateEditorView(
                    template: template,
                    onSave: { updatedTemplate in
                        try? modelContext.save()
                    }
                )
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Manage Prompt Templates")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(templates.count) templates")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    
                    TextField("Search templates...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                
                // Category Filter
                Picker("Category", selection: $selectedCategory) {
                    Text("All Categories").tag(nil as PromptCategory?)
                    ForEach(PromptCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category as PromptCategory?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 150)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Template List View
    
    private var templateListView: some View {
        VStack(spacing: 0) {
            // List Header
            HStack {
                Text("Templates")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            // Templates List
            if filteredTemplates.isEmpty {
                emptyTemplatesView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTemplates, id: \.0) { category, categoryTemplates in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                ForEach(categoryTemplates, id: \.id) { template in
                                    TemplateListRowView(
                                        template: template,
                                        isSelected: selectedTemplate?.id == template.id,
                                        onSelect: { selectedTemplate = template },
                                        onEdit: { 
                                            selectedTemplate = template
                                            showingEditTemplate = true
                                        },
                                        onDelete: { deleteTemplate(template) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Template Detail View
    
    private var templateDetailView: some View {
        VStack(spacing: 0) {
            if let template = selectedTemplate {
                TemplateDetailView(template: template)
            } else {
                emptyDetailView
            }
        }
    }
    
    // MARK: - Empty States
    
    private var emptyTemplatesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Templates")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Create your first prompt template to get started")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Template") {
                showingCreateTemplate = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyDetailView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Select a Template")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Choose a template from the list to view its details and edit it")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func deleteTemplate(_ template: PromptTemplate) {
        modelContext.delete(template)
        
        do {
            try modelContext.save()
            if selectedTemplate?.id == template.id {
                selectedTemplate = nil
            }
        } catch {
            print("Failed to delete template: \(error)")
        }
    }
}

// MARK: - Template List Row View

struct TemplateListRowView: View {
    let template: PromptTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.category.icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(template.templateDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(template.category.rawValue)
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                    
                    if template.isDefault {
                        Text("Default")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("\(template.useCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("uses")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button("Edit") {
                onEdit()
            }
            
            if !template.isDefault {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
        }
    }
}

// MARK: - Template Detail View

struct TemplateDetailView: View {
    let template: PromptTemplate
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: template.category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(template.category.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    
                    Text(template.templateDescription)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                
                Divider()
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Text("Template Content")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(template.content)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .textSelection(.enabled)
                }
                
                // Variables
                if !template.variables.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Variables")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(template.variables, id: \.self) { variable in
                                VariableChipView(variable: variable)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Statistics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistics")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        StatisticItem(
                            title: "Uses",
                            value: "\(template.useCount)",
                            icon: "arrow.clockwise"
                        )
                        
                        StatisticItem(
                            title: "Created",
                            value: formatDate(template.createdAt),
                            icon: "calendar"
                        )
                        
                        if let lastUsed = template.lastUsed {
                            StatisticItem(
                                title: "Last Used",
                                value: formatDate(lastUsed),
                                icon: "clock"
                            )
                        }
                    }
                }
                
                Divider()
                
                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preview")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("This template would generate a prompt like:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(template.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        .lineLimit(nil)
                }
            }
            .padding(20)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct VariableChipView: View {
    let variable: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text("[\(variable)]")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
            
            Text(TemplateVariableManager.getVariableDescription(variable))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    PromptTemplateManager()
        .modelContainer(for: [PromptTemplate.self], inMemory: true)
}
