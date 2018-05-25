defmodule Plug.IpWhitelist.HerokuRemoteIpTest do
  use ExUnit.Case, async: true

  defp build_conn do
    Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, "/", nil)
  end

  test "options returns nil" do
    assert nil == Plug.IpWhitelist.HerokuRemoteIp.init("options")
  end

  test "Sets remote_ip from x-forwarded-for" do
    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)

    assert request.remote_ip == {2, 2, 2, 2}
  end

  test "Ignores spoofed ips" do
    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "1.1.1.1, 2.2.2.2")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)

    assert request.remote_ip == {2, 2, 2, 2}
  end

  test "Can handle invalid x-forwarded-for" do
    request =
      build_conn()
      |> Plug.Conn.put_req_header("x-forwarded-for", "not an ip address")
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)

    assert request.remote_ip == nil
  end

  test "Can handle missing x-forwarded-for" do
    request =
      build_conn()
      |> Plug.IpWhitelist.HerokuRemoteIp.call(nil)

    assert request.remote_ip == nil
  end
end
