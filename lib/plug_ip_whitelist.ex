defmodule Plug.IpWhitelist do
  @moduledoc """
    Parent module for the IpWhitelisting plug
  """

  # An ip byte is the things with dots between them i guess
  @type ip_byte :: 0..255

  # An ip is a tuple with 4 ip bytes
  @type ip :: {ip_byte, ip_byte, ip_byte, ip_byte}

  # We can also represent an ip as a list when that is easier for enumeration
  @type ip_as_list :: [ip_byte, ...]

  # An ip range is a tuple of 2 ips {upper bound, lower bound}
  @type ip_range :: {ip, ip}
end
