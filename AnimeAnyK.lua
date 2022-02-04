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



--
-- BEGIN Class
--

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

-- Define Class: Core
Core_jbgyampcwu = {
}

-- Get video height as int
function Core_jbgyampcwu.GetVideoHeightInt()
    local videoHeightString = mp.get_property("height")
    local videoHeightInt = tonumber(videoHeightString)

    return videoHeightInt
end

-- Return indicator file exist or not, and indicator file full path
--
-- Return value:
--     bool: indicatorFileExist
--     string: indicatorFileFullPath
function Core_jbgyampcwu.GetIndicatorFileStatus()
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

-- Get Anime4K Command
-- Different video resolution leads to different command results
function Core_jbgyampcwu.GetAnime4KCommand(videoHeightInt)
    -- Anime4K profile preset
    -- See "Best Practices" section
    -- https://github.com/bloc97/Anime4K/blob/master/GLSL_Instructions.md
    local restoreCnnQuality = "M"
    local restoreCnnSoftQuality = "M"
    local upscaleCnnX2Quality = "M"
    local upscaleCnnX2Quality_2 = "S"
    local upscaleDenoiseCnnX2Quality = "M"

    --
    -- BEGIN Const
    --
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

    --
    -- END Cosnt
    --

    -- Primary mode combinations
    function getPrimaryModeString()
        -- Mode A
        if videoHeightInt >= 1080
        then
            return restoreCnnPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2, " A (Fast)"
        end

        -- Mode B
        if videoHeightInt >= 720
        then
            return restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2, " B (Fast)"
        end

        -- Mode C
        if videoHeightInt < 720
        then
            return upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path_2, " C (Fast)"
        end
    end

    -- Get primary mode string
    local primaryModeString, modeName = getPrimaryModeString()

    -- Add ClampHighlights if possible
    if UserInput_jbgyampcwu.UseClampHighlights
    then
        primaryModeString = clampHighlightsPath .. primaryModeString
    end

    -- Remove last semicolon
    primaryModeString = primaryModeString:sub(1, -2)

    -- Combine other parts together
    primaryModeString = commandPrefixConst .. "\"" .. primaryModeString .. "\"" .. commandShowTextConst .. "\"" .. commandShowTextContentConst .. modeName .. "\""

    -- DEBUG
    --print(primaryModeString)
    return primaryModeString
end

-- Send Anime4K command to mpv
function Core_jbgyampcwu.SendAnime4kCommand()
    local videoHeightInt = Core_jbgyampcwu.GetVideoHeightInt()

    -- Prepare final command, will send to mpv
    local finalCommand

    -- Enable different Anime4K combinations by video height
    if UserInput_jbgyampcwu.UseUserInputCommand
    then
        if videoHeightInt >= 2160
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand2160P
            mp.command(finalCommand)

            return
        end

        if videoHeightInt >= 1440
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand1440P
            mp.command(finalCommand)

            return
        end

        if videoHeightInt >= 1080
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand1080P
            mp.command(finalCommand)

            return
        end

        if videoHeightInt >= 720
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand720P
            mp.command(finalCommand)

            return
        end

        if videoHeightInt < 720
        then
            finalCommand = UserInput_jbgyampcwu.UserCommand480P
            mp.command(finalCommand)

            return
        end
    -- If no user command requested, then do nothing on 2160p
    -- Treat <2160p as 1080p(no built-in command) for now
    else
        if videoHeightInt < 2160
        then
            finalCommand = Core_jbgyampcwu.GetAnime4KCommand(videoHeightInt)
            mp.command(finalCommand)
        end
    end

    --
    -- End Analyze video
    --
end

--
-- END Class
--



--
-- BEGIN Event
--

-- Video loaded event
function videoLoadedEvent_jbgyampcwu(event)
    local indicatorFileExist, _ = Core_jbgyampcwu.GetIndicatorFileStatus()
    if indicatorFileExist == false
    then
        return
    else
        Core_jbgyampcwu.SendAnime4kCommand()
    end
end

-- Toggle on/off event
function inputCommandEvent_jbgyampcwu()
    -- Get indicator file status
    local indicatorFileExist, indicatorFileFullPath = Core_jbgyampcwu.GetIndicatorFileStatus()

    if indicatorFileExist == false
    then
        -- Create file
        local file_object = io.open(indicatorFileFullPath, 'a')

        -- Ignore possible close error (happens on read only file system)
        local closeResult, err = pcall(function () file_object:close() end)

        -- Trigger scripted Anime4K
        Core_jbgyampcwu.SendAnime4kCommand()
    else
        -- Delete exist file, ignore possible delete error (happens on read only file system)
        local deleteResult, err = pcall(function () os.remove(indicatorFileFullPath) end)

        -- Clear glsl
        mp.command("no-osd change-list glsl-shaders clr \"\"; show-text \"GLSL shaders cleared\"")
    end
end

--
-- END Event
--



mp.register_event("file-loaded", videoLoadedEvent_jbgyampcwu)
mp.add_key_binding(nil, "toggle-anime4k-jbgyampcwu", inputCommandEvent_jbgyampcwu)
