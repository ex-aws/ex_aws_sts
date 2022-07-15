defmodule ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapterTest do
  use ExUnit.Case, async: false
  alias ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter

  import Mox

  @role_arn "2222222/test_role"
  @web_identity_token "yo"
  @role_session_name "default_session"
  @expiration 30_000

  setup do
    {:ok, path} = Briefly.create()
    File.write!(path, @web_identity_token)

    System.put_env("AWS_REGION", "eu-west-1")
    System.put_env("AWS_WEB_IDENTITY_TOKEN_FILE", path)
    System.put_env("AWS_ROLE_ARN", @role_arn)

    on_exit(fn ->
      System.delete_env("AWS_REGION")
      System.delete_env("AWS_WEB_IDENTITY_TOKEN_FILE")
      System.delete_env("AWS_ROLE_ARN")
      System.delete_env("AWS_STS_REGIONAL_ENDPOINTS")
    end)
  end

  describe "when the loader and config are injected" do
    test "#adapt_auth_config" do
      expiration = 500

      config = %{
        role_arn: "1111111/test_role",
        role_session_name: "test",
        access_key_id: "dummy",
        secret_access_key: "dummy",
        http_client: ExAws.Request.HttpMock
      }

      access_key_id = "ASgeIAIOSFODNN7EXAMPLE"
      secret_access_key = "AROACLKWSDQRAOEXAMPLE:test"
      security_token = "AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE"

      sts_resp_xml =
        sts_xml_response(
          config.role_session_name,
          config.role_arn,
          security_token,
          access_key_id,
          secret_access_key
        )

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             _url,
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=1111111%2Ftest_role&RoleSessionName=test&Version=2011-06-15&WebIdentityToken=ey",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: sts_resp_xml}}
      end)

      expected = %{
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        security_token: security_token,
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

      access_key_id = "ASgeIAIOSFODNN7EXAMPLE"
      secret_access_key = "AROACLKWSDQRAOEXAMPLE:test"
      security_token = "AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE"

      sts_resp_xml =
        sts_xml_response(
          @role_session_name,
          @role_arn,
          security_token,
          access_key_id,
          secret_access_key
        )

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             _url,
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=2222222%2Ftest_role&RoleSessionName=default_session&Version=2011-06-15&WebIdentityToken=yo",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: sts_resp_xml}}
      end)

      expected = %{
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        security_token: security_token,
        role_arn: @role_arn,
        role_session_name: @role_session_name,
        expiration: @expiration
      }

      assert expected == AssumeRoleWebIdentityAdapter.adapt_auth_config(config, nil, nil)
    end
  end

  describe "use of global and regional sts endpoint" do
    test "regional endpoints" do
      System.put_env("AWS_STS_REGIONAL_ENDPOINTS", "regional")

      config = %{
        http_client: ExAws.Request.HttpMock
      }

      access_key_id = "ASgeIAIOSFODNN7EXAMPLE"
      secret_access_key = "AROACLKWSDQRAOEXAMPLE:test"
      security_token = "AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE"

      sts_resp_xml =
        sts_xml_response(
          @role_session_name,
          @role_arn,
          security_token,
          access_key_id,
          secret_access_key
        )

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             "https://sts.eu-west-1.amazonaws.com/",
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=2222222%2Ftest_role&RoleSessionName=default_session&Version=2011-06-15&WebIdentityToken=yo",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: sts_resp_xml}}
      end)

      expected = %{
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        security_token: security_token,
        role_arn: @role_arn,
        role_session_name: @role_session_name,
        expiration: @expiration
      }

      assert expected == AssumeRoleWebIdentityAdapter.adapt_auth_config(config, nil, nil)
    end

    test "global endpoint" do
      config = %{
        http_client: ExAws.Request.HttpMock
      }

      access_key_id = "ASgeIAIOSFODNN7EXAMPLE"
      secret_access_key = "AROACLKWSDQRAOEXAMPLE:test"
      security_token = "AQoDYXdzEE0a8ANXXXXXXXXNO1ewxE5TijQyp+IEXAMPLE"

      sts_resp_xml =
        sts_xml_response(
          @role_session_name,
          @role_arn,
          security_token,
          access_key_id,
          secret_access_key
        )

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             "https://sts.amazonaws.com/",
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=2222222%2Ftest_role&RoleSessionName=default_session&Version=2011-06-15&WebIdentityToken=yo",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: sts_resp_xml}}
      end)

      expected = %{
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        security_token: security_token,
        role_arn: @role_arn,
        role_session_name: @role_session_name,
        expiration: @expiration
      }

      assert expected == AssumeRoleWebIdentityAdapter.adapt_auth_config(config, nil, nil)
    end

    test "when the region is not specified - fall back to default region" do
      System.delete_env("AWS_REGION")
      System.put_env("AWS_STS_REGIONAL_ENDPOINTS", "regional")

      config = %{
        region: "us-east-1",
        http_client: ExAws.Request.HttpMock
      }

      sts_resp_xml =
        sts_xml_response(
          "role_session_name",
          "role_arn",
          "security_token",
          "access_key_id",
          "secret_access_key"
        )

      ExAws.Request.HttpMock
      |> expect(:request, fn _method,
                             "https://sts.us-east-1.amazonaws.com/",
                             "Action=AssumeRoleWithWebIdentity&DurationSeconds=900&RoleArn=2222222%2Ftest_role&RoleSessionName=default_session&Version=2011-06-15&WebIdentityToken=yo",
                             _headers,
                             _opts ->
        {:ok, %{status_code: 200, body: sts_resp_xml}}
      end)

      AssumeRoleWebIdentityAdapter.adapt_auth_config(config, nil, nil)
    end
  end

  describe "when the specified file does not exist" do
    test "#adapt_auth_config" do
      System.put_env("AWS_WEB_IDENTITY_TOKEN_FILE", "./does_not_exist")

      assert_raise File.Error, fn ->
        AssumeRoleWebIdentityAdapter.adapt_auth_config(%{}, nil, nil)
      end
    end
  end

  defp test_loader(_config) do
    %{
      role_arn: "1111111/test_role",
      web_identity_token: "ey",
      use_regional_endpoints: false
    }
  end

  defp sts_xml_response(session_name, role_arn, security_token, access_key_id, secret_access_key) do
    {
      "AssumeRoleWithWebIdentityResponse",
      [xmlns: "http://schemas.example.tld/1999"],
      [
        {
          "AssumeRoleWithWebIdentityResult",
          nil,
          [
            {"SubjectFromWebIdentityToken", nil, "amzn1.account.AF6RHO7KZU5XRVQJGXK6HB56KR2A"},
            {"Audience", nil, "client.5498841531868486423.1548@apps.example.com"},
            {"AssumedRoleUser", nil,
             [
               {"Arn", nil, "#{role_arn}/#{session_name}"},
               {"AssumedRoleId", nil, "AROACLKWSDQRAOEXAMPLE:#{session_name}"}
             ]},
            {"Credentials", nil,
             [
               {"SessionToken", nil, security_token},
               {"SecretAccessKey", nil, secret_access_key},
               {"Expiration", nil, "2014-10-24T23:00:23Z"},
               {"AccessKeyId", nil, access_key_id}
             ]},
            {"SourceIdentity", nil, "SourceIdentityValue"},
            {"Provider", nil, "www.amazon.com"}
          ]
        }
      ]
    }
    |> XmlBuilder.generate()
  end
end
