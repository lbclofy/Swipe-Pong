--require "CiderDebugger";---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

local performance = require('performance')
performance:newPerformanceMeter()


-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

_G._W = display.contentWidth
_G._H = display.contentHeight
_G.centerX = _W*.5
_G.centerY = _H*.5

_G.scale = _H/960
_G.ballR = _W*.025
_G.phi = 1.61803398875

_G.maxSpeed  = _W

_G.forceFactor = _W*.4

_G.isDrawing = false

_G.font = "Dyslexie Regular"
--attempting to get font to work
--_G.font = "data\Dyslexie Regular LP129383 (1)"

--Colors    { R = ,   G = ,     B = }
_G.Red =      { R = 244/255,  G = 067/255,  B = 054/255 }
_G.Red100 =   { R = 255/255,  G = 205/255,  B = 210/255 }
_G.Red300 =   { R = 229/255,  G = 115/255,  B = 115/255 }
_G.Red700 =   { R = 211/255,  G = 047/255,  B = 047/255 }
_G.Yellow =   { R = 225/255,  G = 196/255,  B = 000/255 }
_G.Green =    { R = 076/255,  G = 175/255,  B = 080/255 }
_G.Blue =     { R = 000/255,  G = 191/255,  B = 165/255 }--{ R = 033/255,  G = 150/255,  B = 243/255 }
_G.Blue100 =  { R = 187/255,  G = 222/255,  B = 251/255 }
_G.Blue300 =  { R = 100/255,  G = 181/255,  B = 246/255 }
_G.Blue700 =  { R = 025/255,  G = 118/255,  B = 210/255 }
_G.Purple =   { R = 156/255,  G = 039/255,  B = 176/255 }
_G.BlueGrey = { R = 096/255,  G = 125/255,  B = 139/255 }
_G.Black =    { R = 000/255,  G = 000/255,  B = 000/255 }
_G.White =    { R = 255/255,  G = 255/255,  B = 255/255 }
_G.hlColor =  { R = 244/255,  G = 067/255,  B = 054/255 }
_G.priColor = { R = Yellow.R, G = Yellow.G, B = Yellow.B}
_G.secColor = { R =  Blue.R,  G = Blue.G,   B = Blue.B  }

_G.outlineColor = { highlight = { r= 0, g=0, b=0 }, shadow = { r=0, g=0, b=0 } }



_G.fontSize = _W*.05
_G.phi = 1.618033988749894


_G.gRadius = { 1.000*ballR, 2.000*ballR, 2.155*ballR, 2.415*ballR, 2.702*ballR, 3.001*ballR, 3.001*ballR, 3.305*ballR, 3.614*ballR, 3.924*ballR, 4.000*ballR, 4.155*ballR}


_G.ballCoord = {
  --1 Ball
  { 0, 0 },
  --2 Balls
  {  - ballR, 0,    ballR, 0 },
  --3 Balls
  { 1.155*ballR*math.cos(math.rad(-90)) , 1.155*ballR*math.sin(math.rad(-90)),            1.155*ballR*math.cos(math.rad(30)), 1.155*ballR*math.sin(math.rad(30)),
  1.155*ballR*math.cos(math.rad(150)), 1.155*ballR*math.sin(math.rad(150)),},
  --4 Balls
  { (gRadius[4] - ballR)*math.cos(math.rad(-90)), (gRadius[4] - ballR)*math.sin(math.rad(-90)),     (gRadius[4] - ballR)*math.cos(math.rad(0)), (gRadius[4] - ballR)*math.sin(math.rad(0)),
  (gRadius[4] - ballR)*math.cos(math.rad(90)), (gRadius[4] - ballR)*math.sin(math.rad(90)),         (gRadius[4] - ballR)*math.cos(math.rad(180)), (gRadius[4] - ballR)*math.sin(math.rad(180))},
  --5 Balls
  {  (gRadius[5] - ballR)*math.cos(math.rad(-90)), (gRadius[5] - ballR)*math.sin(math.rad(-90)),    (gRadius[5] - ballR)*math.cos(math.rad(-18)), (gRadius[5] - ballR)*math.sin(math.rad(-18)),
  (gRadius[5] - ballR)*math.cos(math.rad(54)), (gRadius[5] - ballR)*math.sin(math.rad(54)),         (gRadius[5] - ballR)*math.cos(math.rad(126)), (gRadius[5] - ballR)*math.sin(math.rad(126)),
  (gRadius[5] - ballR)*math.cos(math.rad(198)), (gRadius[5] - ballR)*math.sin(math.rad(198)) },

  {  (gRadius[6] - ballR)*math.cos(math.rad(-90)), (gRadius[6] - ballR)*math.sin(math.rad(-90)),  (gRadius[6] - ballR)*math.cos(math.rad(-30)), (gRadius[6] - ballR)*math.sin(math.rad(-30)),
  (gRadius[6] - ballR)*math.cos(math.rad(30)), (gRadius[6] - ballR)*math.sin(math.rad(30)),       (gRadius[6] - ballR)*math.cos(math.rad(90)), (gRadius[6] - ballR)*math.sin(math.rad(90)),
  (gRadius[6] - ballR)*math.cos(math.rad(150)), (gRadius[6] - ballR)*math.sin(math.rad(150)),     (gRadius[6] - ballR)*math.cos(math.rad(210)), (gRadius[6] - ballR)*math.sin(math.rad(210)) },

  {  (gRadius[7] - ballR)*math.cos(math.rad(-90)), (gRadius[7] - ballR)*math.sin(math.rad(-90)),  (gRadius[7] - ballR)*math.cos(math.rad(-30)), (gRadius[7] - ballR)*math.sin(math.rad(-30)),
  (gRadius[7] - ballR)*math.cos(math.rad(30)), (gRadius[7] - ballR)*math.sin(math.rad(30)),       (gRadius[7] - ballR)*math.cos(math.rad(90)), (gRadius[7] - ballR)*math.sin(math.rad(90)),
  (gRadius[7] - ballR)*math.cos(math.rad(150)), (gRadius[7] - ballR)*math.sin(math.rad(150)),     (gRadius[7] - ballR)*math.cos(math.rad(210)), (gRadius[7] - ballR)*math.sin(math.rad(210)),
  0, 0 },

  {  (gRadius[8] - ballR)*math.cos(math.rad(-90)), (gRadius[8] - ballR)*math.sin(math.rad(-90)),        (gRadius[8] - ballR)*math.cos(math.rad(-38.571)), (gRadius[8] - ballR)*math.sin(math.rad(-38.571)),
  (gRadius[8] - ballR)*math.cos(math.rad(12.857)), (gRadius[8] - ballR)*math.sin(math.rad(12.857)),     (gRadius[8] - ballR)*math.cos(math.rad(64.286)), (gRadius[8] - ballR)*math.sin(math.rad(64.286)),
  (gRadius[8] - ballR)*math.cos(math.rad(115.714)), (gRadius[8] - ballR)*math.sin(math.rad(115.714)),     (gRadius[8] - ballR)*math.cos(math.rad(167.143)), (gRadius[8] - ballR)*math.sin(math.rad(167.143)),
  (gRadius[8] - ballR)*math.cos(math.rad(218.571)), (gRadius[8] - ballR)*math.sin(math.rad(218.571)),     0,0 },

  {  (gRadius[9] - ballR)*math.cos(math.rad(-90)), (gRadius[9] - ballR)*math.sin(math.rad(-90)),      (gRadius[9] - ballR)*math.cos(math.rad(-45)), (gRadius[9] - ballR)*math.sin(math.rad(-45)),
  (gRadius[9] - ballR)*math.cos(math.rad(0)),  (gRadius[9] - ballR)*math.sin(math.rad(0)),         (gRadius[9] - ballR)*math.cos(math.rad(45)), (gRadius[9] - ballR)*math.sin(math.rad(45)),
  (gRadius[9] - ballR)*math.cos(math.rad(90)), (gRadius[9] - ballR)*math.sin(math.rad(90)),       (gRadius[9] - ballR)*math.cos(math.rad(135)), (gRadius[9] - ballR)*math.sin(math.rad(135)),
  (gRadius[9] - ballR)*math.cos(math.rad(180)), (gRadius[9] - ballR)*math.sin(math.rad(180)),       (gRadius[9] - ballR)*math.cos(math.rad(225)), (gRadius[9] - ballR)*math.sin(math.rad(225)),
  0, 0 },

  { (gRadius[10] - ballR)*math.cos(math.rad(-90)), (gRadius[10] - ballR)*math.sin(math.rad(-90)),          (gRadius[10] - ballR)*math.cos(math.rad(-50)), (gRadius[10] - ballR)*math.sin(math.rad(-50)),
  (gRadius[10] - ballR)*math.cos(math.rad(-10)), (gRadius[10] - ballR)*math.sin(math.rad(-10)),             (gRadius[10] - ballR)*math.cos(math.rad(30)), (gRadius[10] - ballR)*math.sin(math.rad(30)),
  (gRadius[10] - ballR)*math.cos(math.rad(70)), (gRadius[10] - ballR)*math.sin(math.rad(70)),           (gRadius[10] - ballR)*math.cos(math.rad(110)), (gRadius[10] - ballR)*math.sin(math.rad(110)),
  (gRadius[10] - ballR)*math.cos(math.rad(150)), (gRadius[10] - ballR)*math.sin(math.rad(150)),           (gRadius[10] - ballR)*math.cos(math.rad(190)), (gRadius[10] - ballR)*math.sin(math.rad(190)),
  (gRadius[10] - ballR)*math.cos(math.rad(230)), (gRadius[10] - ballR)*math.sin(math.rad(230)),           0, 0 },

  { (gRadius[11] - ballR)*math.cos(math.rad(-90)), (gRadius[11] - ballR)*math.sin(math.rad(-90)),          (gRadius[11] - ballR)*math.cos(math.rad(-50)), (gRadius[11] - ballR)*math.sin(math.rad(-50)),
  (gRadius[11] - ballR)*math.cos(math.rad(-10)), (gRadius[11] - ballR)*math.sin(math.rad(-10)),            (gRadius[11] - ballR)*math.cos(math.rad(30)),  (gRadius[11] - ballR)*math.sin(math.rad(30)),
  (gRadius[11] - ballR)*math.cos(math.rad(70)),  (gRadius[11] - ballR)*math.sin(math.rad(70)),             (gRadius[11] - ballR)*math.cos(math.rad(110)), (gRadius[11] - ballR)*math.sin(math.rad(110)),
  (gRadius[11] - ballR)*math.cos(math.rad(150)), (gRadius[11] - ballR)*math.sin(math.rad(150)),            (gRadius[11] - ballR)*math.cos(math.rad(190)), (gRadius[11] - ballR)*math.sin(math.rad(190)),
  (gRadius[11] - ballR)*math.cos(math.rad(230)), (gRadius[11] - ballR)*math.sin(math.rad(230)),           - ballR, 0,
  ballR, 0 },

  { (gRadius[12] - ballR)*math.cos(math.rad(-90)), (gRadius[12] - ballR)*math.sin(math.rad(-90)),          (gRadius[12] - ballR)*math.cos(math.rad(-50)), (gRadius[12] - ballR)*math.sin(math.rad(-50)),
  (gRadius[12] - ballR)*math.cos(math.rad(-10)), (gRadius[12] - ballR)*math.sin(math.rad(-10)),            (gRadius[12] - ballR)*math.cos(math.rad(30)),  (gRadius[12] - ballR)*math.sin(math.rad(30)),
  (gRadius[12] - ballR)*math.cos(math.rad(70)),  (gRadius[12] - ballR)*math.sin(math.rad(70)),             (gRadius[12] - ballR)*math.cos(math.rad(110)), (gRadius[12] - ballR)*math.sin(math.rad(110)),
  (gRadius[12] - ballR)*math.cos(math.rad(150)), (gRadius[12] - ballR)*math.sin(math.rad(150)),            (gRadius[12] - ballR)*math.cos(math.rad(190)), (gRadius[12] - ballR)*math.sin(math.rad(190)),
  (gRadius[12] - ballR)*math.cos(math.rad(230)), (gRadius[12] - ballR)*math.sin(math.rad(230)),            1.155*ballR*math.cos(math.rad(-90)) , 1.155*ballR*math.sin(math.rad(-90)),
  1.155*ballR*math.cos(math.rad(30)), 1.155*ballR*math.sin(math.rad(30)),                                  1.155*ballR*math.cos(math.rad(150)), 1.155*ballR*math.sin(math.rad(150)) }

}

_G.bg = display.newRect(centerX, centerY, _W, _H)
bg:setFillColor(1,1,1)

transition.callback = transition.to ;

function transition.fromtocolor(obj, colorFrom, colorTo, time, delay, ease)

        local _obj =  obj ;
        local ease = ease or easing.linear


        local fcolor = colorFrom or {255,255,255} ; -- defaults to white
        local tcolor = colorTo or {0,0,0} ; -- defaults to black
        local t = nil ;
        local p = {} --hold parameters here
        local rDiff = tcolor[1] - fcolor[1] ; --Calculate difference between values
        local gDiff = tcolor[2] - fcolor[2] ;
        local bDiff = tcolor[3] - fcolor[3] ;

                --Set up proxy
        local proxy = {step = 0} ;

    local mt

    if( obj and obj.setTextColor ) then
      mt = {
          __index = function(t,k)
              --print("get") ;
              return t["step"]
          end,

          __newindex = function (t,k,v)
              --print("set")
              --print(t,k,v)
              if(_obj.setTextColor) then
                  _obj:setTextColor(fcolor[1] + (v*rDiff) ,fcolor[2] + (v*gDiff) ,fcolor[3] + (v*bDiff) )
              end
              t["step"] = v ;


          end

      }
    else
       mt = {
          __index = function(t,k)
              --print("get") ;
              return t["step"]
          end,

          __newindex = function (t,k,v)
              --print("set")
              --print(t,k,v)
              if(_obj.setFillColor) then
                  _obj:setFillColor(fcolor[1] + (v*rDiff) ,fcolor[2] + (v*gDiff) ,fcolor[3] + (v*bDiff) )
              end
              t["step"] = v ;


          end

      }
    end

        p.time = time or 1000 ; --defaults to 1 second
        p.delay = delay or 0 ;
        p.transition = ease ;


        setmetatable(proxy,mt) ;

        p.colorScale = 1 ;

        t = transition.to(proxy,p , 1 )  ;

        return t

end

transition.callback = transition.to ;

function transition.matTrans(obj, xt, yt, time, delay )

  local delay = delay or 0

  local function endMove ( obj )
    transition.to( obj, { time=250, xScale = 1.0, yScale = 1.0 } )
  end

  local function move ( obj )
    transition.to( obj, {x = xt, y = yt, onComplete = endMove, easing = easing.inOutCubic, time = time } )
  end

  transition.to( obj, { time=250, xScale = 1.1, yScale = 1.1, onComplete=move } )



end


local function convertDecToLat( number )

    local text = "zero"

    if     number == 1 then text = "One"
    elseif number == 2 then text = "Two"
    elseif number == 3 then text = "Three"
    elseif number == 4 then text = "Four"
    elseif number == 5 then text = "Five"
    elseif number == 6 then text = "Six"
    elseif number == 7 then text = "Seven"
    elseif number == 8 then text = "Eight"
    elseif number == 9 then text = "Nine"
    elseif number == 10 then text = "Ten"
    elseif number == 0 then text = "Zero"
    else                    text = " "
    end

    return text

end
_G.convertDecToLat = convertDecToLat

local function createGrid(w, h, size)
	local p = Math.floor(w / size)
	local q = Math.floor(h / size)
	retval = {}
	for i=1,p do
		retval[i] = {}
		for j=1,q do
			retval[i][j] = false
		end
	end
end

local function convertDecToTens( number )

    local text = "zero"

    if     number == 10 then text = "Ten"
    elseif number == 20 then text = "Twenty"
    elseif number == 30 then text = "Thirty"
    elseif number == 40 then text = "Forty"
    elseif number == 50 then text = "Fifty"
    elseif number == 60 then text = "Sixty"
    elseif number == 70 then text = "Seventy"
    elseif number == 80 then text = "Eighty"
    elseif number == 90 then text = "Ninety"
    elseif number == 100 then text = "One Hundred"
    elseif number == 0 then text = "Zero"
    else                    text = " "
    end

    return text

end
_G.convertDecToTens = convertDecToTens


local composer = require( "composer" )
composer.recycleOnSceneChange = true
composer.gotoScene( "menu" )
