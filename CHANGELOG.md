# Changelog

All notable changes to the Veterans Claims Foundation CRM project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CHANGELOG.md to track all project updates and improvements

## [2025-01] - Latest Updates

### Fixed
- **File Upload in Copilot Chat**: Fixed file importer not presenting when triggered from upload button
  - Moved `fileImporter` modifier to higher-level view hierarchy (`CopilotView`)
  - Changed `showingFileUpload` from `@State` to `@Binding` for proper state management
  - Added delay mechanism (0.2s) to ensure Menu dismissal before file importer presentation
  - Added debug logging for upload state tracking

- **Document Association with Chat Sessions**: Fixed documents not being associated with chat sessions
  - Added retry mechanism (3 attempts with 0.1s delay) for document-session association
  - Ensured session is saved to database before processing documents
  - Added manual association fallback if automatic association fails
  - Added debug logging for document processing and association

- **Document Passing to OpenAI API**: Fixed documents not being included in chat context
  - Updated `createMessageArray` to accept optional `sessionDocuments` parameter
  - Added document context system message with file names, content previews, and summaries
  - Documents now automatically included in chat context for AI analysis
  - Added debug logging for document inclusion in API requests

- **Keychain Error -34018**: Fixed Keychain operation failures
  - Added fallback mechanism for `kSecUseDataProtectionKeychain` (macOS 10.15+)
  - Retry logic for Keychain save/load operations without data protection keychain
  - Graceful handling of `errSecMissingEntitlement` errors
  - Removed unnecessary `keychain-access-groups` entitlement

- **Encryption Failure Handling**: Added graceful fallback for encryption failures
  - Documents stored unencrypted if encryption fails (with warning)
  - Prevents complete upload failure due to Keychain issues
  - Added debug logging for encryption success/failure

- **PDF Export Crash**: Fixed crash when exporting chat to PDF
  - Replaced Key-Value Coding (KVC) with proper `PDFDocumentAttribute` API
  - Handled unsupported metadata keys (like "Keywords") gracefully
  - Proper type conversion for PDF document attributes
  - Keywords appended to Subject attribute instead of separate field

- **Collapsible Section Responsiveness**: Fixed "time limit" feeling on opening/closing cards
  - Optimized animation duration (0.2s) for smoother transitions
  - Added `.contentShape(Rectangle())` to ensure entire header area is tappable
  - Separate animation for chevron icon rotation
  - Added transition effects for content appearance/disappearance

- **Dropdown Conflicts in AddVeteranView**: Fixed dropdowns not working in "New Veteran" modal
  - Removed all `.onTapGesture` modifiers from `CollapsibleSection` instances
  - Resolved tap gesture conflicts with embedded `Picker` components
  - All 9 collapsible sections now properly support dropdown interactions

- **VA Forms API Decoding Errors**: Fixed multiple decoding issues
  - Added `CodingKeys` enum to map snake_case API fields to camelCase Swift properties
  - Implemented custom decoder for `benefit_categories` to handle mixed types (strings, objects, numbers)
  - Made `sha256` field optional to handle null values in API responses
  - Enhanced error messages with path information for debugging

- **VA Forms API Empty Response**: Fixed "data couldn't be read because it is missing" error
  - Added detection for empty API responses
  - Enhanced error messages to suggest authorization issues
  - Improved debugging with console logging of raw responses

### Added
- **Upload Progress Indicator**: Visual progress indicator during document processing
  - Shows processing status and progress percentage
  - Displays in chat input area during document upload

- **Attached Documents UI**: Horizontal scroll view showing all attached documents
  - Document chips with file names
  - Visual indication of attached documents
  - Removed separate dropdown and icon (simplified to single upload button)

- **Document Count Display**: Shows number of attached documents in chat header

- **Search Bar in Kanban Board**: Added search functionality to filter claims
  - Search by claim number, type, primary condition, secondary conditions, veteran name, or status
  - Real-time filtering as you type

- **Complete Edit Claim Modal**: Full edit capability with all 80+ fields
  - Organized into collapsible sections (Basic Information, Conditions, Nexus, Exams, Evidence, Forms, Appeals, Notes)
  - Save and Close buttons
  - Input validation with error alerts
  - Loads existing claim data into all fields

- **Custom App Logo**: Branded app icon in sidebar navigation
  - Uses `AppLogo.imageset` from Assets catalog
  - Replaced system icon with custom branding

- **VA Forms URL Opening**: Click forms to open in browser
  - Context menu for additional actions
  - Direct navigation to form web pages

- **Unified Search Bar for VA.gov**: Single search bar for all VA.gov data types
  - Context-aware search across Forms, Facilities, and Reference Data
  - Real-time filtering

- **Input Validation**: Comprehensive validation for claim editing
  - Required field validation
  - Number validation (prevents negative values)
  - Text sanitization (trimming whitespace)
  - Error alerts with clear messages

- **Shared Components**: Consolidated `CollapsibleSection` into `SharedComponents.swift`
  - Removed duplicate definitions from `AddVeteranView` and `EditClaimView`
  - Single source of truth for collapsible section behavior

### Changed
- **File Upload UI**: Simplified to single upload button
  - Removed Menu dropdown
  - Removed separate upload icon
  - Single `doc.badge.plus` button for file upload

- **PDF Export Metadata**: Switched from KVC to PDFDocumentAttribute API
  - Proper type-safe metadata handling
  - Better error handling for unsupported keys

- **Keychain Storage**: Enhanced with fallback mechanisms
  - Attempts data protection keychain first, falls back to standard keychain
  - Better error recovery

- **Document Storage**: Added fallback for encryption failures
  - Stores unencrypted if encryption fails (with warning)
  - Prevents complete upload failure

- **Error Messages**: Enhanced throughout application
  - More detailed error messages for debugging
  - User-friendly messages for common errors
  - Path information in decoding errors

### Improved
- **Code Organization**: Consolidated shared components
- **Error Handling**: More comprehensive error handling throughout
- **User Experience**: Better feedback and visual indicators
- **Documentation**: Updated README and developer guides

## [2024-12] - VA.gov API Integration

### Added
- **Multi-Key API Support**: Separate API keys for Benefits and Forms APIs
- **VA Forms API Integration**: Browse and search VA forms
- **Benefits Reference Data API**: Access to states, countries, and reference data
- **Facilities API**: VA facility information (when authorized)
- **Environment Switching**: Toggle between Sandbox and Production
- **Connection Testing**: Built-in API connection verification
- **Unified Search**: Single search bar for all VA.gov data

### Fixed
- **API Key Storage**: Secure Keychain storage for multiple keys
- **Error Handling**: Comprehensive error messages for API issues
- **Data Models**: Flexible decoding for various API response formats

## [2024-11] - Production Readiness

### Added
- **Edit Claim Modal**: Complete edit capability with all fields
- **Search Functionality**: Added to Kanban board
- **Input Validation**: Comprehensive validation throughout app
- **Error Alerts**: User-friendly error messages
- **Production Readiness Documentation**: PRODUCTION_READINESS.md
- **Testing Guide**: TESTING_GUIDE.md

### Fixed
- **Build Errors**: Resolved all compilation errors
- **Duplicate Code**: Consolidated CollapsibleSection
- **Code Organization**: Shared components in SharedComponents.swift

## [2024-10] - AI Copilot & HIPAA Compliance

### Added
- **AI Copilot**: GPT-4 integration for VA claims guidance
- **Advanced De-identification**: GPT-4 powered PHI removal
- **Document Analysis**: PDF text extraction and AI analysis
- **Prompt Templates**: Pre-configured templates for common scenarios
- **PDF Export**: Export chat conversations as PDFs
- **Audit Logging**: Complete tracking of AI interactions
- **Secure Storage**: Encrypted conversation storage

### Fixed
- **HIPAA Compliance**: Comprehensive PHI protection
- **Security**: End-to-end encryption with Keychain storage
- **Error Handling**: Comprehensive error handling with fallbacks

## [2024-09] - Core Features

### Added
- **Veteran Management**: 200+ fields for comprehensive profiles
- **Claims Management**: 80+ fields for detailed claim tracking
- **Kanban Board**: Visual workflow management
- **Document Management**: Secure file storage and organization
- **Email Integration**: HIPAA-compliant Paubox integration
- **Activity Logging**: Complete audit trail
- **Search Functionality**: Global search across all data

### Fixed
- **Data Models**: SwiftData persistence with proper relationships
- **UI/UX**: Modern design with glass morphism
- **Performance**: Optimized for large datasets

---

## Version History

- **v1.0.0** (Current): Production-ready with all core features
- **v0.9.0**: AI Copilot and HIPAA compliance
- **v0.8.0**: VA.gov API integration
- **v0.7.0**: Production readiness improvements
- **v0.6.0**: Core features and data models

---

## Notes

- All dates are approximate and based on development timeline
- Features marked as "Fixed" may have been issues discovered during development
- "Added" features represent new functionality
- "Changed" features represent modifications to existing functionality
- "Improved" features represent enhancements to existing functionality

---

**Last Updated**: January 2025  
**Maintained By**: Veterans Claims Foundation Development Team

