{:status, pid, _, _} = :sys.get_status(FonaModem)
{:status, pid, _, _} = :sys.get_status(NervesCell.CellStateMachine)
{:status, pid, _, _} = :sys.get_status(NervesCell.KeypadDialer)
result = GenServer.call(pid, {:send_at_command, "AT+CPTONE=18\r\n"})
result = GenServer.call(pid, {:send_at_command, "ATE?\r\n"})

pid = Process.whereis(NervesCell.CellStateMachine)
NervesCell.CellStateMachine.go_off_hook
