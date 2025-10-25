local _, Private = ...

local Timers = Private.Timers
local wipe = wipe

local function sortFunc(a, b)
    local _, numA = a:match("(%a+)(%d+)")
    local _, numB = b:match("(%a+)(%d+)")
    return tonumber(numA) < tonumber(numB)
end

Private.CoroutineQueues = {
    New = function(timerKey, processFunc, delayTime, maxTries)
        delayTime = delayTime or 1
        maxTries = maxTries or 10

        local obj = {}

        local queue = {}
        local retryCounts = {}
        local coroutineRef = nil

        local function sortIndexedTableDescending(item)
            if not retryCounts[item] then
                retryCounts[item] = 0
            end

            queue[#queue + 1] = item

            local seen = {}
            local i = 1

            -- Remove duplicates in-place
            while i <= #queue do
                local _item = queue[i]
                if seen[_item] then
                    table.remove(queue, i)
                else
                    seen[_item] = true
                    i = i + 1
                end
            end

            -- Sort in-place by numeric suffix descending
            table.sort(queue, sortFunc)
        end

        local function loop()
            while #queue > 0 do
                local item = table.remove(queue, 1)
                local tries = retryCounts[item] or 0

                if tries >= maxTries then
                    retryCounts[item] = nil -- exceeded max tries
                else
                    if processFunc(item) then
                        retryCounts[item] = tries + 1
                        sortIndexedTableDescending(item)
                    else
                        retryCounts[item] = nil -- success, cleanup
                    end
                end

                coroutine.yield()
            end
        end

        local function run()
            if not coroutineRef then
                coroutineRef = coroutine.create(loop)
            end

            if coroutine.status(coroutineRef) == "suspended" then
                local ok, err = coroutine.resume(coroutineRef)
                if not ok then error("CoroutineQueue failed: " .. tostring(err)) end

                if coroutine.status(coroutineRef) == "suspended" then
                    Timers:AddTimer(timerKey, 0, run)
                else
                    Timers:RemoveTimer(timerKey)
                    coroutineRef = nil
                end
            end
        end

        obj.Push = function(_, item)
            sortIndexedTableDescending(item)
            if not coroutineRef then
                Timers:AddTimer(timerKey, delayTime, run)
            end
        end

        obj.Stop = function()
            coroutineRef = nil
            wipe(queue)
            wipe(retryCounts)
            Timers:RemoveTimer(timerKey)
        end

        obj.IsRunning = function()
            return coroutineRef ~= nil and coroutine.status(coroutineRef) == "suspended"
        end

        return obj
    end
}
