local widget = nil
function init()
    widget = g_ui.displayUI('teste')
    widget.label:setColorText("Olá [color=red]mundo[/color] [color='blue']azul[/color]!")

end

function terminate()

end
