-- @docclass
UIButton = extends(UIWidget, "UIButton")

function UIButton.create()
  local button = UIButton.internalCreate()
  button:setFocusable(false)
  button:setClickSound(2774)
  return button
end

function UIButton:onMouseRelease(pos, button)
  return self:isPressed()
end
