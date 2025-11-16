---
url: "https://developer.va.gov/explore/api/appealable-issues/docs?version=current"
title: "VA API Platform | Appealable Issues API Documentation"
---

[Skip to main content](https://developer.va.gov/explore/api/appealable-issues/docs?version=current#main)

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
3. [Appealable Issues API](https://developer.va.gov/explore/api/appealable-issues)
4. [Docs](https://developer.va.gov/explore/api/appealable-issues/docs?version=current#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/appealable-issues/docs#page-header) In this section

- [Appealable Issues API](https://developer.va.gov/explore/api/appealable-issues)
- [Docs](https://developer.va.gov/explore/api/appealable-issues/docs)
- [Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code)
- [Client Credentials Grant](https://developer.va.gov/explore/api/appealable-issues/client-credentials)
- [Test data](https://developer.va.gov/explore/api/appealable-issues/test-users)
- [Release notes](https://developer.va.gov/explore/api/appealable-issues/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/appealable-issues/sandbox-access)

# Docs

## Appealable Issues API

[https://api.va.gov/internal/docs/appealable-issues/v0/openapi.json](https://api.va.gov/internal/docs/appealable-issues/v0/openapi.json)

The Appealable Issues API lets you retrieve a claimant's previously decided (appealable) issues and any chains of preceding issues. An "issue" is a problem listed in a claim to VA, and a claim may include multiple issues. Claimants may be Veterans or dependents of Veterans, such as spouses, children (biological and step), and parents (biological and foster).

You can use appealable issues data to submit a Higher-Level Review, Notice of Disagreement, or Supplemental Claim. Note that issues returned by the API may be eligible for appeal to VA, but eligibility is not guaranteed.

To check the status of all decision reviews or appeals for a specified individual, use the [Appeals Status API](https://developer.va.gov/explore/api/appeals-status/docs).

## Technical overview

### Authentication and authorization

The authorization model for the Appealable Issues API uses OAuth 2.0/OpenID Connect. The following models are supported:

- [Authorization Code Grant (ACG)](https://developer.va.gov/explore/api/appealable-issues/authorization-code)
- [Client Credentials Grant (CCG)](https://developer.va.gov/explore/api/appealable-issues/client-credentials)

**Important:** To get production access using client credentials grant, you must either work for VA or have specific VA agreements in place. If you have questions, [contact us](https://developer.va.gov/support/contact-us).

### Test data

Our sandbox environment is populated with [claimant test data](https://developer.va.gov/explore/api/appealable-issues/test-users) that can be used to test various response scenarios. This sandbox data contains no PII or PHI, but mimics real claimant account information.

### Appealable Issues

GET
/appealable-issues/{decisionReviewType}

Returns all appealable issues of the selected appeal type for a claimant.

#### Schemas

appealableIssue

appealableIssues

errorModel

[Back to topBack to top](https://developer.va.gov/explore/api/appealable-issues/docs?version=current#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: