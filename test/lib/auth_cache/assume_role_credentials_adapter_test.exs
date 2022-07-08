defmodule ExAws.STS.AuthCache.AssumeRoleCredentialsAdapterTest do
  use ExUnit.Case, async: true
  alias ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter

  import Mox

  test "#adapt_auth_config" do
    profile = "default"
    auth = test_loader(profile)

    expected = %{
      access_key_id: "accessKeYz",
      secret_access_key: "secret_access_KeY",
      security_token: "SeCURItyToken",
      role_arn: auth.role_arn,
      role_session_name: auth.role_session_name,
      source_profile: auth.source_profile
    }

    sts_xml_resp =
      sts_xml_response(
        expected.role_session_name,
        expected.role_arn,
        expected.security_token,
        expected.access_key_id,
        expected.secret_access_key
      )

    ExAws.Request.HttpMock
    |> expect(:request, fn _method,
                           _url,
                           "Action=AssumeRole&DurationSeconds=900&RoleArn=1111111%2Ftest_role&RoleSessionName=test&Version=2011-06-15",
                           _headers,
                           _opts ->
      {:ok, %{status_code: 200, body: sts_xml_resp}}
    end)

    assert expected ==
             AssumeRoleCredentialsAdapter.adapt_auth_config(auth, profile, 300, &test_loader/1)
  end

  defp test_loader("default") do
    %{
      source_profile: "source",
      role_arn: "1111111/test_role",
      role_session_name: "test"
    }
  end

  defp test_loader("source") do
    %{
      http_client: ExAws.Request.HttpMock,
      access_key_id: "1",
      secret_access_key: "secret",
      region: "us-east-1"
    }
  end

  defp sts_xml_response(session_name, role_arn, security_token, access_key_id, secret_access_key) do
    {
      "AssumeRoleResponse",
      [xmlns: "https://sts.amazonaws.com/doc/2011-06-15/"],
      [
        {
          "AssumeRoleResult",
          nil,
          [
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
             ]}
          ]
        }
      ]
    }
    |> XmlBuilder.generate()
  end

end
