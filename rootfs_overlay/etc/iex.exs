NervesMOTD.print()

# Add Toolshed helpers to the IEx session
use Toolshed

reup = fn ->
  Application.stop(:nerves_cell)
  Application.ensure_started(:nerves_cell)
end
