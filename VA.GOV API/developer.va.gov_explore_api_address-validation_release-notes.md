---
url: "https://developer.va.gov/explore/api/address-validation/release-notes"
title: "VA API Platform | Address Validation API Release notes"
---

[Skip to main content](https://developer.va.gov/explore/api/address-validation/release-notes#main)

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
4. [Release notes](https://developer.va.gov/explore/api/address-validation/release-notes#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/address-validation/release-notes#page-header) In this section

- [Address Validation API](https://developer.va.gov/explore/api/address-validation)
- [Docs](https://developer.va.gov/explore/api/address-validation/docs)
- [Test data](https://developer.va.gov/explore/api/address-validation/test-users)
- [Release notes](https://developer.va.gov/explore/api/address-validation/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/address-validation/sandbox-access)

# Release notes

## Address Validation API

## May 15, 2024

We released version 3 (v3) of the Address Validation API. Updates include:

- `/validate` and `/candidate` endpoints.
  - Removing support for US Congressional District.
  - Adding country code support for both International Standards Organization (ISO) and Federal Information Processing Standards (FIPS).
- Renaming `/cityStateProvince` endpoint to `/locality` to reflect the capability of the endpoint.

- For ease of mapping, fields are renamed to be identical between this API and Contact Information API version 2 (v2).


To learn more, review the [Address Validation API v3 documentation](https://developer.va.gov/explore/api/address-validation/docs?version=v3).

* * *

## September 26, 2018

Create Address Validation API

- The ‘validate’ API accepts a structured JSON address object (broken down by street/city/state/zip/etc), and returns a result indicating whether the address is valid, and if so includes a canonicalized address and geocoding information (lat/long) for the address.

[Back to topBack to top](https://developer.va.gov/explore/api/address-validation/release-notes#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: