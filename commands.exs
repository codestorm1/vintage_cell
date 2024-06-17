{:status, pid, _, _} = :sys.get_status(FonaModem)
{:status, pid, _, _} = :sys.get_status(NervesCell.CellStateMachine)
{:status, pid, _, _} = :sys.get_status(NervesCell.KeypadDialer)
result = GenServer.call(pid, {:send_at_command, "AT+CPTONE=18\r\n"})
result = GenServer.call(pid, {:send_at_command, "ATE?\r\n"})

pid = Process.whereis(NervesCell.CellStateMachine)
NervesCell.CellStateMachine.go_off_hook()

color = Blinkchain.Color.parse("#2200FF")

show = fn first, last, color ->
  for i <- first..last do
    Blinkchain.set_pixel(%Blinkchain.Point{x: i, y: 0}, color)
  end

  Blinkchain.render()
end
