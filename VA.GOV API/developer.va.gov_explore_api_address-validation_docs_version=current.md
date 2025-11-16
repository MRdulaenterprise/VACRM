---
url: "https://developer.va.gov/explore/api/address-validation/docs?version=current"
title: "VA API Platform | Address Validation API Documentation"
---

[Skip to main content](https://developer.va.gov/explore/api/address-validation/docs?version=current#main)

![United States Flag](<Base64-Image-Removed>)

Official website of the United States government

Here's how you know

Here's how you know

[VA \| Developer](https://developer.va.gov/ "VA API Platform home page")

Search

- [Explore APIs](https://developer.va.gov/explore)

[Explore APIs](https://developer.va.gov/explore)

- [Production Access](https://developer.va.gov/production-access)

Production Access![](<Base64-Image-Removed>)

- [About](https://developer.va.gov/about)

About![](<Base64-Image-Removed>)

- [API Status](https://valighthouse.statuspage.io/)
- [Support](https://developer.va.gov/support)

[Support](https://developer.va.gov/support)

- Search

Menu

1. [Home](https://developer.va.gov/)
2. [Explore APIs](https://developer.va.gov/explore)
3. [Address Validation API](https://developer.va.gov/explore/api/address-validation)
4. [Docs](https://developer.va.gov/explore/api/address-validation/docs?version=current#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/address-validation/docs#page-header) In this section

- [Address Validation API](https://developer.va.gov/explore/api/address-validation)
- [Docs](https://developer.va.gov/explore/api/address-validation/docs)
- [Test data](https://developer.va.gov/explore/api/address-validation/test-users)
- [Release notes](https://developer.va.gov/explore/api/address-validation/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/address-validation/sandbox-access)

# Docs

## Address Validation API

Select a versionv3 - Current Version (Internal Only)v2 - Previous Version (Internal Only)v1 - Previous Version (Internal Only)

Update page

[https://api.va.gov/internal/docs/address-validation/v3/openapi.json](https://api.va.gov/internal/docs/address-validation/v3/openapi.json)

The Address Validation API accepts and validates an address and standardizes it for mailing. It can also help you process an address by:

- Inferring missing or incorrect address components
- Supplementing an address with additional information, such as geocode, latitude and longitude, and postal service metadata (when available)

## Technical Overview

The Address Validation API returns validated addresses as they appear in the USPS database for domestic addresses. It validates by separating the address into individual components and then providing component-level validation checks.

This API is certified by the United States Postal Service (USPS) Coding Accuracy Support System (CASS) and adheres to [United States Postal Service (USPS) Publication 28 standards](https://pe.usps.com/text/pub28/welcome.htm) for domestic, military, and US territory addresses.

For international addresses, validation relies on Universal Postal Union (UPU) standards.

## Validation

If an address is found, it is considered valid based on metadata returned by the Address Validation service, such as the confidence score and the [Delivery Point Validation (DPV)](https://postalpro.usps.com/address-quality/dpv).

If an address is found, there are multiple checks performed on the validated address. The address can fail validation for a variety of reasons, such as the inability to deliver (for domestic mailing addresses) or the format. For specific reasons why an address failed, refer to the error messages returned.

If an address is not found, it automatically fails validation.

## Address override indicator

Sometimes an entered address is accurate for a Veteran but does not pass validation rules. These instances can occur when an address is newer than what is in the CASS software or in regions where address data is less accurate.

Systems can accept these addresses despite the lack of address validation by submitting an "accepted address" (usually confirmed by the Veteran) to the Contact Information API (see Requirements below). An address is considered accepted after the address has been sent to the validation API and has failed validation, but the Veteran has confirmed the address is correct as entered. The accepted address can then be passed to the Contact Information API using an address override indicator set to show that the validation was overridden. To set an override indicator, the original address and the `overrideValidationKey` returned in the validation API response must be provided to the Contact Information API, in order to prove that a validation attempt has been made before overriding.

## Version Interoperability

To ensure interoperability between APIs and eliminate the need for transforming data as one API feeds into the other, we strongly recommend using versions of the following APIs that are compatible.

| ### If Using | ### Then Use... |
| --- | --- |
| Address Validation API v1/v2 | Contact Information API v1<br>Profile Service API v1/v2 |
| Address Validation API v3 | Contact Information API v2<br>Profile Service API v3 |

## Authorization

API requests are authorized through a symmetric API token provided in an HTTP header with name apikey.

**Important**: To get production access, you must either work for VA or have specific VA agreements in place. If you have questions, [contact us](https://developer.va.gov/support/contact-us).

[Creative Commons](https://developer.va.gov/terms-of-service)

### AddressValidation-v3   Address Standardization and Validation endpoints

POST
/validate

Validates and standardizes an address.

POST
/candidate

Discovers possible addresses when a request could match multiple records.

GET
/locality

Returns the city and state or province associated with a zip code or international postal code. For International addresses, locality lookup is only available for Canadian postal codes

#### Schemas

Message

AddressValidationRequest

Country

Province

RequestAddress

State

AddressValidationResponse

County

Geocode

ResponseAddress

CandidateAddressRequest

CandidateAddressResponse

CityStateAddressV3Response

Locality

ServiceResponse

[Back to topBack to top](https://developer.va.gov/explore/api/address-validation/docs?version=current#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: