print("Connecting to github.\n")

local info = http.get("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/Info.txt")
if not info then error("Failed to get info!") end
info = textutils.unserialise(info.readAll())

function installFile (file,folder)
    local newFile = http.get(("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/%s/%s.lua"):format(folder,file))

    if not newFile then return end
    newFile = newFile.readAll()
    
    local currentFile = fs.open(file..".lua","w")
    currentFile.write(newFile)
    currentFile.close()
end

local notUpdated = {}
local updated = {}

for i,folder in pairs({...,"Loader"}) do
    local setting = folder.."_version"

    local newVersion = info[folder].version
    local currentVersion = settings.get(setting)

    if currentVersion == newVersion then
        settings.set(setting,newVersion)
        settings.save()

        for _,file in pairs(info[folder].files) do
            --installFile(file,folder)
        end

        updated[i] = folder
    else
        notUpdated[i] = folder
    end
end

if #notUpdated > 0 then
    print(table.concat(notUpdated,", ").." are up to date!".."\n")
end

if #updated > 0 then
    print("Successfully updated: "..table.concat(updated,", ").."\n")
end

os.sleep(3)
