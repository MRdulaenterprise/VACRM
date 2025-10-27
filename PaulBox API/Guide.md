Quick start guide
Follow these steps to get up and running sending HIPAA compliant, secure email with the Paubox Email API. You can test and even use it in production to send up tp 300 emails per month for free.

Step 1: Sign up and create a Paubox account

Don't worry, it's free to sign up and to send up to 300 emails per month with our API. Just visit our sign up page and create an account.

If you send more than 300 emails in one month, you will be automatically moved up to the appropriate pricing tier and billed the annual cost.

Step 2: Add and verify your domain

Once you have a Paubox account, if you haven't already added a domain for the Paubox Email API, do so from the Paubox Email API > Settings page where you can Add a domain and verify that it's yours. 

Step 3: Generate an API key

From the Paubox Email API > Settings click on the domain you would like to generate an API key for, and then press the Add API Key button. Give the key a description and a new key will be generated upon submission. 

You can generate several API keys to use in different applications as needed. Make sure you save your key because if you lose it you will have to generate a new one.

To connect and send secure email, you'll need the API key and your customer endpoint, which is shown on the Paubox Email API > Settings page as well.

Step 4: Integrate the Paubox Email API into your application

(We even have code for you!)
The fastest way to get started is to use the Paubox Email API SDK repositories on GitHub. You can also checkout some quick samples on the Paubox Email API information page.

We have code for the following languages:

C#
Java
Python 3
Python 2
PHP
Rails
Node
Perl
Ruby
Mulesoft
If you're a hardcore developer you can take a look at the entirety of the API Docs on this site using the left navigation bar and build code from scratch.

General information
This site contains the raw Paubox Email API documentation. If you're not sure where to start, visit our Quick start guide to get setup.

Base URL

https://api.paubox.net/v1/<USERNAME>

Replace <USERNAME> with your API endpoint username

Authorization

Use the authorization header in request: authorization: Token token=<API_KEY>

Replace <API_KEY> with your API key

Date format

Dates are passed as strings formatted to RFC 2822 standards e.g. "Fri, 16 Feb 2018 13:00:00 GMT"

Standard HTTP response codes

Status Code	Status Message
200	Service Ok
400	Bad Request
401	Unauthorized
404	Not Found
500, 502, 503, 504	Server Error

Paubox Email API
v1.0.0
api_username
string
Your Paubox Email API endpoint username
Default:
YOUR_API_USERNAME
Paubox API uses a custom token format in the Authorization header.

IMPORTANT: You must prefix your API key with "Token token="

Format: Authorization: Token token=YOUR_API_KEY_HERE

Example: Authorization: Token token=9e5b092b632445b8f570c62ae54f30fda1044305

Do NOT use just the API key alone or Bearer token format.

An API key is a token that you provide when making API calls. Include the token in a header parameter called Authorization.

Example: Authorization: 123
Public documentation for Paubox's Transactional Email API

Authentication


IMPORTANT: This API uses a custom authentication format that requires the "Token token=" prefix.

All requests must include the Authorization header in this exact format:

Authorization: Token token=YOUR_API_KEY
Note for Code Generation Tools: Auto-generated code from this specification may need to be modified to include the "Token token=" prefix, as most generators expect standard Bearer token format.

Webhooks
How to use webhooks

Webhooks are currently triggered at an organization-wide level. This means that events for all domains your organization has set up with Paubox will trigger a webhook notification. You can setup webhooks in the Paubox web application. Go to Paubox Email API > Webhooks.

Webhook fields

URL: You will need to provide an HTTPS URL which you own, to which you would like your webhook payload to be sent.
Event: The events notifications to which you would like to subscribe
Available events

Event Name	Event Name Key Value	Trigger
Delivered	api_mail_log_delivered	When message is delivered
Temporary Failure	api_mail_log_temporary_failure	On soft bounce of message
Permanent Failure	api_mail_log_permanent_failure	On hard bounce of message
Opened	api_mail_log_opened	On opening of message
Payloads

Every Webhook notification will include an event_name key, and a payload key. The type of payload you should expect is dependent on the data model that is triggering the webhook event.

The most common type of payload is the API Mail Log payload, which is structured as follows:

{
 "event_name": "api_mail_log_permanent_failure",
 "payload": {
   "id": 5555555555,
   "subject": "Hello from the Paubox Email API",
   "header_message_id": "<XXX430aa-9b7c-42d5-9614-2e38f5a3f71f@XXXXXXXXX.com>",
   "source_tracking_id": "XXXef39e-b376-4a44-b2b9-85bdb406dXXX",
   "outbound_queue_id": "XXXyFY0y3Yz2XXX",
   "time": "2022-04-18T20:27:25.379Z",
   "from": "XXXXXX@XXXXXXX.com",
   "to": "XXXXXXX@XXXXXXX.com",
   "custom_headers": {
     "X-Custom-Header": "value"
   }
 }
}

SMTP API
Connecting to Paubox Email API via SMTP

To configure your application or service to send email through Paubox’s SMTP relay to Email API, follow these steps:

Generate a Paubox Email API key from the Paubox Email API > Settings page.
Configure the SMTP server host to smtp.paubox.com.
This is often labeled as the SMTP relay or outgoing mail server in most email clients.
Set your username to the literal string apikey.
Note: this should be the exact word "apikey", not the API key you generated.
Use your API key as the SMTP password.
Choose the appropriate port, typically 587, unless your network requires another.

ℹ️ Tip
If you're pasting a base64-encoded API key, double-check for any extra spaces or line breaks.
These can inadvertently appear when copying from certain terminals or editors, and they will prevent authentication.
Since SMTP is a line-based protocol, even a stray newline can result in failure.

Available SMTP Ports

Choose the correct port based on your desired level of security:

For TLS connections, use:
25 or 587
For SSL/TLS connections, use:
465

ℹ️ Tip
If you're not sure which one to use, 587 with STARTTLS is the most widely supported and recommended option.

Sending Mail via SMTP

Once your SMTP connection is set up, you’re ready to construct and send email messages using your preferred client, service, or library.

Rate Limits

To avoid delivery interruptions, be aware of Paubox's SMTP usage thresholds:

A single IP address may send up to 500 messages per minute.
Avoid Direct IP Usage

Always reference the host as smtp.paubox.com — do not use direct IP addresses.
Paubox’s infrastructure may change without warning, and relying on hardcoded IPs could cause unexpected delivery issues in the future.

Limits and overage rates
What to do if you've reached your limit

You will be charged a small amount per-email for each email that you send beyond the limit of your current plan. Any overage charges will appear on an invoice of the month after any over-limit sending occurs.

Paubox Email API overage costs

If you go over your plan limits, here’s a breakdown of the overage costs you’ll incur:

Plan Information	Monthly Plan Limits	Cost Per Extra Email
Free	300	-
Standard	10,000 emails	$0.0130
Standard	30,000 emails	$0.0130
Standard	50,000 emails	$0.0100
Standard	100,000 emails	$0.0098
Standard	Custom	-

Paulbox Github repo for SDKs. https://github.com/orgs/Paubox/repositories

API Key: 605f76f07290d321ac2e8540ad5cf97dfb1fbd80
production API Key: 6a647f9fa6c84cfb93fa51898b3bf9c50cf1acea
domain: mrdula.co
From email: matt@mrdula.co

Public upload address: https://next.paubox.com/public/mrdula/upload