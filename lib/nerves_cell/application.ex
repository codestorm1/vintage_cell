defmodule NervesCell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesCell.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: NervesCell.Worker.start_link(arg)
        # {NervesCell.Worker, arg},
        # {NervesCell.KeypadDialer,
        #  %{
        #    row_pins: [17, 27, 23, 24],
        #    col_pins: [5, 6, 13, 26],
        #    input: "",
        #    matrix: nil,
        #    size: nil,
        #    last_message_at: 0
        #  }}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: NervesCell.Worker.start_link(arg)
      # {NervesCell.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: NervesCell.Worker.start_link(arg)
      # {NervesCell.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:nerves_cell, :target)
  end
end
