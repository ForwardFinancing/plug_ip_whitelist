defmodule Plug.IpWhitelist.EnvironmentVariableParser do
  @moduledoc """
    IP Whitelists often need to be stored as an environment variable.
    This module provides functionality for parsing a list of IP ranges out of a
    string which could be stored in your application's environment variables.
    Example:
      "1.1.1.1-1.1.1.1 2.3.4.5-6.7.8.9"
  """

  @doc """
    Given a string of ip ranges, convert to a list of ip ranges
    Example input:
      "1.1.1.1-1.1.1.1 2.3.4.5-6.7.8.9"
    Example output:
      [
        {{1, 1, 1, 1}, {1, 1, 1, 1}},
        {{2, 3, 4, 5}, {6, 7, 8, 9}}
      ]
  """
  @spec parse(String.t()) :: [IpWhitelist.ip_range(), ...]
  def parse(string_ip_whitelist) do
    string_ip_whitelist
    |> String.split(" ")
    |> Enum.map(&parse_ip_range/1)
  end

  @doc """
    Given a string which contains an ip range, convert to an ip_range
    Example input:
      1.1.1.1-1.1.1.1
    Example output:
      {{1, 1, 1, 1}, {1, 1, 1, 1}}
  """
  @spec parse_ip_range(String.t()) :: IpWhitelist.ip_range()
  def parse_ip_range(string_ip_range) do
    string_ip_range
    |> String.split("-")
    |> Enum.map(&parse_ip_address/1)
    |> List.to_tuple()
  end

  @doc """
    Given a string which contains an ip address, convert to an ip_address
    Example input:
      "1.1.1.1"
    Example output:
      {1, 1, 1, 1}
  """
  @spec parse_ip_address(String.t()) :: IpWhitelist.ip_address()
  def parse_ip_address(string_ip_address) do
    string_ip_address
    |> String.split(".")
    |> Enum.map(&parse_ip_byte/1)
    |> List.to_tuple()
  end

  @doc """
    Given a string which contains an integer, convert to an integer (ip_byte)
    Example input:
      "1"
    Example output:
      1
  """
  @spec parse_ip_byte(String.t()) :: IpWhitelist.ip_byte()
  def parse_ip_byte(string_ip_byte) do
    ip_byte =
      string_ip_byte
      |> Integer.parse()
      |> Tuple.to_list()
      |> List.first()

    if ip_byte >= 0 && ip_byte <= 255 do
      ip_byte
    else
      {:error, "IP byte must be between 0 and 255"}
    end
  end
end
