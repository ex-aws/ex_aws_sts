defmodule ExAws.STS.ParsersTest do
  use ExUnit.Case, async: true

  alias ExAws.STS.Parsers

  def parse_mock_response(action, arity) when is_atom(action) do
    p = Path.join([__DIR__, "fixtures", "#{to_string(action)}_response.xml"])
    mock_response = {:ok, %{body: File.read!(p)}}

    case arity do
      2 ->
        Parsers.parse(mock_response, action)

      3 ->
        config = [json_codec: Jason]

        Parsers.parse(mock_response, action, config)
    end
  end

  @actions [
    assume_role: 2,
    assume_role_with_s_a_m_l: 2,
    assume_role_with_web_identity: 2,
    decode_authorization_message: 3,
    get_access_key_info: 2,
    get_caller_identity: 2,
    get_session_token: 2,
    get_federation_token: 2
  ]

  if System.get_env("SWEET_XML") == "DISABLED" do
    for {action, arity} <- @actions do
      test "raises missing sweet_xml error for `:#{action}`" do
        assert_raise RuntimeError,
                     "Dependency sweet_xml is required for role based authentication",
                     fn -> parse_mock_response(unquote(action), unquote(arity)) end
      end
    end
  else
    # Build tests for all actions and verifies that mock responses were parsed
    for {action, arity} <- @actions do
      @tag action: action
      test "parses `:#{action}` using mock response" do
        assert {:ok, %{body: body}} = parse_mock_response(unquote(action), unquote(arity))

        for {_, value} <- body do
          assert value && value != "", "did not parse value for response"
        end
      end
    end
  end
end
