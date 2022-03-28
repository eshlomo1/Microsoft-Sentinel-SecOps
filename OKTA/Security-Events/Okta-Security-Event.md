# Okta Event of Interest

### The following events is part of Okta events. This events appears on the System log API (also Core Okta API) when a suspicious events occurs.
### When you export the logs to SIEM platform that could be Event Types of Interest for Security Teams

## User Events

|EventType Filter|Notes|
|------------- |-------------|
|eventType eq "user.session.start"|User logging in|
|eventType eq "user.session.end"|User logging out|
|eventType eq “user.account.lock”|Okta user locked out|
|eventType eq "user.mfa.attempt_bypass"| Attempt bypass of factor|
|eventType eq "user.account.update_password"|User changing password|
|eventType eq "user.authentication.auth_via_mfa"|MFA challenge|
|eventType eq "user.mfa.factor.update"|User changing MFA factors|
|eventType eq "policy.evaluate_sign_on"|Sign in policy evaluation|
|eventType eq "core.user.impersonation.session.initiated"|Initiate impersonation session|
|eventType eq "user.authentication.sso"|User accesing app via single sign on|
|eventType sw "user.authentication.auth"|All types of Auth events, covering MFA, AD, Radius, etc|

## Admin Events

|EventType Filter|Notes|
|------------- |-------------|
|eventType eq "core.user.admin_privilege.granted"| Remove admin privileges| 
|eventType eq "core.user.admin_privilege.revoked|	Add admin privileges|

## Okta Events

| EventType Filter |  Notes|
| ------------- | -------------|
|eventType eq "user.account.reset_password" | User password reset by Okta Admin |
|eventType eq "zone.update"|Modification of a Network Zone|
|eventType eq "user.account.privilege.grant"|Granting Okta Admin to a user|
|eventType eq "group.user_membership.add"|Adding Okta user to a group|
|eventType eq "policy.lifecycle.create"|Creation of a new Okta Policy|
|eventType eq "application.lifecycle.create”|New Application created|
|eventType eq "user.lifecycle.activate”|New Okta user|
|eventType eq "application.provision.user.push"|Assign application to user|
|eventType eq "user.lifecycle.deactivate"|Deactivate Okta user|
|eventType eq "user.lifecycle.suspend"|Suspend Okta user|
|eventType eq "user.session.clear"|Okta user login session cleared|
|eventType eq "system.api_token.create"|Creation of a new Okta API token|
|eventType eq "user.mfa.factor.deactivate”|Removed MFA factor from user|
|eventType eq "user.mfa.factor.reset_all"|Remove all MFA factors from user|
|eventType eq "system.org.rate_limit.violation"|Hitting the rate limit on requests|
|eventType eq "application.user_membership.add"|Adding user to application membership|
|eventType eq "user.session.access_admin_app | These events are associated with users accessing the admin side |
|eventType eq "app.oauth2.as.key.rollover" | Custom Authorization Server token signing key rolled over |

## Okta Account TakeOver Events 

| EventType Filter |  Notes|
| ------------- | -------------|
|eventType eq "user.account.report_suspicious_activity_by_enduser" | Suspicious Activity reported by user
|eventType eq “security.threat.detected" | ThreatInsight detection: access requests from IPs associated with malicious behavior
|eventType eq "security.attack.start" | ThreatInsight detection: access requests from known malicious IPs targeting a specific org
|eventType eq “user.mfa.okta_verify.deny_push” | User rejected an MFA push request
|eventType eq “user.authentication.auth_via_mfa” AND outcome.result eq “FAILURE” | User authentication via MFA
|eventType eq "user.session.start" | User Behavior Detections
|eventType eq "policy.evaluate.sign_on" | User Behavior Detections
|eventType eq "user.session.start" and debugContext.debugData.risk co "HIGH" | Risk Scoring Events
|eventType eq "policy.evaluate_sign_on" and debugContext.debugData.logOnlySecurityData co "HIGH" | Risk Scoring Events
|eventType eq "user.account.reset_password" and outcome.result eq "FAILURE" and outcome.reason eq "User suspended" | Self-service Password Reset attempted for a suspended user
|User fails challenge during Self-Service Password Reset | User fails challenge during Self-Service Password Reset

Refernece: https://developer.okta.com/docs/reference/api/system-log/
