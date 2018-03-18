defmodule EventBus.Logger.Application do
  @moduledoc """
  The EventBus.Logger Application Service.
  """
  use Application
  alias EventBus.Logger.Config
  alias EventBus.Logger.Supervisor.Console, as: ConsoleSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.add_backend {LoggerLogstashBackend, :debug}
    logger_host = Application.get_env(:event_bus_logger, :logstash_host)
    if ! logger_host do
      raise "Couldn't get logger_host from config"
    end
    logger_port = Application.get_env(:event_bus_logger, :logstash_port, 10001)
    Logger.configure_backend {LoggerLogstashBackend, :debug},
      host: logger_host,
      port: logger_port,
      level: :debug,
      metadata: Application.get_env(:event_bus_logger, :additional_params, []),
      type: 'event_bus_logger'

    link =
      Supervisor.start_link([
        supervisor(ConsoleSupervisor, [], id: make_ref(), restart: :permanent),
      ], strategy: :one_for_one, name: EventBus.Logger.Supervisor)

    if Config.enabled?() do
      EventBus.subscribe({EventBus.Logger, Config.topics()})
    end

    link
  end
end
