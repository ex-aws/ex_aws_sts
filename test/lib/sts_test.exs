defmodule ExAws.STSTest do
  use ExUnit.Case, async: true

  alias ExAws.STS

  test "#get_caller_identity" do
    version = "2011-06-15"

    expected = %{
      "Action" => "GetCallerIdentity",
      "Version" => version
    }

    assert expected == STS.get_caller_identity().params
  end

  test "#assume_role" do
    version = "2011-06-15"
    arn = "1111111/test_role"
    name = "test role"
    external_id = "test id"

    expected = %{
      "Action" => "AssumeRole",
      "RoleSessionName" => name,
      "RoleArn" => arn,
      "Version" => version,
      "ExternalId" => external_id
    }

    assert expected == STS.assume_role(arn, name, external_id: external_id).params
  end

  test "#assume_role_with_web_identity" do
    version = "2011-06-15"
    arn = "1111111/test_role"
    name = "test role"
    token = "atoken"

    expected = %{
      "Action" => "AssumeRoleWithWebIdentity",
      "RoleSessionName" => name,
      "RoleArn" => arn,
      "WebIdentityToken" => token,
      "Version" => version
    }

    assert expected == STS.assume_role_with_web_identity(arn, name, token).params
  end

  test "#assume_role_with_saml" do
    version = "2011-06-15"
    principal_arn = "1111111/test_principal"
    role_arn = "1111111/test_role"
    saml_assertion = "assertioncontent" |> Base.encode64()

    expected = %{
      "Action" => "AssumeRoleWithSAML",
      "PrincipalArn" => principal_arn,
      "RoleArn" => role_arn,
      "SAMLAssertion" => saml_assertion,
      "Version" => version
    }

    assert expected == STS.assume_role_with_saml(principal_arn, role_arn, saml_assertion).params
  end

  test "#decode_authorization_message" do
    version = "2011-06-15"
    message = "msgcontent"

    expected = %{
      "Action" => "DecodeAuthorizationMessage",
      "EncodedMessage" => message,
      "Version" => version
    }

    assert expected == STS.decode_authorization_message(message).params
  end

  test "#get_access_key_info" do
    version = "2011-06-15"
    key_id = "AKIAI44QH8DHBEXAMPLE"

    expected = %{
      "Action" => "GetAccessKeyInfo",
      "AccessKeyId" => key_id,
      "Version" => version
    }

    assert expected == STS.get_access_key_info(key_id).params
  end

  test "#get_federation_token" do
    version = "2011-06-15"
    duration = 900
    name = "Bob"

    policy = %{
      "Statement" => [
        %{
          "Sid" => "Stmt1",
          "Effect" => "Allow",
          "Action" => "s3:*",
          "Resource" => "*"
        }
      ]
    }

    expected = %{
      "Action" => "GetFederationToken",
      "DurationSeconds" => duration,
      "Name" => name,
      "Policy" => Jason.encode!(policy),
      "Version" => version
    }

    opts = [duration: duration, policy: policy]

    assert expected == STS.get_federation_token(name, opts).params
  end

  test "#get_session_token" do
    version = "2011-06-15"
    duration = 900

    expected = %{
      "Action" => "GetSessionToken",
      "DurationSeconds" => duration,
      "Version" => version
    }

    assert expected == STS.get_session_token(duration: duration).params
  end
end
