local args = {...}

if args[1] == nil then error("No file given", 0) end
if args[2] ~= nil then error("Too many files given", 0) end

local path = require "cc.strings".split(args[1], "[/]")


local title = path[#path]

-- this one cuts out the extension too! file names are still lowercase & full of underscores though so it looks weird
-- local title = require "cc.strings".split(path[#path], "[.]")[1]

local screen_x,screen_y = term.getSize()

-- this should open using a command arg (no file selection menu just yet)
local file = fs.open(args[1], "r")
local content = file.readAll()
file.close()

local content_lines = require "cc.strings".wrap(content)

-- split the file into screen-sized pages
local counter = 0
local holding_table = {}
local pages = {}
for i = 1, #content_lines do
    if counter == screen_y - 2 then -- if limit of screen reached, minus two to account for the title & page count
        table.insert(pages, holding_table)
        holding_table = {}
        counter = 0
    end
    table.insert(holding_table, content_lines[i])
    counter = counter + 1
end

if holding_table[1] ~= nil then
    table.insert(pages, holding_table)
end

local currentPage = 1

local function render()
    term.clear()

    term.setCursorPos(tonumber(screen_x) / 2 - string.len(title) / 2 + 1, 1) -- half the screen size, then half the length of the title plus one to center it
    term.write(title)

    term.setCursorPos(1, 2)

    for i = 1, #pages[currentPage] do
        print(pages[currentPage][i])
    end

    if term.isColor() then
        if currentPage ~= 1 then
            term.setCursorPos(2, screen_y)
            term.write("<")
        end
        
        if currentPage ~= #pages then
            term.setCursorPos(screen_x - 1, screen_y)
            term.write(">")
        end
    end

    local pageDisplay = tostring("Page "..currentPage.."/"..#pages)
    term.setCursorPos(tonumber(screen_x) / 2 - (string.len(pageDisplay) / 2)+1, screen_y)
    term.write(pageDisplay)
end

render()

while true do
    local e = {os.pullEvent()}
    if e[1] == "key" then -- [2] is the key that was pressed
        if e[2] == keys.right and currentPage ~= #pages then
            currentPage = currentPage + 1
            render()
        elseif e[2] == keys.left and currentPage ~= 1 then
            currentPage = currentPage - 1
            render()
        end
    elseif e[1] == "mouse_click" then -- [3] is x, [4] is y
        if e[3] == 2 and e[4] == screen_y and currentPage ~= 1 then
            currentPage = currentPage - 1
            render()
        end

        if e[3] == screen_x - 1 and e[4] == screen_y and currentPage ~= #pages then
            currentPage = currentPage + 1
            render()
        end
    end

    os.sleep(0.1)
end