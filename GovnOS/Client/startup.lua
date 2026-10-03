if not fs.exists("loader.lua") then
    local code = http.get("https://raw.githubusercontent.com/Solar40990/GovnoCode/refs/heads/main/GovnOS/Loader/loader.lua")

    if code then
        code = code.readAll()

        local file = fs.open("loader.lua","w")
        file.write(code)
        file.close()
    else
        error("Something went wrong!")
    end
end

shell.run("loader.lua","Client")

shell.run("system.lua")