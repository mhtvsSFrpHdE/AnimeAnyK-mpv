-- Tested on Anime4K version v4.0
-- Use namespace "_jbgyampcwu" to avoid possible conflicts
--
-- Automatically turn on Anime4K depending on video resolution
-- 2160P: Ignore, or send user command
-- 1080P ~ under 2160P: Mode A
-- 720P ~ under 1080P: Mode B
-- Under 720P: Mode C



--require 'mp.msg'
function videoLoadedEvent_jbgyampcwu(event)
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
    local restoreCnnQuality = "S"
    local restoreCnnSoftQuality = "S"
    local upscaleCnnX2Quality = "S"
    local upscaleDenoiseCnnX2Quality = "S"

    local useClampHighlights = true

    --
    -- End User input
    --



    --
    -- BEGIN Anime4K Command
    --

    -- Const
    local commandPrefixConst = "no-osd change-list glsl-shaders set "
    local commandShowTextConst = "; show-text "
    local commandShowTextContentConst = "Anime4K: Scripted"

    -- Shader path
    local clampHighlightsPath = "~~/shaders/Anime4K_Clamp_Highlights.glsl;"
    local restoreCnnPath = "~~/shaders/Anime4K_Restore_CNN_" .. restoreCnnQuality .. ".glsl;"
    local restoreCnnSoftPath = "~~/shaders/Anime4K_Restore_CNN_Soft_" .. restoreCnnSoftQuality .. ".glsl;"
    local upscaleCnnX2Path = "~~/shaders/Anime4K_Upscale_CNN_x2_" .. upscaleCnnX2Quality .. ".glsl;"
    local upscaleDenoiseCnnX2Path = "~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_" .. upscaleDenoiseCnnX2Quality .. ".glsl;"
    local autoDownscalePreX2Path = "~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;"
    local autoDownscalePreX4Path = "~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;"

    -- Generate Anime4K command

    -- Primary mode combinations
    local modeACommand = restoreCnnPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path
    local modeBCommand = restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path
    local modeCCommand = upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path
    local modeAACommand = restoreCnnPath .. upscaleCnnX2Path .. restoreCnnPath .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. upscaleCnnX2Path
    local modeBBCommand = restoreCnnSoftPath .. upscaleCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. restoreCnnSoftPath .. upscaleCnnX2Path
    local modeCACommand = upscaleDenoiseCnnX2Path .. autoDownscalePreX2Path .. autoDownscalePreX4Path .. restoreCnnPath .. upscaleCnnX2Path

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
            finalCommand = userCommand2160P
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
