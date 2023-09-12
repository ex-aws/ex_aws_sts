defmodule ExAws.STS.Parsers.XML do
  @moduledoc false

  def xpath(parent, spec, subspec) do
    xml_module().xpath(parent, spec, subspec)
  rescue
    _ in UndefinedFunctionError ->
      raise "Dependency sweet_xml is required for role based authentication"
  end

  def sigil_x(path, modifiers) do
    xml_module().sigil_x(path, modifiers)
  rescue
    _ in UndefinedFunctionError ->
      raise "Dependency sweet_xml is required for role based authentication"
  end

  defp xml_module, do: Application.get_env(:ex_aws_sts, :xml_module, SweetXml)
end
