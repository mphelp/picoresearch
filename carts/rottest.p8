pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local time_t=0

local rspr_clear_col=14
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

-- 3, 2, 1
curs = {
	sx = 16,
	sy = 16,
	mx = 2,
	my = 2,
	mode = 3,
	col = 4
}
draw_curs = function()
	if (curs.mode == 1) then
		spr(80, curs.sx, curs.sy)
	elseif (curs.mode == 3) then
		spr(96, curs.sx, curs.sy)
		rectfill(curs.sx-9, curs.sy-9, curs.sx-9, curs.sy+16, curs.col)
		rectfill(curs.sx-9, curs.sy-9, curs.sx+16, curs.sy-9, curs.col)
		rectfill(curs.sx+16, curs.sy+16, curs.sx+16, curs.sy-9, curs.col)
		rectfill(curs.sx+16, curs.sy+16, curs.sx-9, curs.sy+16, curs.col)
	end

end
threebythree = function(x,y)
	-- get pipes from map x and y
end
twobytwo = function()

end
onebyone = function()

end
function samepipes(p1, p2)
	--for _,v in pairs(p1) do 
	--	if (p2.x != v.x or p2.y != v.y) then
	--		return false
	--	end
	--end
	return false
end
add_pipes = function()
	if (curs.mode == 3) then
		for i = curs.mx - 1, curs.mx + 1 do
			for j = curs.my - 1, curs.my + 1 do
				if (i >= 0 and j >= 0) make_pipe(i,j)
			end 
		end
		--if samepipes(pipes, new_pipes) then
		--	pipes = new_pipes -- from make pipe
		--end
	end
end

-- world to screen space project
local cam_focal=1/8
function project(x,y,z,cx,cy)
	local w=cam_focal/(cam_focal+z)
 return cx+x*w,cy-y*w,z,w
end

local world_radius=8
local pipes={}
function make_pipe(mx,my)
	return add(new_pipes,{
	n = mget(mx,my), -- sprite n
 	x=0,y=0,z=0,
	cx = 8*mx + 0,
	cy = 8*my + 0,
 	angle=0,
 	-- sprite coords
 	sx=shl(band(mget(mx,my), 0x0f), 3), -- sprite x 
 	sy=shr(band(mget(mx,my), 0xf0), 1), -- sprite y
 	draw=draw_pipe,
 	update=function() 
 	 -- done in control_plyr
 	end})
end
delete_pipes = function()
	for p in all(pipes) do 
		del(pipes, p)
	end
end

function draw_pipe(self)
	--print(self.n)
	-- rotate sprite (using sprite 32/16 as buffer)
	rspr(self.sx,self.sy,32,16,-self.angle,1)	
	
	-- project
	--print(self.cx)
	--print(self.cy)
	local x,y,z,w=project(self.x,self.y,self.z, self.cx, self.cy)
	--print('x: '..x)
	--print('y: '..y)
	--print('z: '..z)
	--print('w: '..w)
	--local x,y,w = self.cx, self.cy, self.z
	
	-- display sprite (inc. scaling)
 	sspr(32,16,16,16,x-4*w,y-4*w,16*w,16*w)	

    -- unrotate sprite
	--rspr(self.sx,self.sy,32,16,0,1)	
 	--sspr(32,16,16,16,68,68)
	--spr(10,68,68)
	--spr(10,60,68)
	--spr(10,52,68)
	--spr(11,60,60)
	rectfill(self.cx,self.cy,self.cx,self.cy, 15)
end
update_pipes = function()
	for pipe in all(pipes) do
		local x,y=world_radius*cos(pipe.angle),-world_radius*sin(pipe.angle)
		pipe.x,pipe.y=x,y

		if (btnp(4)) then
			pipe.z += .01
		end
		if (btnp(5)) then
			pipe.z -= 0.01
		end
	end
end

function move_cursor()
	-- Old Key bindings
	--if(btnp(0)) plyr.angle -= 0.25
	--if(btnp(1)) plyr.angle += 0.25
	--if(btn(4)) plyr.z += 0.01
	--if(btn(5)) plyr.z -= 0.01
	if(btnp(0)) then 
		curs.sx -= 8
		curs.mx -= 1
	end
	if(btnp(1)) then 
		curs.sx += 8
		curs.mx += 1
	end
	if(btnp(2)) then 
		curs.sy -= 8
		curs.my -= 1
	end
	if(btnp(3)) then 
		curs.sy += 8
		curs.my += 1
	end
	--plyr.angle+=plyr.da
	--plyr.da*=0.9
	

	--if btnp(4) then
	--	make_part(x,y,plyr.angle+0.5)
	--end	

end

function _update60()
	delete_pipes() -- from previous
	move_cursor()
	add_pipes()
	if (not samepipes(new_pipes, pipes)) then
		delete_pipes()
		pipes = new_pipes
	end
	update_pipes()
	--for _,a in pairs(pipes) do
	--	a:update()
	--end
	
end

function _draw()
	cls(0)


	map(0,0,0,0,64,64)	
	threebythree(20,20)
	
	palt(0,false)
	palt(14,true)

	--map(0,0,0,0,64,64)

	for _,a in pairs(pipes) do
		a:draw()
	end
	
	palt()	

	-- Cursor
	draw_curs()
	print(#pipes, 0,0,3)
	if (#pipes > 0) then 
		print(#pipes)
	end
end

function _init()
	--plyr=make_plyr()
	--for i=1,5 do
	--	make_npc()
	--end
end

__gfx__
00000000000000008888888888888888eeeeeeee668eeeeeeee99eeeeeeeeeeeeeeeeeee0000000000099000555555550000000000000000dddddddd00000000
00000000000000008999999999999998eeeeeee6668eeeeeee9997eeeeeeeeeeeeeeeeee0000000000099000555555550000000000000000d666666d00000000
007007000000000089aaaaaaaaaaaa98eeeeee6668eeeeeeee99997eeeeeeeeeee3333ee0000000000099000fffff5550000000000000000d666666d00000000
000770000000000089a0000770000a98eeee786682eeeeeeee99990997799eeeee3bb3ee0000000099999999ffffff550000000000000000d666666d00000000
000770000000000089a0000770000a98eeee778682eeeeeee9990099999009eeee3bb3ee0000000099999999ffffff550000000000000000d666666d00000000
007007000000000089a0000770000a98eee677788eeeeeeee9999990090000eeee3333ee0000000000099000ffffff550000000000000000d666666d00000000
000000000000000089a0000770000a98ee6067782cceeeee999777edd9ee999eeeeeeeee000000000009900055ffff550000000000000000d666666d00000000
000000000000000089a7777777777a98e606668277c7ce7eee4466d77d797799eeeeeeee000000000009900055ffff550000000000000000dddddddd00000000
000000000000000089a7777777777a98e707778277c7ce7eee4466d77d7977990000000000000000111111113333333300000000000000000000000000000000
000000000000000089a0000770000a98ee7076682cceeeee9997770dd000999e0000000000000000111111113333333300000000000000000000000000000000
000000000000000089a0000770000a98eee766688eeeeeeee9999990090000ee0000000000000000eeeee1116666633300000000000000000000000000000000
000000000000000089a0000770000a98eeee668782eeeeeee9990099999009ee0000000000000000eeeeee116666663300000000000000000000000000000000
000000000000000089a0000770000a98eeee687782eeeeeeee99990997799eee0000000000000000eeeeee116666663300000000000000000000000000000000
000000000000000089aaaaaaaaaaaa98eeeeee7778eeeeeeee99997eeeeeeeee0000000000000000eeeeee116666663300000000000000000000000000000000
00000000000000008999999999999998eeeeeee7778eeeeeee9997eeeeeeeeee000000000000000011eeee113366663300000000000000000000000000000000
00000000000000008888888888888888eeeeeeee778eeeeeeee99eeeeeeeeeee000000000000000011eeee113366663300000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11777111117711777177711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11717111111711117171711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11717111111711777177711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11717111111711711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11777117117771777111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000007900d777d0099000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009900d777d9990777000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000099990ddd09909999000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000099990ddd09909999000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000770999766667790999000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000779900976667799999000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000779900976667799999000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009999900974449999999000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009999999994449999000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009999999990009900000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009999999990009900000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000009900000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000f00000000000
000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000f000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000f000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000
00f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000
00000f000000000000000000060000000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000000000
0000000000000000000007708867077000f0000000000000000000000000000000000000000000000000000f0000000000000000000000000000000000000000
00000000000000000000777786670076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000002877667760000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000002888676600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022886660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000c77277770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000c77287777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000077cc886880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000070c7c0086600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000700000028600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000088600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

__map__
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0b1b0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0a0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e1b0a0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000