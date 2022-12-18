--[[
    @Website:   https://crow.pub/
]]



--[[
thisptr + 10104
↓
table m_flPoseParameter
    - 023 (float)

m_flPoseParameter[0]    --> leg direction while running
m_flPoseParameter[6]    --> animation while player in air
m_flPoseParameter[7]    --> leg animation while running
m_flPoseParameter[8]    --> animation while ducking & moving
m_flPoseParameter[9]    --> animation while slow walking
m_flPoseParameter[10]   --> animation while running
m_flPoseParameter[11]   --> player pose animation (yaw)
m_flPoseParameter[12]   --> player pose animation (pitch) (up ~ down)
m_flPoseParameter[13]   --> player pose animation (pitch) (zero ~ down)
m_flPoseParameter[14]   --> arm animation
m_flPoseParameter[15]   --> arm animation
m_flPoseParameter[16]   --> player pose animation (duck)
m_flPoseParameter[17]   --> player pose animation (duck)
]]









local render_world_to_screen, rage_exploit, ui_get_binds, ui_get_alpha, entity_get_players, entity_get, entity_get_entities, entity_get_game_rules, common_set_clan_tag, common_is_button_down, common_get_username, common_get_date, ffi_cast, ffi_typeof, render_gradient, render_text, render_texture, render_rect_outline, render_rect, entity_get_local_player, ui_create, ui_get_style, ui_get_icon, math_floor, math_abs, math_max, math_ceil, math_min, math_random, utils_trace_bullet, render_screen_size, render_load_font, render_load_image_from_file, render_measure_text, render_poly, render_poly_blur, common_add_notify, common_add_event, utils_console_exec, utils_execute_after, utils_create_interface, utils_trace_line, ui_find, entity_get_threat, string_format = render.world_to_screen, rage.exploit, ui.get_binds, ui.get_alpha, entity.get_players, entity.get, entity.get_entities, entity.get_game_rules, common.set_clan_tag, common.is_button_down, common.get_username, common.get_date, ffi.cast, ffi.typeof, render.gradient, render.text, render.texture, render.rect_outline, render.rect, entity.get_local_player, ui.create, ui.get_style, ui.get_icon, math.floor, math.abs, math.max, math.ceil, math.min, math.random, utils.trace_bullet, render.screen_size, render.load_font, render.load_image_from_file, render.measure_text, render.poly, render.poly_blur, common.add_notify, common.add_event, utils.console_exec, utils.execute_after, utils.create_interface, utils.trace_line, ui.find, entity.get_threat, string.format
local vmt_hook = require("neverlose/vmt_hook")

ffi.cdef[[
    typedef void*(__thiscall* get_client_entity_t)(void*, int);
    typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int);


    typedef struct
    {
        float x;
        float y;
        float z;
    } Vector_t;

    
    typedef struct
    {
        char    pad0[0x60]; // 0x00
        void* pEntity; // 0x60
        void* pActiveWeapon; // 0x64
        void* pLastActiveWeapon; // 0x68
        float        flLastUpdateTime; // 0x6C
        int            iLastUpdateFrame; // 0x70
        float        flLastUpdateIncrement; // 0x74
        float        flEyeYaw; // 0x78
        float        flEyePitch; // 0x7C
        float        flGoalFeetYaw; // 0x80
        float        flLastFeetYaw; // 0x84
        float        flMoveYaw; // 0x88
        float        flLastMoveYaw; // 0x8C // changes when moving/jumping/hitting ground
        float        flLeanAmount; // 0x90
        char    pad1[0x4]; // 0x94
        float        flFeetCycle; // 0x98 0 to 1
        float        flMoveWeight; // 0x9C 0 to 1
        float        flMoveWeightSmoothed; // 0xA0
        float        flDuckAmount; // 0xA4
        float        flHitGroundCycle; // 0xA8
        float        flRecrouchWeight; // 0xAC
        Vector_t        vecOrigin; // 0xB0
        Vector_t        vecLastOrigin;// 0xBC
        Vector_t        vecVelocity; // 0xC8
        Vector_t        vecVelocityNormalized; // 0xD4
        Vector_t        vecVelocityNormalizedNonZero; // 0xE0
        float        flVelocityLenght2D; // 0xEC
        float        flJumpFallVelocity; // 0xF0
        float        flSpeedNormalized; // 0xF4 // clamped velocity from 0 to 1
        float        flRunningSpeed; // 0xF8
        float        flDuckingSpeed; // 0xFC
        float        flDurationMoving; // 0x100
        float        flDurationStill; // 0x104
        bool        bOnGround; // 0x108
        bool        bHitGroundAnimation; // 0x109
        char    pad2[0x2]; // 0x10A
        float        flNextLowerBodyYawUpdateTime; // 0x10C
        float        flDurationInAir; // 0x110
        float        flLeftGroundHeight; // 0x114
        float        flHitGroundWeight; // 0x118 // from 0 to 1, is 1 when standing
        float        flWalkToRunTransition; // 0x11C // from 0 to 1, doesnt change when walking or crouching, only running
        char    pad3[0x4]; // 0x120
        float        flAffectedFraction; // 0x124 // affected while jumping and running, or when just jumping, 0 to 1
        char    pad4[0x208]; // 0x128
        float        flMinBodyYaw; // 0x330
        float        flMaxBodyYaw; // 0x334
        float        flMinPitch; //0x338
        float        flMaxPitch; // 0x33C
        int            iAnimsetVersion; // 0x340
    } CCSGOPlayerAnimationState_534535_t;
]]

local function this_call(call_function, parameters)
    return function(...)
        return call_function(parameters, ...)
    end
end

local entity_list_003 = ffi.cast(ffi.typeof("uintptr_t**"), utils.create_interface("client.dll", "VClientEntityList003"))
local get_entity_address = this_call(ffi.cast("get_client_entity_t", entity_list_003[0][3]), entity_list_003)


local group = ui.create("Main")
local anim_breakers = group:selectable("Anim. Breakers", {"0 Pitch on land", "Static leg in air", "Break leg", "Static on slow walk", "Static on duck"}, 0)
local legmovement = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement")
local slow_walk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk");
local hooked_function, is_jumping = nil, false

inside_updateCSA = function(thisptr, edx)
    hooked_function(thisptr, edx)
    if entity_get_local_player() == nil or ffi.cast('uintptr_t**', thisptr) == nil then return end

    legmovement:override(nil)
    if anim_breakers:get(1) then
        if ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi.cast("uintptr_t", thisptr) + 0x9960)[0].bHitGroundAnimation then
            if not is_jumping then
                ffi.cast("float*", ffi.cast("uintptr_t", thisptr) + 10104)[12] = 0.5
            end
        end
    end

    ffi.cast("float*", ffi.cast("uintptr_t", thisptr) + 10104)[6] = anim_breakers:get(2) and 1 or 0

    if anim_breakers:get(3) then
        legmovement:override("Sliding")
        ffi.cast("float*", ffi.cast("uintptr_t", thisptr) + 10104)[0] = 0
    end

    if anim_breakers:get(4) and slow_walk:get() then
        legmovement:override("Walking")
        ffi.cast("float*", ffi.cast("uintptr_t", thisptr) + 10104)[9] = 0
    end

    if anim_breakers:get(5) then
        ffi.cast("float*", ffi.cast("uintptr_t", thisptr) + 10104)[8] = 0
    end

end

update_hook = function()
    local self = entity_get_local_player()
    if not self or not self:is_alive() then
        return
    end

    local self_index = self:get_index()
    local self_address = get_entity_address(self_index)

    if not self_address or hooked_function then
        return
    end

    local new_point = vmt_hook.new(self_address)
    hooked_function = new_point.hook("void(__fastcall*)(void*, void*)", inside_updateCSA, 224)
end

events.createmove_run:set(function(cmd)
    is_jumping = bit.band(cmd.buttons, 2) ~= 0
    update_hook()
end)

ui.sidebar("AnimBreaker",'wheelchair')