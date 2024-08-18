defmodule NervesCell.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @bell_gpio Application.compile_env(:nerves_cell, :bell_ringer_pin)
  @hook_gpio Application.compile_env(:nerves_cell, :hook_gpio_pin)
  @dial_gpio Application.compile_env(:nerves_cell, :dial_gpio_pin)

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
        {NervesCell.BellServer, @bell_gpio},
        {NervesCell.CellStateMachine, {:on_hook, ""}},
        {NervesCell.RotaryDialServer, {self(), @dial_gpio}},
        {NervesCell.PhoneHookServer, {self(), @hook_gpio}},
        {NervesCell.LEDServer, nil}
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
