import Foundation
import SwiftUI
import Security

// MARK: - PaulBox Email Service
class PaulBoxEmailService: ObservableObject {
    static let shared = PaulBoxEmailService()
    
    // MARK: - Configuration
    private let baseURL = "https://api.paubox.net/v1/mrdula"
    
    private var apiKey: String {
        // Try to get from Keychain first, fallback to hardcoded for development
        return PaulBoxEmailService.loadAPIKeyFromKeychain() ?? "6a647f9fa6c84cfb93fa51898b3bf9c50cf1acea"
    }
    
    private var fromEmail: String {
        return UserDefaults.standard.string(forKey: "emailFromAddress") ?? "matt@mrdula.co"
    }
    
    private var domain: String {
        return UserDefaults.standard.string(forKey: "emailDomain") ?? "mrdula.co"
    }
    
    // MARK: - Rate Limiting
    private var lastSentTime: Date?
    private let rateLimitDelay: TimeInterval = 0.12 // 500 messages per minute
    
    // MARK: - Keychain Methods
    private static func loadAPIKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "PaulBoxAPIKey",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
    
    // MARK: - Email Models
    
    struct EmailRequest: Codable {
        let data: EmailData
        
        struct EmailData: Codable {
            let message: Message
            
            struct Message: Codable {
                let recipients: [String]
                let headers: Headers
                let content: Content?
                let attachments: [Attachment]?
                
                struct Headers: Codable {
                    let subject: String
                    let from: String
                    let replyTo: String?
                    
                    enum CodingKeys: String, CodingKey {
                        case subject, from
                        case replyTo = "reply-to"
                    }
                }
                
                struct Content: Codable {
                    let textPlain: String?
                    let textHtml: String?
                    
                    enum CodingKeys: String, CodingKey {
                        case textPlain = "text/plain"
                        case textHtml = "text/html"
                    }
                }
                
                struct Attachment: Codable {
                    let fileName: String
                    let contentType: String
                    let content: String // Base64-encoded content
                }
            }
        }
    }
    
    struct EmailResponse: Codable {
        let sourceTrackingId: String
        let data: String
        let customHeaders: [String: String]?
        
        enum CodingKeys: String, CodingKey {
            case sourceTrackingId
            case data
            case customHeaders
        }
    }
    
    struct EmailError: Codable {
        let errors: [ErrorDetail]
        
        struct ErrorDetail: Codable {
            let title: String
            let detail: String
        }
    }
    
    // MARK: - Test Connection Method
    func testConnection() async throws -> Bool {
        let url = URL(string: "\(baseURL)/messages")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create a minimal test request
        let testRequest = EmailRequest(
            data: EmailRequest.EmailData(
                message: EmailRequest.EmailData.Message(
                    recipients: [fromEmail],
                    headers: EmailRequest.EmailData.Message.Headers(
                        subject: "Test Connection",
                        from: fromEmail,
                        replyTo: nil
                    ),
                    content: EmailRequest.EmailData.Message.Content(
                        textPlain: "Test email",
                        textHtml: "<p>Test email</p>"
                    ),
                    attachments: nil
                )
            )
        )
        
        do {
            let jsonData = try JSONEncoder().encode(testRequest)
            urlRequest.httpBody = jsonData
            
            print("PaulBoxEmailService: Testing connection...")
            print("PaulBoxEmailService: Request URL: \(url)")
            print("PaulBoxEmailService: Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("PaulBoxEmailService: Request Body: \(jsonString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("PaulBoxEmailService: Invalid response type")
                return false
            }
            
            print("PaulBoxEmailService: Test Response Status: \(httpResponse.statusCode)")
            print("PaulBoxEmailService: Test Response Headers: \(httpResponse.allHeaderFields)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("PaulBoxEmailService: Test Response Body: \(responseString)")
            }
            
            return httpResponse.statusCode == 200
        } catch {
            print("PaulBoxEmailService: Test connection failed: \(error)")
            return false
        }
    }
    
    // MARK: - Public Methods
    func sendEmail(
        to recipients: [String],
        subject: String,
        htmlBody: String? = nil,
        textBody: String? = nil,
        replyTo: String? = nil,
        attachments: [EmailAttachment] = []
    ) async throws -> String {
        
        // Debug logging
        print("PaulBoxEmailService: Sending email to \(recipients)")
        print("PaulBoxEmailService: API Key loaded: \(apiKey.isEmpty ? "EMPTY" : "PRESENT")")
        print("PaulBoxEmailService: From Email: \(fromEmail)")
        
        // Rate limiting
        await enforceRateLimit()
        
        // Convert attachments to API format
        let apiAttachments = attachments.map { attachment in
            EmailRequest.EmailData.Message.Attachment(
                fileName: attachment.fileName,
                contentType: attachment.contentType,
                content: attachment.base64Content
            )
        }
        
        let request = EmailRequest(
            data: EmailRequest.EmailData(
                message: EmailRequest.EmailData.Message(
                    recipients: recipients,
                    headers: EmailRequest.EmailData.Message.Headers(
                        subject: subject,
                        from: fromEmail,
                        replyTo: replyTo
                    ),
                    content: EmailRequest.EmailData.Message.Content(
                        textPlain: textBody,
                        textHtml: htmlBody
                    ),
                    attachments: apiAttachments.isEmpty ? nil : apiAttachments
                )
            )
        )
        
        let url = URL(string: "\(baseURL)/messages")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Token token=\(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            
            // Debug: Print the request details
            print("PaulBoxEmailService: Request URL: \(url)")
            print("PaulBoxEmailService: Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("PaulBoxEmailService: Request Body: \(jsonString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmailServiceError.invalidResponse
            }
            
            // Debug: Print response details
            print("PaulBoxEmailService: Response Status: \(httpResponse.statusCode)")
            print("PaulBoxEmailService: Response Headers: \(httpResponse.allHeaderFields)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("PaulBoxEmailService: Response Body: \(responseString)")
            }
            
            // Try to parse error response for more details
            if httpResponse.statusCode >= 400 {
                do {
                    if let errorData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("PaulBoxEmailService: Parsed Error Response: \(errorData)")
                    }
                } catch {
                    print("PaulBoxEmailService: Could not parse error response as JSON")
                }
            }
            
            switch httpResponse.statusCode {
            case 200:
                let emailResponse = try JSONDecoder().decode(EmailResponse.self, from: data)
                lastSentTime = Date()
                return emailResponse.sourceTrackingId
                
            case 400:
                let errorResponse = try JSONDecoder().decode(EmailError.self, from: data)
                throw EmailServiceError.badRequest(errorResponse.errors.first?.detail ?? "Bad Request")
                
            case 401:
                throw EmailServiceError.unauthorized
                
            case 404:
                throw EmailServiceError.notFound
                
            case 500...504:
                throw EmailServiceError.serverError(httpResponse.statusCode)
                
            default:
                throw EmailServiceError.unknownError(httpResponse.statusCode)
            }
            
        } catch let error as EmailServiceError {
            throw error
        } catch {
            throw EmailServiceError.networkError(error.localizedDescription)
        }
    }
    
    func sendTemplateEmail(
        template: EmailTemplate,
        to recipients: [String],
        variables: [String: String] = [:],
        replyTo: String? = nil
    ) async throws -> String {
        
        let rendered = template.render(variables: variables)
        
        return try await sendEmail(
            to: recipients,
            subject: rendered.subject,
            htmlBody: rendered.html,
            textBody: rendered.text,
            replyTo: replyTo
        )
    }
    
    
    // MARK: - Private Methods
    private func enforceRateLimit() async {
        guard let lastSent = lastSentTime else { return }
        
        let timeSinceLastSent = Date().timeIntervalSince(lastSent)
        if timeSinceLastSent < rateLimitDelay {
            let delay = rateLimitDelay - timeSinceLastSent
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
}

// MARK: - Email Service Errors
enum EmailServiceError: LocalizedError {
    case invalidResponse
    case badRequest(String)
    case unauthorized
    case notFound
    case serverError(Int)
    case unknownError(Int)
    case networkError(String)
    case rateLimitExceeded
    case invalidRecipients
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from email service"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unauthorized:
            return "Unauthorized - check API key"
        case .notFound:
            return "Email service not found"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknownError(let code):
            return "Unknown error: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded - too many requests"
        case .invalidRecipients:
            return "Invalid email recipients"
        }
    }
}

// MARK: - Email Template
struct EmailTemplate: Hashable {
    let id: String
    let name: String
    let subject: String
    let htmlBody: String
    let textBody: String
    
    func render(variables: [String: String]) -> (subject: String, html: String, text: String) {
        var renderedSubject = subject
        var renderedHtml = htmlBody
        var renderedText = textBody
        
        for (key, value) in variables {
            let placeholder = "{{\(key)}}"
            renderedSubject = renderedSubject.replacingOccurrences(of: placeholder, with: value)
            renderedHtml = renderedHtml.replacingOccurrences(of: placeholder, with: value)
            renderedText = renderedText.replacingOccurrences(of: placeholder, with: value)
        }
        
        return (subject: renderedSubject, html: renderedHtml, text: renderedText)
    }
}

// MARK: - Predefined Templates
extension EmailTemplate {
    static let claimCreated = EmailTemplate(
        id: "claim_created",
        name: "Claim Created Notification",
        subject: "Your VA Claim Has Been Created - {{claimNumber}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <h2>Your VA Claim Has Been Created</h2>
            <p>Dear {{veteranName}},</p>
            <p>We have successfully created your VA claim with the following details:</p>
            <ul>
                <li><strong>Claim Number:</strong> {{claimNumber}}</li>
                <li><strong>Claim Type:</strong> {{claimType}}</li>
                <li><strong>Primary Condition:</strong> {{primaryCondition}}</li>
                <li><strong>Date Created:</strong> {{dateCreated}}</li>
            </ul>
            <p>We will keep you updated on the progress of your claim. If you have any questions, please don't hesitate to contact us.</p>
            <p>Thank you for your service.</p>
            <p><strong>Veterans Claims Foundation</strong></p>
        </body>
        </html>
        """,
        textBody: """
        Your VA Claim Has Been Created
        
        Dear {{veteranName}},
        
        We have successfully created your VA claim with the following details:
        
        Claim Number: {{claimNumber}}
        Claim Type: {{claimType}}
        Primary Condition: {{primaryCondition}}
        Date Created: {{dateCreated}}
        
        We will keep you updated on the progress of your claim. If you have any questions, please don't hesitate to contact us.
        
        Thank you for your service.
        
        Veterans Claims Foundation
        """
    )
    
    static let claimStatusUpdated = EmailTemplate(
        id: "claim_status_updated",
        name: "Claim Status Update",
        subject: "Update on Your VA Claim - {{claimNumber}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <h2>Update on Your VA Claim</h2>
            <p>Dear {{veteranName}},</p>
            <p>We have an update on your VA claim:</p>
            <ul>
                <li><strong>Claim Number:</strong> {{claimNumber}}</li>
                <li><strong>Previous Status:</strong> {{previousStatus}}</li>
                <li><strong>New Status:</strong> {{newStatus}}</li>
                <li><strong>Date Updated:</strong> {{dateUpdated}}</li>
            </ul>
            <p>{{statusMessage}}</p>
            <p>If you have any questions about this update, please contact us.</p>
            <p>Thank you for your service.</p>
            <p><strong>Veterans Claims Foundation</strong></p>
        </body>
        </html>
        """,
        textBody: """
        Update on Your VA Claim
        
        Dear {{veteranName}},
        
        We have an update on your VA claim:
        
        Claim Number: {{claimNumber}}
        Previous Status: {{previousStatus}}
        New Status: {{newStatus}}
        Date Updated: {{dateUpdated}}
        
        {{statusMessage}}
        
        If you have any questions about this update, please contact us.
        
        Thank you for your service.
        
        Veterans Claims Foundation
        """
    )
    
    static let documentUploaded = EmailTemplate(
        id: "document_uploaded",
        name: "Document Upload Confirmation",
        subject: "Document Upload Confirmation - {{documentName}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <h2>Document Upload Confirmation</h2>
            <p>Dear {{veteranName}},</p>
            <p>We have successfully received your uploaded document:</p>
            <ul>
                <li><strong>Document Name:</strong> {{documentName}}</li>
                <li><strong>Document Type:</strong> {{documentType}}</li>
                <li><strong>Upload Date:</strong> {{uploadDate}}</li>
                <li><strong>File Size:</strong> {{fileSize}}</li>
            </ul>
            <p>This document has been added to your claim file and will be reviewed as part of your case.</p>
            <p>If you have any questions about this document, please contact us.</p>
            <p>Thank you for your service.</p>
            <p><strong>Veterans Claims Foundation</strong></p>
        </body>
        </html>
        """,
        textBody: """
        Document Upload Confirmation
        
        Dear {{veteranName}},
        
        We have successfully received your uploaded document:
        
        Document Name: {{documentName}}
        Document Type: {{documentType}}
        Upload Date: {{uploadDate}}
        File Size: {{fileSize}}
        
        This document has been added to your claim file and will be reviewed as part of your case.
        
        If you have any questions about this document, please contact us.
        
        Thank you for your service.
        
        Veterans Claims Foundation
        """
    )
    
    static let activityAlert = EmailTemplate(
        id: "activity_alert",
        name: "Activity Alert",
        subject: "Activity Alert - {{activityType}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <h2>Activity Alert</h2>
            <p>An activity has been logged for veteran {{veteranName}}:</p>
            <ul>
                <li><strong>Activity Type:</strong> {{activityType}}</li>
                <li><strong>Description:</strong> {{activityDescription}}</li>
                <li><strong>Date:</strong> {{activityDate}}</li>
                <li><strong>Performed By:</strong> {{performedBy}}</li>
            </ul>
            <p>{{activityNotes}}</p>
            <p>Please review this activity in the system.</p>
            <p><strong>Veterans Claims Foundation</strong></p>
        </body>
        </html>
        """,
        textBody: """
        Activity Alert
        
        An activity has been logged for veteran {{veteranName}}:
        
        Activity Type: {{activityType}}
        Description: {{activityDescription}}
        Date: {{activityDate}}
        Performed By: {{performedBy}}
        
        {{activityNotes}}
        
        Please review this activity in the system.
        
        Veterans Claims Foundation
        """
    )
    
    static let allTemplates: [EmailTemplate] = [
        .claimCreated,
        .claimStatusUpdated,
        .documentUploaded,
        .activityAlert
    ]
}
