defmodule LogFormatter do
  @moduledoc """
  simple log formatter
  """
  @protected [:request_ip]

  # https://timber.io/blog/the-ultimate-guide-to-logging-in-elixir/

  def format(level, message, timestamp, metadata) do
    "#{fmt_timestamp(timestamp)} [#{level}] #{fmt_metadata(metadata)} message: #{message}\n"
  rescue
    _ -> "could not format message: #{inspect({level, message, timestamp, metadata})}\n"
  end

  defp fmt_metadata(md) do
    md
    |> Keyword.keys()
    |> Stream.map(&output_metadata(md, &1))
    |> Enum.join(" ")
  end

  def output_metadata(metadata, key) do
    case key in @protected do
      true ->
        redacted = String.slice(metadata[key], 0..3)
        rest = String.slice(metadata[key], 4..-1) |> String.replace(~r/([0-9])/, "*")
        "#{key}=(#{redacted <> rest})"

      _ ->
        "#{key}=(#{metadata[key]})"
    end
  end

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 3}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}Z"
    end
  end
end
