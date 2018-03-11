defmodule EventBus.Logger.Worker.Console do
  @moduledoc """
  Worker for EventBucket
  """

  use GenServer
  require Logger
  alias EventBus.Logger.Config

  ## Public api

  @doc """
  Process event
  """
  def process({_topic, _id} = event_shadow) do
    GenServer.cast(__MODULE__, event_shadow)
    :ok
  end

  ## Callbacks

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc false
  def init(_opts), do: {:ok, nil}

  @doc false
  def handle_cast({topic, id}, state) do
    event = EventBus.fetch_event({topic, id})
    log(event)
    EventBus.mark_as_completed({EventBus.Logger, topic, id})
    {:noreply, state}
  end

  defp log(event) do
    getv = fn k -> event |> Map.get(k) |> inspect end

    Logger.info(
      "[EVENT_BUS]",
      evbus_topic: "#{event.topic}",
      evbus_data: inspect(event.data),
      evbus_id: getv.(:id),
      evbus_source: getv.(:source),
      evbus_occured_at: getv.(:occured_at)
    )
  end
end
