//
//  VAGovModels.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation

// MARK: - Helper Types for String-based Responses

/// Wrapper to make String Identifiable for use in SwiftUI lists
struct IdentifiableString: Codable, Identifiable {
    let id: String
    let value: String
    
    init(_ value: String) {
        self.id = value
        self.value = value
    }
}

// MARK: - VA Forms API Models

struct VAFormsResponse: Codable {
    let data: [VAForm]
}

struct VAFormResponse: Codable {
    let data: VAForm
}

struct VAForm: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: FormAttributes
    
    struct FormAttributes: Codable {
        // Use CodingKeys to map snake_case API fields to camelCase Swift properties
        let formName: String
        let title: String
        let url: String
        let firstIssuedOn: String?
        let lastRevisionOn: String?
        let pages: Int?
        let sha256: String?  // Can be null in API response
        let validPdf: Bool
        let deletedAt: String?
        let language: String?
        // benefit_categories can be an array of strings or objects, so we'll decode flexibly
        let benefitCategories: [String]?
        let vaFormAdministration: String?
        let formUsage: String?
        let formDetails: String?
        let formToolIntro: String?
        let formToolUrl: String?
        let formType: String?
        let formTitles: [String]?
        let relatedForms: [String]?
        let relatedOrReplacedForms: [String]?
        
        enum CodingKeys: String, CodingKey {
            case formName = "form_name"
            case title
            case url
            case firstIssuedOn = "first_issued_on"
            case lastRevisionOn = "last_revision_on"
            case pages
            case sha256
            case validPdf = "valid_pdf"
            case deletedAt = "deleted_at"
            case language
            case benefitCategories = "benefit_categories"
            case vaFormAdministration = "va_form_administration"
            case formUsage = "form_usage"
            case formDetails = "form_details"
            case formToolIntro = "form_tool_intro"
            case formToolUrl = "form_tool_url"
            case formType = "form_type"
            case formTitles = "form_titles"
            case relatedForms = "related_forms"
            case relatedOrReplacedForms = "related_or_replaced_forms"
        }
        
        // Custom decoder to handle benefit_categories which might be strings or objects
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            formName = try container.decode(String.self, forKey: .formName)
            title = try container.decode(String.self, forKey: .title)
            url = try container.decode(String.self, forKey: .url)
            firstIssuedOn = try container.decodeIfPresent(String.self, forKey: .firstIssuedOn)
            lastRevisionOn = try container.decodeIfPresent(String.self, forKey: .lastRevisionOn)
            pages = try container.decodeIfPresent(Int.self, forKey: .pages)
            sha256 = try container.decodeIfPresent(String.self, forKey: .sha256)  // Can be null
            validPdf = try container.decode(Bool.self, forKey: .validPdf)
            deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
            language = try container.decodeIfPresent(String.self, forKey: .language)
            vaFormAdministration = try container.decodeIfPresent(String.self, forKey: .vaFormAdministration)
            formUsage = try container.decodeIfPresent(String.self, forKey: .formUsage)
            formDetails = try container.decodeIfPresent(String.self, forKey: .formDetails)
            formToolIntro = try container.decodeIfPresent(String.self, forKey: .formToolIntro)
            formToolUrl = try container.decodeIfPresent(String.self, forKey: .formToolUrl)
            formType = try container.decodeIfPresent(String.self, forKey: .formType)
            formTitles = try container.decodeIfPresent([String].self, forKey: .formTitles)
            relatedForms = try container.decodeIfPresent([String].self, forKey: .relatedForms)
            relatedOrReplacedForms = try container.decodeIfPresent([String].self, forKey: .relatedOrReplacedForms)
            
            // Handle benefit_categories which might be array of strings, objects, or mixed types
            // Use a flexible decoder that handles any type in the array
            if container.contains(.benefitCategories) {
                var categories: [String] = []
                
                // Try to decode as array of strings first (most common case)
                if let stringArray = try? container.decode([String].self, forKey: .benefitCategories) {
                    categories = stringArray
                }
                // If that fails, decode as array of flexible types
                else if let unkeyedContainer = try? container.nestedUnkeyedContainer(forKey: .benefitCategories) {
                    var tempContainer = unkeyedContainer
                    
                    while !tempContainer.isAtEnd {
                        // Try String first
                        if let stringValue = try? tempContainer.decode(String.self) {
                            categories.append(stringValue)
                            continue
                        }
                        
                        // Try object with name/description (API structure)
                        if let categoryObject = try? tempContainer.decode(BenefitCategory.self) {
                            // Prefer name field (most common in API)
                            if let name = categoryObject.name {
                                categories.append(name)
                            } else if let description = categoryObject.description {
                                // Fallback to description if name is missing
                                categories.append(description)
                            } else if let title = categoryObject.title {
                                categories.append(title)
                            } else if let value = categoryObject.value {
                                categories.append(value)
                            }
                            continue
                        }
                        
                        // Try number
                        if let numberValue = try? tempContainer.decode(Double.self) {
                            categories.append(String(numberValue))
                            continue
                        }
                        
                        // Try Int
                        if let intValue = try? tempContainer.decode(Int.self) {
                            categories.append(String(intValue))
                            continue
                        }
                        
                        // If we can't decode it, skip it by decoding as AnyCodable (which will consume the value)
                        _ = try? tempContainer.decode(AnyCodable.self)
                    }
                }
                
                benefitCategories = categories.isEmpty ? nil : categories
            } else {
                benefitCategories = nil
            }
        }
        
        // Helper struct for benefit category objects
        // The API returns objects with "name" and "description" fields
        private struct BenefitCategory: Codable {
            let name: String?
            let description: String?
            // Fallback fields in case API structure varies
            let title: String?
            let value: String?
        }
        
        // Helper to decode any type (for skipping unknown types)
        private struct AnyCodable: Codable {}
    }
}

// MARK: - VA Facilities API Models

struct VAFacilitiesResponse: Codable {
    let data: [VAFacility]
    let meta: FacilitiesMeta?
    
    struct FacilitiesMeta: Codable {
        let pagination: Pagination?
        
        struct Pagination: Codable {
            let currentPage: Int?
            let perPage: Int?
            let totalPages: Int?
            let totalEntries: Int?
        }
    }
}

struct VAFacility: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: FacilityAttributes
    
    struct FacilityAttributes: Codable {
        let name: String
        let facilityType: String
        let classification: String?
        let latitude: Double
        let longitude: Double
        let address: Address
        let phone: Phone
        let hours: [String: String]?
        let services: [String]?
        let website: String?
        let operatingStatus: OperatingStatus?
        
        struct Address: Codable {
            let mailing: MailingAddress?
            let physical: PhysicalAddress?
            
            struct MailingAddress: Codable {
                let address1: String?
                let address2: String?
                let address3: String?
                let city: String?
                let state: String?
                let zip: String?
            }
            
            struct PhysicalAddress: Codable {
                let address1: String?
                let address2: String?
                let address3: String?
                let city: String?
                let state: String?
                let zip: String?
            }
        }
        
        struct Phone: Codable {
            let fax: String?
            let main: String?
            let pharmacy: String?
            let afterHours: String?
            let patientAdvocate: String?
            let mentalHealthClinic: String?
            let enrollmentCoordinator: String?
        }
        
        struct OperatingStatus: Codable {
            let code: String?
            let additionalInfo: String?
        }
    }
}

// MARK: - Benefits Reference Data API Models

// Benefits Reference Data API returns items in different formats:
// - Some endpoints return simple arrays of strings (states, countries)
// - Some return arrays of objects with different structures

// Common response wrapper
struct BenefitsReferenceDataResponse<T: Codable>: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [T]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
}

// States: Returns array of state code strings ["AK", "AL", ...]
struct StatesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [String]  // Array of state codes
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var states: [String] {
        return items
    }
}

// Countries: Returns array of country name strings ["Afghanistan", "Albania", ...]
struct CountriesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [String]  // Array of country names
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var countries: [String] {
        return items
    }
}

// Disabilities: Returns array of objects with id, name, endDateTime
struct DisabilitiesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [Disability]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var disabilities: [Disability] {
        return items
    }
}

struct Disability: Codable, Identifiable {
    let id: Int  // API returns integer IDs
    let name: String
    let endDateTime: String?  // ISO 8601 date string or null
}

// Service Branches: Returns array of objects with code, description
struct ServiceBranchesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [ServiceBranch]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var serviceBranches: [ServiceBranch] {
        return items
    }
}

struct ServiceBranch: Codable, Identifiable {
    let code: String
    let description: String
    
    // Make Identifiable work with code as id
    var id: String {
        return code
    }
}

// Contention Types: Returns array of objects with code, description
struct ContentionTypesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [ContentionType]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var contentionTypes: [ContentionType] {
        return items
    }
}

struct ContentionType: Codable, Identifiable {
    let code: String
    let description: String
    
    // Make Identifiable work with code as id
    var id: String {
        return code
    }
}

// Treatment Centers: Need to check actual format
struct TreatmentCentersResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [TreatmentCenter]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var treatmentCenters: [TreatmentCenter] {
        return items
    }
}

struct TreatmentCenter: Codable, Identifiable {
    // Format to be determined from API response
    let code: String?
    let name: String?
    let description: String?
    let city: String?
    let state: String?
    let classification: String?
    
    // Make Identifiable work
    var id: String {
        return code ?? name ?? UUID().uuidString
    }
}

// Military Pay Types: Need to check actual format
struct MilitaryPayTypesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [MilitaryPayType]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var militaryPayTypes: [MilitaryPayType] {
        return items
    }
}

struct MilitaryPayType: Codable, Identifiable {
    // Format to be determined from API response
    let code: String?
    let description: String?
    let name: String?
    
    // Make Identifiable work
    var id: String {
        return code ?? name ?? UUID().uuidString
    }
}

// Special Circumstances: Need to check actual format
struct SpecialCircumstancesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [SpecialCircumstance]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var specialCircumstances: [SpecialCircumstance] {
        return items
    }
}

struct SpecialCircumstance: Codable, Identifiable {
    // Format to be determined from API response
    let code: String?
    let description: String?
    let name: String?
    
    // Make Identifiable work
    var id: String {
        return code ?? name ?? UUID().uuidString
    }
}

// Intake Sites: Need to check actual format
struct IntakeSitesResponse: Codable {
    let totalItems: Int
    let totalPages: Int
    let links: [Link]?
    let items: [IntakeSite]
    
    struct Link: Codable {
        let href: String
        let rel: String
    }
    
    // Computed property for compatibility
    var intakeSites: [IntakeSite] {
        return items
    }
}

struct IntakeSite: Codable, Identifiable {
    // Format to be determined from API response
    let code: String?
    let name: String?
    let description: String?
    let city: String?
    let state: String?
    
    // Make Identifiable work
    var id: String {
        return code ?? name ?? UUID().uuidString
    }
}
