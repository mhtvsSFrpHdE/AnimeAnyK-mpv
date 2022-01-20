-- Tested on Anime4K version v4.0 and mpv-x86_64-20211219-git-fd63bf3
--
-- Automatically turn on Anime4K depending on video resolution
-- 2160P: Ignore, or send user command
-- 1080P ~ under 2160P: Mode A
-- 720P ~ under 1080P: Mode B
-- Under 720P: Mode C

-- Use namespace "_jbgyampcwu" to avoid possible conflicts
-- Rely on mp.utils functions, they may be removed in future mpv versions
--
-- Class reference: https://www.lua.org/pil/16.1.html



-- Define Class: PlatformInformation
-- Determine OS type and provide corresponding variable value
PlatformInformation = {
    -- https://mpv.io/manual/stable/#string-list-and-path-list-options
    PathListSeparator = nil
}
function PlatformInformation:new (o, pathListSeparator)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    local osEnv = os.getenv("OS")
    -- osEnv = ""

    -- Windows 10
    if osEnv == "Windows_NT"
    then
        self.PathListSeparator = pathListSeparator or ";"
    -- All other OS goes here
    else
        self.PathListSeparator = pathListSeparator or ":"
    end

    return o
end

-- Return indicator file exist or not, and indicator file full path
--
-- Return value:
--     bool: indicatorFileExist
--     string: indicatorFileFullPath
function getIndicatorFileStatus_jbgyampcwu()
    -- Require
    local mpUtils = require 'mp.utils'

    -- Const
    local indicatorFileName = "Anime4K_jbgyampcwu.i"

    -- Get file path
    local fileName = mp.get_property("path")
    local fileParentFolder, _ = mpUtils.split_path(fileName)

    -- Fill parent folder
    local indicatorFileFullPath = mpUtils.join_path(fileParentFolder, indicatorFileName)

    -- Try indicator file exist
    local indicatorFileExist, _ = mpUtils.file_info(indicatorFileFullPath)
    if indicatorFileExist == nil
    then
        return false, indicatorFileFullPath
    else
        return true, indicatorFileFullPath
    end
end

-- Send Anime4K command to mpv
function sendAnime4kCommand_jbgyampcwu()
    --
    -- BEGIN User input
    --

    -- If you have your own string, paste it here
    -- For complex primary mode (AA or BB or CA, etc)
    --   also paste it here and edit manually for customization.
    local userCommand2160P = ""
    local userCommand1440P = ""
    local userCommand1080P = ""
    local userCommand720P = ""
    local userCommand480P = ""

    local useUserInputCommand = false

    -- Anime4K profile preset
    -- See "Best Practices" section
    -- https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md
    local restoreCnnQuality = "M"
    local restoreCnnSoftQuality = "S"
    local upscaleCnnX2Quality = "M"
    local upscaleCnnX2ndQuality = "S"
    local upscaleDenoiseCnnX2Quality = "S"

    local useClampHighlights = true

    --
    -- End User input
    --



    --
    -- BEGIN Anime4K Command
    --

    -- Const
    local platformInformation = PlatformInformation:new()
    local pathListSeparator = platformInformation.PathListSeparator
    local commandPrefixConst = "no-osd change-list glsl-shaders set "
    local commandShowTextConst = pathListSeparator .. " show-text "
    local commandShowTextContentConst = "Anime4K: Scripted"

    -- Shader path
    local clampHighlightsPath = "~~/shaders/Anime4K_Clamp_Highlights.glsl" .. pathListSeparator
    local restoreCnnPath = "~~/shaders/Anime4K_Restore_CNN_" .. restoreCnnQuality .. ".glsl" .. pathListSeparator
    local restoreCnnSoftPath = "~~/shaders/Anime4K_Restore_CNN_Soft_" .. restoreCnnSoftQuality .. ".glsl" .. pathListSeparator
    local upscaleCnnX2Path = "~~/shaders/Anime4K_Upscale_CNN_x2_" .. upscaleCnnX2Quality .. ".glsl" .. pathListSeparator
    local upscaleDenoiseCnnX2Path = "~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_" .. upscaleDenoiseCnnX2Quality .. ".glsl" .. pathListSeparator
    local autoDownscalePreX2Path = "~~/shaders/Anime4K_AutoDownscalePre_x2.glsl" .. pathListSeparator
    local autoDownscalePreX4Path = "~~/shaders/Anime4K_AutoDownscalePre_x4.glsl" .. pathListSeparator

    -- Generate Anime4K command

    -- Primary mode combinations
    local modeACommand = restoreCnnPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2ndQuality
    local modeBCommand = restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2ndQuality
    local modeCCommand = upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2ndQuality
    local modeAACommand = restoreCnnPath .. upscaleCnnX2Path .. restoreCnnPath .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2ndQuality
    local modeBBCommand = restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. restoreCnnSoftPath .. upscaleCnnX2ndQuality
    local modeCACommand = upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. restoreCnnPath .. upscaleCnnX2ndQuality

    -- Add details on primary mode string to finalize
    function getAnime4KFullCommand(primaryModeString, debugText)
        -- Initialize debug text if not provided
        if debugText == nil
        then
            debugText = ""
        end

        -- Add ClampHighlights if possible
        if useClampHighlights
        then
            primaryModeString = clampHighlightsPath .. primaryModeString
        end

        -- Remove last semicolon
        primaryModeString = primaryModeString:sub(1, -2)

        -- Combine other parts together
        primaryModeString = commandPrefixConst .. "\"" .. primaryModeString .. "\"" .. commandShowTextConst .. "\"" .. commandShowTextContentConst .. debugText .. "\""

        return primaryModeString
    end

    --
    -- END Anime4K Command
    --



    --
    -- BEGIN Analyze video
    --

    -- Get video height as int
    local videoHeightString = mp.get_property("height")
    local videoHeightInt = tonumber(videoHeightString)

    -- Prepare final command, will send to mpv
    local finalCommand

    -- Enable different Anime4K combinations by video height
    if videoHeightInt >= 2160
    then
        -- This is already a 4K video but anyway
        if useUserInputCommand
        then
            finalCommand = userCommand2160P
        else
            -- If no user command requested, then do nothing on this resolution
            return
        end

        mp.command(finalCommand)

        return
    end

    if videoHeightInt >= 1440
    then
        -- Treat 1440p as 1080p for now but anyway
        if useUserInputCommand
        then
            finalCommand = userCommand1440P
            mp.command(finalCommand)

            return
        end

        -- If no user command requested, keep execute "if" statement chain
    end

    if videoHeightInt >= 1080
    then
        if useUserInputCommand
        then
            finalCommand = userCommand1080P
        else
            finalCommand = getAnime4KFullCommand(modeACommand, " A")
        end

        mp.command(finalCommand)

        return
    end

    if videoHeightInt >= 720
    then
        if useUserInputCommand
        then
            finalCommand = userCommand720P
        else
            finalCommand = getAnime4KFullCommand(modeBCommand, " B")
        end

        mp.command(finalCommand)

        return
    end

    if videoHeightInt < 720
    then
        if useUserInputCommand
        then
            finalCommand = userCommand480P
        else
            finalCommand = getAnime4KFullCommand(modeCCommand, " C")
        end

        mp.command(finalCommand)

        return
    end

    --
    -- End Analyze video
    --
end

-- Video loaded event
function videoLoadedEvent_jbgyampcwu(event)
    local indicatorFileExist, _ = getIndicatorFileStatus_jbgyampcwu()
    if indicatorFileExist == false
    then
        return
    else
        sendAnime4kCommand_jbgyampcwu()
    end
end

-- Toggle on/off event
function inputCommandEvent_jbgyampcwu()
    -- Get indicator file status
    local indicatorFileExist, indicatorFileFullPath = getIndicatorFileStatus_jbgyampcwu()

    if indicatorFileExist == false
    then
        -- Create file
        local file_object = io.open(indicatorFileFullPath, 'a')

        -- Ignore possible close error (happens on read only file system)
        local closeResult, err = pcall(function () file_object:close() end)

        -- Trigger scripted Anime4K
        sendAnime4kCommand_jbgyampcwu()
    else
        -- Delete exist file, ignore possible delete error (happens on read only file system)
        local deleteResult, err = pcall(function () os.remove(indicatorFileFullPath) end)

        -- Const
        local platformInformation = PlatformInformation:new()
        local pathListSeparator = platformInformation.PathListSeparator

        -- Clear glsl
        mp.command("no-osd change-list glsl-shaders clr \"\"" .. pathListSeparator .. "show-text \"GLSL shaders cleared\"")
    end
end

-- Delay some code executing
-- May useful when OSD messaging
-- https://github.com/mpv-player/mpv/issues/6592
function runFuntionButDelay_jbgyampcwu(myTime, myFunction)
    mp.add_timeout
    (
        myTime,
        function()
            myFunction()
        end
    )
end

mp.register_event("file-loaded", videoLoadedEvent_jbgyampcwu)
mp.add_key_binding(nil, "toggle-anime4k-jbgyampcwu", inputCommandEvent_jbgyampcwu)
