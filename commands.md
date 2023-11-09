
 {:status, pid, _, _} = :sys.get_status(ModemServer)
result = GenServer.call(pid, {:send_at_command, "AT+CPTONE=18\r\n"})
result = GenServer.call(pid, {:send_at_command, "ATE?\r\n"})
