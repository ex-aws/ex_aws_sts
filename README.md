# ExAws.STS

[![Module Version](https://img.shields.io/hexpm/v/ex_aws_sts.svg)](https://hex.pm/packages/ex_aws_sts)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_aws_sts/)
[![Total Download](https://img.shields.io/hexpm/dt/ex_aws_sts.svg)](https://hex.pm/packages/ex_aws_sts)
[![License](https://img.shields.io/hexpm/l/ex_aws_sts.svg)](https://github.com/ex-aws/ex_aws_sts/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/ex-aws/ex_aws_sts.svg)](https://github.com/ex-aws/ex_aws_sts/commits/master)

Service module for [https://github.com/ex-aws/ex_aws](https://github.com/ex-aws/ex_aws).

## Installation

The package can be installed by adding `:ex_aws_sts` to your list of dependencies in `mix.exs` along with `:ex_aws`.

```elixir
def deps do
  [
    {:ex_aws, "~> 2.2"},
    {:ex_aws_sts, "~> 2.2"},
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

`ExAws.STS` allows to authentication based on `role_arn` and `source_profile` as specified in the `awscli` config file.

When specified in your `~/.aws/config` you can set 
 
```elixir
config :ex_aws,
  secret_access_key: [{:awscli, "profile_name", 1_800}],
  access_key_id: [{:awscli, "profile_name", 1_800}],
  awscli_auth_adapter: ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter
```

and if the profile `profile_name` sets a `role_arn` then this will make ExAws
issue an `AssumeRoleCredentials` request to fetch the `access_key_id`
and `secret_access_key`.
The third element in the tuple (1_800 in the example) is the desired expiration in seconds.
[AWS enforces a minimum](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html#API_AssumeRole_RequestParameters) of 900 seconds (15 minutes).

### Using AWS CLI config from ENV vars

It is possible to inject the credentials by configuration, for example, by using ENV vars. This is very useful for containerized applications.

In order to do that, just place in the config the block `awscli_credentials` with your `profile_name` as key and the corresponding values. Then under `access_key_id` and `secret_access_key` just make a reference to the profile, so it will be used to ask for the credentials automatically.

```elixir
config :ex_aws,
  access_key_id: [{:awscli, "default", 1_800}],
  secret_access_key: [{:awscli, "default", 1_800}],
  awscli_auth_adapter: ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter,
  awscli_credentials: %{
    "default" => %{
      role_arn: {:system, "AWS_ROLE_ARN"},
      access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
      secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
      source_profile: "default"
    }
  }
```

### Using Web Identity tokens from ENV vars

Similarly, it is possible to use a web identity token to perform the assume role operation. It currently uses the following env vars to obtain it:

`AWS_WEB_IDENTITY_TOKEN_FILE`: path of the file with the web identity token
`AWS_ROLE_ARN`: role to be assumed

```elixir
config :ex_aws,
  secret_access_key: [{:awscli, "profile_name", 1_800}],
  access_key_id: [{:awscli, "profile_name", 1_800}],
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
