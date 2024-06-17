NervesMOTD.print()

# Add Toolshed helpers to the IEx session
use Toolshed

reup = fn ->
  Application.stop(:nerves_cell)
  Application.ensure_started(:nerves_cell)
end

show = fn first, last, color ->
  for i <- first..last do
    Blinkchain.set_pixel(%Blinkchain.Point{x: i, y: 0}, color)
  end

  Blinkchain.render()
end
