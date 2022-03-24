import Config

config :logger, :console,
  format: {LogFormatter, :format},
  metadata: [:request_ip, :foo]
