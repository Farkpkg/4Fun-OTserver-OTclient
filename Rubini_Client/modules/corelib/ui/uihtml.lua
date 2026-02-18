-- @docclass
UIHtml = extends(UIWidget, "UIHtml")

function UIHtml.create()
  local label = UIHtml.internalCreate()
  label:setPhantom(true)
  label:setFocusable(false)
  label:setTextAlign(AlignLeft)
  return label
end
