//
//  SearchService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import SwiftData

// MARK: - Search Result Types
enum SearchResultType: String, CaseIterable {
    case veteran = "Veteran"
    case claim = "Claim"
    case document = "Document"
    case activity = "Activity"
    
    var icon: String {
        switch self {
        case .veteran: return "person.fill"
        case .claim: return "doc.text.fill"
        case .document: return "folder.fill"
        case .activity: return "clock.fill"
        }
    }
    
    var color: String {
        switch self {
        case .veteran: return "blue"
        case .claim: return "green"
        case .document: return "orange"
        case .activity: return "purple"
        }
    }
}

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let type: SearchResultType
    let title: String
    let subtitle: String
    let searchableContent: String
    let associatedVeteran: Veteran?
    let associatedClaim: Claim?
    let associatedDocument: Document?
    let associatedActivity: ClaimActivity?
    
    // For veteran results
    init(veteran: Veteran) {
        self.type = .veteran
        self.title = veteran.fullName
        self.subtitle = "\(veteran.serviceBranch) • \(veteran.claims.count) claims"
        self.searchableContent = """
        \(veteran.fullName)
        \(veteran.emailPrimary)
        \(veteran.phonePrimary)
        \(veteran.serviceBranch)
        \(veteran.rankAtSeparation)
        \(veteran.ssnLastFour)
        \(veteran.dateOfBirth.formatted())
        \(veteran.serviceStartDate.formatted())
        \(veteran.serviceEndDate.formatted())
        \(veteran.addressStreet ?? "")
        \(veteran.addressCity ?? "")
        \(veteran.addressState ?? "")
        \(veteran.addressZip)
        """.lowercased()
        self.associatedVeteran = veteran
        self.associatedClaim = nil
        self.associatedDocument = nil
        self.associatedActivity = nil
    }
    
    // For claim results
    init(claim: Claim) {
        self.type = .claim
        self.title = claim.claimNumber
        self.subtitle = "\(claim.claimType) • \(claim.claimStatus)"
        self.searchableContent = """
        \(claim.claimNumber)
        \(claim.claimType)
        \(claim.claimStatus)
        \(claim.primaryCondition)
        \(claim.secondaryConditions)
        \(claim.veteran?.fullName ?? "")
        \(claim.claimFiledDate.formatted())
        \(claim.claimReceivedDate?.formatted() ?? "")
        \(claim.claimDecisionDate?.formatted() ?? "")
        """.lowercased()
        self.associatedVeteran = claim.veteran
        self.associatedClaim = claim
        self.associatedDocument = nil
        self.associatedActivity = nil
    }
    
    // For document results
    init(document: Document) {
        self.type = .document
        self.title = document.fileName
        self.subtitle = "\(document.documentType.rawValue) • \(ByteCountFormatter.string(fromByteCount: document.fileSize, countStyle: .file))"
        self.searchableContent = """
        \(document.fileName)
        \(document.documentType.rawValue)
        \(document.documentDescription)
        \(document.veteran?.fullName ?? "")
        \(document.claim?.claimNumber ?? "")
        \(document.uploadDate.formatted())
        """.lowercased()
        self.associatedVeteran = document.veteran
        self.associatedClaim = document.claim
        self.associatedDocument = document
        self.associatedActivity = nil
    }
    
    // For activity results
    init(activity: ClaimActivity) {
        self.type = .activity
        self.title = activity.activityType.rawValue
        self.subtitle = "\(activity.claimDescription) • \(activity.performedBy)"
        self.searchableContent = """
        \(activity.activityType.rawValue)
        \(activity.claimDescription)
        \(activity.notes)
        \(activity.performedBy)
        \(activity.claim?.claimNumber ?? "")
        \(activity.claim?.veteran?.fullName ?? "")
        \(activity.date.formatted())
        """.lowercased()
        self.associatedVeteran = activity.claim?.veteran
        self.associatedClaim = activity.claim
        self.associatedDocument = nil
        self.associatedActivity = activity
    }
    
}

// MARK: - Search Service
class SearchService: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var selectedFilter: SearchResultType? = nil
    
    private var allResults: [SearchResult] = []
    
    func performSearch(
        veterans: [Veteran],
        claims: [Claim],
        documents: [Document],
        activities: [ClaimActivity],
        searchText: String
    ) {
        self.searchText = searchText
        
        guard !searchText.isEmpty else {
            searchResults = []
            allResults = []
            return
        }
        
        isSearching = true
        
        // Build all search results
        var results: [SearchResult] = []
        
        // Add veteran results
        for veteran in veterans {
            results.append(SearchResult(veteran: veteran))
        }
        
        // Add claim results
        for claim in claims {
            results.append(SearchResult(claim: claim))
        }
        
        // Add document results
        for document in documents {
            results.append(SearchResult(document: document))
        }
        
        // Add activity results
        for activity in activities {
            results.append(SearchResult(activity: activity))
        }
        
        // Filter results based on search text
        let filteredResults = results.filter { result in
            result.searchableContent.contains(searchText.lowercased())
        }
        
        // Apply type filter if selected
        let finalResults = if let filter = selectedFilter {
            filteredResults.filter { $0.type == filter }
        } else {
            filteredResults
        }
        
        // Sort results by type and relevance
        searchResults = finalResults.sorted { first, second in
            // First sort by type
            if first.type != second.type {
                return first.type.rawValue < second.type.rawValue
            }
            
            // Then by title
            return first.title < second.title
        }
        
        allResults = results
        isSearching = false
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        allResults = []
        selectedFilter = nil
    }
    
    func setFilter(_ filter: SearchResultType?) {
        selectedFilter = filter
        
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // Re-filter results with new filter
        let filteredResults = allResults.filter { result in
            result.searchableContent.contains(searchText.lowercased())
        }
        
        let finalResults = if let filter = selectedFilter {
            filteredResults.filter { $0.type == filter }
        } else {
            filteredResults
        }
        
        searchResults = finalResults.sorted { first, second in
            if first.type != second.type {
                return first.type.rawValue < second.type.rawValue
            }
            return first.title < second.title
        }
    }
    
    var resultCounts: [SearchResultType: Int] {
        var counts: [SearchResultType: Int] = [:]
        
        for result in allResults {
            if result.searchableContent.contains(searchText.lowercased()) {
                counts[result.type, default: 0] += 1
            }
        }
        
        return counts
    }
}
