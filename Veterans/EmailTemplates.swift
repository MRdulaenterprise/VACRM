import Foundation

// MARK: - Email Template Manager
class EmailTemplateManager: ObservableObject {
    static let shared = EmailTemplateManager()
    
    @Published var templates: [EmailTemplate] = []
    
    static var allTemplates: [EmailTemplate] {
        return [
            EmailTemplate.welcomeVeteran,
            EmailTemplate.claimApproved,
            EmailTemplate.claimDenied,
            EmailTemplate.newVeteranAlert,
            EmailTemplate.urgentActivityAlert
        ]
    }
    
    func getTemplate(by id: String) -> EmailTemplate? {
        return templates.first { $0.id == id }
    }
    
    func getTemplateByName(_ name: String) -> EmailTemplate? {
        return templates.first { $0.name == name }
    }
}

// MARK: - Email Template Extensions
extension EmailTemplate {
    
    // MARK: - Veteran Communication Templates
    static let welcomeVeteran = EmailTemplate(
        id: "welcome_veteran",
        name: "Welcome Veteran",
        subject: "Welcome to Veterans Claims Foundation - {{veteranName}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">Welcome to Veterans Claims Foundation</h1>
                <p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Your trusted partner in VA benefits</p>
            </div>
            <div style="padding: 30px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
                <p>Dear {{veteranName}},</p>
                <p>Welcome to Veterans Claims Foundation! We're honored to assist you with your VA benefits claim.</p>
                <p>Your veteran profile has been successfully created with the following information:</p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin: 10px 0;"><strong>Veteran ID:</strong> {{veteranId}}</li>
                        <li style="margin: 10px 0;"><strong>Service Branch:</strong> {{serviceBranch}}</li>
                        <li style="margin: 10px 0;"><strong>Service Dates:</strong> {{serviceStartDate}} - {{serviceEndDate}}</li>
                        <li style="margin: 10px 0;"><strong>Contact Email:</strong> {{emailPrimary}}</li>
                    </ul>
                </div>
                <p>What happens next:</p>
                <ol>
                    <li>Our team will review your information</li>
                    <li>We'll help you identify potential claims</li>
                    <li>We'll guide you through the claims process</li>
                    <li>We'll track your claim status and keep you informed</li>
                </ol>
                <p>If you have any questions or need assistance, please don't hesitate to contact us.</p>
                <p>Thank you for your service to our country.</p>
                <div style="text-align: center; margin-top: 30px;">
                    <p style="font-weight: bold; color: #1e3c72;">Veterans Claims Foundation</p>
                    <p style="color: #666; font-size: 14px;">Dedicated to serving those who served</p>
                </div>
            </div>
        </body>
        </html>
        """,
        textBody: """
        Welcome to Veterans Claims Foundation
        
        Dear {{veteranName}},
        
        Welcome to Veterans Claims Foundation! We're honored to assist you with your VA benefits claim.
        
        Your veteran profile has been successfully created with the following information:
        
        Veteran ID: {{veteranId}}
        Service Branch: {{serviceBranch}}
        Service Dates: {{serviceStartDate}} - {{serviceEndDate}}
        Contact Email: {{emailPrimary}}
        
        What happens next:
        1. Our team will review your information
        2. We'll help you identify potential claims
        3. We'll guide you through the claims process
        4. We'll track your claim status and keep you informed
        
        If you have any questions or need assistance, please don't hesitate to contact us.
        
        Thank you for your service to our country.
        
        Veterans Claims Foundation
        Dedicated to serving those who served
        """
    )
    
    static let claimApproved = EmailTemplate(
        id: "claim_approved",
        name: "Claim Approved",
        subject: "🎉 Great News! Your VA Claim Has Been Approved - {{claimNumber}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">🎉 Congratulations!</h1>
                <p style="margin: 10px 0 0 0; font-size: 18px;">Your VA Claim Has Been Approved</p>
            </div>
            <div style="padding: 30px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
                <p>Dear {{veteranName}},</p>
                <p>We have excellent news! Your VA claim has been approved by the Department of Veterans Affairs.</p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #28a745;">
                    <h3 style="color: #28a745; margin-top: 0;">Claim Details</h3>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin: 10px 0;"><strong>Claim Number:</strong> {{claimNumber}}</li>
                        <li style="margin: 10px 0;"><strong>Approval Date:</strong> {{approvalDate}}</li>
                        <li style="margin: 10px 0;"><strong>Rating:</strong> {{rating}}%</li>
                        <li style="margin: 10px 0;"><strong>Effective Date:</strong> {{effectiveDate}}</li>
                    </ul>
                </div>
                <p><strong>What this means for you:</strong></p>
                <ul>
                    <li>You will receive monthly compensation payments</li>
                    <li>You may be eligible for additional benefits</li>
                    <li>Your rating may qualify you for other VA services</li>
                </ul>
                <p>We will continue to monitor your case and assist you with any follow-up actions needed.</p>
                <p>Thank you for your service, and congratulations on this important milestone!</p>
                <div style="text-align: center; margin-top: 30px;">
                    <p style="font-weight: bold; color: #28a745;">Veterans Claims Foundation</p>
                    <p style="color: #666; font-size: 14px;">Celebrating your success</p>
                </div>
            </div>
        </body>
        </html>
        """,
        textBody: """
        🎉 Congratulations! Your VA Claim Has Been Approved
        
        Dear {{veteranName}},
        
        We have excellent news! Your VA claim has been approved by the Department of Veterans Affairs.
        
        Claim Details:
        Claim Number: {{claimNumber}}
        Approval Date: {{approvalDate}}
        Rating: {{rating}}%
        Effective Date: {{effectiveDate}}
        
        What this means for you:
        • You will receive monthly compensation payments
        • You may be eligible for additional benefits
        • Your rating may qualify you for other VA services
        
        We will continue to monitor your case and assist you with any follow-up actions needed.
        
        Thank you for your service, and congratulations on this important milestone!
        
        Veterans Claims Foundation
        Celebrating your success
        """
    )
    
    static let claimDenied = EmailTemplate(
        id: "claim_denied",
        name: "Claim Denied",
        subject: "Important Update on Your VA Claim - {{claimNumber}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #dc3545 0%, #e74c3c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">Important Update</h1>
                <p style="margin: 10px 0 0 0; font-size: 18px;">Your VA Claim Status</p>
            </div>
            <div style="padding: 30px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
                <p>Dear {{veteranName}},</p>
                <p>We have received an update on your VA claim that requires our attention.</p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #dc3545;">
                    <h3 style="color: #dc3545; margin-top: 0;">Claim Details</h3>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin: 10px 0;"><strong>Claim Number:</strong> {{claimNumber}}</li>
                        <li style="margin: 10px 0;"><strong>Decision Date:</strong> {{decisionDate}}</li>
                        <li style="margin: 10px 0;"><strong>Status:</strong> {{status}}</li>
                        <li style="margin: 10px 0;"><strong>Reason:</strong> {{denialReason}}</li>
                    </ul>
                </div>
                <p><strong>Don't give up - we're here to help!</strong></p>
                <p>This is not the end of the road. We can help you:</p>
                <ul>
                    <li>Review the denial reasons and gather additional evidence</li>
                    <li>File an appeal or reconsideration</li>
                    <li>Submit new and material evidence</li>
                    <li>Explore alternative approaches to your claim</li>
                </ul>
                <p>Our team will review your case and develop a strategy for moving forward. We'll be in touch soon with our recommendations.</p>
                <p>Remember, many successful claims start with an initial denial. We're committed to helping you get the benefits you deserve.</p>
                <div style="text-align: center; margin-top: 30px;">
                    <p style="font-weight: bold; color: #dc3545;">Veterans Claims Foundation</p>
                    <p style="color: #666; font-size: 14px;">We don't give up on our veterans</p>
                </div>
            </div>
        </body>
        </html>
        """,
        textBody: """
        Important Update on Your VA Claim
        
        Dear {{veteranName}},
        
        We have received an update on your VA claim that requires our attention.
        
        Claim Details:
        Claim Number: {{claimNumber}}
        Decision Date: {{decisionDate}}
        Status: {{status}}
        Reason: {{denialReason}}
        
        Don't give up - we're here to help!
        
        This is not the end of the road. We can help you:
        • Review the denial reasons and gather additional evidence
        • File an appeal or reconsideration
        • Submit new and material evidence
        • Explore alternative approaches to your claim
        
        Our team will review your case and develop a strategy for moving forward. We'll be in touch soon with our recommendations.
        
        Remember, many successful claims start with an initial denial. We're committed to helping you get the benefits you deserve.
        
        Veterans Claims Foundation
        We don't give up on our veterans
        """
    )
    
    // MARK: - Team Communication Templates
    static let newVeteranAlert = EmailTemplate(
        id: "new_veteran_alert",
        name: "New Veteran Alert",
        subject: "New Veteran Added - {{veteranName}} ({{veteranId}})",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #6f42c1 0%, #8e44ad 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">New Veteran Added</h1>
                <p style="margin: 10px 0 0 0; font-size: 18px;">Action Required</p>
            </div>
            <div style="padding: 30px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
                <p>A new veteran has been added to the system and requires attention.</p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <h3 style="color: #6f42c1; margin-top: 0;">Veteran Information</h3>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin: 10px 0;"><strong>Name:</strong> {{veteranName}}</li>
                        <li style="margin: 10px 0;"><strong>Veteran ID:</strong> {{veteranId}}</li>
                        <li style="margin: 10px 0;"><strong>Service Branch:</strong> {{serviceBranch}}</li>
                        <li style="margin: 10px 0;"><strong>Contact:</strong> {{emailPrimary}}</li>
                        <li style="margin: 10px 0;"><strong>Added By:</strong> {{addedBy}}</li>
                        <li style="margin: 10px 0;"><strong>Date Added:</strong> {{dateAdded}}</li>
                    </ul>
                </div>
                <p><strong>Next Steps:</strong></p>
                <ol>
                    <li>Review the veteran's information for completeness</li>
                    <li>Assess potential claims based on service history</li>
                    <li>Schedule initial consultation if needed</li>
                    <li>Assign case manager if appropriate</li>
                </ol>
                <p>Please log into the system to review the full veteran profile and take appropriate action.</p>
                <div style="text-align: center; margin-top: 30px;">
                    <p style="font-weight: bold; color: #6f42c1;">Veterans Claims Foundation</p>
                    <p style="color: #666; font-size: 14px;">Team notification system</p>
                </div>
            </div>
        </body>
        </html>
        """,
        textBody: """
        New Veteran Added - Action Required
        
        A new veteran has been added to the system and requires attention.
        
        Veteran Information:
        Name: {{veteranName}}
        Veteran ID: {{veteranId}}
        Service Branch: {{serviceBranch}}
        Contact: {{emailPrimary}}
        Added By: {{addedBy}}
        Date Added: {{dateAdded}}
        
        Next Steps:
        1. Review the veteran's information for completeness
        2. Assess potential claims based on service history
        3. Schedule initial consultation if needed
        4. Assign case manager if appropriate
        
        Please log into the system to review the full veteran profile and take appropriate action.
        
        Veterans Claims Foundation
        Team notification system
        """
    )
    
    static let urgentActivityAlert = EmailTemplate(
        id: "urgent_activity_alert",
        name: "Urgent Activity Alert",
        subject: "🚨 URGENT: {{activityType}} - {{veteranName}}",
        htmlBody: """
        <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #dc3545 0%, #e74c3c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
                <h1 style="margin: 0; font-size: 28px;">🚨 URGENT ALERT</h1>
                <p style="margin: 10px 0 0 0; font-size: 18px;">Immediate Attention Required</p>
            </div>
            <div style="padding: 30px; background: #f8f9fa; border-radius: 0 0 10px 10px;">
                <p><strong>URGENT:</strong> An activity requiring immediate attention has been logged.</p>
                <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #dc3545;">
                    <h3 style="color: #dc3545; margin-top: 0;">Activity Details</h3>
                    <ul style="list-style: none; padding: 0;">
                        <li style="margin: 10px 0;"><strong>Veteran:</strong> {{veteranName}} ({{veteranId}})</li>
                        <li style="margin: 10px 0;"><strong>Activity Type:</strong> {{activityType}}</li>
                        <li style="margin: 10px 0;"><strong>Description:</strong> {{activityDescription}}</li>
                        <li style="margin: 10px 0;"><strong>Date/Time:</strong> {{activityDate}}</li>
                        <li style="margin: 10px 0;"><strong>Performed By:</strong> {{performedBy}}</li>
                        <li style="margin: 10px 0;"><strong>Priority:</strong> {{priority}}</li>
                    </ul>
                </div>
                <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 8px; margin: 20px 0;">
                    <p style="margin: 0; color: #856404;"><strong>Notes:</strong> {{activityNotes}}</p>
                </div>
                <p><strong>Required Actions:</strong></p>
                <ul>
                    <li>Review the activity details immediately</li>
                    <li>Take appropriate action based on the activity type</li>
                    <li>Update the veteran's case status if needed</li>
                    <li>Follow up with the veteran if required</li>
                </ul>
                <p>Please log into the system immediately to address this urgent matter.</p>
                <div style="text-align: center; margin-top: 30px;">
                    <p style="font-weight: bold; color: #dc3545;">Veterans Claims Foundation</p>
                    <p style="color: #666; font-size: 14px;">Urgent notification system</p>
                </div>
            </div>
        </body>
        </html>
        """,
        textBody: """
        🚨 URGENT ALERT - Immediate Attention Required
        
        URGENT: An activity requiring immediate attention has been logged.
        
        Activity Details:
        Veteran: {{veteranName}} ({{veteranId}})
        Activity Type: {{activityType}}
        Description: {{activityDescription}}
        Date/Time: {{activityDate}}
        Performed By: {{performedBy}}
        Priority: {{priority}}
        
        Notes: {{activityNotes}}
        
        Required Actions:
        • Review the activity details immediately
        • Take appropriate action based on the activity type
        • Update the veteran's case status if needed
        • Follow up with the veteran if required
        
        Please log into the system immediately to address this urgent matter.
        
        Veterans Claims Foundation
        Urgent notification system
        """
    )
    
}
