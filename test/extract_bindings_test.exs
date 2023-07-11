defmodule ExtractBindingsTest do
  use ExUnit.Case
  import ExtractBindings

  test "variables should only yield themselves" do
    assert extract_binding(quote do: x) == [quote(do: x)]
  end

  test "variables with default values should only yield themselves" do
    assert extract_binding(quote do: x \\ 42) == [quote(do: x)]
  end

  test "exact match to a constant should yield no bindings" do
    assert extract_binding(:match) == []
    assert extract_binding(42) == []
    assert extract_binding(nil) == []
    assert extract_binding(true) == []
  end

  test "(left) aliased exact matches should yield the alias" do
    assert extract_binding(quote do: x = :match) == [quote(do: x)]
  end

  test "(right) aliased exact matches should yield the alias" do
    assert extract_binding(quote do: :match = x) == [quote(do: x)]
  end

  test "an aliased pattern should yield both sides" do
    assert extract_binding(quote do: x = y) == [quote(do: x), quote(do: y)]
  end

  test "matching an empty struct should yield no vars" do
    assert extract_binding(quote do: %{}) == []
  end

  test "matching a struct should yield its vars" do
    assert extract_binding(quote do: %{x: 42}) == []
    assert extract_binding(quote do: %{x: v}) == [quote(do: v)]
    assert extract_binding(quote do: %{x: v, y: w}) == [quote(do: v), quote(do: w)]
  end

  test "matching list should yield every pattern's vars" do
    assert extract_binding(quote do: []) == []
    assert extract_binding(quote do: [x]) == [quote(do: x)]
    assert extract_binding(quote do: [x, y]) == [quote(do: x), quote(do: y)]
    assert extract_binding(quote do: [x, y, z]) == [quote(do: x), quote(do: y), quote(do: z)]
    assert extract_binding(quote do: [x | y]) == [quote(do: x), quote(do: y)]
  end

  test "should work with nested data structures" do
    code =
      quote do
        obj = %{x: %{"a" => a, ^x => b}, z: [c, d]}
      end

    assert extract_binding(code) == [
             quote(do: obj),
             quote(do: a),
             quote(do: b),
             quote(do: c),
             quote(do: d)
           ]
  end
end
