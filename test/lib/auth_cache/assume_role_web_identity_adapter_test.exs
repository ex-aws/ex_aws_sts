defmodule ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapterTest do
  use ExUnit.Case, async: false
  alias ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter

  import Mox

  setup do
    Application.put_env(
      :ex_aws,
      :awscli_auth_adapter,
      ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter
    )

    on_exit(fn ->
      Application.put_env(:ex_aws, :awscli_auth_adapter, nil)
    end)
  end

  test "#adapt_auth_config" do
    profile = "any"
    auth = test_loader(profile)

    body = %{
      access_key_id: "1",
      secret_access_key: "secret",
      session_token: "token"
    }

    ExAws.Request.HttpMock
    |> expect(:request, fn _method, _url, _body, _headers, _opts ->
      require IEx
      IEx.pry()
      {:ok, %{status_code: 200, body: body}}
    end)

    expected = %{
      access_key_id: body.access_key_id,
      secret_access_key: body.secret_access_key,
      security_token: body.session_token,
      role_arn: auth.role_arn,
      role_session_name: auth.role_session_name
    }

    assert expected ==
             AssumeRoleWebIdentityAdapter.adapt_auth_config(profile, 300, &test_loader/1)
  end

  defp test_loader(profile) do
    %{
      secret_access_key: [{:awscli, profile, 30}],
      access_key_id: [{:awscli, profile, 30}],
      role_arn: "1111111/test_role",
      role_session_name: "test",
      token: "ey",
      region: "us-east-1",
      http_client: ExAws.Request.HttpMock
    }
  end
end
