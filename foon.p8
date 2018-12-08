pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function getmapstate()
 if mapnames_enabled then
	 return "[ enabled ]"
 else
 	return "[ disabled ]"
 end
end

function togglemap()
 mapnames_enabled = not mapnames_enabled
 return ""	 
end

function _init()



magic_anim = copy(battle_anim)
magic_anim.audio = 17
magic_anim.slides = {85,86}

attack_anim = copy(battle_anim)
attack_anim.audio = 16
attack_anim.slides = {69,70}


 money = 100
 copycount = 10
 can = {}
 can.x = 50
 can.y = 50
 can.frames = {64,65,66}
 can.frameid = 1
 can.speed = 1
 can.size = {8,8}
 can.faceleft = false
 error = false
 animation_ongoing = false

 gamestate = 0
	mapnames_enabled = false
 sentence  = ""
 menuid = 1
 selectid = 1
 levelid = 1
 
 menuscreen ={}
 
 menuscreen[1] = {}
 menuscreen[1].len = 2
 menuscreen[1].text = 
 {
 {"inventory",2},
 {"settings",3}
 }
 menuscreen[1].icons = {}
 
 menuscreen[2] = {}
 menuscreen[2].len = 3
 menuscreen[2].text =
 {
 {"deed to usidore's hat",0}, 
 {"back",1}
 }
 menuscreen[2].icons =
 {
 84
 }
 
 menuscreen[3] = {}
 menuscreen[3].len = 2
 menuscreen[3].icons ={}
 menuscreen[3].text =
 {
 {"map names ",-1,{false,1},{true,0}},
 {"back",1}
 }

 menuscreen[4] = {}
 menuscreen[4].len = 2
 menuscreen[4].text = 
 {
 {"ether",-1,{false,5,5},{true,3,5}},
 {"health potion",-1,{false,5,5},{true,3,5}},
 }
 menuscreen[4].icons = {
 124,
 125}
 
 menuscreen[5] = {}
 menuscreen[5].len = 1
 menuscreen[5].text = 
 {
 {"red potion",-1,{false,5,5},{true,3,5}},
 }
 menuscreen[5].icons = {
 123}
 
 music(1)

 oldlocs = {}
	cellx = 116
	celly = 8
	sx = 25
	sy = 25
	celw = 12
	celh = 6	

 //hogsface	
	mapxoffset = -8 * 25
	mapyoffset = -8 * 18	
	//belaroth
//	mapxoffset = -8 * 55
//	mapyoffset = -8 * 18
	world="overworld"

 inittext()

 init_mapelems()
 initnpcs()


 
 statuseffects = {}
 statuseffects.redpotion = {false,0}
cls()



end


function perform_referenced_functions(id,extra)
 if id == 0 then 
 	return togglemap()
 elseif id == 1 then 
 	return getmapstate()
 elseif id == 2 then 
 	return useitem()
 elseif id == 3 then 
 	return buy(extra)
 elseif id == 4 then 
 	return amount(extra)
 elseif id == 5 then 
 	return price(extra)
 end
end

function amount(nr)
	return (" x"..nr)
	
end

function price(amount)
	return ("["..amount.."g]")
end

function buy(price)
 if money >= price then
  additem(menuscreen[menuid].text[selectid][1])
  sfx(28)
  money -=price
 else
		sfx(23)
	end
end

function isblocked(x,y)
 	if (fget(mget(((x-(x % 8) ) / 8),((y-(y % 8) ) / 8)) , 0)) then
 	 return true
	elseif (newworld:blocked(x,y)) then
 		return true	
 	
 	end 
 	return false
end

function getabsoluteposition(x,y,worldid,player)

local x2 = x
local y2 = y
if player then
local mxo = mapxoffset
local myo = mapyoffset
if player then
 mxo *=-1
 myo *=-1
end
 if worldid == "overworld" then
  x2 = x+mxo
  y2 = y+myo
 elseif player then
  x2 =	((x/8+cellx) *8)-sx
  y2 = ((y/8+celly) *8)-sy
 end
end

return ({x2,y2})

end

function getmapflags(sprite,xoffset,yoffset)
 local x =  getabsoluteposition(sprite.x,sprite.y,world,true)
 local y  = x[2]+yoffset
  x = x[1] + xoffset
  xmax = x + sprite.size[1]
  ymax = y + sprite.size[2]
  tilex = ((x-(x % 8) ) / 8)
  tiley = ((y-(y % 8) ) / 8) 
  tilexmax = ((xmax-(xmax % 8) ) / 8)
  tileymax = ((ymax-(ymax % 8) ) / 8) 

		return bor (
    bor ( 
        bor (
            fget(mget(tilex,tiley)),
            fget(mget(tilexmax,tileymax))
        ),
        fget(mget(tilex,tileymax))
    ),
    fget(mget(tilexmax,tiley))
)
 					
end


function updatesprite(sprite)
 sprite.frameid+=1
 if sprite.frameid > #sprite.frames then
 	sprite.frameid = 1
 end
end

function _update()
 
  if gamestate == 0 then
  	handleinputs_titlescreen()
  elseif gamestate == 1 then

  	handleinputs_worldscreen()
  	
  elseif gamestate == 2 then

   handleinputs_menuscreen()
  elseif gamestate == 3 then
  	handleinputs_battlescreen()
  
  elseif gamestate == 4 then
  	 --noop
  elseif gamestate ==5 then
  	handleinputs_dialogue()
 end
end


function _draw()


 	if gamestate==0 then
 		draw_titlescreen()
  elseif (gamestate==1) then
   draw_worldscreen()
 	elseif gamestate ==2 then
 	 draw_menuscreen()
 	elseif gamestate ==3 then
 		draw_battlescreen()
  elseif gamestate ==4 then
   draw_gameover()
  elseif gamestate ==5 then
   draw_dialogue()
  end
 
// print(chunt.loc[1]..','..chunt.loc[2],10,75,10)
 //print(intersect_box(l[1],chunt.loc[1],l[2],chunt.loc[2]),0,0,10)

// local l =  getabsoluteposition(can.x,can.y,world,true)

// print(newworld:blocked(l[1],l[2]),10,10,10)
// myelem.draw()
end
-->8
function inittext()
 verbs = 
 {"killed",
 "played mittens with",
 "sent a letter to",
 "was killed by",
 "married", 
 "rented a condo with",
 "summoned",
 "banished",
 "slayed",
 "vanquished",
 "vacationed with",
 "was defeated by",
 "was murdered by", 
 "discovered", 
 "forgot about",
 "valiantly fought",
 "am confused by",
 "interrupted",
 "worked out with",
 "tutored",
 "waved at",
 "shook my \nfinger at",
 "broke up with",
 "sternly lectured",
 "sneezed on",
 "fornicated with",
 "blessed",
 "dreamed about",
 "prophesied",
 "had my heart\n broken by",
 "ensorcled",
 "read a great \nbook with",
 "drank a mead with",
 "was tricked by",
 "had a night on \nthe town with",
 "cursed",
 "cooked dinner with",
 "charmed the \ninlaws with",
 "ignored",
 "went out \nclubbing with",
 "embarked on \na quest with",
 "couldn't remember",
 "am really foggy about",
 "struggled to \nthink about",
 "pretended to \nknow about",
 "entombed",
 "set a trap for",
 "assasinated",
 "knighted",
 "embalmed",
 "annointed",
 "made fun of"}
 nouns = {
 "a great rock",
 "many houseflies",
 "an evil sigil",
 "a dragon",
 "arnie", 
 "usidore",
 "a cockatrice",
 "a eunuch",
 "a shapeshifter",
 "a genie",
 "dripfang",
 "blemish",
 "activia",
 "an evil spider",
 "some tourists",
 "an innkeeper",
 "a stablekeeper",
 "a milkmaid",
 "a tax collector",
 "a corsair",
 "a brigand",
 "momo",
 "a talking flower",
 "a sheriff",
 "a blue tiger",
 "a memory gremlin",
 "arnor",
 "larry birdman",
 "a soulwalker",
 "a pinglet",
 "mayor manana",
 "an evil skeleton",
 "a mimic",
 "chunt",
 "spintax", 
 "wheelbear",
 "cockroach clown",
 "twosidore",
 "a slime",
 "a vampire",
 "a hunger ghost",
 "6 werewolves",
 "an innocent shopkeeper",
 "a tavern wench",
 "an elderdly scholar",
 "a thousand bees", 
 "the pyramid of confusion",
 "a harpie",
 "the hottest shark \ni've ever seen",
 "otak barleyfoot",
 "tomblain belaroth",
 "the dark lord",
 "bob johnson",
 "macho mantis randy mantis",
 "a glass anus",
 "a scroll of foretelling",
 "some guy named larry",
 "grimhoof",
 "the tallest mountain",
 "an unwed mother",
 "a troll",
 "the boy king",
 "queen titania",
 "a bear",
 "a wolf",
 "a lucky scarab",
 "an evil rooster",
 "good king belaroth",
 "a flock of birds",
 "a single starling",
 "a cricket",
 "a she-goat",
 "a great red stag",
 "a tiger with 10 eyes",
 "the entire faculty of \n jizzleknob prep",
 "the dark blade of infinite",
 "the shroud of holy noise",
 "the burger king"
 }

	stringstodraw={
	{"hogsface",{36*8,20*8}},	
	{"capital\ncity",{39*8,25*8}},
	{"meagas",{45*8,32*8}},
	{"jizzleknob\nprep",{51*8,19*8}},
	{"erik's\nisland",{57*8,35*8}},
	{"the\nbig\napple",{47*8,18*8}},
	{"castle\nbelaroth",{62*8,24*8}},
 {"woods of\nholly",{41*8,41*8}},
 {"fingarian glacier",{46*8,12*8}},
 {"scrr",{18*8,34*8}},
 {"mountains of\nits'ak",{21*8,15*8}},
 {"gunder",{33*8,14*8}},
 {"mcshingleshane\nforest",{30*8,25*8}},
 {"shrike\nvalley",{40*8,22*8}},
 {"furlingshire",{30*8,38*8}},
 {"gratax",{42*8,45*8}},
 {"little bowl",{23*8,42*8}},
 {"big bowl",{17*8,45*8}},
 {"malfoi",{46*8,52*8}},
	{"terr'akkas",{21*8,28*8}},
	{"hawai",{18*8,39*8}}
	}


end

-->8
menu_bounce_start = 5
menu_bounce_direction = 1
canhealth = {1,1}
enemyhealth ={1,1}
battleselect = 1
animation = {}
battleturn = false

battlestats = {{}}

battlestats[1] = {}
battlestats[1].attack = 10
battlestats[1].magic = 50
battlestats[1].hp = 100
battlestats[1].mp = 100
battlestats[1].defense = .5

battlestats[2] ={}

battle_anim = {}
battle_anim.running = false
battle_anim.lastupdate = nil
battle_anim.duration = .2
battle_anim.audio = nil
battle_anim.slides = {69,70}
battle_anim.location = {0,0}
battle_anim.index = 1


function attack(idsource,iddest)
 win = false
	source = battlestats[idsource]
	dest = battlestats[iddest]
	damage =  source.attack * dest.defense
	dest.hp -= damage
	if dest.hp <0 then 
		dest.hp = 0 
		win = true
	end
 start_animation(attack_anim,iddest)
	battleturn =  not battleturn
 return win
end





function wait(a) for i = 1,a do flip() end end

function draw_gameover()
cls()
print("---- game over ----",20,50,10)
end

----------- animation ------

function start_animation(a,loc)
if loc == 2 then
	loc = {95,75}
else
	loc = {15,75}
end
 a.index = 1
 a.location = {loc[1],loc[2]}
	animation = a	
	animation_ongoing = true
	 if(animation_ongoing) then
 	if animation.audio then 
 		sfx(animation.audio) 
 	end
 	
 	for i = 1, #animation.slides do
   draw_battlescreen()
   
   spr(animation.slides[animation.index],
   animation.location[1],
   animation.location[2])
   
   animation.index+=1
   wait(5)
 	end
 	draw_battlescreen()
 	animation_ongoing = false
 end
end

function animate()

end

----------- title -----------
function draw_titlescreen()
 version = 0.9
 cls()
 
 print("version: "..version,5,5,10)
 print("   welcome to can's quest\n - a journey thorugh foon - ",10,30,10)
 print("controls:",10,60,7)
 print("press 'z' to interact",10,70,7)
 print("press 'x' to open menu",10,80,7)

 print("  press z to proceed",
 menu_bounce_start-6,
 110,10)
 bounceupdate()
 
end


function handleinputs_titlescreen()
  if btnp(4) then
  gamestate = 1
  music(-1)
  end
end

----------- menu -----------
function draw_menuscreen()
   cls()
   print("--menu--",20,5,7)
   drawarrow(7,22+10*selectid,7)
   drawmenu(menuid)
   updatesprite(can)
   pal()
   if (statuseffects.redpotion[1]==true) then
  		pal(15,8)
  	end
   spr(can.frames[can.frameid],10,10)
			pal()
   drawhealthbars(false)
   print(money.."g",35,14,7)
   spr(94,22,12)
   print("press x to return",
   menu_bounce_start,
   120,
   7)
bounceupdate()
end

function drawarrow(x,y,col)
 line( x, y, x-5, y, col)
 line( x, y, x-2, y+2, col )
 line( x, y, x-2, y-2, col )
end

function restore_status(st)
 
	if st == "redpotion" then
	 statuseffects.redpotion[1] = false
 	if world == "overworld" then
 	can.x = 50
 	can.y = 50
 	end
 end
  can.speed = 1
end

function draw_redpotion()
 local duration = time()-10 - statuseffects.redpotion[2]
 if duration>=0 then
   restore_status("redpotion")
 
 else
     spr(123,0,0)
 	   print(flr(duration*-1),10,3,10)
 end

end


function drawmenu(menuid)
	if (menuscreen[menuid]) then
 	for m=1,menuscreen[menuid].len do
  		if menuscreen[menuid].text[m] then
  			item = menuscreen[menuid].text[m]
  			print(item[1],10,20+10*m,10)
  		 if item[2] == -1 then
   		 for  i=3,  #item do
   		 --i[1]=on select (vs menu load)
   		  if item[i][1] == false then
   		    local extra = nil
         if item[i][3] != nil then
         	extra = item[i][3]
         end
   		  		print (perform_referenced_functions(item[i][2],extra),64,20+10*m,8)
 						end
 					end
   		end
  		end
  		if menuscreen[menuid].icons[m] then  			
  			spr(menuscreen[menuid].icons[m],100,20+10*m)
  		end  		
  end
 end
end

function selectmenu()
 data = menuscreen[menuid].text[selectid]
	if data[2]>0 then
  menuid = data[2]
 	selectid = 1
 	sfx(18)
 elseif data[2] == -1 then
   for  i=3, #data do
   	sfx(18)
    if data[i][1] == true then
         local extra = nil
         if data[i][3] != nil then
         	extra = data[i][3]
         end
   		  		perform_referenced_functions(data[i][2],extra)
 			end
 		end
 end
end



function handleinputs_menuscreen()
  if btnp(5) then
		returntoworld()
  	sfx(15)
  end
  if btnp(2) and selectid!=1  then
  	selectid-=1
  	sfx(18)
  end
  
  if btnp(3) and menuscreen[menuid].len>=selectid+1 then
  	selectid+=1
  	sfx(18)
  end
  if btnp(4) then
  	selectmenu()
  end
end
----------- dialogue --------


function draw_dialogue()
 rectfill(0,90,127,127,7)
 rect(0,90,127,127,6)
 print(dialogue,20,95,0)
	print ("press z to return",
	menu_bounce_start,120,6)
	
	bounceupdate()

	end

function bounceupdate()
	menu_bounce_start+=menu_bounce_direction

	if menu_bounce_start>=55 or menu_bounce_start<=5 then
	 menu_bounce_direction *=-1
	end
end
function handleinputs_dialogue()
  if btnp(4) then 
    sfx(26)
    returntoworld()
  end
end
----------- world -----------

function drawplayer()
  pal()
  
  if (statuseffects.redpotion[1]==true) then
  	dorandommoves(can,true)
  	pal(15,8)
  	draw_redpotion()
  end
  spr(can.frames[can.frameid],can.x,can.y,1,1,can.faceleft,false)
  pal()

end


function draw_worldscreen()
  cls()
 	newworld:draw(0)
 	drawnpcs() 
  drawplayer()
 	newworld:draw(1)
 end

function canmovementblocked(xoff,yoff)
	local blocked = true
 local l =  getabsoluteposition(can.x+xoff,can.y+yoff,world,true)
	if band(
	(getmapflags(can,xoff,yoff)
	), 0x1)==0 
	and not (newworld:blocked(l[1],l[2]) )
		then
	 blocked = false

 end

return blocked
end

function handleinputs_worldscreen()
  justtele = false
  updatenpcs()
  yadjust = 0
  xadjust = 0
  if btn(0) then
  	updatesprite(can)
  	if not canmovementblocked(-can.speed,0) then
   		xadjust+=can.speed
  		can.faceleft = true
  	end
  elseif btn(1) then
   updatesprite(can)
	  if not canmovementblocked(can.speed,0) then
    xadjust-=can.speed
    can.faceleft = false
   end
  end
  if btn(2) then
   updatesprite(can)
 		
   if not canmovementblocked(0,-can.speed) then
  
 			yadjust+=can.speed
 		end
  elseif btn(3) then
   updatesprite(can) 
  if not canmovementblocked(0,can.speed) then
    	yadjust-=can.speed 
   end
  end
  
  if btnp(4) then
  	world_select()
  end
  
  if btnp(5) then
  	gamestate = 2
  	sfx(15)
  end
 
  if world == "overworld" then
  	mapxoffset +=xadjust
   mapyoffset +=yadjust
  else
  	can.x -=xadjust
  	can.y -=yadjust
  end

  local l =  getabsoluteposition(can.x,can.y,world,true)
  newworld:touch(l[1],l[2])

end


function world_select()
	selectnpc()
end
----------- battle -----------   cls()


function startbattle(enemyid)
 sfx(25)
 circlewipe()
 battleturn = false
 battleselect = 1
 if npcs[enemyid].battlestats.hp>0 then
  gamestate = 3
  enemy = setenemysprite(enemyid)
 	eid = enemyid
 	battlestats[2] = enemy.battlestats
	end
end

function draw_battlescreen()
 cls()
 print("!!battle!!",50,10,7)
 draw_battle_art()
	draw_battlemenu()
//	animate()
end


function setenemysprite(e)
 updatesprite(npcs[e])
 return npcs[e]
end

function getenemysprite()
 e = flr(rnd(5))+1
 return setenemysprite(e)
end

function draw_battle_art()
 drawhealthbars(true)


 updatesprite(can)
 spr(can.frames[can.frameid],
 15,
 75)
 print ("can\nthe yellow",10,30,10)
 if enemy == nil then
		enemy = getenemysprite ()
	end
	updatesprite(enemy)
	
	drawsprite(enemy.frames[enemy.frameid],
	95,75, true,enemy.plt,true)
 print (enemy.name,75,30,10)
end


function drawhealthbars(inbattle)
 local xoff = 0
 local yoff = 50
 --lots of random numbers here,
 --swapped from variables to
 --hardcoded values to save space
 --check out old versions of code
 --to see what these mean.
if inbattle then
 print ("hp:",xoff-10+75,yoff,8)
  rectfill(
  xoff+75,
  yoff,
  xoff+battlestats[2].hp/2+
  75,
  yoff+5,
 8)
 rect(
 xoff+75,
 yoff,
 xoff+50+75,
 yoff+5,
 2)
 print ("mp:",
 xoff+75-10,
 yoff+8,
 12)
 rectfill(xoff+75,
 yoff + 8,
 xoff + 75+battlestats[2].mp/2,
 yoff + 8+ 5,
 12)
 rect(xoff+75,
 yoff + 8,
 xoff + 50+75,
 yoff + 8+ 5,
 1) 
 else
   xoff = 60
   yoff = 10

 end
 print ("hp:",xoff,yoff,8)
 rectfill(xoff+12,
 yoff,
 xoff+ 12 +battlestats[1].hp/2,
 yoff+5,8)
 rect(xoff+12,
 yoff,
 xoff+12+50,
 yoff+5,2)
 
 print ("mp:",
 xoff,
 yoff+8,
 12)
 rectfill(xoff+12,
 yoff + 8,
 xoff+12 +battlestats[1].mp/2,
 yoff + 8+ 5,
 12)
 rect(xoff+12,
 yoff + 8,
 xoff+12 +50,
 yoff + 8+ 5,
 1)
 

end
function checkmp(id)

if battlestats[id].mp > 0 then
 	return true
 else
 	return false
 	end
end
 
function returntoworld()
  enemy = nil
  gamestate = 1
  menuid = 1
  selectid=1
end
 
function battleselectmenu()
 if (	battleturn == false)

 and not animation_ongoing then
	  win = false
  	if battleselect == 3 then
  	  sfx(19)
  	  returntoworld()
   elseif battleselect ==1 then
   	win = attack(1,2)
   elseif battleselect ==2 then
   	if checkmp(1) then
   		win = magic(1,2)
   	end
  	end
  	if win then 
  	local gold = flr(rnd(100))
  	dialogue = "you win "..gold.." gold!"
 		money+=gold
 		kill(eid)
 		gamestate = 5
 	 sfx(27)	
 		   
 	end
 else
 	enemyturn()
 end
end


function magic (idsource,iddest)
	win = false
	source = battlestats[idsource]
	dest = battlestats[iddest]
	damage =  source.magic * dest.defense
	dest.hp -= damage
	source.mp -= 10
	if source.mp<0 then
		source.mp = 0
	end
	if dest.hp <0 then 
		dest.hp = 0 
		win = true
	end
 start_animation(magic_anim,iddest)
	battleturn =  not battleturn
	return win
end

function gameover()

	gamestate = 4

end

function enemyturn()
 local win = false
	local move = flr(rnd(2))
	if (move != -1) then
		win = attack(2,1)	
	end
	if win then
	 	print ("you lose!!",50,50,10)
 		wait(20)
			gameover()
 end
end
function draw_battlemenu()
	rect (1,90,125,125,10)
	print("attack",25,95,10)
	print("spell",25,105,10)
	print("run",25,115,10)
	drawarrow(15,87+10*battleselect,10)
end



function handleinputs_battlescreen()
  if (battleturn == true)
  then
 	 enemyturn()
  end
  if btnp(2) and battleselect!=1  then
  	sfx(18)
  	battleselect-=1
  end
 
  if btnp(3) and 3>=battleselect+1 then
   	sfx(18)
  	battleselect+=1
  end
  
  if btnp(4) then 
   battleselectmenu()
  end

end
-->8
blocking_interacts = {}
topitems = {}
justtele = false
nr_of_cavelevels =4

caveids={{113,33},{113,48},{113,18},{98,48}}





worldmap ={}
worldmap.currworld = nil
worldmap.lvls = {}
function worldmap:blocked(x,y)
	return self.currworld:blocked(x,y)
end
function worldmap:draw(lvl) 
 if lvl == 0 then
  if world == "overworld" then
  	map(0, 0,mapxoffset, mapyoffset, 128, 64 )
		 if mapnames_enabled then
 			for s=1,#stringstodraw do
 			 string = stringstodraw[s]
 				print(string[1],string[2][1]+mapxoffset,string[2][2]+mapyoffset,0)
 			end
			end
  else
  	map(cellx, celly, sx, sy,celw, celh)
  end
 end
 self.currworld:draw(lvl)

end
function worldmap:touch(x,y)
  self.currworld:touch(x,y)
end
function worldmap:switchworld(id)
 self.currworld = self.lvls[id]
end
lvlmap = {}
lvlmap.elems ={}
function lvlmap:blocked(xin,yin)
 for i = 1, #self.elems do
  local l = self.elems[i]
  if l.block == true then
   if intersect_box(l.loc[1],xin,l.loc[2],yin) then
    return true
   end
  end
 end
 return false
end
function lvlmap:draw(lvl)
 for i = 1, #self.elems do
 local l = self.elems[i]
  if l.drawlvl == lvl then
  	drawsprite(l.sprite,l.loc[1],l.loc[2])
 	end
 end
end
function lvlmap:addblockingelem(sprite,x,y)
 m = copy(mapelem)
 m.sprite = sprite
 m.block = true
 m.loc = {x,y}
 add(self.elems,m)
end
function lvlmap:touch(x,y)
 for i=1, #self.elems do
 	l = self.elems[i]
 	if intersect_box(l.loc[1],x,l.loc[2],y)then
			l:touch()
		end
	end
end
function lvlmap:addtown(x,y,tele)
 m = copy(mapelem)
 m.sprite = 32
 m.loc = {x,y}
 m.tele = tele
 add(self.elems,m)
end
function lvlmap:addcastle(x,y,tele)
 m1 = copy(mapelem)
 m2 = copy(mapelem)
 m1.sprite = 20
 m2.sprite = 21
 m1.loc = {x,y}
 m1.tele = tele
 m2.loc = {x+8,y}
 m2.tele = tele 
 add(self.elems,m1)
 add(self.elems,m2)
end
function lvlmap:addexit(x,y,lvl)
 m1 = copy(mapelem)
 m1.sprite = 67
 m1.loc = {x,y}
 m1.tele = {"exit",lvl}
 m2 = copy(mapelem)
 m2.sprite = 67
 m2.loc = {x+8,y}
 m2.tele = {"exit",lvl}
  add(self.elems,m1)
 add(self.elems,m2)
end

function lvlmap:addspseries(x,y,sp,width,lvl, blocking, repeatflag,tele)
	for i = 1, width do
 	m = copy(mapelem)
	 m.sprite = sp
  m.loc = {x,y}
  m.block = blocking
  m.drawlvl = lvl
  if tele then
  	m.tele = tele
  end
  add(self.elems,m)
  if not repeatflag then
  	sp+=1
  end
  x+=8
 end
end
function lvlmap:addcolumn(x,y,height)
	for i = 1, height-1 do
 	m = copy(mapelem)
	 m.sprite = 57
  m.loc = {x,y}
  m.drawlvl = 1
  add(self.elems,m)
  y-=8
 end
 	m = copy(mapelem)
	 m.sprite = 10
  m.loc = {x,y}
  m.drawlvl = 1
  add(self.elems,m)
end


mapelem = {}
mapelem.loc = {0,0}
mapelem.sprite = 1
mapelem.tele = {nil,nil}
mapelem.block = false
mapelem.drawlvl = 0

function mapelem:touch()
	if (self.tele[1]!=nil) and
	(self.tele[2]!=nil) then  
	
	
	  if not justtele then
				justtele = true
				teleport(self.tele[1], self.tele[2])
    levelid = self.tele[2] 	  
    newworld:switchworld(levelid)
			end
 
	end
end



function create_world()

 hogsface  = copy(lvlmap)
 tavern    = copy(lvlmap)
 overworld = copy(lvlmap)
 newworld  = copy(worldmap)
 belaroth  = copy(lvlmap)
 cavern  = copy(lvlmap)
 megas  = copy(lvlmap)
 capitol  = copy(lvlmap)
 capitol:addcastle(90*8,34*8,{"c_castle",10})
 capitol:addexit(90*8,45*8,1)
 capitol:addexit(91*8,45*8,1)


 c_castle = copy(lvlmap)

 c_castle:addspseries(100*8,39*8,42,3,1,false)
 c_castle:addspseries(100*8,33*8,42,3,1,false)

 c_castle:addcolumn(99*8,40*8,2)
 c_castle:addcolumn(103*8,40*8,2)


 c_castle:addspseries(108*8,39*8,42,3,1,false)
 c_castle:addspseries(108*8,33*8,42,3,1,false)

 c_castle:addcolumn(107*8,40*8,2)
 c_castle:addcolumn(111*8,40*8,2)
 c_castle:addcolumn(103*8,34*8,2)
 c_castle:addcolumn(107*8,34*8,2)
 c_castle:addcolumn(99*8,34*8,2)
 c_castle:addcolumn(111*8,34*8,2)
 c_castle:addexit(104*8,47*8,9)
 c_castle:addexit(105*8,47*8,9)
 


 cave1      = copy(lvlmap)
 cave1:addspseries(120*8,33*8,101,2,0,false,false,{"cave",6})
 cave1:addexit(120*8,48*8,1)
 cave2      = copy(lvlmap)
 cave2:addspseries(120*8,48*8,101,2,0,false,false,{"cave",7})
 cave2:addexit(120*8,63*8,5)
 cave3      = copy(lvlmap)
 cave3:addspseries(120*8,18*8,101,2,0,false,false,{"cave",8})
 cave3:addexit(120*8,33*8,6)
 cave4      = copy(lvlmap)
 cave4:addexit(105*8,63*8,7)


 tavern_m = copy(mapelem)
 tavern_m.loc ={108*8,006*8}
 tavern_m.sprite = 114
 tavern_m.tele = {"tavern",3}
 
 belaroth:addspseries(118*8,11*8,42,3,1,false)
 belaroth:addspseries(118*8,4*8,42,3,1,false)
 belaroth:addcolumn(117*8,12*8,2)
 belaroth:addcolumn(121*8,12*8,2)
 belaroth:addcolumn(117*8,5*8,2)
 belaroth:addcolumn(121*8,5*8,2)
 belaroth:addexit(118*8,17*8,1)
 belaroth:addexit(119*8,17*8,1)


 cavern:addexit(90*8,63*8,1)


 overworld:addspseries(34*8,18*8,107,2,0,false,false,{"cave",5})
 overworld:addspseries(60*8,23*8,107,2,0,false,false,{"cavern",11})



 add(hogsface.elems,tavern_m)
 
 overworld:addtown(37*8,21*8,{"town",2})
 overworld:addtown(46*8,34*8,{"megas",12})

 --castle belaroth
 overworld:addcastle(64*8,26*8,{"castle",4})
 --capitol city
 overworld:addcastle(40*8,27*8,{"capitol",9})


 tavern:addexit(106*8,31*8,2)
 tavern:addspseries(108*8,28*8,126,5,0,true,true)
 tavern:addblockingelem(112,112*8,29*8)
 tavern:addblockingelem(112,103*8,28*8)

 hogsface:addexit(104*8,15*8,1)
 hogsface:addexit(105*8,15*8,1)
 megas:addexit(90*8,29*8,1)
 megas:addexit(91*8,29*8,1)


 newworld.lvls[1]  = overworld
 newworld.lvls[2]  = hogsface
 newworld.lvls[3]  = tavern
 newworld.lvls[4]  = belaroth 
 newworld.lvls[5]  = cave1  
 newworld.lvls[6]  = cave2   
 newworld.lvls[7]  = cave3
 newworld.lvls[8]  = cave4  
 newworld.lvls[9]  = capitol
 newworld.lvls[10] = c_castle 
 newworld.lvls[11] = cavern  
 newworld.lvls[12] = megas  
 newworld.currworld = newworld.lvls[1]


end



function init_mapelems()


create_world()

end






function draw_caveelems()
  if cavelevels[levelid]then
  for n=1,cavelevels[levelid].nr_of_elems do
   local elem = cavelevels[levelid].elems[n] 
   drawsprite(elem[1],
   elem[2],
   elem[3])
  end

 end

end


function wipe(topbottom)
 if topbottom then
  for i=0, 10 do
   draw_worldscreen()
  	rectfill(0,130,250,130-i*15,0)
  	wait(1)
 	end
	else
 	 for i=0, 10 do
 	 draw_worldscreen()
  	rectfill(0,0,250,0+i*15,0)
  	wait(1)
 	end
 end

end

function circlewipe()
 	 for i=0, 10 do
  	circfill(50,50,0+i*15,8)
  	wait(1)

 end

end

function teleport(location,newloc)
 oldx = can.x
 oldy = can.y
 oldworld = world
 oldcellx = cellx
 oldcelly = celly
 oldsx = sx
 oldsy = sy
 oldcelw = celw
 oldcelh = celh
 
 teleportworked = false
 if location == "exit" then
   sfx(21)
   wipe(false)
   
  	loc = oldlocs[#oldlocs]
 		del(oldlocs,loc)
 		can.x = loc[1]
 		can.y = loc[2]
 		world = loc[3]
 		cellx = loc[4]
   celly = loc[5]
   sx    = loc[6]
   sy    = loc[7]
   celw  = loc[8]
   celh  = loc[9]
   if world == "overworld" then
   	mapyoffset-=8
   else
   can.y+=8
   end
 		
 elseif location =="tavern" then
 sfx(22)
 	wipe(true)
 	cellx = 101
 	celly = 26
 	sx = 25
 	sy = 25
 	celw = 12
 	celh = 6
 	world="tavern"
 	can.x = 65
 	can.y = 55
 	teleportworked = true
 elseif location =="town" then
  sfx(22)
  wipe(true)
 	cellx = 99
 	celly = 0
 	sx = 0
 	sy = 0
 	celw = 14
 	celh = 20
 	can.x = 50
 	can.y = 100
 	world="town"
 	teleportworked = true

 elseif location =="castle" then
  sfx(22)
  wipe(true)
 	cellx = 113
 	celly = 2
 	sx = 0
 	sy = 0
 	celw = 14
 	celh = 20
 	can.x = 50
 	can.y = 109
 	world="castle"
 	teleportworked = true
 	
 elseif location =="cavern" then
  sfx(22)
  wipe(true)
 	cellx = 86
 	celly = 55
 	sx = 25
 	sy = 25
 	celw = 12
 	celh = 9
 	can.x = 58
 	can.y = 70
 	world="cavern"
 	teleportworked = true

 elseif location =="cave" then
  sfx(22)
  wipe(true)
 	cellx = caveids[newloc-4][1]
 	celly = caveids[newloc-4][2]
 	sx = 0
 	sy = 0
 	celw = 20
 	celh = 20
 	can.x = 58
 	can.y = 109
 	world="cave"
 	teleportworked = true
 	
 elseif location =="capitol" then
  sfx(22)
  wipe(true)
 	cellx = 85
 	celly = 30
 	sx = 0
 	sy = 0
 	celw = 14
 	celh = 20
 	can.x = 50
 	can.y = 100
 	world="capitol"
 	teleportworked = true
 elseif location =="c_castle" then
  sfx(22)
  wipe(true)
 	cellx = 99
 	celly = 32
 	sx = 0
 	sy = 0
 	celw = 14
 	celh = 20
 	can.x = 50
 	can.y = 100
 	world="c_castle"
 	teleportworked = true
 elseif location =="megas" then
  sfx(22)
  wipe(true)
 	cellx = 85
 	celly = 14
 	sx = 0
 	sy = 0
 	celw = 14
 	celh = 20
 	can.x = 50
 	can.y = 100
 	world="megas"
 	teleportworked = true 	
	end

	if teleportworked then
	
		add(oldlocs,
		{oldx,
		oldy,
		oldworld,
  oldcellx,
  oldcelly,
  oldsx,
  oldsy,
  oldcelw,
  oldcelh
		})

 
	end

end

function xywithin(x,y,box)
if flr(x+4) >= box[1]*8 then
		if flr(x)<= box[3]*8 then
			if flr(y+4)>=(box[2]*8) then
				if flr(y)<=(box[4]*8) then
					return true
				end
			end
	 end
	end
	return false
end




-->8
-- lots of useful stuff here
-- taken from harraps post:
-- https://www.lexaloffle.com/bbs/?tid=2951
function copy(o)
  local c
  if type(o) == 'table' then
    c = {}
    for k, v in pairs(o) do
      c[k] = copy(v)
    end
  else
    c = o
  end
  return c
end
-->8
function useitem()
local item = 
	menuscreen[2].text[selectid]
 
 if item[1] == "red potion" then
  sfx(18)
  dropitem(selectid)
  statuseffects.redpotion[1] = true
  statuseffects.redpotion[2] = time()
  can.speed*=1.5
 elseif item[1] == "ether" then
  if battlestats[1].mp>=100 then
   sfx(23)
  else
   battlestats[1].mp+=10
   if battlestats[1].mp > 100 then
   battlestats[1].mp = 100
   end
   sfx(24)
   dropitem(selectid)
  end
 elseif item[1] == "health potion" then
  if battlestats[1].hp>=100 then
   sfx(23)
  else
   battlestats[1].hp+=10
   sfx(24)
   if battlestats[1].hp > 100 then
  	 battlestats[1].hp = 100
   end
   dropitem(selectid)
  end
 end
end

function dropitem(id)
  if menuscreen[2].text[id][4][3] <=1 then
   del(menuscreen[2].text,
   menuscreen[2].text[id])
   del(menuscreen[2].icons,
   menuscreen[2].icons[id])
   menuscreen[2].len-=1
  else
  menuscreen[2].text[id][4][3]-=1
  end
end

function iteminmenu(item)
	for i=1, #menuscreen[2].text do
	 if menuscreen[2].text[i][1] == item then
	 	return true
  end
  
	end
	return false

end

function geticon(name)
 icon = 1
 if name == "red potion" then
  icon= 123
 elseif name == "ether" then
  icon=124
 elseif name == "health potion" then
  icon=125
 elseif name == "lunar sword" then
  icon=068  
 end
 return icon
end

function additem(name)
 local back = copy(menuscreen[2].text[#menuscreen[2].text]) 
 del(menuscreen[2].text,menuscreen[2].text[#menuscreen[2].text])

	for i=1, #menuscreen[2].text do
	 if menuscreen[2].text[i][1] == name then
   menuscreen[2].text[i][4][3]+=1
   
   add(menuscreen[2].text,back)
			
			return 
  end 		
	
	end

 --if it is here, the 
 --item is not in inventory
 icon = geticon(name)
 name ={
 name,
 -1,
 {true,2},
 {false,4,1} 
 }
 add(menuscreen[2].text,name)
 add(menuscreen[2].icons,icon)
 menuscreen[2].len+=1
 add(menuscreen[2].text,back)
end


-->8

nr_of_npcs = 19

function randomcolors()
 plt = {}
 skin = {4,15,2,14}
 i = flr(rnd(#skin))+1
 add(plt,{11,skin[i]})
 
 clothes = {1,3,6,7,8,9,10,12,13} 

 i = flr(rnd(#clothes))+1
 add(plt,{13,clothes[i]})
 
 i = flr(rnd(#clothes))+1
 add(plt,{1,clothes[i]})
 
 return plt
end

function addvillager(x,y,w,lvl)
 spts = {
 {119,119,120,120},
 {89,89,90,90}
 }
 
 dia = 
 {
 "oh no, it's\nyou again",
 "get away from me!",
 "get out of\nmy sight",
 "you're not\nwelcome here",
 "oh it's you \nagain!",
 "welcome back!",
 "good to see a \nfamiliar face!",
 "don't i know you \nfrom somewhere?",
 "another yellow\nwizard!?",
 "greetings!",
 "nice to see \nyou again",
 "wasn't i just \ntalking to you?",
 "why do you always \nhang around here?",
 "do you need something?"
 }

 nr_of_npcs+=1
 n = copy(npc)
 n.name = "villager"
 n.msg = ": "..dia[flr(rnd(#dia)+1)]
 
 n.x = x
 n.y = y
 n.world = w
 n.lvlid = lvl
 n.interact = "talk"
 i = flr(rnd(2))+1
 n.frames = spts[i]
 n.plt = randomcolors()
 n.randommoves = true
 add(npcs,n)
end

function kill(id)
 npcs[id].frames = {121,121,122,122}
 npcs[id].alive = false
 if (not (npcs[id].name == "")) then
 	npcs[id].name = npcs[id].name.."(rip)"
 end
 if(npcs[id].msg == "") then
 	npcs[id].msg = ": boo!"
 end
 npcs[id].interact = "talk"
 
end
  npc = {}
  npc.frames = {64,65,66}
  npc.frameid = 1
  npc.speed = 0.5
  npc.lvlid = 1
  npc.x = 19*8
  npc.y = 15*8
  npc.randommoves = false
  npc.path={{{19*8,15*8}}}
  npc.futurepath = {}
  npc.faceleft = false
  npc.msg = ""
  npc.name = ""
  npc.msgyoffset = 0
  npc.msgxoffset = 0
  npc.battlestats = {}
  npc.interact = "battle"
  npc.world = "overworld"
  npc.battlestats.attack = 5
  npc.battlestats.magic = 5
  npc.battlestats.defense = .75
  npc.battlestats.hp = 100
  npc.battlestats.mp = 100
  npc.alive = true
  npc.plt = nil
function initnpcs()
 npcs ={}
 intersecting = {}
 for n=1,nr_of_npcs+copycount do 
  n = copy(npc)
  add(npcs,n)
 end
 
 for n=nr_of_npcs+1,nr_of_npcs+copycount do 
  x = rnd(500)
  y = rnd(500)
  while  (isblocked(x,y)) do
		 x = rnd(500)
   y = rnd(500)
  end
 	npcs[n].x = x
  npcs[n].y = y
  local txt = generatecansentences()
  npcs[n].msg = txt[2]
  npcs[n].interact = "talk"
  npcs[n].randommoves = true
  npcs[n].name = txt[1]
		npcs[n].msgyoffset = -10
		npcs[n].msgxoffset = -20
  npcs[n].world = "overworld"
  npcs[n].alive = true		
 end
 --grimhoof 
 
 npcs[1].frames = {96,96,97,97}
 npcs[1].x= 19*8
 npcs[1].y= 15*8
 npcs[1].name = "grimhoof"
 npcs[1].path={
 {19*8,15*8},
 {15*8,19*8},
 {15*8,22*8},
 {15*8,22*8}, 
 {18*8,22*8},
 {21*8,18*8}, 
 }
 
 
  --ogre  
 npcs[2].frames = {87,87,88,88}
 npcs[2].x= 30*8
 npcs[2].y = 20*8
 npcs[2].name = "ogre"
 npcs[2].msg = ": top o' the \nmornin' to ya"
 npcs[2].interact = "talk"
 npcs[2].path={
 {30*8,20*8},
 {34*8,20*8},
 {38*8,24*8},
 {38*8,27*8},
 
 {40*8,29*8},
 {40*8,40*8},
 
 {37*8,43*8},
 {37*8,44*8},
 {26*8,44*8}  
 }
 
 --lady outside castle belaroth
 npcs[3].frames = {89,89,90,90}
 npcs[3].plt = randomcolors()
 npcs[3].x= 57*8
 npcs[3].y= 28*8
 npcs[3].name = "villager"
 npcs[3].path={
 {57*8,28*8},
 {65*8,28*8} 
 }


 --skeleton
 npcs[4].frames = {71,71,72,72}
 npcs[4].x= 120*8
 npcs[4].y= 43*8
 npcs[4].world = "cave"
 npcs[4].name = "clax"
 npcs[4].lvlid = 5
 npcs[4].msg = ": fight me!"
 npcs[4].msgxoffset-=20
 npcs[4].path={
 {120*8,43*8},
 {121*8,43*8}
 }
 
 --guy in the southeast
 npcs[5].frames = {103,103,104,104}
 npcs[5].x= 45*8
 npcs[5].y= 53*8
 npcs[5].name = "tradesman"
 npcs[5].path={
 {45*8,53*8},
 {45*8,46*8},
 {44*8,46*8} 
 }
 
 --witch outside terrakis
 npcs[6].speed =.25
 npcs[6].frames = {91,91,92,92}
 npcs[6].x= 22*8
 npcs[6].y= 26*8
 npcs[6].plt = randomcolors()
 npcs[6].name = "trainee\nwizard"
 npcs[6].path={
 {22*8,26*8},
 {25*8,29*8},
 {25*8,30*8},
 {22*8,30*8} 
 }
 
 
   --pinglet  
 n = npcs[7]
 n.frames = {105,105,106,106}
 n.x= 35*8
 n.y = 47*8
 n.name = "pinglet"
 n.randommoves = true
 n.interact = "battle"
 
    --arnie  
     --103*8,28*8)
 n = npcs[8]
 n.frames = {81}
 n.x= 102*8
 n.y = 28*8
 n.name = "arnie"
 n.msg = ": hi"
 n.path={
 {102*8,28*8}
 }
 n.interact = "talk"
 n.world = "tavern"
 n.lvlid = 3
 
    --chunt  
 n = npcs[9]
 n.frames = {82}
 n.x= 103*8
 n.y = 29*8
 n.name = "chunt"
 n.msg = ": get wet"
 n.path={
 {103*8,29*8}
 }
 n.interact = "talk"
 n.world = "tavern"
 n.lvlid = 3
 
 
    --usidore
 n = npcs[10]  
 n.frames = {80}


 n.x= 103*8
 n.y = 27*8
 n.name = "usidore"
 n.msg = ": i am usidore,\nwizard of the 12th realm \nof ephysiyies,\nmaster of light and..."
 n.path={
 {103*8,27*8}
 }
 n.interact = "talk"
 n.world = "tavern"
 n.lvlid = 3
 
 --blemish 
 n = npcs[11]
 n.frames = {119,119,120,120}
 n.x= 111*8
 n.y = 27*8
 n.plt = randomcolors()
 n.name = "blemish"
 n.msg = ": greetings."
 n.randommoves = true
 n.interact = "shop"
 n.world = "tavern"
 n.lvlid = 3
 n.storeid=1
 

 --ooze
 n = npcs[12]
 n.frames = {116,116,116,117,117,117}
 n.x= 115*8
 n.y= 52*8
 n.world = "cave"
 n.name = "ooze"
 n.lvlid = 6
 n.msgxoffset-=20
 n.path={
 {115*8,52*8},
 {121*8,52*8}
 }
  --mimic
 n = npcs[13]
 n.frames = {78}
 n.x= 103*8
 n.y= 54*8
 n.world = "cave"
 n.name = "mimic" 
 n.lvlid = 8
 n.path={
 {103*8,54*8}
 }
 
  --mimic
 n = npcs[14]
 n.frames = {78}
 n.x= 108*8
 n.y= 54*8
 n.world = "cave"
 n.name = "mimic" 
 n.interact = "chest"
 n.item = "lunar sword" 
 n.lvlid = 8
 n.path={
 {108*8,54*8}
 } 
 
 
   --king
 n = npcs[15]
 n.frames = {111}
 n.x= 119*8
 n.y= 8*8
 n.world = "castle"
 n.name = "good king belaroth" 
 n.interact = "talk"
 n.msg = ":\nhowdy"
 n.lvlid = 4
 n.path={
 {119*8,8*8}
 } 
 
 n = npcs[16]
 n.frames = {73,73,74,74}
 n.x= 117*8
 n.y= 7*8
 n.world = "castle"
 n.lvlid = 4
 n.name = "raspberry\nberet"
 n.interact = "battle"
 n.path={
 {117*8,7*8},
 {121*8,7*8} 
 }
 
 npcs[17] = copy(npcs[16])
 n = npcs[17]
 n.x= 121*8
 n.y= 10*8
 n.path={
 {121*8,10*8},
 {117*8,10*8} 
 } 
 
 n = npcs[18]
 n.frames = {119,119,120,120}
 n.x= 93*8
 n.y= 59*8
 n.world = "cavern"
 n.lvlid = 11
 n.plt = randomcolors()
 n.name = "tomblain\nbelaroth"
 n.msg = ":\n i am preparing\n for the batdance "
 n.interact = "talk"
 n.randommoves= true
 
 --redpotion dealer 
 n = npcs[19]
 n.frames = {89,89,90,90}
 n.x= 101*8
 n.y = 38*8
 n.name = "shopkeeper"
 n.msg = ": greetings."
 n.randommoves = true
 n.interact = "shop"
 n.world = "c_castle"
 n.lvlid = 10
 n.plt = randomcolors()
 n.storeid=2 
 
 addvillager(88*8,39*8,"capitol",9)
 addvillager(92*8,37*8,"capitol",9)
 addvillager(109*8,10*8,"town",2)
 addvillager(103*8,6*8,"town",2)

 end

function openshop(shopid)
 menuid = shopid+3
 gamestate = 2
end

function openchest(item)
 additem(item)
 dialogue = "you found a "..item
 gamestate = 5
end

function updatenpcs()
 for n=1, #npcs do
  if npcs[n].world == world then
   updatesprite(npcs[n])
   movesprite(npcs[n])
  end
 end
 
end

function drawnpcs()
 if (#intersecting >0) then 
 	for n=1, #intersecting do
   interact(npcs[intersecting[n]])
 		end
 end
  intersecting = {}
  for n=1, #npcs do
   if npcs[n].world == world and
   (npcs[n].lvlid == levelid) then
  	drawsprite(npcs[n].frames[npcs[n].frameid],
  	npcs[n].x,
  	npcs[n].y,
  	npcs[n].faceleft,
  	npcs[n].plt)
  	if  arespritesintersecting(can.x,can.y,npcs[n].x,npcs[n].y,true) then
   		add(intersecting,n)
		 end
 end
 end
end

function interact(n)
 local tx = 0
 local ty = 0

  if (n.interact == "battle")or
   ((statuseffects.redpotion[1] == true 
   and n.alive == true))then
   drawsprite(93,n.x+6,n.y-8,false)
  elseif n.interact == "talk" then
  drawsprite(109,n.x+6,n.y-8,false)
  elseif( n.interact =="shop") or
   ( n.interact =="chest")then
  drawsprite(77,n.x+6,n.y-8,false)
  end

end

function selectnpc()
	if #intersecting >0 then
 	local n = npcs[intersecting[1]]
 	if (n.interact == "battle") or
 	(statuseffects.redpotion[1] == true 
  and n.alive == true) 	
 	then
 	 startbattle(intersecting[1])
 	elseif n.interact =="talk" then
 	  sfx(26)
 	  dialogue = n.name..n.msg
 	 gamestate = 5
  elseif n.interact =="shop" then
 	  sfx(26)
 	  openshop(n.storeid)
 	elseif n.interact =="chest" then
 	  n.frames = {79}
 	  n.interact = ""
 	  sfx(27)
 	  openchest(n.item)
 	end
 end
end




function intersect_box(x1,x2,y1,y2)
 local max1 = {x1+8,y1+8}
 local max2 = {x2+8,y2+8}
   if 
   --x intersect
   ( ((x1<=x2) and (x2<=x1+8))
   or  ((x2<=x1) and (x1<=x2+8))
   )
   and
   (
      ( ((y1<=y2) and (y2<=y1+8))
   or  ((y2<=y1) and (y1<=y2+8))
   )

   )
  then
 
   return true
  end
 return false
end



function arespritesintersecting(x1,y1,x2,y2,isplayer)
 x1 = getabsoluteposition(x1,y1,world,isplayer)
 y1 = x1[2]
 x1 = x1[1]

 x2 = getabsoluteposition(x2,y2,world,false)
 y2 = x2[2]
 x2 = x2[1]

 if intersect_box(x2,x1,y2,y1)
  then return true 

   else

 return false
 end
    
end


function generatecansentences()
   nounnum = flr(rnd(#nouns)+1)
   verbnum = flr(rnd(#verbs)+1)
   noun = nouns[nounnum]
   verb = verbs[verbnum]
   life = flr(rnd(10000))
   sentence = ":\n".."i just "..verb.."\n"..noun
   return {("can nr."..life),sentence}
 end


function drawsprite(sp,x,y, faceleft,plt,absolute)

 if plt then
  for i=1, #plt do
  	pal(plt[i][1],plt[i][2])
  end
 end

 if absolute then
 		spr(sp,
  	x,
  	y,
  	1,1,faceleft,false)
 elseif world == "overworld" then
		spr(sp,
  	x+mapxoffset,
  	y+mapyoffset,
  	1,1,faceleft,false)
 else
  spr(sp,
    (x/8-cellx) *8+sx,
    (y/8-celly) *8+sy,
    1,1,faceleft,false)
 end
 pal()
end
-->8

function movesprite(sprite)
 if sprite.randommoves then dorandommoves(sprite)
 else  followpath(sprite)
 end
end

function dorandommoves(sprite,player)
 x = rnd(7)
 y = rnd(7)
 
  if x >2 then
  	xmove = 0
  elseif x<1 then
  	xmove=-sprite.speed
  elseif x>1 then
  	xmove = sprite.speed
  end
  
  if y >2 then
   ymove = 0
  elseif y<1 then
  	ymove = -sprite.speed
  elseif y>1 then
  	ymove = sprite.speed 
  end

	 if not (isblocked(sprite.x+xmove,sprite.y+ymove)) then
	 	sprite.x +=xmove
	 	sprite.y +=ymove
	 	--need blocking map elem check here
	 elseif player and world == "overworld" and
	  not (isblocked(sprite.x+xmove-mapxoffset,sprite.y+ymove-mapyoffset)) then

	 	sprite.x +=xmove/sprite.speed 
	 	sprite.y +=ymove/sprite.speed 
	 	
	 	if sprite.x>55 then sprite.x=55
	 	elseif sprite.x<45 then sprite.x=45 end
	 	if sprite.y>55 then sprite.y=55
	 	elseif sprite.y<45 then sprite.y=45 end
	 	
	 end
end

function followpath(sprite) 
 if (sprite.randommoves) then
 //noop
 else
  
  if #sprite.path == 0 then
  	futuretocurrentpath(sprite)
  end
  
 	activepath = sprite.path[1]
 	
 	newx = 1
 	newy = 1
 	sprite.faceleft = false
 	if (activepath[1]-sprite.x)<0 then
 		newx = -1
 		sprite.faceleft = true
 	elseif activepath[1] == sprite.x then
 		newx=0
 	end
 	
 	if (activepath[2]-sprite.y)<0 then
 		newy = -1
 	elseif activepath[2] == sprite.y then
 		newy=0
 	end
 	
 	
 	if newx == 0 and newy==0 then
  	add(sprite.futurepath,activepath)
  	del(sprite.path,activepath)
 	end
 	
 	sprite.x += newx * sprite.speed
 	sprite.y += newy * sprite.speed
 	end
end


function futuretocurrentpath(sprite)
 len = #sprite.futurepath
 while len!=0 do
 
 	add(sprite.path,sprite.futurepath[len])
 	len-=1
 	
 end
sprite.futurepath={}
end


__gfx__
000000007777777744333333333333443333333bb333333bb33333331f1f1f111f11f1f111f11f11577777753242242358222285333333333333333333333333
00000000777777774443333333333444333333bbbb3333bbbb333333f11111111111111111111111777777772224422258228285333333222233332222333333
007007007777777734443333333344433333333bb333333bb33333331111111111111111111c1111677777763244442358222285333333244233332442333333
00077000777777773344444444444433333bb3bbbb3bb3bbbb3bb333f111c1111111111111c1c11f766666673244442358282285332222444422224444222233
0007700077777777333444444444433333bbbb3223bbbb3223bbbb33111c1c11111c111111111111767dd7672422224258222285332442444424424444244233
00700700777777773333333333333333333bb332233bb332233bb333f111111111c1c1111111111f677dd7763224422358228285324444244244442442444423
0000000077777777333333333333333333bbbb3333bbbb3333bbbb3311111111111111111111111157dddd753244442358222285244444422444444224444442
00000000777777773333333333333333333223333332233333322333f111111111111111111111115d6666d52444444258282285444224444442244444422444
442442446566533333333333333566563555355555535553ffffffff111111111111111111111111333333333333333333333333332442444424424444244233
3244442365565333b3b33333333565563565556556555653fffffffa111111111111111111111111333333333333333333333333324444222244442222444423
b344443b656653333b333333333566563566666666666653ffaffffff1111111111c1111111c111f333333333333333333333333244444244244442442444442
b332233b65565b3333333333b3b565563561616666161653fffffffa1111c11111c1c11111c1c111444443333332233333344444244222444422224444222244
bb3333bb656653b3333333333b3566563566666666666653ffafffff111c1c11111111c111111111444444333324423333444444332442444424424444244233
333bb333655653333333b3b3333565563566664444666653fffffafff111111111111c1c1111111f333344433244442334443333324444224244442442444423
b33bb33b6566533333333b33333566563566664554666653fffffffa11111111111c111111111111333334443244442344433333244444442444444224444442
b3bbbb3b6556533333333333333565563566664554666653ffffffff1111111111c1c11111111111333333442444444244333333244224442442244224422442
333333937777777777777777777777773332233bb332233bb3322333111111111111111111111111222222222222222222222222332442444424424444244233
33333999c7777777c7777c77cc777cc7333223bbbb3223bbbb322333f111111111111c111111111f2eeeeeeeeeeeeeeeeeeeeee2324444222244442222444423
66633444ccc77777ccc7ccc7ccccccc73333333bb333333bb3333333111111111111c1c111c111112ee2eee2eee2eeee2eee2ee2244444244244442442444442
444334547cccccccc7c77cc7ccccccc7333bb3bbbb3bb3bbbb3bb33311111111111111111c1c111f2ee2eee2eee2eeee2eee2ee2244222444422224444222244
454222337cccc7ccc7c7ccccc7cccccc33bbbb3223bbbb3223bbbb33f11111111c1111111111111199e2eee2eee2eeee2eee2e99332442444424424444244233
111555337c7cc7ccc7c7cc7cc7cccc7c333bb332233bb332233bb33311111111c1c111111111111f092eeee2eee2eeee2eeee290324444244244442442444423
444515337c7cc7ccccc7cc7cc7cccc7c33bbbb3333bbbb3333bbbb331111111111111111111111110099eeeeeeeeeeeeeeee9900244444422444444224444442
45433333cc7cccc7cccccccccccccccc333223333332233333322333f11f1f1111f11f1f11f11f1f000999999999999999999000244444424444444424444442
b332233b3b3b3333333333333334443333333333333444333334443333344433dd5dd5555dddddd5443333333333334433344333333333443334443344333333
bb3223bb33b33333333b3b3333344433333b3b33333444333334443333344433dd5555d55dd66dd5444333333333344433344333333334443334443344433333
b333333b333333333333b333333444333333b3333334443333344433333444335555d5d556dddd65344433333333444333344333333344433334443334443333
bb3bb3bb4444444444444433b3b44433333444443334444444444433444444335d5dd5555d6666d5334443333334443333344333333444333334443333444433
23bbbb3244444444444444333b344433333444443334444444444433444444335d5dd5dd5dddddd5333444333344433333444333333443333334443333344433
233bb332333333333334443333344433333444333333333333333333333333335d5555dd5dd66dd5333344433444333334443333333443333333444333344433
33bbbb333333b3b333344433333444333334443333b3b333333b3b3333333b3b55ddd55556dddd65333334444443333344433333333443333333344433344433
333bb33333333b33333444333334443333344433333b33333333b333333333b3d5ddd5dd5d6666d5333333444433333344333333333443333333334433344433
09990000099900000999000051515151000600000000000000008000007777700777770000888800008888000000000000000000005555000055550055555555
99999000999990009999900015151515000600000008800000088800007575700757570000245440002454400000000000000000057777550554455051111115
0aaaa0000aaaa0000aaaa00051515151000600000088980008800880007757700775770000274400702444000000000000000000577997755544445551111115
061f1600061f1600061f160015151515000600000089980000800800070750070075000000676640766666000000000000000000579aa9755444444551111115
06fff60006fff60006fff6f051515151000600000089880000800800007777707777770000d4da0440ddad00000000000000000057799775555aa555555aa555
099699f409969f400996994015151515005550000008800000888000005775000057557000656600506666000000000000000000577777555444444554444445
f999990409f99940f999990451515151000900000000000008080000007557707775770000666110011666000000000000000000577555005444444554444445
09292904092999000999290415151515000500000000000000000000077000007000077000110000000001100000000000000000755000005555555555555555
01110000002220000011150088988888000000f000000000ccc00000000dd000000dd0000055bb000055bb000000000000000000002222000099990000000000
1111100002fff200011151158988888808000fff00000000c00ccc0000dddd0000dddd00005b5bb0005b5bb000555000005550000288882209aaaa9000044000
0cccc0000f1f1f0001111122889898880080fff40000000000cc0cc000dd5dd000dd5dd0005bbb00005bbb0005bbb00005bbb000288585829aa9aaa900644600
061f160000f2f00001777100898989880008ff400c0cc00000c000c000ddd10000ddd10000b111b00bb111000b5b50000b5b5000288858829aaa9aa906999960
06fff6000e222e00115551118888988800f884000c000c00000000c0002dd200002dd20000b1110bb011110005bbb00005bbb0b02885858299aaaa9906997960
011611f4eeeeeee050111105988888980fff400000c0c000cccc00c00d222200002222d0001b11000011110006666b4006666640288888229a9999a906979960
f1111104f11111f00010100088989888fff40000000c0000cc00ccc000dddd0000dddd00001116600661111006b66640b66666042882220009aaaa9006999960
012121040771770005101500888888890f400000000000000cccc00000dd000000d00dd000660000000006600656660006665604822000000099990000666600
0000012000000110556655661dddddddf44444452222222222222222000000000000000000660000000000e04424424444244244005555000055550000aaa000
0000115200001120665566551ddddddd4222222521111111111111120000000000000000006660e00e666e5e2244442222444422057777550577775506444600
0000122210001252556611661ddddddd42222225211555555555511200000000000000000ee66e5eee666eee4244442442444424577777755779977504141400
1122220011222222665511551ddddddd4222222521dddddddddddd120000000000000000eeeeeeeeeee66e00442222444422224457757575579aa97508444800
1222222022222200556611661ddddddd4222222521dddddddddddd120000000000000000eeeeee000eeeeee04424411111144244575757755779977507777780
1222222222222220662266551ddddddd42222225266666666666666200000000000000000eeeeee0050000504241111111111424577777555777775577777778
4022020292009020552455661ddddddd422222252666666666666662000000000000000005000050000000002411111111111142577555005775550045555548
9090090909000090662266551ddddddd45555551266666666666666200000000000000000000000000000000441111111111114475500000755000008dd5dd88
000000004242424222222222dddddddd000000000000000000000000000bbb00000bbb0000006600006666600000000000000000000000005555555500000000
000550004242424244444444dddddddd0003330000333000000b0b00000b5bb0000b5bb060067760067777700004400000044000000440005dd5d55500000000
005555004242444221122222dddddddd0033b330033b33000b000000000bbb00000bbb000067575006757570006446000064460000644600555d55d500000000
055555504442424241144444dddddddd003bbb333bbbbb300000000000ddddd00ddddd0006777760067777600688886006cccc6006bbbb605555555500000000
055555504242424221122222dddddddd03bb8b833bb8b8300b0000b000dbdd0bb0dddd0006755677606755600688786006cc7c6006bb7b601111111100000000
015555104244424244445544dddddddd03bbbbb33bbbbb3000000000001111000011110006776600006766000687886006c7cc6006b7bb601111111100000000
011551104242424222225122dddddddd03bbbbb333bbbb30000b0000001116600661110006760060066660000688886006cccc6006bbbb601111111100000000
010110104242424244445544dddddddd033333330333333000000000006600000000066066600000000000600066660000666600006666001111111181818181
e1e1e1e1e1e1e1e0f04262d0e1e1f142625313131313131313131313131313132121212121212121332121616161616161212121212121218181818181818181
818181818181818181818181810000000000000000e1e1e1f2212121212121d2e1e1e10000000000000000000000000000353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f02121212121212121212121212121212121212121212121332121618181818161212121212161617181818181818181
818181818181818181818181810000000000000000e1e1f12183838383212121d1e1e18383838383838383838383838383353535353535351717353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0f0e0f02121212121332121618121028161616161616161708182828281818181
818181818181818181818181810000000000000000e1e1f2218321218321212121d2e18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f1212121212102212121d2e1e1e1e1e1010362d1e1e1f021212121332121616121c38181808080808080819161616171818181
818181818181818181818181810000000000000000e1f22121838383832121212121d19383838393838383938383839383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f121616161616161612121d1e1e1e1e1035262d1e1e1f22121212133212121c130218181818181818181819161616171818181
818181818181818181818181810000000000000000f1212121212183212126212121d18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f1616170808080806161d0e1e1e1e1e1f02102d1e1f22121212121332121b32121b17282828282828281818180808081818181
818181818181818181818181810000000000000000f12121212621832121c3212121d18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f1616171818181819061d2e2f22121d1f1e0f0d1f22121212121213321b321d0e0f16161616161616172828181818181818181
818181818181818181818181810000000000000000f1212121332183133021212121d18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161718121818191616161616121d1e1f021212121212121212133b3400360d2e1f021212121216161616181818181818181
818181818181818181818181810000000000000000f1212121e32183212126212121d18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161718181218181906170906121d1f121212121212121212121b34003030360d1f121212121212121216161718181818181
818181818181818181818181810000000000000000e1f02121212083212133212121d18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f161617181818121219161729261e2f121212121212121212121b3400303030362d1f121212121212140602161718181818181
818181818181818181818181810000000000000000e1f121212121831313632121d0e19383838393838383938383839383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f1616171818181818191616161612121212121212121212121b321420303030362d1e1e0e0e021212142622161818181818181
818181818181818181818181810000000000000000e1f1212121218321212121d0e1e18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161728281818181926121213321212121212121212121d321212142525252d0e1e1e1e1e1f0e0e0f0212161818181818181
818181818181818181818181810000000000000000e1e1e0f02121832121d0e0e1e1e18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161616172828292616121215313131313131313131313631313a121d0e0e0e1e1e1e1e1e1010101e1e0f161818181818181
818181818181818181818181810000000000000000e1e1e1e1f0218321d0e1e1e1e1e18383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f0616161616161612121d0e0e0e0e0f021212121212121212121a3d1e2f22121d1f1214203030362216181818181818181
81818181818181818181818181000000000000000000000000002121210000000000008383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f02121212121212121d0e1e1e1e1e1e1f0212121212121214060d0e1021323212121212142036221616181818181818181
81818181818181818181818181000000000000000000e10101e2e2e2e2e2e2e2e1e1008383838383838383838383838383353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f0212121212121d0e1e1e1e1e1f021212121212121214062d0e152622133212121212142526221618181818181818181
81818181818181818181818181000000000000000000f10303602121212121d2e1e1000000000000838383000000000000353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e0e0e0e1e1e1e1e1e1e1e0e0e0f02121212121d0e16221212133212121212121212121618181818181818181
81818181818181818181818181000000000000000000f1030303602121212121d2e1353535353535353535353535353535353535353535351717353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e0e0e1f12121212133212121212121616161618181818181818181
81818181818181818181818181000000000000000000f1030352622121212121d1e1353535353535353535353535353535353535353535354646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f02121212133216161616161617081818181818181818181
81818181818181818181818181000000000000000000f14262212121212121d0e1e1353535353535353535353535353535353535354646464646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f12140602133216170808080808181818181818181818181
81818181818181818181818181000000000000000000f12121212121212121d1e1e1353535353535354646353535353535353546464646464646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f042622133216181818181818181818181818181818181
81818181818181818181818181000000000000000000e1f0212121212121d0e1e1e1353535353535354646353535353535353546464646464646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f0212153026181818282818181818181818181818181
81818181818181818181818181000000000000000000e1e1e0f02121d0e0e1e1e1e1353535353546464646464635353535353546464635354646463535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f021216181816161718181818181818181818181
81818181818181818181818181000000000000000000000000002121000000000000353535354646464646464646353535353546463535354646464635353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f08181816161818181618181818181818181
81818181818181818181818181000000000000000000e1e2e2e2e2e2e2e2e2e2e1e1353535464646464646464646463535353546463535353546464646353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f18181818081818161618181818181818181
81818181818181818181818181000000000000000000e1e1e1e1e183838383e1e1e1353535354646464646464646353535353546463535353535464646463535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f18181818181816161818181818181818181
81818181818181818181818181000000000000000000e1e1e183838383838383e1e1353535353546464646464635353535353546464635353535354646463535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e081818181818181818181818181
81818181818181818181818181000000000000000000e1e1838383838383838383e1353535353535354646353535353535353546464646353535464646463535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181818181818181
81818181818181818181818181000000000000000000e183838383838383838383e1353535353535354646353535353535353535464646463546464646353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181818181
81818181818181818181818181000000000000000000e183838383838383838383e1353535353535354646353535353535353535354646464646464646353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e18181818181818181
81818181818181818181818181000000000000000000e1e1838383838383e1e1e1e1353535353535354646353535353535353535353546464646463535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e181818181818181
81818181818181818181818181000000000000000000e1e1e1e18383e1e1e1e1e1e1353535353535354646353535353535353535353535464646353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181
81818181818181818181818181000000000000000000000000008383000000000000353535353535351717353535353535353535353535351717353535353535
__gff__
0100000000000001010101010001010101010001020200010101000100010101020101010000000101010000000101010000000000000000000100000000000000000006000000808080808080000000010101010000008080808080800000000000010200000080808080020200000001000001000000808000000000000100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101013c013c3c3c3c3c3c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101013c013c3c3c3c3c3c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000001e1e1e1e1e1e1e1e1e1e1e1e1e1e000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e010101010101010101010101010101010101010101010101013c3c3c3c3c3c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000001e1e1e2f1212121212122d1e1e1e000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e1e1f12121212121212121d1e1e383838383838383838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e1e2f1212121212121212122d1e383838383838383838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e2f12121212621212121212121d383838383838383838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f12121212123e1212121212121d383838383938383839383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f1212121212123a123c1212121d38383838380c0c0c38383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2101010101010101010101010101010101010101010101010118181818181818181818181818181818181818181818000000000000000000000000000000000000000000001f121262121212123b121212121d38383838380c0c0c38383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e222e0101010101010101010101010101010101010101010118181818181818181818181818181818181818181818000000000000000000000000000000000000000000001f1212123a12123b12121212121d38383838380c0c0c38383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010101181818181818181818181818181818181818000000000000000000000000000000000000000000001e0f1212123a3b1212121212121d3838383838380c3838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2322222223222223010101010101010101010101010101010122181818181818181818181818181818181818000000000000000000000000000000000000000000001e1f121212123f12121212120d1e3838383838380c3838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2e1e1e1e1e1e1f2525122d2e2f282818181818181818220101010101010101010101010101012218181818181818181818181818181818181818000000000000000000000000000000000000000000001e1f1212121233121212120d1e1e3838383838380c3838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e331d1e1e1e1e10252506040506161627282818181818182201010101010101012222220101221818181818181818181818181818181818181818000000000000000000000000000000000000000000001e1e0e0f12123312120d0e1e1e1e3838383839380c3839383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f1e331d1e1e1e102525300d0e0e0e0f1616161627181818181822220101222201010d0f120101181818181818181818181818181818181818181818000000000000000016161616161616161616161616161e1e1e1e0f1233120d1e1e1e1e1e3838383838380c3838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123c1d1e1e1e1e0e0e0e1e1e1e1e1f1220121616272818181804060101121201011d1e0f01011818181818181818181818181818181818181818180000000000000000161818181818181818181818181800000000001212120000000000003838383838380c3838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123b121d2e2e1e1e1e1e1e102d1e1e1f1212121216161627281824260101121201011d1e1f0101120d0f12181818180d0e0e0e0e0e181818181818180000000000000000161818181212121212121818181800002e2e2e2e2e2e2e2e2e2e2e2e383838383838383838383838383800
1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123b120d1e123b1d1e1e1e103030260d1e0e0e0e0e0e0f1616160406122123121201011d1e1f210104101006181818181d1e1e1e1e1e0f1818181818180000000000000000181818121212121212121218181800001f121212121212121212121d000000000038383800000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1f12123b120d2f123b121d1e1f10303026121d1e1e2e2e1e1e1e0e0f120405060405061221231d1e1f1223243030261818180d1e1e1e1e1e1e1f1818181818180000000000000000181818121212121212121212181800001f121212121212121212121d535353535353537171535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1f123d120d1e123b12121d1e2f252526121224252612241d1e1e1e1f12040d0f30302612120d1e1e2f1204123030261818181d1e1e1e1e1e1e1e0f18181818180000000000000000181812121212121212121212121800001f121212121212121212121d536464646464646464535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1f12330d2f123b12120d1e2f12121212121c3131311a121d1e1e1e1f121d1e1e0e0e0f200d2e2e2f120430303025261818181d10101e1e1e1e2f1818181818180000000000000000181212621212121212121212121800001f121212121212121212121d536464646464646464535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1f123e12123b12120d1e2f12123b3f123b12120406123a12121d1e1f121d1e1f16162f0d1e0f12141530303026181818180d1e3030102e2e2e2f18181818181800000000000000001812123e1212621212121212121800001f121212121212121212121d536464535353535353535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1e12123a3d12120d1e2f12123b123e3b121204303006123a3c04100b121d1e1f07161616162d0f121212122618180d0e0e1e10302525061818181818181818180000000000000000181212123a12331212121212121800001f121212121212121212121d536464645353535353535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0f123a12122d2f12123b1212121212303030303006123a24300b120b101617080809162d1e0e0e0e0f1b18122d6b6c2f2526121218181818181818181818000000000000000018121212123a331212121212121800001e0e0e0f12120d0e0e0e0e1e536464646464646464646464646464
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f123a121212123b120d0e0f123030303030303006123f240b120b2616271b121916122d2e2e2e2f181812121212121218181818181818181818181818000000000000000018121212121233621212121212180000000000001212000000000000536464646464646464646464646464
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f10100f123f12123b120d1e1e1e0f04303030303030300633120b120b061616272829160406121b12121812120405050506181818181818181818181818180000000000000000181212121212333c1212121212180000000000000000000000000000535364646464646464646464646464
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f24262d0f3312123a12122d1e1010303030303030303026330d1e1e1f24061616161616042612121212181212243030302612121212181818181818181818000000000000000018181212121233121212120d0f180000717171717171717171717171535353535353535353535353646464
1e1e1e1e1e1e1e1e1e1e101e1e1e1e123a12123c1212123a12122d0f303030303030303030263e0b12120b122405050505052612121212121812121212242612123312121818181818181818180000000000000000181812121212331212120d1e2e180000717171717171717171717171536464646464646464646464646464
1e1e1e1e1e1e1e1e1e10301e1e1e1e06123f3b12120d0f123a12121e1f242525252525252526123a202012121212121212121212121c3131313131313131313131371218181818181818181818000000000000000018181818181233120d0e1e1e2e180000717171717171717171717171536464646464646464646464646464
1e1e1e1e1e1e1e1f103030102d1e2430063312120d1f1415123f122d1e0e0e0e0e0e0e0f1b0406123f12121212121212121212123b120406121212121212121818181818181818181818181818000000000000000000000000001212120000000000000000717171717171717171717171536464645353535353535353535353
1e1e1e1e1e1e1f10303030051d1e1f302633120d1e1f1231123e12122d1e1e1e1e1e1e2f1204302633121212121212121212123d12040506181818181818181818181818181818181818181818000000000000000000000000000000000000000000000000717171717171717171717171536464646464646464535353535353
1e1e1e1e1e1e1f30303030061d1e1f302633122d1e1e0e0e0f123a12122d1e1e1e1e2f12122425263331313131313131313131361212121218181818181818181818181818181818181818181800000000000000001e1e1e1e1e1e1e1e1e1e1e1e1e1e0000000000000012120000000000536464646464646464535353535353
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100200c233116330c233116330c2331920031610000000c2331163311633116330c2330000031610000000c233316000c233116330c2331160311633316100c2333161011633316000c233116001163311633
0110000024050240002d0502d0001f0502d0502d0002f0500000024050240502f0502d0502d0501f050000002d0500000000000000000b0000000000000000000000000000090000000000000000000000000000
01100000240502400029050290502805029050290002b050000002d0502d0502b0502905029050280500000029050000000000000000000000000000000000000000000000000000000000000000000000000000
01100000211501a15019100191501a150000001c1501d150000001c1501a15019100191501a150000001c1501d150000001a150191501915000000000001a1001a15019000191501a150000001c1501d15000000
0110000021150111501c1001c1501d150000001f15021150000001f1501d150000001c1501d150000001f15021150000001d1501c1501c1500000021100211501d150000001c1501d1501d1001f1502115000000
011000001c1501d150000001f15021150000001f1501d150000001f1501c1501c15000000000003210032150000003215032150000002b1502915000000281502615000000281502915000000281502615000000
001000001f1502115000000221502415000000221502115000000221501f1501f15000000000002d1502d150000002d1502d150000002e1502d150000002b15029150000002b1502d150000002b1502915000000
001000002b150251502515000000211002115026150261002615026150261002515026150000002815026150000002b1502d150000002b1502915000000281502a1502a1502a1500000000000000000000000000
001000002815028150281500000000000000001d150291001d1501d150291001c1501d150000001f15021150000002215024150000002215021150000001f1502115021150211500000000000000000000000000
011900000c7230c5530c7230c7230c7230c7230c7230c5530c7230c7230c7230c7230c5530c7230c7230c7230c5530c7230c7230c7230c5530c7230c7230c7230c5530c7230c7230c7230c5530c7230c7230c723
01190000215301a53019100195301a530000001c5301d530000001c5501a55019100195501a550005001c5501d550005001a550195501955000500005001a5001a55019500195501a550005001c5501d5501a100
0114000015150151501815018150181501a1501a1501c1501c1501c1501d1501c1501c1501a1501a1501a15017150171501315013150131501515017150171501815018150181501515015155151501515015150
0114000014150151501515017150171501715014150141501015010150101501015515150151501815018150181501a1501a1501c1501c1501c1501d1501c1501c1501a1501a1501a15017150171501315013150
011400001515017150171501815018150181501515015155151501515015150000001765500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000018066180661c06629066290661c0661806618066190001a0000f0000f0000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001e650112501f6501f6501925016250162501a6501a6501a6502225022650226501a6501b6501b65014250282502d6502d6502d6502d6502c650102502b6502a6501d2500b2501b6501b6500c6500a650
00010000107501075010750127501475016750197501d75021750257502a7502e7502e7502d7502a750297502675023750217501e7501b7501875016750157501475013750137501375013750137501375000000
010300002305023050100501005023000180002300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a6572a6572a6572a65720657206572065720657156571565715657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0117000015615187230c6150c7530c7030c7001d3000000010300103000c6031870310300000000000000000000000000010300000000c7030c60500000000000000000000000000000000000000000000000000
01190000186550c6550c6000c7030c7030c7001d3000000010300103000c6031870310300000000000000000000000000010300000000c7030c60500000000000000000000000000000000000000000000000000
011700000c655186530c6050c7030c7030c7001d3000000010300103000c6031870310300000000000000000000000000010300000000c7030c60500000000000000000000000000000000000000000000000000
011000000c2560c253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000024550241503c1500c1500c1000c1000c1000c1000c1000c1000c1000c1001e5001e5001e5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000a2500b2500e250102501325016250192501e250222002c200312003c2003f2003f2003f2003f2003f200000000000000000000000000000000000000000000000000000000000000000000000000000
01050000105520f5520f5521812218122181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000024150241502615026150291502915028150281502b1002810028150281502915029150291500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001b5501b5501b5502255022550225502255029550295502955029550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000000033650316502f6502b6500000026650226501e6501a650166501465012650106500f6500f650186501c6502065022650296502d6502f650316500000000000000000000000000000000000000000
__music__
00 02034044
01 04054344
00 06074344
02 08094344
00 0a0b4344
00 0a024344
01 0c424344
00 0d424344
02 0e424344

