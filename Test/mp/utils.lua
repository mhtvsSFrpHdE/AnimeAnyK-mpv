local utils = {}

function utils.get_path_splitter()
    local osEnv = os.getenv("OS")

    -- Windows 10
    if osEnv == "Windows_NT"
    then
        return "\\"
    -- All other OS goes here
    else
        return "/"
    end
end

-- https://stackoverflow.com/questions/27819086/how-do-you-find-the-last-occurence-of-a-pattern-using-string-find
-- https://www.lua.org/pil/20.1.html
-- https://www.lua.org/pil/20.2.html
function utils.split_path(path)
    local pathSplitter = utils.get_path_splitter()

    -- ".": pattern start with any characters
    -- "*": pattern start part occurs 0 times also ok
    -- "\\": pattern ends with symbol "\""
    --
    -- Example:
    --     find ".*\" from "C:\" -> true, founded: "C:\"
    --     find ".*\" from "\" -> also true, founded: "\"
    local findPattern = ".*" .. pathSplitter

    local lastSplitterStartIndex, lastSplitterEndIndex = path:find(findPattern)
    local pathLength = string.len(path)

    local parentFolder = string.sub(path, lastSplitterStartIndex, lastSplitterEndIndex - 1)
    local fileName = string.sub(path, lastSplitterEndIndex + 1, pathLength)

    return parentFolder, fileName
end

function utils.join_path(parentFolder, file)
    local pathSplitter = utils.get_path_splitter()

    return parentFolder .. pathSplitter .. file
end

function utils.file_info(ignore1)
    return Test.IndicatorFileExist
end

return utils