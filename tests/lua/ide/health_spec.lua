describe("ide.core.health", function()
  it("check_all returns a table of results", function()
    local health = require("ide.core.health")
    local results = health.check_all()
    assert.is_table(results)
    assert.is_true(#results > 0)
  end)

  it("each result has name and status fields", function()
    local health = require("ide.core.health")
    local results = health.check_all()
    for _, item in ipairs(results) do
      assert.is_string(item.name)
      assert.is_true(item.status == "ok" or item.status == "missing" or item.status == "warning" or item.status == "error")
    end
  end)
end)
