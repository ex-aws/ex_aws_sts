# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.3.0 - 2020-05-15

- Removed hardcoded `Poison` dependency, now uses configured `json_codec` within thP parent `ex_aws` module.

## v2.2.0 - 2020-05-14

- Added ability to allow STS credentials to be injected by configuration

## v2.1.0 - 2020-04-06

* Changed implementation to use `File.read!` for user-friendly error stack trace
* Fixed callback signature warning
* Fixed issue caused by changing key order in map
* Removed unused entry point that doesn't implement callback behaviour
* Added adapter for using Web Identity tokens when assuming role
* Fixed bug in XML parsing paths
* Added missing typespec to `get_caller_identity/0`
* Fixed typespec on `assume_role_with_saml/4`
* Added `AssumeRoleWithWebIdentity`, `GetAccessKeyInfo`, and `AssumeRoleWithSAML`

## v2.0.1 - 2019-07-17

* Fixed issue with `AssumeRoleCredentialsAdapter`

## v2.0.0 - 2017-11-10

- Major Project Split. Please see the main ExAws repository for previous changelogs.
