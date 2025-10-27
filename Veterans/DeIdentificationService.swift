//
//  DeIdentificationService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftUI

/// HIPAA-compliant de-identification service following Safe Harbor method
/// Enhanced with GPT-4 approach based on DeID-GPT research
/// Implements detection and redaction of 18 HIPAA Safe Harbor identifiers
class DeIdentificationService {
    
    // MARK: - Properties
    @Published var isDeidentifying = false
    @Published var lastError: DeIdentificationError?
    
    // OpenAI service for GPT-4 de-identification
    private let openAIService = OpenAIService()
    
    // MARK: - Deidentification Context
    
    enum DeidentificationContext {
        case userQuery          // General questions - minimal de-identification
        case veteranRecord      // Database records - full de-identification
        case documentUpload     // Uploaded docs - full de-identification
    }

    // Enhanced regex patterns based on DeID-GPT research
    private let phiPatterns: [NSRegularExpression] = [
        // Names (enhanced pattern based on DeID-GPT findings)
        try! NSRegularExpression(pattern: "\\b([A-Z][a-z]{2,}\\s[A-Z][a-z]{2,}(?:\\s[A-Z][a-z]{2,})?)\\b", options: .caseInsensitive),
        // Medical professions (from DeID-GPT research)
        try! NSRegularExpression(pattern: "\\b(Dr\\.?|Doctor|Physician|Nurse|RN|LPN|PA|NP|MD|DO|Surgeon|Specialist)\\s+[A-Z][a-z]+\\b", options: .caseInsensitive),
        // Dates (comprehensive patterns)
        try! NSRegularExpression(pattern: "\\b(0?[1-9]|1[0-2])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d{2})\\b"), // MM/DD/YYYY
        try! NSRegularExpression(pattern: "\\b((19|20)\\d{2})-(0?[1-9]|1[0-2])-(0?[1-9]|[12][0-9]|3[01])\\b"), // YYYY-MM-DD
        try! NSRegularExpression(pattern: "\\b(January|February|March|April|May|June|July|August|September|October|November|December)\\s+\\d{1,2},?\\s+\\d{4}\\b", options: .caseInsensitive),
        // Ages (from DeID-GPT research)
        try! NSRegularExpression(pattern: "\\b(age|aged)\\s+\\d{1,3}\\b", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\b\\d{1,3}\\s+(years?\\s+old|yo)\\b", options: .caseInsensitive),
        // Telephone numbers
        try! NSRegularExpression(pattern: "\\b\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\\b"),
        // Fax numbers
        try! NSRegularExpression(pattern: "\\bFax:?\\s*\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\\b", options: .caseInsensitive),
        // Email addresses
        try! NSRegularExpression(pattern: "\\b[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}\\b", options: .caseInsensitive),
        // Social Security Numbers (SSN) - XXX-XX-XXXX
        try! NSRegularExpression(pattern: "\\b\\d{3}-\\d{2}-\\d{4}\\b"),
        // Medical Record Numbers (enhanced patterns)
        try! NSRegularExpression(pattern: "\\bMRN:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\bMedical\\s+Record\\s+Number:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        // Health Plan Beneficiary Numbers
        try! NSRegularExpression(pattern: "\\bHPBN:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        // Account Numbers
        try! NSRegularExpression(pattern: "\\bAccount:?\\s*[0-9]{8,}\\b", options: .caseInsensitive),
        // Certificate/License Numbers
        try! NSRegularExpression(pattern: "\\bLicense:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        // Vehicle Identifiers
        try! NSRegularExpression(pattern: "\\bVIN:?\\s*[A-HJ-NPR-Z0-9]{17}\\b", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\bPlate:?\\s*[A-Z0-9]{3,7}\\b", options: .caseInsensitive),
        // Device Identifiers
        try! NSRegularExpression(pattern: "\\bDeviceID:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        // URLs
        try! NSRegularExpression(pattern: "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)", options: .caseInsensitive),
        // IP Address
        try! NSRegularExpression(pattern: "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b"),
        // Biometric Identifiers
        try! NSRegularExpression(pattern: "\\b(fingerprint|retina scan|iris scan|DNA|genetic)\\b", options: .caseInsensitive),
        // Full Face Photographic Images
        try! NSRegularExpression(pattern: "\\b(full face photo|photographic image of \\w+|patient photo)\\b", options: .caseInsensitive),
        // Veteran-specific identifiers
        try! NSRegularExpression(pattern: "\\bVeteranID:?\\s*[A-Z0-9]{5,}\\b", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\bVA\\s+File\\s+Number:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        // Addresses (enhanced patterns)
        try! NSRegularExpression(pattern: "\\b\\d{1,5}\\s[A-Z][a-z]+\\s(Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Place|Pl)\\b", options: .caseInsensitive),
        try! NSRegularExpression(pattern: "\\b[A-Z][a-z]+,\\s[A-Z]{2}\\s\\d{5}\\b"), // City, ST ZIP
        // Hospital/Medical facility names (common patterns)
        try! NSRegularExpression(pattern: "\\b[A-Z][a-z]+\\s+(Hospital|Medical Center|Clinic|Health Center)\\b", options: .caseInsensitive),
    ]
    
    // MARK: - Smart Detection Methods
    
    /// Determines if text should be de-identified based on context and content
    /// - Parameters:
    ///   - text: The input text to analyze
    ///   - context: The context in which the text is being used
    /// - Returns: True if de-identification is needed, false otherwise
    func shouldDeidentify(_ text: String, context: DeidentificationContext) async -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        switch context {
        case .userQuery:
            // For user queries, only de-identify if obvious PHI is present
            return containsObviousPHI(text)
            
        case .veteranRecord, .documentUpload:
            // For records and documents, always de-identify
            return true
        }
    }
    
    /// Checks for obvious PHI patterns that should always be redacted
    /// - Parameter text: The text to check
    /// - Returns: True if obvious PHI is detected
    private func containsObviousPHI(_ text: String) -> Bool {
        let obviousPHIPatterns = [
            // Social Security Numbers
            try! NSRegularExpression(pattern: "\\b\\d{3}-\\d{2}-\\d{4}\\b"),
            // Full addresses with house numbers
            try! NSRegularExpression(pattern: "\\b\\d{1,5}\\s[A-Z][a-z]+\\s(Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Lane|Ln|Drive|Dr|Court|Ct|Place|Pl)\\b", options: .caseInsensitive),
            // Medical record numbers with prefixes
            try! NSRegularExpression(pattern: "\\b(MRN|Medical Record Number|Patient ID):?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
            // Specific phone numbers
            try! NSRegularExpression(pattern: "\\b\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\\b"),
            // Email addresses
            try! NSRegularExpression(pattern: "\\b[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}\\b", options: .caseInsensitive),
            // VA File Numbers
            try! NSRegularExpression(pattern: "\\bVA\\s+File\\s+Number:?\\s*[A-Z0-9]+\\b", options: .caseInsensitive),
        ]
        
        for pattern in obviousPHIPatterns {
            let matches = pattern.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            if !matches.isEmpty {
                return true
            }
        }
        
        return false
    }

    /// De-identifies text using GPT-4 approach (DeID-GPT method)
    /// - Parameters:
    ///   - text: The input string potentially containing PHI/PII
    ///   - context: The context in which de-identification is being performed
    /// - Returns: A tuple containing the de-identified string and a log of redactions
    func deidentifyWithGPT4(text: String, context: DeidentificationContext = .userQuery) async -> (deidentifiedText: String, redactionLog: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (text, "No PHI/PII detected or redacted.")
        }
        
        // Create context-appropriate prompt for GPT-4 de-identification
        let prompt = createDeidentificationPrompt(for: text, context: context)
        
        do {
            let messages = [
                OpenAIService.OpenAIMessage(role: "system", content: "You are a HIPAA-compliant medical text de-identification expert."),
                OpenAIService.OpenAIMessage(role: "user", content: prompt)
            ]
            
            let deidentifiedText = try await openAIService.sendChatCompletion(
                messages: messages,
                model: "gpt-4",
                temperature: 0.1, // Low temperature for consistent results
                maxTokens: 2000
            )
            
            // Generate redaction log by comparing original and de-identified text
            let redactionLog = generateRedactionLog(original: text, deidentified: deidentifiedText)
            
            return (deidentifiedText, redactionLog)
            
        } catch {
            // Fallback to rule-based de-identification if GPT-4 fails
            print("GPT-4 de-identification failed, falling back to rule-based method: \(error)")
            return deidentify(text: text)
        }
    }
    
    /// Creates context-appropriate de-identification prompt
    private func createDeidentificationPrompt(for text: String, context: DeidentificationContext) -> String {
        switch context {
        case .userQuery:
            return """
            You are assisting with HIPAA compliance. Review this text and ONLY redact ACTUAL protected health information:

            DO REDACT:
            - Social Security Numbers (XXX-XX-XXXX)
            - Full street addresses with house numbers
            - Medical record numbers with prefixes (MRN:, Patient ID:)
            - Specific phone numbers and emails
            - Specific dates tied to medical events

            DO NOT REDACT:
            - Hypothetical case descriptions ("my client", "a veteran")
            - General age references in questions ("72 years old")
            - Common first names without identifiers
            - Medical conditions (PTSD, diabetes, etc.)
            - General questions about processes

            Text to review: \(text)

            Return the text with ONLY obvious PHI redacted as [REDACTED_PHI_X]. If no PHI found, return original text.
            """
            
        case .veteranRecord, .documentUpload:
            return """
            You are a HIPAA-compliant medical text de-identification expert. Your task is to identify and redact all Protected Health Information (PHI) from the following medical text while preserving the original structure and meaning.

            PHI categories to identify and redact:
            1. Names (patients, doctors, family members)
            2. Professions (medical staff titles with names)
            3. Locations (hospitals, cities, addresses)
            4. Ages (patient ages)
            5. Dates (visit dates, birth dates, admission/discharge dates)
            6. Contacts (phone numbers, emails)
            7. IDs (patient IDs, medical record numbers, SSNs)
            8. Biometric identifiers
            9. Any other unique identifying information

            Instructions:
            - Replace each PHI element with [REDACTED_PHI_X] where X is a sequential number
            - Preserve the original text structure and medical meaning
            - Only redact clear PHI, not general medical terms
            - Maintain proper grammar and sentence flow
            - Return only the de-identified text

            Medical text to de-identify:
            \(text)
            """
        }
    }

    /// Traditional rule-based de-identification (fallback method)
    /// - Parameter text: The input string potentially containing PHI/PII.
    /// - Returns: A tuple containing the de-identified string and a log of redactions.
    func deidentify(text: String) -> (deidentifiedText: String, redactionLog: String) {
        // Common words that should not be flagged as PHI
        let commonWords = ["test", "what", "the", "and", "for", "are", "but", "not", "you", "all", "can", "had", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "its", "may", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "man", "men", "put", "say", "she", "too", "use", "va", "benefits", "news", "latest", "disability", "claim", "appeal", "veteran", "service", "military", "army", "navy", "air", "force", "marine", "coast", "guard"]
        
        let lowercaseText = text.lowercased()
        
        // Check if text contains only common words
        let words = lowercaseText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let hasOnlyCommonWords = words.allSatisfy { word in
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            return commonWords.contains(cleanWord)
        }
        
        if hasOnlyCommonWords {
            return (text, "No PHI/PII detected or redacted.")
        }
        
        var deidentifiedText = text
        var logEntries: [String] = []
        var redactedCount = 0

        for pattern in phiPatterns {
            let matches = pattern.matches(in: deidentifiedText, options: [], range: NSRange(location: 0, length: deidentifiedText.utf16.count))

            // Process matches in reverse order to avoid issues with range changes
            for match in matches.reversed() {
                if let range = Range(match.range, in: deidentifiedText) {
                    let matchedString = String(deidentifiedText[range])
                    let redactionTag = "[REDACTED_PHI_\(redactedCount)]"
                    deidentifiedText.replaceSubrange(range, with: redactionTag)
                    logEntries.append("Redacted '\(matchedString)' with '\(redactionTag)'")
                    redactedCount += 1
                }
            }
        }
        
        let finalLog = logEntries.isEmpty ? "No PHI/PII detected or redacted." : logEntries.joined(separator: "\n")
        return (deidentifiedText, finalLog)
    }
    
    /// Checks if the given text contains PHI/PII patterns.
    /// - Parameter text: The input string to check for PHI/PII.
    /// - Returns: True if PHI/PII is detected, false otherwise.
    func containsPHI(_ text: String) -> Bool {
        // Common words that should not be flagged as PHI
        let commonWords = ["test", "what", "the", "and", "for", "are", "but", "not", "you", "all", "can", "had", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "its", "may", "new", "now", "old", "see", "two", "way", "who", "boy", "did", "man", "men", "put", "say", "she", "too", "use", "va", "benefits", "news", "latest", "disability", "claim", "appeal", "veteran", "service", "military", "army", "navy", "air", "force", "marine", "coast", "guard"]
        
        let lowercaseText = text.lowercased()
        
        // Check if text contains only common words
        let words = lowercaseText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let hasOnlyCommonWords = words.allSatisfy { word in
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            return commonWords.contains(cleanWord)
        }
        
        if hasOnlyCommonWords {
            return false
        }
        
        for pattern in phiPatterns {
            let matches = pattern.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            if !matches.isEmpty {
                return true
            }
        }
        return false
    }
    
    /// Generates a redaction log by comparing original and de-identified text
    private func generateRedactionLog(original: String, deidentified: String) -> String {
        let originalWords = original.components(separatedBy: .whitespacesAndNewlines)
        let deidentifiedWords = deidentified.components(separatedBy: .whitespacesAndNewlines)
        
        var redactionCount = 0
        var logEntries: [String] = []
        
        for (index, word) in originalWords.enumerated() {
            if index < deidentifiedWords.count {
                let deidentifiedWord = deidentifiedWords[index]
                if deidentifiedWord.contains("[REDACTED_PHI_") {
                    logEntries.append("Redacted '\(word)' with '\(deidentifiedWord)'")
                    redactionCount += 1
                }
            }
        }
        
        return logEntries.isEmpty ? "No PHI/PII detected or redacted." : logEntries.joined(separator: "\n")
    }
}

enum DeIdentificationError: Error, LocalizedError {
    case redactionFailed(String)
    case invalidRegex(String)
    case gpt4DeidentificationFailed(String)

    var errorDescription: String? {
        switch self {
        case .redactionFailed(let reason):
            return "De-identification redaction failed: \(reason)"
        case .invalidRegex(let pattern):
            return "Invalid regular expression pattern: \(pattern)"
        case .gpt4DeidentificationFailed(let reason):
            return "GPT-4 de-identification failed: \(reason)"
        }
    }
}