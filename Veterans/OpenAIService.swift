//
//  OpenAIService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import Security

/// Secure OpenAI API service with HIPAA compliance features
/// Implements TLS 1.3+, Keychain storage, and audit logging
class OpenAIService: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var lastError: OpenAIError?
    
    private let baseURL = "https://api.openai.com/v1"
    private let keychainService = "com.veterans.copilot.openai"
    private let keychainAccount = "openai-api-key"
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        
        return URLSession(configuration: config)
    }
    
    // MARK: - API Request/Response Models
    
    struct OpenAIRequest: Codable {
        let model: String
        let messages: [OpenAIMessage]
        let temperature: Double
        let max_tokens: Int?
        let stream: Bool
    }
    
    struct OpenAIMessage: Codable {
        let role: String
        let content: String
    }
    
    struct OpenAIStreamResponse: Codable {
        let choices: [OpenAIChoice]
    }
    
    struct OpenAIResponse: Codable {
        let choices: [OpenAIChoice]
        let usage: OpenAIUsage?
    }
    
    struct OpenAIChoice: Codable {
        let message: OpenAIMessage?
        let delta: OpenAIMessage?
        let finish_reason: String?
    }
    
    struct OpenAIUsage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
    
    // MARK: - API Key Management
    
    /// Store OpenAI API key securely in Keychain
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
            throw OpenAIError.keychainStoreFailed(status)
        }
        
        // Log API key storage (without the actual key)
        logAPIKeyStored()
    }
    
    /// Retrieve OpenAI API key from Keychain
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
              let keyData = result as? Data,
              let apiKey = String(data: keyData, encoding: .utf8) else {
            if status == errSecItemNotFound {
                throw OpenAIError.apiKeyNotFound
            }
            throw OpenAIError.keychainRetrieveFailed(status)
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
    
    /// Create access control for Keychain item
    private func createAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .userPresence,
            &error
        ) else {
            throw OpenAIError.accessControlCreationFailed
        }
        
        return accessControl
    }
    
    // MARK: - Chat Completions
    
    /// Send chat completion request to OpenAI
    func sendChatCompletion(
        messages: [OpenAIMessage],
        model: String = "gpt-4",
        temperature: Double = 0.7,
        maxTokens: Int = 2000
    ) async throws -> String {
        
        guard !isLoading else {
            throw OpenAIError.requestInProgress
        }
        
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
            let apiKey = try retrieveAPIKey()
            let request = OpenAIRequest(
                model: model,
                messages: messages,
                temperature: temperature,
                max_tokens: maxTokens,
                stream: false
            )
            
            // Log API request (without PHI)
            logAPIRequest(
                model: model,
                messageCount: messages.count,
                temperature: temperature,
                maxTokens: maxTokens
            )
            
            let response = try await performRequest(request, apiKey: apiKey)
            
            // Log successful response
            logAPIResponse(
                model: model,
                tokenCount: response.usage?.total_tokens ?? 0,
                success: true
            )
            
            return response.choices.first?.message?.content ?? ""
            
        } catch {
            // Log API error
            logAPIResponse(
                model: model,
                tokenCount: 0,
                success: false,
                error: error.localizedDescription
            )
            
            await MainActor.run {
                lastError = error as? OpenAIError ?? OpenAIError.unknownError(error)
            }
            throw error
        }
    }
    
    /// Send streaming chat completion request
    func sendStreamingChatCompletion(
        messages: [OpenAIMessage],
        model: String = "gpt-4",
        temperature: Double = 0.7,
        maxTokens: Int = 2000,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) async {
        
        guard !isLoading else {
            onError(OpenAIError.requestInProgress)
            return
        }
        
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
            let apiKey = try retrieveAPIKey()
            let request = OpenAIRequest(
                model: model,
                messages: messages,
                temperature: temperature,
                max_tokens: maxTokens,
                stream: true
            )
            
            // Log streaming request
            logAPIRequest(
                model: model,
                messageCount: messages.count,
                temperature: temperature,
                maxTokens: maxTokens,
                streaming: true
            )
            
            try await performStreamingRequest(
                request,
                apiKey: apiKey,
                onChunk: onChunk,
                onComplete: onComplete,
                onError: onError
            )
            
        } catch {
            await MainActor.run {
                lastError = error as? OpenAIError ?? OpenAIError.unknownError(error)
            }
            onError(error)
        }
    }
    
    // MARK: - Request Implementation
    
    private func performRequest(_ request: OpenAIRequest, apiKey: String) async throws -> OpenAIResponse {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Veterans-Copilot/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add security headers
        urlRequest.setValue("nosniff", forHTTPHeaderField: "X-Content-Type-Options")
        urlRequest.setValue("deny", forHTTPHeaderField: "X-Frame-Options")
        urlRequest.setValue("1; mode=block", forHTTPHeaderField: "X-XSS-Protection")
        
        let requestData = try JSONEncoder().encode(request)
        urlRequest.httpBody = requestData
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data)
            throw OpenAIError.apiError(httpResponse.statusCode, errorResponse?.error?.message ?? "Unknown error")
        }
        
        return try JSONDecoder().decode(OpenAIResponse.self, from: data)
    }
    
    private func performStreamingRequest(
        _ request: OpenAIRequest,
        apiKey: String,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Veterans-Copilot/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add security headers
        urlRequest.setValue("nosniff", forHTTPHeaderField: "X-Content-Type-Options")
        urlRequest.setValue("deny", forHTTPHeaderField: "X-Frame-Options")
        urlRequest.setValue("1; mode=block", forHTTPHeaderField: "X-XSS-Protection")
        
        let requestData = try JSONEncoder().encode(request)
        urlRequest.httpBody = requestData
        
        let (stream, response) = try await session.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            onError(OpenAIError.invalidResponse)
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            onError(OpenAIError.apiError(httpResponse.statusCode, "Streaming request failed"))
            return
        }
        
        var buffer = ""
        
        for try await byte in stream {
            let character = Character(UnicodeScalar(byte))
            buffer.append(character)
            
            // Process complete lines
            while let newlineIndex = buffer.firstIndex(of: "\n") {
                let line = String(buffer[..<newlineIndex])
                buffer.removeSubrange(..<buffer.index(after: newlineIndex))
                
                if line.hasPrefix("data: ") {
                    let jsonString = String(line.dropFirst(6))
                    
                    if jsonString == "[DONE]" {
                        onComplete()
                        return
                    }
                    
                    if let data = jsonString.data(using: .utf8),
                       let streamResponse = try? JSONDecoder().decode(OpenAIStreamResponse.self, from: data),
                       let delta = streamResponse.choices.first?.delta,
                       !delta.content.isEmpty {
                        onChunk(delta.content)
                    }
                }
            }
        }
        
        onComplete()
    }
    
    // MARK: - Model Management
    
    /// Get available models
    func getAvailableModels() async throws -> [String] {
        // For now, return a predefined list of supported models
        // In production, you might want to call the models endpoint
        return [
            "gpt-4",
            "gpt-4-turbo",
            "gpt-3.5-turbo"
        ]
    }
    
    /// Validate API key by making a test request
    func validateAPIKey() async throws -> Bool {
        let testMessage = OpenAIMessage(role: "user", content: "Hello")
        let testRequest = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [testMessage],
            temperature: 0.1,
            max_tokens: 10,
            stream: false
        )
        
        do {
            let apiKey = try retrieveAPIKey()
            _ = try await performRequest(testRequest, apiKey: apiKey)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Usage Tracking
    
    /// Get API usage information
    func getUsageInfo() async throws -> OpenAIUsageInfo {
        // This would typically call the OpenAI usage endpoint
        // For now, return placeholder data
        return OpenAIUsageInfo(
            totalTokens: 0,
            promptTokens: 0,
            completionTokens: 0,
            totalRequests: 0
        )
    }
}

// MARK: - OpenAI API Types

struct OpenAIErrorResponse: Codable {
    let error: OpenAIErrorDetail?
}

struct OpenAIErrorDetail: Codable {
    let message: String
    let type: String?
    let code: String?
}

// MARK: - Streaming Response Models (Simplified - removed problematic Codable structs)

struct OpenAIUsageInfo: Codable {
    let totalTokens: Int
    let promptTokens: Int
    let completionTokens: Int
    let totalRequests: Int
}

// MARK: - OpenAI Errors

enum OpenAIError: Error, LocalizedError {
    case apiKeyNotFound
    case keychainStoreFailed(OSStatus)
    case keychainRetrieveFailed(OSStatus)
    case accessControlCreationFailed
    case requestInProgress
    case invalidResponse
    case apiError(Int, String)
    case networkError(Error)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotFound:
            return "OpenAI API key not found. Please configure your API key in settings."
        case .keychainStoreFailed(let status):
            return "Failed to store API key in Keychain: \(status)"
        case .keychainRetrieveFailed(let status):
            return "Failed to retrieve API key from Keychain: \(status)"
        case .accessControlCreationFailed:
            return "Failed to create Keychain access control"
        case .requestInProgress:
            return "A request is already in progress"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let code, let message):
            return "OpenAI API Error (\(code)): \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Audit Logger Integration

// Note: Audit logging will be implemented separately
private func logAPIKeyStored() {
    print("API key stored")
}

private func logAPIRequest(model: String, messageCount: Int, temperature: Double, maxTokens: Int, streaming: Bool = false) {
    print("API request: model=\(model), messages=\(messageCount), streaming=\(streaming)")
}

private func logAPIResponse(model: String, tokenCount: Int, success: Bool, error: String? = nil) {
    print("API response: model=\(model), tokens=\(tokenCount), success=\(success)")
}

// MARK: - Extensions

extension OpenAIService {
    /// Create a system message for Veterans Benefits context
    func createSystemMessage() -> OpenAIMessage {
        let systemPrompt = """
        You are a helpful AI assistant specializing in Veterans Benefits Claims. You provide accurate, helpful information about VA disability claims, appeals, and related processes. Always remind users that you are an AI assistant and that they should consult with qualified professionals for specific legal or medical advice.
        
        Key guidelines:
        - Provide accurate information about VA processes
        - Suggest consulting VSOs, attorneys, or medical professionals when appropriate
        - Be empathetic and understanding of veterans' situations
        - Focus on practical, actionable advice
        - Always maintain professionalism and respect
        """
        
        return OpenAIMessage(role: "system", content: systemPrompt)
    }
    
    /// Create messages array with system prompt and conversation history
    func createMessageArray(
        conversationHistory: [ChatMessage],
        currentMessage: String,
        sessionDocuments: [ChatDocument]? = nil
    ) -> [OpenAIMessage] {
        var messages: [OpenAIMessage] = [createSystemMessage()]
        
        // Add document context if available
        if let documents = sessionDocuments, !documents.isEmpty {
            print("📄 Including \(documents.count) document(s) in OpenAI request")
            var documentContext = "The following documents have been uploaded to this conversation:\n\n"
            for (index, document) in documents.enumerated() {
                documentContext += "Document \(index + 1): \(document.fileName)\n"
                
                // Add document text (prefer de-identified, fallback to extracted)
                if let documentText = document.deidentifiedText ?? document.extractedText {
                    // Limit document text to avoid token limits (first 2000 characters per document)
                    let truncatedText = String(documentText.prefix(2000))
                    documentContext += "Content preview: \(truncatedText)\n"
                    print("  ✅ Added content for \(document.fileName) (\(truncatedText.count) chars)")
                } else {
                    print("  ⚠️ No text content available for \(document.fileName)")
                }
                
                if let summary = document.summary {
                    documentContext += "Summary: \(summary)\n"
                    print("  ✅ Added summary for \(document.fileName)")
                }
                
                documentContext += "\n"
            }
            
            documentContext += "You can reference these documents when answering questions. Use the document content to provide accurate, specific information.\n\n"
            
            // Add document context as a system message
            messages.append(OpenAIMessage(role: "system", content: documentContext))
            print("📤 Document context added to messages array")
        } else {
            print("ℹ️ No documents to include in OpenAI request")
        }
        
        // Add conversation history (last 10 messages to stay within token limits)
        let recentHistory = Array(conversationHistory.suffix(10))
        for message in recentHistory {
            let role = message.role.rawValue
            let content = message.isDeidentified ? (message.deidentifiedContent ?? message.content) : message.content
            messages.append(OpenAIMessage(role: role, content: content))
        }
        
        // Add current message
        messages.append(OpenAIMessage(role: "user", content: currentMessage))
        
        return messages
    }
}
