local function readFileContents(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil
    end
    local contents = file:read("*a")
    file:close()
    return contents
end

local function parseASCIIList(list)
    local lines = {}

    for line in list:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local asciiData = {}

    for i = 2, #lines do
        local decimal, hex, octal, char, description = lines[i]:match("(%d+)%s+(%x+)%s+(%d+)%s+(%S+)%s+(.+)")
        if decimal and hex and octal and char and description then
            table.insert(asciiData, {
                decimal = tonumber(decimal),
                hex = hex,
                octal = tonumber(octal),
                char = char,
                description = description
            })
        end
    end

    return asciiData
end

local function splitListIntoParts(list, numParts)
    local totalEntries = #list
    local entriesPerPart = math.floor(totalEntries / numParts)
    local remainingEntries = totalEntries % numParts

    local parts = {}
    local currentIndex = 1

    for i = 1, numParts do
        local partSize = entriesPerPart
        if i <= remainingEntries then
            partSize = partSize + 1
        end

        local part = {}
        for j = 1, partSize do
            part[j] = list[currentIndex]
            currentIndex = currentIndex + 1
        end

        parts[i] = part
    end

    return parts
end

function generateHtmlFile(inputPath, outputPath, tables)
    local inputFile = io.open(inputPath, "r")
    if not inputFile then
        print("Failed to open input file")
        return
    end

    local content = inputFile:read("*all")
    inputFile:close()

    for key, value in pairs(tables) do
        local targetString = string.format("_%s_", key)
        local replacementString = value
        content = string.gsub(content, targetString, replacementString)
    end

    local outputFile = io.open(outputPath, "w")
    if not outputFile then
        print("Failed to open output file")
        return
    end

    outputFile:write(content)
    outputFile:close()
end

function generateAsciiTables()
    local asciiList = readFileContents("ascii.txt")
    local asciiData = parseASCIIList(asciiList)
    local asciiParts = splitListIntoParts(asciiData, 4)

    html = ""
    for i, part in ipairs(asciiParts) do
        local partHtml = "<table><tr><th>Dec</th><th>Hex</th><th>Oct</th><th>Char</th><th>Description</th></tr>"
        for j, data in ipairs(part) do
            partHtml = partHtml ..
                string.format("<tr><td>%3d</td><td>%2s</td><td>%3d</td><td>%s</td><td>%s</td></tr>", data.decimal,
                    data.hex,
                    data.octal, data.char, data.description)
        end
        partHtml = partHtml .. "</table>"

        html = html .. partHtml
    end

    return html
end

function generateExtendedAsciiTables()
    local asciiList = readFileContents("extended-ascii.txt")
    local asciiData = parseASCIIList(asciiList)
    local asciiParts = splitListIntoParts(asciiData, 4)

    html = ""
    for i, part in ipairs(asciiParts) do
        local partHtml = "<table><tr><th>Dec</th><th>Hex</th><th>Oct</th><th>Char</th><th>Description</th></tr>"
        for j, data in ipairs(part) do
            partHtml = partHtml ..
                string.format("<tr><td>%3d</td><td>%2s</td><td>%3d</td><td>%s</td><td>%s</td></tr>", data.decimal,
                    data.hex,
                    data.octal, data.char, data.description)
        end
        partHtml = partHtml .. "</table>"

        html = html .. partHtml
    end

    return html
end

local tables = {
    ASCII = generateAsciiTables(),
    EXTENDEDASCII = generateExtendedAsciiTables()
}

generateHtmlFile("template.html", "index.html", tables)
