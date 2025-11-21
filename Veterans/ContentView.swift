import SwiftUI
import SwiftData

// MARK: - Navigation Section
enum NavigationSection: String, CaseIterable {
    case dashboard = "Dashboard"
    case veterans = "Veterans"
    case claims = "Claims"
    case kanban = "Kanban Board"
    case documents = "Documents"
    case va = "VA.GOV"
    case copilot = "Copilot"
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .veterans: return "person.3.fill"
        case .claims: return "doc.text.fill"
        case .kanban: return "rectangle.3.group.fill"
        case .documents: return "folder.fill"
        case .va: return "building.2.fill"
        case .copilot: return "brain.head.profile"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var veterans: [Veteran]
    @Query private var claims: [Claim]
    @Query private var documents: [Document]
    @Query private var activities: [ClaimActivity]
    
    @State private var selectedSection: NavigationSection = .dashboard
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var showingAddVeteran = false
    @State private var showingAddClaim = false
    @State private var showingDocumentUpload = false
    @State private var showingEmailCompose = false
    @State private var showingEmailSettings = false
    @State private var showingExport = false
    @State private var showingImport = false
    @State private var navigationPath = NavigationPath()
    
    // Veteran selection for dashboard actions
    @State private var showingVeteranSelectorForClaim = false
    @State private var showingVeteranSelectorForDocument = false
    @State private var selectedVeteranForClaim: Veteran?
    @State private var selectedVeteranForDocument: Veteran?
    
    private var searchService = SearchService()
    
    private var filteredVeterans: [Veteran] {
        if searchText.isEmpty {
            return veterans
        } else {
            return veterans.filter { veteran in
                veteran.firstName.localizedCaseInsensitiveContains(searchText) ||
                veteran.lastName.localizedCaseInsensitiveContains(searchText) ||
                veteran.emailPrimary.localizedCaseInsensitiveContains(searchText) ||
                veteran.phonePrimary.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func performSearch() {
        if searchText.isEmpty {
            showingSearchResults = false
        } else {
            showingSearchResults = true
            searchService.performSearch(
                veterans: veterans,
                claims: claims,
                documents: documents,
                activities: activities,
                searchText: searchText
            )
        }
    }
    
    private func getTargetTab() -> Int {
        switch selectedSection {
        case .claims: return 1 // Claims tab
        case .documents: return 2 // Documents tab
        default:
            return 0 // Overview tab
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            sidebarView
                .frame(width: 250)
            
            NavigationStack(path: $navigationPath) {
                mainContentArea
                    .navigationDestination(for: Veteran.self) { veteran in
                        VeteranDetailView(veteran: veteran, initialTab: nil)
                    }
            }
        }
        .sheet(isPresented: $showingAddVeteran) {
            AddVeteranView()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
        }
        .sheet(isPresented: $showingVeteranSelectorForClaim) {
            VeteranSelectorView(
                veterans: veterans,
                onVeteranSelected: { veteran in
                    selectedVeteranForClaim = veteran
                    showingVeteranSelectorForClaim = false
                }
            )
            .frame(minWidth: 600, idealWidth: 700, maxWidth: 800)
            .frame(minHeight: 500, idealHeight: 600, maxHeight: 700)
        }
        .sheet(item: $selectedVeteranForClaim) { veteran in
            AddClaimView(veteran: veteran)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 700, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingEmailCompose) {
            EmailComposeView()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
        }
        .sheet(isPresented: $showingEmailSettings) {
            SettingsView()
                .frame(minWidth: 600, idealWidth: 800, maxWidth: 1000)
                .frame(minHeight: 400, idealHeight: 600, maxHeight: 800)
        }
        .sheet(isPresented: $showingExport) {
            ExportView()
        }
        .sheet(isPresented: $showingImport) {
            ImportView()
        }
        .task {
            // Initialize LoggingManager with model context from environment
            // This ensures setup happens when the view appears and has access to the environment modelContext
            LoggingManager.shared.setupActivityLogger(modelContext: modelContext)
        }
    }
    
    private var sidebarView: some View {
            VStack(spacing: 0) {
            // Header
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // App Logo
                        Image("AppLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Veterans Claims Foundation")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Veterans Benefit Management")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // Navigation List
                VStack(spacing: 0) {
                    List(selection: $selectedSection) {
                        ForEach(NavigationSection.allCases, id: \.self) { section in
                        HStack(spacing: 12) {
                            Image(systemName: section.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedSection == section ? .white : .primary)
                                .frame(width: 20, height: 20)
                            
                            Text(section.rawValue)
                                .font(.system(size: 14, weight: selectedSection == section ? .semibold : .medium))
                                .foregroundColor(selectedSection == section ? .white : .primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedSection == section ? Color.blue : Color.clear)
                        )
                                .tag(section)
                        .onTapGesture {
                            selectedSection = section
                            navigationPath = NavigationPath() // Pop to root
                        }
                        }
                    }
                    .listStyle(.sidebar)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                }
                
            Spacer()
            
            // Bottom Action Buttons
            VStack(spacing: 8) {
                    Divider()
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                    // Email Actions
                        Button(action: {
                            showingEmailCompose = true
                        }) {
                        HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 20)
                            
                                Text("Compose Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                                Spacer()
                            }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingEmailSettings = true
                        }) {
                        HStack(spacing: 12) {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 20, height: 20)
                            
                            Text("Settings")
                                    .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                                Spacer()
                            }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Button(action: {
                            showingExport = true
                        }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 20)
                            
                            Text("Export Data")
                                    .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                                Spacer()
                            }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingImport = true
                        }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                            
                            Text("Import Data")
                                    .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                                Spacer()
                            }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.1))
                        )
                        }
                        .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Logout action
                        print("Logout tapped")
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                            
                            Text("Logout")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
    
    private var mainContentArea: some View {
        Group {
            // Show kanban as single screen, others as split view
            if selectedSection == .kanban {
                VStack {
                    KanbanBoardView()
                }
                .navigationTitle("Kanban Board")
            } else {
                VStack(spacing: 0) {
                    searchBarView
                    mainContentView
                }
                .navigationTitle(showingSearchResults ? "Search Results" : selectedSection.rawValue)
            }
        }
    }
    
    private var searchBarView: some View {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search veterans, claims, documents...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .onChange(of: searchText) { _, newValue in
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                performSearch()
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
                        
                        // Quick Actions
                        HStack(spacing: 8) {
                            Button(action: { showingAddVeteran = true }) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 36, height: 36)
                                    .background(.blue.opacity(0.1), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                if veterans.isEmpty {
                                    // Navigate to veterans section if no veterans exist
                                    selectedSection = .veterans
                                } else {
                                    // Show veteran selector for claim
                                    showingVeteranSelectorForClaim = true
                                }
                            }) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.green)
                                    .frame(width: 36, height: 36)
                                    .background(.green.opacity(0.1), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Add Claim")
                            
                            Button(action: {
                                if veterans.isEmpty {
                                    // Navigate to veterans section if no veterans exist
                                    selectedSection = .veterans
                                } else {
                                    // Navigate to documents section where they can upload
                                    selectedSection = .documents
                                }
                            }) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 36, height: 36)
                                    .background(.orange.opacity(0.1), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Upload Document")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(.primary.opacity(0.1))
                            .frame(height: 1),
                        alignment: .bottom
                    )
    }
                    
    private var mainContentView: some View {
                    Group {
                        if showingSearchResults {
                            SearchResultsView(
                                searchService: searchService,
                    navigationPath: $navigationPath,
                                selectedSection: $selectedSection
                            )
                        } else {
                            switch selectedSection {
                            case .dashboard:
                                DashboardView(
                                    veterans: veterans,
                                    claims: claims,
                        onNavigateToVeterans: {
                            selectedSection = .veterans
                            navigationPath = NavigationPath() // Pop to root
                        },
                        onNavigateToClaims: {
                            selectedSection = .claims
                            navigationPath = NavigationPath() // Pop to root
                        }
                                )
                            case .veterans:
                                VeteransListView(
                        veterans: filteredVeterans
                                )
                            case .claims:
                                ClaimsListView(
                                    claims: claims,
                                    onClaimSelected: { claim in
                                        // Find the veteran who owns this claim and navigate to them
                                        if let veteran = veterans.first(where: { $0.claims.contains(where: { $0.id == claim.id }) }) {
                                            navigationPath.append(veteran)
                                        }
                                    }
                                )
                            case .documents:
                                DocumentsListView(
                                    onDocumentSelected: { document in
                                        // Find the veteran who owns this document and navigate to them
                                        if let veteran = veterans.first(where: { $0.documents.contains(where: { $0.id == document.id }) }) {
                                            navigationPath.append(veteran)
                                        }
                                    }
                                )
                            case .va:
                                VAView()
                            case .copilot:
                                CopilotView()
                case .kanban:
                    EmptyView() // This won't be reached due to the if condition above
                }
            }
        }
    }
    
    }
    
    // MARK: - Veterans List View
    struct VeteransListView: View {
        let veterans: [Veteran]
        
        var body: some View {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Veterans")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(veterans.count) veterans in database")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatBadge(icon: "person.2.fill", count: veterans.count, label: "Total", color: .blue)
                        StatBadge(icon: "doc.text.fill", count: veterans.reduce(0) { $0 + $1.claims.count }, label: "Claims", color: .green)
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
                
                // Enhanced List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(veterans, id: \.id) { veteran in
                        NavigationLink(value: veteran) {
                            VeteranRowView(veteran: veteran)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    // MARK: - Veteran Row View
    struct VeteranRowView: View {
        let veteran: Veteran
        @State private var isHovered = false
        
        var body: some View {
        HStack(spacing: 16) {
            // Profile Image
                    ZStack {
                        Circle()
                    .fill(.blue.gradient)
                    .frame(width: 50, height: 50)
                
                Text("\(veteran.firstName.prefix(1))\(veteran.lastName.prefix(1))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Veteran Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(veteran.firstName) \(veteran.lastName)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                
                Text(veteran.emailPrimary)
                    .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                
                Text("\(veteran.claims.count) claims")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Status Badge
            StatusBadge(status: veteran.claims.first?.claimStatus ?? "No Claims")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
            .onHover { hovering in
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Claims List View
    struct ClaimsListView: View {
        let claims: [Claim]
        let onClaimSelected: (Claim) -> Void
        @State private var showingEditClaim = false
        @State private var selectedClaim: Claim?
    @State private var showingClaimDetail = false
        
        var body: some View {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Claims")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(claims.count) claims in database")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatBadge(icon: "doc.text.fill", count: claims.count, label: "Total", color: .blue)
                        StatBadge(icon: "checkmark.circle.fill", count: claims.filter { $0.claimStatus == "approved" }.count, label: "Approved", color: .green)
                        StatBadge(icon: "clock.fill", count: claims.filter { $0.claimStatus == "inProgress" }.count, label: "In Progress", color: .orange)
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
                
                // Enhanced List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(claims, id: \.id) { claim in
                            Button(action: {
                                selectedClaim = claim
                                showingClaimDetail = true
                            }) {
                                ClaimRowView(claim: claim)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                            Button("View Claim Details") {
                                selectedClaim = claim
                                showingClaimDetail = true
                            }
                            
                                Button("Edit Claim") {
                                    selectedClaim = claim
                                    showingEditClaim = true
                                }
                                
                                Button("View Veteran Details") {
                                    onClaimSelected(claim)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
            }
            .sheet(isPresented: $showingEditClaim) {
                if let claim = selectedClaim {
                    EditClaimView(claim: claim)
                        .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                        .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
                }
            }
        .sheet(item: $selectedClaim) { claim in
            ClaimDetailModal(claim: claim)
        }
        }
    }
    
    // MARK: - Claim Row View
    struct ClaimRowView: View {
        let claim: Claim
        @State private var isHovered = false
        
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Claim Icon
            ZStack {
                Circle()
                    .fill(.green.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Claim Info
            VStack(alignment: .leading, spacing: 4) {
                Text(claim.claimType)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Filed: \(claim.claimFiledDate, formatter: dateFormatter)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("Status: \(claim.claimStatus)")
                            .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
            // Status Badge
            StatusBadge(status: claim.claimStatus)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
    
// MARK: - Documents List View
struct DocumentsListView: View {
    let onDocumentSelected: (Document) -> Void
    @Environment(\.modelContext) private var modelContext
    @Query private var veterans: [Veteran]
    
    @State private var showingVeteranSelector = false
    @State private var veteranForUpload: Veteran?
    @State private var veteranForNewFolder: Veteran?
    @State private var actionType: DocumentActionType = .upload
    
    enum DocumentActionType {
        case upload
        case newFolder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Documents")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(veterans.reduce(0) { $0 + $1.documents.count }) documents")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        actionType = .newFolder
                        showingVeteranSelector = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("New Folder")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.blue.gradient, in: Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        actionType = .upload
                        showingVeteranSelector = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("New File")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.green.gradient, in: Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
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
            
            // Content
            if veterans.isEmpty {
                emptyStateView
            } else {
                documentsContentView
            }
        }
        .sheet(isPresented: $showingVeteranSelector) {
            VeteranSelectorView(
                veterans: veterans,
                onVeteranSelected: { veteran in
                    showingVeteranSelector = false
                    if actionType == .upload {
                        veteranForUpload = veteran
                    } else {
                        veteranForNewFolder = veteran
                    }
                }
            )
            .frame(minWidth: 600, idealWidth: 700, maxWidth: 800)
            .frame(minHeight: 500, idealHeight: 600, maxHeight: 700)
        }
        .sheet(item: $veteranForUpload) { veteran in
            DocumentUploadView(veteran: veteran, claim: nil)
                .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                .frame(minHeight: 700, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(item: $veteranForNewFolder) { veteran in
            NewFolderView(veteran: veteran)
                .frame(minWidth: 600, idealWidth: 700, maxWidth: 800)
                .frame(minHeight: 400, idealHeight: 500, maxHeight: 600)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Documents")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("Upload documents to get started")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    private var documentsContentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(veterans.filter { !$0.documents.isEmpty }, id: \.id) { veteran in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                            Text(veteran.fullName)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text("\(veteran.documents.count) document\(veteran.documents.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                        
                        ForEach(veteran.documents, id: \.id) { document in
                            DocumentsListRowView(document: document) {
                                onDocumentSelected(document)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Documents List Row View
struct DocumentsListRowView: View {
    let document: Document
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(document.documentType.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatFileSize(document.fileSize))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
    
    // MARK: - Dashboard View
    struct DashboardView: View {
        let veterans: [Veteran]
        let claims: [Claim]
    let onNavigateToVeterans: () -> Void
    let onNavigateToClaims: () -> Void
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Total Veterans",
                        value: "\(veterans.count)",
                        icon: "person.2.fill",
                    color: .blue,
                    action: onNavigateToVeterans
                    )
                    
                    StatCard(
                        title: "Active Claims",
                        value: "\(claims.filter { $0.claimStatus.lowercased() != "closed" && $0.claimStatus.lowercased() != "complete" }.count)",
                        icon: "doc.text.fill",
                    color: .green,
                    action: onNavigateToClaims
                    )
                    
                    StatCard(
                        title: "Pending Claims",
                        value: "\(claims.filter { $0.claimStatus.lowercased() == "new" || $0.claimStatus.lowercased() == "in progress" || $0.claimStatus.lowercased() == "under review" }.count)",
                        icon: "clock.fill",
                    color: .orange,
                    action: onNavigateToClaims
                    )
                    
                    StatCard(
                        title: "Approved Claims",
                        value: "\(claims.filter { $0.claimStatus.lowercased() == "approved" || $0.claimStatus.lowercased() == "complete" }.count)",
                        icon: "checkmark.circle.fill",
                    color: .green,
                    action: onNavigateToClaims
                    )
                }
                .padding()
        }
        }
    }
    
    // MARK: - Stat Card
    struct StatCard: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
    let action: (() -> Void)?
        @State private var isHovered = false
    
    init(title: String, value: String, icon: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.action = action
    }
        
        var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(color.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    if isHovered {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(color)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: color.opacity(0.1), radius: isHovered ? 12 : 6, x: 0, y: isHovered ? 6 : 3)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .buttonStyle(PlainButtonStyle())
        }
    }
    
// MARK: - Veteran Selector View
struct VeteranSelectorView: View {
    let veterans: [Veteran]
    let onVeteranSelected: (Veteran) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedVeteran: Veteran?
    
    private var filteredVeterans: [Veteran] {
        if searchText.isEmpty {
            return veterans
        } else {
            return veterans.filter { veteran in
                veteran.firstName.localizedCaseInsensitiveContains(searchText) ||
                veteran.lastName.localizedCaseInsensitiveContains(searchText) ||
                veteran.emailPrimary.localizedCaseInsensitiveContains(searchText) ||
                veteran.veteranId.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select Veteran")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Choose a veteran to associate with this document")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Search Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search veterans...", text: $searchText)
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
            .padding(.vertical, 16)
            
            // Veterans List
            if filteredVeterans.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Veterans Found")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(searchText.isEmpty ? "No veterans in database" : "No veterans match your search")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredVeterans, id: \.id) { veteran in
                            VeteranSelectionRow(
                                veteran: veteran,
                                isSelected: selectedVeteran?.id == veteran.id
                            ) {
                                selectedVeteran = veteran
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            
            // Footer
            HStack {
                Spacer()
                
                Button("Select") {
                    if let veteran = selectedVeteran {
                        onVeteranSelected(veteran)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedVeteran == nil)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .top
            )
        }
    }
}

// MARK: - New Folder View
struct NewFolderView: View {
    let veteran: Veteran
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var folderName = ""
    @State private var folderDescription = ""
    @State private var isCreating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Folder")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("for \(veteran.fullName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter folder name", text: $folderName)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter folder description", text: $folderDescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .lineLimit(3...6)
                    }
                }
                .padding(20)
            }
            
            // Footer
            HStack {
                Spacer()
                
                Button("Create Folder") {
                    createFolder()
                }
                .buttonStyle(.borderedProminent)
                .disabled(folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .top
            )
        }
    }
    
    private func createFolder() {
        // Note: This is a placeholder for folder creation
        // In a real implementation, you would create a Folder model or use tags/categories
        // For now, we'll just show a success message and dismiss
        isCreating = true
        
        // TODO: Implement actual folder creation logic
        // This could involve:
        // 1. Creating a Folder model with name, description, veteran relationship
        // 2. Or using document tags/categories to organize documents
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCreating = false
            dismiss()
        }
    }
}

    #Preview {
        ContentView()
            .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
    }

