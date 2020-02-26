defmodule ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapterTest do
  use ExUnit.Case, async: true
  alias ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter

  import Mox

  @role_arn "2222222/test_role"
  @web_identity_token "yo"
  @role_session_name "default_session"
  @expiration 30_000

  setup do
    {:ok, path} = Briefly.create()
    File.write!(path, @web_identity_token)

    System.put_env("AWS_WEB_IDENTITY_TOKEN_FILE", path)
    System.put_env("AWS_ROLE_ARN", @role_arn)

    on_exit(fn ->
      System.delete_env("AWS_WEB_IDENTITY_TOKEN_FILE")
      System.delete_env("AWS_ROLE_ARN")
    end)
  end

  describe "when the loader and config are injected" do
    test "#adapt_auth_config" do
      expiration = 500

      config = %{
        region: "us-east-1",
        role_arn: "1111111/test_role",
        role_session_name: "test",
        access_key_id: "dummy",
        secret_access_key: "dummy",
        http_client: ExAws.Request.HttpMock
      }

      body = %{
        access_key_id: "1",
        secret_access_key: "secret",
        session_token: "token"
      }

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             _url,
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=1111111%2Ftest_role&RoleSessionName=test&Version=2011-06-15&WebIdentityToken=ey",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: body}}
      end)

      expected = %{
        access_key_id: body.access_key_id,
        secret_access_key: body.secret_access_key,
        security_token: body.session_token,
        role_arn: config.role_arn,
        role_session_name: config.role_session_name,
        expiration: expiration
      }

      assert expected ==
               AssumeRoleWebIdentityAdapter.adapt_auth_config(
                 config,
                 nil,
                 expiration,
                 &test_loader/1
               )
    end
  end

  describe "when the loader and config are the default" do
    test "#adapt_auth_config" do
      config = %{
        http_client: ExAws.Request.HttpMock
      }

      body = %{
        access_key_id: "1",
        secret_access_key: "secret",
        session_token: "token"
      }

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             _url,
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=2222222%2Ftest_role&RoleSessionName=default_session&Version=2011-06-15&WebIdentityToken=yo",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: body}}
      end)

      expected = %{
        access_key_id: body.access_key_id,
        secret_access_key: body.secret_access_key,
        security_token: body.session_token,
        role_arn: @role_arn,
        role_session_name: @role_session_name,
        expiration: @expiration
      }

      assert expected == AssumeRoleWebIdentityAdapter.adapt_auth_config(config, nil, nil)
    end
  end

  defp test_loader(_config) do
    %{
      role_arn: "1111111/test_role",
      web_identity_token: "ey"
    }
  end
end
