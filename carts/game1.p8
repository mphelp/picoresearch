pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- plumber problems 
-- by matthew phelps

-- page 1

-- the storyline

local storyline = {
    [0] = " ",
    [1] = "^5hi ^9lario!^l ^5good to see you!^l^lfunny running into you^loutisde the lushroom ^lkingdom.^l^lhey, i have a favor^lto ask...",
    [2] = "^5i tried talking your^lbrothers into fixing this ^lhere basement.^l^lsimple task, but oh so^lconveniently their^l^eprincess^5 needed saving^lagain.^l^ltypical...",
    [3] = "^5but then i thought of^lyou, the^8 real^5 plumber.^l^lall i need is a patch job^lfor some burst pipes. ^lit's kind of a mess down^lhere but i know you're^lthe best in the business.^l^lyou up for the job? ^3\140^5",
    [4] = "^5fantastic! here's a^l^cscrewdriver^5 for your^ltoolset. ^l^lin case you've somehow^lforgotten how to fix^lpipes as a plumber...^l^l...let me remind you:",
    [5] = "^5move tool: \139 \145 \148 \131^l^lextract pipes: ^l  press \151 to extract, ^l  \139 \145 to rotate, ^l  \151 to place pipes back ^l^lcheck solution: press c^l^lreset: hold c",
    [6] = "^5if you didn't catch^lall that, i've^lleft you a manual^lat the top of your^lscreen for reference.",
    [7] = "^5thanks again ^9lario!^5^l^li can always count on you.^l^lman, you really are the^lbest brother. ^4the other ^ltwo should've stuck to ^ltheir day job...^5",
}
local storyline2 = {
    [0] = " ",
    [1] = "^5oh hi again!^l^li forgot to mention^lsomething...^l^l",
    [2] = "^5the pipes in each^lroom don't just require^la ^cscrewdriver^5.^l^lthey require ^dpliers^5 too^lif you want them^lproperly repaired.^l^loh look! a pair ^ljust materialized...",
    [3] = "^5bigger tool,^l bigger challenge.^l^lbut i know you^lcan do it. good luck^lwith the repairs!^l^li promise i've told^lyou everything...",
}
local storyline3 = {
    [0] = "",
    [1] = "^5...i lied.^l",
    [2] = "^5there's one final^ltool you need in^laddition to your^l^cscrewdriver^5 and ^dpliers^5:^l^la ^9hammer^5.",
    [3] = "^5it's your strongest tool^lyet and surely all ^83^5^ltools can fix these^lpipes for good.^l^lhere's hoping!^l^li owe you one buddy.",
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
local glevel_dynamic=0
local glevel_mode = 1
local intro_timer = 0
local intro_timer_static = 0
local original_pipes = {}
local BTN_C_HOLD = 0

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
local debug_string2=""
local soln_string = ""
local target_string = ""
local debug_story = ""
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

handle_beginning_transitions = function()
    if (gstate == "title" or gstate == "title_anim") then 
        title_check()
    else if (gstate == "intro" or gstate == "intro_anim") then 
        intro_check()
    else 
        move_anim_check()
        if (gstate != "end") then 
            mistake1_check() 
            mistake2_check() 
            animate_heater_cooler()
            move_check()
            jump_anim_check()
            curs_check()
    end end end
end
is_full_solution = function () 
    return is_solution_red() and is_solution_green() and curs.didrotate
end
handle_level_transitions = function()
    soln_string = ""
    if (gstate == "curs" and curs.didrotate 
        and is_solution_red() and is_solution_green() 
        and bnp('z')) then
            gstate = "jump_anim"
            --soln_string = "VALID SOLUTION!" 
            play_solution()
            --music(16, 0, 12)
    end
end
handle_global_effects = function()
    shake_camera()
end
function _update()
    handle_beginning_transitions()
    handle_level_transitions()
    handle_global_effects()
    if (gstate == "curs") then
        curs_check()
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
    elseif (gstate == "mistake1") then 
    elseif (gstate == "move_anim") then 
       

        --move_player()
        --pl_animtimer_incr()
        -- This is handled now in state trans
    elseif (gstate == "jump_anim") then 
    end
end

function _draw()
    debug_print(config.DEBUG)
    if (gstate == "end") then 
        draw_end()
    elseif (gstate == "title" or gstate == "title_anim") then
        cls(config.title_bgcolor)
        draw_title()
    else 
        if (gstate == "intro" or gstate == "intro_anim" 
            or gstate == "mistake1" or gstate == "mistake1_anim"
            or gstate == "mistake2" or gstate == "mistake2_anim") then 
            cls(config.title_bgcolor)
            
            --print('worm'..worm.story)
            --if (worm.speech) print ('speech')
            --print(gstate)
            --print(intro_timer)
            --print(debug_story)
            --print(glevel)
            --print(glevel_dynamic)
            draw_intro()
        else 
            cls(config.bgcolor)
            --draw_floor()
            draw_wall()
            draw_wall_moveable()
            draw_level()
            --draw_hammer()
            draw_player()
            --draw_border()
            draw_header()
            if (config.DEBUG_2) then 
                print(pl.frame,0,20)
                print(pl.animtimer,0,30)
                print(debug_string2)
                print(gstate)
            end 
            if (config.DEBUG_RESET) then 
                --cursor(0,20)
                --for key,value in pairs(original_pipes) do print(key..':'..value) end
                --print(debug_string,0,20) 
            end 
            debug_string2 = ""
            --print(gstate,0,20)
            if (gstate != "move") then
                cursor(0,20)
                print(debug_string)
                print(target_string)
                print(soln_string)
                if (gstate == "curs" or gstate == "move_anim" or gstate == "jump_anim") then
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
draw_wall = function()
    -- wall is at 0,16
    map(0,16,
        8*((gst[glevel].corner.x)%16),8*((gst[glevel].corner.y)%16),
        gst[glevel].width,gst[glevel].height)
end
draw_wall_moveable = function()
    -- wall moveable is at 0,24
    map(0,24,
        8*((gst[glevel].center.x)%16),8*((gst[glevel].center.y)%16),
        gst[glevel].wide,gst[glevel].tall)
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
draw_end = function() 
    cls(1)
    cursor(10,10)
    color(6)
    print("that's all of the game ")
    print("right now. but i'll \nbe adding more levels\nand a proper \nending soon.\n\n\n")
    print("thanks for playtesting! \140")
    print("\n- matt")
end 
draw_intro = function() 
    map(gmap.intro.x,gmap.intro.y,0,0,16,16)
    draw_screwdriver()
    draw_player()
    draw_worm()
    if (config.DEBUG) then 
        print(gstate)
        print(intro_timer)
        print(worm.story)
    end
    if (gstate == "mistake1") then 
        draw_speech(1)
    elseif (gstate == "mistake2") then 
        draw_speech(2)
    else draw_speech(0)
    end
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
draw_speech = function(mistake)
    -- bubble
    if (worm.speech) then 
        local ul = {x = 1,y=1}
        local br = {x = ul.x+13,y=ul.y+8}
        draw_speech_helper(ul,br,3,2,true) -- shadow
        draw_speech_helper(ul,br,0,0,false)
        -- story
        if (worm.story > 0) then 
            local text 
            if (mistake == 0) then 
                text = storyline[worm.story]
            elseif (mistake == 1) then 
                text = storyline2[worm.story]
            elseif (mistake == 2) then
                text = storyline3[worm.story] 
            end
            printc(text,sub(text,1,worm.speech_frame),8*ul.x+6,8*ul.y+6)
            worm.speech_frame+=1
            if (worm.speech_frame < #text) then -- worm talking 
                local r = rnd(80)
                if (btw(r,1,4)) then sfx(39) end
                if (btw(r,5,8)) then sfx(38) end
                if (btw(r,9,12)) then sfx(37) end 
                if (btw(r,13,16)) then sfx(40) end
            end 
            if (worm.speech_frame > #text + 20) then -- show continue
                print('❎',8*br.x-5,8*br.y-3,5)
            end
        end
    end
end
draw_screwdriver = function()
    if (pl.x == 62) then 
        sfx(7)
    elseif (pl.x < 62) then 
        pl.screwdriver_anim = 0
        if (((gstate == "intro" or gstate == "intro_anim") and btw(intro_timer,1430,2960))
            or ((gstate == "mistake1" or gstate == "mistake1_anim") and btw(intro_timer,680,1900))
            or ((gstate == "mistake2" or gstate == "mistake2_anim") and btw(intro_timer,680,1900))) then 
            if (curs.mode == 3) then 
                spr(pl.tool_sprite[curs.mode],128/2-8,96,2,2)
            else 
                spr(pl.tool_sprite[curs.mode],128/2-4,96,1,2)
            end
        end
    else
        pl.screwdriver_anim+=.75
        if (pl.screwdriver_anim < 12) then 
            circ(128/2,103+3,pl.screwdriver_anim,rnd(15))
        end
    end
end
draw_hammer = function()
    spr(gsprites.hammer, 54, 24, 2, 2)
    spr(gsprites.hammer_bubble, 50, 14)
end
draw_curs = function()
    local sprite, color
    if (curs.mode == 1) then 
        sprite = gsprites.curs1
        color = 12
    elseif (curs.mode == 2) then
        sprite = gsprites.curs2
        color = 13
    elseif (curs.mode == 3) then 
        sprite = gsprites.curs3
        color = 9
    end 
    spr(sprite, curs.sx+(curs.mode-1)*4, curs.sy+(curs.mode-1)*4)
    draw_curs_box(1,8*curs.mode,color)
end
draw_curs_box = function(n1, n2,color)
    rectfill(curs.sx-n1, curs.sy-n1, curs.sx-n1, curs.sy+n2, color)
    rectfill(curs.sx-n1, curs.sy-n1, curs.sx+n2, curs.sy-n1, color)
    rectfill(curs.sx+n2, curs.sy+n2, curs.sx+n2, curs.sy-n1, color)
    rectfill(curs.sx+n2, curs.sy+n2, curs.sx-n1, curs.sy+n2, color)
end
shadow_spr_below_with = function(sprn, col)
end
draw_header = function() 
    -- header base
    local hh = 13
    header_breaks = {22,48,72,91}
    rectfill(header_breaks[1],0,127,hh,gcolors.header)
    for i = 0,15 do 
        spr(207,i*8,hh-3)
    end
    fillp(0b1111000011110000.1)
    rectfill(0,0,127,hh,gcolors.header_shadow)
    fillp()
    rectfill(0,0,127,0,gcolors.header_shadow)
    rectfill(0,0,0,hh,gcolors.header_shadow)
    rectfill(127,0,127,hh,gcolors.header_shadow)
    -- draw subheaders
    rectfill(header_breaks[1]+1,0,header_breaks[1]+1,hh,gcolors.header_shadow)
    rectfill(1,1,header_breaks[1],hh,gcolors.header)
    for i=1,#header_breaks-1 do 
        rectfill(header_breaks[i]+2,1,header_breaks[i+1],hh,gcolors.header)
    end
    rectfill(header_breaks[#header_breaks]+2,1,126,hh,gcolors.header)
    -- draw labels
    -- label 1
    print("LVL",3,3,gcolors.header_text)
    rectfill(3,9,13,9,gcolors.header_text)
    rectfill(3,11,20,11,gcolors.header_text)
    print_shadow(glevel,header_breaks[1]-5,4,gcolors.header_text)
    -- control label
    print("how",header_breaks[1]+3,2,gcolors.header_text)
    print("to",header_breaks[1]+17,2,gcolors.header_text)
    print("\nplay",header_breaks[1]+3,2,gcolors.header_text)
    spr(255,header_breaks[1]+19,12)
    -- move cursor label
    spr(205,header_breaks[2],-2,2,2)
    spr(238,header_breaks[2]+17,4)
    -- rotate label
    spr(223,header_breaks[3]+3,-1,1,2)
    spr(254,header_breaks[3]+12,7) -- keys
    spr(237,header_breaks[3]+12,2) -- x
    -- check sol and reset
    print("finish\nreset",header_breaks[4]+3,2)
    spr(253,119,2)
    rectfill(114,9,125,11,gcolors.header_text)
    --rectfill(115,10,124,10,10)
    rectfill(115,10,124,10,gcolors.header_shadow)
    if (BTN_C_HOLD > 15) then 
        rectfill(115,10,114+BTN_C_HOLD/10,10,10) -- RESET
    end
end
print_shadow = function(text,x,y,color) 
    print(text,x+1,y,0)
    print(text,x-1,y,0)
    print(text,x,y-1,0)
    print(text,x,y+1,0)
    print(text,x,y,color)
end

-->8
-- page 3 (config)

config = {
	bgcolor = 0,
    title_bgcolor = 0,
    DEBUG = false,
    DEBUG_SOLN = false,
    SHOW_SOLN = false,
    DEBUG_INTRO = false,
    SKIPTOLEVEL = false,
    skip_level = 1,
    DEBUG_RESET = false,
    DEBUG_2 = false,
    SKIPTOEND = false
}
-- g means global
gst = {
    [0] = {
        r = { s = {x=0,y=0}, t = {x=0,y=0} },
        g = { },
    },
    [1] = { 
        r = { s = {x=34,y=23}, t = {x=45,y=22} },
        g = { },
        corner = {x=35,y=20}, height = 8, width = 10,
        center = {x=38,y=22}, wide = 4, tall = 3
    },
    [2] = {
        r = { s = {x=50,y=9}, t = {x=61,y=5} },
        g = { },
        corner = {x=51,y=4}, height = 8, width = 10,
        center = {x=54,y=6}, wide = 4, tall = 3
    },
    [3] = {
        r = { },
        g = { s = {x=66,y=9}, t = {x=77,y=5} },
        corner = {x=67,y=4}, height = 8, width = 10,
    },
    [4] = {
        r = { s = {x=82,y=10}, t = {x=93,y=5 } },
        g = { s = {x=82,y=4 }, t = {x=93,y=8} },
        corner = {x=83,y=4}, height = 8, width = 10,
    }
}
gsprites = {
    border = 112,
    hammer = 65,
    hammer_bubble = 113,
    curs1 = 219,
    curs2 = 235,
    curs3 = 251,
    floor1 = 06,
    speech_corner = 230,
    speech_edge_top = 247,
    speech_edge_side = 246,
    placable = 202,
    source_heater = { [0] = 40,[1] = 8,[2] = 24 },
    target_heater = { [0] = 41,[1] = 9,[2] = 25 },
    source_cooler = { [0] = 3, [1] = 3,[2] = 3,[3] = 3,
        [4] = 3,[5] = 3,[6] = 3,[7] = 3,[8] = 3, [9] = 3,[10] = 3,[11] = 3, 
        [12] = 4,[13] = 5,[14] = 6,[15] = 7},
    target_cooler = { [0] = 2 }
}
gmap = {
    border = {x = 112, y = 0},
    land = {x = 16,y = 0},
    title = {x = 0, y = 0},
    intro = {x = 16, y = 0},
    -- levels
    [0] = {x = 16, y = 0},
    [1] = {x = 32, y = 16},
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
    frame = 'rest',
    jump_acc = .5,
    jump_speed = 0,
    jump_yet = false,
    jump_count = 0,
    screwdriver_anim = 0,
    tool_sprite = {
        [1] = 64,
        [2] = 67,
        [3] = 65,   
    }
}
worm = {
    x = 30, 
    y = 104,
    animtimer = 0,
    animlength = 18,
    sprites = {
        inch1 = 229,
        inch2 = 228,
    },
    frame = 'inch1',
    speech = false,
    story = 0,
    speech_shadow = 5,
    speech_frame = 0,
    continue = false, -- x button to continue listening
    speech_intervals = {65,500,800,1400,1700,2300,2500,2800,2930},
    speech_intervals2 = {65,500,1300,1800,2050},
    speech_intervals3 = {65,500,1300,1800,2050}
}
curs = {
	sx = 6*16, -- pixel on screen
	sy = 6*16,
	bx = 6, -- block on screen
	by = 6,
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
gcolors = {
    header = 8,
    header_base = 1,
    header_shadow = 2,
    header_text = 6,
    header_text2 = 7
}
heater_cooler = {
    h = { animlength = 3, i = 0},
    c = { animlength = 16, i = 0}
}

-->8
-- page 4 (updating)

-- State transitions:
title_check = function()
    if (gstate == "title") then
        if (bnp('z') or bnp('x')) then
            if (config.SKIPTOEND) then 
                gstate = "end"
            elseif (config.SKIPTOLEVEL) then 
                gstate = "move"
                glevel = config.skip_level
                --intro_timer = worm.speech_intervals[#worm.speech_intervals]-1
            else 
                gstate = "title_anim"
            end
        end
    else 
        pl_update_walk(1)
        if ((bnp('z') or bnp('x')) or (pl.x > 130 and pl.x < 140)) then 
            gstate = "intro"
            pl.x = -10
        end
    end
end
mistake1_check = function() 
    if (gstate == "move_anim") then 
        intro_timer = 0
        intro_timer_static = 0
        worm.story = 0
        worm.speech = false
        worm.x = 30
    else
        intro_timer += 1
        if (gstate == "mistake1") then 
            intro_timer_static += 1
            if (intro_timer_static < 28) then 
                pl_update_walk(1)
            end
            if (btw(intro_timer_static,28,30)) then 
                pl.frame = 'rest'
                music(-1,500)
            end
            if (intro_timer > 30 or worm.story == 1) then 
                -- Speech
                worm.speech = true
                worm_update_inch()
                if (intro_timer == worm.speech_intervals2[worm.story+1]) then 
                    worm.speech_frame = 0
                    worm.story += 1
                end 
            end 
            if (bnp('z') or bnp('x')) then
                worm.story += 1 
                worm.speech_frame = 0
                intro_timer = worm.speech_intervals2[worm.story] 
            end -- advance/continue dialogue
            if (intro_timer == worm.speech_intervals2[#worm.speech_intervals2-1]) then 
                worm.speech = false
                gstate = "mistake1_anim"
            end
        elseif (gstate == "mistake1_anim") then --intro_anim
            worm.x -= 1
            worm_update_inch()
            pl_update_walk(1)
            if (intro_timer == worm.speech_intervals2[#worm.speech_intervals2]) then  
                gstate = "move"
                --glevel_dynamic = 1
                --glevel = 1
                pl.x = -10
                play_bridge() -- for now
                -- pipes
                store_pipes()
            end
        end
    end
end
mistake2_check = function() 
    if (gstate == "move_anim") then 
        intro_timer = 0
        intro_timer_static = 0
        worm.story = 0
        worm.speech = false
        worm.x = 30
    else
        intro_timer += 1
        if (gstate == "mistake2") then 
            intro_timer_static += 1
            if (intro_timer_static < 28) then 
                pl_update_walk(1)
            end
            if (btw(intro_timer_static,28,30)) then 
                pl.frame = 'rest'
                music(-1,500)
            end
            if (intro_timer > 30 or worm.story == 1) then 
                -- Speech
                worm.speech = true
                worm_update_inch()
                --debug_story = intro_timer
                --if (debug_story > 65) then stop() end 
                --if (intro_timer == worm.speech_intervals3[worm.story+1]) then 
                --debug_story = worm.speech_intervals3[worm.story+1]..'interval'
                -- It seems like intro_timer is skipping numbers somehow
                if (btw(intro_timer,worm.speech_intervals3[worm.story+1],worm.speech_intervals3[worm.story+1]+2)) then
                    worm.speech_frame = 0
                    worm.story += 1
                    --debug_story = 'story'..worm.story
                end 
            end 
            if (bnp('z') or bnp('x')) then
                worm.story += 1 
                worm.speech_frame = 0
                intro_timer = worm.speech_intervals3[worm.story] 
            end -- advance/continue dialogue
            if (intro_timer == worm.speech_intervals3[#worm.speech_intervals3-1]) then 
                worm.speech = false
                gstate = "mistake2_anim"
            end
        elseif (gstate == "mistake2_anim") then --intro_anim
            worm.x -= 1
            worm_update_inch()
            pl_update_walk(1)
            if (intro_timer == worm.speech_intervals3[#worm.speech_intervals3]) then  
                gstate = "move"
                --glevel_dynamic = 1
                --glevel = 1
                pl.x = -10
                play_bridge() -- for now
                -- pipes
                store_pipes()
            end
        end
    end
end
intro_check = function()
    intro_timer = intro_timer + 1
    if (gstate == "intro") then 

        intro_timer_static = intro_timer_static + 1

        if (intro_timer_static < 28) then 
            pl_update_walk(1)
        end
        if (btw(intro_timer_static,28,30)) then 
            pl.frame = 'rest'
        end
        if (intro_timer > 30 or worm.story == 1) then 
            -- Speech
            worm.speech = true
            worm_update_inch()
            if (intro_timer == worm.speech_intervals[worm.story+1]) then 
                worm.speech_frame = 0
                worm.story += 1
            end 
        end 
        if (bnp('z') or bnp('x')) then
            worm.story += 1 
            worm.speech_frame = 0
            intro_timer = worm.speech_intervals[worm.story] 
        end -- advance/continue dialogue
        if (intro_timer == worm.speech_intervals[#worm.speech_intervals-1]) then 
            worm.speech = false
            gstate = "intro_anim"
        end
    elseif (gstate == "intro_anim") then --intro_anim
        worm.x -= 1
        worm_update_inch()
        pl_update_walk(1)
        if (intro_timer == worm.speech_intervals[#worm.speech_intervals]) then  
            gstate = "move"
            glevel_dynamic = 1
            glevel = 1
            pl.x = -10
            play_bridge() -- for now
            pl.x = -10
            -- pipes
            store_pipes()
        end
    end
end
animate_heater_cooler = function()
    heater_cooler.h.i = (heater_cooler.h.i + 1/4)%heater_cooler.h.animlength
    heater_cooler.c.i = (heater_cooler.c.i + 0.2)%heater_cooler.c.animlength
    if (gst[glevel].r.s != nil) then -- red source heater
        local i = flr(heater_cooler.h.i)
        mset(gst[glevel].r.s.x,gst[glevel].r.s.y,gsprites.source_heater[i])
    end 
    if (gst[glevel].g.s != nil) then -- green source cooler
        local i = flr(heater_cooler.c.i)
        mset(gst[glevel].g.s.x,gst[glevel].g.s.y,gsprites.source_cooler[i])
    end
    if (gstate == "move_anim" or gstate == "jump_anim") then
        if (gst[glevel].r.t != nil) then -- red target heater
            local i = flr(heater_cooler.h.i)
            mset(gst[glevel].r.t.x,gst[glevel].r.t.y,gsprites.target_heater[i])
        end 
        if (gst[glevel].g.t != nil) then -- green target cooler
            mset(gst[glevel].g.t.x,gst[glevel].g.t.y,gsprites.target_cooler[0])
        end 
    end
end
move_check = function()
    if (gstate == "move") then 
        if (pl.x < 20) and not is_full_solution() then 
            pl_update_walk(1)
        else if (pl.x >= 20) and not is_full_solution() then 
            pl.frame = 'rest'
            gstate = "curs"
            curs.bx = 6
            curs.by = 6
        end end 
    end
    --if (pl.x > 48 and pl.x < 80 and btnp(5)) then
      --  if (gstate == "curs") then
      --      gstate = "move"
      --  elseif (gstate == "move") then
       --     gstate = "curs"
      --  end
    --end
end
jump_anim_check = function () 
    if (gstate == "jump_anim") then 
        if (pl.jump_count == 4) then 
            pl.jump_yet = false
            gstate = "move_anim"
            pl.jump_count = 0
        else 
            if (not pl.jump_yet) then
                pl.jump_speed = -4
                pl.jump_yet = true
                pl.jump_count += 1
                pl.frame = 'jump'
            else 
                pl.jump_speed += pl.jump_acc
                pl.y += pl.jump_speed
                if (pl.y >= (13*8)-3) then 
                    pl.y = 13*8
                    pl.frame = 'rest'
                    pl.jump_yet = false
                end
            end
        end
    end 
end
move_anim_check = function ()
    if (gstate == "move_anim") then 
        pl_update_walk(1)
        if (pl.x > 130) then 
            glevel_dynamic += 0.3334
            if (glevel != flr(glevel_dynamic)) then 
                glevel = flr(glevel_dynamic)
                store_pipes() -- ONLY IF NEW LEVEL
            else 
                glevel = flr(glevel_dynamic)
            end
            curs.mode = curs.mode % 3 + 1
            if (glevel == 1) then 
                if (curs.mode == 2) then 
                    gstate = "mistake1"
                elseif (curs.mode == 3) then 
                    gstate = "mistake2"
                end
            elseif (gstate != "end") then 
                gstate = "move"
            end 
            pl.x = -10
            -- pipes
            if (gstate != "end") then 
                reset_pipes()
                store_pipes()
            end
        end 
    end 
end 
btn_c_held = function() 
    if (bn('z')) then 
        BTN_C_HOLD+=1 
        if (BTN_C_HOLD == 110) return true
    else BTN_C_HOLD=0
        return false
    end
end
curs_check = function()
    if (gstate == "curs" and bnp('x') and curs_on_pipe()) then
        gstate = "beginzoom"
    elseif(gstate == "curs" and btn_c_held()) then 
        -- sound effect
        -- reset
        reset_pipes()
        BTN_C_HOLD = 0
    elseif(gstate == "beginzoom") then
        gstate = "zoomin"
    elseif (gstate == "zoomin" and curs.zoomInDone) then
        gstate = "zoomed"
    elseif (gstate == "zoomed" and (bnp('r') or bnp('l'))) then
        gstate = "rotate"
    elseif (gstate == "rotate" and curs.rotateDone) then
        gstate = "zoomed"
    elseif (gstate == "zoomed" and bnp('x')) then
        gstate = "zoomout"
    elseif (gstate == "zoomout" and curs.zoomOutDone) then
        gstate = "endzoom"
    elseif (gstate == "endzoom") then
        gstate = "curs"
    end
end
curs_on_pipe = function()
    pipe_located = false
    for i=curs.mapx , curs.mapx + curs.mode - 1 do -- MUST BE ONE PIPE
        for j=curs.mapy , curs.mapy + curs.mode - 1 do 
            pipe_located = pipe_located or is_pipe_spr(mget(i,j))
        end 
    end 
    return pipe_located
end
store_pipes = function()
    if (gst[glevel] == nil) then 
        gstate = "end"
    else 
        for i=gst[glevel].corner.x,gst[glevel].corner.x + gst[glevel].width-1 do
            original_pipes[i] = {}
            for j=gst[glevel].corner.y,gst[glevel].corner.y + gst[glevel].height-1 do
                local n = mget(i,j)
                original_pipes[i][j] = n
            end 
        end
    end     
end  
reset_pipes = function () 
    for i=gst[glevel].corner.x,gst[glevel].corner.x + gst[glevel].width-1 do
        for j=gst[glevel].corner.y,gst[glevel].corner.y + gst[glevel].height-1 do
            local n = original_pipes[i][j]
            mset(i,j,n)
        end 
    end
    -- reset targets
    if (gst[glevel].r.t != nil) then -- red target heater
        mset(gst[glevel].r.t.x,gst[glevel].r.t.y, 57)
    end 
    if (gst[glevel].g.t != nil) then -- green target cooler
        local i = flr(heater_cooler.c.i)
        mset(gst[glevel].g.t.x,gst[glevel].g.t.y, 56)
    end
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
            --if (config.DEBUG_SOLN) debug_string = debug_string .."next xy: "..x..","..y.."\n"
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
    --debug_string = debug_string .. "\nx is "..x.."\n"
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
                if (config.DEBUG_SOLN) debug_string = debug_string ..x..","..y.." go straight\n"
            elseif (dir[(sol_dir+1)%4] == 1) then 
                -- turn left
                if (config.DEBUG_SOLN) debug_string = debug_string ..x..","..y.." turn left\n"
                sol_dir = (sol_dir-1)%4
            elseif (dir[(sol_dir-1)%4] == 1) then 
                -- turn right
                if (config.DEBUG_SOLN) debug_string = debug_string ..x..","..y.." turn right\n"
                sol_dir = (sol_dir+1)%4
            end
            -- move x and y
            x += x_from_sol_dir(sol_dir)
            y += y_from_sol_dir(sol_dir)
            --if (config.DEBUG_SOLN) debug_string = debug_string .."next xy: "..x..","..y.."\n"
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
    -- FOR DEBUG: need to print both paths
    if (config.DEBUG_SOLN and gst[glevel].g.t != nil) then 
        target_string = "green target: "..gst[glevel].g.t.x ..",".. gst[glevel].g.t.y
    elseif (config.DEBUG_SOLN and gst[glevel].r.t != nil) then 
        target_string = "red target: "..gst[glevel].r.t.x ..",".. gst[glevel].r.t.y
    end
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
    local sc = {x = 6, y = 6, w = 4-curs.mode, h = 3-curs.mode} -- should come from gst but this is temp
	if(btnp(0) and btw(curs.bx,sc.x+1,sc.x+sc.w)) then 
		curs.bx -= 1
	elseif(btnp(1) and btw(curs.bx,sc.x,sc.x+sc.w-1)) then 
		curs.bx += 1
	elseif(btnp(2) and btw(curs.by,sc.y+1,sc.y+sc.h)) then 
		curs.by -= 1
	elseif(btnp(3) and btw(curs.by,sc.y,sc.y+sc.h-1)) then 
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
pl_update_walk = function(speed)
    pl.x = pl.x+speed
    debug_string2 = debug_string2.. "\nbefore "..pl.frame
    pl.frame = next_pl_walk()
    debug_string2 = debug_string2.. "\nafter "..pl.frame
    pl_animtimer_incr()
end
worm_animtimer_incr = function()
    worm.animtimer = (worm.animtimer + 1)%(worm.animlength)
end
pl_animtimer_incr = function()
    pl.animtimer = (pl.animtimer + 1)%(pl.animlength)
end
next_pl_walk = function()
    debug_string2 = debug_string2.. "\nin function pl walk"
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
-- functions below written and created by "freds72"
-- link to his post:
-- https://www.lexaloffle.com/bbs/?pid=52525#p
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
local cam_focal=1/8
function project(x,y,z,cx,cy)
	local w=cam_focal/(cam_focal+z)
 return cx+x*w,cy-y*w,z,w
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
-- tommy krug 2
-- edward atkinson 9
-- jacob naatz 15
-- chris enabnit 12
-- jack bao 10
-- njin 8
-- ramzi 3/11

-->8
-- page (8) MUSIC
play_bridge = function()
    music(10) -- channels 1-3, 0 is sfx
end
play_solution = function() 
    sfx(35)
end



__gfx__
00000000010101010011111111111100111111001111110011111100111111001111110000111111000000000000000000000000000000000000000000000000
0000000000010000101000011000010110000101100001011000010110c001011008010110108001000000000000000000000000000000330000000000000000
007007001111111116100001100001611000016110000161100001611000c1611000016116100001000000000000000000000000000000030000000000000000
0007700000000001161000011000016110000161100001611ccc0161100001611080816116180801000000000000000000000000000000003000000000000000
0007700001010101161cccc11cccc1611cccc1611c6cc1611cccc1611cccc1611888016116108881000000033330033300000000000000003000000000000000
0070070000000001161cccc11cccc1611cc6c1611cccc1611cccc1611cccc1611899816116189981000003330033030300000000000000003000000000000000
0000000011111111101cccc11cccc1011cccc1011cccc1011cccc1011cccc101199a91011019a991000003000003000300000000000000003000000000000000
00000000000100000011111111111100111111001111110011111100111111001111110000111111000000330003000300000000000000003000000000000000
00288200000000000000000000288200002882000028820000000000002882001111110000111111000000300333000300000000003000003033000000003300
00288200000000000000000000288200002882000028820000000000002882001000810110180001000000333300003000300003333330003333033303333330
00288822000022222222000022888200222222222228822222222222002882001800016116100081000003300000003003300300333330033003330300330000
00288888000288888888200088888200888888888828828888888888002882001000016116100001000003000000030000303300303330033003333300300000
00028888002888888888820088882000888888888828828888888888002882001088816116188801000033000000030000303300303030033003300000300000
00002222002888222288820022220000222222222228822222222222002882001889916116199881000330000000333300333300303030030033300003000000
0000000000288200002882000000000000288200002882000000000000288200199a91011019a991000000000000330000330303303030030330300303000000
00000000002882000028820000000000002882000028820000000000002882001111110000111111000000000000000000000003003030030000333303000000
003bb3000000000000000000003bb300003bb300003bb30000000000003bb3001111110000111111000000000000000000000000000000000000000000000000
003bb3000000000000000000003bb300003bb300003bb30000000000003bb3001000010110100001000000000000000000000000000000000000000000000000
003bbb33000033333333000033bbb30033333333333bb33333333333003bb3001008016116108001000000088880000000000000000000000000000000000000
003bbbbb0003bbbbbbbb3000bbbbb300bbbbbbbbbb3bb3bbbbbbbbbb003bb3001008816116188001000008880088800000000000000000000000000000000000
0003bbbb003bbbbbbbbbb300bbbb3000bbbbbbbbbb3bb3bbbbbbbbbb003bb3001089816116189801000008080000880000000000800008000000000000000000
00003333003bbb3333bbb3003333000033333333333bb33333333333003bb3001899916116199981000000080000080000000000080000800000000000000000
00000000003bb300003bb30000000000003bb300003bb30000000000003bb300199a91011019a991000000080008880000000000088000800000000000000000
00000000003bb300003bb30000000000003bb300003bb30000000000003bb3001111110000111111000000088888000000000000008000800000000000000000
0028820000288200003bb300003bb300003bb3000028820022222222222222220011111100111111000000080000000000000000008000800000000000000888
0028820000288200003bb300003bb300003bb3000028820029999992229999221010000110100001000000080000080000000000080000808880800888800808
33288822228882332222bb3333bb2222222222223328823322292222229229221610000116100001000000080000088888088888088800808080088880800880
bb288888888882bb88882bbbbbb2888888888888bb2882bb22292222229222221610000116100001000000880000080000080880080800808880080880800088
bbb2888888882bbb888882bbbb28888888888888bb2882bb22292222229999221610000116100001000000800000880000800080080080808000080800800008
33bb22222222bb332288823333288822222222223328823322292222222229221610000116100501000008800000800000888800080880808888080800808088
003bb300003bb3000028820000288200003bb300002882002229222222922922101c0cc110105051000008000000800000000000888808800000000000808880
003bb300003bb3000028820000288200003bb3000028820022222222229992220011111100111111000000000000000000000000800000000000000000000000
00000000000000111000100000600600000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666
00000000000111667111710006600660000000000000000000000000000000000000000000000000000000000000000000000000699999666966666669999666
00000000001666666161610006600660000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669666666
00000000016666666161610000600600000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669666666
00000000166661111111610000a66a00000000000000000000000000000000000000000000000000000000000000000000000000666966666966666669996666
0000000016111199100010000dd00dd0000000000000000000000000000000000000000000000000000000000000000000000000666966666999996669666666
0000000001000199100000000dd00dd0000000000000000000000000000000000000000000000000000000000000000000000000666966666666666669999966
0000000000000199100000000dd00dd0000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666
000000cc00000199100000000dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc66666666
00000ccc00000199100000000dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc66696666
0000cccc00000199100000000dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000007000cccccccc66696666
000cccc00000019910000000dd0000dd0000000000000000000000000000000000000000000000000000000000000000000000000007a700cccccccc66696666
0005c0000000019910000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000337000cccccccc66696666
006000000000019910000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000300000cccccccc66696666
060000000000019910000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000330000cccccccc66666666
600000000000001100000000dd0000dd00000000000000000000000000000000000000000000000000000000000000000000000000300000cccccccc66666666
0000000000000000000000000099700000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
0099700000997000009970000099990000000000000000000000000000000000000000000000000000000000000000000000000044444494cccccccccccccccc
0099990000999900009999000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
00fff00000fff00000fff00000fff00000000000000000000000000000000000000000000000000000000000000000000000000044944444cccccccccccccccc
00eff00000eff00000eff0000feff00000000000000000000000000000000000000000000000000000000000000000000000000044444444cccccccccccccccc
00eea0000feea0000feea00000eea00000000000000000000000000000000000000000000000000000000000000000000000000044444444ccccc3cccccccccc
00fee00000eeed000deee0000deeed0000000000000000000000000000000000000000000000000000000000000000000000000044449444ccccc3cccccccccc
00d0d00000d000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444c3ccc3ccc3ccccc3
66666666077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333333333333
66666666776666670600006000000000000000000000000000000000000000000000000000000000000000000000000000000000449444443333333333333333
66666666766161660060060000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443339333333333393
66666666766616660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333339333333
66666666766161660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000494444443333333333333333
66666666076666670060060000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333339333339333
66666666000077700600006000000000000000000000000000000000000000000000000000000000000000000000000000000000444444943933333333333333
66666666000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444443333333333333333
00000000000000000000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00010000000100000001000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000
00010000000100000001000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000
11111111111111111111111100000000000000000000000000000000000000000000000011111111000000000000000000000000000000000000000000000000
00000001000000011111111100000000000000000000000000000000000000000000000000000001000000000000000000000000000000000600000000000000
00000001000000011111111100000000000000000000000000000000000000000000000000000001000000000000000000000000000000006660000022222222
00000001000000011111111100000000000000000000000000000000000000000000000000000001000000000000000000000000000000066666000002020202
11111111111111111111111100000000000000000000000000000000000000000000000011111111000000000000000000000000000000000600000020202020
00010000111111111111111100000000000000000000000000000000000000000000000000011111000000000000000000000000000006000000060000000000
01101000001111100111000011111110011111110000000000000000000000000001000011111111111111110000000000000000000066006660066000000000
111111010111111011110011001111111111111100000000000000000000000000010000000dddd0100888800c0000c000000000000666606060666600000000
111111110111111111111111111111110011111100000000000000000000000011111111115dddd11128888100c00c0000000000000066006660066000060000
111111111111111111111111011111110111111100000000000000000000000000000001115dddd1112888810000000000000000000006000000060000066000
111111111111111111111111001111000011111100000000000000000000000000000001115dddd1112888110000000000000000000000000600000006666600
111111111111111111111111011111000111111100000000000000000000000000000011115dd5111112221100c00c0000000000000000066666000060066000
11111111011111101011011101111110011111110000000000000000000000001111111111555511111122110c0000c000000000000000006660000060060060
11111111001100001010000101111110111111110000000000000000000000000011000011115511111111110000000000000000000000000600000060000006
111111110000000000000011000000000000000000000000000000060c0cc0000001000011111111000111110000000011111110066666000000000060000006
11111111000000000000011111000000000000000000000000006667000000000011000011111111000111110d0000d011111100661616600007700006006006
1111111100000001000001111110011000000000000000000006777700000000111111111111ee111111111100d00d0011111111666166600007700000066006
11111111000000010000111111111110079000000079000000677777000000000000001111eeddd1111111110000000011111110661616600777777000666660
1111111100000001000111111111111199900000099900000677777700000000000000011e2222dd111111110000000011111111066666000777777000066000
1111111100000001000111111111111103300000003300000677777700000000000000014444422d1111111100d00d0011111110000000000555555000006000
1111111100011111001111111111111103300000003303330677777700000000111111114339999d111111110d0000d011111110000000000000000000000000
11111111000100000111111111111110003333330003330367777777000000000001000013333331111111110000000011111111000000000000000000000000
00010000000000000111111111111111000000000001000177777776666666661145111100011111111100000000000000111100066660000000000006060600
00010000000000001111111111111111000000000010001077777776777777771145111100011111111100000900009011111110661166000007700000000000
11111111000000001111111111111100000000000000010077777776777777771141511111111111111111110090090011111111661666000007700000000000
00000001000000001111111111111110000000000000000077777776777777771411511111111111111111110000000011111111661166000777777000000000
00000001000000000111111111111110000000000000000077777776777777771411151111111111111111110000000011111111066660000777777000000000
00000001000000000111111111111000000000000000000077777776777777771411151111111111111111110090090011111111000000000555555000000000
11111111111100000011101111100000000100100000000077777776777777771dd1122111111111111111110900009011111111000000000000000000000000
1111000000010000000000010000000000111011000000007777777677777777dddd222211111111111111110000000011111111000000000000000000000000
__label__
00000000000000001111111000000000000000000000000000000000000000000000000000111110000000000000000000000000111111100000000000000000
00000000000000000011111100000000000000000000000000000000000000000000000001111110000000000000000000000000001111110000000000000000
00000000000000001111111100000000000000000000000000000000000000000000000001111111000000000000000000000000111111110000000000000000
00000000000000000111111100000000000000000000000000000000000000000000000011111111000000000000000000000000011111110000000000000000
00000000000000000011110000000000000000000000000000000000000000000000000011111111000000000000000000000000001111000000000000000000
00000000000000000111110000000000000000000000000000000000000000000000000011111111000000000000000000000000011111000000000000000000
00000000000000000111111000000000000000000000000000000000000000000000000001111110000000000000000000000000011111100000000000000000
00000000000000000111111000000000000000000000000000000000000000000000000000110000000000000000000000000000011111100000000000000000
00000000000000000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000011111110111000001111111
00000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111001111111111
00000000000000000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111111111111
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111101111111
00000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111101111111
00000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000001110111011011100111011
00000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011010000100000001
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000001110110000000000000000000000000000000000000000
00111110000000000000000000000000000000000000000000000000000000000000000000000000011111110000000000000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000111111111100000000000000000000000000000000000000
01111111000000000000000000000000000000000000000000000000000000000000000000000000111111111110011000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000111111111111111000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000011111111111111100000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000011111111111111100000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000001110111111111100000000000000000000000000000000
00110000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111000000000000000000000000000000000
00000000000000000000000000000000000000110011110000000000000000000000000000000000000000001111111000000000000000000000000000000011
00000000000000000000000000000000000001111111111000000000000000000000330000000000000000000011111100000000000000000000000000000111
00000000000000000000000000000000000001111111111100000000000000000000030000000000000000001111111100000000000000000000000000000111
00000000000000000000000000000000000011111111111100000000000000000000003000000000000000000111111100000000000000000000000000001111
00000000000000000000000000000000000111111111133330033300000000000000003000000000000000000011110000000000000000000000000000011111
00000000000000000000000000000000000111111113331133030300000000000000003000000000000000000111110000000000000000000000000000011111
00000000000000000000000000000000001111111113111103000300000000000000003000000000000000000111111000000000000000000000000000111111
00000000000000000000000000000000011111111111331103000300000000000000003000000000000000000111111000000000000000000000000001111111
00000000000000000000000000000000011111111111311333000300000000003000003033111110003300001111111100000000000000000000000001111111
00000000000000000000000000000000111111111111333300003000300003333330003333133313333330001111111100000000000000000000000011111111
00000000000000000000000000000000111111111113310000003003300300333330033003331311331001101111110000000000000000000000000011111111
00000000000000000000000000000000111111111113111000030000303300303330033013333311311111101111111000000000000000000000000011111111
00000000000000000000000000000000011111111133111000030000303300303030033013311111311111111111111000000000000000000000000001111111
00000000000000000000000000000000011111111331100000333300333300303030030033311113111111111111100000000000000000000000000001111111
00000000000000000000000000000000001110111110000000330000330303303030030331311313111111111110000000000000000000000000000000111011
00000000000000000000000000000000000000010000000000000000000003003030030000333303111111100000000000000000000000000000000000000001
01101000000000000000000000000000000000000000000000000000000000000000000000000011111111100000000000000000000000000000000000000000
11111101110000000000000000000000000000000000000000000000000000000000000000000111111111000000000000000000000000000000000000000000
11111111111001100000000000000000000000000000088880000000000000000000000000000111111111110000000000000000000000000000000000000000
11111111111111100000000000000000000000000008880088800000000000000000000000001111111111100000000000000000000000000000000000000000
11111111111111110000000000000000000000000008080000880000000000800008000000011111111111110000000000000000000000000000000000000000
11111111111111110000000000000000000000000000080000080000000000080000800000011111111111100000000000000000000000000000000000000000
11111111111111110000000000000000000000000000080008880000000000088000800000111111111111100000000000000000000000000000000000000000
11111111111111100000000000000000000000000000088888000000000000008000800001111111111111110000000000000000000000000000000000000000
11111111111111100000000000000000000000000000080000000000000000008000800001111111111888100000000000000000000000000000000000000000
11111111111111000000000000000000000000000000080000080000000000080000808881811888811818000000000000000000000000000000000000000000
11111111111111110000000000000000000000000000080000088888088888088800808081188881811881110000000000000000000000000000000000000000
11111111111111100000000000000000000000000000880000080000080880080800808881181881811188100000000000000000000000000000000000000000
11111111111111110000000000000000000000000000800000880000800080080080808001181811811118110000000000000000000000000000000000000000
11111111111111100000000000000000000000000008800000800000888800080880808888181811818188100000000000000000000000000000000000000000
11111111111111100000000000000000000000000008000000800000000000888808800000111011818881100000000000000000000000000000000000000000
11111111111111110000000000000000000000000000000000000000000000800000000000000001111111110000000000000000000000000000000000000000
01111111111111110000000000000000000000110000000000000000000000000000000000000000111111100000000000000000000000000000000000000000
11111111111111110000000000000000000001111100000000000000000000000000000000000000001111110000000000000000000000000000000000000000
11111111111111000000000000000000000001111110011000000000000000000000000000000000111111110000000000000000000000000000000000000000
11111111111111100000000000000000000011111111111000000000000000000000000000000000011111110000000000000000000000000000000000000000
01111111111111100000000000000000000111111111111100000000000000000000000000000000001111000000000000000000000000000000000000000000
01111111111110000000000000000000000111111111111100000000000000000000000000000000011111000000000000000000000000000000000000000000
00111011111000000000000000000000001111111111111100000000000000000000000000000000011111100000000000000000000000000000000000000000
00000001000000000000000000000000011111111111111000000000000000000000000000000000011111100000000000000000000000000000000000000000
00000000000000000000000000000000011111111111111000000000000000000000000000000000001111100000000000000000001111100000000000000000
00000000000000000000000000000000111111111111110000000000000000000000000000000000011111100000000000000000011111100000000000000000
00000000000000000000000000000000111111111111111100000000000000000000000000000000011111110000000000000000011111110000000000000000
00000000000000000000000000000000111111111111111000000000000000000000000000000000111111110000000000000000111111110000000000000000
00000000000000000000000000000000011111111111111100000000000000000000000000000000111111110000000000000000111111110000000000000000
00000000000000000000000000000000011111111111111000000000000000000000000000000000111111110000000000000000111111110000000000000000
00000000000000000000000000000000001110111111111000000000000000000000000000000000011111100000000000000000011111100000000000000000
00000000000000000000000000000000000000011111111100000000000000000000000000000000001100000000000000000000001100000000000000000000
00000000000000000000000000000444044404441144114400000044444000000444004400000044044404440444044400000000000000000000000000000000
00000000000000000000000000000404040404000411141100000440404400000040040400000400004004040404004000000000000000000000000000000000
00000000000000000000000000000444044004401444144400000444044400000040040400000444004004440440004000000000000000000000000000000000
00000000000000000000000000000400040404000114111400000440404400000040040400000004004004040404004000000000000000000000000000000000
00000000000000000000000000000400040404440441144000000044444000000040044000000440004004040404004000000000000000000000000000000000
00000000000000000000000000000000000000000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111110000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100011010000011110000111100011010000011110001101000011010000110100000111100011010000011110000111100011010000011110001101000
11111110111111011111111011111110111111011111111011111101111111011111110111111110111111011111111011111110111111011111111011111101
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01110000111111110000000000000000000000000000000000000000000000110000000000000000000000000000000000111110000000000000000000000000
11110011111111110000000000000000000000000000000000000000000001111100000000000000000000000000000001111110000000000000000000000000
11111111111111000000000000000000000000000000000000000000000001111110011000000000000000000000000001111111000000000000000000000000
11111111111111100000000000000000000000000000000000000000000011111111111000000000000000000000000011111111000000000000000000000000
11111111111111100000000000000000000000000000000000000000000111111111111100000000000000000000000011111111000000000000000000000000
11111111111110000000000000000000000000000000000000000000000111111111111100000000000000000000000011111111000000000000000000000000
10110111111000000000000000000000000000000000000000000000001111111111111100000000000000000000000001111110000000000000000000000000
10100001000000000000000000000000000000000000000000000000011111111111111000000000000000000000000000110000000000000000000000000000

__gff__
000000000000000000000000000000000903060c0f0f050a0000000000000000903060c0f0f050a00000000000000000693c96c3a55a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000d3000000000000d1000000d300000000000000f2ec00000000000000000000000000e2ec0000d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048484848484848484848484848484848
0000d100000000000000000000f2d2f2000000000000d300000000000000000000000000f2f30000f2d2d2d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000048000000000000000000000000000048
00000000000000000000f40000000000000000000000d1000000000000d10000000000000000000000000000000000d10000000000000000000000000000f2d2000000000000000000000000000000d1000000000000000000000000000000d10000000000000000000000000000000048000000000000000000000000000048
d1000000000000000000f2e3000000000000000000000000000000000000000000e1c0e8c0c0c0c0d8e8c0e8c0c0f100d1e1c0e8c0c0c0c0d8e8c0e8c0c0f10000e1c0e8c0c0c0c0d8e8c0e8c0c0f10000e1c0e8c0c0c0c0d8e8c0e8c0c0f10000e1c0e8c0c0c0c0d8e8c0e8c0c0000048000000000000000000000000000048
00000000e2fc0000000000d3000000e2d0e300000000000000000000000000e200c0c000001300000000000000c0c00000c0e800000000111616161200e8c00000c0d800002123002122002700d8c00000c00322000011161616161612c0c00000c0000000000000000000000000000048000000000000000000000000000048
00000000f2f3000000d1e3f3000000f2e0f300000000000000000000000000f200c0d800000013000000111200d8c00000c0c00000000000000000101639c00000c0d80000230021232026272738c00000c0d82700001700000000001139c00000c0000000000000000000000000000048000000000000000000000000000048
d0e300000000000000e2ec0000000000f30000000000000000d100000000000000c0d80000000013161613101639c00000c0c000001100111616161300c0c00000c0c000000000270027002727c0c00000c0d820220034000000000017c0c00000c0000000000000000000000000000048000000000000000000000000000048
e0ec00000000000000f2ec00000000000000000000000000000000000000000000c02812000000170000000000e8c00000c0e800001700170000000017e8c00000c0c000002123270027000000d8c00000c0d800202634262626262217c0c00000c0000000000000000000000000000048000000000000000000000000000048
f2f30000e2e300000000d300000000000000000000000000000000000000000000c0c010161616130000000000e8c00000c0c000001012130000000017c0c00000c0c000002420272623000000c0c00000c0c00000003400000000203538c00000c0000000000000000000000000000048000000000000000000000000000048
00000000f2ec00000000d10000d100000000000000000000000000000000d10000d8d800000000000000000000c0d80000d82816161613000000001113c0d80000d80325262300270000000000e8d80000d8c000000017170000001113c0d80000d8000000000000000000000000000048000000000000000000000000000048
0000000000d3000000000000000000000000d1000000000000000000e2e3000000d8d800000000000000000000c0d80000d8e800000000000000111300e8d80000d8d800000000270000000000c0d80000d82816161613171616161300e8d80000d8000000000000000000000000000048000000000000000000000000000048
0000000000d300000000000000000000000000000000000000000000d4ec000000c0c000000000000000000000c0c00000c0c000001016161616130000e8c00000c0c000202626230000000000c0c00000c0c000000000170000000000e8c00000c0000000000000000000000000000048000000000000000000000000000048
fcd0fcfcd0fcd0d0d0fcd0fcfcd0fcd0fcd0fcfcd0fcd0d0d0fcd0fce0e0fcd0fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d0fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d0fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d0fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d00000000000000000000000000000000048000000000000000000000000000048
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0e0c0e0e0e0e0c0e0e0e0c0e0e0c0e0e0e0c0e0e0e0e0c0f8e0e0c0e0e0c0e0e0e0c0e0e0e0e0c0f8e0e0c0e0e0c0e0e0e0c0e0e0e0e0c0f8e0e0c0e00000000000000000000000000000000048000000000000000000000000000048
00f400000000000000000000000000000000000000000000000000000000000000000000000000f5f5000000000000000000f4f4f500f50000000000e700000000000000000000f5f5000000e70000f500000000000000f5f5000000e70000f50000000000000000000000000000000048000000000000000000000000000048
d2f30000000000e2e3000000d1000000e2d0e300000000000000000000d10000000000d100000000000000e2e30000000000f2ec00000000d100000000000000000000d100000000000000e2e3000000000000d100000000000000e2e30000000000000000000000000000000000000048484848484848484848484848484848
c0c0c0c0c0c0c0c0c0c0c0c000000000c0c0c0c0c0c0c0c0c0c0c0d0d0d000f700000000e2ec0000d30000000000000000000000000000000000000000000000f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f700000000000000000000000000000000f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f700000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c000000000c0c0c0e1d1c1c1d1c1c0c0d0d0d000f700000000f2f30000f2d2d2d1000000000000000000000000000000000000000000000000000000000000000000000000f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f700000000000000000000000000000000f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
c0c0c0c0c0c0c0c0c0c0c0c000000000c0c0c0c1c1e1c2c3e1c0c0d0d0d000f7000000000000000000000000000000d10000000000000000000000000000f2d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c000000000f0c0c0e1c1c1c1c1d1c0c0d0d0d000f700e1c0e8c0c0c0c0d8e8c0e8c0c0f100d1e1c0e8c0c0c0c0d8e8c0e8c0c0f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c000000000c0c0c0c0c0c0c0c0c0c0c0d0d0d000f700c0c000000000000000000000c0c00000c0e800000000111616161200e8c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000f700c0d800000000000000001112d8c00000c0c00000000000000000101639c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c00000000000f1f1f1f1f10000d0d0d0d0d00000f700c0d80011161616161716131039c00000c0c000001100111616161300c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c00000000000f1f1e4e5f10000d0c9c9c9d00000f700c02812170000000017000000e8c00000c0e800001700170000000017e8c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010000000000f1f1f4f5f10000d0c9c9c9d00000f700c0c010130000000017000000e8c00000c0c000001012130000000017c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d000f1f1f1f1f10000d0d0d0d0d00000f700d8d800000000000000000000c0d80000d82816161613000000001113c0d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d00000000000000000000000000000000000d8d800000000000000000000c0d80000d8e800000000000000111300e8d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d00000000000000000000000000000000000c0c000000000000000000000c0c00000c0c000001016161616130000e8c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d000000000000000000000000000000000fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d0fcc0c2c2c2c0c2c2c2c2c0c2c2c2c0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d000000000000000000000000000000000e0c0e0e0e0c0e0e0e0e0c0e0e0e0c0e0e0c0e0e0e0c0e0e0e0e0c0f8e0e0c0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d00000000000000000000000000000000000000000000000f5f5000000000000000000f4f4f500f50000000000e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010101010101010101010101d0d0d0d000000000000000000000000000000000000000d100000000000000e2e30000000000f2ec00000000d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010700001035010350103501035010350101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150101501015010150
01100000101501c1501c1501c1501c1500f1500f1500f1500f1500f1501d150111501015010150101501015010650106501065010650106501065010650106501065010150101501015010150101501015010150
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000016030190301e0302554025530255202551025510255150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000a00001d75016750117500c7500a7500a7500a7500a750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01110000291121f1002b120241002d1302e1302f13230120301203011030115301153011530115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00002600023000200001b000194001c400214000b000184201f4202342021400184201f4202443021400184201f4202342000000184201f41024420244102441024410244102441024410244100000000000
010800000c55022700227000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000f55022700227000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001153022700227002270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001452022700227002270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 682a432c
02 292b432c
00 41424344
00 41424344
00 41424344
00 41424344
00 23244344

