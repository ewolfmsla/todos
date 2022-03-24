defmodule LoggerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  require Logger

  test "redacts ip address but not foo" do
    {result, log} =
      with_log(fn ->
        Logger.info("test, 1, 2, 3", request_ip: "192.168.1.42", foo: "bar")
        1 + 2 * 3
      end)

    assert result == 7
    assert log =~ "request_ip=(192.***.*.**)"
    assert log =~ "foo=(bar)"

    IO.inspect(log)
  end
end
