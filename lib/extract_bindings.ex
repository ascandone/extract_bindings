defmodule ExtractBindings do
  def extract_binding(param) do
    case param do
      {:\\, _, [left, _]} ->
        [left]

      {:=, _, [left, right]} ->
        extract_binding(left) ++ extract_binding(right)

      {:%{}, _, args} ->
        for {_key, value} <- args,
            bound <- extract_binding(value) do
          bound
        end

      [] ->
        []

      [hd | tl] ->
        extract_binding(hd) ++ extract_binding(tl)

      {:|, _, [hd, tl]} ->
        extract_binding(hd) ++ extract_binding(tl)

      {name, _, _} when is_atom(name) ->
        [param]

      _ ->
        []
    end
  end
end
