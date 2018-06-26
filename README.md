# Plug.IpWhitelist

[![Maintainability](https://api.codeclimate.com/v1/badges/78d5200b37d13ff2da1d/maintainability)](https://codeclimate.com/github/ForwardFinancing/plug_ip_whitelist/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/78d5200b37d13ff2da1d/test_coverage)](https://codeclimate.com/github/ForwardFinancing/plug_ip_whitelist/test_coverage)

[![Build Status](https://travis-ci.org/ForwardFinancing/plug_ip_whitelist.svg?branch=master)](https://travis-ci.org/ForwardFinancing/plug_ip_whitelist)

## Installation

The package can be installed by adding `plug_ip_whitelist` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plug_ip_whitelist, "~> 1.0.0"}
  ]
end
```

## Usage

Include `Plug.IpWhitelist.IpWhitelistEnforcer` somewhere in your Phoenix application's plug chain, with options. This usually means it goes somewhere in your Routes or Endpoint files, or in a Controller:

```elixir
plug Plug.IpWhitelist.IpWhitelistEnforcer, [
  ip_whitelist: [
      {{1, 1, 1, 1}, {1, 1, 1, 2}},
      {{1, 2, 3, 4}, {5, 6, 7, 8}}
  ],
  response_code_when_blacklisted: 401,
  response_body_when_blacklisted: "Not Authenticated"
]
```

### IMPORTANT: Set IP Address via `remote_ip`
Phoenix/Plug.Conn do not provide out of the box support for request ip address. IpWhitelistEnforcer assumes that something further up the plug chain has already set the `remote_ip` attribute on the connection to be the request ip address. If your application runs on Heroku, see the section on Usage with Heroku for the built-in functionality provided

### Usage outside of a Plug

Sometimes you just want a boolean indicating whether or not an IP address is on
the whitelist.

```elixir
ip_whitelist = [
    {{1, 1, 1, 1}, {1, 1, 1, 2}},
    {{1, 2, 3, 4}, {5, 6, 7, 8}}
]

# You can pass in a Plug.Conn to see if it's remote ip is whitelisted:
Plug.IpWhitelist.IpWhitelistEnforcer.is_whitelisted?(some_conn, ip_whitelist)
# => true/false

# Or you can pass in an IP address directly:
Plug.IpWhitelist.IpWhitelistEnforcer.is_whitelisted?({1, 1, 1, 1}, ip_whitelist)
# => true
```

### Options

`ip_whitelist` (required): A list of ip range tuples

  Example:
    ```
      [
        {{1, 1, 1, 1}, {1, 1, 1, 2}},
        {{1, 2, 3, 4}, {5, 6, 7, 8}}
      ]
    ```
  This designates the ranges of IP addresses which are whitelisted

`response_code_when_blacklisted`: The HTTP status code assigned to the
  response when the request's IP address is not in the whitelist. Defaults
  to `401` if not specified

`response_body_when_blacklisted`: The body assigned to the response when the
  request's IP address is not in the whitelist. Defaults to
  `"Not Authenticated"` if not specified

## Usage with Heroku

If your application runs on Heroku, the request ip can be retrieved from the X-Forwarded-For header (this header is set by the Heroku router). The Plug.IpWhitelist.HerokuRemotIp plug handles retrieving the request ip from the X-Forwarded-For header and storing it in the `remote_ip` attribute on the connection.

To use this module, include it in your plug chain anywhere before the IpWhitelistEnforcer plug:

```elixir
plug Plug.IpWhitelist.HerokuRemoteIp
plug Plug.IpWhitelist.IpWhitelistEnforcer, [...options...]
```

For more info see the module documentation https://hexdocs.pm/plug_ip_whitelist/Plug.IpWhitelist.HerokuRemoteIp

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/plug_ip_whitelist](https://hexdocs.pm/plug_ip_whitelist).

