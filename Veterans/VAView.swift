//
//  VAView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI

struct VAView: View {
    @StateObject private var apiService = VAGovAPIService()
    @StateObject private var cacheService = VAGovCacheService()
    
    @State private var selectedTab: VATab = .forms
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum VATab: String, CaseIterable {
        case forms = "Forms"
        case facilities = "Facilities"
        case reference = "Reference Data"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .forms: return "doc.text.fill"
            case .facilities: return "building.2.fill"
            case .reference: return "list.bullet.rectangle.fill"
            case .settings: return "gear"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Unified Search Bar
            unifiedSearchBar
            
            // Tab Navigation
            tabNavigationView
            
            // Content Area
            contentArea
        }
        .background(.ultraThinMaterial)
        .onAppear {
            checkAPIConfiguration()
        }
    }
    
    private var unifiedSearchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField(searchPlaceholder, text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    private var searchPlaceholder: String {
        switch selectedTab {
        case .forms:
            return "Search VA forms by name, title, or category..."
        case .facilities:
            return "Search facilities by name, location, or type..."
        case .reference:
            return "Search reference data..."
        case .settings:
            return "Search settings..."
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("VA.GOV Integration")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Access VA forms, facilities, and reference data")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // API Status Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(apiService.hasAPIKey() ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(apiService.hasAPIKey() ? "Connected" : "Not Configured")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(apiService.hasAPIKey() ? .green : .red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill((apiService.hasAPIKey() ? Color.green : Color.red).opacity(0.1))
                )
            }
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                    Spacer()
                    Button("Dismiss") {
                        errorMessage = nil
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(.primary.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var tabNavigationView: some View {
        HStack(spacing: 0) {
            ForEach(VATab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedTab == tab ? Color.blue : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                if tab != VATab.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    private var contentArea: some View {
        Group {
            switch selectedTab {
            case .forms:
                VAFormsView(apiService: apiService, cacheService: cacheService, searchText: $searchText)
            case .facilities:
                VAFacilitiesView(apiService: apiService, cacheService: cacheService, searchText: $searchText)
            case .reference:
                VAReferenceDataView(apiService: apiService, cacheService: cacheService, searchText: $searchText)
            case .settings:
                VASettingsView(apiService: apiService)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func checkAPIConfiguration() {
        if !apiService.hasAPIKey() {
            errorMessage = "VA.GOV API key not configured. Please configure it in Settings."
        }
    }
}

// MARK: - VA Forms View

struct VAFormsView: View {
    @ObservedObject var apiService: VAGovAPIService
    @ObservedObject var cacheService: VAGovCacheService
    @Binding var searchText: String
    
    @State private var forms: [VAForm] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedForm: VAForm?
    @State private var showingFormDetail = false
    
    private var filteredForms: [VAForm] {
        if searchText.isEmpty {
            return forms
        } else {
            return forms.filter { form in
                form.attributes.title.localizedCaseInsensitiveContains(searchText) ||
                form.attributes.formName.localizedCaseInsensitiveContains(searchText) ||
                (form.attributes.benefitCategories?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Refresh Button Bar
            HStack(spacing: 12) {
                Spacer()
                
                Button(action: loadForms) {
                    HStack(spacing: 6) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                        }
                        Text("Refresh")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Forms List
            if forms.isEmpty && !isLoading {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredForms, id: \.id) { form in
                            VAFormRowView(form: form) {
                                // Open the form URL when clicked
                                if let url = URL(string: form.attributes.url) {
                                    NSWorkspace.shared.open(url)
                                }
                            } onDetailTap: {
                                // Show detail view on secondary action (right-click or option-click)
                                selectedForm = form
                                showingFormDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            loadForms()
        }
        .sheet(isPresented: $showingFormDetail) {
            if let form = selectedForm {
                VAFormDetailView(form: form)
                    .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                    .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No VA Forms Loaded")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            } else {
                Text("Click 'Refresh' to load VA forms from the API")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Load Forms") {
                loadForms()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    private func loadForms() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let response = try await apiService.getAllForms()
                await MainActor.run {
                    self.forms = response.data
                    self.isLoading = false
                    
                    // If we got a response but it's empty, show a helpful message
                    if response.data.isEmpty {
                        self.errorMessage = "No forms found. The Forms API may not be authorized yet, or the sandbox may have no test data. Check the console for detailed error information."
                    }
                }
            } catch let error as VAGovError {
                await MainActor.run {
                    // Provide more user-friendly error messages
                    switch error {
                    case .noAPIKey:
                        self.errorMessage = "VA.gov Forms API key not configured. Please configure it in Settings."
                    case .apiError(let code, let message):
                        if code == 403 {
                            self.errorMessage = "Forms API access not authorized. Your API key needs to be specifically authorized for the Forms API service. Please request access at: https://developer.va.gov/explore/api/va-forms/sandbox-access"
                        } else {
                            self.errorMessage = "API Error (\(code)): \(message)"
                        }
                    case .decodingError(let decodingError):
                        // Provide more helpful decoding error message
                        if let decodingError = decodingError as? DecodingError {
                            var errorDetails = "Failed to decode Forms API response. "
                            switch decodingError {
                            case .dataCorrupted(let context):
                                errorDetails += "Data is corrupted: \(context.debugDescription)"
                            case .keyNotFound(let key, let context):
                                errorDetails += "Missing key '\(key.stringValue)' at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                            case .typeMismatch(let type, let context):
                                errorDetails += "Type mismatch for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                            case .valueNotFound(let type, let context):
                                errorDetails += "Value not found for \(type) at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                            @unknown default:
                                errorDetails += "\(decodingError.localizedDescription)"
                            }
                            errorDetails += "\n\nCheck the console for the raw API response to see what structure was returned."
                            self.errorMessage = errorDetails
                        } else {
                            self.errorMessage = "Failed to decode response: \(decodingError.localizedDescription)"
                        }
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error loading forms: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - VA Form Row View

struct VAFormRowView: View {
    let form: VAForm
    let onTap: () -> Void
    let onDetailTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Form Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.gradient)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Form Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(form.attributes.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text("Form: \(form.attributes.formName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if let categories = form.attributes.benefitCategories, !categories.isEmpty {
                        Text("Categories: \(categories.prefix(2).joined(separator: ", "))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Form Details
                VStack(alignment: .trailing, spacing: 4) {
                    if let pages = form.attributes.pages {
                        Text("\(pages) pages")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    if form.attributes.validPdf {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("Valid PDF")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isHovered ? .blue.opacity(0.3) : .clear, lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button("View Details") {
                onDetailTap()
            }
            
            Button("Open Form URL") {
                onTap()
            }
        }
    }
}

// MARK: - VA Form Detail View

struct VAFormDetailView: View {
    let form: VAForm
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(form.attributes.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Form: \(form.attributes.formName)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    // Form Details
                    VStack(alignment: .leading, spacing: 16) {
                        FormDetailRow(title: "Form Name", value: form.attributes.formName)
                        FormDetailRow(title: "Form Type", value: form.attributes.formType ?? "N/A")
                        FormDetailRow(title: "Pages", value: form.attributes.pages?.description ?? "N/A")
                        FormDetailRow(title: "Language", value: form.attributes.language ?? "English")
                        FormDetailRow(title: "Valid PDF", value: form.attributes.validPdf ? "Yes" : "No")
                        
                        if let firstIssued = form.attributes.firstIssuedOn {
                            FormDetailRow(title: "First Issued", value: firstIssued)
                        }
                        
                        if let lastRevision = form.attributes.lastRevisionOn {
                            FormDetailRow(title: "Last Revision", value: lastRevision)
                        }
                    }
                    
                    // Benefit Categories
                    if let categories = form.attributes.benefitCategories, !categories.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Benefit Categories")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                    
                    // Form Usage
                    if let usage = form.attributes.formUsage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Form Usage")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(usage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Actions
                    HStack(spacing: 12) {
                        Button(action: {
                            if let url = URL(string: form.attributes.url) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Download PDF")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if let toolUrl = form.attributes.formToolUrl, !toolUrl.isEmpty {
                            Button(action: {
                                if let url = URL(string: toolUrl) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "wrench.and.screwdriver.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Form Tool")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.green)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Form Details")
        }
    }
}

struct FormDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - VA Facilities View

struct VAFacilitiesView: View {
    @ObservedObject var apiService: VAGovAPIService
    @ObservedObject var cacheService: VAGovCacheService
    @Binding var searchText: String
    
    @State private var facilities: [VAFacility] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedFacilityType = "all"
    
    private var filteredFacilities: [VAFacility] {
        if searchText.isEmpty {
            return facilities
        } else {
            return facilities.filter { facility in
                facility.attributes.name.localizedCaseInsensitiveContains(searchText) ||
                facility.attributes.facilityType.localizedCaseInsensitiveContains(searchText) ||
                facility.attributes.address.physical?.city?.localizedCaseInsensitiveContains(searchText) ?? false ||
                facility.attributes.address.physical?.state?.localizedCaseInsensitiveContains(searchText) ?? false ||
                facility.attributes.address.physical?.zip?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    private let facilityTypes = ["all", "health", "benefits", "cemetery", "vet_center"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Controls
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Picker("Type", selection: $selectedFacilityType) {
                        Text("All Types").tag("all")
                        Text("Health").tag("health")
                        Text("Benefits").tag("benefits")
                        Text("Cemetery").tag("cemetery")
                        Text("Vet Center").tag("vet_center")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    
                    Button("Search") {
                        searchFacilities()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Facilities List
            if facilities.isEmpty && !isLoading {
                VStack(spacing: 20) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Facilities Found")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Search for VA facilities by location or type")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredFacilities, id: \.id) { facility in
                            VAFacilityRowView(facility: facility)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    private func searchFacilities() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let facilityType = selectedFacilityType == "all" ? nil : selectedFacilityType
                let response = try await apiService.searchFacilities(facilityType: facilityType)
                await MainActor.run {
                    self.facilities = response.data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - VA Facility Row View

struct VAFacilityRowView: View {
    let facility: VAFacility
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Facility Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.green.gradient)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Facility Info
            VStack(alignment: .leading, spacing: 4) {
                Text(facility.attributes.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(facility.attributes.facilityType.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                if let address = facility.attributes.address.physical {
                    Text("\(address.city ?? ""), \(address.state ?? "")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Contact Info
            VStack(alignment: .trailing, spacing: 4) {
                if let phone = facility.attributes.phone.main {
                    Text(phone)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if let website = facility.attributes.website {
                    Button(action: {
                        if let url = URL(string: website) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("Website")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHovered ? .green.opacity(0.3) : .clear, lineWidth: 2)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - VA Reference Data View

struct VAReferenceDataView: View {
    @ObservedObject var apiService: VAGovAPIService
    @ObservedObject var cacheService: VAGovCacheService
    @Binding var searchText: String
    
    @State private var selectedDataType: ReferenceDataType = .disabilities
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    enum ReferenceDataType: String, CaseIterable {
        case disabilities = "Disabilities"
        case serviceBranches = "Service Branches"
        case treatmentCenters = "Treatment Centers"
        case states = "States"
        case countries = "Countries"
        
        var icon: String {
            switch self {
            case .disabilities: return "cross.case.fill"
            case .serviceBranches: return "flag.fill"
            case .treatmentCenters: return "cross.fill"
            case .states: return "map.fill"
            case .countries: return "globe"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Data Type Selector
            HStack(spacing: 0) {
                ForEach(ReferenceDataType.allCases, id: \.self) { dataType in
                    Button(action: {
                        selectedDataType = dataType
                        loadReferenceData()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: dataType.icon)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(dataType.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectedDataType == dataType ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedDataType == dataType ? Color.blue : Color.clear)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if dataType != ReferenceDataType.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Reference Data Content
            Group {
                switch selectedDataType {
                case .disabilities:
                    ReferenceDataListView<Disability>(
                        title: "Disabilities",
                        searchText: searchText,
                        loadData: {
                            let response = try await apiService.getDisabilities()
                            return response.disabilities
                        },
                        filterPredicate: { disability, search in
                            disability.name.localizedCaseInsensitiveContains(search) ||
                            String(disability.id).localizedCaseInsensitiveContains(search)
                        },
                        itemView: { disability in
                            AnyView(VStack(alignment: .leading, spacing: 4) {
                                Text(disability.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("ID: \(disability.id)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            })
                        }
                    )
                case .serviceBranches:
                    ReferenceDataListView<ServiceBranch>(
                        title: "Service Branches",
                        searchText: searchText,
                        loadData: {
                            let response = try await apiService.getServiceBranches()
                            return response.serviceBranches
                        },
                        filterPredicate: { branch, search in
                            branch.description.localizedCaseInsensitiveContains(search) ||
                            branch.code.localizedCaseInsensitiveContains(search)
                        },
                        itemView: { branch in
                            AnyView(VStack(alignment: .leading, spacing: 4) {
                                Text(branch.description)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                Text("Code: \(branch.code)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            })
                        }
                    )
                case .treatmentCenters:
                    ReferenceDataListView<TreatmentCenter>(
                        title: "Treatment Centers",
                        searchText: searchText,
                        loadData: {
                            let response = try await apiService.getTreatmentCenters()
                            return response.treatmentCenters
                        },
                        filterPredicate: { center, search in
                            (center.name?.localizedCaseInsensitiveContains(search) ?? false) ||
                            (center.description?.localizedCaseInsensitiveContains(search) ?? false) ||
                            (center.code?.localizedCaseInsensitiveContains(search) ?? false) ||
                            (center.city?.localizedCaseInsensitiveContains(search) ?? false) ||
                            (center.state?.localizedCaseInsensitiveContains(search) ?? false)
                        },
                        itemView: { center in
                            AnyView(VStack(alignment: .leading, spacing: 4) {
                                Text(center.name ?? center.description ?? "Unknown")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                if let city = center.city, let state = center.state {
                                    Text("\(city), \(state)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else if let code = center.code {
                                    Text("Code: \(code)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            })
                        }
                    )
                case .states:
                    ReferenceDataListView<IdentifiableString>(
                        title: "States",
                        searchText: searchText,
                        loadData: {
                            let response = try await apiService.getStates()
                            return response.states.map { IdentifiableString($0) }
                        },
                        filterPredicate: { state, search in
                            state.value.localizedCaseInsensitiveContains(search)
                        },
                        itemView: { stateCode in
                            AnyView(VStack(alignment: .leading, spacing: 4) {
                                Text(stateCode.value)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            })
                        }
                    )
                case .countries:
                    ReferenceDataListView<IdentifiableString>(
                        title: "Countries",
                        searchText: searchText,
                        loadData: {
                            let response = try await apiService.getCountries()
                            return response.countries.map { IdentifiableString($0) }
                        },
                        filterPredicate: { country, search in
                            country.value.localizedCaseInsensitiveContains(search)
                        },
                        itemView: { countryName in
                            AnyView(VStack(alignment: .leading, spacing: 4) {
                                Text(countryName.value)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                            })
                        }
                    )
                }
            }
        }
        .onAppear {
            loadReferenceData()
        }
    }
    
    private func loadReferenceData() {
        // This will be handled by the individual ReferenceDataListView components
    }
}

// MARK: - Generic Reference Data List View

struct ReferenceDataListView<T: Codable & Identifiable>: View {
    let title: String
    let searchText: String
    let loadData: () async throws -> [T]
    let filterPredicate: ((T, String) -> Bool)?
    let itemView: (T) -> AnyView
    
    @State private var items: [T] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var filteredItems: [T] {
        guard let filterPredicate = filterPredicate, !searchText.isEmpty else {
            return items
        }
        return items.filter { filterPredicate($0, searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading \(title)...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: searchText.isEmpty ? "list.bullet.rectangle" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text(searchText.isEmpty ? "No \(title) Data" : "No Results Found")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Text("No items match \"\(searchText)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }
                    
                    if items.isEmpty {
                        Button("Load Data") {
                            performLoadData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredItems, id: \.id) { item in
                            HStack {
                                itemView(item)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.regularMaterial)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .onAppear {
            performLoadData()
        }
        .onChange(of: searchText) { _, _ in
            // Search filtering happens automatically via filteredItems computed property
        }
    }
    
    private func performLoadData() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let loadedItems = try await loadData()
                await MainActor.run {
                    self.items = loadedItems
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - VA Settings View

struct VASettingsView: View {
    @ObservedObject var apiService: VAGovAPIService
    
    @State private var apiKey = ""
    @State private var environment: VAGovAPIService.Environment = .sandbox
    @State private var showingAPIKeyField = false
    @State private var connectionStatus = "Unknown"
    @State private var isTestingConnection = false
    
    var body: some View {
        VStack(spacing: 20) {
            // API Configuration Section
            VStack(alignment: .leading, spacing: 16) {
                Text("API Configuration")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    // Environment Selection
                    HStack {
                        Text("Environment:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Picker("Environment", selection: $environment) {
                            ForEach(VAGovAPIService.Environment.allCases, id: \.self) { env in
                                Text(env.displayName).tag(env)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .onChange(of: environment) { _, newValue in
                            apiService.setEnvironment(newValue)
                        }
                    }
                    
                    // API Key Management
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("API Key:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            if showingAPIKeyField {
                                VStack(alignment: .leading, spacing: 4) {
                                    SecureField("Enter API Key", text: $apiKey)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 300)
                                    
                                    // Show validation feedback
                                    if !apiKey.isEmpty {
                                        let validation = apiService.validateAPIKeyFormat(apiKey)
                                        Text(validation.message)
                                            .font(.system(size: 11))
                                            .foregroundColor(validation.isValid ? .green : .orange)
                                    }
                                }
                            } else {
                                HStack {
                                    Text(apiService.hasAPIKey() ? "••••••••••••••••" : "Not Set")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(apiService.hasAPIKey() ? .green : .red)
                                        .frame(width: 300, alignment: .leading)
                                    
                                    if apiService.hasAPIKey() {
                                        // Show API key info
                                        Button(action: {
                                            do {
                                                let key = try apiService.retrieveAPIKey()
                                                print("API Key Info:")
                                                print("  Length: \(key.count) characters")
                                                print("  First 4 chars: \(String(key.prefix(4)))...")
                                                print("  Last 4 chars: ...\(String(key.suffix(4)))")
                                            } catch {
                                                print("Could not retrieve API key: \(error)")
                                            }
                                        }) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(.plain)
                                        .help("Show API key info in console")
                                    }
                                }
                            }
                            
                            Button(showingAPIKeyField ? "Save" : "Edit") {
                                if showingAPIKeyField {
                                    // Validate API key format before saving
                                    let validation = apiService.validateAPIKeyFormat(apiKey)
                                    if !validation.isValid {
                                        // Show validation error
                                        print("⚠️ API Key Validation Error: \(validation.message)")
                                        return
                                    }
                                    
                                    do {
                                        try apiService.storeAPIKey(apiKey)
                                        showingAPIKeyField = false
                                        apiKey = ""
                                        print("✅ API key saved successfully")
                                        // Test connection after saving
                                        testConnection()
                                    } catch {
                                        print("❌ Failed to store API key: \(error)")
                                    }
                                } else {
                                    showingAPIKeyField = true
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // Connection Test
                    HStack {
                        Text("Status:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(connectionStatus == "Connected" ? .green : .red)
                                .frame(width: 8, height: 8)
                            
                            Text(connectionStatus)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(connectionStatus == "Connected" ? .green : .red)
                        }
                        
                        Button("Test Connection") {
                            testConnection()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isTestingConnection)
                        
                        Button("Diagnostic Test") {
                            Task {
                                await apiService.testRawRequest()
                            }
                        }
                        .buttonStyle(.bordered)
                        .help("Test different authentication formats")
                        
                        if isTestingConnection {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            
            // API Information Section
            VStack(alignment: .leading, spacing: 16) {
                Text("API Information")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    VAInfoRow(title: "Base URL", value: "https://\(environment.rawValue)")
                    VAInfoRow(title: "Authentication", value: "API Key")
                    VAInfoRow(title: "Rate Limits", value: "Varies by endpoint")
                    VAInfoRow(title: "Documentation", value: "https://developer.va.gov/explore")
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Help Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Need Help?")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Link("Get Sandbox API Key", destination: URL(string: "https://developer.va.gov/explore/api/va-forms/sandbox-access")!)
                        .font(.system(size: 14))
                    
                    Link("Request Production Access", destination: URL(string: "https://developer.va.gov/go-live")!)
                        .font(.system(size: 14))
                    
                    Text("If you're getting a 403 error, your API key may be invalid, expired, or for a different environment.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.regularMaterial)
            )
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            environment = apiService.getCurrentEnvironment()
            updateConnectionStatus()
        }
    }
    
    private func testConnection() {
        Task {
            await MainActor.run {
                isTestingConnection = true
                connectionStatus = "Testing..."
            }
            
            do {
                let success = try await apiService.testConnection()
                await MainActor.run {
                    connectionStatus = success ? "Connected" : "Failed"
                    isTestingConnection = false
                }
            } catch let error as VAGovError {
                await MainActor.run {
                    connectionStatus = "Failed"
                    isTestingConnection = false
                    // Log detailed error for debugging
                    print("Connection test error details:")
                    print("  Error type: \(error)")
                    print("  Description: \(error.localizedDescription)")
                    
                    // Show full error message in console
                    if case .apiError(let code, let message) = error {
                        print("  Status code: \(code)")
                        print("  Message: \(message)")
                    }
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "Failed"
                    isTestingConnection = false
                    print("Connection test error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateConnectionStatus() {
        connectionStatus = apiService.hasAPIKey() ? "Configured" : "Not Configured"
    }
}

struct VAInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    VAView()
}

