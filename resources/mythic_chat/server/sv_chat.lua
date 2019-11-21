RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('mythic_chat:server:ClearChat')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
    end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)

    TriggerEvent('chatMessage', source, name, '/' .. command)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end

    CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(player)

    if mPlayer ~= nil then
        if mPlayer:GetData('active_char') ~= -1 then
            local mData = mPlayer:GetData('data')
            local cData = mPlayer:GetData('character'):GetData()
            for k, command in pairs(commandSuggestions) do
                if IsPlayerAceAllowed(player, ('command.%s'):format(k)) then
                    if commands[k] ~= nil then
                        if commands[k].admin then
                            if mData.perm == 'admin' then
                                TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                            else
                                TriggerClientEvent('chat:removeSuggestion', player, '/' .. k)
                            end
                        elseif commands[k].job ~= nil then
                            for k2, v2 in pairs(commands[k].job) do
                                if v2['base'] == cData.job.base then
                                    if tonumber(v2['grade']) <= cData.job.grade then
                                        TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                                        break
                                    else
                                        TriggerClientEvent('chat:removeSuggestion', player, '/' .. k)
                                    end
                                else
                                    TriggerClientEvent('chat:removeSuggestion', player, '/' .. k)
                                end
                            end
                            
                        else
                            TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                        end
                    else
                        TriggerClientEvent('chat:addSuggestion', player, '/' .. k, '')
                    end
                end
                
            end
        end
    end
end

AddEventHandler('chat:init', function()
    --refreshCommands(source)
end)

RegisterServerEvent('mythic_base:server:Logout')
AddEventHandler('mythic_base:server:Logout', function()
    TriggerClientEvent('chat:resetSuggestions', source)
    --refreshCommands(source)
end)

RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    refreshCommands(source)
end)

RegisterServerEvent('onResourceStart')
AddEventHandler('onResourceStart', function(resource)
    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)