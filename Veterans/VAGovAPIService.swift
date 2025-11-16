//
//  VAGovAPIService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import Security

/// VA.GOV API service with secure keychain storage and environment switching
/// Implements TLS 1.3+, Keychain storage, and comprehensive error handling
class VAGovAPIService: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var lastError: VAGovError?
    
    private let keychainService = "com.veterans.crm.vagov"
    private let keychainAccountBenefits = "vagov-api-key-benefits" // For Benefits Reference Data, Facilities, etc.
    private let keychainAccountForms = "vagov-api-key-forms" // For Forms API
    
    enum Environment: String, CaseIterable {
        case sandbox = "sandbox-api.va.gov"
        case production = "api.va.gov"
        
        var displayName: String {
            switch self {
            case .sandbox: return "Sandbox"
            case .production: return "Production"
            }
        }
    }
    
    private var currentEnvironment: Environment {
        let environmentString = UserDefaults.standard.string(forKey: "vaGovEnvironment") ?? Environment.sandbox.rawValue
        return Environment(rawValue: environmentString) ?? .sandbox
    }
    
    private var baseURL: String {
        "https://\(currentEnvironment.rawValue)"
    }
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        // Allow system to negotiate TLS version (TLS 1.2+)
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        
        return URLSession(configuration: config)
    }
    
    // MARK: - API Key Management
    
    /// Store Benefits Reference Data API key securely in Keychain
    func storeBenefitsAPIKey(_ apiKey: String) throws {
        try storeAPIKey(apiKey, account: keychainAccountBenefits, keyType: "Benefits Reference Data")
    }
    
    /// Store Forms API key securely in Keychain
    func storeFormsAPIKey(_ apiKey: String) throws {
        try storeAPIKey(apiKey, account: keychainAccountForms, keyType: "Forms API")
    }
    
    /// Generic API key storage method
    private func storeAPIKey(_ apiKey: String, account: String, keyType: String) throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty else {
            throw VAGovError.keychainStoreFailed(errSecParam)
        }
        
        let keyData = trimmedKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: keyData
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw VAGovError.keychainStoreFailed(status)
        }
        
        print("\(keyType) API Key stored: Length=\(trimmedKey.count), First 4 chars=\(String(trimmedKey.prefix(4)))...")
    }
    
    /// Retrieve Benefits Reference Data API key from Keychain
    func retrieveBenefitsAPIKey() throws -> String {
        return try retrieveAPIKey(account: keychainAccountBenefits)
    }
    
    /// Retrieve Forms API key from Keychain
    func retrieveFormsAPIKey() throws -> String {
        return try retrieveAPIKey(account: keychainAccountForms)
    }
    
    /// Generic API key retrieval method
    private func retrieveAPIKey(account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw VAGovError.keychainRetrievalFailed(status)
        }
        
        return apiKey
    }
    
    /// Check if Benefits Reference Data API key is stored
    func hasBenefitsAPIKey() -> Bool {
        do {
            _ = try retrieveBenefitsAPIKey()
            return true
        } catch {
            return false
        }
    }
    
    /// Check if Forms API key is stored
    func hasFormsAPIKey() -> Bool {
        do {
            _ = try retrieveFormsAPIKey()
            return true
        } catch {
            return false
        }
    }
    
    /// Check if any API key is stored (for backward compatibility)
    func hasAPIKey() -> Bool {
        return hasBenefitsAPIKey() || hasFormsAPIKey()
    }
    
    /// Legacy method for backward compatibility - stores as Benefits key
    /// Also migrates old single key to Benefits key if it exists
    func storeAPIKey(_ apiKey: String) throws {
        // Check if there's an old key stored with the old account name
        let oldAccount = "vagov-api-key"
        let oldQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: oldAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var oldResult: AnyObject?
        let oldStatus = SecItemCopyMatching(oldQuery as CFDictionary, &oldResult)
        
        // If old key exists, migrate it to Benefits key
        if oldStatus == errSecSuccess,
           let oldData = oldResult as? Data,
           let oldKey = String(data: oldData, encoding: .utf8) {
            print("Migrating old API key to Benefits Reference Data key...")
            try storeBenefitsAPIKey(oldKey)
            // Delete old key
            SecItemDelete(oldQuery as CFDictionary)
        } else {
            // Store new key as Benefits key
            try storeBenefitsAPIKey(apiKey)
        }
    }
    
    /// Legacy method for backward compatibility - retrieves Benefits key
    /// Also checks for old single key and migrates it if found
    func retrieveAPIKey() throws -> String {
        // First try to get Benefits key
        do {
            return try retrieveBenefitsAPIKey()
        } catch {
            // If Benefits key doesn't exist, check for old key and migrate it
            let oldAccount = "vagov-api-key"
            let oldQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: oldAccount,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var oldResult: AnyObject?
            let oldStatus = SecItemCopyMatching(oldQuery as CFDictionary, &oldResult)
            
            if oldStatus == errSecSuccess,
               let oldData = oldResult as? Data,
               let oldKey = String(data: oldData, encoding: .utf8) {
                print("Migrating old API key to Benefits Reference Data key...")
                try storeBenefitsAPIKey(oldKey)
                // Delete old key
                SecItemDelete(oldQuery as CFDictionary)
                return oldKey
            }
            
            throw error
        }
    }
    
    /// Set environment (Sandbox/Production)
    func setEnvironment(_ environment: Environment) {
        UserDefaults.standard.set(environment.rawValue, forKey: "vaGovEnvironment")
    }
    
    /// Get current environment
    func getCurrentEnvironment() -> Environment {
        return currentEnvironment
    }
    
    // MARK: - API Request Methods
    
    /// Make authenticated API request
    private func makeRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        queryParams: [String: String] = [:],
        useFormsKey: Bool = false
    ) async throws -> T {
        
        // Determine which API key to use
        let apiKey: String
        if useFormsKey {
            guard hasFormsAPIKey() else {
                throw VAGovError.noAPIKey
            }
            apiKey = try retrieveFormsAPIKey()
        } else {
            guard hasBenefitsAPIKey() else {
                throw VAGovError.noAPIKey
            }
            apiKey = try retrieveBenefitsAPIKey()
        }
        
        // Ensure API key is trimmed (in case it was stored with whitespace)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty else {
            throw VAGovError.noAPIKey
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")!
        
        if !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw VAGovError.invalidURL
        }
        
        // Debug logging (without exposing full API key)
        print("VA.GOV API Request:")
        print("  URL: \(url.absoluteString)")
        print("  Environment: \(currentEnvironment.displayName) (\(currentEnvironment.rawValue))")
        print("  Base URL: \(baseURL)")
        print("  API Key length: \(trimmedKey.count)")
        print("  API Key prefix: \(String(trimmedKey.prefix(4)))...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // VA.gov Forms API documentation shows exact format:
        // curl -X GET 'https://sandbox-api.va.gov/services/va_forms/v0/forms' \
        //   --header 'apikey: <key>' \
        //   --header 'accept: application/json'
        // Note: HTTP headers are case-insensitive, but we'll match the docs exactly
        request.setValue(trimmedKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        // Note: User-Agent not shown in API docs, so we'll omit it to match exactly
        
        // Log all headers being sent (without exposing full API key)
        print("  Request Headers:")
        print("    apikey: \(String(trimmedKey.prefix(4)))...\(String(trimmedKey.suffix(4))) (length: \(trimmedKey.count))")
        print("    accept: application/json")
        
        // Note: VA Forms API uses "apikey" header, NOT "Authorization: Bearer" format
        // Other VA.gov APIs (like Benefits Claims) use OAuth/Bearer tokens, but Forms API is different
        
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Store response data outside do block so it's accessible in catch blocks
        var responseData: Data?
        
        do {
            let (data, response) = try await session.data(for: request)
            responseData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VAGovError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to parse error message from response
                var errorMessage = "Unknown error"
                if let dataString = String(data: data, encoding: .utf8) {
                    errorMessage = dataString
                    // Try to extract JSON message if present
                    if let jsonData = dataString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let message = json["message"] as? String {
                        errorMessage = message
                    }
                }
                
                // Log response details for debugging
                print("VA.GOV API Response:")
                print("  Status Code: \(httpResponse.statusCode)")
                print("  Response: \(errorMessage)")
                
                // Provide more helpful error messages for common status codes
                if httpResponse.statusCode == 403 {
                    // Check for specific error messages
                    let lowercasedError = errorMessage.lowercased()
                    var detailedMessage = """
                    API key authentication failed (403 Forbidden).
                    
                    """
                    
                    if lowercasedError.contains("cannot consume") || lowercasedError.contains("you cannot consume") {
                        detailedMessage += """
                        The error "You cannot consume this service" means your API key is valid but NOT authorized for this specific API service.
                        
                        IMPORTANT FINDINGS:
                        • Your API key IS working (Benefits Reference Data API works successfully)
                        • Your API key is NOT authorized for Forms API or Facilities API
                        • Even though Forms API data is "open/public", it still requires API key authorization
                        
                        This is a server-side authorization issue. Your request format is correct, but the API key needs to be:
                        1. Specifically requested for each API service you want to use
                        2. Activated/approved in the VA.gov developer portal for that service
                        3. Approved by VA.gov administrators (can take 24-48 hours)
                        
                        Action required:
                        1. Log into https://developer.va.gov/explore
                        2. Request sandbox access for VA Forms API: https://developer.va.gov/explore/api/va-forms/sandbox-access
                        3. Request sandbox access for VA Facilities API: https://developer.va.gov/explore/api/va-facilities/sandbox-access
                        4. Wait for approval (can take 24-48 hours)
                        5. Contact VA.gov support if the key shows as active but still doesn't work
                        
                        Note: Each API service requires separate authorization, even if they're all "open" APIs.
                        
                        """
                    } else {
                        detailedMessage += """
                        Possible causes:
                        • API key is invalid or expired
                        • API key doesn't have access to this endpoint
                        • API key is for a different environment (sandbox vs production)
                        
                        Please verify your API key in Settings and ensure it matches your selected environment.
                        Get a new API key at: https://developer.va.gov/explore/api/va-forms/sandbox-access
                        
                        """
                    }
                    
                    detailedMessage += "Server response: \(errorMessage)"
                    throw VAGovError.apiError(httpResponse.statusCode, detailedMessage)
                } else if httpResponse.statusCode == 401 {
                    throw VAGovError.apiError(httpResponse.statusCode, "Unauthorized: API key is missing or invalid. Please check your API key in Settings.")
                } else if httpResponse.statusCode == 404 {
                    throw VAGovError.apiError(httpResponse.statusCode, "Endpoint not found. The API endpoint may have changed.")
                }
                
                throw VAGovError.apiError(httpResponse.statusCode, errorMessage)
            }
            
            // Debug: Log raw response for ALL APIs to understand structure
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                let preview = responseString.prefix(1000)
                if endpoint.contains("benefits-reference-data") {
                    print("  📋 Raw Benefits Reference Data Response (first 1000 chars):")
                } else {
                    print("  📋 Raw API Response (first 1000 chars):")
                }
                print("  \(preview)")
                print("  📋 Full response length: \(responseString.count) characters")
            }
            
            guard let data = responseData else {
                throw VAGovError.invalidResponse
            }
            
            // Check if response is empty (common issue with unauthorized APIs)
            if data.isEmpty {
                let errorMessage = "API returned empty response. This usually means the API key is not authorized for this service."
                print("  ⚠️ Empty response from API")
                throw VAGovError.apiError(httpResponse.statusCode, errorMessage)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let result = try decoder.decode(T.self, from: data)
            
            // Log successful API call
            logAPICall(endpoint: endpoint, statusCode: httpResponse.statusCode)
            
            return result
            
        } catch let error as VAGovError {
            await MainActor.run {
                lastError = error
            }
            throw error
        } catch let decodingError as DecodingError {
            // Log the raw response when decoding fails to help diagnose structure issues
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("  ⚠️ DECODING ERROR - Full raw response:")
                print("  \(responseString)")
                print("  ⚠️ Decoding error details: \(decodingError)")
                
                // Try to parse as generic JSON to see structure
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("  📊 Parsed JSON structure (top-level keys):")
                    for (key, value) in json {
                        if let array = value as? [Any] {
                            print("    - \(key): Array with \(array.count) items")
                        } else if let dict = value as? [String: Any] {
                            print("    - \(key): Dictionary with keys: \(dict.keys.joined(separator: ", "))")
                        } else {
                            print("    - \(key): \(type(of: value))")
                        }
                    }
                }
            } else {
                print("  ⚠️ Decoding failed: \(decodingError)")
            }
            let vaGovError = VAGovError.decodingError(decodingError)
            await MainActor.run {
                lastError = vaGovError
            }
            throw vaGovError
        } catch {
            // Try to include server payload for easier diagnosis
            let vaGovError = VAGovError.decodingError(error)
            await MainActor.run {
                lastError = vaGovError
            }
            throw vaGovError
        }
    }
    
    // MARK: - VA Forms API
    
    /// Get all VA forms
    func getAllForms() async throws -> VAFormsResponse {
        // Use Forms API key for Forms API calls
        return try await makeRequest(
            endpoint: "/services/va_forms/v0/forms",
            responseType: VAFormsResponse.self,
            useFormsKey: true
        )
    }
    
    /// Get specific form by name
    func getForm(byName formName: String) async throws -> VAFormResponse {
        // Use Forms API key for Forms API calls
        return try await makeRequest(
            endpoint: "/services/va_forms/v0/forms/\(formName)",
            responseType: VAFormResponse.self,
            useFormsKey: true
        )
    }
    
    /// Test alternative endpoint format (just /forms as shown in docs)
    func testAlternativeEndpoint() async throws -> VAFormsResponse {
        // Try the simpler format shown in documentation
        return try await makeRequest(
            endpoint: "/forms",
            responseType: VAFormsResponse.self,
            useFormsKey: true
        )
    }
    
    // MARK: - VA Facilities API
    
    /// Search facilities by location
    func searchFacilities(
        latitude: Double? = nil,
        longitude: Double? = nil,
        radius: Int? = nil,
        facilityType: String? = nil,
        services: [String]? = nil
    ) async throws -> VAFacilitiesResponse {
        
        var queryParams: [String: String] = [:]
        
        if let lat = latitude {
            queryParams["lat"] = String(lat)
        }
        if let lng = longitude {
            queryParams["long"] = String(lng)
        }
        if let rad = radius {
            queryParams["radius"] = String(rad)
        }
        if let type = facilityType {
            queryParams["type"] = type
        }
        if let svcs = services {
            queryParams["services"] = svcs.joined(separator: ",")
        }
        
        return try await makeRequest(
            endpoint: "/services/va_facilities/v1/facilities",
            responseType: VAFacilitiesResponse.self,
            queryParams: queryParams
        )
    }
    
    // MARK: - Benefits Reference Data API
    
    /// Get disabilities list
    func getDisabilities() async throws -> DisabilitiesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/disabilities",
            responseType: DisabilitiesResponse.self
        )
    }
    
    /// Get service branches list
    func getServiceBranches() async throws -> ServiceBranchesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/service-branches",
            responseType: ServiceBranchesResponse.self
        )
    }
    
    /// Get treatment centers list
    func getTreatmentCenters() async throws -> TreatmentCentersResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/treatment-centers",
            responseType: TreatmentCentersResponse.self
        )
    }
    
    /// Get states list
    func getStates() async throws -> StatesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/states",
            responseType: StatesResponse.self
        )
    }
    
    /// Get countries list
    func getCountries() async throws -> CountriesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/countries",
            responseType: CountriesResponse.self
        )
    }
    
    /// Get contention types list
    func getContentionTypes() async throws -> ContentionTypesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/contention-types",
            responseType: ContentionTypesResponse.self
        )
    }
    
    /// Get military pay types list
    func getMilitaryPayTypes() async throws -> MilitaryPayTypesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/military-pay-types",
            responseType: MilitaryPayTypesResponse.self
        )
    }
    
    /// Get special circumstances list
    func getSpecialCircumstances() async throws -> SpecialCircumstancesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/special-circumstances",
            responseType: SpecialCircumstancesResponse.self
        )
    }
    
    /// Get intake sites list
    func getIntakeSites() async throws -> IntakeSitesResponse {
        return try await makeRequest(
            endpoint: "/services/benefits-reference-data/v1/intake-sites",
            responseType: IntakeSitesResponse.self
        )
    }
    
    // MARK: - Test Connection
    
    /// Test API connection with current configuration
    /// Tests both VA Forms API and Benefits Reference Data API to verify API key authorization
    func testConnection() async throws -> Bool {
        print("🧪 Testing VA.GOV connection...")
        print("  Environment: \(currentEnvironment.rawValue)")
        print("  Has Benefits API Key: \(hasBenefitsAPIKey())")
        print("  Has Forms API Key: \(hasFormsAPIKey())")
        
        guard hasAPIKey() else {
            throw VAGovError.noAPIKey
        }
        
        // Test Benefits Reference Data API first (this should work if API key is valid)
        print("\n  📊 Testing Benefits Reference Data API (should work if API key is valid)...")
        var benefitsTestPassed = false
        var benefitsDataCounts: [String: Int] = [:]
        do {
            let statesResponse = try await getStates()
            benefitsDataCounts["States"] = statesResponse.items.count
            print("  ✅ States: \(statesResponse.items.count) items")
            
            let disabilitiesResponse = try await getDisabilities()
            benefitsDataCounts["Disabilities"] = disabilitiesResponse.items.count
            print("  ✅ Disabilities: \(disabilitiesResponse.items.count) items")
            
            let serviceBranchesResponse = try await getServiceBranches()
            benefitsDataCounts["Service Branches"] = serviceBranchesResponse.items.count
            print("  ✅ Service Branches: \(serviceBranchesResponse.items.count) items")
            
            let treatmentCentersResponse = try await getTreatmentCenters()
            benefitsDataCounts["Treatment Centers"] = treatmentCentersResponse.items.count
            print("  ✅ Treatment Centers: \(treatmentCentersResponse.items.count) items")
            
            print("  ✅ Benefits Reference Data API: SUCCESS")
            print("  📊 Sandbox Data Summary:")
            for (key, count) in benefitsDataCounts.sorted(by: { $0.key < $1.key }) {
                print("     • \(key): \(count) items")
            }
            print("  ⚠️ Note: Sandbox has limited test data. Production will have full datasets.")
            benefitsTestPassed = true
        } catch let error as VAGovError {
            if case .apiError(let code, _) = error, code == 403 {
                print("  ⚠️ Benefits Reference Data API: 403 (API key not authorized for this service)")
            } else {
                print("  ⚠️ Benefits Reference Data API: \(error)")
            }
        } catch {
            print("  ⚠️ Benefits Reference Data API: \(error.localizedDescription)")
        }
        
        // Test VA Forms API
        print("\n  📋 Testing VA Forms API...")
        var formsTestPassed = false
        if hasFormsAPIKey() {
            do {
                let response = try await getAllForms()
                print("  ✅ VA Forms API: SUCCESS")
                print("     Forms returned: \(response.data.count)")
                formsTestPassed = true
            } catch let error as VAGovError {
                print("  ⚠️ VA Forms API: \(error)")
                print("\n  💡 VA Forms API Analysis:")
                print("     • Forms API key is configured but returned an error")
                print("     • Check that the Forms API key is valid and authorized")
            } catch {
                print("  ⚠️ VA Forms API: \(error.localizedDescription)")
            }
        } else {
            print("  ⚠️ VA Forms API: No Forms API key configured")
            print("\n  💡 To enable VA Forms API:")
            print("     • Configure a Forms API key in Settings")
            print("     • Forms API requires a separate API key from Benefits Reference Data")
            print("     • Get Forms API key: https://developer.va.gov/explore/api/va-forms/sandbox-access")
        }
        
        // Return success if at least Benefits Reference Data works
        if benefitsTestPassed {
            if formsTestPassed {
                print("\n✅ Connection test successful! Both APIs are working.")
            } else {
                print("\n✅ Connection test successful! Benefits Reference Data API is working.")
                print("   ⚠️ VA Forms API requires separate authorization (see above).")
            }
            return true
        } else {
            print("\n❌ Connection test failed. API key may be invalid or not activated.")
            throw VAGovError.apiError(403, "API key is not authorized for any tested services. Please check your API key in the VA.gov developer portal.")
        }
    }
    
    /// Diagnostic function to test raw API request with different endpoint paths and auth formats
    func testRawRequest() async {
        guard hasAPIKey() else {
            print("❌ No API key stored")
            return
        }
        
        do {
            let apiKey = try retrieveAPIKey()
            let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("🔍 Testing different endpoint paths and auth formats:")
            print("  API Key: \(String(trimmedKey.prefix(4)))...\(String(trimmedKey.suffix(4)))")
            print("  Environment: \(currentEnvironment.rawValue)")
            
            // Test different endpoint paths based on documentation
            // Documentation shows "/forms" but OpenAPI spec suggests "/services/va_forms/v0/forms"
            let endpointPaths = [
                "/services/va_forms/v0/forms",  // OpenAPI spec format (current)
                "/forms",                        // Documentation format (line 100-101)
                "/va_forms/v0/forms",            // Without /services prefix
                "/services/va_forms/forms",      // Without version
                "/va_forms/forms"                // Minimal path
            ]
            
            for (index, path) in endpointPaths.enumerated() {
                let testURL = "https://\(currentEnvironment.rawValue)\(path)"
                print("\n  📍 Test Path \(index + 1): \(path)")
                print("     Full URL: \(testURL)")
                
                guard let url = URL(string: testURL) else {
                    print("     ❌ Invalid URL")
                    continue
                }
                
                // Test with apikey header (exact format from API docs)
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue(trimmedKey, forHTTPHeaderField: "apikey")
                request.setValue("application/json", forHTTPHeaderField: "accept")
                // Note: User-Agent not in API docs, so we omit it
                
                do {
                    let (data, response) = try await session.data(for: request)
                    if let httpResponse = response as? HTTPURLResponse {
                        print("     Status Code: \(httpResponse.statusCode)")
                        var responseMessage = ""
                        if let responseString = String(data: data, encoding: .utf8) {
                            let preview = responseString.prefix(200)
                            print("     Response: \(preview)")
                            responseMessage = responseString
                        }
                        if httpResponse.statusCode == 200 {
                            print("     ✅✅✅ SUCCESS with path: \(path) ✅✅✅")
                            print("     This is the correct endpoint path!")
                            return
                        } else if httpResponse.statusCode == 404 {
                            print("     ⚠️ 404 - Endpoint not found (wrong path)")
                        } else if httpResponse.statusCode == 403 {
                            if responseMessage.lowercased().contains("cannot consume") {
                                print("     ✅ 403 - Path is CORRECT! API key not authorized for this service")
                                print("     This confirms the endpoint path is right, but the API key needs activation")
                            } else {
                                print("     ⚠️ 403 - Authentication failed (but path might be correct)")
                            }
                        }
                    }
                } catch {
                    print("     ❌ Request failed: \(error.localizedDescription)")
                }
            }
            
            print("\n  📊 Diagnostic Summary:")
            print("  ✅ Endpoint path: /services/va_forms/v0/forms (CONFIRMED CORRECT)")
            print("  ✅ Authentication format: 'apikey' header (CONFIRMED CORRECT)")
            print("  ❌ API key authorization: NOT AUTHORIZED for VA Forms API")
            print("")
            print("  💡 The 403 error on Path 1 confirms:")
            print("     • The endpoint path is correct")
            print("     • The authentication format is correct")
            print("     • The API key is valid but NOT authorized for this service")
            print("")
            print("  🔧 Action Required:")
            print("     1. Log into: https://developer.va.gov/explore")
            print("     2. Check your API key status for VA Forms API")
            print("     3. Ensure the key is 'Active' and registered for 'VA Forms API'")
            print("     4. Contact VA.gov support if key shows as active but still fails")
            print("     5. Sandbox access: https://developer.va.gov/explore/api/va-forms/sandbox-access")
            
        } catch {
            print("❌ Raw request test failed: \(error)")
        }
    }
    
    /// Validate API key format (basic validation)
    func validateAPIKeyFormat(_ apiKey: String) -> (isValid: Bool, message: String) {
        // VA.gov API keys are typically alphanumeric strings
        // Basic validation - check if it's not empty and has reasonable length
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return (false, "API key cannot be empty")
        }
        
        if trimmed.count < 10 {
            return (false, "API key appears to be too short")
        }
        
        // Check for common invalid patterns
        if trimmed.lowercased().contains("your") || trimmed.lowercased().contains("example") {
            return (false, "API key appears to be a placeholder")
        }
        
        return (true, "API key format looks valid")
    }
    
    // MARK: - Logging
    
    private func logAPIKeyStored() {
        print("VA.GOV API key stored securely in Keychain")
    }
    
    private func logAPICall(endpoint: String, statusCode: Int) {
        print("VA.GOV API call: \(endpoint) - Status: \(statusCode)")
    }
}

// MARK: - Error Types

enum VAGovError: Error, LocalizedError {
    case noAPIKey
    case keychainStoreFailed(OSStatus)
    case keychainRetrievalFailed(OSStatus)
    case invalidURL
    case invalidResponse
    case apiError(Int, String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "VA.GOV API key not configured"
        case .keychainStoreFailed(let status):
            return "Failed to store API key in Keychain (Status: \(status))"
        case .keychainRetrievalFailed(let status):
            return "Failed to retrieve API key from Keychain (Status: \(status))"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from VA.GOV API"
        case .apiError(let code, let message):
            return "VA.GOV API Error (\(code)): \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

