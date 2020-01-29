pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- planet tests
-- by matt phelps
-- == main methods ==
function _init()

end

function _update()
    if (btn(0)) then center.angle += 0.02 end 
    if (btn(1)) then center.angle -= 0.02 end 
    if (btn(3)) then -- speed up
        center.speed = min(20,center.speed+center.acc)
    else -- slow down
        center.speed = max(0,center.speed-center.decel)
    end 
    center.x = (center.x + center.speed*cos(center.angle))%128
    center.y = (center.y + center.speed*sin(center.angle))%128
end

function _draw()
    cls(3)
    draw_rocket()
    print('speed: '..center.speed,1,1,c['lime'])
end


-->8
-- == global config ==
c = {
    black = 0, blue = 1, maroon = 2,
    green = 3, brown = 4, dark_gray = 5,
    light_gray = 6, white = 7,
    red = 8, orange = 9, yellow = 10,
    lime = 11, light_blue = 12,
    lavender = 13, pink = 14, tan = 15
}
function x(r) 
    if r == nil or r.r == nil or r.a == nil then return nil end
    return r.r*cos(center.angle+r.a)
end
function y(r) 
    if r == nil or r.r == nil or r.a == nil then return nil end
    return r.r*sin(center.angle+r.a)
end

center = {x=50,y=50,angle=0,speed=0,acc=2,decel=.5}
rock = {
    { r = 9, a = 0 },
    { r = 8, a = 0.35 },
    { r = 0, a = 0.5 },
    { r = 8, a = 0.65 },
    { r = 9, a = 0 },
}
-->8
-- == rocket ==
function draw_rocket()
    -- center
    pset(center.x,center.y,c['black'])
    color(c['black'])
    local r1 = rock[1]
    line(center.x+x(r1),center.y+y(r1),
         center.x+x(r1),center.y+y(r1))
    for r in all(rock) do 
        line(center.x+x(r),
             center.y+y(r))
    end
end
-->8
-- == helper func ==
function btw(a,b,c)
    return a >= b and a <= c
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
