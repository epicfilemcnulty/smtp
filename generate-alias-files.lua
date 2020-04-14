local base_dir = "/etc/chasquid/domains"
local aliases_file = os.getenv("MAIL_ALIASES_FILE") or "aliases.lua"
local aliases = dofile(aliases_file)

for domain, users in pairs(aliases) do
    os.execute("mkdir -p "..base_dir.."/"..domain)
    local file = io.open(base_dir.."/"..domain.."/aliases", "w+")
    for user, a in pairs(users) do
        for _, alias in ipairs(a) do
            file:write(alias..": "..user.."\n")
        end
    end
    file:close()
end

