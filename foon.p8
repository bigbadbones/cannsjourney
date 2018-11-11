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
 copycount = 10
 can = {}
 can.x = 50
 can.y = 50
 can.frames = {64,65,66}
 can.frameid = 1
 can.speed = 1
 can.size = {8,8}
 can.faceleft = false
 
 animation_ongoing = false

 gamestate = 0
	mapnames_enabled = false
 sentence  = ""
 menuid = 1
 selectid = 1
 townid = 1
 
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
 {"lunar sword",0},
 {"deed to usidore's hat",0},
 {"back",1}
 }
 menuscreen[2].icons =
 {
 68,
 84
 }
 
 
 menuscreen[3] = {}
 menuscreen[3].len = 3
 menuscreen[3].icons ={}
 menuscreen[3].text =
 {
 {"map names ",-1,{false,1},{true,0}},
 {"back",1}
 }


 
 
 music(1)
 canmemory ={}
 oldlocs = {}
	currtime = time()
	
	updatetime = 0
	stringlist={}
	drawtext = false
	stringstodraw={
	{"hogsface",{36*8,20*8}},	
	{"capitol\ncity",{39*8,26*8}},
	{"meagas",{45*8,33*8}},
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
 {"terenth",{56*8,28*8}},
 {"gratax",{42*8,45*8}},
 {"little bowl",{23*8,42*8}},
 {"big bowl",{17*8,45*8}},
 {"malfoi",{46*8,52*8}},
	{"terr'akkas",{21*8,28*8}},
	{"hawai",{18*8,39*8}}
	}
	cellx = 116
	celly = 8
	sx = 25
	sy = 25
	celw = 12
	celh = 6	
	mapxoffset = -8 * 29
	mapyoffset = -8 * 16
	world="overworld"
 inittext()
 initnpcs()
 init_mapelems()
end


function perform_referenced_functions(id)
 if id == 0 then 
 	return togglemap()
 elseif id == 1 then 
 	return getmapstate()
 end
end
 
  



function isblocked(x,y)
  local tilex = ((x-(x % 8) ) / 8)
  local tiley = ((y-(y % 8) ) / 8) 
 	if (fget(mget(tilex,tiley) , 0)) then
 	 return true
 	end 
 	return false
end

function getmapflags(sprite,xoffset,yoffset)
 if world == "overworld" then
  x = sprite.x + xoffset +(-mapxoffset)
  y = sprite.y + yoffset +(-mapyoffset)
  xmax = x + sprite.size[1]
  ymax = y + sprite.size[2]
  tilex = ((x-(x % 8) ) / 8)
  tiley = ((y-(y % 8) ) / 8) 
  tilexmax = ((xmax-(xmax % 8) ) / 8)
  tileymax = ((ymax-(ymax % 8) ) / 8) 
 else 
  x = sprite.x + xoffset-sx
  y = sprite.y + yoffset-sy
  xmax = x + sprite.size[1]
  ymax = y + sprite.size[2]
  tilex = ((x-(x % 8) ) / 8)+cellx
  tiley = ((y-(y % 8) ) / 8)+celly
  tilexmax = ((xmax-(xmax % 8) ) / 8)+cellx
  tileymax = ((ymax-(ymax % 8) ) / 8) +celly
	end 
	 
 field = fget(mget(tilex,tiley) ) 
 field = bor (field,fget(mget(tilexmax,tileymax)))
 field = bor (field,fget(mget(tilex,tileymax)))
 field = bor (field,fget(mget(tilexmax,tiley)))
 return field

end


function updatesprite(sprite)
 sprite.frameid+=1
 if sprite.frameid > #sprite.frames then
 	sprite.frameid = 1
 end
end

function _update()
 if not animation_ongoing then
 
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
  end
 end
end

function _draw()
 if animation_ongoing then
 	animate()
 else
 	if gamestate==0 then
 		draw_titlescreen()
  elseif (gamestate==1) then
   draw_worldscreen()
   updatemapinteracts()
 	elseif gamestate ==2 then
 	 draw_menuscreen()
 	elseif gamestate ==3 then
 		draw_battlescreen()
  elseif gamestate ==4 then
   draw_gameover()
  end
 end
end
-->8



function inittext()
 verbs = 
 {"killed",
  
 "played mittens with",
 "sent a letter to",
 "was killed by",
 "married", 
 "survived a date \n to makeout point with",
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
 "farted within\nearshot of",
 "shook my \nfinger at",
 "broke up with",
 "sternly lectured",
 "sneezed on",
 "fornicated with",
 "chanted \nspellcraft with",
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
 "the cavern \nof many tomorrows",
 "the population\nof hawai",
 "the waving woman",
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
 "dq",
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
 "a sphere of \n solid buttholes",
 "an innocent shopkeeper",
 "a tavern wench",
 "an elderdly scholar",
 "a thousand bees", 
 "the pyramid of confusion",
 "a harpie",
 "the hottest shark \nhe's ever seen",
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

end

-->8

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



function attack(idsource,iddest)
	source = battlestats[idsource]
	dest = battlestats[iddest]
	damage =  source.attack * dest.defense
	dest.hp -= damage
    start_animation(attack_anim,iddest)
	battleturn =  not battleturn
	if dest.hp <0 then dest.hp = 0 
	 return true 
	else return false
	end
end


attack_anim = {}
attack_anim.running = false
attack_anim.lastupdate = nil
attack_anim.duration = .2
attack_anim.audio = 16
attack_anim.slides = {69,70}
attack_anim.location = {0,0}
attack_anim.index = 1




magic_anim = {}
magic_anim.running = false
magic_anim.lastupdate = nil
magic_anim.duration = .2
magic_anim.audio = 17
magic_anim.slides = {85,86}
magic_anim.location = {0,0}
magic_anim.index = 1



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
	if a.audio then 
		sfx(a.audio) 
	end
	spr(a.slides[a.index],
	a.location[1],
	a.location[2])
	
	animation.lastupdate = time()
 animation.index+=1
	animation_ongoing = true
end




function animate()

if time() - animation.lastupdate 
 >=animation.duration then
 if animation.index>#animation.slides then
 	animation_ongoing = false
	else
 spr(animation.slides[animation.index],
 animation.location[1],
 animation.location[2])
 
 animation.lastupdate = time()
 animation.index+=1
 end
	end
end

----------- title -----------
function draw_titlescreen()
 version = 0.5
 cls()
 print("version: "..version,5,5,10)
 print("   welcome to can's quest\n - a journey thorugh foon - ",10,30,10)
 print("controls:",10,60,7)
 print("press 'z' to interact",10,70,7)
 print("press 'x' to open menu",10,80,7)

 print("  press z to proceed",15,110,10)

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
   print("--menu--",50,10,7)
   drawarrow(7,22+10*selectid,7)
   drawmenu(menuid)
   updatesprite(can)
   spr(can.frames[can.frameid],10,10)
   print("press x to return",10,120,7)

end

function drawarrow(x,y,col)
 line( x, y, x-5, y, col)
 line( x, y, x-2, y+2, col )
 line( x, y, x-2, y-2, col )
end



function drawmenu(menuid)
	if (menuscreen[menuid]) then
 	for m=1,menuscreen[menuid].len do
  		if menuscreen[menuid].text[m] then
  			item = menuscreen[menuid].text[m]
  			print(item[1],10,20+10*m,10)
  		 if item[2] == -1 then
   		 for  i=3,  #item do
   		  if item[i][1] == false then
   		  		print (perform_referenced_functions(item[i][2]),60,20+10*m,10)
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
   		  		perform_referenced_functions(data[i][2])
 			end
 		end
 end
end



function handleinputs_menuscreen()
  if btnp(5) then
  	gamestate = 1
  	menuid = 1
  	selectid=1
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

----------- world -----------

function draw_worldscreen()
  cls()
  drawmap()
 	drawnpcs() 
  draw_mapelems()
  spr(can.frames[can.frameid],can.x,can.y,1,1,can.faceleft,false)
 end

function handleinputs_worldscreen()
  currtime= time()
  updatenpcs()
  yadjust = 0
  xadjust = 0
  if btn(0) then
  	updatesprite(can)
  	if band((getmapflags(can,-can.speed,0)), 0x1)==0 then
  		xadjust+=can.speed
  		can.faceleft = true
  	end
  elseif btn(1) then
   updatesprite(can)
 		if band((getmapflags(can,can.speed,0)), 0x1)==0 then
    xadjust-=can.speed
    can.faceleft = false
   end
  end
  if btn(2) then
   updatesprite(can)
 		if band((getmapflags(can,0,-can.speed)),0x1)==0 then
 			yadjust+=can.speed
 		end
  elseif btn(3) then
   updatesprite(can) 
 		if band((getmapflags(can,0,can.speed)),0x1)==0 then
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
  
  teleportflags = getmapflags(can,0,0)
  if bor(teleportflags,0x6) then
   if not (band(teleportflags,0x4)==0) then
    	processteleport(true)
   elseif not (band(teleportflags,0x2)==0) then
    	processteleport(false)
   end
  end
  

end


function world_select()
selectnpc()
end
----------- battle -----------   cls()


function startbattle(enemyid)
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
 drawhealthbars()


 updatesprite(can)
 spr(can.frames[can.frameid],
 15,
 75)
 print ("can\nthe yellow",10,30,10)
 if enemy == nil then
		enemy = getenemysprite ()
	end
	updatesprite(enemy)
	spr(enemy.frames[enemy.frameid],
	95,
	75,
	1,1,true,	false)	
 print (enemy.name,75,30,10)
end


function drawhealthbars()
 local xoff = 0
 local yoff = 50
 local barwidth = 50
 local barheight = 5
 local enemyspace = 75
 local hpmpspace = 8
 print ("hp:",xoff,yoff,8)
 rectfill(xoff+12,
 yoff,
 xoff+ 12 +battlestats[1].hp/2,
 yoff+barheight,8)
 rect(xoff+12,
 yoff,
 xoff+12+barwidth,
 yoff+barheight,2)
 
 print ("mp:",
 xoff,
 yoff+hpmpspace,
 12)
 rectfill(xoff+12,
 yoff + hpmpspace,
 xoff+12 +battlestats[1].mp/2,
 yoff + hpmpspace+ barheight,
 12)
 rect(xoff+12,
 yoff + hpmpspace,
 xoff+12 +barwidth,
 yoff + hpmpspace+ barheight,
 1)
 
 print ("hp:",xoff-10+enemyspace,yoff,8)
  rectfill(
  xoff+enemyspace,
  yoff,
  xoff+battlestats[2].hp/2+
  enemyspace,
  yoff+barheight,
 8)
 rect(
 xoff+enemyspace,
 yoff,
 xoff+barwidth+enemyspace,
 yoff+barheight,
 2)
 print ("mp:",
 xoff+enemyspace-10,
 yoff+hpmpspace,
 12)
 rectfill(xoff+enemyspace,
 yoff + hpmpspace,
 xoff + enemyspace+battlestats[2].mp/2,
 yoff + hpmpspace+ barheight,
 12)
 rect(xoff+enemyspace,
 yoff + hpmpspace,
 xoff + barwidth+enemyspace,
 yoff + hpmpspace+ barheight,
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
  	  returntoworld()
   elseif battleselect ==1 then
   	win = attack(1,2)
   elseif battleselect ==2 then
   	if checkmp(1) then
   		win = magic(1,2)
   	end
  	end
  	if win then print ("you win!!",50,50,10)
 		wait(20)
 		   returntoworld()
 		   kill(eid)
 	end
 else
 	enemyturn()
 end
end


function magic (idsource,iddest)
	source = battlestats[idsource]
	dest = battlestats[iddest]
	damage =  source.magic * dest.defense
	dest.hp -= damage
	source.mp -= 10
	if source.mp<0 then
		source.mp = 0
	end
 start_animation(magic_anim,iddest)
	battleturn =  not battleturn
	if dest.hp <0 then dest.hp = 0 
	 return true 
	else return false
	end
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
 if (battleturn == true)
 then
	 enemyturn()
 end
	rect (1,90,125,125,10)
	print("attack",25,95,10)
	print("spell",25,105,10)
	print("run",25,115,10)
	drawarrow(15,87+10*battleselect,10)
end

function handleinputs_battlescreen()
  
  if btnp(2) and battleselect!=1  then
  	battleselect-=1
  end
 
  if btnp(3) and 3>=battleselect+1 then
  	battleselect+=1
  end
  
  if btnp(4) then 
   battleselectmenu()
  end

end


function wait(a) for i = 1,a do flip() end end
-->8

outside_hoggsface = {37,21,37,21}
outside_capitol_city = {40,28,41,28}
outside_gratax = {43,46,43,46}
outside_meagas = {46,34,46,34}

outside_furlingshire = {31,34,37,34}
outside_terrakis = {22,29,23,29}
outside_jizzleknob = {52,21,53,21}
outside_cave = {34,18,35,18}




nr_of_towns =8
towns ={}

nr_of_cavelevels =1
towns ={}


cavelevel = 1

cavelevels ={}
cavelevels[1] ={}
cavelevels[1].floor =
{
{120,37},
{121,37},
{120,36},
{121,36},
{120,35},
{121,35},
{120,34},
{121,34},
{120,33},
{121,33},
{120,32},
{121,32},
{120,31},
{121,31},
{120,30},
{121,30},
{120,29},
{121,29},
{120,28},
{121,28},
{120,27},
{121,27},
{120,26},
{121,26},
{120,25},
{121,25},
{120,24},
{121,24}
}




function init_cavelems()

 for n=1,nr_of_cavelevels do 
  add(cavelevels,{})
  cavelevels[n].nr_of_elems = 4
		cavelevels[n].elems ={}
		cavelevels[n].elems = 
		{
		{67,120*8,38*8,"exit",1},
		{67,121*8,38*8,"exit",1},
		{67,120*8,39*8,"exit",1},
		{67,121*8,39*8,"exit",1}	
		}
 end



end


function init_mapelems()
init_cavelems()
 for n=1,nr_of_towns do 
  add(towns,{})
  towns[n].nr_of_elems = 0
  towns[n].nr_of_interacts=0
 end
 
 --hogsface
 towns[1].nr_of_elems =4
 towns[1].elems=
 {
 {114,120*8,003*8,"tavern",2},
 {98,125*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",1},
 {67,121*8,7*8,"exit",1}
 }
 
 --tavern
 towns[2].nr_of_elems = 2
 towns[2].elems=
 {
 {67,121*8,15*8,"exit",1},
 {67,122*8,15*8,"exit",1}
 }
 
 
  --capitol
 towns[3].nr_of_elems =10
 towns[3].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,003*8,nil,nil},
 {98,126*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {20,121*8,1*8,nil,nil},
 {21,122*8,1*8,nil,nil},
 {67,120*8,7*8,"exit",3},
 {67,121*8,7*8,"exit",3}
 }
 
 --gratax
 towns[4].nr_of_elems =6
 towns[4].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,2*8,nil,nil},
 {98,129*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",4},
 {67,121*8,7*8,"exit",4}
 }
 
  --meagas
 towns[5].nr_of_elems =6
 towns[5].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,2*8,nil,nil},
 {98,129*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",4},
 {67,121*8,7*8,"exit",4}
 }
 
 
 
 --furlingshire
 towns[6].nr_of_elems =6
 towns[6].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,2*8,nil,nil},
 {98,129*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",4},
 {67,121*8,7*8,"exit",4}
 }
--terrakis 
 towns[7].nr_of_elems =6
 towns[7].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,2*8,nil,nil},
 {98,129*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",4},
 {67,121*8,7*8,"exit",4}
 }
--jizzleknob 
 towns[8].nr_of_elems =6
 towns[8].elems=
 {
 {98,118*8,2*8,nil,nil},
 {98,125*8,2*8,nil,nil},
 {98,129*8,005*8,nil,nil},
 {98,123*8,004*8,nil,nil},
 {67,120*8,7*8,"exit",4},
 {67,121*8,7*8,"exit",4}
 }
end



function draw_caveelems()
  if cavelevels[cavelevel]then
  for n=1,cavelevels[cavelevel].nr_of_elems do
   elem = cavelevels[cavelevel].elems[n] 
   drawsprite(elem[1],
   elem[2],
   elem[3])
  end
 
 end

end


function draw_mapelems()
 if not (world=="overworld") then
  if  (world=="cave") then
  	draw_caveelems()
  elseif towns[townid] then
   for n=1, towns[townid].nr_of_elems do
    elem =towns[townid].elems[n] 
    drawsprite(elem[1],elem[2],
    elem[3],false)
   end
	 end
	end

end

function updatemapinteracts()
if not (world=="overworld")
and (world=="cave")  then
  for n=1,cavelevels[cavelevel].nr_of_elems do
   local elem = cavelevels[cavelevel].elems[n] 
   if (isplayerintersecting
   (elem[2],elem[3]))
    then
   	 if  elem[4] and elem[5] then
   	 townid = elem[5]
    	teleport(elem[4])
    	break
   	end
   end
  end
elseif not (world=="overworld") then
  for n=1,towns[townid].nr_of_elems do
   local elem = towns[townid].elems[n] 
   if (isplayerintersecting
   (elem[2],elem[3])
   )
    then
   	 if  elem[4] and elem[5] then
   	 townid = elem[5]
    	teleport(elem[4])
    	break
   	end
   end
  end

	end
end


function teleport(location)
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
 	cellx = 116
 	celly = 10
 	sx = 25
 	sy = 25
 	celw = 12
 	celh = 6
 	world="tavern"
 	can.x = 65
 	can.y = 55
 	teleportworked = true
 elseif location =="town" then
 	cellx = 116
 	celly = 0
 	sx = 25
 	sy = 25
 	celw = 12
 	celh = 8
 	can.x = 58
 	can.y = 70
 	world="town"
 	teleportworked = true


 elseif location =="cave" then
 	cellx = 113
 	celly = 23
 	sx = 0
 	sy = 0
 	celw = 20
 	celh = 20
 	can.x = 58
 	can.y = 109
 	world="cave"
 	clearlevel()
 	loadlevel()
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
if x+4 >= box[1]*8 then
		if x<= box[3]*8 then
			if y+4>=(box[2]*8) then
				if y<=(box[4]*8) then
					return true
				end
			end
	 end
	end
	return false
end

function processteleport()
 x = can.x
 y = can.y
 if world == "overworld" then
 	x-=mapxoffset
 	y-=mapyoffset
 else
  x-=sx
  x+=cellx*8
  y-=sy
  y+=celly*8 
 end
 if xywithin(x,y,outside_hoggsface) then
  townid = 1
  teleport("town")
 elseif xywithin(x,y,outside_capitol_city) then
  townid = 3
  teleport("town")
 elseif xywithin(x,y,outside_gratax) then
  townid = 4
  teleport("town")
 elseif xywithin(x,y,outside_meagas) then
  townid = 5
  teleport("town")
 elseif xywithin(x,y,outside_furlingshire) then
  townid = 6
  teleport("town")  
 elseif xywithin(x,y,outside_terrakis) then
  townid = 7
  teleport("town")   
 elseif xywithin(x,y,outside_jizzleknob) then
  townid = 8
  teleport("town")   
 elseif xywithin(x,y,outside_cave) then
  caveid = 1
  teleport("cave")
  
 end
 
end



function drawmap()

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
		
			  
   if world == "tavern" then 
  		spr(80,40,50) --usidore
  		spr(81,30,40) -- arnie
  		spr(82,40,30) --chunt
  		spr(112,40,40) --table
  end
  
 end
 
end
-->8


function clearlevel()
	for x=113,127 do
 	for y=23,38 do
 		mset( x, y, 83 )
 	end
	end
	mset(120,38, 18)
	mset(121,38, 18)
end


function generatelevel()

end

function loadlevel ()
	for i=1, #cavelevels[cavelevel].floor do
		clevel = cavelevels[cavelevel].floor[i]		
		mset(clevel[1], clevel[2], 100 )
	end
end


-->8

-->8

function kill(id)
 npcs[id].frames = {121,121,122,122}
 if (not (npcs[id].name == "")) then
 	npcs[id].name = npcs[id].name.."(rip)"
 end
end


function initnpcs()
 nr_of_npcs = 6 
 npcs ={}
 intersecting = {}
 for n=1,nr_of_npcs+copycount do 
  add(npcs,{})
  npcs[n].frames = {64,65,66}
  npcs[n].frameid = 1
  npcs[n].speed = 1
  npcs[n].x = 19*8
  npcs[n].y = 15*8
  npcs[n].randommoves = true
  npcs[n].path={{{19*8,15*8}}}
  npcs[n].futurepath = {}
  npcs[n].faceleft = false
  npcs[n].msg = ""
  npcs[n].name = ""
  npcs[n].msgyoffset = 0
  npcs[n].msgxoffset = 0
  npcs[n].battlestats = {}
  npcs[n].world = "overworld"
 npcs[n].battlestats.attack = 5
 npcs[n].battlestats.magic = 5
 npcs[n].battlestats.defense = .75
 npcs[n].battlestats.hp = 100
 npcs[n].battlestats.mp = 100
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
  npcs[n].name = txt[1]
		npcs[n].msgyoffset = -10
		npcs[n].msgxoffset = -20
  npcs[n].world = "overworld"		
 end
 --grimhoof 
 
 npcs[1].frames = {96,96,97,97}
 npcs[1].x= 19*8
 npcs[1].y= 15*8
 npcs[1].name = "grimhoof"
 npcs[1].randommoves = false
 npcs[1].path={
 {19*8,15*8},
 {15*8,19*8},
 {15*8,22*8},
 {15*8,22*8}, 
 {18*8,22*8},
 {21*8,18*8}, 
 }
 
 
  --ogre  
 npcs[2].speed =0.5
 npcs[2].frames = {87,87,88,88}
 npcs[2].x= 30*8
 npcs[2].y = 20*8
 npcs[2].name = "ogre"
 npcs[2].msg = ": top o' the \nmornin' to ya"
 npcs[2].randommoves = false
 npcs[2].path={
 {30*8,20*8},
 {34*8,20*8},
 {38*8,24*8},
 {38*8,27*8},
 {44*8,33*8},
 {45*8,34*8},
 {45*8,35*8},
 {37*8,43*8},
 {37*8,44*8},
 {26*8,44*8}  
 }
 
 --lady outside castle belaroth
 npcs[3].speed =1
 npcs[3].frames = {89,89,90,90}
 npcs[3].x= 57*8
 npcs[3].y= 28*8
 npcs[3].name = "villager"
 npcs[3].randommoves = false
 npcs[3].path={
 {57*8,28*8},
 {65*8,28*8} 
 }


 --skeleton
 npcs[4].speed =1
 npcs[4].frames = {71,71,72,72}
 npcs[4].x= 120*8
 npcs[4].y= 34*8
 npcs[4].world = "cave"
 npcs[4].level = 1
 npcs[4].name = "clax"
 npcs[4].msg = ": fight me!"
 npcs[4].msgxoffset-=20
 npcs[4].randommoves = false
 npcs[4].path={
 {120*8,34*8},
 {121*8,34*8}
 }
 
 --guy in the southeast
 npcs[5].speed =1
 npcs[5].frames = {103,103,104,104}
 npcs[5].x= 45*8
 npcs[5].y= 53*8
 npcs[5].name = "tradesme"
 npcs[5].randommoves = false
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
 npcs[6].name = "trainee wizard"
 npcs[6].randommoves = false
 npcs[6].path={
 {22*8,26*8},
 {25*8,29*8},
 {25*8,30*8},
 {22*8,30*8} 
 }
 
end


function updatenpcs()
 for n=1, #npcs do
  updatesprite(npcs[n])
  movesprite(npcs[n])
 end
 
end

function drawnpcs()
 
 if (#intersecting >0) then 
 	for n=1, #intersecting do
   talk(npcs[intersecting[n]])

 		end
 end
  intersecting = {}
  for n=1, #npcs do
   if npcs[n].world == world then
  	drawsprite(npcs[n].frames[npcs[n].frameid],
  	npcs[n].x,
  	npcs[n].y,
  	npcs[n].faceleft)
  	if  isplayerintersecting(npcs[n].x,npcs[n].y) then	
  		add(intersecting,n)
		 end
 end

 end
end

function talk(n)
if world == "overworld" then
  	print (
  	n.name..n.msg,
  	n.x+mapxoffset+
  	n.msgxoffset,
  	n.y+mapyoffset
  	-10+n.msgyoffset,
  	10)
  	
else
 print (
  	n.name..n.msg,
   (n.x/8-cellx) *8+sx
   +n.msgxoffset,
  	(n.y/8-celly) *8+sy
  	+n.msgyoffset-10,
  	10)
  	
  	end
end

function selectnpc()

	if #intersecting >0 then
 	startbattle(intersecting[1])
 end
end

function isplayerintersecting(spr_x,spr_y)
 intersect = false
 
 if world == "overworld" then
  x_s1 = can.x - mapxoffset
  y_s1 = can.y - mapyoffset
  y_s2 = spr_y+4
  x_s2 = spr_x+4

 else
  x_s1 = can.x
  y_s1 = can.y
  y_s2 =(spr_y/8-celly) *8+sx 
  x_s2 =(spr_x/8-cellx) *8+sy
 end


  
 if (x_s1 <= x_s2)
 and(x_s2 <= (x_s1+8))
 and(y_s1 <= y_s2)
 and(y_s2 <= (y_s1+8)) 
then    
    intersect = true
 end
 
 return intersect
 
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


function drawsprite(sp,x,y, faceleft)

	if world == "overworld" then
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

end
-->8

function movesprite(sprite)
 if sprite.randommoves then dorandommoves(sprite)
 else  followpath(sprite)
 end
end

function dorandommoves(sprite)
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
000000007777777744333333333333443333333bb333333bb33333331f1f1f111f11f1f111f11f11656666663242242366666666333333333333333333333333
00000000777777774443333333333444333333bbbb3333bbbb333333f11111111111111111111111655665662224422266555556333333222233332222333333
007007007777777734443333333344433333333bb333333bb33333331111111111111111111c1111656655563244442365556656333333244233332442333333
00077000777777773344444444444433333bb3bbbb3bb3bbbb3bb333f111c1111111111111c1c11f655665563244442366556556332222444422224444222233
0007700077777777333444444444433333bbbb3223bbbb3223bbbb33111c1c11111c111111111111656655552422224265556656332442444424424444244233
00700700777777773333333333333333333bb332233bb332233bb333f111111111c1c1111111111f655655653224422365566556324444244244442442444423
0000000077777777333333333333333333bbbb3333bbbb3333bbbb33111111111111111111111111656655653244442365566656244444422444444224444442
00000000777777773333333333333333333223333332233333322333f11111111111111111111111655655552444444265556556444224444442244444422444
442442446566533333333333333566563555355535555533ffffffff111111111111111111111111333333333333333333333333332442444424424444244233
3244442365565333b3b33333333565563565556555656553fffffffa111111111111111111111111333333333333333333333333324444222244442222444423
b344443b656653333b333333333566563566666666666653ffaffffff1111111111c1111111c111f333333333333333333333333244444244244442442444442
b332233b65565b3333333333b3b565563561616161616153fffffffa1111c11111c1c11111c1c111444443333332233333344444244222444422224444222244
bb3333bb656653b3333333333b3566563566666666666653ffafffff111c1c11111111c111111111444444333324423333444444332442444424424444244233
333bb333655653333333b3b3333565563566664444666653fffffafff111111111111c1c1111111f333344433244442334443333324444224244442442444423
b33bb33b6566533333333b33333566563566664554666653fffffffa11111111111c111111111111333334443244442344433333244444442444444224444442
b3bbbb3b6556533333333333333565563566664554666653ffffffff1111111111c1c11111111111333333442444444244333333244224442442244224422442
333333937777777777777777777777773332233bb332233bb3322333111111111111111111111111665555556655555566655555332442444424424444244233
33333999c7777777c7777c77cc777cc7333223bbbb3223bbbb322333f111111111111c111111111f566666665666656655666556324444222244442222444423
66633444ccc77777ccc7ccc7ccccccc73333333bb333333bb3333333111111111111c1c111c11111555666665556555655555556244444244244442442444442
444334047cccccccc7c77cc7ccccccc7333bb3bbbb3bb3bbbb3bb33311111111111111111c1c111f655555555656655655555556244222444422224444222244
404222337cccc7ccc7c7ccccc7cccccc33bbbb3223bbbb3223bbbb33f11111111c11111111111111655556555656555556555555332442444424424444244233
111555337c7cc7ccc7c7cc7cc7cccc7c333bb332233bb332233bb33311111111c1c111111111111f656556555656556556555565324444244244442442444423
444505337c7cc7ccccc7cc7cc7cccc7c33bbbb3333bbbb3333bbbb33111111111111111111111111656556555556556556555565244444422444444224444442
40433333cc7cccc7cccccccccccccccc333223333332233333322333f11f1f1111f11f1f11f11f1f556555565555555555555555244444424444444424444442
b332233b3b3b33333333333333344433333333333334443333344433333444333334443333344433443333333333334433344333333333443334443344333333
bb3223bb33b33333333b3b3333344433333b3b33333444333334443333344433b3b4443333344433444333333333344433344333333334443334443344433333
b333333b333333333333b333333444333333b3333334443333344433333444333b34443333344433344433333333444333344333333344433334443334443333
bb3bb3bb4444444444444433b3b44433333444443334444444444433444444334444444444444433334443333334443333344333333444333334443333444433
23bbbb3244444444444444333b344433333444443334444444444433444444334444444444444433333444333344433333444333333443333334443333344433
233bb332333333333334443333344433333444333333333333333333333333333334443333344433333344433444333334443333333443333333444333344433
33bbbb333333b3b333344433333444333334443333b3b333333b3b3333333b3b3334443333344433333334444443333344433333333443333333344433344433
333bb33333333b33333444333334443333344433333b33333333b333333333b33334443333344433333333444433333344333333333443333333334433344433
09990000099900000999000051515151000600000000000000008000007777700777770000554400005544000ddd00000ddd0000000000000000000000000000
9999900099999000999990001515151500060000000880000008880000757570075757000054544000545440ddddd000ddddd000000000000000000000000000
0aaaa0000aaaa0000aaaa00051515151000600000088980008800880007757700775770000544400005444000555500005555000000000000000000000000000
061f1600061f1600061f16001515151500060000008998000080080007075007007500000011111001111100051f1000051f1000000000000000000000000000
06fff60006fff60006fff6f0515151510006000000898800008008000077777077777700001411044011110005fff00005fff0f0000000000000000000000000
099699f409969f400996994015151515005550000008800000888000005775000057557000111100001111000ddddf400ddddd40000000000000000000000000
f999990409f99940f999990451515151000900000000000008080000007557707775770000111660066111000dfddd40fddddd04000000000000000000000000
09292904092999000999290415151515000500000000000000000000077000007000077000660000000006600d2ddd000ddd5d04000000000000000000000000
01110000002220000011150088988888000000f000000000ccc00000000dd000000dd0000055ff000055ff000ddd00000ddd0000000000000000000000000000
1111100002fff200011151158988888808000fff00000000c00ccc0000dddd0000dddd00005f5ff0005f5ff0ddddd000ddddd000000000000000000000000000
0cccc0000f1f1f0001111122889898880080fff40000000000cc0cc000dd5dd000dd5dd0005fff00005fff000555500005555000000000000000000000000000
061f160000f2f00001777100898989880008ff400c0cc00000c000c000ddd10000ddd10000f111f00ff111000512100005121000000000000000000000000000
06fff60003222300115551118888988800f884000c000c00000000c0002dd200002dd20000f1110ff01111000522200005222020000000000000000000000000
011611f43333333050111105988888980fff400000c0c000cccc00c00d222200002222d0001f1100001111000dddd2400ddddd40000000000000000000000000
f1111104f11111f00010100088989888fff40000000c0000cc00ccc000dddd0000dddd0000111660066111100d2ddd402ddddd04000000000000000000000000
012121040771770005101500888888890f400000000000000cccc00000dd000000d00dd000660000000006600d5ddd000ddd5d04000000000000000000000000
00000120000001105566556622442222f44444450000000000000000000222000002220000660000000000e04424424444244244000000000000000000000000
000011520000112066556655222224424222222500000000000000000002522000025220006660e00e666e5e2244442222444422000000000000000000000000
0000122210001252556611664112211242222225000000000000000000022200000222000ee66e5eee666eee4244442442444424000000000000000000000000
1122220011222222665511552114411242222225000000000000000000ddddd00ddddd00eeeeeeeeeee66e004422224444222244000000000000000000000000
1222222022222200556611662222224442222225000000000000000000d2dd0220dddd00eeeeee000eeeeee04424411111144244000000000000000000000000
1222222222222220662266552445542242222225000000000000000000555500005555000eeeeee0050000504241111111111424000000000000000000000000
40220202920090205524556622251222422222250000000000000000005551100115550005000050000000002411111111111142000000000000000000000000
90900909090000906622665524455244455555510000000000000000001100000000011000000000000000004411111111111144000000000000000000000000
000000004242424222222222442442440000bb00000b000000000000000fff00000fff0000006600006666600000000000000000000000000000000000000000
00011000424242424444444422444422000bbb0b000bb000000b0b00000f5ff0000f5ff060067760067777700000000000000000000000000000000000000000
00111100424244422112222242444424b00bbb00000bbb000b000000000fff00000fff0000675750067575700000000000000000000000000000000000000000
0111111044424242411444444422224400bbbbb0000bbbb00000000000ddddd00ddddd0006777760067777600000000000000000000000000000000000000000
0111111042424242211222224424424400bbbbb0000bbbb00b0000b000dfdd0ff0dddd0006755677606755600000000000000000000000000000000000000000
05111150424442424444554442411424003b3b3000bbbb3000000000001111000011110006776600006766000000000000000000000000000000000000000000
0551155042424242222251222411114200003000003bbb30000b0000001116600661110006760060066660000000000000000000000000000000000000000000
05055050424242424444554444111144000000000003330000000000006600000000066066600000000000600000000000000000000000000000000081818181
e1e1e1e1e1e1e1e0f04262d0e1e1f14262e32121c113131313131313131313132121212121212121212121a32161616161212121212121218181818181818181
81818181818181818181818181818181818181818181818181818181818100000000000000000000000000000000000000353535353535353535353535353535
35e1e1e1e1e1e1e1e1e1e1e1e1e1e1f16221a3b3212121212121212121212121212121212121212121212121f361818161212121212161617181818181818181
81818181818181818181818181818181818181818181818181818181818100000000000000000000000000000000000000353535353535353535353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1e1f201622121f32121d0e0e0e0e0e0e0f040602121212121212121212121215313028161616161616161708182828281818181
81818181818181818181818181818181818181818181818181818181818100000000000000000000000000000000000000353535353535353535353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f1212121212102212121d2e1e1e1e1e101036221212121212121212121212121c3618181808080808080819161616171818181
81818181818181818181818181818181818181818181818181818181818100000000000000000000000050500000000000353535353535353535353535353535
e1e1e1e1e1e1e1e1e1e1e1e1e1f121616161616161612121d1e1e1e1e1035262212121212121212121212121b321618181818181818181819161616171818181
81818181818181818181818181818181818181818181818181818181818100000000000000000050505000000000000000353535353535353535353535353535
35e1e1e1e1e152e1e1e1e1e1e1f161617080808080616121d2e1e1e1e1f021022121212121212121212121b32121617282828282828281818180808081818181
81818181818181818181818181818181818181818181818181818181818100000000000000500000000000000000000000464646464646464646464646464646
35e1e1e1e1e1e1e1e1e1e1e1e1f16161718181818190612121212121d1f1212121212121212121212121b3212121616161616161616172828181818181818181
81818181818181818181818181818181818181818181818181818181818100000000000000500000000000000000000000464646464646463030464646464646
35e1e1e1e1e1e1e1e1e1e1e1e1f16161718121818191616161616121d1e1f021212121212121212121b340036021212121212121216161616181818181818181
81818181818181818181818181818181818181818181818181818181818100000000000050000000000000000000000000000000000000003030000000000000
00e1e1e1e1e1e1e1e1e1e1e1e1f16161718181218181906170906121d1f121212121212121212121b34003030360212121212121212121216161718181818181
81818181818181818181818181818181818181818181818181818181818100000000000000000050000000000000000000000000000000000000000000000081
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161718181812121916172926121b021212121212121212121b3400303030362212121212121212140602161718181818181
81818181818181818181818181818181818181818181818181818181818100000000500050000000000000000000000000000000000000000000000000000081
e1e1e1e1e1e1e1e1e1e1e1e1e1f1616171818181818191616161612121212121212121212121b321420303030362d0f021212121212142622161818181818181
81818181818181818181818181818181818181818181818181000000000000000050500000000000000000000000000000000000000000000000000000000081
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161728281818181926121213321212121212121212121d321212142525252d0f22121212121212121212161818181818181
81818181818181818181818181818181818181818181818181000000000000005050000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161616172828292616121215313131313131313131313631313a121d0e0e0f2212121212121212121216161818181818181
81818181818181818181818181818181818181818181818181000000000000505000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1f16161616161616161612121d0e0e0e0e0f021212121212121212121a3d2e2f221212121212140506021216181818181818181
81818181818181818181818181818181818181818181818181000000000000500000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f02121212121212121d0e1e1e1e1e1e1f02121212121212121405062021323212121212142036221616181818181818181
81818181818181818181818181818181818181818181818181000000000000005050000000000000000050505000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e0e1e1e1e1f0212121212121d0e1e1e1e1e1f021212121212121212121425252622133212121212142526221618181818181818181
81818181818181818181818181818181818181818181818181000000000000500000000050000000005000500000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e0e0e0e1e1e1e1e1e1e1e0e0e0f0212121212121426221212133212121212121212121618181818181818181
81818181818181818181818181818181818181818181818181000000000050000000000000500000500050000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e0f021212121212133212121212121616161618181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f02121212133216161616161617081818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000050000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f12140602133216170808080808181818181818181818181
81818181818181818181818181818181818181818181818181000000000050000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f042622133216181818181818181818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000500000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f0212153026181818282818181818181818181818181
81818181818181818181818181818181818181818181818181000000000050000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f021216181816161718181818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000050000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f08181816161818181618181818181818181
81818181818181818181818181818181818181818181818181000000000050000000005000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f18181818081818161618181818181818181
81818181818181818181818181818181818181818181818181000000000000000050500000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f18181818181816161818181818181818181
81818181818181818181818181818181818181818181818181000000000000505000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0e0e081818181818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e18181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e181818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1818181818181
81818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0101000000000001010101010101010101010001020200010101000100010101020101010000000101010101010101010000000000000000000000000000000000000006000000808080808080000000010101010000008080808080800000000000000200000080808080020200000001000001000000808000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101013c013c3c3c3c3c3c3c3c3c3c3c3c3c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a2b2b2b2b2b2b2b2b2b2b0c
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101013c013c3c3c3c3c3c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e010101010101010101010101010101010101010101010101013c3c3c3c3c3c3c3c3c3c3c3c3c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111212121212121212121213
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e01010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b2b2b2b12122b2b2b2b2b2c
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2101010101010101010101010101010101010101010101010118181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000001212000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e22730101010101010101010101010101010101010101010118181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0101010101010101010101010101010101010101010101010101181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000717171717171717171717171
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2322222223222223010101010101010101010101010101010122181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000717171717171717171717171
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2e1e1e1e1e1e1f2525122d2e2f282818181818181818220101010101010101010101010101012218181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000717171717171717171717171
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e331d1e1e1e1e10252506040506161627282818181818182201010101010101012222220101221818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000717171717171717171717171
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f1e331d1e1e1e102525300d0e0e0e0f1616161627181818181822220101222201010d0f120101181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000717171717171717171717171
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123c1d1e1e1e1e0e0e0e1e1e1e1e1f1220121616272818181804060101121201011d1e0f0101181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000012120000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123b121d2e2e1e1e1e1e1e102d1e1e1f1212121216161627281824260101121201011d1e1f0101120d0f12181818180d0e0e0e0e0e18181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000012120000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e2f12123b120d1e123b1d1e1e1e103030260d1e0e0e0e0e0e0f1616160406122123121201011d1e1f210104101006181818181d1e1e1e1e1e0f181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1f12123b120d2f123b121d1e1f10303026121d1e1e6b6c1e1e1e0e0f120405060405061221231d1e1f1223243030261818180d1e1e1e1e1e1e1f181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1f123d120d1e123b12121d1e2f252526121224252612241d1e1e1e1f12040d0f30302612120d1e1e2f1204123030301818181d1e1e1e1e1e1e1e0f1818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1f12330d2f123b12120d1e2f12121212121c3131311a121d1e1e1e1f121d1e1f25252620122d2e2f120430303030301818181010101e1e1e1e2f18181818181818181818181818181818181818181818180000000000000000000000000000000000000000000000000000000000000000004c
1e1e1e1e1e1e1e1e1e1e1e1e1e1f123e12123b12120d1e2f12123b3f123b12120430123a12201d1e1f121d1e1f161616161212121415303030303018181804303030102e2e2e2f181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000004c00000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e12123a3d12120d1e2f12123b123e3b121204303030123a3c04100b121d1e1f0708091616121212121212301818181212243030252506181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e1e1e1e1e1e1e0e0f123a12122d2f12123b1212121212303030303012123a24300b120b1016171b120916121212121212301812121212242526121218181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e0f123a121212123b120d0d0f123030303030303012123f240b120b26162712121916121212121212181812121212121212121818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f10100f123f12123b120d1e1e2f0f04303030303030300633120b120b06161627282916040612121212181212040505050612121818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f24262d0f3312123a12122d1e1010303030303030303026330d1e1e1f24061616161616042612121212181212243030302614151212181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1e1e1e101e1e1e1e123a12123c1212123a12122d0f303030303030303030263e0b14150b12240505050505261212121212182012121224261212331212181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1e1e10301e1e1e1e06123f3b12120d2f123a12121e1f242525252525252526123a202012121212121212121212121c3131313131313131313131371218181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1e1f103030102d1e2430063312120d1f1415123f122d1e0e0e0e0e0e0e0f1b0406123a12121212121212121212123b120406121212121212121818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1f10303030051d1e1f302633120d1e1f1231123e12122d1e1e1e1e1e1e2f12043026123a1212121212121212123d12040506181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
1e1e1e1e1e1e1f30303030061d1e1f302633122d1e1e0e0e0e123a12122d1e1e1e1e2f121224252612123a31313131313131313612121212181818181818181818181818181818181818181818181818181818181818181818181818181800000000000000000000000000000000000000535353535353535353535353535353
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100200c233116330c233116330c2331920031610000000c2331163311633116330c2330000031610000000c233316000c233116330c2331160311633316100c2333161011633316000c233116001163311633
0110000024050240002d0502d0001f0502d0502d0002f0500000024050240502f0502d0502d0501f050000002d0500000000000000000b0000000000000000000000000000090000000000000000000000000000
01100000240502400029050290502805029050290002b050000002d0502d0502b0502905029050280500000029050000000000000000000000000000000000000000000000000000000000000000000000000000
01100000211501a15019100191501a150000001c1501d150000001c1501a15019100191501a150000001c1501d150000001a150191501915000000000001a1001a15019000191501a150000001c1501d15000000
0110000021150111501c1001c1501d150000001f15021150000001f1501d150000001c1501d150000001f15021150000001d1501c1501c1500000021100211501d150000001c1501d1501d1001f1502115000000
001000001c1501d150000001f15021150000001f1501d150000001f1501c1501c15000000000003210032150000003215032150000002b1502915000000281502615000000281502915000000281502615000000
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

