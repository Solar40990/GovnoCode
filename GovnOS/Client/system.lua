local modem = peripheral.find("modem")
modem.open(0)

local pattern = "--------------------------"

local currentMenu = "loading"

settings.load()
settings.define("24HourFormat",{default = true,type = "boolean"})
settings.define("mute",{default = false,type = "boolean"})
settings.define("skipLoader",{default = false,type = "boolean"})

function drawClock ()
    local x,y = term.getCursorPos()
    local time = textutils.formatTime(os.time("local"),settings.get("24HourFormat"))
    term.setCursorPos(20,1)
    term.write(("%7s"):format(time))
    term.setCursorPos(x,y)
end

function detectClicks (buttonTemplate)
    while true do
        local _,_,_,y = os.pullEvent("mouse_click")
        if buttonTemplate[y] then
            if not settings.get("mute") then
                modem.transmit(6,0,{type = "playSound",info = {sound = "ui.button.click",volume = 0.25}})
            end
            if buttonTemplate[y]() then break end
        end
    end
end
local menuTemplates = {
menu = [[GovnOS 1.0
--------------------------
Options
Soundpad

About
]],
options = [[Settings
--------------------------
24HourFormat = %s
Mute = %s

SkipLoader = %s
]],
soundpad = [[Soundpad
--------------------------
%s
]],
about = [[About GovnOS
--------------------------
Version: 1.0 Unstable

Powered by:
HuesOS Technologies

Made with:
Child labor
]],
loading = [[Loading
--------------------------
]]
}

local buttonTemplates = {
    menu = {
        [3] = function ()
            currentMenu = "options"
            return true
        end,
        [4] = function ()
            currentMenu = "soundpad"
            return true
        end,
        [6] = function ()
            currentMenu = "about"
            return true
        end
    },
    options = {
        [3] = function ()
            local value = not settings.get("24HourFormat")
            settings.set("24HourFormat",value)
            term.setCursorPos(16,3)
            term.write(("%-5s"):format(value))
            drawClock()
        end,
        [4] = function ()
            local value = not settings.get("mute")
            settings.set("mute",value)
            term.setCursorPos(8,4)
            term.write(("%-5s"):format(value))
        end,
        [6] = function ()
            local value = not settings.get("skipLoader")
            settings.set("skipLoader",value)
            term.setCursorPos(14,6)
            term.write(("%-5s"):format(value))
        end,
        [19] = function ()
            currentMenu = "menu"
            settings.save()
            return true
        end
    },
    soundpad = {
        [17] = function ()
            modem.transmit(6,0,{type = "stopAudio",info = {}})
        end,
        [19] = function ()
            currentMenu = "menu"
            return true
        end
    },
    about = {
        [19] = function ()
            currentMenu = "menu"
            return true
        end
    }
}

local menus = {
    menu = function ()
        print(menuTemplates.menu)

        term.setCursorPos(1,20)
        term.write(pattern)

        detectClicks(buttonTemplates.menu)
    end,
    options = function ()     
        print((menuTemplates.options):format(settings.get("24HourFormat"),settings.get("mute"),settings.get("skipLoader")))
        
        term.setCursorPos(1,19)
        print("Save & exit")
        term.write(pattern)

        detectClicks(buttonTemplates.options)
    end,
    soundpad = function ()
        print(menuTemplates.soundpad)

        term.setCursorPos(1,17)
        term.write("Stop")

        term.setCursorPos(1,19)
        print("Exit")
        term.write(pattern)

        detectClicks(buttonTemplates.soundpad)
    end,
    about = function ()
        print(menuTemplates.about)
        
        term.setCursorPos(1,19)
        print("Exit")
        term.write(pattern)

        detectClicks(buttonTemplates.about)
    end,
    loading = function ()
        print(menuTemplates.loading)
        
        term.setCursorPos(1,20)
        term.write(pattern)

        term.setCursorPos(1,3)

        local audioList

        parallel.waitForAny(
            function ()
                local index = 0
                while true do
                    modem.transmit(6,0,{type = "getAudio",info = {replyChannel = 0}})
                    index = index+1
                    if index > 3 then index = 0 end
                    term.setCursorPos(8,1)
                    term.write(("%-3s"):format(string.rep(".",index)))
                    os.sleep(1)
                end 
            end,
            function ()
                while true do
                    local _,_,channel,_,message = os.pullEvent("modem_message")
                    if channel == 0 and message.audioList then
                        audioList = message.audioList
                        break
                    end
                end
            end
        )

        for i,audio in pairs(audioList) do
            buttonTemplates.soundpad[2+i] = function ()
                modem.transmit(6,0,{type = "playAudio",info = {audio = ("music/%s.dfpwm"):format(audio)}})
            end
            audioList[i] = ("%d. %s"):format(i,audio)
        end
        menuTemplates.soundpad = menuTemplates.soundpad:format(table.concat(audioList,"\n"))

        currentMenu = "menu"
    end
}

parallel.waitForAll(
    function ()
        while true do
            os.sleep(60 - os.date("*t").sec)
            drawClock()
        end
    end,
    function ()
        while true do
            term.clear()
            term.setCursorPos(1,1)
            drawClock()
            menus[currentMenu]()
        end
    end
)