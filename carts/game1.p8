pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- game 1 
-- by matthew phelps

-- page 1

-- the storyline
-- rats have gotten into
--    the basement! they must
--    have smelled my grandma's
--    cheddar. and now they've
--    come through the pipes. 

-- gstate: move, curs, beginzoom, zoomin, zoomed, rotate, zoomout
local gstate, glevel=0

-- macros
bnmap = {x=5, z=4, l=0, r=1, u=2, d=3 }
bn = function(button) return btn(bnmap[button]) end
bnp = function(button) return btnp(bnmap[button]) end
round = function(n)
    if ((n-flr(n)) > (ceil(n)-n)) then
        return ceil(n)
    else
        return flr(n)
    end
end
qtr_turns = function()
    return round(4*curs.lastangle)
end
-- debug
local debug_string=""
local soln_string = ""
local target_string = ""
debug_print = function(DEBUG)
    if (DEBUG) then
        print(gstate)
        print('z: '..curs.z)
        print('curs mapx : '..curs.mapx)
        print('curs mapy : '..curs.mapy)
        print('curs cx : '..curs.cx)
        print('curs cy : '..curs.cy)
        print(curs.mapx)
        print(curs.mapy)
        print('curs.cy: '..curs.cy)
        print('curs.angle: '..curs.angle)
        if (curs.lastangle != nil) then
            print('curs.lastang: '..curs.lastangle)
        else
            print('curs.lastang: 0')
        end
    end
end

function _init()
    gstate = "title"
end

handle_state_transitions = function()
    title_check()
    hammer_check()
    curs_check()
end
handle_level_transitions = function()
    soln_string = ""
    if (curs.didrotate and is_solution()) then
            soln_string = "VALID SOLUTION!" 
            play_solution()
            --music(16, 0, 12)
            glevel = glevel + 1
    end
end
handle_global_effects = function()
    shake_camera()
end
function _update()
    handle_state_transitions()
    handle_level_transitions()
    handle_global_effects()
    if (gstate == "curs") then
        move_cursor()
    elseif (gstate == "beginzoom") then
        begin_zoom()
    elseif (gstate == "endzoom") then
        end_zoom()
    elseif (gstate == "zoomin") then 
        zoom_in_animate()
    elseif (gstate == "zoomed") then    
        keep_zoomed()
    elseif (gstate == "zoomout") then
        zoom_out_animate()
    elseif (gstate == "rotate") then
        rotate_animate()
    elseif (gstate == "move") then
        move_player()

        pl_animtimer_incr()
    end
end

function _draw()
    debug_print(config.DEBUG)
    if (gstate == "title") then
        cls(config.title_bgcolor)
        draw_title()
    else 
        cls(config.bgcolor)
        draw_floor()
        draw_level()
        draw_hammer()
        draw_player()
        draw_border()
        if (gstate != "move") then
            print(debug_string)
            print(target_string)
            print(soln_string)
            if (gstate == "curs") then
                draw_curs()
            else
                transform_and_display_buffer()
            end
        end
    end
end

-->8
-- page 2 (drawing)

draw_floor = function()
    for i = 1,14 do
        for j = 7,15 do
            spr(gsprites.floor1, i*8, j*8)
        end
    end
end

draw_title = function()
    -- title
    map(0,0,0,0,16,16)
    print("press ❎ to start", 29, 80, 4)
end

draw_level = function()
    map(gmap[glevel].x, gmap[glevel].y, 0, 0, 16, 16)
end

draw_border = function()
    map(gmap.border.x, gmap.border.y, 0, 0, 16, 16)
end

draw_player = function()
    spr(pl.sprites[pl.frame], pl.x, pl.y, 1, 1, pl.lookLeft, false)
end

draw_hammer = function()
    spr(gsprites.hammer, 54, 24, 2, 2)
    spr(gsprites.hammer_bubble, 50, 14)
end
draw_curs = function()
    spr(gsprites.curs, curs.sx+(curs.mode-1)*4, curs.sy+(curs.mode-1)*4)
    draw_curs_box(1,8*curs.mode)
end
draw_curs_box = function(n1, n2)
    rectfill(curs.sx-n1, curs.sy-n1, curs.sx-n1, curs.sy+n2, curs.col)
    rectfill(curs.sx-n1, curs.sy-n1, curs.sx+n2, curs.sy-n1, curs.col)
    rectfill(curs.sx+n2, curs.sy+n2, curs.sx+n2, curs.sy-n1, curs.col)
    rectfill(curs.sx+n2, curs.sy+n2, curs.sx-n1, curs.sy+n2, curs.col)
end
shadow_spr_below_with = function(sprn, col)

end
-->8
-- page 3 (config)

config = {
	bgcolor = 0,
    title_bgcolor = 2,
    DEBUG = false,
    DEBUG_SOLN = false,
    SHOW_SOLN = true
}
-- g means global
gst = {
    [1] = {
        s = {x=33,y=12}, t = {x=46,y=11}
    },
    [2] = {
        s = {x=50,y=12}, t = {x=61,y=8}
    },
    [3] = {
        s = {x=66,y=12}, t = {x=77,y=8}
    }
}
gsprites = {
    border = 112,
    hammer = 65,
    hammer_bubble = 113,
    curs = 114,
    floor1 = 06
}
gmap = {
    border = {x = 112, y = 0},
    land = {x = 16,y = 0},
    title = {x = 0, y = 0},
    -- levels
    [0] = {x = 16, y = 0},
    [1] = {x = 32, y = 0},
    [2] = {x = 48, y = 0},
    [3] = {x = 64, y = 0}
}
pl = {
    x = 30,
    y = 30,
    dx = 0,
    dy = 0,
    ddx = 0,
    decelx = 0,
    accelx = 0,
    decely = 0,
    sprites = {
        rest = 96,
        walk1 = 97,
        walk2 = 98,
        jump = 99
    },
    lookLeft = false,
    resting = true,
    animtimer = 0,
    animlength = 6,
    frame = 'rest'
}
curs = {
	sx = 80, -- pixel on screen
	sy = 80,
	bx = 5, -- block on screen
	by = 5,
    mapx = 0, -- map block position of cursor
    mapy = 0, 
	mode = 1, -- mode x mode grid
	col = 6,
    zoomInDone = false,
    zoomOutDone = false,
    rotateDone = false,
    animtimer = 0,
    animlength = 12,
    z = 0, -- zoom level
    cx = nil, -- center of zoom/rot
    cy = nil,
    angle = 0,
    lastangle = nil,
    rotDir = nil,
    shadowCol = 0,
    didrotate = false
}
buffer = {spx = 5*8, spy = 10*8, bx = 5, by = 10, rotspx = 9*8, rotspy = 10*8}
cam = {shake=0}

-->8
-- page 4 (updating)

-- State transitions:
title_check = function()
    if (gstate == "title") then
        if (btn(4) or btn(5)) then
            gstate = "move"
            glevel = 1
            play_bridge() -- for now
        end
    end
end
hammer_check = function()
    if (pl.x > 48 and pl.x < 80 and btnp(5)) then
        if (gstate == "curs") then
            gstate = "move"
        elseif (gstate == "move") then
            gstate = "curs"
        end
    end
end
curs_check = function()
    if (gstate == "curs" and bnp('z') and curs_on_pipe()) then
        gstate = "beginzoom"
    elseif(gstate == "beginzoom") then
        gstate = "zoomin"
    elseif (gstate == "zoomin" and curs.zoomInDone) then
        gstate = "zoomed"
    elseif (gstate == "zoomed" and (bnp('r') or bnp('l'))) then
        gstate = "rotate"
    elseif (gstate == "rotate" and curs.rotateDone) then
        gstate = "zoomed"
    elseif (gstate == "zoomed" and bnp('z')) then
        gstate = "zoomout"
    elseif (gstate == "zoomout" and curs.zoomOutDone) then
        gstate = "endzoom"
    elseif (gstate == "endzoom") then
        gstate = "curs"
    end
end
curs_on_pipe = function()
    pipe_located = false
    for i=curs.mapx , curs.mapx + curs.mode - 1 do 
        for j=curs.mapy , curs.mapy + curs.mode - 1 do 
            pipe_located = pipe_located or is_pipe_spr(mget(i,j))
        end 
    end 
    return pipe_located
end
curs_in_bounds = function() 
end 

-- Map modification with cells
debug_str = ""
begin_zoom = function()
    -- Add tiles to buffer 
    for i = 0, curs.mode-1 do
        for j = 0, curs.mode-1 do
            local sprn = mget(i + curs.mapx, j+curs.mapy)
            local sprx = 8 * (sprn % 16)
            local spry = 8 * flr(sprn / 16)
            if (sprn != 0) then
                for u = 0, 7 do
                    for v = 0, 7 do
                        local c = sget(sprx+u, spry+v)
                        debug_str = debug_str .. c .. ","
                        sset(buffer.spx+u+i*8, buffer.spy+v+j*8, c)
                    end
                end
            end
        end
    end
end
end_zoom = function()
    -- based on current angle, adjust map
    rewrite_pipe_map()
    -- erase animation buffer, reset cursor angles
    curs.didrotate = reset_buffer()
    -- (potentially) shake
    shake_camera(curs.didrotate)
end
rewrite_pipe_map = function()
    old_sprn = {}
    if (curs.mode == 1) then
        new_sprn = next_pipe_spr(mget(curs.mapx,curs.mapy),qtr_turns())
        mset(curs.mapx, curs.mapy, new_sprn)
    elseif (curs.mode == 2) then
        for i=0,3 do 
            origx = curs.mapx + flr(shr(i+1,1))%2
            origy = curs.mapy + flr(shr(i,1))
            old_sprn[i] = mget(origx,origy)
        end
        for i=0,3 do
            newx  = curs.mapx + flr(shr((i+1+qtr_turns())%4,1))%2
            newy  = curs.mapy + flr(shr((i+qtr_turns())%4,1))
            new_sprn = next_pipe_spr(old_sprn[i],qtr_turns())
            mset(newx, newy, new_sprn) 
        end
    elseif (curs.mode == 3) then 
        -- center
        new_sprn = next_pipe_spr(mget(curs.mapx+1,curs.mapy+1),qtr_turns())
        mset(curs.mapx+1, curs.mapy+1, new_sprn)
        -- corners 
        for i=0,6,2 do 
            origx = curs.mapx + shl(flr(shr(shr(i,1)+1,1))%2,1)
            origy = curs.mapy + shl(flr(shr(i,2)),1)
            old_sprn[i] = mget(origx,origy)
        end
        for i=0,6,2 do
            newx  = curs.mapx + shl(flr(shr(shr((i+2*qtr_turns())%8,1)+1,1))%2,1)
            newy  = curs.mapy + shl(flr(shr((i+2*qtr_turns())%8,2)),1)
            new_sprn = next_pipe_spr(old_sprn[i],qtr_turns())
            mset(newx, newy, new_sprn) -- move new rotated pipe
        end
        -- edges 
        for i=1,7,2 do
            origx = curs.mapx + (shr(i+1,1)%4)%(5-shr(i+1,1))
            origy = curs.mapy + shr(i-1,1)%(5-shr(i-1,1))
            old_sprn[i] = mget(origx,origy)
        end
        for i=1,7,2 do
            newx  = curs.mapx + (shr((i+1+2*qtr_turns())%8,1)%4)%(5-shr((i+1+2*qtr_turns())%8,1))
            newy  = curs.mapy + shr((i-1+2*qtr_turns())%8,1)%(5-shr((i-1+2*qtr_turns())%8,1))
            new_sprn = next_pipe_spr(old_sprn[i],qtr_turns())
            mset(newx, newy, new_sprn) 
        end
    end
end
reset_buffer = function()
    for u = 0, 8*curs.mode-1 do
        for v = 0, 8*curs.mode - 1 do
            sset(buffer.spx+u, buffer.spy+v, 0)
            sset(buffer.rotspx+u, buffer.rotspy+v, 0)
        end
    end
    -- reset angle, zoom to 0
    local didrotate = (curs.lastangle%1 != 0)
    curs.angle, curs.lastangle, curs.z = 0, 0, 0
    return didrotate
end
shake_camera = function(didrotate)
    if (gstate == "endzoom" and didrotate) then
        cam.shake = 1
        if (rnd(1)>0.5) then sfx(32) else sfx(33) end
    end
    local shakex=2-rnd(4)
    local shakey=2-rnd(4)
    shakex*=cam.shake
    shakey*=cam.shake
    camera(shakex,shakey)
    cam.shake = cam.shake*0.80
    if (cam.shake<0.03) cam.shake=0
end
is_solution = function()
    debug_string = ""
    local x, y = gst[glevel].s.x+1, gst[glevel].s.y 
    -- red: 1 right side, 2 bottom side, 4 left side, 8 top side
    -- green: 16, 32, 64, 128 (unfinished)
    sol_dir = 2 -- left side
    while (not target_reached(x,y)) do 
        curr_spr = mget(x,y)
        if (not is_pipe_spr(curr_spr)) then 
            return false
        else 
            red_fl = fget(curr_spr) % 16
            dir = {}
            dir[0] = red_fl % 2
            dir[1] = flr(shr(red_fl,1)) % 2
            dir[2] = flr(shr(red_fl,2)) % 2
            dir[3] = flr(shr(red_fl,3)) % 2
            if (dir[sol_dir] == 0) then 
                return false
            end
            -- straight pipe is default
            if (dir[(sol_dir+2)%4] == 1) then 
                -- continue same direction
                if (config.DEBUG_SOLN) debug_string = x..","..y.." go straight\n"
            elseif (dir[(sol_dir+1)%4] == 1) then 
                -- turn left
                if (config.DEBUG_SOLN) debug_string = x..","..y.." turn left\n"
                sol_dir = (sol_dir-1)%4
            elseif (dir[(sol_dir-1)%4] == 1) then 
                -- turn right
                if (config.DEBUG_SOLN) debug_string = x..","..y.." turn right\n"
                sol_dir = (sol_dir+1)%4
            end
            -- move x and y
            x += x_from_sol_dir(sol_dir)
            y += y_from_sol_dir(sol_dir)
            if (config.DEBUG_SOLN) debug_string = debug_string .."next xy: "..x..","..y.."\n"
        end
    end
    return true
end
x_from_sol_dir = function(sol_dir)
    return (sol_dir%(5-sol_dir))-1
end
y_from_sol_dir = function(sol_dir)
    return -1*((((sol_dir+1)%4)%(4-sol_dir))-1)
end
target_reached = function(x,y)
    if (config.DEBUG_SOLN) target_string = "target: "..gst[glevel].t.x ..",".. gst[glevel].t.y
    return (x==gst[glevel].t.x) and (y==gst[glevel].t.y)
end
is_pipe_spr = function(n)
    return btw(n,16,23) or btw(n,32,39) or btw(n,48,53)
end
-- Animation + movement
curs_animation_done = function()
    curs.animtimer = (curs.animtimer+1)%(1+curs.animlength)
    return (curs.animtimer == 0)
end
zoom_animate_dir = function(dir)
    if (dir == "in") then
        if (curs_animation_done()) then
            curs.zoomInDone = true
            curs.z = 1
        else
            curs.z += 1/curs.animlength
        end
    elseif (dir == "out") then
        if (curs_animation_done()) then
            curs.zoomOutDone = true
            curs.z = 0
        else
            curs.z -= 1/curs.animlength
        end
    end
end
keep_zoomed = function()
    curs.lastangle = curs.angle
    curs.zoomInDone = false
    curs.zoomOutDone = false
    curs.rotateDone = false
end
zoom_in_animate = function()
    zoom_animate_dir("in")
end
zoom_out_animate = function()
    zoom_animate_dir("out")
end
rotate_animate = function()
    if (curs.rotDir == nil) then
        if (bnp('l')) then
            curs.rotDir = 'l'
        elseif (bnp('r')) then
            curs.rotDir = 'r'
        end
        curs.lastangle = curs.angle
    else
        if (curs_animation_done()) then
            curs.rotateDone = true
            if (curs.rotDir == 'l') then
                curs.angle = curs.lastangle - 0.25
            elseif (curs.rotDir == 'r') then
                curs.angle = curs.lastangle + 0.25
            end
            curs.lastangle = curs.angle
            curs.rotDir = nil
        else 
            if (curs.rotDir == 'l') then
                curs.angle -= 0.25/(curs.animlength)
            elseif
                (curs.rotDir == 'r') then
                curs.angle += 0.25/(curs.animlength)
            end
        end
    end
end
move_cursor = function()
	if(btnp(0)) then 
		curs.bx -= 1
	elseif(btnp(1)) then 
		curs.bx += 1
	elseif(btnp(2)) then 
		curs.by -= 1
	elseif(btnp(3)) then 
		curs.by += 1
	end
    -- screen
    curs.sx = curs.bx*8
    curs.sy = curs.by*8
    curs.cx = curs.sx + 4*curs.mode -- center
    curs.cy = curs.sy + 4*curs.mode
    -- map loc 
    curs.mapx = curs.bx + gmap[glevel].x
    curs.mapy = curs.by + gmap[glevel].y
end
move_player = function()
    if (btn(0)) then 
        if not pl.lookLeft then
            pl.lookLeft = true
        end
        pl.x -= 1.0
        pl.frame = next_pl_walk()
        return 
    end
    if (btn(1)) then 
        if pl.lookLeft then
            pl.lookLeft = false
        end
        pl.x += 1.0
        pl.frame = next_pl_walk() 
        return 
    end
    -- NO JUMPING CURRENTLY!
    pl.frame = "rest"
end
pl_animtimer_incr = function()
    pl.animtimer = (pl.animtimer + 1)%(pl.animlength)
end
next_pl_walk = function()
    if (pl.animtimer >= pl.animlength/2) then
        return "walk1";
    else 
        return "walk2";
    end
end
-->8
-- page 5 (rotation)

-- world to screen space project
local cam_focal=1/8
function project(x,y,z,cx,cy)
	local w=cam_focal/(cam_focal+z)
 return cx+x*w,cy-y*w,z,w
end
function transform_and_display_buffer()
    local z = curs.z
    local sx = curs.sx-(z)*4*curs.mode+.5
    local sy = curs.sy-(z)*4*curs.mode+.5
    local w = (1+z)*8*curs.mode
    -- Cursor buffer shadow
    rectfill(sx,sy,sx+w-1.5,sy+w-1.5,curs.shadowCol)
	-- Rotate pipes
	rspr(buffer.spx,buffer.spy,
        buffer.rotspx,buffer.rotspy,
        curs.angle,curs.mode)	
 	-- Display pipes
    sspr(buffer.rotspx,buffer.rotspy,8*curs.mode,8*curs.mode,
        sx, sy, w, w)
end
local rspr_clear_col=0
function rspr(sx,sy,x,y,a,w)
	local ca,sa=cos(a),sin(a)
	local srcx,srcy,addr,pixel_pair
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
				sset(x+ix,y+iy,c)
			else
				sset(x+ix,y+iy,rspr_clear_col)
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
	end
end
-->8
-- page 6 (rot logic)

-- need to rewrite map
btw = function(a,b,c)
    return a >= b and a <= c 
end
next_pipe_spr = function(n, qtr_clockwise_turns)
    -- red 
    if (btw(n,16,19)) then
        n = ((n-16)+qtr_clockwise_turns)%4 + 16
    elseif (btw(n,20,21)) then
        n = ((n-20)+qtr_clockwise_turns)%2 + 20 
    elseif (btw(n,22,23)) then
        n = ((n-22)+qtr_clockwise_turns)%2 + 22
    -- green
    elseif (btw(n,32,35)) then  
        n = ((n-32)+qtr_clockwise_turns)%4 + 32
    elseif (btw(n,36,37)) then  
        n = ((n-36)+qtr_clockwise_turns)%2 + 36
    elseif (btw(n,38,39)) then
        n = ((n-38)+qtr_clockwise_turns)%2 + 38
    -- redgreen
    elseif (btw(n,48,51)) then
        n = ((n-48)+qtr_clockwise_turns)%4 + 48
    elseif (btw(n,52,53)) then
        n = ((n-52)+qtr_clockwise_turns)%2 + 52
    end
    return n
end

-->8
-- page (7) credits

-- playtesters in order of appearance:
-- tommy krug
-- edward atkinson

-->8
-- page (8) MUSIC
play_bridge = function()
    music(10,200) -- channels 1-3, 0 is sfx
end
play_solution = function() 
    sfx(35)
end

__gfx__
000000000000000000000000000007001111111111111111dd11dd11d666666d0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000700000000001666666111666611dd11dd116d6666d10000000000000000000000000000000000000000000000880000000000000000
00700700000007000000707000070007111611111161161111dd11dd66d66d110000000000000000000000000000000000000000000000080000000000000000
00077000000000000000070000000000111611111161111111dd11dd666dd1110000000000000000000000000000000000000000000000008000000000000000
000770000000000000000000000007001116111111666611dd11dd11666dd1110000000000000000000000088880088800000000000000008000000000000000
007007000000000000000000000000001116111111111611dd11dd1166d11d110000000000000000000008880088080800000000000000008000000000000000
00000000000000000000000000000000111611111161161111dd11dd6d1111d10000000000000000000008000008000800000000000000008000000000000000
00000000000000000000000000000000111111111166611111dd11ddd111111d0000000000000000000000880008000800000000000000008000000000000000
00288200000000000000000000288200002882000028820000000000002882000000000000000000000000800888000800000000008000008088000000008800
00288200000000000000000000288200002882000028820000000000002882000000000000000000000000888800008000800008888880008888088808888880
00288822000022222222000022888200222222222228822222222222002882000000000000000000000008800000008008800800888880088008880800880000
00288888000288888888200088888200888888888828828888888888002882000000000000000000000008000000080000808800808880088008888800800000
00028888002888888888820088882000888888888828828888888888002882000000000000000000000088000000080000808800808080088008800000800000
00002222002888222288820022220000222222222228822222222222002882000000000000000000000880000000888800888800808080080088800008000000
00000000002882000028820000000000002882000028820000000000002882000000000000000000000000000000880000880808808080080880800808000000
00000000002882000028820000000000002882000028820000000000002882000000000000000000000000000000000000000008008080080000888888000000
00133100000000000000000000133100001331000013310000000000001331000000000000000000000000000000000000000000000000000000000000000000
00133100000000000000000000133100001331000013310000000000001331000000000000000000000000000000000000000000000000000000000000000000
00133311000011111111000011333100111111111113311111111111001331000000000000000000000000088880000000000000000000000000000000000000
00133333000133333333100033333100333333333313313333333333001331000000000000000000000008880088800000000000000000000000000000000000
00013333001333333333310033331000333333333313313333333333001331000000000000000000000008080000880000000000800008000000000000000000
00001111001333111133310011110000111111111113311111111111001331000000000000000000000000080000080000000000080000800000000000000000
00000000001331000013310000000000001331000013310000000000001331000000000000000000000000080008880000000000088000800000000000000000
00000000001331000013310000000000001331000013310000000000001331000000000000000000000000088888000000000000008000800000000000000000
00288200002882000013310000133100001331000028820022222222222222220000000000000000000000080000000000000000008000800000000000000888
00288200002882000013310000133100001331000028820029999992229999220000000000000000000000080000080000000000880000808880800888800808
11288822228882112222331111332222222222221128821122292222229229220000000000000000000000080000088888088888888800808080088880800880
33288888888882338888233333328888888888883328823322292222229222220000000000000000000000880000080000080880088800808880080880800088
33328888888823338888823333288888888888883328823322292222229999220000000000000000000000800000880000800080080080808000080800800008
11332222222233112288821111288822222222221128821122292222222229220000000000000000000008800000800000888800880880808888080800808088
00133100001331000028820000288200001331000028820022292222229229220000000000000000000008000000800000000000888808800000000000808880
00133100001331000028820000288200001331000028820022222222229992220000000000000000000000000000000000000000800000000000000000000000
00000000000000011100010000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666
00000000000011166711171000000000000000000000000000000000000000000000000000000000000000000000000000000000699999666966666669999666
00000000000166666616161000000000000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669666666
00000000001666666616161000000000000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669666666
00000000016666111111161000000000000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669996666
00000000016111199100010000000000000000000000000000000000000000000000000000000000000000000000000000000000666966666999996669666666
00000000001000199100000000000000000000000000000000000000000000000000000000000000000000000000000000000000666966666666666669999966
00000000000000199100000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc66666666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc66696666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000cccccccc66696666
000000000000001991000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007a700cccccccc66696666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000337000cccccccc66696666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000cccccccc66696666
0000000000000019910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000cccccccc66666666
0000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000cccccccc66666666
0000000000000000000000000099700000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
0099700000997000009970000099990000000000000000000000000000000000000000000000000000000000000000000000000044444494cccccccccccccccc
0099990000999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
00fff00000fff00000fff00000fff00000000000000000000000000000000000000000000000000000000000000000000000000044944444cccccccccccccccc
00eff00000eff00000eff0000feff00000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
00eea0000feea0000feea00000eea00000000000000000000000000000000000000000000000000000000000000000000000000044444444ccccc3cccccccccc
00fee00000eee50005eee00005eee50000000000000000000000000000000000000000000000000000000000000000000000000044449444ccccc3cccccccccc
0050500000500000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444c3ccc3ccc3ccccc3
66666666077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333333333333
66666666776666670600006000000000000000000000000000000000000000000000000000000000000000000000000000000000449444443333333333333333
66666666766161660060060000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443339333333333393
66666666766616660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333339333333
66666666766161660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000494444443333333333333333
66666666076666670060060000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333339333339333
66666666000077700600006000000000000000000000000000000000000000000000000000000000000000000000000000000000444444943933333333333333
66666666000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333333333333
__gff__
000000000000000000000000000000000903060c0f0f050a0000000000000000903060c0f0f050a00000000000000000693c96c3a55a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048484848484848484848484848484848
000000000000000000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
00000000000a0b000d0e0000000000006e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e0000000000000000000000000000000048000000000000000000000000000048
00000000001a1b1c1d1e1f00000000007e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f0000000000000000000000000000000048000000000000000000000000000048
00000000002a2b002d000000000000007d6d6d6d7d6d6d7d6d7d6d6d7d6d6d7d7d6d6d6d7d6d6d7d6d7d6d6d7d6d6d7d7d6d0707070707070707070707077d7d7d6d0707070707070707070707077d7d7d6d0707070707070707070707077d7d0000000000000000000000000000000048000000000000000000000000000048
00000000003a3b3c3d3e3f00000000007d7d6d6d6d6d6d6d6d6d6d6d6d6d6d6d7d07070707070707070707070707076d7d7d0700000000111616161200077d6d7d7d0700002123002122002700077d6d7d7d0522000011161616161612077d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d7d6d6d6d6d6d6d6d6d6d6d7d7d6d7d7d07000000000000000000000000077d7d6d0700000000000000001016366d7d7d6d0700002300212320262727046d7d7d6d0727000017000000000011366d7d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d7d6d6d6d6d6d6d7d7d6d6d6d7d7d6d7d07000000130000000000000000076d7d6d0700001100111616161300077d6d7d6d0700000000270027002727077d6d7d6d0720220034000000000017077d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d7d6d6d6d6d7d7d6d6d6d6d7d7d7d6d6d07000000001300000011120000076d6d7d0700001700170000000017077d6d6d7d0700002123270027000000077d6d6d7d0700202634262626262217077d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d6d6d6d6d7d7d7d7d7d6d6d7d6d7d6d6d07000000000013161613101616366d6d6d0700001012130000000017076d6d6d6d0700002420272623000000076d6d6d6d0700000034000000002035046d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d6d6d6d6d7d7d7d7d7d7d6d7d6d7d6d7d37161200000017000000000000076d7d7d3716161613000000001113076d6d7d7d0525262300270000000000076d6d7d7d0700000017170000001113076d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d7d6d6d6d6d6d6d6d7d7d7d7d7d7d7d7d07001016161613000000000000077d7d6d0700000000000000111300077d7d7d6d0700000000270000000000077d7d7d6d3716161613171616161300077d7d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000006d7d7d7d7d7d6d6d6d7d7d7d6d6d6d6d6d07000000000000000000000000076d6d7d0700001016161616130000077d6d6d7d0700202626230000000000077d6d6d7d0700000000170000000000077d6d0000000000000000000000000000000048000000000000000000000000000048
000000000000000000000000000000007d6d6d6d6d7d7d7d6d6d6d6d6d6d6d7d7d07070707070707070707070707077d7d6d0707070707070707070707076d7d7d6d0707070707070707070707076d7d7d6d0707070707070707070707076d7d0000000000000000000000000000000048484848484848484848484848484848
__sfx__
010700001035010350103501035010350101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150
01100000101501c1501c1501c1501c1500f1500f1500f1500f1500f1501d150111501015010150101501015010650106501065010650106501065010650106501065010150101501015010150101501015010150
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e0000151501515014150151501515014150171501505015150151501515015150151501b1501715015050151501515015150151501515014150171501505015150151501515015150151501b1501715015050
010e00001015010150101501015010150121501715010050101501015010150101501015012150171501005010150101501015010150101501b150171501005010150101501015010150101501a1501715010050
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b7502e750307402e730267102f7002a3002a200252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500003065015650126500f6400d6400c6300a61007610076100661004610016100260001600016000060000600006000060000000000000000000000000000000000000000000000000000000000000000000
000500003d67015650126400f6400d6300c6200a62007620076200661004610016100060000600016000060000600006000060000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01110000291121f1002b120241002d1302e1302f13230120301203011030115301153011530115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002600023000200001b000194001c400214000b000184201f4202342021400184201f4202443021400184201f4202342000000184201f41024420244102441024410244102441024410244100000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100001e7151e7151e7151e7101e7101e7101e7101e7101e7151e7151e7151e7101e7101e7101e7101e7101d7151d7151d7151d7101d7101d7101d7101d7101d7151d7151d7151d7101d7101d7101d7101d710
01110000227152271522715227102271022710227102271022715227152271522710227102271022710227102071520715207152071020710207102071020710207152071520715207151b7201b7201b7301b734
011100000000000000160201902019020190201d0250000016030160320000000000190321903200000000000000000000140201802018020180201b025000001b0301b032000000000018032180320000000000
011100000000000000160201902019020190201d0250000000000000001602019020190201902022035000001b0321b0321b0321b0321b0321b0321a030190321803018020180201802018010180101801518000
011100001707316600166003061500000246150000000000170730000016600170730000000000000002461517073246150000000000246150000000000000001707300000000001707300000000002461524615
__music__
01 08404344
02 09424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 282a432c
02 292b432c
00 41424344
00 41424344
00 41424344
00 41424344
00 23244344

