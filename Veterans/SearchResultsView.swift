//
//  SearchResultsView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

struct SearchResultsView: View {
    @ObservedObject var searchService: SearchService
    @Binding var navigationPath: NavigationPath
    @Binding var selectedSection: NavigationSection
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Found \(searchService.searchResults.count) results for \"\(searchService.searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Filter buttons
                HStack(spacing: 8) {
                    FilterButton(
                        title: "All",
                        count: searchService.searchResults.count,
                        isSelected: searchService.selectedFilter == nil
                    ) {
                        searchService.setFilter(nil)
                    }
                    
                    ForEach(SearchResultType.allCases, id: \.self) { type in
                        let count = searchService.resultCounts[type] ?? 0
                        if count > 0 {
                            FilterButton(
                                title: type.rawValue,
                                count: count,
                                isSelected: searchService.selectedFilter == type
                            ) {
                                searchService.setFilter(type)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            
            // Search Results
            if searchService.searchResults.isEmpty {
                EmptySearchView()
            } else {
                List {
                    ForEach(searchService.searchResults, id: \.id) { result in
                        Button(action: {
                            handleResultTap(result)
                        }) {
                            SearchResultRowContent(result: result)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .background(.ultraThinMaterial)
            }
        }
    }
    
    private func handleResultTap(_ result: SearchResult) {
        switch result.type {
        case .veteran:
            if let veteran = result.associatedVeteran {
                navigationPath.append(veteran)
            }
        case .claim:
            if let claim = result.associatedClaim {
                navigationPath.append(claim)
                selectedSection = .claims
            }
        case .document:
            if let veteran = result.associatedVeteran {
                navigationPath.append(veteran)
                selectedSection = .documents
            }
        case .activity:
            if let veteran = result.associatedVeteran {
                navigationPath.append(veteran)
                selectedSection = .veterans // Activities are shown in veteran detail view
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue : Color.secondary.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Result Row
struct SearchResultRowContent: View {
    let result: SearchResult
    @State private var isHovered = false
    
    var body: some View {
            HStack(spacing: 12) {
                // Type Icon
                ZStack {
                    Circle()
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: result.type.icon)
                        .foregroundColor(typeColor)
                        .font(.title3)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(result.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(result.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(typeColor.opacity(0.2))
                            .foregroundColor(typeColor)
                            .cornerRadius(4)
                    }
                    
                    Text(result.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Additional context
                    if let veteran = result.associatedVeteran {
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "person")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            Text(veteran.fullName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let claim = result.associatedClaim {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                    Text(claim.claimNumber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? Color.primary.opacity(0.05) : Color.clear)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
    
    private var typeColor: Color {
        switch result.type {
        case .veteran: return .blue
        case .claim: return .green
        case .document: return .orange
        case .activity: return .purple
        }
    }
}

// MARK: - Empty Search View
struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results Found")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Try adjusting your search terms or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    SearchResultsView(
        searchService: SearchService(),
        navigationPath: .constant(NavigationPath()),
        selectedSection: .constant(NavigationSection.veterans)
    )
    .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}
