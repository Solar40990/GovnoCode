term.setCursorPos(1,1)
term.write("--------------------------")
term.setCursorPos(1,20)
term.write("--------------------------")
term.setCursorPos(1,2)

if not http.get("http://google.com") then
    if not fs.exists("system.lua") then
        error("Check your internet connection!")
    end
    shell.run("system.lua")
else
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

    local success = shell.run("loader.lua","Client")

    if success then shell.run("system.lua") end
end