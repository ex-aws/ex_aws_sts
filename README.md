# ExAws.STS

Service module for https://github.com/ex-aws/ex_aws

## Installation

The package can be installed by adding `ex_aws_sts` to your list of dependencies in `mix.exs`
along with `:ex_aws` and your preferred JSON codec / http client

```elixir
def deps do
  [
    {:ex_aws, "~> 2.0"},
    {:ex_aws_sts, "~> 2.0"},
    {:poison, "~> 3.0"},
    {:hackney, "~> 1.9"},
  ]
end
```

Documentation can be found at [https://hexdocs.pm/ex_aws_sts](https://hexdocs.pm/ex_aws_sts).

## Role based authentication

Using the `:awscli_auth_adapter` option of `ex_aws` is supported, but requires additional dependencies:

```elixir
{:sweet_xml, "~> 0.6"}
{:configparser_ex, "~> 2.0"}
```

### Using AWS CLI config file with source profile

`ExAws.STS` allows to authentication based on `role_arn` and `source_profile` as specified in the 
`awscli` config file.
 When specified in your `~/.aws/config` you can set 
  
```
config :ex_aws,
  secret_access_key: [{:awscli, "profile_name", 30}],
  access_key_id: [{:awscli, "profile_name", 30}],
  awscli_auth_adapter: ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter
```

and if the profile `profile_name` sets a `role_arn` then this will make ExAws 
issue an `AssumeRoleCredentials` request to fetch the `access_key_id` 
and `secret_access_key`.

### Using Web Identity tokens from ENV vars

Similarly, it is possible to use a web identity token to perform the assume role operation. It currently uses the following env vars to obtain it:

`AWS_WEB_IDENTITY_TOKEN_FILE`: path of the file with the web identity token
`AWS_ROLE_ARN`: role to be assumed

```elixir
config :ex_aws,
  secret_access_key: [{:awscli, "profile_name", 30}],
  access_key_id: [{:awscli, "profile_name", 30}],
  awscli_auth_adapter: ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter
```

## License

The MIT License (MIT)

Copyright (c) 2014 CargoSense, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
