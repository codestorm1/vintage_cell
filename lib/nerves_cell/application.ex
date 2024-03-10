defmodule NervesCell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @hook_gpio 25
  @dialer_gpio 23

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
        {WaveshareModem, %{}},
        {NervesCell.CellStateMachine, {:on_hook, ""}},
        {NervesCell.RotaryDialServer, {self(), @dialer_gpio}},
        {NervesCell.PhoneHookServer, {self(), @hook_gpio}}
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
