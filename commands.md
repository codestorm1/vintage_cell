
 {:status, pid, _, _} = :sys.get_status(ModemServer)
result = GenServer.call(pid, {:send_at_command, "AT+CPTONE=18\r\n"})
result = GenServer.call(pid, {:send_at_command, "ATE?\r\n"})

{:ok, pid} = GenStateMachine.start_link(NervesCell.CellStateMachine, {:on_hook, ""})
GenStateMachine.cast(pid, :go_off_hook)
GenStateMachine.cast(pid, {:digit_dialed, "9"})
GenStateMachine.cast(pid, :go_on_hook)
