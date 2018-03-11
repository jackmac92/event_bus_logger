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
    Logger.info(
      event_topic: event.topic,
      event_data: event.data,
      meta: event |> Map.take(:id, :occurred_at, :source)
    )
  end
end
