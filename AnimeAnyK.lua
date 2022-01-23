-- Tested on Anime4K version v4.0.1 and mpv-x86_64-20211219-git-fd63bf3
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



-- Define Class: UserInput
-- Override built-in Anime4K command for either early access to new version Anime4K
-- or temporary workaround a discovered bug without waiting for AnimeAnyK to fix it
UserInput_jbgyampcwu = {
    -- Toggle user command mode
    UseUserInputCommand = false,

    -- If you have your own string, paste it here
    --
    -- For complex primary mode (AA or BB or CA, etc)
    -- also paste it here and edit manually for customization.
    UserCommand2160P = "",
    UserCommand1440P = "",
    UserCommand1080P = "",
    UserCommand720P = "",
    UserCommand480P = "",

    -- Optional: Clamp_Highlights
    -- https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md#best-practices
    UseClampHighlights = true
}

-- Define Class: PlatformInformation
-- Determine OS type and provide corresponding variable value
PlatformInformation_jbgyampcwu = {
    -- Linux/Unix is ":", Windows is ";".
    -- https://mpv.io/manual/stable/#string-list-and-path-list-options
    --
    -- There is difference between path list separator and
    -- "send multiple command at once" command separator.
    -- Command separator is always ";".
    -- https://mpv.io/manual/stable/#input-conf-syntax
    PathListSeparator = nil
}
function PlatformInformation_jbgyampcwu:new (o, pathListSeparator)
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
    -- Anime4K profile preset
    -- See "Best Practices" section
    -- https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md
    local restoreCnnQuality = "M"
    local restoreCnnSoftQuality = "M"
    local upscaleCnnX2Quality = "M"
    local upscaleCnnX2Quality_2 = "S"
    local upscaleDenoiseCnnX2Quality = "M"

    --
    -- BEGIN Anime4K Command
    --

    -- Const
    local platformInformation = PlatformInformation_jbgyampcwu:new()
    local pathListSeparator = platformInformation.PathListSeparator
    local commandPrefixConst = "no-osd change-list glsl-shaders set "
    local commandShowTextConst = "; show-text "
    local commandShowTextContentConst = "Anime4K: Scripted"

    -- Shader path
    local clampHighlightsPath = "~~/shaders/Anime4K_Clamp_Highlights.glsl" .. pathListSeparator
    local restoreCnnPath = "~~/shaders/Anime4K_Restore_CNN_" .. restoreCnnQuality .. ".glsl" .. pathListSeparator
    local restoreCnnSoftPath = "~~/shaders/Anime4K_Restore_CNN_Soft_" .. restoreCnnSoftQuality .. ".glsl" .. pathListSeparator
    local upscaleCnnX2Path = "~~/shaders/Anime4K_Upscale_CNN_x2_" .. upscaleCnnX2Quality .. ".glsl" .. pathListSeparator
    local upscaleCnnX2Path_2 = "~~/shaders/Anime4K_Upscale_CNN_x2_" .. upscaleCnnX2Quality_2 .. ".glsl" .. pathListSeparator
    local upscaleDenoiseCnnX2Path = "~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_" .. upscaleDenoiseCnnX2Quality .. ".glsl" .. pathListSeparator
    local autoDownscalePreX2Path = "~~/shaders/Anime4K_AutoDownscalePre_x2.glsl" .. pathListSeparator
    local autoDownscalePreX4Path = "~~/shaders/Anime4K_AutoDownscalePre_x4.glsl" .. pathListSeparator

    -- Generate Anime4K command

    -- Primary mode combinations
    local modeACommand = restoreCnnPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2
    local modeBCommand = restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2
    local modeCCommand = upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2

    -- Add details on primary mode string to finalize
    function getAnime4KFullCommand(primaryModeString, debugText)
        -- Initialize debug text if not provided
        if debugText == nil
        then
            debugText = ""
        end

        -- Add ClampHighlights if possible
        if UserInput_jbgyampcwu.UseClampHighlights
        then
            primaryModeString = clampHighlightsPath .. primaryModeString
        end

        -- Remove last semicolon
        primaryModeString = primaryModeString:sub(1, -2)

        -- Combine other parts together
        primaryModeString = commandPrefixConst .. "\"" .. primaryModeString .. "\"" .. commandShowTextConst .. "\"" .. commandShowTextContentConst .. debugText .. "\""

        -- DEBUG
        --print(primaryModeString)
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
    -- DEBUG
    --videoHeightInt = 1080

    -- Prepare final command, will send to mpv
    local finalCommand

    -- Enable different Anime4K combinations by video height
    if videoHeightInt >= 2160
    then
        -- This is already a 4K video but anyway
        if UserInput_jbgyampcwu.UseUserInputCommand
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand2160P
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
        if UserInput_jbgyampcwu.UseUserInputCommand
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand1440P
            mp.command(finalCommand)

            return
        end

        -- If no user command requested, keep execute "if" statement chain
    end

    if videoHeightInt >= 1080
    then
        if UserInput_jbgyampcwu.UseUserInputCommand
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand1080P
        else
            finalCommand = getAnime4KFullCommand(modeACommand, " A")
        end

        mp.command(finalCommand)

        return
    end

    if videoHeightInt >= 720
    then
        if UserInput_jbgyampcwu.UseUserInputCommand
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand720P
        else
            finalCommand = getAnime4KFullCommand(modeBCommand, " B")
        end

        mp.command(finalCommand)

        return
    end

    if videoHeightInt < 720
    then
        if UserInput_jbgyampcwu.UseUserInputCommand
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand480P
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

        -- Clear glsl
        mp.command("no-osd change-list glsl-shaders clr \"\"; show-text \"GLSL shaders cleared\"")
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
