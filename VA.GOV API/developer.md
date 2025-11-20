# VA.gov API Key Migration Guide

## Overview

This document explains the current multi-key implementation for VA.gov API integration and provides step-by-step instructions for reverting to a single API key once production API keys are available from the VA.

## Current State: Multi-Key System

### Why We Have Two Keys

The app currently uses **two separate API keys** for VA.gov services:

1. **Benefits Reference Data API Key** (`vagov-api-key-benefits`)
   - Used for: Benefits Reference Data, Facilities, and other reference APIs
   - Stored in Keychain as: `vagov-api-key-benefits`

2. **Forms API Key** (`vagov-api-key-forms`)
   - Used specifically for: VA Forms API
   - Stored in Keychain as: `vagov-api-key-forms`

### Reason for Multi-Key System

The sandbox environment requires **separate authorization** for each API service:
- Even though Forms API data is "open/public", it still requires specific API key authorization
- The sandbox environment has service-based authorization that doesn't grant access to all services with a single key
- This is a **sandbox limitation**, not a production requirement

**Reference**: See `API-Access-Investigation-Results.md` for detailed investigation findings.

## Production State: Single Key Expected

Once you receive a **production API key** from the VA, it should work for **all services** (Forms, Facilities, Benefits Reference Data, etc.) with a single key. At that point, we need to revert the app to use a single key.

---

## Recent Updates & Improvements

### Multi-Key Implementation (Latest)
- **Separate Key Storage**: Benefits and Forms API keys stored separately in Keychain
- **UI Updates**: Separate input fields and status indicators for each key
- **API Routing**: Automatic key selection based on endpoint
- **Connection Testing**: Tests both keys independently
- **Migration Support**: Automatic migration from single key to multi-key (if needed)

### Forms API Enhancements (Latest)
- **Decoding Fixes**: Resolved snake_case field mapping issues
- **Mixed Type Handling**: Flexible decoding for `benefit_categories` (strings, objects, numbers)
- **Optional Fields**: Made `sha256` optional to handle null values
- **Error Messages**: Enhanced error messages for debugging decoding issues
- **URL Opening**: Click forms to open in browser

### Error Handling (Latest)
- **Empty Response Detection**: Detects and reports empty API responses
- **Authorization Errors**: Clear messages for 403 Forbidden errors
- **Decoding Errors**: Detailed error messages with path information
- **Connection Testing**: Comprehensive connection testing with status indicators

---

## Migration Plan: Revert to Single Key

### Prerequisites

Before starting the migration, ensure you have:

1. ✅ **Production API key** from VA.gov that works for all services
2. ✅ **Tested the production key** against all endpoints:
   - Forms API: `https://api.va.gov/services/va_forms/v0/forms`
   - Facilities API: `https://api.va.gov/services/va_facilities/v1/facilities`
   - Benefits Reference Data: `https://api.va.gov/services/benefits-reference-data/v1/*`
3. ✅ **Backup of current code** (create a git branch)
4. ✅ **Access to test environment** to verify changes

### Step 1: Create Migration Branch

```bash
git checkout -b revert-to-single-va-api-key
```

### Step 2: Update VAGovAPIService.swift

**File**: `Veterans/Veterans/VAGovAPIService.swift`

#### 2.1 Remove Multi-Key Constants

**Find and remove:**
```swift
private let keychainAccountBenefits = "vagov-api-key-benefits" // For Benefits Reference Data, Facilities, etc.
private let keychainAccountForms = "vagov-api-key-forms" // For Forms API
```

**Replace with:**
```swift
private let keychainAccount = "vagov-api-key" // Single API key for all services
```

#### 2.2 Simplify API Key Storage Methods

**Remove these methods:**
- `storeBenefitsAPIKey(_:)`
- `storeFormsAPIKey(_:)`
- `retrieveBenefitsAPIKey()`
- `retrieveFormsAPIKey()`
- `hasBenefitsAPIKey()`
- `hasFormsAPIKey()`

**Keep and update:**
- `storeAPIKey(_:)` - Update to use `keychainAccount`
- `retrieveAPIKey()` - Update to use `keychainAccount`
- `hasAPIKey()` - Keep as-is (already exists)

**New simplified implementation:**

```swift
/// Store API key securely in Keychain
func storeAPIKey(_ apiKey: String) throws {
    let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmedKey.isEmpty else {
        throw VAGovError.keychainStoreFailed(errSecParam)
    }
    
    let keyData = trimmedKey.data(using: .utf8)!
    
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
    
    print("VA.gov API Key stored: Length=\(trimmedKey.count), First 4 chars=\(String(trimmedKey.prefix(4)))...")
}

/// Retrieve API key from Keychain
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
```

#### 2.3 Update makeRequest Method

**Find:**
```swift
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
    // ... rest of method
}
```

**Replace with:**
```swift
private func makeRequest<T: Codable>(
    endpoint: String,
    responseType: T.Type,
    queryParams: [String: String] = [:]
) async throws -> T {
    
    guard hasAPIKey() else {
        throw VAGovError.noAPIKey
    }
    
    let apiKey = try retrieveAPIKey()
    // ... rest of method (unchanged)
}
```

#### 2.4 Update All API Methods

**Remove `useFormsKey: true` parameter from:**
- `getAllForms()` - Remove `useFormsKey: true` from `makeRequest` call
- `getForm(_:)` - Remove `useFormsKey: true` from `makeRequest` call
- `testAlternativeEndpoint()` - Remove `useFormsKey: true` from `makeRequest` call

**Example change:**
```swift
// Before
let response: FormsResponse = try await makeRequest(
    endpoint: "/services/va_forms/v0/forms",
    responseType: FormsResponse.self,
    useFormsKey: true
)

// After
let response: FormsResponse = try await makeRequest(
    endpoint: "/services/va_forms/v0/forms",
    responseType: FormsResponse.self
)
```

#### 2.5 Add Key Migration Logic (Optional but Recommended)

Add a migration method to consolidate existing keys when the app first runs with the new code:

```swift
/// Migrate existing multi-key setup to single key
/// This should be called once during app initialization
func migrateToSingleKeyIfNeeded() {
    // Check if we have both keys
    let hasBenefits = hasBenefitsAPIKey()
    let hasForms = hasFormsAPIKey()
    
    // If we have both, prefer Benefits key (or Forms if Benefits doesn't exist)
    if hasBenefits {
        do {
            let key = try retrieveBenefitsAPIKey()
            try storeAPIKey(key)
            print("✅ Migrated Benefits API key to single key")
        } catch {
            print("❌ Failed to migrate Benefits key: \(error)")
        }
    } else if hasForms {
        do {
            let key = try retrieveFormsAPIKey()
            try storeAPIKey(key)
            print("✅ Migrated Forms API key to single key")
        } catch {
            print("❌ Failed to migrate Forms key: \(error)")
        }
    }
    
    // Clean up old keys (optional - can be done later)
    // deleteOldKeychainEntries()
}
```

**Note**: You'll need to keep the old methods temporarily for migration, then remove them after migration is complete.

### Step 3: Update EmailSettings.swift

**File**: `Veterans/Veterans/EmailSettings.swift`

#### 3.1 Remove Multi-Key State Variables

**Find and remove:**
```swift
@State private var showVAGovBenefitsAPIKeyAlert: Bool = false
@State private var showVAGovFormsAPIKeyAlert: Bool = false
@State private var newVAGovBenefitsAPIKey: String = ""
@State private var newVAGovFormsAPIKey: String = ""
```

**Replace with:**
```swift
@State private var showVAGovAPIKeyAlert: Bool = false
@State private var newVAGovAPIKey: String = ""
```

#### 3.2 Update UI to Single Key Input

**Find the VA.GOV API Configuration section** (around line 344) and replace the two separate key sections with a single section:

**Remove:**
- "Benefits Reference Data API Key" section
- "Forms API Key" section

**Replace with:**
```swift
// MARK: - VA.GOV API Configuration
VStack(alignment: .leading, spacing: 16) {
    Text("VA.GOV API Configuration")
        .font(.headline)
    
    // API Key
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("VA.gov API Key")
                    .font(.headline)
                Text("Used for all VA.gov API services (Forms, Facilities, Benefits Reference Data)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Change") {
                vaGovSaveStatus = ""
                newVAGovAPIKey = ""
                showVAGovAPIKeyAlert = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        
        HStack {
            Text("Status:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(vaGovService.hasAPIKey() ? "Configured" : "Not configured")
                .font(.caption)
                .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
            
            Spacer()
            
            Image(systemName: vaGovService.hasAPIKey() ? "checkmark.circle.fill" : "exclamationmark.triangle")
                .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
        }
    }
    .padding()
    .background(Color(NSColor.controlBackgroundColor))
    .cornerRadius(8)
    
    if !vaGovSaveStatus.isEmpty {
        Text(vaGovSaveStatus)
            .font(.caption)
            .foregroundColor(vaGovSaveStatus.contains("Error") ? .red : .green)
            .padding(.horizontal)
    }
    
    // Environment picker, Connection Test, Configuration Details sections remain the same
    // ... (keep existing code)
}
```

#### 3.3 Update Alert Definitions

**Find and remove:**
```swift
.alert("Change Benefits Reference Data API Key", isPresented: $showVAGovBenefitsAPIKeyAlert) {
    SecureField("New Benefits Reference Data API Key", text: $newVAGovBenefitsAPIKey)
    Button("Cancel", role: .cancel) { }
    Button("Save") {
        saveVAGovBenefitsAPIKey()
    }
} message: {
    Text("Enter your Benefits Reference Data API key...")
}

.alert("Change Forms API Key", isPresented: $showVAGovFormsAPIKeyAlert) {
    SecureField("New Forms API Key", text: $newVAGovFormsAPIKey)
    Button("Cancel", role: .cancel) { }
    Button("Save") {
        saveVAGovFormsAPIKey()
    }
} message: {
    Text("Enter your Forms API key...")
}
```

**Replace with:**
```swift
.alert("Change VA.gov API Key", isPresented: $showVAGovAPIKeyAlert) {
    SecureField("New VA.gov API Key", text: $newVAGovAPIKey)
    Button("Cancel", role: .cancel) { }
    Button("Save") {
        saveVAGovAPIKey()
    }
} message: {
    Text("Enter your VA.gov API key. This key is used for all VA.gov API services (Forms, Facilities, Benefits Reference Data). This will be stored securely in the macOS Keychain.")
}
```

#### 3.4 Update Helper Methods

**Remove:**
- `saveVAGovBenefitsAPIKey()`
- `saveVAGovFormsAPIKey()`

**Update or add:**
```swift
private func saveVAGovAPIKey() {
    guard !newVAGovAPIKey.isEmpty else {
        vaGovSaveStatus = "Error: API key cannot be empty"
        return
    }
    
    do {
        try vaGovService.storeAPIKey(newVAGovAPIKey)
        vaGovSaveStatus = "VA.gov API key saved successfully"
        newVAGovAPIKey = ""
    } catch {
        vaGovSaveStatus = "Error saving VA.gov API key: \(error.localizedDescription)"
    }
}
```

#### 3.5 Update Connection Test Button

**Find:**
```swift
.disabled(vaGovTestConnectionStatus == .testing || (!vaGovService.hasBenefitsAPIKey() && !vaGovService.hasFormsAPIKey()))
```

**Replace with:**
```swift
.disabled(vaGovTestConnectionStatus == .testing || !vaGovService.hasAPIKey())
```

#### 3.6 Update Configuration Details Section

**Find and remove:**
```swift
HStack {
    Text("Benefits API Key:")
        .font(.caption)
        .foregroundColor(.secondary)
    Spacer()
    Text(vaGovService.hasBenefitsAPIKey() ? "Configured" : "Not configured")
        .font(.caption)
        .foregroundColor(vaGovService.hasBenefitsAPIKey() ? .green : .orange)
}

HStack {
    Text("Forms API Key:")
        .font(.caption)
        .foregroundColor(.secondary)
    Spacer()
    Text(vaGovService.hasFormsAPIKey() ? "Configured" : "Not configured")
        .font(.caption)
        .foregroundColor(vaGovService.hasFormsAPIKey() ? .green : .orange)
}
```

**Replace with:**
```swift
HStack {
    Text("API Key:")
        .font(.caption)
        .foregroundColor(.secondary)
    Spacer()
    Text(vaGovService.hasAPIKey() ? "Configured" : "Not configured")
        .font(.caption)
        .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
}
```

### Step 4: Update testConnection Method

**File**: `Veterans/Veterans/VAGovAPIService.swift`

Update the `testConnection()` method to use the single key for all tests. The method should test all endpoints with the same key.

### Step 5: Clean Up Old Keychain Entries (Optional)

After migration is complete and verified, you can optionally delete the old keychain entries:

```swift
private func deleteOldKeychainEntries() {
    let oldAccounts = ["vagov-api-key-benefits", "vagov-api-key-forms"]
    
    for account in oldAccounts {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

---

## Testing Checklist

After making the changes, test the following:

### ✅ API Key Management
- [ ] Can store a single API key
- [ ] Can retrieve the stored API key
- [ ] Can change/update the API key
- [ ] Key is stored securely in Keychain
- [ ] Old multi-keys are migrated (if migration code is included)

### ✅ API Functionality
- [ ] Forms API works with single key
- [ ] Facilities API works with single key
- [ ] Benefits Reference Data API works with single key
- [ ] All endpoints return data successfully
- [ ] Error handling works correctly (403, 401, etc.)

### ✅ UI/UX
- [ ] Settings screen shows single API key input
- [ ] Status indicator shows "Configured" when key is set
- [ ] Connection test button works
- [ ] Configuration details show correct status
- [ ] Alerts work for changing API key

### ✅ Environment Switching
- [ ] Can switch between Sandbox and Production
- [ ] Single key works in both environments (if applicable)
- [ ] Environment setting persists

---

## Rollback Plan

If issues arise after migration:

1. **Revert the code changes:**
   ```bash
   git checkout main
   ```

2. **Restore old keys from backup** (if you backed up keychain entries)

3. **Re-apply multi-key code** if needed

---

## Key Information for VA.gov Production Key

When requesting the production API key from VA.gov, ensure you have:

### Required Information
- ✅ **Organization name**
- ✅ **Use case description**
- ✅ **Expected API usage** (Forms, Facilities, Benefits Reference Data)
- ✅ **Production environment access** (not just sandbox)
- ✅ **Contact information**

### Testing the Production Key

Before migrating, test the production key with:

```bash
# Test Forms API
curl -X GET 'https://api.va.gov/services/va_forms/v0/forms' \
  --header 'apikey: YOUR_PRODUCTION_KEY' \
  --header 'accept: application/json'

# Test Facilities API
curl -X GET 'https://api.va.gov/services/va_facilities/v1/facilities?bbox[]=-122.4&bbox[]=37.8&bbox[]=-122.3&bbox[]=37.9' \
  --header 'apikey: YOUR_PRODUCTION_KEY' \
  --header 'accept: application/json'

# Test Benefits Reference Data
curl -X GET 'https://api.va.gov/services/benefits-reference-data/v1/states' \
  --header 'apikey: YOUR_PRODUCTION_KEY' \
  --header 'accept: application/json'
```

All three should return `200 OK` with data if the key is properly authorized.

---

## Questions to Ask VA.gov Support

If you're unsure about the production key:

1. **"Does this production API key work for all VA.gov API services (Forms, Facilities, Benefits Reference Data)?"**
2. **"Do I need separate keys for different services in production, or is one key sufficient?"**
3. **"What are the rate limits for this production key?"**
4. **"Are there any service-specific authorizations needed beyond the API key?"**

---

## Summary

**Current State**: Multi-key system (Benefits + Forms) for sandbox environment  
**Target State**: Single key for all services in production  
**Migration Complexity**: Medium (requires changes in 2 main files)  
**Estimated Time**: 2-4 hours (including testing)  
**Risk Level**: Low (can rollback easily)

---

## Additional Notes

- The migration can be done incrementally (keep old methods temporarily for migration)
- Consider adding a feature flag to switch between multi-key and single-key modes during transition
- Document any production-specific differences you discover during testing
- Update this guide if you find any additional steps needed

---

**Last Updated**: November 20, 2025  
**Migration Completed**: [ ] Yes [ ] No  
**Production Key Tested**: [ ] Yes [ ] No
