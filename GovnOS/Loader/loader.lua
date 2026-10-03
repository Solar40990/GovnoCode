local info = http.get("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/Info.txt")
info = textutils.unserialise(info.readAll())

function installFile (file,folder)
    print(file)
    local newFile = http.get(("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/%s/%s.lua"):format(folder,file))
    
    if newFile then
        newFile = newFile.readAll()
        local currentFile = fs.open(file..".lua","w")
        currentFile.write(newFile)
        currentFile.close()
    end
end

for _,name in pairs({...,"Loader"}) do
    local setting = name.."_version"

    local newVersion = info[name].version
    local currentVersion = settings.get(setting)

    if currentVersion ~= newVersion then
        settings.set(setting,newVersion)
        settings.save()
        for _,file in pairs(info[name].files) do
            installFile(file,name)
        end
    end
end