defmodule ExAws.STS.AuthCache.AssumeRoleCredentialsAdapter do
  @moduledoc """
  Provides a custom Adapter that intercepts ExAWS configuration
  which uses Role ARN + Source Profile for authentication.
  """

  @behaviour ExAws.Config.AuthCache.AuthConfigAdapter

  @impl true
  def adapt_auth_config(auth, profile, expiration) do
    adapt_auth_config(auth, profile, expiration, &load_credentials/1)
  end

  def adapt_auth_config(%{source_profile: source_profile} = auth, _, expiration, loader) do
    source_profile_auth = loader.(source_profile)
    get_security_credentials(auth, source_profile_auth, expiration)
  end

  def adapt_auth_config(auth, _, _, _), do: auth

  defp get_security_credentials(auth, source_profile_auth, expiration) do
    duration = credential_duration_seconds(expiration)
    role_session_name = Map.get(auth, :role_session_name, "default_session")

    assume_role_options =
      case auth do
        %{external_id: external_id} -> [duration: duration, external_id: external_id]
        _ -> [duration: duration]
      end

    assume_role_request =
      ExAws.STS.assume_role(auth.role_arn, role_session_name, assume_role_options)

    assume_role_config = ExAws.Config.new(:sts, source_profile_auth)

    with {:ok, result} <- ExAws.request(assume_role_request, assume_role_config) do
      %{
        access_key_id: result.body.access_key_id,
        secret_access_key: result.body.secret_access_key,
        security_token: result.body.session_token,
        role_arn: auth.role_arn,
        role_session_name: role_session_name,
        source_profile: auth.source_profile
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

  defp load_credentials(profile) do
    ExAws.CredentialsIni.security_credentials(profile)
  end
end
