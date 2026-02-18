local clientUiDebug
local clientUiDebugLabel
local clientUiDebugHighlightWidget
local clientUiDebugActivateButton
local clientUiDrawActivateButton
local enabled = true
local enabledDraw = true

function onClientUiDebuggerMouseMove(mouseBindWidget, mousePos, mouseMove)
    if not DEVELOPERMODE then
        return
    end

    local widgets = rootWidget:recursiveGetChildrenByPos(mousePos)

    local smallestWidget
    for _, widget in pairs(widgets) do
        if (widget:getId() ~= 'highlightWidget' and widget:getId() ~= 'toolTip') then
            if (not smallestWidget or
                    (widget:getSize().width <= smallestWidget:getSize().width and widget:getSize().height <= smallestWidget:getSize().height)
            ) then
                smallestWidget = widget
            end
        end
    end
    if smallestWidget then
        clientUiDebugHighlightWidget:setPosition(smallestWidget:getPosition())
        clientUiDebugHighlightWidget:setSize(smallestWidget:getSize())
        clientUiDebugHighlightWidget:raise()
    end

    local widgetNames = {}
    for wi = #widgets, 1, -1 do
        local widget = widgets[wi]
        if (widget:getId() ~= 'highlightWidget') then
            table.insert(widgetNames, widget:getClassName() .. '#' .. widget:getId() .. (widget.instance and ' (' .. widget.instance .. ')' or ''))
        end
    end
    clientUiDebugLabel:setText(table.concat(widgetNames, " -> "))
end

function activate()
  enabled = not enabled
  if enabled then
    clientUiDebugLabel:setVisible(true)
    clientUiDebug:setPhantom(false)
    clientUiDebugActivateButton:setColor('#FF0000')
    connect(rootWidget, {
        onMouseMove = onClientUiDebuggerMouseMove,
    })
  else
    clientUiDebugLabel:setVisible(false)
    clientUiDebug:setPhantom(true)
    clientUiDebugActivateButton:setColor('#00FF00')
    clientUiDebugHighlightWidget:setSize({0, 0})
    --clientUiDebugLabel:setText("")
    disconnect(rootWidget, {
        onMouseMove = onClientUiDebuggerMouseMove,
    })
  end
end

function activateDraw()
  enabledDraw = not enabledDraw
  if enabledDraw then
    clientUiDrawActivateButton:setColor('#FF0000')
  else
    clientUiDrawActivateButton:setColor('#00FF00')
  end
  g_ui.setDebugBoxesDrawing(not g_ui.isDrawingDebugBoxes())
end

function init()
    connect(rootWidget, {
        onMouseMove = onClientUiDebuggerMouseMove,
    })
    if not DEVELOPERMODE then
        return
    end
    clientUiDebug = g_ui.displayUI('client_ui_debug')
    clientUiDebugLabel = clientUiDebug:getChildById('clientUiDebugLabel')
    clientUiDebugHighlightWidget = g_ui.createWidget('HighlightWidget', rootWidget)
    clientUiDebugActivateButton = clientUiDebug:getChildById('activateButton')
    clientUiDrawActivateButton = clientUiDebug:getChildById('activateDrawButton')
    activate()
end

function terminate()
    disconnect(rootWidget, {
        onMouseMove = onClientUiDebuggerMouseMove,
    })
    if not DEVELOPERMODE then
        return
    end
    clientUiDebug:destroy()
    clientUiDebugHighlightWidget:destroy()
end

function toggleVisible()
    if not g_app.isDevMode() then
        clientUiDebug:setVisible(false)
    else
        clientUiDebug:setVisible(true)
    end
end