import SwiftUI
import SwiftData

// MARK: - Navigation Section
enum NavigationSection: String, CaseIterable {
    case dashboard = "Dashboard"
    case veterans = "Veterans"
    case claims = "Claims"
    case kanban = "Kanban Board"
    case documents = "Documents"
    case copilot = "Copilot"
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .veterans: return "person.3.fill"
        case .claims: return "doc.text.fill"
        case .kanban: return "rectangle.3.group.fill"
        case .documents: return "folder.fill"
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
    @State private var navigationPath = NavigationPath()
    
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
                    .navigationDestination(for: Claim.self) { claim in
                        ClaimDetailView(claim: claim)
                    }
            }
        }
        .sheet(isPresented: $showingAddVeteran) {
            AddVeteranView()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
        }
        .sheet(isPresented: $showingAddClaim) {
            // For now, we'll need to select a veteran first
            Text("Please select a veteran first")
                .frame(minWidth: 400, minHeight: 200)
        }
        .sheet(isPresented: $showingDocumentUpload) {
            // For now, we'll need to select a veteran first
            Text("Please select a veteran first")
                .frame(minWidth: 400, minHeight: 200)
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
    }
    
    private var sidebarView: some View {
            VStack(spacing: 0) {
            // Header
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Veterans Claims")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Foundation CRM")
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
                            
                            Button(action: { showingAddClaim = true }) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.green)
                                    .frame(width: 36, height: 36)
                                    .background(.green.opacity(0.1), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { showingDocumentUpload = true }) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .frame(width: 36, height: 36)
                                    .background(.orange.opacity(0.1), in: Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
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
                        NavigationLink(value: claim) {
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
        .sheet(isPresented: $showingClaimDetail) {
            if let claim = selectedClaim {
                ClaimDetailView(claim: claim)
                    .frame(minWidth: 1000, idealWidth: 1200, maxWidth: 1400)
                    .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
            }
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
        
        var body: some View {
        VStack(spacing: 0) {
            // Header
                HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Documents")
                        .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                    Text("No documents uploaded yet")
                        .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
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
            
            // Empty State
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
    
    #Preview {
        ContentView()
            .modelContainer(for: [Veteran.self, Claim.self, Document.self, ClaimActivity.self], inMemory: true)
}

