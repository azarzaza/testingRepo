

function MYTH.Chat.RegisterCommand(this, command, callback, suggestion, arguments, job)
    if job ~= nil then
        if job.grade ~= nil then
            job.grade = 1
        end
    end

	commands[command] = {}
	commands[command].cmd = callback
    commands[command].arguments = arguments or -1
    commands[command].job = job

	if suggestion ~= nil then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

    RegisterCommand(command, function(source, args, rawCommand)
        local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)

        if mPlayer ~= nil then
            local cData = mPlayer:GetData('character'):GetData()
            if commands[command].job ~= nil then
                for k, v in pairs(commands[command].job) do
                    if v['base'] == cData.job.base then
                        if tonumber(v['grade']) <= cData.job.grade then
                            if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
                                callback(source, args, rawCommand)
                                break
                            else
                                TriggerEvent('mythic_chat:server:Server', source, "Invalid Number Of Arguments")
                            end
                        end
                    end
                end
            else
                if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
                    callback(source, args, rawCommand)
                else
                    TriggerEvent('mythic_chat:server:Server', source, "Invalid Number Of Arguments")
                end
            end
        end
    end, false)
end

function MYTH.Chat.RegisterAdminCommand(this, command, callback, suggestion, arguments)
	commands[command] = {}
	commands[command].cmd = callback
    commands[command].arguments = arguments or -1
    commands[command].admin = true

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

    RegisterCommand(command, function(source, args, rawCommand)
        local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)
        local mData = mPlayer:GetData('data')
        if mData.perm == 'admin' then
            if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
                callback(source, args, rawCommand)
            else
                TriggerEvent('mythic_chat:server:Server', source, "Invalid Number Of Arguments")
            end
        else
            exports['mythic_base']:FetchComponent('PwnzorLog'):PlayerLog('Mythic Chat', mPlayer, 'Player That Isn\'t An Admin Attempted To Use An Admin Command. | Details [ Command: ' .. command .. ' ]')
            exports['mythic_base']:FetchComponent('PwnzorLog'):CheatLog('Mythic Chat', 'Player That Isn\'t An Admin Attempted To Use An Admin Command. | Details [ Command: ' .. command .. ' User ID: '.. mData.id .. ' ]')
        end
    end, false)
end

--[[ COMMANDS ]]--
MYTH.Chat:RegisterCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('mythic_chat:client:ClearChat', source)
end, {
    help = "Clear The Chat"
})

MYTH.Chat:RegisterCommand('ooc', function(source, args, rawCommand)
    if #rawCommand:sub(4) > 0 then
        TriggerEvent('mythic_chat:server:OOC', source, rawCommand:sub(4))
    end
end, {
    help = "Out of Character Chat, THIS IS NOT A SUPPORT CHAT",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To The OOC Channel"
        }
    }
}, -1)

MYTH.Chat:RegisterCommand('311', function(source, args, rawCommand)
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)
    local name = mPlayer:GetData('character'):getName()
    fal = name.first .. " " .. name.last
    local msg = rawCommand:sub(5)
    TriggerClientEvent('mythic_jobs:client:Do311Alert', source, fal, msg)
end, {
    help = "Non-Emergency Line",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 311 Channel"
        }
    }
}, -1)

MYTH.Chat:RegisterCommand('911', function(source, args, rawCommand)
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)
    local name = mPlayer:GetData('character'):getName()
    fal = name.first .. " " .. name.last
    local msg = rawCommand:sub(5)
    TriggerClientEvent('mythic_jobs:client:Do911Alert', source, fal, msg)
end, {
    help = "Emergency Line",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 911 Channel"
        }
    }
}, -1)

--[[ ADMIN-RESTRICTED COMMANDS ]]--
MYTH.Chat:RegisterAdminCommand('server', function(source, args, rawCommand)
    TriggerEvent('mythic_chat:server:Server', source, rawCommand:sub(8))
end, {
    help = "Test",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 911 Channel"
        }
    }
}, -1)

MYTH.Chat:RegisterAdminCommand('system', function(source, args, rawCommand)
    TriggerEvent('mythic_chat:server:System', source, rawCommand:sub(8))
end, {
    help = "Test",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 911 Channel"
        }
    }
}, -1)