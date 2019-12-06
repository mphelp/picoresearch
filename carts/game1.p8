pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- game 1 
-- by matthew phelps

-- page 1

-- the storyline
local textCol   = 5
local accentCol = 9
-- 1 blue, 9 orange
local storyline = {
    [0] = " ",
    [1] = "^5hi ^9lario!^l ^5good to see you!^l^lfunny running into you^loutisde the lushroom ^lkingdom.^l^lhey, i have a favor^lto ask...",
    [2] = "^5i tried talking your^lbrothers into fixing this ^lhere basement.^l^lsimple task, but oh so^lconveniently their^l^eprincess^5 needed saving^lagain.^l^ltypical...",
}
-- printc(text,x,y)
 -- by yellowafterlife (2015)
 -- introduces a function with
 -- formatting. supports:
 -- ^0..^f: set color
 -- ^l: linebreak
function printc(text,t,x,y)
  local l=x
  local s=7
  local o=1
  local i=1
  local n=#text+1
  while i<=n do
   local c=sub(t,i,i)
   if c=="^" or c=="" then
    i+=1
    local p=sub(t,o,i-2)
    print(p,l,y,s)
    l+=4*#p
    o=i+1
    c=sub(t,i,i)
    if c=="l" then
     l=x
     y+=6
    else
     for k=1,16 do
      if c==sub("0123456789abcdef",k,k) then
       s=k-1
       break
      end
     end
    end
   end
   i+=1
  end
 end

-- gstate: move, curs, beginzoom, zoomin, zoomed, rotate, zoomout
local gstate, glevel=0
local intro_timer = 0

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
    if (gstate == "title" or gstate == "title_anim") then 
        title_check()
    else if (gstate == "intro") then 
        intro_check()
    else 
        hammer_check()
        curs_check()
    end end 
end
handle_level_transitions = function()
    soln_string = ""
    if (curs.didrotate and is_solution_red() and is_solution_green()) then
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
    if (gstate == "title" or gstate == "title_anim") then
        cls(config.title_bgcolor)
        draw_title()
    else 
        if (gstate == "intro") then 
            cls(config.title_bgcolor)
            draw_intro()
        else 
            cls(config.bgcolor)
            draw_floor()
            draw_level()
            draw_hammer()
            draw_player()
            draw_border()
            draw_header()
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
    -- draw title
    map(gmap.title.x,gmap.title.y,0,0,16,16)
    spr(10,38,32,6,4)
    if (gstate == "title") then 
        print("press ❎ to start", 29, 80, 4)
    else 
        draw_player()
    end
end
draw_intro = function() 
    map(gmap.intro.x,gmap.intro.y,0,0,16,16)
    draw_player()
    draw_worm()
    print(intro_timer)
    draw_speech()
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
draw_worm = function()
    spr(worm.sprites[worm.frame],worm.x,worm.y)
    rectfill(worm.x+8,worm.y+7,worm.x+8,worm.y+7,3) -- green 3 tail
end
draw_speech_helper = function(ul,br,xoff,yoff,pal_c)
    if (worm.speech) then 
        if (pal_c == true) then 
            for i = 0,15 do pal(i,worm.speech_shadow) end
        end
        -- Draw speech bubble
        spr(gsprites.speech_corner,8*ul.x+xoff,8*ul.y+yoff)
        spr(gsprites.speech_corner,8*br.x+xoff,8*ul.y+yoff,1,1,true,false)
        spr(gsprites.speech_corner,8*ul.x+xoff,8*br.y+yoff,1,1,false,true)
        spr(gsprites.speech_corner,8*br.x+xoff,8*br.y+yoff,1,1,true,true)
        for i=ul.x+1,br.x-1 do 
            spr(gsprites.speech_edge_top,8*i+xoff,8*ul.y+yoff)
            spr(gsprites.speech_edge_top,8*i+xoff,8*br.y+yoff,1,1,false,true)
        end
        for j=ul.y+1,br.y-1 do 
            spr(gsprites.speech_edge_side,8*ul.x+xoff,8*j+yoff,1,1,true)
            spr(gsprites.speech_edge_side,8*br.x+xoff,8*j+yoff)
        end
        rectfill(8*ul.x+8+xoff,8*ul.y+8+yoff,8*br.x+xoff,8*br.y+yoff,7)
        pal()
        if (pal_c == false) then
            for i = 0,9 do 
                line(worm.x,worm.y-3,worm.x+i,worm.y-30,7)
            end
        end
    end
end
draw_speech = function()
    -- bubble
    local ul = {x = 1,y=1}
    local br = {x = ul.x+13,y=ul.y+8}
    draw_speech_helper(ul,br,3,2,true) -- shadow
    draw_speech_helper(ul,br,0,0,false)
    -- story
    if (worm.story > 0) then 
        local text = storyline[worm.story]
        printc(text,sub(text,1,worm.speech_frame),8*ul.x+6,8*ul.y+6)
        worm.speech_frame+=1
    end
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
shadow_spr_below_with = function(sprn, col) end
draw_header = function() 
    map()

end

-->8
-- page 3 (config)

config = {
	bgcolor = 0,
    title_bgcolor = 0,
    DEBUG = false,
    DEBUG_SOLN = false,
    SHOW_SOLN = true
}
-- g means global
gst = {
    [1] = { 
        r = { s = {x=33,y=12}, t = {x=46,y=11} },
        g = { },
    },
    [2] = {
        r = { s = {x=50,y=12}, t = {x=61,y=8} },
        g = { },
    },
    [3] = {
        r = { },
        g = { s = {x=66,y=12}, t = {x=77,y=8} },
    },
    [4] = {
        r = { s = {x=82,y=13}, t = {x=93,y=8 } },
        g = { s = {x=82,y=7 }, t = {x=93,y=11} },
    }
}
gsprites = {
    border = 112,
    hammer = 65,
    hammer_bubble = 113,
    curs = 114,
    floor1 = 06,
    speech_corner = 214,
    speech_edge_top = 230,
    speech_edge_side = 246,
}
gmap = {
    border = {x = 112, y = 0},
    land = {x = 16,y = 0},
    title = {x = 0, y = 0},
    intro = {x = 16, y = 0},
    -- levels
    [0] = {x = 16, y = 0},
    [1] = {x = 32, y = 0},
    [2] = {x = 48, y = 0},
    [3] = {x = 64, y = 0},
    [4] = {x = 80, y = 0},
}
pl = {
    x = -16,
    y = 104,
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
worm = {
    x = 30, 
    y = 104,
    animtimer = 0,
    animlength = 18,
    sprites = {
        inch1 = 199,
        inch2 = 198,
    },
    frame = 'inch1',
    speech = false,
    story = 0,
    speech_shadow = 5,
    speech_frame = 0,
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
        if (bnp('z') or bnp('x')) then
            gstate = "title_anim"
        end
    else if (gstate == "title_anim") then 
        pl_update_walk()
        if ((bnp('z') or bnp('x')) or (pl.x > 130 and pl.x < 140)) then 
            gstate = "intro"
            pl.x = -10
        end
    end
    end
end
intro_check = function()
    if (gstate == "intro") then 
        intro_timer = intro_timer + 1

        if (intro_timer < 20) then 
            pl_update_walk()
        else if (btw(intro_timer,20,30)) then 
            pl.frame = 'rest'
        else 
            -- Speech
            worm.speech = true
            worm_update_inch()
            if (intro_timer == 80 or intro_timer == 300) then 
                worm.speech_frame = 0
                worm.story = worm.story + 1
            end 
        end end 
        -- level
        if ((bnp('z') or bnp('x')) or intro_timer > 3000) then
            gstate = "move"
            glevel = 1
            --glevel = 1
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
is_solution_red = function()
    debug_string = ""
    -- null check
    if (gst[glevel].r.s == nil or gst[glevel].r.t == nil) then 
        return true
    end 
    local x, y = gst[glevel].r.s.x+1, gst[glevel].r.s.y 
    -- red: 1 right side, 2 bottom side, 4 left side, 8 top side
    -- green: 16, 32, 64, 128 (unfinished)
    sol_dir = 2 -- left side
    while (not target_reached(x,y,true)) do 
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
is_solution_green = function()
    debug_string = ""
    -- null check
    if (gst[glevel].g.s == nil or gst[glevel].g.t == nil) then 
        return true
    end 
    local x, y = gst[glevel].g.s.x+1, gst[glevel].g.s.y 
    -- red: 1 right side, 2 bottom side, 4 left side, 8 top side
    -- green: 16, 32, 64, 128 (unfinished)
    sol_dir = 2 -- left side
    while (not target_reached(x,y,false)) do 
        curr_spr = mget(x,y)
        if (not is_pipe_spr(curr_spr)) then 
            return false
        else 
            green_fl = fget(curr_spr)
            dir = {}
            dir[0] = flr(shr(green_fl,4)) % 2
            dir[1] = flr(shr(green_fl,5)) % 2
            dir[2] = flr(shr(green_fl,6)) % 2
            dir[3] = flr(shr(green_fl,7)) % 2
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
target_reached = function(x,y,isRed)
    if (config.DEBUG_SOLN) target_string = "target: "..gst[glevel].t.x ..",".. gst[glevel].t.y
    if (isRed) then 
        return (x==gst[glevel].r.t.x) and (y==gst[glevel].r.t.y)
    else 
        return (x==gst[glevel].g.t.x) and (y==gst[glevel].g.t.y)
    end
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
worm_update_inch = function()
    worm.frame = next_worm_inch()
    worm_animtimer_incr()
end 
pl_update_walk = function()
    pl.x = pl.x+1
    pl.frame = next_pl_walk()
    pl_animtimer_incr()
end
worm_animtimer_incr = function()
    worm.animtimer = (worm.animtimer + 1)%(worm.animlength)
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
next_worm_inch = function()
    if (worm.animtimer >= worm.animlength/2) then
        return "inch1";
    else 
        return "inch2";
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
000000000000000000000700000000001666666111666611dd11dd116d6666d10000000000000000000000000000000000000000000000330000000000000000
00700700000007000000707000070007111611111161161111dd11dd66d66d110000000000000000000000000000000000000000000000030000000000000000
00077000000000000000070000000000111611111161111111dd11dd666dd1110000000000000000000000000000000000000000000000003000000000000000
000770000000000000000000000007001116111111666611dd11dd11666dd1110000000000000000000000033330033300000000000000003000000000000000
007007000000000000000000000000001116111111111611dd11dd1166d11d110000000000000000000003330033030300000000000000003000000000000000
00000000000000000000000000000000111611111161161111dd11dd6d1111d10000000000000000000003000003000300000000000000003000000000000000
00000000000000000000000000000000111111111166611111dd11ddd111111d0000000000000000000000330003000300000000000000003000000000000000
00288200000000000000000000288200002882000028820000000000002882000000000000000000000000300333000300000000003000003033000000003300
00288200000000000000000000288200002882000028820000000000002882000000000000000000000000333300003000300003333330003333033303333330
00288822000022222222000022888200222222222228822222222222002882000000000000000000000003300000003003300300333330033003330300330000
00288888000288888888200088888200888888888828828888888888002882000000000000000000000003000000030000303300303330033003333300300000
00028888002888888888820088882000888888888828828888888888002882000000000000000000000033000000030000303300303030033003300000300000
00002222002888222288820022220000222222222228822222222222002882000000000000000000000330000000333300333300303030030033300003000000
00000000002882000028820000000000002882000028820000000000002882000000000000000000000000000000330000330303303030030330300303000000
00000000002882000028820000000000002882000028820000000000002882000000000000000000000000000000000000000003003030030000333303000000
00133100000000000000000000133100001331000013310000000000001331000000000000000000000000000000000000000000000000000000000000000000
00133100000000000000000000133100001331000013310000000000001331000000000000000000000000000000000000000000000000000000000000000000
00133311000011111111000011333100111111111113311111111111001331000000000000000000000000088880000000000000000000000000000000000000
00133333000133333333100033333100333333333313313333333333001331000000000000000000000008880088800000000000000000000000000000000000
00013333001333333333310033331000333333333313313333333333001331000000000000000000000008080000880000000000800008000000000000000000
00001111001333111133310011110000111111111113311111111111001331000000000000000000000000080000080000000000080000800000000000000000
00000000001331000013310000000000001331000013310000000000001331000000000000000000000000080008880000000000088000800000000000000000
00000000001331000013310000000000001331000013310000000000001331000000000000000000000000088888000000000000008000800000000000000000
00288200002882000013310000133100001331000028820022222222222222220000000000000000000000080000000000000000008000800000000000000888
00288200002882000013310000133100001331000028820029999992229999220000000000000000000000080000080000000000080000808880800888800808
11288822228882112222331111332222222222221128821122292222229229220000000000000000000000080000088888088888088800808080088880800880
33288888888882338888233333328888888888883328823322292222229222220000000000000000000000880000080000080880080800808880080880800088
33328888888823338888823333288888888888883328823322292222229999220000000000000000000000800000880000800080080080808000080800800008
11332222222233112288821111288822222222221128821122292222222229220000000000000000000008800000800000888800080880808888080800808088
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000111011110000000001111000101001110000000000000000000000000000000010101010000000000000000000000000000000000000000000000000
00010000111011110000000011111101111101110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111111111110000000000000000000000000000000010101010000000000000000000000000000000000000000000000000
00000001111111100000000011111111111111110000000007900000007900000000000000000000000000000000000000000000000000000000000000000000
00000001111111100000000011111111111111110000000099900000099900000000000010101010000000000000000000000000000000000000000000000000
00000001111111100000000011111111111111110000000003300000003300000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000011111111111111110001001003300000003303330000000010101010000000000000000000000000000000000000000000000000
00010000111011110000000011111111111111110011101100333333000333030000000000000000000000000000000000000000000000000000000000000000
11111111001111100111000011111110011111111111111000000666000000000000000000000000000000000000000000000000000000000000000000000000
111011110111111011110011001111111111111111111100000067770000000000000000111dddd1111888810000000000000000000000000000000000000000
111111110111111111111111111111110011111111111111000677770000000000000000005dddd0002888800000000000000000000000000000000000000000
111111111111111111111111011111110111111111111110006777770000000000000000005dddd0002888800000000000000000000000000000000000000000
111111011111111111111111001111000011111111111111067777770000000000000000005dddd0002888000000000000000000000000000000000000000000
111111111111111111111111011111000111111111111110677777770000000000000000005dd500002222000000000000000000000000000000000000000000
11011111011111101011011101111110011111111111111067777777000000000000000000555500002222000000000000000000000000000000000000000000
01111111001100001010000101111110111111111111111167777777000000000000000000005500000222000000000000000000000000000000000000000000
11111111000000000000001100000000dddddddddddddddd66666666000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000011111000000d10111049111111d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000011111100110d01110049111110d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000111111111110d11100149111100d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000001111111111111d11001149111000d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000001111111111111d10011149110001d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000011111111111111d00111149100011d77777777000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000111111111111110d99999949999999d77777777000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd000000000111111111111111d44444449444444d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d119411d000000001111111111111111d11111149011110d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d119411d000000001111111111111100d11111049111101d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d449499d000000001111111111111110d11110049111010d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d999444d000000000111111111111110d11100049110101d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d119411d000000000111111111111000d11000149101011d77777776000000000000000000000000000000000000000000000000000000000000000000000000
d119411d000000000011101111100000d10001149010111d77777776000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd000000000000000100000000dddddddddddddddd77777776000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000903060c0f0f050a0000000000000000903060c0f0f050a00000000000000000693c96c3a55a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000d3000000000000d1000000d300000000000000f2d50000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048484848484848484848484848484848
0000d100000000000000000000f2d2f2000000000000d30000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
00000000000000000000c50000000000000000000000d1000000000000d100005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
d1000000000000000000f2e300000000000000000000000000000000000000005e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e0000000000000000000000000000000048000000000000000000000000000048
00000000e2c30000000000d3000000e2c4e300000000000000000000000000e26e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e6e6e6e6f6e6f6e6f6e6f6e6e6e6f6f6e0000000000000000000000000000000048000000000000000000000000000048
00000000f2f3000000d1e3f3000000f2e0f300000000000000000000000000f27e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f7e7f7f7f7e7f7e7f7e7f7f7e7e7f7e7f0000000000000000000000000000000048000000000000000000000000000048
c4e300000000000000e2d50000000000f30000000000000000d10000000000007d6d6d6d7d6d6d7d6d7d6d6d7d6d6d7d7d6d0707070707070707070707077d7d7d6d0707070707070707070707077d7d7d6d0707070707070707070707077d7d0000000000000000000000000000000048000000000000000000000000000048
e0d500000000000000f2d50000000000000000000000000000000000000000007d07070707070707070707070707076d7d7d0700000000111616161200077d6d7d7d0700002123002122002700077d6d7d7d0522000011161616161612077d6d0000000000000000000000000000000048000000000000000000000000000048
f2f30000e2e300000000d30000000000000000000000000000000000000000007d07000000000000000000000000077d7d6d0700000000000000001016366d7d7d6d0700002300212320262727046d7d7d6d0727000017000000000011366d7d0000000000000000000000000000000048000000000000000000000000000048
00000000f2d500000000d10000d100000000000000000000000000000000d1007d07000000130000000000000000076d7d6d0700001100111616161300077d6d7d6d0700000000270027002727077d6d7d6d0720220034000000000017077d6d0000000000000000000000000000000048000000000000000000000000000048
0000000000d3000000000000000000000000d1000000000000000000e2e300006d07000000001300000011120000076d6d7d0700001700170000000017077d6d6d7d0700002123270027000000077d6d6d7d0700202634262626262217077d6d0000000000000000000000000000000048000000000000000000000000000048
0000000000d300000000000000000000000000000000000000000000d4d500006d07000000000013161613101616366d6d6d0700001012130000000017076d6d6d6d0700002420272623000000076d6d6d6d0700000034000000002035046d6d0000000000000000000000000000000048000000000000000000000000000048
c3c4c3c3c4c3c4c4c4c3c4c3c3c4c3c4c3c4c3c3c4c3c4c4c4c3c4c3e0e0c3c47d37161200000017000000000000076d7d7d3716161613000000001113076d6d7d7d0525262300270000000000076d6d7d7d0700000017170000001113076d6d0000000000000000000000000000000048000000000000000000000000000048
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e07d07001016161613000000000000077d7d6d0700000000000000111300077d7d7d6d0700000000270000000000077d7d7d6d3716161613171616161300077d7d0000000000000000000000000000000048000000000000000000000000000048
00c50000000000000000000000000000000000000000000000000000000000006d07000000000000000000000000076d6d7d0700001016161616130000077d6d6d7d0700202626230000000000077d6d6d7d0700000000170000000000077d6d0000000000000000000000000000000048000000000000000000000000000048
d2f30000000000e2e3000000d1000000e2c4e300000000000000000000d100007d07070707070707070707070707077d7d6d0707070707070707070707076d7d7d6d0707070707070707070707076d7d7d6d0707070707070707070707076d7d0000000000000000000000000000000048484848484848484848484848484848
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0c0c0c0c0c0c0c0c0c0c0c0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0000000000000000000000000d0c0c0c0e1d1c1c1d1c1c0c0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d00000f2f2f2f2f2f200000000d0c0c0c0c1c1e1c2c3e1c0c0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d00000e0e0e0e0e00063000000d0f0c0c0e1c1c1c1c1d1c0c0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d00000f1f1d3f1f10000000000d0c0c0c0c0c0c0c0c0c0c0c0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d000000000d2d1e10000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0000000000000000000000000d000f1f1f1f1f10000d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0000000000000000000000000d000f1f1e4e5f10000d0c9c9c9d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000f1f1f4f5f10000d0c9c9c9d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000f1f1f1f1f10000d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

