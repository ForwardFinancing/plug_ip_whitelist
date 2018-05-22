defmodule Plug.IpWhitelist.IpWhitelistEnforcer do
  @moduledoc """
    Only allow requests from the range of IP addresses specified in the
    application config. Assumes the request ip is present in the `remote_ip`
    attribute on the passed in plug.
    If the request IP is not whitelisted, the specified response code and body
      will be added to the Plug.Conn and it will be halted.
    If the request IP is on the whitelist, the plug chain will continue
    Include this module in your plug chain with required options
    Options:
      ip_whitelist (required): A list of ip range tuples
        Example:
          ```
            [
              {{1, 1, 1, 1}, {1, 1, 1, 2}},
              {{1, 2, 3, 4}, {5, 6, 7, 8}}
            ]
          ```
        This designates the ranges of IP addresses which are whitelisted
      response_code_when_blacklisted: The HTTP status code assigned to the
        response when the request's IP address is not in the whitelist. Defaults
        to `401` if not specified
      response_body_when_blacklisted: The body assigned to the response when the
        request's IP address is not in the whitelist. Defaults to
        `"Not Authenticated"` if not specified
    Example:
      ```
        # Include after a plug which adds the request IP to the remote_ip
        #   attribute on the Plug.Conn
        plug Plug.IpWhitelist.IpWhitelistEnforcer, [
          ip_whitelist: [
            {{1, 1, 1, 1}, {1, 1, 1, 2}},
            {{1, 2, 3, 4}, {5, 6, 7, 8}}
          ]
        ]
      ```
  """

  import Plug.Conn
  alias Plug.IpWhitelist

  @doc """
    Initialize the plug with options as described in the module documentation
  """
  @spec init(
          ip_whitelist: [IpWhitelist.ip_range(), ...],
          response_code_when_blacklisted: integer(),
          response_body_when_blacklisted: String.t()
        ) :: [
          ip_whitelist: [IpWhitelist.ip_range(), ...],
          response_code_when_blacklisted: integer(),
          response_body_when_blacklisted: String.t()
        ]
  def init(options), do: options

  @spec call(
          Plug.Conn.t(),
          ip_whitelist: [IpWhitelist.ip_range(), ...],
          response_code_when_blacklisted: integer(),
          response_body_when_blacklisted: String.t()
        ) :: Plug.Conn.t()
  def call(conn, options) do
    ip_whitelist = Keyword.fetch!(options, :ip_whitelist)
    # Do any of the whitelisted IP ranges contain the request ip?
    if Enum.any?(ip_whitelist, &ip_in_range?(&1, conn.remote_ip)) do
      # If the request IP was in the range, return the conn unchanged to
      #   continue through the plug pipeline
      conn
    else
      # If the request IP was not in the range, return the specified response
      #   code and response body
      conn
      |> send_resp(
        Keyword.get(options, :response_code_when_blacklisted, 401),
        Keyword.get(
          options,
          :response_body_when_blacklisted,
          "Not Authenticated"
        )
      )
      |> halt()
    end
  end

  # If there is no ip than it is not in the range
  @spec ip_in_range?(any, nil) :: false
  defp ip_in_range?(_, nil), do: false

  # Convert the tuple ip addresses to lists so they can be iterated over
  @spec ip_in_range?(IpWhitelist.ip_range(), IpWhitelist.ip()) :: boolean
  defp ip_in_range?({lower_bound, upper_bound}, ip_address)
       when is_tuple(lower_bound) and is_tuple(upper_bound) and
              is_tuple(ip_address) do
    ip_in_range?(
      {Tuple.to_list(lower_bound), Tuple.to_list(upper_bound)},
      Tuple.to_list(ip_address)
    )
  end

  @spec ip_in_range?(
          {IpWhitelist.ip_as_list(), IpWhitelist.ip_as_list()},
          IpWhitelist.ip_as_list()
        ) :: boolean
  defp ip_in_range?({lower_bound, upper_bound}, ip_address)
       when is_list(lower_bound) and is_list(upper_bound) and
              is_list(ip_address) do
    # Confirm that for each part of the ip address, that part is greater than
    #   or equal to the lower bound at that part's index and less than or equal
    #   to the upper bound at that part's index
    ip_address
    |> Enum.with_index()
    |> Enum.all?(fn {ip_byte, index} ->
      ip_byte >= Enum.at(lower_bound, index) &&
        ip_byte <= Enum.at(upper_bound, index)
    end)
  end
end
