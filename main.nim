{.experimental: "codeReordering".}

import os, illwill, sugar, random


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
  "#################          #         #    #################    #",
  "# ->->->->->->  #          #         #    #               #    #",
  "#################          ###########    #          ::   #    #",
  "#  . . . . . . . . . .                    #               #    #",
  "#  .)()()()()()()()().     ###########    #               #    #",
  "#  .)()()()()()()()().     #         #    #        ?      #    #",
  "#  .)()()()()()()()().     #         #    #############  ##    #",
  "#                          #         #                         #",
  "############################         ###########################",
]

var floor2 = @[
  "############################         ######",
  "#                          #         ######",
  "#     #####################################",
  "#                                         #",
  "#     #####################################",
  "#                                      :: #",
  "#     #####################################",
  "#                                         #",
  "#     #####################################",
  "#                          #         ######",
  "############################         ######",
]

var floor3 = @[
  "############################         ###########################",
  "#                          #         #                         #",
  "#######################    #         #    #################    #",
  "#                          #         #    #               #    #",
  "#    #################################    #          ::   #    #",
  "#                                  #      #               #    #",
  "#######################    ###########    #               #    #",
  "#                          ###########    #        ?      #    #",
  "#    #################################    #############  ##    #",
  "#                                                              #",
  "################################################################",
]

var floors = @[floor1, floor2, floor3]

var story = 0

init()

proc drawFloor() =
  for y, line in floors[story]:
    for x, c in line:
      var color = case c:
        of '#': fgMagenta
        else: fgWhite
      tb.write(x, y, resetStyle, color, $c)

proc showDialog(x, y: int, msg: string) =
  tb.drawRect(x, y, x + msg.len + 4, y+3)
  tb.write(x+3, y+1, fgRed, msg)
  tb.display()

proc gameOver =
  showDialog(3, 3, "Caught by Monster! GAME OVER!")
  sleep(2000)
  exitProc()

var movableFloor = [' ', '@', '.']

proc moveMonster(x, y: int; mx, my: var int) =
  var dx = x - mx
  if dx > 0: dx = [0, 1].sample
  if dx < 0: dx = [0, -1].sample

  var dy = y - my
  if dy > 0: dy = 1
  if dy < 0: dy = -1

  let floor = floors[story]

  if floor[my+dy][mx+dx] in movableFloor:
    mx += dx
    my += dy

  elif floor[my+dy][mx] in movableFloor:
    my += dy

  elif floor[my][mx+dx] in movableFloor:
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

  var floor = floors[story]

  if key == Key.Space:
    floor[y][x] = '#'

  if floor[ny][nx] in movableFloor:
    x = nx
    y = ny
    moveMonster(x, y, mx, my)

  if x == mx and y == my:
    gameOver()

  drawFloor()
  tb.write(x, y, fgCyan, "@")
  tb.write(mx, my, fgRed, "%")

  tb.display()

gameOver()

