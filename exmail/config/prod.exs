use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
domain = System.get_env("EXMAIL_DOMAIN") || "${EXMAIL_DOMAIN}"

config :exmail, Exmail.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: domain, port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  server: true,
  version: Mix.Project.config[:version]

# Do not print debug messages in production
config :logger,
  level: :warn,
  truncate: 8192000,  # for debug
  backends: [
    {ExSyslog, :exsyslog_error},
    {ExSyslog, :exsyslog_debug},
    {ExSyslog, :exsyslog_json},
    {LoggerFileBackend, :debug_logger}
  ]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :exmail, Exmail.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :exmail, Exmail.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :exmail, Exmail.Endpoint, server: true
#
config :exmail, Exmail.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "${SECRET_KEY_BASE}"

# Configure your database
config :exmail, Exmail.Repo,
  adapter: Ecto.Adapters.MySQL,
  hostname: System.get_env("DBHOST") || "${DBHOST}",
  database: System.get_env("DBNAME") || "${DBNAME}",
  username: System.get_env("DBUSER") || "${DBUSER}",
  password: System.get_env("DBPASS") || "${DBPASS}",
  pool_size: 30

config :exmail, Exmail.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "email-smtp.us-east-1.amazonaws.com",
  port: 587,
  username: System.get_env("SESUSER") || "${SESUSER}",
  password: System.get_env("SESPASS") || "${SESPASS}",
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :ueberauth, Ueberauth,
  providers: [
      # google: {Ueberauth.Strategy.Google, []},
      # facebook: {Ueberauth.Strategy.Facebook, [profile_fields: "email, name"]},
      github: {Ueberauth.Strategy.Github, [uid_field: "login"]},
      identity: {Ueberauth.Strategy.Identity, [callback_methods: ["POST"]]},
  ]

config :sentry,
  dsn: System.get_env("SENTRY_ENDPOINT") || "${SENTRY_ENDPOINT}",
  use_error_logger: true,
  environment_name: Mix.env,
  # enable_source_code_context: true, root_source_code_path: File.cwd!,
  included_environments: [:prod],
  hackney_opts: [pool: :sentry],
  tags: %{
    env: "production",
    system: "exmail",
  }

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID") || "${GITHUB_CLIENT_ID}",
  client_secret: System.get_env("GITHUB_CLIENT_SECRET") || "${GITHUB_CLIENT_SECRET}"

config :arc,
  storage: Arc.Storage.S3,
  bucket: System.get_env("EXMAIL_BUCKET") || "${EXMAIL_BUCKET}",
  asset_host: "http://#{domain}/edge"

config :exmail, :redis,
  track: {:system, "REDIS_TRACK_URI"}

# config :ua_inspector,
  # database_path: {:system, "UAINSPECTOR_DBPATH"}

config :exq,
  name: Exq,
  host: System.get_env("REDIS_URI") || "${REDIS_URI}",
  port: 6379,
  database: 10,
  queues: [{"default", :infinite}, {"sequence", 1}],
  scheduler_enable: true,
  max_retries: 25,
  reconnect_on_sleep: 1000  # milliseconds
  # concurrency: 100,
  # poll_timeout: 100,
  # redis_timeout: 5000,
  # genserver_timeout: 5000,
  # scheduler_poll_timeout: 200,
  # shutdown_timeout: 5000

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"