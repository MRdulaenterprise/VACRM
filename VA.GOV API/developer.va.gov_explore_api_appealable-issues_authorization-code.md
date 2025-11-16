---
url: "https://developer.va.gov/explore/api/appealable-issues/authorization-code"
title: "VA API Platform | Appealable Issues API Authorization Code Grant"
---

[Skip to main content](https://developer.va.gov/explore/api/appealable-issues/authorization-code#main)

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
4. [Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header) In this section

- [Appealable Issues API](https://developer.va.gov/explore/api/appealable-issues)
- [Docs](https://developer.va.gov/explore/api/appealable-issues/docs)
- [Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code)
- [Client Credentials Grant](https://developer.va.gov/explore/api/appealable-issues/client-credentials)
- [Test data](https://developer.va.gov/explore/api/appealable-issues/test-users)
- [Release notes](https://developer.va.gov/explore/api/appealable-issues/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/appealable-issues/sandbox-access)

# Authorization Code Grant

## Appealable Issues API

## On this Page:

- [Getting Started](https://developer.va.gov/explore/api/appealable-issues/authorization-code#getting-started)
- [Building OpenID Connect Applications](https://developer.va.gov/explore/api/appealable-issues/authorization-code#building-oidc-apps)
  - [Initiating the Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code#authorization-code-grant)
    - [Requesting Authorization](https://developer.va.gov/explore/api/appealable-issues/authorization-code#requesting-authorization)
    - [Requesting a Token with an Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code#requesting-a-token)
    - [Manage Account](https://developer.va.gov/explore/api/appealable-issues/authorization-code#manage-account)
    - [Revoking Tokens](https://developer.va.gov/explore/api/appealable-issues/authorization-code#revoking-tokens)
    - [Revoking Grants](https://developer.va.gov/explore/api/appealable-issues/authorization-code#revoking-grants)
  - [PKCE (Proof Key for Code Exchange) Authorization](https://developer.va.gov/explore/api/appealable-issues/authorization-code#pkce-authorization)
    - [Requesting Authorization](https://developer.va.gov/explore/api/appealable-issues/authorization-code#pkce-requesting-authorization)
    - [Requesting a Token with an Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code#pkce-requesting-a-token)
- [Scopes](https://developer.va.gov/explore/api/appealable-issues/authorization-code#scopes)
- [ID Token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token)
- [Test Users](https://developer.va.gov/explore/api/appealable-issues/authorization-code#test-users)
- [HTTPS](https://developer.va.gov/explore/api/appealable-issues/authorization-code#https)

### It's good to know that:

- The access credentials we supply are for the sandbox environment only and will not work in the production environment.
- This page provides examples that show authorization server URLs in the sandbox environment, which differ depending on the API.
- When your application is ready, you may [apply for production access](https://developer.va.gov/production-access/request-prod-access).

## Getting Started

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

VA Developer uses the [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) standard to allow Veterans to authorize third-party applications or accredited representatives to access data on their behalf. The kind of access granted, process for authorization, and third party being authorized depends on the API.

The first step toward authorization is to [fill out our application](https://developer.va.gov/explore/api/appealable-issues/sandbox-access) and make sure to select the right OAuth API for your needs. To complete the form, you will need:

- Your organization name
- To know which OAuth APIs you want to access
- To know whether your app can securely hide a client secret
- Your OAuth redirect URI

After you submit the form, we'll send you an email containing access information for test data and the sandbox environment, including a client ID and secret if you can safely store a client secret. If you cannot safely store a client secret, we will send you a client ID and you will use the [Proof Key for Code Exchange](https://developer.va.gov/explore/api/appealable-issues/authorization-code#pkce-authorization) (PKCE) flow ( [RFC 7636](https://tools.ietf.org/html/rfc7636)) for authorization.

## Building OpenID Connect Applications

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

After being approved to use OpenID Connect, you'll receive a client ID.

- If you are building a **server-based application**, you’ll also receive a client secret and will use the [authorization code grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code#authorization-code-grant) to complete authentication.
- If you are unable to **safely store a client secret**, such as within a native mobile app, you will [use PKCE](https://developer.va.gov/explore/api/appealable-issues/authorization-code#pkce-authorization) to complete authentication.

### Initiating the Authorization Code Grant

**Note:** We provide a sample [Node.JS](https://nodejs.org/en/) application for demonstrating how to get up and running with our OAuth system. You can find the complete source code for it on our [GitHub](https://github.com/department-of-veterans-affairs/vets-api-clients/tree/master/samples/oauth_node)

#### Requesting Authorization

Begin the OpenID Connect authorization by using the authorization endpoint, query parameters, and scopes listed below.

Ensure your screenreader verbosity is set to high for code snippets.

```plaintext
https://sandbox-api.va.gov/oauth2/appeals/v1/authorization?
  client_id=0oa1c01m77heEXUZt2p7
  &redirect_uri=<yourRedirectURL>
  &response_type=code
  &scope=veteran/AppealableIssues.read representative/AppealableIssues.read
  &state=1AOQK33KIfH2g0ADHvU1oWAb7xQY7p6qWnUFiG1ffcUdrbCY1DBAZ3NffrjaoBGQ
  &nonce=o5jYpLSe29RBHBsn5iAnMKYpYw2Iw9XRBweacc001hRo5xxJEbHuniEbhuxHfVZy
```

Copy code to clipboard

| Query Parameter | Required | Values |
| --- | --- | --- |
| `client_id` | **Required** | The `client_id` issued by the VA API Platform team |
| `redirect_uri` | **Required** | The URL you supplied. The user will be redirected to this URL after authorizing your application. |
| `response_type` | **Required** | Supported response types: `code` |
| `state` | **Required** | Specifying a `state` param helps protect against some classes of Cross Site Request Forgery (CSRF) attacks, and applications must include it. The `state` param will be passed back from the authorization server to your redirect URL unchanged, and your application should verify that it has the expected value. This helps assure that the client receiving the authorization response is the same as the client that initiated the authorization process. |
| `scope` | **Required** | Will use your application's default scopes unless you specify a smaller subset of scopes separated by a space. Review the [Scopes section](https://developer.va.gov/explore/api/appealable-issues/authorization-code#scopes) for more information. |
| `nonce` | Optional | Using a `nonce` with JWTs prevents some kinds of replay attacks where a malicious party can attempt to resend an `id_token` request in order to impersonate a user of your application.<br>A nonce should be generated on a per-session basis and stored on the user's client. If the user requested an id\_token (by including the openid scope in the authorization request) then the [payload of the id\_token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#payload) will contain a nonce value that should match the nonce value included in the authorization request.<br>The [OpenID Connect documentation](https://openid.net/specs/openid-connect-core-1_0.html#NonceNotes) offers the following suggestion for generating nonces:<br>The nonce parameter value needs to include per-session state and be unguessable to attackers. One method to achieve this for Web Server Clients is to store a cryptographically random value as an HttpOnly session cookie and use a cryptographic hash of the value as the nonce parameter. In that case, the nonce in the returned ID Token is compared to the hash of the session cookie to detect ID Token replay by third parties. A related method applicable to JavaScript Clients is to store the cryptographically random value in HTML5 local storage and use a cryptographic hash of this value. |
| `prompt` | Optional | Supported prompts: `login`, `consent` and `none`.<br>If `login` is specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.<br>If `consent` is specified, the user will be asked to consent to their scopes being used regardless of prior consent.<br>If `none` is specified, an application will attempt an authorization request without user interaction. When the session is invalid or there are scopes the user has not consented to, one of the following errors will be thrown: `login_required` or `consent_required`. |

Query Parameters

The Veteran will need to grant your application access permission. To do this, direct the Veteran to the URL above. The Veteran is taken through an authentication flow by VA.gov and asked to consent to your application accessing their data. The data that can be accessed is defined by your scopes. After the Veteran gives permission, your application will receive a response based on the `response_type` you requested.

#### Requesting a Token with an Authorization Code Grant

After a Veteran gives authorization for you to access their data, their browser will be redirected to your application with the response shown below, which returns the `code` and `state` parameters you must use to make a request to our authorization service. We require the state parameter for all authorization code grant flows.

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 302 Found
Location: <yourRedirectURL>?
  code=z92dapo5
  &state=af0ifjsldkj
```

Copy code to clipboard

Use the following format, in HTTP basic authentication, for your request using the returned code and state parameters.

- Use your client ID and client secret as the HTTP basic authentication username and password, encoded using base64.
- Be sure to replace `<yourRedirectURL>` with the redirect URL that you provided during registration.

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/token HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

grant_type=authorization_code
&code=z92dapo5
&redirect_uri=<yourRedirectURL>
```

Copy code to clipboard

The authorization server will respond with an [access token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token). If you requested the `offline_access` scope, you will also receive a `refresh_token`. The response will look like this:

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "access_token": "SlAV32hkKG",
  "expires_in": 3600,
  "refresh_token": "8xLOxBtZp8",
  "scope": "veteran/AppealableIssues.read representative/AppealableIssues.read",
  "patient": "1558538470",
  "state": "af0ifjsldkj",
  "token_type": "Bearer",
}
```

Copy code to clipboard

If an error occurs, you will instead receive a response like this:

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "error": "invalid_request"
}
```

Copy code to clipboard

Use the returned `access_token` to authorize requests to our platform by including it in the header of HTTP requests as `Authorization: Bearer {access_token}`.

**Note:** the [access token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token) will only work for the API and scopes for which you have previously initiated authorization. If you need additional scopes in the future, you will need to build a new authorization URL with the additional scopes and have the Veteran grant consent again.

Refresh tokens expire if they are not used for a period of 7 days in sandbox and 42 days in production. Use the `refresh_token` to obtain a new `access_token` after its expiry by sending the following request.

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/token HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

grant_type=refresh_token&refresh_token={ *refresh_token* }
```

Copy code to clipboard

The response will return a new `access_token` and `refresh_token`, if you requested the `offline_access` scope.

#### Manage Account

The manage endpoint directs end users to a URL where they can view which applications currently have access to their data and can make adjustments to these access rights (grants).

Ensure your screenreader verbosity is set to high for code snippets.

```http
GET /oauth2/appeals/v1/manage HTTP/1.1
Host: sandbox-api.va.gov
```

Copy code to clipboard

#### Revoking Tokens

Clients may revoke their own `access_tokens` and `refresh_tokens` using the revoke endpoint. Once revoked, the introspection endpoint will see the token as inactive.

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/revoke HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

token={ *access_token* }&token_type_hint=access_token
```

Copy code to clipboard

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/revoke HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

token={ *refresh_token* }&token_type_hint=refresh_token
```

Copy code to clipboard

#### Revoking Grants

**NOTE:** This endpoint is not available in the production environment and excludes identity provider grants.

A user will be prompted only once to consent to each client's use of their data. Such a grant will remain in effect unless and until revoked. Grants for a specific user and client are revoked in the sandbox environment using the below endpoint.

Ensure your screenreader verbosity is set to high for code snippets.

```http
DELETE /oauth2/appeals/v1/grants HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded

client_id={client_id}&email={test account email}
```

Copy code to clipboard

The client ID is your application client ID ( `client_id`) and the email is the user’s email, which must be passed into the body of the request. Bad requests will be returned with an error response and description of the error.

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "error": "invalid_request",
  "error_description": "Invalid email address."
}
```

Copy code to clipboard

### PKCE (Proof Key for Code Exchange) Authorization

**NOTE:** We provide a [sample CLI application](https://github.com/department-of-veterans-affairs/vets-api-clients/tree/master/samples/oauth_pkce_cli) for getting started using PKCE.

#### Requesting Authorization

Begin the OpenID Connect authorization by using the authorization endpoint, query parameters, and scopes listed below.

Ensure your screenreader verbosity is set to high for code snippets.

```plaintext
https://sandbox-api.va.gov/oauth2/appeals/v1/authorization?
  client_id=0oa1c01m77heEXUZt2p7
  &redirect_uri=<yourRedirectURL>
  &response_type=code
  &scope=veteran/AppealableIssues.read representative/AppealableIssues.read
  &state=1AOQK33KIfH2g0ADHvU1oWAb7xQY7p6qWnUFiG1ffcUdrbCY1DBAZ3NffrjaoBGQ
  &code_challenge_method=S256
  &code_challenge=gNL3Mve3EVRsiFq0H6gfCz8z8IUANboT-eQZgEkXzKw
```

Copy code to clipboard

| Query Parameter | Required | Values |
| --- | --- | --- |
| `client_id` | **Required** | The `client_id` issued by the VA APIs team. |
| `redirect_uri` | **Required** | The URL you supplied. The user will be redirected to this URL after authorizing your application. |
| `response_type` | **Required** | Supported response types: `code` |
| `code_challenge` | **Required** | Base64 encoded challenge generated from your `code_verifier` |
| `code_challenge_method` | **Required** | Supported code challenges: `S256` |
| `state` | **Required** | Specifying a `state` param helps protect against some classes of Cross Site Request Forgery (CSRF) attacks, and applications must include it. The `state` param will be passed back from the authorization server to your redirect URL unchanged, and your application should verify that it has the expected value. This helps assure that the client receiving the authorization response is the same as the client that initiated the authorization process. |
| `scope` | Optional | Will use your application's default scopes unless you specify a smaller subset of scopes separated by a space. Review the [Scopes section](https://developer.va.gov/explore/api/appealable-issues/authorization-code#scopes) for more information. |
| `prompt` | Optional | Supported prompts: `login`, `consent` and `none`.<br>If `login` is specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.<br>If `consent` is specified, the user will be asked to consent to their scopes being used regardless of prior consent.<br>If `none` is specified, an application will attempt an authorization request without user interaction. When the session is invalid or there are scopes the user has not consented to, one of the following errors will be thrown: `login_required` or `consent_required`. |

Query Parameters

The Veteran will need to grant your application access permission. To do this, direct the Veteran to the URL above. The Veteran is taken through an authentication flow by VA.gov and asked to consent to your application accessing their data. The data that can be accessed is defined by your scopes. After the Veteran gives permission, your application will receive an authorization code.

#### Requesting a Token with an Authorization Code Grant

After the Veteran consents to authorize your application, their browser will redirect to your application with the response shown below, which returns the `code` and `state` parameters you must use to make a request to our authorization service and the `code_verifier` used to create the `code_challenge` in the previous step.

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 302 Found
Location: <yourRedirectURL>?
  code=z92dapo5
  &state=af0ifjsldkj
```

Copy code to clipboard

Use the following format, in HTTP basic authentication, for your request.

- Use the `code` parameter that was returned in the previous step.
- Be sure to replace `<yourRedirectURL>` with the redirect URL that you provided during registration.

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/token HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=z92dapo5
&client_id=0oa1c01m77heEXUZt2p7
&redirect_uri=<yourRedirectURL>
&code_verifier=ccec_bace_d453_e31c_eb86_2ad1_9a1b_0a89_a584_c068_2c96
```

Copy code to clipboard

The authorization server will send a 200 response with an [access token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token). If you requested the `offline_access` scope, you will also receive a `refresh_token`. The response body will look like this, where `expires_in` is the time in seconds before the token expires:

Ensure your screenreader verbosity is set to high for code snippets.

```json
{
  "access_token": "SlAV32hkKG",
  "expires_in": 3600,
  "refresh_token": "8xLOxBtZp8",
  "scope": "veteran/AppealableIssues.read representative/AppealableIssues.read",
  "state": "af0ifjsldkj",
  "token_type": "Bearer"
}
```

Copy code to clipboard

If an error occurs, you will instead receive a 400 response, like this:

Ensure your screenreader verbosity is set to high for code snippets.

```http
HTTP/1.1 400 Bad Request
Content-Type: application/json
Cache-Control: no-store
Pragma: no-cache

{
  "error": "invalid_request"
}
```

Copy code to clipboard

Use the returned `access_token` to authorize requests to our platform by including it in the header of HTTP requests as `Authorization: Bearer {access_token}`.

**NOTE:** the [access token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token) will only work for the API and scopes for which you have previously initiated authorization.

Refresh tokens expire if they are not used for a period of 7 days in sandbox and 42 days in production. Use the `refresh_token` to obtain a new `access_token` after its expiry by sending the following request.

Ensure your screenreader verbosity is set to high for code snippets.

```http
POST /oauth2/appeals/v1/token HTTP/1.1
Host: sandbox-api.va.gov
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token={your refresh_token}
&client_id={client_id}
&scope=veteran/AppealableIssues.read representative/AppealableIssues.read
```

Copy code to clipboard

The response will return a new `access_token` and `refresh_token`, if you requested the `offline_access` scope.

## Scopes

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

Scopes define the API endpoint your application is allowed to access. We suggest requesting the fewest number of scopes for which you require a Veteran to provide consent. You can always request access to additional scopes if a Veteran or an accredited representative needs the data while using your application.

| Scope | Values and description |
| --- | --- |
| `profile` | Granted by default, allows access to a user's first and last name and email. |
| `offline_access` | This scope causes the authorization server to provide a refresh token when the [access token](https://developer.va.gov/explore/api/appealable-issues/authorization-code#id-token) is requested. |
| `openid` | An `id_token` is available in the authorization code grant (response\_type = code) token response when the 'openid' scope is used. |

**API-specific scopes:**

| Scope | Values and Description |
| --- | --- |
| `veteran/AppealableIssues.read` | View a claimant's appealable issues. Request this scope if your application will have claimants consent to share their own data. |
| `representative/AppealableIssues.read` | View a claimant's appealable issues. Request this scope if your application will have users who represent claimants to VA. |

## ID Token

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

Access tokens and `id_tokens` are [JSON Web Tokens](https://jwt.io/) or JWTs. A JWT consists of three parts: a header, a payload, and a signature.

An `id_token` is available in the authorization code grant (response\_type = code) token response when the openid scope is used.

Your application must validate JWT signatures. This allows your application to verify that the provided JWT originates from our authorization servers and prevents your application from accepting a JWT with claims that are attempting to impersonate one of your users.

### Header

The JWT's header has two fields, `alg` and `kid`. `alg` indicates the algorithm that was used to sign the JWT, and `kid` identifies the key that was used to sign the JWT. Signing keys and associated metadata are accessible from [https://api.va.gov/oauth2/appeals/v1/keys](https://api.va.gov/oauth2/appeals/v1/keys).

### Signature

The signature is a cryptographically generated signature of the JWT's header and payload used to confirm the JWT's authenticity. Your application must validate this signature using the `alg` and the `kid` from the JWT's header. You may want use one of the JWT libraries listed at [jwt.io](https://jwt.io/) to help make this process easier.

### Payload

The payload is a JSON object containing identity and authentication-related `claims`. There are a couple claims in the JWT that are important for your application to consider:

- `nonce` \- should match the `nonce` you initiated authorization with.
- `exp` \- the expiration time of the JWT. The token cannot be accepted by VA Developer after this time, and your application should not use an expired token to identify a user.

## Test Users

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

Some APIs require test users and test data. Most of the test data provided by VA Developer comes from internal VA systems, are not real data, and are reset based upon new recordings of underlying services. We provide test accounts for you to use while developing your application. These test accounts are API-specific, and contain data that is geared toward each API.

To access test data, go to the [test data page](https://developer.va.gov/explore/api/appealable-issues/test-users) and find test users that meet your use case. Then, access test account credentials by using the link in the email we'll send to you when you sign up for sandbox access.

## HTTPS

[Return to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#page-header)

Outside of local development environments, all redirect endpoints must use the `https` protocol for communication. The `https` protocol provides a secure encrypted connection between the user's client, your application, VA Developer, and authorization servers. This mitigates the risk of some types of man-in-the-middle attacks and prevents third-parties from intercepting user's authorization credentials.

[Back to topBack to top](https://developer.va.gov/explore/api/appealable-issues/authorization-code#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: