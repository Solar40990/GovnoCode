local info = http.get("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/Info.txt")
if not info then return end
info = textutils.unserialise(info.readAll())

function installFile (file,folder)
    local newFile = http.get(("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/%s/%s.lua"):format(folder,file))
    
    if newFile then
        newFile = newFile.readAll()
        local currentFile = fs.open(file..".lua","w")
        currentFile.write(newFile)
        currentFile.close()
    end
end

local notUpdated = {}
local updated = {}

for i,name in pairs({...,"Loader"}) do
    local setting = name.."_version"

    local newVersion = info[name].version
    local currentVersion = settings.get(setting)

    if currentVersion ~= newVersion then
        settings.set(setting,newVersion)
        settings.save()
        for i,file in pairs(info[name].files) do
            installFile(file,name)
        end
        updated[i] = name
    else
        notUpdated[i] = name
    end
end

if #notUpdated > 0 then
    print(table.concat(notUpdated,", ").." are up to date!")
end

if #updated > 0 then
    print("Successfully updated: "..table.concat(updated,", "))
end

os.sleep(3)
