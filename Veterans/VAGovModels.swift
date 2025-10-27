//
//  VAGovModels.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation

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
        let formName: String
        let title: String
        let url: String
        let firstIssuedOn: String?
        let lastRevisionOn: String?
        let pages: Int?
        let sha256: String
        let validPdf: Bool
        let deletedAt: String?
        let language: String?
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

struct DisabilitiesResponse: Codable {
    let data: [Disability]
}

struct Disability: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: DisabilityAttributes
    
    struct DisabilityAttributes: Codable {
        let name: String
        let code: String
        let diagnosticCode: String?
    }
}

struct ServiceBranchesResponse: Codable {
    let data: [ServiceBranch]
}

struct ServiceBranch: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: ServiceBranchAttributes
    
    struct ServiceBranchAttributes: Codable {
        let name: String
        let code: String
    }
}

struct TreatmentCentersResponse: Codable {
    let data: [TreatmentCenter]
}

struct TreatmentCenter: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: TreatmentCenterAttributes
    
    struct TreatmentCenterAttributes: Codable {
        let name: String
        let code: String
        let city: String?
        let state: String?
        let classification: String?
    }
}

struct StatesResponse: Codable {
    let data: [VAState]
}

struct VAState: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: VAStateAttributes
    
    struct VAStateAttributes: Codable {
        let name: String
        let code: String
    }
}

struct CountriesResponse: Codable {
    let data: [Country]
}

struct Country: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: CountryAttributes
    
    struct CountryAttributes: Codable {
        let name: String
        let code: String
    }
}

// MARK: - Common Response Models

struct ContentionTypesResponse: Codable {
    let data: [ContentionType]
}

struct ContentionType: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: ContentionTypeAttributes
    
    struct ContentionTypeAttributes: Codable {
        let name: String
        let code: String
    }
}

struct MilitaryPayTypesResponse: Codable {
    let data: [MilitaryPayType]
}

struct MilitaryPayType: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: MilitaryPayTypeAttributes
    
    struct MilitaryPayTypeAttributes: Codable {
        let name: String
        let code: String
    }
}

struct SpecialCircumstancesResponse: Codable {
    let data: [SpecialCircumstance]
}

struct SpecialCircumstance: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: SpecialCircumstanceAttributes
    
    struct SpecialCircumstanceAttributes: Codable {
        let name: String
        let code: String
    }
}

struct IntakeSitesResponse: Codable {
    let data: [IntakeSite]
}

struct IntakeSite: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: IntakeSiteAttributes
    
    struct IntakeSiteAttributes: Codable {
        let name: String
        let code: String
        let city: String?
        let state: String?
    }
}
