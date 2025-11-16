---
url: "https://developer.va.gov/explore/api/appealable-issues/client-credentials"
title: "VA API Platform | Appealable Issues API Client Credentials Grant"
---

[Skip to main content](https://developer.va.gov/explore/api/appealable-issues/client-credentials#main)

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
4. [Client Credentials Grant](https://developer.va.gov/explore/api/appealable-issues/client-credentials#content)

[Skip Page Navigation](https://developer.va.gov/explore/api/appealable-issues/client-credentials#page-header) In this section

- [Appealable Issues API](https://developer.va.gov/explore/api/appealable-issues)
- [Docs](https://developer.va.gov/explore/api/appealable-issues/docs)
- [Authorization Code Grant](https://developer.va.gov/explore/api/appealable-issues/authorization-code)
- [Client Credentials Grant](https://developer.va.gov/explore/api/appealable-issues/client-credentials)
- [Test data](https://developer.va.gov/explore/api/appealable-issues/test-users)
- [Release notes](https://developer.va.gov/explore/api/appealable-issues/release-notes)
- [Sandbox access](https://developer.va.gov/explore/api/appealable-issues/sandbox-access)

# Client Credentials Grant

## Appealable Issues API

The authentication model for the Appealable Issues API uses OAuth 2.0 with OpenID Connect.

VA's [OAuth 2.0 Client Credentials Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4) (CCG) grants access by using your RSA public key in [JSON Web Key (JWK)](https://datatracker.ietf.org/doc/html/rfc7517) format, as described in the [OpenID spec](https://openid.net/specs/draft-jones-json-web-key-03.html).

To learn how to [generate an RSA key pair](https://developer.va.gov/explore/api/appealable-issues/client-credentials#generating-rsa) and [request an access token with CCG](https://developer.va.gov/explore/api/appealable-issues/client-credentials#requesting-a-token), follow the instructions on this page. It's important to read and understand this documentation before you develop your application and test it in the sandbox. If you're just getting started with the API, we provide a [Postman collection](https://github.com/department-of-veterans-affairs/vets-api-clients/tree/master/samples/postman) that you can use to request access tokens after generating your keys and signing up for sandbox access.

## It's good to know that:

- The access credentials we give are for the sandbox environment only and will not work in the production environment.
- Important: To get production access to certain APIs via CCG, you must either work for VA or have specific VA agreements in place. [Read the API's documentation](https://developer.va.gov/explore/api/appealable-issues/docs) to see if it requires such agreements.
- This page provides examples that show authorization server URLs in the sandbox environment. Unless otherwise indicated, you can get production auth server URLs from the API documentation.
- When your application is ready, you may [apply for production access](https://developer.va.gov/production-access/request-prod-access).

## Getting started

[Return to top](https://developer.va.gov/explore/api/appealable-issues/client-credentials#page-header)

### Generating RSA key pair and converting public key to JWK Format

CCG uses [public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) for authentication. You will need to generate an RSA key pair and share the public key with VA in JWK format when requesting sandbox access. You will later use the private key to sign token requests.

Note: Your private key is a secret and should be kept secure. Anyone with access to your private key and client ID will be able to use your identity to make token requests to the API.

1. Generate the private key: Use the following [OpenSSL](https://www.openssl.org/docs/man3.0/man1/openssl-rsa.html) command to generate a private RSA key in PEM format:


```
openssl genrsa -out private.pem 2048
```

2. Generate the public key: Once you have the private key, you can extract the corresponding public key using the following command:


```
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
```

3. Convert the public key to JWK format: After generating the public key in PEM format, you'll need to convert it to JWK format. [pem-jwk](https://www.npmjs.com/package/pem-jwk) is a convenient Node tool for converting PEM to JWK. To convert your public key to JWK with pem-jwk, use the following command:


```
pem-jwk public.pem > public.jwk
```


Your JWK should look similar to the example shown below:

Ensure your screenreader verbosity is set to high for code snippets.

```json
{
  "kty": "RSA",
  "n": "mYi1wUpwkJ1QB8...",
  "e": "AQAB"
}
```

Next, get sandbox access. When you request access, provide your RSA public key in JWK format. We will send your client ID in an email.

### A note on key rotation and key ID

If you plan to rotate keys in production, we recommend that you add the optional ["kid" (key ID) parameter](https://datatracker.ietf.org/doc/html/rfc7517#section-4.5) to your JWK. The key ID is a string that identifies which of multiple public keys the auth server will use for signature verification, should be unique for any key in a set, and must not exceed 255 characters. The "kid" parameter is not required for sandbox use with a single RSA key.

If you include a key ID, your JWK should look similar to this. Replace `KEY_ID` with your actual key ID:

Ensure your screenreader verbosity is set to high for code snippets.

```json
{
  "kty": "RSA",
  "n": "mYi1wUpwkJ1QB8...",
  "e": "AQAB",
  "kid": "KEY_ID"
}
```

## Requesting a token with CCG

[Return to top](https://developer.va.gov/explore/api/appealable-issues/client-credentials#page-header)

To get authorized to make API requests, generate a [JSON web token (JWT)](https://jwt.io/introduction) and sign it using your private key. You'll then use the signed JWT as a client assertion (CCG authorization credential) when requesting an access token.

### Generating and signing the JWT

Generate your JWT using:

- The client ID we sent you by email.
- The token recipient URL ( `aud`). Check the table below for the values to use for this API.
- Your RSA private key, for signing the client assertion.

This table describes the claims you will use in your JWT and client assertion:

| Claim | Required | Description |
| --- | --- | --- |
| `aud` | True | **String.** The recipient URL (audience) where you will send your token. For the Appealable Issues API, these are:<br>- Sandbox:<br>  <br>  ```<br>  https://deptva-eval.okta.com/oauth2/auskff5o6xsoQVngk2p7/v1/token<br>  ```<br>  <br>- Production:<br>  <br>  ```<br>  https://va.okta.com/oauth2/ausjem1ol3S3DGSDV297/v1/token<br>  ``` |
| `iss` | True | **String.** The client ID. |
| `sub` | True | **String.** The client ID. |
| `iat` | False | **Integer.** A timestamp for how many seconds have passed since January 1, 1970 UTC. It must be a time before the request occurs. <br>`Example: 1604429781` |
| `exp` | True | **Integer.** A timestamp for when the token will expire, given in seconds since January 1, 1970. This claim fails the request if the expiration time is more than 300 seconds (5 minutes) after the iat. <br>`Example: 1604430081` |
| `jti` | False | **String.** A unique token identifier. If you specify this parameter, the token can only be used once and, as a result, subsequent token requests won't succeed. <br>`Example: 23f8f614-72c3-4267-b0da-b8b067662c74` |

The following example shows how a JWT could be generated and signed with a NodeJS function using the [nJwt](https://www.npmjs.com/package/njwt) library:

Ensure your screenreader verbosity is set to high for code snippets.

```javascript
function getAssertionPrivatekey (clientId, key, audience) {
  let secondsSinceEpoch = Math.round(Date.now() / 1000);
  const claims = {
    "aud": audience,
    "iss": clientId,
    "sub": clientId,
    "iat": secondsSinceEpoch,
    "exp": secondsSinceEpoch + 3600,
    "jti": crypto.randomUUID()
  };
  let secret = fs.readFileSync(key, "utf8");
  let algorithm = "RS256";
  const token = jwt.create(claims, secret, algorithm);
  return token.compact();
}
```

Copy code to clipboard

### Retrieving an access token

POST your client assertion to the `/token` service to receive an access token. The token endpoints for the Appealable Issues API are shown below:

- Sandbox:

```
https://sandbox-api.va.gov/oauth2/appeals/system/v1/token
```

- Production:

```
https://api.va.gov/oauth2/appeals/system/v1/token
```


The following table describes the required values you will use in your token request:

| Field | Required | Value |
| --- | --- | --- |
| `grant_type` | True | `client_credentials` |
| `client_assertion_type` | True | `urn:ietf:params:oauth:client-assertion-type:jwt-bearer` |
| `client_assertion` | True | Signed [JWT](https://jwt.io/introduction) |
| `scope` | True | - `system/AppealableIssues.read` |

Request a token as shown in the cURL command below. Be sure to include the scopes for the API. Replace `CLIENT_ASSERTION` with your own signed client assertion.

Ensure your screenreader verbosity is set to high for code snippets.

```bash
curl --location --request POST 'https://sandbox-api.va.gov/oauth2/appeals/system/v1/token' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode 'client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer' \
  --data-urlencode 'client_assertion=CLIENT_ASSERTION' \
  --data-urlencode 'scope=system/AppealableIssues.read'

```

Copy code to clipboard

We will respond with a JSON object containing your access token, which will look like the following example:

Ensure your screenreader verbosity is set to high for code snippets.

```bash
{
  "access_token": "eyJraWQiOi...",
  "token_type": "Bearer",
  "scope": "system/AppealableIssues.read",
  "expires_in": 300
}
```

Copy code to clipboard

Use the returned `access_token` to authorize requests to our platform by including it in the header of HTTP requests as `Authorization: Bearer ACCESS_TOKEN` (replace `ACCESS_TOKEN` with your own access token). Your access token will remain valid for 5 minutes. If your access token expires, you will need to request a new one.

## Test user ICNs

[Return to top](https://developer.va.gov/explore/api/appealable-issues/client-credentials#page-header)

You can get test users' Integrated Control Numbers (ICNs) on the [test data page](https://developer.va.gov/explore/api/appealable-issues/test-users). Search by the values indicated in your API documentation.

[Back to topBack to top](https://developer.va.gov/explore/api/appealable-issues/client-credentials#ds-back-to-top)

Help improve this site

- [API Publishing](https://developer.va.gov/api-publishing)
- [Accessibility](https://www.section508.va.gov/)
- [Support](https://developer.va.gov/support)
- [Web Policies](https://www.va.gov/webpolicylinks.asp)
- [Terms of Service](https://developer.va.gov/terms-of-service)
- [Privacy](https://www.va.gov/privacy/)

[![Department of Veterans Affairs Logo](https://developer.va.gov/static/media/lighthouseVaLogo.164b2c3067103035bb45.png)](https://www.va.gov/)

Commit Hash: