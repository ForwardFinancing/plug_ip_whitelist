defmodule Plug.IpWhitelist.HerokuRemoteIp do
  @moduledoc """
    This Plug is for use on applications running on Heroku. It injects the ip
    address of the request into the the remote_ip attribute on the Plug.
    It should be included in the Plug pipeline before the `IpWhitelistEnforcer`.
    We can get the originating request IP from the X-Forwarded-For header, which
    usually contains a single ip address ie:
      X-Forwarded-For: <the real request ip>
    It will contain list of ip addresses if something besides the heroku router
    modified the X-Forwarded-For header earlier in the request chain. An example
    of when this would happen is if an attacker were trying to spoof the IP
    address. The heroku router handles this by including a comma-seperated list
    of ip addresses in the X-Forwarded-For header, where the last ip address
    in the list is the originating request IP, ie:
      X-Forwarded-For: <spoofed request ip>, <real request ip>
    So, we make the assumption that the heroku router isn't compromised and that
    nothing between the heroku router and our application has been compromised.
    Given that assumption, we can trust that the last ip address in the list is
    the actual originating request IP, which we want to compare against our
    whitelist
    See also: https://devcenter.heroku.com/articles/http-routing#heroku-headers
  """

  alias Plug.IpWhitelist
  import Plug.Conn

  @doc """
    Initialize the plug with options (there are none)
  """
  def init(options), do: nil

  @doc """
    Find the request IP address as described in the module documentation.
    Set the request IP address that is discovered as the `remote_ip` attribute
    on the returned Plug.Conn
  """
  @spec call(Plug.Conn.t(), nil) :: Plug.Conn.t()
  def call(conn, nil) do
    Map.put(
      conn,
      :remote_ip,
      request_ip(conn)
    )
  end

  # Retrieve the request IP from the Plug.Conn (in the X-Forwarded-For header
  #   as described above)
  @spec request_ip(Plug.Conn.t()) :: IpWhitelist.ip() | nil
  defp request_ip(conn) do
    request_ip_list =
      conn
      |> get_req_header("x-forwarded-for")
      |> List.last()

    if request_ip_list do
      # Get the last ip address in the list and parse
      case request_ip_list
           |> String.split(", ")
           |> List.last()
           |> String.to_charlist()
           |> :inet_parse.address() do
        {:ok, request_ip_address} -> request_ip_address
        _ -> nil
      end
    else
      nil
    end
  end
end
