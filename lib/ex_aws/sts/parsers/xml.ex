defmodule ExAws.STS.Parsers.XML do
  @moduledoc false

  if Code.ensure_loaded?(SweetXml) do
    defdelegate xpath(parent, spec, subspec), to: SweetXml
    defdelegate sigil_x(path, modifiers), to: SweetXml
  else
    def xpath(_parent, _spec, _subspec),
      do: raise("Dependency sweet_xml is required for role based authentication")

    def sigil_x(_path, _modifiers),
      do: raise("Dependency sweet_xml is required for role based authentication")
  end
end
