local M = {}

local function server_file(root_dir)
  return root_dir .. "/.remote-debug-servers"
end

local function detect_project_name(root_dir)
  local project_file = root_dir .. "/.project"

  if vim.fn.filereadable(project_file) == 1 then
    local content = table.concat(vim.fn.readfile(project_file), "\n")
    local name = content:match("<name>(.-)</name>")

    if name and name ~= "" then
      return name
    end
  end

  return vim.fn.fnamemodify(root_dir, ":p:h:t")
end

local function read_servers(root_dir)
  local path = server_file(root_dir)

  if vim.fn.filereadable(path) == 0 then
    return {}
  end

  local content = table.concat(vim.fn.readfile(path), "\n")

  if content == "" then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, content)

  if not ok or type(decoded) ~= "table" then
    vim.notify("Invalid .remote-debug-servers JSON", vim.log.levels.ERROR)
    return {}
  end

  return decoded
end

local function write_servers(root_dir, servers)
  local path = server_file(root_dir)
  local encoded = vim.json.encode(servers)

  -- Pretty-ish formatting for readability
  encoded = encoded
      :gsub("%[", "[\n  ")
      :gsub("%]", "\n]")
      :gsub("},{", "},\n  {")

  vim.fn.writefile(vim.split(encoded, "\n"), path)

  vim.notify("Saved remote debug servers to " .. path, vim.log.levels.INFO)
end

local function add_server(root_dir)
  local servers = read_servers(root_dir)

  vim.ui.input({ prompt = "Server name: " }, function(name)
    if not name or name == "" then
      return
    end

    vim.ui.input({ prompt = "Host: ", default = "127.0.0.1" }, function(host)
      if not host or host == "" then
        return
      end

      vim.ui.input({ prompt = "Port: ", default = "5005" }, function(port)
        port = tonumber(port)

        if not port then
          vim.notify("Invalid port", vim.log.levels.ERROR)
          return
        end

        local default_project_name = detect_project_name(root_dir)

        vim.ui.input({ prompt = "Project name: ", default = default_project_name }, function(project_name)
          if not project_name or project_name == "" then
            return
          end

          table.insert(servers, {
            name = name,
            host = host,
            port = port,
            projectName = project_name,
          })

          write_servers(root_dir, servers)
        end)

        write_servers(root_dir, servers)
      end)
    end)
  end)
end

local function attach_server(root_dir)
  local dap = require("dap")
  local servers = read_servers(root_dir)

  if #servers == 0 then
    vim.notify("No remote debug servers found. Add one first.", vim.log.levels.WARN)
    add_server(root_dir)
    return
  end

  vim.ui.select(servers, {
    prompt = "Attach to remote Java server:",
    format_item = function(server)
      return server.name .. " - " .. server.host .. ":" .. server.port
    end,
  }, function(server)
    if not server then
      return
    end

    dap.run({
      type = "java",
      request = "attach",
      name = "Remote: " .. server.name,
      hostName = server.host,
      port = server.port,
      projectName = server.projectName or detect_project_name(root_dir),
    })
  end)
end

local function delete_server(root_dir)
  local servers = read_servers(root_dir)

  if #servers == 0 then
    vim.notify("No remote debug servers to delete", vim.log.levels.WARN)
    return
  end

  vim.ui.select(servers, {
    prompt = "Delete remote debug server:",
    format_item = function(server)
      return server.name .. " - " .. server.host .. ":" .. server.port
    end,
  }, function(server)
    if not server then
      return
    end

    for index, existing in ipairs(servers) do
      if existing == server then
        table.remove(servers, index)
        break
      end
    end

    write_servers(root_dir, servers)
  end)
end

local function edit_file(root_dir)
  vim.cmd("edit " .. vim.fn.fnameescape(server_file(root_dir)))
end

function M.menu(root_dir)
  vim.ui.select({
    "Attach to server",
    "Add server",
    "Delete server",
    "Edit .remote-debug-servers file",
  }, {
    prompt = "Java Remote Debug:",
  }, function(choice)
    if choice == "Attach to server" then
      attach_server(root_dir)
    elseif choice == "Add server" then
      add_server(root_dir)
    elseif choice == "Delete server" then
      delete_server(root_dir)
    elseif choice == "Edit .remote-debug-servers file" then
      edit_file(root_dir)
    end
  end)
end

function M.attach(root_dir)
  attach_server(root_dir)
end

function M.add(root_dir)
  add_server(root_dir)
end

function M.edit(root_dir)
  edit_file(root_dir)
end

return M
