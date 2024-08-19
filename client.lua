local isTeleporting = false
local lastTeleportLocation = nil 
local debugMode = false 
local activeZone = nil 

local teleportZones = {
    {
        center = vector3(-7.1226, -3.5276, 9.8150), 
        radius = 100.0, 
    },
}

local teleportLocation = vector3(-25.3094, 46.6028, 72.0053) -- Where player must be teleported

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)
        local inZone = false

        for _, zone in pairs(teleportZones) do
            local distanceToZone = #(playerCoords - zone.center)

            if distanceToZone <= zone.radius then
                inZone = true
                activeZone = zone
                break
            end
        end

        if inZone then
            RunTeleportLogic()
        else
            activeZone = nil
        end
    end
end)

function RunTeleportLogic()
    while activeZone do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        if activeZone and #(playerCoords - activeZone.center) <= activeZone.radius and playerCoords.z < activeZone.center.z then
            if not isTeleporting then
                
                DisplayHelpText("Press ~INPUT_CONTEXT~ to teleport on ground")

                if IsControlJustReleased(0, 38) then  
                    TeleportPlayerToLocation(playerPed, teleportLocation)
                end
            end
        else
            isTeleporting = false 
            activeZone = nil 
        end

        if debugMode and activeZone then
            DrawZoneDebug(activeZone)
        end
    end
end

function DrawZoneDebug(zone)
    if not zone then return end

    local height = 10.0 
    local thickness = 0.5

    local halfSideLength = zone.radius
    local bottomZ = zone.center.z
    local topZ = zone.center.z + height

    -- Define the positions of the eight corners of the cube
    local corners = {
        vector3(zone.center.x - halfSideLength, zone.center.y - halfSideLength, bottomZ),  
        vector3(zone.center.x + halfSideLength, zone.center.y - halfSideLength, bottomZ),  
        vector3(zone.center.x - halfSideLength, zone.center.y + halfSideLength, bottomZ),  
        vector3(zone.center.x + halfSideLength, zone.center.y + halfSideLength, bottomZ),  
        vector3(zone.center.x - halfSideLength, zone.center.y - halfSideLength, topZ),     
        vector3(zone.center.x + halfSideLength, zone.center.y - halfSideLength, topZ),     
        vector3(zone.center.x - halfSideLength, zone.center.y + halfSideLength, topZ),     
        vector3(zone.center.x + halfSideLength, zone.center.y + halfSideLength, topZ),     
    }

    
    for i = 1, 4 do
        DrawMarker(2, corners[i].x, corners[i].y, (bottomZ + topZ) / 2, 0, 0, 0, 0, 0, 0, thickness, thickness, height, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    end

    -- Draw horizontal edges at the top and bottom faces
    DrawMarker(2, (corners[1].x + corners[2].x) / 2, (corners[1].y + corners[2].y) / 2, bottomZ, 0, 0, 0, 0, 0, 0, halfSideLength * 2, thickness, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[3].x + corners[4].x) / 2, (corners[3].y + corners[4].y) / 2, bottomZ, 0, 0, 0, 0, 0, 0, halfSideLength * 2, thickness, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[1].x + corners[3].x) / 2, (corners[1].y + corners[3].y) / 2, bottomZ, 0, 0, 0, 0, 0, 0, thickness, halfSideLength * 2, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[2].x + corners[4].x) / 2, (corners[2].y + corners[4].y) / 2, bottomZ, 0, 0, 0, 0, 0, 0, thickness, halfSideLength * 2, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)

    -- Draw the top face
    DrawMarker(2, (corners[5].x + corners[6].x) / 2, (corners[5].y + corners[6].y) / 2, topZ, 0, 0, 0, 0, 0, 0, halfSideLength * 2, thickness, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[7].x + corners[8].x) / 2, (corners[7].y + corners[8].y) / 2, topZ, 0, 0, 0, 0, 0, 0, halfSideLength * 2, thickness, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[5].x + corners[7].x) / 2, (corners[5].y + corners[7].y) / 2, topZ, 0, 0, 0, 0, 0, 0, thickness, halfSideLength * 2, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
    DrawMarker(2, (corners[6].x + corners[8].x) / 2, (corners[6].y + corners[8].y) / 2, topZ, 0, 0, 0, 0, 0, 0, thickness, halfSideLength * 2, thickness, 255, 0, 0, 200, false, false, 2, nil, nil, false)
end

function TeleportPlayerToLocation(playerPed, targetCoords)
    isTeleporting = true
    lastTeleportLocation = targetCoords

    SetEntityCoordsNoOffset(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, true, true, true)
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end
