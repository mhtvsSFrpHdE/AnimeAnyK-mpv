-- Add source code folder
-- https://stackoverflow.com/questions/5761229/is-there-a-better-way-to-require-file-from-relative-path-in-lua
package.path = package.path .. ";../?.lua"



--
-- BEGIN Class
--

-- Define Class: Test
Test = {
    VideoLoadedEventFunction = nil,
    InputCommandEventFunction = nil,
    VideoHeightInt = nil,
    VideoPath = nil,
    IndicatorFileExist = nil,
    LastSendedCommand = nil,
    FailedItem = {},
    FailedItemCount = 0
}
function Test.Reset()
    Test.VideoHeightInt = nil
    Test.IndicatorFileExist = nil
    Test.LastSendedCommand = nil

    local osEnv = os.getenv("OS")

    -- Windows 10
    if osEnv == "Windows_NT"
    then
        Test.VideoPath = "C:\\Video Files\\1.mp4"
    -- All other OS goes here
    else
        Test.VideoPath = "~/VideoFiles/1.mp4"
    end
end

-- Define Class: mp
-- Fake mpv API
mp = {}
function mp.command(command)
    Test.LastSendedCommand = command
end
function mp.register_event(ignore1, videoLoadedEventFunction)
    Test.VideoLoadedEventFunction = videoLoadedEventFunction
end
function mp.add_key_binding(ignore1, ignore2, inputCommandEventFunction)
    Test.InputCommandEventFunction = inputCommandEventFunction
end
function mp.get_property(property)
    if property == "height"
    then
        return Test.VideoHeightInt
    end

    if property == "path"
    then
        return Test.VideoPath
    end

    return nil
end

--
-- END Class
--



-- Load script
require("AnimeAnyK")

-- Test const
testPassed = ": Passed"
testFailed = ": Failed"

--
-- BEGIN Binding test
--

function bindVideoLoad()
    testName = "Test bind video loaded event"

    if Test.VideoLoadedEventFunction == nil
    then
        local failedReason = "\n    Video loaded event not bind\n    VideoLoadedEventFunction: nil"
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    else
        print(testName .. testPassed)
    end
end
bindVideoLoad()

function bindInputCommand()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test bind toggle keypress event"

    if Test.InputCommandEventFunction == nil
    then
        local failedReason = "\n    Toggle on/off event not bind\n    InputCommandEventFunction: nil"
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    else
        print(testName .. testPassed)
    end
end
bindInputCommand()

--
-- END Binding test
--



--
-- BEGIN Common test
--

function ino1080()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 1080P with indicator file NOT exist"

    Test.Reset()
    Test.VideoHeightInt = 1080

    Test.VideoLoadedEventFunction()
    if Test.LastSendedCommand == nil
    then
        print(testName .. testPassed)
    else
        local failedReason = "\n    When indicator file NOT exist, mp.command should not run.\n    LastSendedCommand: " .. Test.LastSendedCommand
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
ino1080()

function ino720()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 720P with indicator file NOT exist"

    Test.Reset()
    Test.VideoHeightInt = 720

    Test.VideoLoadedEventFunction()
    if Test.LastSendedCommand == nil
    then
        print(testName .. testPassed)
    else
        local failedReason = "\n    When indicator file NOT exist, mp.command should not run.\n    LastSendedCommand: " .. Test.LastSendedCommand
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
ino720()

function ino480()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 480P with indicator file NOT exist"

    Test.Reset()
    Test.VideoHeightInt = 480

    Test.VideoLoadedEventFunction()
    if Test.LastSendedCommand == nil
    then
        print(testName .. testPassed)
    else
        local failedReason = "\n    When indicator file NOT exist, mp.command should not run.\n    LastSendedCommand: " .. Test.LastSendedCommand
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
ino480()

function iyes1080()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 1080P with indicator file exist"
    testTarget = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Scripted A (Fast)\""

    Test.Reset()
    Test.VideoHeightInt = 1080
    Test.IndicatorFileExist = true

    Test.VideoLoadedEventFunction()
    if Test.LastSendedCommand ~= nil
    then
        if Test.LastSendedCommand == testTarget
        then
            os.remove("iyes1080_command.txt")
            os.remove("iyes1080_target.txt")
            print(testName .. testPassed)
        else
            local iyes1080_command = io.open("iyes1080_command.txt", "w")
            iyes1080_command:write(Test.LastSendedCommand)
            iyes1080_command:close()

            local iyes1080_target = io.open("iyes1080_target.txt", "w")
            iyes1080_target:write(testTarget)
            iyes1080_target:close()

            local failedReason = "\n    Generated command text mismatch with official.\n    Command saved to: iyes1080*.txt"
            table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
            Test.FailedItemCount = Test.FailedItemCount + 1
        end
    else
        os.remove("iyes1080_command.txt")
        os.remove("iyes1080_target.txt")
        local failedReason = "\n    When indicator file exist, mp.command should run once.\n    LastSendedCommand: nil"
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
iyes1080()

function iyes720()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 720P with indicator file exist"
    testTarget = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Restore_CNN_Soft_M.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Scripted B (Fast)\""

    Test.Reset()
    Test.VideoHeightInt = 720
    Test.IndicatorFileExist = true

    Test.VideoLoadedEventFunction()
    if Test.LastSendedCommand ~= nil
    then
        if Test.LastSendedCommand == testTarget
        then
            os.remove("iyes720_command.txt")
            os.remove("iyes720_target.txt")
            print(testName .. testPassed)
        else
            local iyes720_command = io.open("iyes720_command.txt", "w")
            iyes720_command:write(Test.LastSendedCommand)
            iyes720_command:close()

            local iyes720_target = io.open("iyes720_target.txt", "w")
            iyes720_target:write(testTarget)
            iyes720_target:close()

            local failedReason = "\n    Generated command text mismatch with official.\n    Command saved to: iyes720*.txt"
            table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
            Test.FailedItemCount = Test.FailedItemCount + 1
        end
    else
        os.remove("iyes720_command.txt")
        os.remove("iyes720_target.txt")
        local failedReason = "\n    When indicator file exist, mp.command should run once.\n    LastSendedCommand: nil"
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
iyes720()

function iyes480()
    if Test.FailedItemCount > 0
    then
        return
    end

    testName = "Test 480P with indicator file exist"
    testTarget = "no-osd change-list glsl-shaders set \"~~/shaders/Anime4K_Clamp_Highlights.glsl;~~/shaders/Anime4K_Upscale_Denoise_CNN_x2_M.glsl;~~/shaders/Anime4K_AutoDownscalePre_x2.glsl;~~/shaders/Anime4K_AutoDownscalePre_x4.glsl;~~/shaders/Anime4K_Upscale_CNN_x2_S.glsl\"; show-text \"Anime4K: Scripted C (Fast)\""

    Test.Reset()
    Test.VideoHeightInt = 480
    Test.IndicatorFileExist = true

    Test.VideoLoadedEventFunction()
    Test.LastSendedCommand = nil
    if Test.LastSendedCommand ~= nil
    then
        if Test.LastSendedCommand == testTarget
        then
            os.remove("iyes480_command.txt")
            os.remove("iyes480_target.txt")
            print(testName .. testPassed)
        else
            local iyes480_command = io.open("iyes480_command.txt", "w")
            iyes480_command:write(Test.LastSendedCommand)
            iyes480_command:close()

            local iyes480_target = io.open("iyes480_target.txt", "w")
            iyes480_target:write(testTarget)
            iyes480_target:close()

            local failedReason = "\n    Generated command text mismatch with official.\n    Command saved to: iyes480*.txt"
            table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
            Test.FailedItemCount = Test.FailedItemCount + 1
        end
    else
        os.remove("iyes480_command.txt")
        os.remove("iyes480_target.txt")
        local failedReason = "\n    When indicator file exist, mp.command should run once.\n    LastSendedCommand: nil"
        table.insert(Test.FailedItem, testName .. testFailed .. failedReason)
        Test.FailedItemCount = Test.FailedItemCount + 1
    end
end
iyes480()

--
-- END Common test
--



--
-- BEGIN User command test
--

--
-- END User command test
--



--
-- BEGIN Check test result
--

if Test.FailedItemCount == 0
then
    print("\nAll test passed, have a nice day!")
else
    print()
    for key, value in pairs(Test.FailedItem) do
        print(key .. ". " .. value)
    end
end

--
-- END Check test result
--
