//
//  MedicalConditionModels.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData

// MARK: - Medical Condition Category
@Model
final class MedicalConditionCategory {
    var id: UUID
    var name: String
    var conditionDescription: String
    var color: String // For UI display
    var isActive: Bool
    
    init(name: String, description: String, color: String = "blue", isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.conditionDescription = description
        self.color = color
        self.isActive = isActive
    }
}

// MARK: - Medical Condition
@Model
final class MedicalCondition {
    var id: UUID
    var claim: Claim?
    var conditionName: String
    var category: MedicalConditionCategory?
    var isPrimary: Bool
    var isSecondary: Bool
    var isServiceConnected: Bool
    var isBilateral: Bool
    var ratingPercentage: Int
    var effectiveDate: Date?
    var diagnosisDate: Date?
    var conditionDescription: String
    var symptoms: String
    var treatmentHistory: String
    var nexusLetterRequired: Bool
    var nexusLetterObtained: Bool
    var nexusProviderName: String
    var nexusLetterDate: Date?
    var dbqCompleted: Bool
    var cAndPExamRequired: Bool
    var cAndPExamDate: Date?
    var cAndPExamCompleted: Bool
    var cAndPFavorable: Bool
    var buddyStatementProvided: Bool
    var medicalRecordsOnFile: Bool
    var privateMedicalRecords: Bool
    var vaMedicalRecords: Bool
    var serviceTreatmentRecords: Bool
    var notes: String
    var createdDate: Date
    var modifiedDate: Date
    
    // Relationships - Note: These will be managed through ConditionRelationship model
    // to avoid circular references in SwiftData
    
    init(conditionName: String, category: MedicalConditionCategory?, isPrimary: Bool = false, isSecondary: Bool = false, isServiceConnected: Bool = false, isBilateral: Bool = false, ratingPercentage: Int = 0, effectiveDate: Date? = nil, diagnosisDate: Date? = nil, description: String = "", symptoms: String = "", treatmentHistory: String = "", nexusLetterRequired: Bool = false, nexusLetterObtained: Bool = false, nexusProviderName: String = "", nexusLetterDate: Date? = nil, dbqCompleted: Bool = false, cAndPExamRequired: Bool = false, cAndPExamDate: Date? = nil, cAndPExamCompleted: Bool = false, cAndPFavorable: Bool = false, buddyStatementProvided: Bool = false, medicalRecordsOnFile: Bool = false, privateMedicalRecords: Bool = false, vaMedicalRecords: Bool = false, serviceTreatmentRecords: Bool = false, notes: String = "") {
        self.id = UUID()
        self.conditionName = conditionName
        self.category = category
        self.isPrimary = isPrimary
        self.isSecondary = isSecondary
        self.isServiceConnected = isServiceConnected
        self.isBilateral = isBilateral
        self.ratingPercentage = ratingPercentage
        self.effectiveDate = effectiveDate
        self.diagnosisDate = diagnosisDate
        self.conditionDescription = description
        self.symptoms = symptoms
        self.treatmentHistory = treatmentHistory
        self.nexusLetterRequired = nexusLetterRequired
        self.nexusLetterObtained = nexusLetterObtained
        self.nexusProviderName = nexusProviderName
        self.nexusLetterDate = nexusLetterDate
        self.dbqCompleted = dbqCompleted
        self.cAndPExamRequired = cAndPExamRequired
        self.cAndPExamDate = cAndPExamDate
        self.cAndPExamCompleted = cAndPExamCompleted
        self.cAndPFavorable = cAndPFavorable
        self.buddyStatementProvided = buddyStatementProvided
        self.medicalRecordsOnFile = medicalRecordsOnFile
        self.privateMedicalRecords = privateMedicalRecords
        self.vaMedicalRecords = vaMedicalRecords
        self.serviceTreatmentRecords = serviceTreatmentRecords
        self.notes = notes
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}

// MARK: - Condition Relationship
@Model
final class ConditionRelationship {
    var id: UUID
    var primaryCondition: MedicalCondition?
    var secondaryCondition: MedicalCondition?
    var relationshipType: RelationshipType
    var conditionDescription: String
    var isServiceConnected: Bool
    var nexusRequired: Bool
    var nexusObtained: Bool
    var createdDate: Date
    
    init(primaryCondition: MedicalCondition?, secondaryCondition: MedicalCondition?, relationshipType: RelationshipType, description: String = "", isServiceConnected: Bool = false, nexusRequired: Bool = false, nexusObtained: Bool = false) {
        self.id = UUID()
        self.primaryCondition = primaryCondition
        self.secondaryCondition = secondaryCondition
        self.relationshipType = relationshipType
        self.conditionDescription = description
        self.isServiceConnected = isServiceConnected
        self.nexusRequired = nexusRequired
        self.nexusObtained = nexusObtained
        self.createdDate = Date()
    }
}

// MARK: - Enums
enum RelationshipType: String, CaseIterable, Codable {
    case causedBy = "Caused By"
    case aggravatedBy = "Aggravated By"
    case secondaryTo = "Secondary To"
    case relatedTo = "Related To"
    case independent = "Independent"
}

// MARK: - Extensions for UI
extension MedicalCondition {
    var displayName: String {
        return conditionName
    }
    
    var statusText: String {
        if isServiceConnected {
            return "Service Connected (\(ratingPercentage)%)"
        } else if isPrimary {
            return "Primary Condition"
        } else if isSecondary {
            return "Secondary Condition"
        } else {
            return "Other Condition"
        }
    }
    
    var statusColor: String {
        if isServiceConnected {
            return "green"
        } else if isPrimary {
            return "blue"
        } else if isSecondary {
            return "orange"
        } else {
            return "gray"
        }
    }
}

extension MedicalConditionCategory {
    var displayColor: String {
        return color
    }
}
