defmodule ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter do
  @moduledoc """
  Provides a custom Adapter which intercepts ExAWS configuration
  which uses Role ARN + Source Profile for authentication.
  """

  @behaviour ExAws.Config.AuthCache.AuthConfigAdapter

  @impl true
  def adapt_auth_config(config, profile, expiration) do
    adapt_auth_config(config, profile, expiration, &loader/1)
  end

  def adapt_auth_config(config, _profile, expiration, loader) do
    auth = Map.merge(config, loader.(config))
    get_security_credentials(auth, expiration || 30_000)
  end

  defp get_security_credentials(auth, expiration) do
    duration = credential_duration_seconds(expiration)

    assume_role_request =
      ExAws.STS.assume_role_with_web_identity(
        auth.role_arn,
        auth.role_session_name,
        auth.web_identity_token,
        duration: duration
      )

    with {:ok, result} <- ExAws.request(assume_role_request, auth) do
      %{
        access_key_id: result.body.access_key_id,
        secret_access_key: result.body.secret_access_key,
        security_token: result.body.session_token,
        role_arn: auth.role_arn,
        role_session_name: auth.role_session_name,
        expiration: expiration
      }
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp credential_duration_seconds(expiration_ms) do
    # assume_role accepts a duration between 900 and 3600 seconds
    # We're adding a buffer to make sure the credentials live longer than
    # the refresh interval.
    {min, max, buffer} = {900, 3600, 5}
    seconds = div(expiration_ms, 1000) + buffer
    Enum.max([Enum.min([max, seconds]), min])
  end

  defp loader(config) do
    %{
      access_key_id: "dummy",
      secret_access_key: "dummy",
      role_arn: env_role_arn(config),
      role_session_name: role_session_name(config),
      web_identity_token: web_identity_token(config)
    }
  end

  defp web_identity_token(config) do
    path = config[:web_identity_token_file] || System.get_env("AWS_WEB_IDENTITY_TOKEN_FILE")
    {:ok, token} = File.read(path)
    token
  end

  defp env_role_arn(config) do
    config[:role_arn] || System.get_env("AWS_ROLE_ARN")
  end

  defp role_session_name(config) do
    config[:role_session_name] || "default_session"
  end
end
