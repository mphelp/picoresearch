pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- game 2
-- by matt phelps
-- == main methods ==
function _init()

end

function _update()
    move_ship()
    update_particles()
end

function _draw()
    -- space
    draw_space()
    -- ship
    draw_ship()
    -- particles
    draw_particles()

    -- test
    circfill(20,20,1,10)
    circ(30,20,1,10)
    circfill(20,30,2,10)
    circ(30,30,2,10)
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

-->8
-- == space ==
function draw_space()
    cls(c['blue'])
end
-->8
-- == the ship ==
---- conf
sh = {
    x = 40,
    y = 40
}
---- updates
function move_ship()

    if btn(0) then sh.x-=2 end
    if btn(1) then sh.x+=2 end
    if btn(2) then sh.y-=2 end
    if btn(3) then sh.y+=2 end
    if btn(4) then
         --an example passing a table for the color (flames?)
         for i=1,10 do
             add_new_dust(sh.x,sh.y,
                          rnd(1)-0.5,rnd(1)-2, -- dx, dy
                          rnd(20)+10,rnd(1)+1, -- life, rad
                          0, 0.8, -- grav, perc
                          flame_sequence)
         end
     end
end
---- draws
function draw_ship()
    rect(sh.x-3,sh.y-3,sh.x+3,sh.y+3,c['orange'])
end

-->8
-- == particles ==
---- conf
dust = {}
flame_sequence = {7,7,7,7,7,7,6,6,6,6,6,5,5,9,9,10,10,10,10,10}
---- updates
function update_particles()
    for d in all(dust) do d:update() end
end
---- draws
function draw_particles()
    for d in all(dust) do d:draw() end
end

-->8
-- == ext helper func ==
-- CREDIT: DocRobs (https://www.lexaloffle.com/bbs/?pid=58211)
--        _x coordinate of dust
--        _y coordinate of dust
--        _dx x velocity
--        _dy y velocity
--        _l lifespan
--        _s starting radius
--        _g gravity
--        _p    percentage shrink
--  _f col or table for fade
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_p,_f)
 add(dust, {
 fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,p=_p,draw=function(self)
 pal()palt()circfill(self.x,self.y,self.rad,self.col)
 end,update=function(self)
 self.x+=self.dx self.y+=self.dy
 self.dy+=self.grav self.rad*=self.p self.life-=1
 if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
 if self.life<0then del(dust,self)end end})
 end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
