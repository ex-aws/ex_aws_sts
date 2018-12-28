defmodule ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter do
  @moduledoc false

  @behaviour ExAws.Config.AuthCache.AuthConfigAdapter

  @impl true
  def adapt_auth_config(auth, _profile, expiration) do
    auth =
      case auth do
        %{source_profile: source_profile} ->
          source_profile_auth = ExAws.CredentialsIni.security_credentials(source_profile)
          Map.merge(auth, source_profile_auth)

        _ ->
          auth
      end

    security_credentials_for(auth, expiration)
  end

  defp security_credentials_for(%{role_arn: role_arn} = auth, expiration) do
    assume_role_options =
      if auth[:external_id] do
        [
          duration: credential_duration_seconds(expiration),
          external_id: auth[:external_id]
        ]
      else
        [duration: credential_duration_seconds(expiration)]
      end

    role_session_name = auth[:role_session_name] || "default_session"

    {:ok, result} =
      role_arn
      |> ExAws.STS.assume_role(role_session_name, assume_role_options)
      |> ExAws.Operation.perform(ExAws.Config.new(:sts))

    %{
      access_key_id: result.body.access_key_id,
      secret_access_key: result.body.secret_access_key,
      security_token: result.body.session_token,
      expiration: result.body.expiration,
      role_arn: role_arn,
      role_session_name: role_session_name,
      source_profile: auth[:source_profile]
    }
  end

  defp security_credentials_for(auth, _expiration), do: auth

  defp credential_duration_seconds(expiration_ms) do
    # assume_role accepts a duration between 900 and 3600 seconds
    # We're adding a buffer to make sure the credentials live longer than
    # the refresh interval.
    {min, max, buffer} = {900, 3600, 5}
    seconds = div(expiration_ms, 1000) + buffer
    Enum.max([Enum.min([max, seconds]), min])
  end
end
