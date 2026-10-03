local mode = ...

local info = http.get("https://github.com/Solar40990/GovnoCode/blob/main/GovnOS/Info")
info = textutils.unserialise(info)

for i,file in pairs(info[mode].files) do
    local newFile = http.get("https://github.com/Solar40990/GovnoCode/blob/main/GovnOS/"..mode..file)
    if newFile then
        local currentFile = fs.open(file,"w")
        currentFile.write(newFile)
        currentFile.close()
    end
end