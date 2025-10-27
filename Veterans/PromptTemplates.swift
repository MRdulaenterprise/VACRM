//
//  PromptTemplates.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData

/// Pre-configured prompt templates for Veterans Benefits Claims assistance
class PromptTemplates {
    
    // MARK: - Default Templates
    
    static let defaultTemplates: [PromptTemplate] = [
        PromptTemplate(
            name: "Claim Status Assistance",
            templateDescription: "Help understand VA disability claim status and next steps",
            content: """
            You are an expert VA claims assistant. Help me understand the current status and next steps for a VA disability claim.

            Claim Type: [CLAIM_TYPE]
            Claimed Condition: [CONDITION]
            Current Status: [STATUS]

            Please provide:
            1. What this status means
            2. Typical timeline for this stage
            3. Documents that may be needed
            4. Next steps the veteran should take
            5. Common issues to watch for

            Be specific about VA processes and provide actionable advice.
            """,
            category: .claimStatus,
            variables: ["CLAIM_TYPE", "CONDITION", "STATUS"],
            isDefault: true
        ),
        
        PromptTemplate(
            name: "Service Connection Nexus",
            templateDescription: "Assist in drafting a nexus letter outline connecting condition to military service",
            content: """
            You are a medical-legal expert assisting with VA disability claims. Help create a nexus letter outline connecting a medical condition to military service.

            Condition: [CONDITION]
            Service Branch: [BRANCH]
            Service Dates: [DATES]
            Relevant Service Events: [EVENTS]

            Please provide an outline including:
            1. Current diagnosis requirements
            2. In-service event or exposure documentation
            3. Medical nexus linking #1 and #2
            4. Key medical evidence needed
            5. Service record evidence needed

            Focus on the medical-legal connection and evidence requirements.
            """,
            category: .nexusLetter,
            variables: ["CONDITION", "BRANCH", "DATES", "EVENTS"],
            isDefault: true
        ),
        
        PromptTemplate(
            name: "Appeal Preparation",
            templateDescription: "Guide through the appeals process for a denied VA claim",
            content: """
            You are a VA appeals expert. Guide me through the appeals process for a denied VA disability claim.

            Original Claim: [CLAIM_TYPE]
            Denial Date: [DATE]
            Denial Reason: [REASON]

            Please provide:
            1. Available appeal options (Supplemental Claim, HLR, Board Appeal)
            2. Deadlines for each option
            3. New evidence requirements
            4. BVA hearing preparation tips
            5. Success factors and common pitfalls

            Include specific deadlines and procedural requirements.
            """,
            category: .appeals,
            variables: ["CLAIM_TYPE", "DATE", "REASON"],
            isDefault: true
        )
    ]
    
    // MARK: - Template Management
    
    /// Initialize default templates in the database
    static func initializeDefaultTemplates(in context: ModelContext) {
        for template in defaultTemplates {
            context.insert(template)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save default templates: \(error)")
        }
    }
    
    /// Process template with variable substitution
    static func processTemplate(_ template: PromptTemplate, variables: [String: String]) -> String {
        var processedContent = template.content
        
        for variable in template.variables {
            let placeholder = "[\(variable)]"
            let value = variables[variable] ?? placeholder
            processedContent = processedContent.replacingOccurrences(of: placeholder, with: value)
        }
        
        return processedContent
    }
    
    /// Get template by name
    static func getTemplate(by name: String, from context: ModelContext) -> PromptTemplate? {
        let descriptor = FetchDescriptor<PromptTemplate>(
            predicate: #Predicate { $0.name == name }
        )
        
        do {
            let templates = try context.fetch(descriptor)
            return templates.first
        } catch {
            print("Failed to fetch template: \(error)")
            return nil
        }
    }
    
    /// Get templates by category
    static func getTemplates(by category: PromptCategory, from context: ModelContext) -> [PromptTemplate] {
        let descriptor = FetchDescriptor<PromptTemplate>(
            predicate: #Predicate { $0.category == category }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch templates by category: \(error)")
            return []
        }
    }
    
    /// Get all templates
    static func getAllTemplates(from context: ModelContext) -> [PromptTemplate] {
        let descriptor = FetchDescriptor<PromptTemplate>()
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch all templates: \(error)")
            return []
        }
    }
    
    /// Create new template
    static func createTemplate(
        name: String,
        description: String,
        content: String,
        category: PromptCategory,
        variables: [String] = [],
        in context: ModelContext
    ) -> PromptTemplate {
        let template = PromptTemplate(
            name: name,
            templateDescription: description,
            content: content,
            category: category,
            variables: variables
        )
        
        context.insert(template)
        
        do {
            try context.save()
        } catch {
            print("Failed to save new template: \(error)")
        }
        
        return template
    }
    
    /// Update existing template
    static func updateTemplate(
        _ template: PromptTemplate,
        name: String? = nil,
        description: String? = nil,
        content: String? = nil,
        category: PromptCategory? = nil,
        variables: [String]? = nil,
        in context: ModelContext
    ) {
        if let name = name {
            template.name = name
        }
        if let description = description {
            template.templateDescription = description
        }
        if let content = content {
            template.content = content
        }
        if let category = category {
            template.category = category
        }
        if let variables = variables {
            template.variables = variables
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to update template: \(error)")
        }
    }
    
    /// Delete template
    static func deleteTemplate(_ template: PromptTemplate, from context: ModelContext) {
        context.delete(template)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete template: \(error)")
        }
    }
    
    /// Mark template as used
    static func markTemplateAsUsed(_ template: PromptTemplate, in context: ModelContext) {
        template.markAsUsed()
        
        do {
            try context.save()
        } catch {
            print("Failed to update template usage: \(error)")
        }
    }
    
    // MARK: - Template Validation
    
    /// Validate template content
    static func validateTemplate(_ template: PromptTemplate) -> TemplateValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Check required fields
        if template.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Template name is required")
        }
        
        if template.templateDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Template description is required")
        }
        
        if template.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Template content is required")
        }
        
        // Check for variable consistency
        let contentVariables = extractVariables(from: template.content)
        let declaredVariables = Set(template.variables)
        let contentVariableSet = Set(contentVariables)
        
        let undeclaredVariables = contentVariableSet.subtracting(declaredVariables)
        let unusedVariables = declaredVariables.subtracting(contentVariableSet)
        
        if !undeclaredVariables.isEmpty {
            warnings.append("Content contains undeclared variables: \(undeclaredVariables.joined(separator: ", "))")
        }
        
        if !unusedVariables.isEmpty {
            warnings.append("Declared variables not used in content: \(unusedVariables.joined(separator: ", "))")
        }
        
        // Check content length
        if template.content.count > 4000 {
            warnings.append("Template content is very long (\(template.content.count) characters)")
        }
        
        return TemplateValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    /// Extract variables from template content
    private static func extractVariables(from content: String) -> [String] {
        let pattern = "\\[([A-Z_]+)\\]"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range(at: 1), in: content) {
                return String(content[range])
            }
            return nil
        }
    }
    
    // MARK: - Template Categories
    
    /// Get category icon
    static func getCategoryIcon(for category: PromptCategory) -> String {
        return category.icon
    }
    
    /// Get category color
    static func getCategoryColor(for category: PromptCategory) -> String {
        switch category {
        case .claimStatus:
            return "blue"
        case .nexusLetter:
            return "green"
        case .appeals:
            return "red"
        case .general:
            return "gray"
        case .medical:
            return "purple"
        case .legal:
            return "orange"
        }
    }
    
    // MARK: - Template Statistics
    
    /// Get template usage statistics
    static func getUsageStatistics(from context: ModelContext) -> TemplateUsageStatistics {
        let templates = getAllTemplates(from: context)
        
        let totalTemplates = templates.count
        let totalUses = templates.reduce(0) { $0 + $1.useCount }
        let mostUsedTemplate = templates.max { $0.useCount < $1.useCount }
        
        let categoryStats = Dictionary(grouping: templates) { $0.category }
            .mapValues { $0.count }
        
        return TemplateUsageStatistics(
            totalTemplates: totalTemplates,
            totalUses: totalUses,
            mostUsedTemplate: mostUsedTemplate?.name,
            categoryBreakdown: categoryStats
        )
    }
}

// MARK: - Supporting Types

struct TemplateValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
}

struct TemplateUsageStatistics {
    let totalTemplates: Int
    let totalUses: Int
    let mostUsedTemplate: String?
    let categoryBreakdown: [PromptCategory: Int]
}

// MARK: - Template Extensions

extension PromptTemplate {
    /// Get display name with category
    var displayName: String {
        return "\(name) (\(category.rawValue))"
    }
    
    /// Get preview of content (first 100 characters)
    var contentPreview: String {
        let preview = content.prefix(100)
        return preview.count < content.count ? "\(preview)..." : String(preview)
    }
    
    /// Check if template has all required variables filled
    func hasAllVariablesFilled(_ variables: [String: String]) -> Bool {
        return variables.keys.allSatisfy { self.variables.contains($0) }
    }
    
    /// Get missing variables
    func getMissingVariables(from providedVariables: [String: String]) -> [String] {
        return self.variables.filter { !providedVariables.keys.contains($0) }
    }
}

// MARK: - Variable Management

class TemplateVariableManager {
    
    /// Get common variable suggestions based on category
    static func getVariableSuggestions(for category: PromptCategory) -> [String] {
        switch category {
        case .claimStatus:
            return ["CLAIM_TYPE", "CONDITION", "STATUS", "FILED_DATE", "VETERAN_ID"]
        case .nexusLetter:
            return ["CONDITION", "BRANCH", "DATES", "EVENTS", "DIAGNOSIS_DATE", "SERVICE_CONNECTION"]
        case .appeals:
            return ["CLAIM_TYPE", "DATE", "REASON", "APPEAL_TYPE", "EVIDENCE", "DEADLINE"]
        case .medical:
            return ["CONDITION", "SYMPTOMS", "TREATMENT", "MEDICATIONS", "DIAGNOSIS_DATE"]
        case .legal:
            return ["CASE_TYPE", "JURISDICTION", "STATUTE", "PRECEDENT", "ARGUMENT"]
        case .general:
            return ["TOPIC", "CONTEXT", "GOAL", "AUDIENCE", "FORMAT"]
        }
    }
    
    /// Validate variable name
    static func validateVariableName(_ name: String) -> Bool {
        // Variables should be uppercase, contain only letters and underscores
        let pattern = "^[A-Z_]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, options: [], range: range) != nil
    }
    
    /// Get variable description
    static func getVariableDescription(_ variable: String) -> String {
        switch variable {
        case "CLAIM_TYPE":
            return "Type of VA disability claim (e.g., Initial, Secondary, Increase)"
        case "CONDITION":
            return "Medical condition being claimed"
        case "STATUS":
            return "Current status of the claim"
        case "BRANCH":
            return "Military service branch"
        case "DATES":
            return "Service dates or relevant time periods"
        case "EVENTS":
            return "Relevant service events or exposures"
        case "DATE":
            return "Specific date (denial, filing, etc.)"
        case "REASON":
            return "Reason for denial or other action"
        default:
            return "Custom variable"
        }
    }
}
