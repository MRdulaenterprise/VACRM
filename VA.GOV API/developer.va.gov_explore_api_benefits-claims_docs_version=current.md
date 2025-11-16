---
url: "https://developer.va.gov/explore/api/benefits-claims/docs?version=current"
title: "VA API Platform | Benefits Claims API Documentation"
---

[Skip to main content](https://developer.va.gov/explore/api/benefits-claims/docs?version=current#main)

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
3. [Benefits Claims API](https://developer.va.gov/explore/api/benefits-claims)
4. [Docs](https://developer.va.gov/explore/api/benefits-claims/docs?version=current#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/benefits-claims/docs#page-header) In this section

- [Benefits Claims API](https://developer.va.gov/explore/api/benefits-claims)
- [Docs](https://developer.va.gov/explore/api/benefits-claims/docs)
- [Authorization Code Grant](https://developer.va.gov/explore/api/benefits-claims/authorization-code)
- [Client Credentials Grant](https://developer.va.gov/explore/api/benefits-claims/client-credentials)
- [Test data](https://developer.va.gov/explore/api/benefits-claims/test-users)
- [Release notes](https://developer.va.gov/explore/api/benefits-claims/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/benefits-claims/sandbox-access)

# Docs

## Benefits Claims API

Select a versionv2 - Internal VA Use Onlyv1 - Non-VA Use

Update page

[https://api.va.gov/internal/docs/benefits-claims/v2/openapi.json](https://api.va.gov/internal/docs/benefits-claims/v2/openapi.json)

## Background

The Benefits Claims API Version 2 lets internal consumers:

- Retrieve existing claim information, including status, by claim ID.
- Automatically establish an intent to file at VA.
- Automatically establish a disability compensation claim (VA Form 21-526EZ) at VA.
- Digitally submit supporting documentation for disability compensation claims.
- Retrieve a claimant’s currently appointed accredited representative.
- Request the appointment of an accredited representative, on behalf of a claimant.
- Accept or decline the request to appoint an accredited representative, on behalf of the representative.
- Automatically establish an organization as a claimant’s accredited representative (VA Form 21-22).
- Automatically establish an individual as a claimant’s accredited representative (VA Form 21-22a).

You should use the [Benefits Claims API Version 1](https://developer.va.gov/explore/benefits/docs/claims?version=current) if you are a consumer outside of VA and do not have the necessary VA agreements to use this API.

## Appointing an accredited representative for dependents

Dependents of Veterans, such as spouses, children (biological and step), and parents (biological and foster) may be eligible for VA benefits and can request representation by an accredited representative.

To file claims through an accredited representative, dependents must appoint their own. Once appointed, the representative will have power of attorney (POA) to assist with the dependentʼs VA claims.

Before appointing a representative, the dependentʼs relationship to the Veteran must be established. If a new representative is being appointed, the dependentʼs relationship to the Veteran will be validated first. The representative will be appointed to the dependent, not the Veteran.

## Technical Overview

This API accepts a payload of requests and responses with the payload identifying the claim and claimant. Responses provide the submission’s processing status. Responses also provide a unique ID which can be used with the appropriate GET endpoint to return detailed, end-to-end claims status tracking.

End-to-end claims tracking provides the status of claims as they move through the submission process, but does not return whether the claim was approved or denied.

### Claim statuses

After you submit a disability compensation claim with the `POST /veterans/{veteranId}/526/synchronous` endpoint, it is then established in Veterans Benefits Management System (VBMS). A `202` response means that the claim was successfully submitted by the API. However, it does not mean VA has received the required 526EZ PDF.

To confirm the status of your submission, use the `GET /veterans/{veteranId}/claims/{id}` endpoint and the ID returned with your submission response. Statuses are:

- **Pending**: The claim is successfully submitted for processing
- **Errored**: The submission encountered upstream errors
- **Canceled**: The claim was identified as a duplicate, or another issue caused the claim to be canceled.

  - For duplicate claims, the claim's progress is tracked under a different Claim ID than the one returned in your submission response.
- **Claim received**: The claim was received, but hasn't been assigned to a reviewer yet.
- **Initial review**: The claim has been assigned to a reviewer, who will determine if more information is needed.
- **Evidence gathering, review, and decision**: VA is gathering evidence to make a decision from health care providers, government agencies, and other sources.
- **Preparation for notification**: VA has made a decision on the claim, and is getting a decision letter ready to mail.
- **Complete**: VA has sent a decision letter by U.S. mail.

### Finding a claimant's unique VA ID

This API uses Integration Control Number (ICN) as a unique identifier to identify the subject of each API request. This identifier should be used as the `{veteranId}` parameter in request URLs.

**Note**: though ICNs are typically static, they may change over time. If a specific ICN suddenly responds with a `404 not found` error, it may have changed. It’s a good idea to periodically check the ICN for each claimant.

### Authentication and authorization

The authentication model for the Benefits Claims Version 2 is based on OAuth 2.0 / OpenID Connect and supports the [client credentials grant](https://developer.va.gov/explore/authorization/docs/client-credentials?api=claims).

**Important**: To get production access, you must either work for VA or have specific VA agreements in place. If you have questions, [contact us](https://developer.va.gov/support/contact-us).

### Test data for sandbox environment use

We use mock [test data in the sandbox environment](https://developer.va.gov/explore/api/benefits-claims/test-users/2671/f1097c9772b447bb755b26dcd3e652aecad632389a28f0e19a7ebb082808db39). Sandbox test data and test users for the Benefits Claims API are valid for all versions of the API.

### Claims   Allows authenticated and authorized users to access claims data for a given VA claimant. No data is returned if the user is not authenticated and authorized.

GET
/veterans/{veteranId}/claims

Find all benefits claims for a VA claimant

GET
/veterans/{veteranId}/claims/{id}

Find claim by ID.

### 5103 Waiver   Allows authenticated and authorized users to file a 5103 Notice Response on a claim.

POST
/veterans/{veteranId}/claims/{id}/5103

Submit Evidence Waiver 5103

### Intent to File   Allows authenticated and authorized users to automatically establish an Intent to File (21-0966) in VBMS.

GET
/veterans/{veteranId}/intent-to-file/{type}

Returns claimant's last active Intent to File submission for given benefit type.

POST
/veterans/{veteranId}/intent-to-file

Submit form 0966 Intent to File.

POST
/veterans/{veteranId}/intent-to-file/validate

Validate form 0966 Intent to File.

### Disability Compensation Claims   Allows authenticated and authorized users to automatically establish a Disability Compensation Claim (21-526EZ) in VBMS

POST
/veterans/{veteranId}/526/synchronous

Submits disability compensation claim synchronously (restricted access)

POST
/veterans/{veteranId}/526/validate

Validates a 526 claim form submission.

POST
/veterans/{veteranId}/526/generatePDF/minimum-validations

Returns filled out 526EZ form as PDF with minimum validations (restricted access)

### Power of Attorney   Allows authenticated and authorized users to automatically establish power of attorney appointments to an organization or an individual. Organizations and individuals must be VA accredited representatives.

GET
/veterans/{veteranId}/power-of-attorney

Retrieves current power of attorney

POST
/veterans/{veteranId}/power-of-attorney-request

Creates power of attorney request for an accredited representative

POST
/veterans/power-of-attorney-requests

Retrieves power of attorney requests for accredited representatives

GET
/veterans/power-of-attorney-requests/{id}

Retrieves a power of attorney request

POST
/veterans/power-of-attorney-requests/{id}/decide

Submits representative decision for a power of attorney request

POST
/veterans/{veteranId}/2122/validate

Validates request to establish an organization as a claimant’s accredited representative

POST
/veterans/{veteranId}/2122

Automatically establishes an organization as a claimant’s accredited representative (VA Form 21-22)

POST
/veterans/{veteranId}/2122a/validate

Validates request to establish an individual as a claimant’s accredited representative (VA Form 21-22a)

POST
/veterans/{veteranId}/2122a

Automatically establishes an individual as a claimant’s accredited representative (VA Form 21-22a)

GET
/veterans/{veteranId}/power-of-attorney/{id}

Checks status of power of attorney submission (VA Forms 21-22 or 21-22a)

[Back to topBack to top](https://developer.va.gov/explore/api/benefits-claims/docs?version=current#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: