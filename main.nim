{.experimental: "codeReordering".}

import os, illwill, sugar, random, strformat


var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

proc init() =
  illwillInit(fullscreen = true)
  setControlCHook(exitProc)
  hideCursor()
  tb.setForegroundColor(fgWhite, true)
  drawFloor()
  tb.display()

var y = 5
var x = 5

var my = 2
var mx = 26

var floor1 = @[
  "############################         ###########################",
  "#                          #         #                         #",
  "#####  ##########          #         #    #################    #",
  "#               #          #         #    #               #    #",
  "#  ########   #####        ###########    #          ::   #    #",
  "#  . . . . . . .#. . .                    #               #    #",
  "#  .)()()()()()(#()().     ###########    #               #    #",
  "#  .)()()()()()()()().     #         #    #        ?      #    #",
  "#  .)()()()()()()()().     #         #    #############  ##    #",
  "#                          #         #                         #",
  "############################         ###########################",
]

var floor2 = @[
  "############################         ###########################",
  "#                          #         #                         #",
  "#     ##########################################################",
  "#                  ###  ::                                     #",
  "#     ####################################                     #",
  "#                                                              #",
  "#     ####################################                     #",
  "#               ####                                           #",
  "#     ####################################                     #",
  "#                          #         #                         #",
  "############################         ###########################",
]

var floor3 = @[
  "############################         ###########################",
  "#                          #         #                         #",
  "######  ###############    #         #    #################    #",
  "#                          #         #    #               #    #",
  "#    #################  ##############    #          ::   #    #",
  "#                                ::###    #               #    #",
  "#############  ########    ###########    #               #    #",
  "#                          ###########    #        ?      #    #",
  "#                                                        ##    #",
  "#                                                              #",
  "################################################################",
]

var floor4 = @[
  "############################         ###########################",
  "# ::  #  #                 #         #                         #",
  "#        #                 #         #    #################    #",
  "#####    #                 #         #    #               #    #",
  "#   #    #                 ###########    #               #    #",
  "#                                         #               #    #",
  "#                              #               #    #",
  "#                          ###########    #        ?      #    #",
  "#    #################################    #############  ##    #",
  "#                                      ::                      #",
  "################################################################",
]

var floor5 = @[
  "############################     ###############################",
  "#      XXXXXXXXXXX         #     #                             #",
  "#                          #     #      ::                #",
  "#X X X XXXXXXX             #     #                        #    #",
  "#       X                  #######                        #    #",
  "#      X                                                  #    #",
  "#       X                                                 #    #",
  "#      X                   ###########                    #    #",
  "#       ##############################                   ##    #",
  "#           ::                                                 #",
  "################################################################",
]
var floors = @[floor1, floor2, floor3]

var story = 0

randomize()
init()


proc drawFloor() =
  var xTop = 0
  var yTop = 2

  tb.write(20, 0, resetStyle, fmt"<<< FLOOR {story} >>>")
  for y, line in floors[story]:
    for x, c in line:
      var color = case c:
        of '#': fgYellow
        else: fgWhite
      tb.write(x + xTop, y+yTop, resetStyle, color, $c)

  tb.write(x + xTop, y + yTop, fgCyan, "@")
  tb.write(mx + xTop, my + yTop, fgRed, "%")


proc showDialog(x, y: int, msg: string) =
  tb.drawRect(x, y, x + msg.len + 1, y+2)
  tb.write(x+1, y+1, fgRed, msg)
  tb.display()

proc gameOver =
  showDialog(3, 3, "  Caught by Monster! GAME OVER!  ")
  sleep(2000)
  exitProc()

var movableFloor = [' ', '@', '.']

proc moveMonster(x, y: int; mx, my: var int) =
  var dx = x - mx
  if dx > 0: dx = 1
  if dx < 0: dx = -1

  var dy = y - my
  if dy > 0: dy = 1
  if dy < 0: dy = -1

  # diagonal move
  var canTresspassWall: bool = rand(100) < 2
  if canTresspassWall or floors[story][my+dy][mx+dx] in movableFloor:
    mx += dx
    my += dy

  # vertical move
  elif floors[story][my+dy][mx] in movableFloor:
    my += dy

  # horizontal move
  elif floors[story][my][mx+dx] in movableFloor:
    mx += dx

while true:

  var key = getKey()
  case key:
    of Key.None: sleep(100); continue
    of Key.Escape, Key.Q: exitProc()
    else: discard

  tb.write(x, y, " ")

  var
    nx = x
    ny = y

  if key == Key.Right:
    nx = x + 1
  if key == Key.Left:
    nx = x - 1
  if key == Key.Up:
    ny = y - 1
  if key == Key.Down:
    ny = y + 1

  if key == Key.Space:
    floors[story][y][x] = 'X'

  # floor boundary check

  if floors[story][ny][nx] == ':':
    story += 1
    continue

  if floors[story][ny][nx] in movableFloor:
    x = nx
    y = ny
    moveMonster(x, y, mx, my)

  if x == mx and y == my:
    gameOver()

  drawFloor()

  tb.display()

gameOver()

