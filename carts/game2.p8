pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- game 2
-- by matt phelps
-- == main methods ==
function _init()

end

function _update()

end

function _draw()
    -- space
    draw_space()
    -- ship
    draw_ship()

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

end
---- draws
function draw_ship()
    rect(sh.x-3,sh.y-3,sh.x+3,sh.y+3,c['orange'])
end

-->8
-- == particles ==
---- conf
part = {}

---- updates
---- draws

-->8
-- == ext helper func ==
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
