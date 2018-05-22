defmodule Plug.IpWhitelist.IpWhitelistEnforcerTest do
  use ExUnit.Case, async: true

  def plug_ip_whitelist_options do
    [
      ip_whitelist: [
        {{111, 111, 111, 110}, {111, 111, 111, 112}},
        {{111, 222, 0, 0}, {111, 222, 255, 255}}
      ]
    ]
  end

  defp build_conn do
    Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, "/", nil)
  end

  test "options returns options" do
    assert "options" == Plug.IpWhitelist.IpWhitelistEnforcer.init("options")
  end

  test "excludes requests outside of the whitelisted ip ranges" do
    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    assert request.resp_body == "Not Authenticated"
    assert request.status == 401

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "3.3.3.3, 2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    assert request.resp_body == "Not Authenticated"
    assert request.status == 401

    request =
      build_conn()
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    assert request.resp_body == "Not Authenticated"
    assert request.status == 401

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "foooo")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    assert request.resp_body == "Not Authenticated"
    assert request.status == 401
  end

  test "responds with response body option when blacklisted" do
    options =
      plug_ip_whitelist_options()
      |> Keyword.put(:response_body_when_blacklisted, "A Custom Response Body")

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(options)

    assert request.resp_body == "A Custom Response Body"
    assert request.status == 401
  end

  test "responds with response code option when blacklisted" do
    options =
      plug_ip_whitelist_options()
      |> Keyword.put(:response_code_when_blacklisted, 418)

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(options)

    assert request.resp_body == "Not Authenticated"
    # (I am a Teapot.)
    assert request.status == 418
  end

  test "allows requests inside the whitelisted ip ranges" do
    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "111.111.111.111")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    refute request.status == 401
    refute request.resp_body == "Not Authenticated"

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "3.3.3.3, 111.111.111.111")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    refute request.status == 401
    refute request.resp_body == "Not Authenticated"

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "111.222.255.255")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    refute request.status == 401
    refute request.resp_body == "Not Authenticated"

    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "111.222.0.0")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)
      |> Plug.IpWhitelist.IpWhitelistEnforcer.call(plug_ip_whitelist_options())

    refute request.status == 401
    refute request.resp_body == "Not Authenticated"
  end
end
