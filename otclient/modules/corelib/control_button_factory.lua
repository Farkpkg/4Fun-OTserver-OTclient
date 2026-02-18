ControlButtonFactory = ControlButtonFactory or {}

local factory = ControlButtonFactory
factory.registry = factory.registry or {}

local DEFAULTS = {
    ['MainToggleButton'] = {
        size = '20 20',
        imageClip = '0 0 20 20',
        expectedParentIds = { options = true },
        optionsCategory = 'options'
    },
    ['largeToggleButton'] = {
        size = '108 20',
        imageClip = '0 0 108 20',
        expectedParentIds = { store = true },
        optionsCategory = 'store'
    }
}

local function normalizeSize(size)
    if type(size) == 'string' then
        return size
    end
    if type(size) == 'table' then
        return string.format('%s %s', size.width or size[1], size.height or size[2])
    end
    return nil
end

local function normalizeImageClip(clip)
    if type(clip) == 'string' then
        return clip
    end

    if type(clip) == 'table' then
        local x = clip.x or clip[1]
        local y = clip.y or clip[2]
        local width = clip.width or clip[3]
        local height = clip.height or clip[4]
        if x ~= nil and y ~= nil and width ~= nil and height ~= nil then
            return string.format('%d %d %d %d', x, y, width, height)
        end
    end

    return nil
end

local function ensureCallback(config)
    if type(config.callback) == 'function' then
        return config.callback
    end
    return function() end
end

function factory.registerButton(button, metadata)
    if not button or button:isDestroyed() then
        return
    end

    factory.registry[button:getId()] = {
        widgetClass = metadata.widgetClass,
        parentId = metadata.parentId,
        optionsCategory = metadata.optionsCategory,
        image = metadata.image,
        tooltip = metadata.description,
        index = metadata.index,
        createdAt = os.time()
    }
end

function factory.validateControlButton(button, metadata)
    if not button then
        g_logger.error('[ControlButtonFactory] validateControlButton: nil button')
        return false
    end

    metadata = metadata or factory.registry[button:getId()] or {}
    local widgetClass = metadata.widgetClass or 'MainToggleButton'
    local defaults = DEFAULTS[widgetClass] or DEFAULTS['MainToggleButton']
    local errors = {}

    local parent = button:getParent()
    local parentId = parent and parent:getId() or nil
    if defaults.expectedParentIds and not defaults.expectedParentIds[parentId] then
        table.insert(errors, string.format('invalid parent "%s"', tostring(parentId)))
    end

    local expectedSize = metadata.size or defaults.size
    local actualSize = string.format('%d %d', button:getWidth(), button:getHeight())
    if expectedSize and actualSize ~= expectedSize then
        table.insert(errors, string.format('invalid size "%s" expected "%s"', actualSize, expectedSize))
    end

    local expectedImageClip = normalizeImageClip(metadata.imageClip or defaults.imageClip)
    local currentClip = normalizeImageClip(button:getImageClip())
    if expectedImageClip and currentClip and currentClip ~= expectedImageClip then
        table.insert(errors, string.format('invalid image clip "%s" expected "%s"', tostring(currentClip), tostring(expectedImageClip)))
    end

    local reg = factory.registry[button:getId()]
    if not reg then
        table.insert(errors, 'button is not registered in ControlButtonFactory.registry')
    end

    if metadata.requireOptionsRegistration and (not metadata.optionsState or not metadata.optionsState[button:getId()]) then
        table.insert(errors, 'button not integrated with control_buttons options registry')
    end

    if #errors > 0 then
        g_logger.error(string.format('[ControlButtonFactory] %s failed validation: %s', button:getId() or '<no-id>', table.concat(errors, '; ')))
        return false, errors
    end

    return true
end

function validateControlButton(button)
    return factory.validateControlButton(button)
end

function factory.create(config)
    local parent = config.parent
    if not parent then
        error('[ControlButtonFactory] missing required "parent"')
    end

    local id = config.id
    if not id then
        error('[ControlButtonFactory] missing required "id"')
    end

    local widgetClass = config.widgetClass or 'MainToggleButton'
    local defaults = DEFAULTS[widgetClass] or DEFAULTS['MainToggleButton']

    local button = parent:getChildById(id)
    if not button then
        button = g_ui.createWidget(widgetClass)
        if config.front then
            parent:insertChild(1, button)
        else
            parent:addChild(button)
        end
    end

    button:setId(id)
    button:setTooltip(config.description or id)
    button:setSize(normalizeSize(config.size) or defaults.size)

    if config.image then
        button:setImageSource(config.image)
    end

    button:setImageClip(config.imageClip or defaults.imageClip)
    if type(config.imageBorder) == 'number' then
        button:setImageBorder(config.imageBorder)
    end

    local callback = ensureCallback(config)
    button.onMouseRelease = function(widget, mousePos, mouseButton)
        if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton then
            callback(widget)
            return true
        end
    end

    if not button.index and type(config.index) == 'number' then
        button.index = config.index
    end

    local metadata = {
        widgetClass = widgetClass,
        parentId = parent:getId(),
        optionsCategory = config.optionsCategory or defaults.optionsCategory,
        image = config.image,
        description = config.description,
        index = button.index,
        size = normalizeSize(config.size) or defaults.size,
        imageClip = normalizeImageClip(config.imageClip or defaults.imageClip),
        requireOptionsRegistration = config.requireOptionsRegistration,
        optionsState = config.optionsState
    }

    factory.registerButton(button, metadata)

    if type(config.registerInOptions) == 'function' then
        config.registerInOptions(button, metadata)
    end

    factory.validateControlButton(button, metadata)
    return button
end
