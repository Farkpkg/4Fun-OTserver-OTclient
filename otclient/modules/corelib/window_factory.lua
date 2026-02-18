WindowFactory = WindowFactory or {}

local factory = WindowFactory

factory.defaults = {
    class = 'MainWindow',
    parent = function() return g_ui.getRootWidget() end,
    background = '/images/ui/panel_flat',
    border = 3,
    padding = 6,
    contentId = 'contentPanel',
    width = 420,
    height = 320,
}

local function resolveParent(parent)
    if type(parent) == 'function' then
        return parent()
    end
    return parent
end

local function setPadding(widget, value)
    if widget and value ~= nil and widget.setPadding then
        widget:setPadding(value)
    end
end

function factory.createStandardWindow(config)
    config = config or {}
    local parent = resolveParent(config.parent or factory.defaults.parent)
    local class = config.class or factory.defaults.class

    local window = g_ui.createWidget(class, parent)
    if config.id then
        window:setId(config.id)
    end

    window:setSize(string.format('%d %d', config.width or factory.defaults.width, config.height or factory.defaults.height))

    if config.imageSource or factory.defaults.background then
        window:setImageSource(config.imageSource or factory.defaults.background)
    end

    if config.imageBorder ~= false then
        window:setImageBorder(config.imageBorder or factory.defaults.border)
    end

    setPadding(window, config.padding or factory.defaults.padding)

    if config.title and window.setText then
        window:setText(config.title)
    end

    local content = window:getChildById(config.contentId or factory.defaults.contentId)
    if not content and config.ensureContentPanel ~= false then
        content = g_ui.createWidget('Panel', window)
        content:setId(config.contentId or factory.defaults.contentId)
        content:addAnchor(AnchorTop, 'parent', AnchorTop)
        content:addAnchor(AnchorBottom, 'parent', AnchorBottom)
        content:addAnchor(AnchorLeft, 'parent', AnchorLeft)
        content:addAnchor(AnchorRight, 'parent', AnchorRight)
        setPadding(content, config.contentPadding or 0)
    end

    if config.closeButtonId then
        local closeButton = window:recursiveGetChildById(config.closeButtonId)
        if closeButton then
            closeButton.onClick = function()
                window:hide()
            end
        end
    end

    return window, content
end

local function readStyleClass(widget)
    local style = widget and widget.getStyle and widget:getStyle() or nil
    return style and style.__class or '<unknown>'
end

local function shouldAuditWidget(widget)
    if not widget or widget:isDestroyed() then
        return false
    end

    if widget.isMiniWindow or widget.isWindow then
        return true
    end

    local class = readStyleClass(widget)
    return class == 'UIMiniWindow' or class == 'UIWindow' or class == 'MainWindow' or class == 'PhantomMiniWindow'
end

local function isImagePathValid(path)
    if not path or path == '' then
        return true
    end

    if string.sub(path, 1, 1) ~= '/' then
        return true
    end

    local asPng = path
    if not string.find(path, '%.') then
        asPng = path .. '.png'
    end

    return g_resources.fileExists(asPng)
end

local function auditWindow(window, report)
    local id = window:getId() or '<no-id>'

    if window:getWidth() <= 0 or window:getHeight() <= 0 then
        table.insert(report, string.format('[WindowFactory.audit] %s invalid size: %dx%d', id, window:getWidth(), window:getHeight()))
    end

    local imageSource = window:getImageSource()
    if imageSource and imageSource ~= '' and not isImagePathValid(imageSource) then
        table.insert(report, string.format('[WindowFactory.audit] %s invalid image-source: %s', id, tostring(imageSource)))
    end

    local anchors = window:getAnchors()
    if not anchors or next(anchors) == nil then
        table.insert(report, string.format('[WindowFactory.audit] %s has no anchors configured', id))
    end

    if not window:getParent() then
        table.insert(report, string.format('[WindowFactory.audit] %s has no parent', id))
    end
end

local function walk(widget, fn)
    fn(widget)
    for _, child in ipairs(widget:getChildren()) do
        walk(child, fn)
    end
end

function auditWindowsVisualIntegrity()
    local root = g_ui.getRootWidget()
    local report = {}

    if not root then
        g_logger.error('[WindowFactory.audit] root widget is nil')
        return false, { 'root widget is nil' }
    end

    walk(root, function(widget)
        if shouldAuditWidget(widget) and widget:isVisible() then
            auditWindow(widget, report)
        end
    end)

    if #report > 0 then
        for _, message in ipairs(report) do
            g_logger.error(message)
        end
        return false, report
    end

    g_logger.info('[WindowFactory.audit] visual integrity check passed')
    return true, report
end
