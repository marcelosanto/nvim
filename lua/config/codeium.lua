local module = {}
local cmp = require("cmp")

function module.is_enabled()
  local config = cmp.get_config()
  for i, source in ipairs(config.sources) do
    if source.name == "codeium" then
      return i
    end
  end
  return nil
end

function module.enable()
  local config = cmp.get_config()
  local enabled = module.is_enabled()
  if enabled == nil then
    table.insert(config.sources, 1, {
      name = "codeium",
      group_index = 1,
      priority = 100,
    })
    cmp.setup(config)
  end
end

function module.disable()
  local config = cmp.get_config()
  local index = module.is_enabled()
  if index ~= nil then
    table.remove(config.sources, index)
    cmp.setup(config)
  end
end

return module
