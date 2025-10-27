# Veterans Claims Foundation CRM

A comprehensive Customer Relationship Management (CRM) application designed specifically for nonprofits helping veterans with their VA benefits claims. Built with SwiftUI and SwiftData for macOS, featuring modern design patterns, AI-powered assistance, and comprehensive data management.

## 🚀 Key Features

### 📊 Modern Dashboard
- **Real-time Statistics**: Total veterans, active claims, pending claims, and approved claims
- **Visual Metrics Cards**: Gradient backgrounds with hover effects and animations
- **Quick Actions**: Direct access to add veterans, claims, and upload documents
- **Modern Sidebar Navigation**: Clean, intuitive navigation with SF Symbols

### 👥 Comprehensive Veteran Management
- **Complete Veteran Profiles**: 200+ fields covering all aspects of veteran information
- **Personal Information**: Name, contact details, demographics, emergency contacts
- **Military Service**: Branch, component, service dates, discharge status, rank, occupation
- **Service History**: Combat service, deployments, awards, medals, POW status
- **Exposure Tracking**: Agent Orange, radiation, burn pits, Gulf War, Camp Lejeune
- **Benefits Status**: Healthcare enrollment, education benefits, home loans, compensation
- **Case Management**: VSO assignment, counselor notes, priority levels, follow-up tracking
- **Special Circumstances**: Homeless status, mental health, MST, terminal illness tracking
- **Technology Integration**: Portal accounts, ID.me verification, API sync status

### 📋 Advanced Claims Management
- **Comprehensive Claim Tracking**: 80+ fields for detailed claim management
- **Medical Conditions**: Primary and secondary conditions with categories and relationships
- **Evidence Management**: DD-214, medical records, nexus letters, buddy statements
- **Appeals Process**: Complete appeals workflow with hearing management
- **Status Tracking**: Real-time status updates with priority levels
- **Activity Logging**: Detailed activity tracking
- **Condition Management**: Complex medical condition relationships and hierarchies

### 🎯 Kanban Board Workflow Management
- **Visual Claim Tracking**: Drag-and-drop interface for claim status management
- **Status Columns**: New, In Progress, Under Review, Review of Evidence, Approved, Denied, Appealed, Closed
- **Real-time Updates**: Instant status changes with visual feedback
- **Claim Cards**: Detailed claim information with veteran association
- **Priority Indicators**: Visual priority levels and deadline tracking
- **Quick Actions**: Direct access to edit claims from board view

### 🤖 AI-Powered Copilot Assistant
- **OpenAI Integration**: GPT-4 powered assistance for VA claims guidance
- **Chat Sessions**: Persistent conversation history with veterans and cases
- **Document Analysis**: Upload and analyze PDF documents with AI assistance
- **Prompt Templates**: Pre-configured templates for common VA scenarios
- **De-identification**: Automatic PHI removal for HIPAA compliance
- **PDF Export**: Export chat conversations as professional documents
- **Audit Logging**: Complete tracking of all AI interactions
- **Secure Storage**: Encrypted conversation storage with keychain integration

### 🔍 Advanced Search & Discovery
- **Global Search**: Search across veterans, claims, documents, and activities
- **Smart Filtering**: Filter results by type (veteran, claim, document, activity)
- **Real-time Results**: Instant search results with relevance scoring
- **Content Search**: Search within document content and extracted text
- **Veteran Association**: Automatic linking of search results to veteran profiles
- **Search History**: Track and revisit previous searches

### 📄 Document Management System
- **File Organization**: Upload and categorize documents by type
- **Document Types**: Medical records, service records, discharge documents, claim forms
- **File Tracking**: Size, upload date, and metadata management
- **Drag & Drop**: Modern file upload interface
- **Preview Support**: File previews and thumbnails
- **PDF Processing**: Extract text from PDF documents for AI analysis
- **Secure Storage**: Encrypted document storage with access controls

### 🔄 Activity & Audit System
- **Comprehensive Logging**: Track all user and system actions
- **Activity Types**: Phone calls, emails, document uploads, status changes, meetings
- **Audit Trail**: Complete history of all interactions
- **User Attribution**: Track who performed each action
- **Timeline View**: Chronological activity display
- **AI Interaction Logging**: Track all Copilot conversations and document processing

### 📧 HIPAA-Compliant Email Integration
- **PaulBox API Integration**: Secure, HIPAA-compliant email service
- **Automated Notifications**: Send emails for claim updates, document uploads, and activities
- **Email Templates**: Predefined templates for common scenarios
- **Manual Email Composition**: Full-featured email compose interface
- **Email History Tracking**: Complete audit trail of all sent emails
- **Team Notifications**: Internal alerts for new veterans and urgent activities
- **Veteran Communications**: Automated updates to veterans about their claims
- **Email Settings**: Configurable notification preferences and API settings

### 🏥 Medical Condition Management
- **Complex Condition Tracking**: Primary and secondary conditions with relationships
- **Category Management**: Organize conditions by medical categories
- **Relationship Mapping**: Track how conditions relate to each other
- **Condition History**: Track changes and updates over time
- **Visual Management**: Card-based interface for easy condition management

### 🛡️ HIPAA Compliance & Security
- **Data Encryption**: End-to-end encryption for all sensitive data
- **Keychain Storage**: Secure API key storage using macOS Keychain
- **De-identification**: Automatic PHI removal from AI interactions
- **Audit Logging**: Complete audit trail for compliance requirements
- **Access Controls**: Role-based access to sensitive information
- **TLS 1.3+**: Secure communication protocols for all API calls

## 🎨 Modern UI/UX Features

### Design System
- **Glass Morphism**: Modern materials and transparency effects
- **Consistent Spacing**: 8pt grid system throughout
- **SF Symbols**: Native macOS iconography
- **Dark Mode Support**: Full light/dark mode compatibility
- **Smooth Animations**: 60fps transitions and hover effects

### Navigation
- **Three-Column Layout**: Sidebar, content, and detail views
- **Modern Sidebar**: Icon-based navigation with selection states
- **Toolbar Actions**: Quick access to common functions
- **Search Integration**: Global search across all data

### Forms & Input
- **Grouped Forms**: Organized sections with collapsible groups
- **Material Backgrounds**: Modern glass effects
- **Field Validation**: Real-time validation with visual feedback
- **Progressive Disclosure**: Show/hide advanced options
- **Large Controls**: macOS-optimized input controls

## 📊 Data Models

### Veteran Model (200+ Fields)
```swift
// Personal Information
firstName, lastName, middleName, suffix, preferredName
dateOfBirth, gender, maritalStatus, ssnLastFour

// Contact Information  
emailPrimary, emailSecondary, phonePrimary, phoneSecondary
addressStreet, addressCity, addressState, addressZip

// Military Service
serviceBranch, serviceComponent, serviceStartDate, serviceEndDate
dischargeStatus, rankAtSeparation, militaryOccupation

// Benefits & Compensation
vaHealthcareEnrolled, currentDisabilityRating, monthlyCompensation
educationBenefits, homeLoanCoeIssued, pensionBenefits

// Case Management
caseStatus, assignedVso, assignedCounselor, casePriority
nextActionItem, lastContactDate, veteranResponsive

// Special Circumstances
homelessVeteran, mentalHealthCrisis, terminalIllness
mstSurvivor, womenVeteran, minorityVeteran, lgbtqVeteran

// Technology Integration
portalAccountCreated, idMeVerified, vaGovApiSynced
// ... and 150+ more fields
```

### Claim Model (80+ Fields)
```swift
// Basic Information
claimNumber, claimType, claimStatus, claimFiledDate
primaryCondition, secondaryConditions, totalConditionsClaimed

// Medical Evidence
nexusLetterRequired, dbqCompleted, cAndPExamRequired
serviceTreatmentRecords, vaMedicalRecords, privateMedicalRecords

// Appeals Process
appealFiled, appealType, appealStatus, boardHearingRequested
appealDecisionDate, appealOutcome, cavcFilingDeadline

// Forms & Documentation
vaForm21526ez, vaForm214142, vaForm21781, vaForm21781a
dependentVerification, marriageCertificate, birthCertificates
// ... and 60+ more fields
```

### Medical Condition Models
```swift
// MedicalConditionCategory
name, conditionDescription, colorCode, isActive

// MedicalCondition  
name, conditionDescription, category, severity, onsetDate
isServiceConnected, isPrimary, isSecondary

// ConditionRelationship
primaryCondition, secondaryCondition, relationshipType
conditionDescription, strength, evidence
```

## 🔌 Integrations & API Services

### 🤖 OpenAI Integration
- **API Service**: Secure OpenAI API integration with GPT-4 support
- **Key Management**: Secure API key storage in macOS Keychain
- **Model Support**: GPT-4, GPT-3.5-turbo with configurable parameters
- **Streaming Support**: Real-time response streaming for better UX
- **Rate Limiting**: Built-in rate limiting and error handling
- **Audit Logging**: Complete tracking of all API requests and responses
- **Security**: TLS 1.3+ encryption and security headers
- **Error Handling**: Comprehensive error handling with user-friendly messages

### 📧 Paubox Email Integration
- **HIPAA Compliance**: BAA (Business Associate Agreement) compliant email service
- **API Integration**: RESTful API integration with authentication
- **Email Templates**: Predefined templates for common scenarios
- **Attachment Support**: Secure file attachment handling
- **Delivery Tracking**: Email delivery status and tracking
- **Rate Limiting**: 500 messages per minute rate limiting
- **Error Handling**: Comprehensive error handling and retry logic
- **Configuration**: Easy setup through settings interface

### 🔐 Security & Compliance
- **Keychain Integration**: Secure storage of API keys and credentials
- **Data Encryption**: End-to-end encryption for sensitive data
- **PHI Protection**: Automatic de-identification of protected health information
- **Audit Trails**: Complete audit logging for compliance requirements
- **Access Controls**: Role-based access to sensitive features
- **Secure Communication**: TLS 1.3+ for all external communications

## 🛠 Technical Architecture

### Core Technologies
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Local data persistence with CloudKit support
- **macOS Native**: Optimized for desktop workflows
- **MVVM Architecture**: Clean separation of concerns

### Data Management
- **Local Storage**: SQLite via SwiftData
- **Cloud Sync**: Ready for CloudKit integration
- **Data Validation**: Comprehensive field validation
- **Relationship Management**: Complex model relationships

### AI Services
- **OpenAI Service**: Secure API integration with GPT-4
- **Document Processing**: PDF text extraction and analysis
- **De-identification**: Automatic PHI removal for compliance
- **Prompt Management**: Template system for common VA scenarios
- **Chat Persistence**: Secure storage of conversation history

### Email Services
- **Paubox Integration**: HIPAA-compliant email service
- **Template System**: Predefined email templates
- **Attachment Handling**: Secure file attachment processing
- **Delivery Tracking**: Email status monitoring

### Performance
- **Lazy Loading**: Efficient data loading
- **Background Processing**: Non-blocking operations
- **Memory Management**: Optimized for large datasets
- **Smooth Scrolling**: 60fps performance
- **Async Operations**: Non-blocking API calls and processing

## 🚀 Getting Started

### Prerequisites
- macOS 15.0 or later
- Xcode 16.0 or later
- Apple Silicon or Intel Mac

### Installation
1. Clone the repository
2. Open `Veterans.xcodeproj` in Xcode
3. Build and run the application
4. The app will create a local database automatically

### First Use
1. **Add Veterans**: Use the "+" button to add veteran profiles
2. **Create Claims**: Associate claims with veterans
3. **Upload Documents**: Add supporting documentation
4. **Track Activities**: Monitor all interactions and updates

## 📱 Usage Guide

### Adding a Veteran
1. Click the "+" button in the toolbar
2. Select "Add Veteran" from the dropdown
3. Fill out the comprehensive veteran form
4. Save to add to the system

### Managing Claims
1. Select a veteran from the sidebar
2. Navigate to the Claims section
3. Add new claims with detailed information
4. Track medical conditions and evidence
5. Monitor appeals and hearings

### Document Management
1. Select "Upload Documents" from the toolbar
2. Drag and drop files or use the file picker
3. Categorize documents appropriately
4. Associate with veterans and claims

### Dashboard Overview
1. View real-time statistics
2. Monitor active cases
3. Track system health
4. Quick access to all functions

### Email Configuration
1. Navigate to Dashboard and click "Email Settings"
2. Configure PaulBox API credentials
3. Set notification preferences
4. Test email connection
5. Enable/disable automated notifications

### AI Copilot Setup
1. Navigate to Copilot section from sidebar
2. Click Settings (gear icon) to configure OpenAI
3. Enter your OpenAI API key (stored securely in Keychain)
4. Select preferred model (GPT-4 recommended)
5. Configure temperature and token limits
6. Enable/disable de-identification features
7. Test connection with sample query

### Kanban Board Usage
1. Navigate to Kanban Board from sidebar
2. View claims organized by status columns
3. Drag and drop claims between status columns
4. Click on claim cards to edit details
5. Monitor workflow progress visually
6. Track priority levels and deadlines

### Advanced Search
1. Use the global search bar in the toolbar
2. Search across veterans, claims, documents, and activities
3. Use filters to narrow results by type
4. Click on results to navigate to relevant records
5. Search within document content and extracted text

## 🔧 Advanced Features

### AI-Powered Document Analysis
- **PDF Processing**: Extract text from uploaded PDF documents
- **Content Analysis**: AI-powered analysis of document content
- **De-identification**: Automatic removal of PHI from documents
- **Template Matching**: Match documents to VA form types
- **Evidence Extraction**: Identify key evidence from medical records
- **Summary Generation**: AI-generated document summaries

### Prompt Template System
- **Pre-configured Templates**: Ready-to-use prompts for common VA scenarios
- **Custom Templates**: Create and manage custom prompt templates
- **Variable Substitution**: Dynamic content insertion for personalized prompts
- **Category Organization**: Organize templates by claim type and purpose
- **Usage Tracking**: Monitor template usage and effectiveness
- **Template Editor**: Visual editor for creating and modifying templates

### Medical Condition Management
- **Complex Relationships**: Track how conditions relate to each other
- **Category Organization**: Group conditions by medical categories
- **Severity Tracking**: Monitor condition progression
- **Evidence Linking**: Connect conditions to supporting documentation

### Appeals Process
- **Complete Workflow**: Track appeals from filing to decision
- **Hearing Management**: Schedule and track board hearings
- **Evidence Submission**: Manage new evidence during appeals
- **Deadline Tracking**: Monitor important dates and deadlines

### Case Management
- **Priority System**: Assign and track case priorities
- **Follow-up Tracking**: Automated follow-up reminders
- **VSO Assignment**: Track veteran service organization assignments
- **Counselor Notes**: Detailed case notes and observations

### Workflow Automation
- **Status Transitions**: Automated status updates based on actions
- **Email Triggers**: Automatic email notifications for status changes
- **Activity Logging**: Automatic logging of system and user actions
- **Deadline Alerts**: Automated reminders for important dates
- **Document Processing**: Automatic document categorization and analysis

## 🎯 Future Enhancements

### Planned Features
- **Report Generation**: Comprehensive reporting system with charts and analytics
- **Calendar Sync**: Appointment scheduling and calendar integration
- **Advanced Analytics**: Data insights and trends analysis
- **Backup & Sync**: Cloud backup capabilities with CloudKit
- **API Integration**: VA.gov API connectivity for real-time claim status
- **Mobile Companion**: iOS companion app for field work
- **Voice Integration**: Voice commands and dictation support
- **Multi-language Support**: Internationalization for diverse veteran populations

### Technical Improvements
- **Performance Optimization**: Enhanced data loading and caching
- **Accessibility**: Full VoiceOver support and accessibility features
- **Internationalization**: Multi-language support
- **Enhanced Security**: Advanced encryption and security features
- **Scalability**: Support for larger datasets and multi-user environments
- **Machine Learning**: Enhanced AI capabilities with custom models
- **Integration Expansion**: Additional third-party service integrations

## 📞 Support & Contributing

This CRM is specifically designed for veteran service organizations and includes all essential features for effective case management. The modern interface ensures staff can efficiently track claims, manage documents, and maintain detailed records of all veteran interactions.

### Key Benefits
- **Comprehensive Data Management**: Track every aspect of veteran cases with 200+ fields per veteran
- **AI-Powered Assistance**: GPT-4 integration for intelligent claim guidance and document analysis
- **Modern Interface**: Intuitive, macOS-native design with glass morphism and smooth animations
- **Complete Audit Trail**: Full activity logging and HIPAA compliance features
- **Scalable Architecture**: Ready for growth and expansion with CloudKit integration
- **Professional Support**: Built specifically for nonprofit organizations serving veterans
- **HIPAA Compliance**: Secure, encrypted data handling with automatic PHI protection
- **Workflow Automation**: Streamlined processes with automated notifications and status tracking

### Integration Requirements
- **OpenAI API Key**: Required for AI Copilot functionality
- **Paubox Account**: Required for HIPAA-compliant email services
- **macOS 15.0+**: Minimum system requirements
- **Internet Connection**: Required for AI and email services

---

**Veterans Claims Foundation CRM** - Empowering nonprofits to better serve our veterans through comprehensive case management, AI-powered assistance, and modern technology.