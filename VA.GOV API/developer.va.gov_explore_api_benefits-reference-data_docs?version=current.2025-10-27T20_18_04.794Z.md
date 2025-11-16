[Skip to main content](https://developer.va.gov/explore/api/benefits-reference-data/docs?version=current#main)

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
3. [Benefits Reference Data API](https://developer.va.gov/explore/api/benefits-reference-data)
4. [Docs](https://developer.va.gov/explore/api/benefits-reference-data/docs?version=current#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/benefits-reference-data/docs#page-header) In this section

- [Benefits Reference Data API](https://developer.va.gov/explore/api/benefits-reference-data)
- [Docs](https://developer.va.gov/explore/api/benefits-reference-data/docs)
- [Test data](https://developer.va.gov/explore/api/benefits-reference-data/test-users)
- [Release notes](https://developer.va.gov/explore/api/benefits-reference-data/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/benefits-reference-data/sandbox-access)

# Docs

## Benefits Reference Data API

[https://api.va.gov/internal/docs/benefits-reference-data/v1/openapi.json](https://api.va.gov/internal/docs/benefits-reference-data/v1/openapi.json)

This API lets you look up information that is specifically
filtered and formatted to be accepted within VA benefits claims.
Unless otherwise specified, data returned may be used for any
benefits claim that accepts the data. The information returned is:

- Contention types
- Countries
- Disabilities
- Intake sites
- Military pay types
- Service branches
- Special circumstances
- States
- VA medical treatment facilities

## Technical overview

All returned data is pulled from the Veterans Benefits Administration
(VBA). The data cache is refreshed daily.

Each endpoint returns a specific information type. No input parameters
are needed to return a list of values unless otherwise specified under
the endpoint documentation. None of the endpoints send or receive
protected health information (PHI) or personally identifiable information
(PII).

### Authentication and Authorization

API requests are authorized through a symmetric API token provided in an
HTTP header with name 'apikey'.

### Testing in the sandbox environment

Test data from the sandbox environment is for testing your API only
and is not guaranteed to be up-to-date.

This API has a reduced API rate limit in the sandbox, so when you're ready to move
to production, be sure to
[request a production API key.](https://developer.va.gov/go-live)

### Reference Data

GET
/contention-types

Retrieve a list of contention types.

GET
/countries

Retrieve a list of countries.

GET
/disabilities

Retrieve a list of disabilities.

GET
/intake-sites

Retrieve a list of intake sites.

GET
/military-pay-types

Retrieve a list of military pay types.

GET
/service-branches

Retrieve a list of service branches.

GET
/special-circumstances

Retrieve a list of special circumstances.

GET
/states

Retrieve a list of states.

GET
/treatment-centers

Retrieve a list of treatment centers.

#### Schemas

BadRequest

ContentionType

ContentionTypesResponse

CountriesResponse

DisabilitiesResponse

Disability

IntakeSite

IntakeSitesResponse

InternalServerError

MilitaryPayType

MilitaryPayTypesResponse

PageLink

ServiceBranch

ServiceBranchesResponse

ServiceUnavailable

SpecialCircumstance

SpecialCircumstancesResponse

StatesResponse

TreatmentCenter

TreatmentCentersResponse

[Back to topBack to top](https://developer.va.gov/explore/api/benefits-reference-data/docs?version=current#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: