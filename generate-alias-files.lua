local base_dir = "/etc/chasquid/domains"
local alias_file = os.getenv("MAIL_ALIAS_FILE") or "aliases.lua"
local aliases = dofile(alias_file)

for domain, users in pairs(aliases) do
    os.execute("mkdir -p "..base_dir.."/"..domain)
    local file = io.open(base_dir.."/"..domain.."/aliases", "w+")
    for user, info in pairs(users) do
        for _, alias in ipairs(info.aliases) do
            file:write(alias..": "..user.."\n")
        end
    end
    file:close()
end

