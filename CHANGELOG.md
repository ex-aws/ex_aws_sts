# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

* Use `ExAws.Config` in order to retrieve the `:auth_credentials`

## v2.1.0 - 2020-04-06

* Change implementation to use `File.read!` for user-friendly error stack trace
* Fix callback signature warning
* Fix issue caused by changing key order in map
* Remove unused entry point that doesn't implement callback behaviour
* Add adapter for using Web Identity tokens when assuming role
* Fix bug in XML parsing paths
* Add missing typespec to `get_caller_identity/0`
* Fix typespec on `assume_role_with_saml/4`
* Add `AssumeRoleWithWebIdentity`, `GetAccessKeyInfo`, and `AssumeRoleWithSAML`
* Match spec argument name with function argument

## v2.0.1 - 2019-07-17

* Fix issue with `AssumeRoleCredentialsAdapter`
* Allow authentication base on `:source_profile` and `role_arn`

## v2.0.0 - 2017-11-10

- Major Project Split. Please see the main ExAws repository for previous changelogs.
