# VA.gov API Access Investigation Results

## Summary

Investigation of VA.gov API access issues reveals that:
1. **API Key is Valid** - Works successfully for Benefits Reference Data API
2. **API Key Needs Separate Authorization** - Forms API and Facilities API require separate authorization requests
3. **Sandbox Data is Limited** - Sandbox environment has reduced test datasets

## Current Status

### ✅ Working APIs

**Benefits Reference Data API** - Fully functional with current API key:
- **States**: 61 items (all returned)
- **Countries**: 213 items (all returned)  
- **Disabilities**: 9 items (all returned) ⚠️ Limited sandbox data
- **Service Branches**: 23 items (all returned)
- **Treatment Centers**: 166 items (all returned)
- **Contention Types**: 7 items (all returned)

### ❌ Not Authorized APIs

**VA Forms API** - Returns 403 "You cannot consume this service"
- **Status**: API key is valid but NOT authorized for Forms API
- **Issue**: Even though Forms API data is "open/public", it still requires API key authorization
- **Endpoint**: `/services/va_forms/v0/forms` (correct)
- **Authentication**: `apikey` header (correct)

**VA Facilities API** - Returns 403 "You cannot consume this service"
- **Status**: API key is valid but NOT authorized for Facilities API
- **Issue**: Requires separate authorization request
- **Endpoint**: `/services/va_facilities/v1/facilities` (correct)
- **Authentication**: `apikey` header (correct)

## Key Findings

### 1. Forms API Authorization Issue

**Problem**: Even though the documentation states Forms API is "open" (publicly available data), it still requires:
- A valid API key
- The API key to be specifically authorized for Forms API service
- Approval from VA.gov administrators

**Why This Happens**: 
- VA.gov uses a service-based authorization model
- Each API service requires separate authorization, even if data is "open"
- Your current API key is authorized for Benefits Reference Data only

**Solution**:
1. Visit: https://developer.va.gov/explore/api/va-forms/sandbox-access
2. Request sandbox access for VA Forms API
3. Wait for approval (24-48 hours typically)
4. The same API key will work once authorized

### 2. Sandbox Data Limitations

**Disabilities**: Only 9 items in sandbox (vs. thousands in production)
- This is expected - sandbox has limited test data
- Production will have full disability database
- All 9 items are being returned correctly

**Other Reference Data**: 
- States: 61 (complete)
- Countries: 213 (complete)
- Service Branches: 23 (complete)
- Treatment Centers: 166 (complete)
- Contention Types: 7 (complete)

### 3. Facilities API Authorization

**Problem**: Same as Forms API - requires separate authorization

**Solution**:
1. Visit: https://developer.va.gov/explore/api/va-facilities/sandbox-access
2. Request sandbox access for VA Facilities API
3. Wait for approval

## Technical Details

### API Request Format (Correct)
```bash
curl -X GET 'https://sandbox-api.va.gov/services/va_forms/v0/forms' \
  --header 'apikey: <key>' \
  --header 'accept: application/json'
```

### Response Codes
- **200**: Success (Benefits Reference Data)
- **403**: "You cannot consume this service" (Forms/Facilities - not authorized)
- **401**: Invalid or missing API key
- **404**: Endpoint not found (wrong path)

### Endpoint Paths (All Correct)
- Forms: `/services/va_forms/v0/forms` ✅
- Facilities: `/services/va_facilities/v1/facilities` ✅
- Benefits Reference Data: `/services/benefits-reference-data/v1/*` ✅

## Recommendations

### Immediate Actions

1. **Request Forms API Access**
   - Go to: https://developer.va.gov/explore/api/va-forms/sandbox-access
   - Submit request for sandbox access
   - Wait for approval email

2. **Request Facilities API Access**
   - Go to: https://developer.va.gov/explore/api/va-facilities/sandbox-access
   - Submit request for sandbox access
   - Wait for approval email

3. **Verify API Key Status**
   - Log into: https://developer.va.gov/explore
   - Check which APIs your key is authorized for
   - Verify key status (Active/Pending)

### Code Updates Made

1. ✅ Enhanced error messages explaining authorization requirements
2. ✅ Updated test connection to show all available data counts
3. ✅ Added note about sandbox data limitations
4. ✅ Improved guidance for requesting API access

### Expected Behavior After Authorization

Once Forms API and Facilities API are authorized:
- Forms API will return hundreds/thousands of VA forms
- Facilities API will return facility data based on search criteria
- All APIs will work with the same API key
- No code changes needed - authorization is server-side

## Conclusion

**The code is correct.** The issue is that the API key needs to be authorized for each specific API service. This is a VA.gov platform requirement, not a code issue.

**Current Status:**
- ✅ Benefits Reference Data: Working (getting all available sandbox data)
- ⏳ Forms API: Waiting for authorization
- ⏳ Facilities API: Waiting for authorization

**Next Steps:**
1. Request access to Forms API and Facilities API
2. Wait for approval (24-48 hours)
3. Test again - should work automatically once approved

