defmodule Plug.IpWhitelist.EnvironmentVariableParserTest do
  use ExUnit.Case, async: true

  test "parse" do
    assert(
      Plug.IpWhitelist.EnvironmentVariableParser.parse(
        "1.1.1.1-1.1.1.1 2.3.4.5-6.7.8.9"
      ) ==
        [
          {{1, 1, 1, 1}, {1, 1, 1, 1}},
          {{2, 3, 4, 5}, {6, 7, 8, 9}}
        ]
    )
  end

  test "invalid ip byte" do
    assert(
      Plug.IpWhitelist.EnvironmentVariableParser.parse_ip_byte("300") ==
        {:error, "IP byte must be between 0 and 255"}
    )
  end
end
