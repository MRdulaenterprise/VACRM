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
    private let keychainAccount = "vagov-api-key"
    
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
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        
        return URLSession(configuration: config)
    }
    
    // MARK: - API Key Management
    
    /// Store VA.GOV API key securely in Keychain
    func storeAPIKey(_ apiKey: String) throws {
        let keyData = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: keyData
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw VAGovError.keychainStoreFailed(status)
        }
        
        // Log API key storage (without the actual key)
        logAPIKeyStored()
    }
    
    /// Retrieve VA.GOV API key from Keychain
    func retrieveAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
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
    
    /// Check if API key is stored
    func hasAPIKey() -> Bool {
        do {
            _ = try retrieveAPIKey()
            return true
        } catch {
            return false
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
        queryParams: [String: String] = [:]
    ) async throws -> T {
        
        guard hasAPIKey() else {
            throw VAGovError.noAPIKey
        }
        
        let apiKey = try retrieveAPIKey()
        
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")!
        
        if !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw VAGovError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Veterans-CRM/1.0", forHTTPHeaderField: "User-Agent")
        
        await MainActor.run {
            isLoading = true
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VAGovError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
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
        } catch {
            let vaGovError = VAGovError.networkError(error)
            await MainActor.run {
                lastError = vaGovError
            }
            throw vaGovError
        }
    }
    
    // MARK: - VA Forms API
    
    /// Get all VA forms
    func getAllForms() async throws -> VAFormsResponse {
        return try await makeRequest(
            endpoint: "/services/va_forms/v0/forms",
            responseType: VAFormsResponse.self
        )
    }
    
    /// Get specific form by name
    func getForm(byName formName: String) async throws -> VAFormResponse {
        return try await makeRequest(
            endpoint: "/services/va_forms/v0/forms/\(formName)",
            responseType: VAFormResponse.self
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
    
    // MARK: - Test Connection
    
    /// Test API connection with current configuration
    func testConnection() async throws -> Bool {
        do {
            // Use a simple endpoint to test connection
            _ = try await getStates()
            return true
        } catch {
            throw error
        }
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
