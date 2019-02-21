class Director
  @@d = 50
  @@r = @@d / 2
  @@sx = @@sy = 20
  @@ex = @@sx + @@d * SIDE
  @@ey = @@sy + @@d * SIDE
  @@rx = @@ex + 10
  @@STRCOLOR = C_BLUE
  @@STRFONTSIZE = 32
  @@exitFlag = 0
  @@font = Font.new(28)
  @@mouse = Sprite.new(0, 0, Image.new(10, 10, C_WHITE))
  @@menu0 = Menu.new(Window.width / 4, Window.height / 2, "Push Mouse", 64)
  @@menu1 = [
    Menu.new(Window.width * 0 / 3, Window.height / 2, "3", 92),
    Menu.new(Window.width * 1 / 3, Window.height / 2, "5", 92),
    Menu.new(Window.width * 2 / 3, Window.height / 2, "7", 92)
  ]
  @@menu2 = [
    Menu.new(Window.width * 0 / 4, Window.height / 2, "Normal", 30),
    Menu.new(Window.width * 1 / 4, Window.height / 2, "Handicap", 30),
    Menu.new(Window.width * 2 / 4, Window.height / 2, "Weak", 30),
    Menu.new(Window.width * 3 / 4, Window.height / 2, "Revolution", 30)
  ]
  @@menu3 = Menu.new(Window.width / 3, Window.height / 2, "Start", 64)

  def initialize
    @menu = 0
  end

  def init
    @game = Othello.new
    @manturn = BLACK_TURN
    @finish = false
    @putflag = false
  end

  def initGrp
    @scene_back = Image.new(Window.width, Window.height, C_GREEN)
    @board_back = Image.new(Window.width, Window.height, C_BLACK)
  end

  def waitDisp
  
  end

  def title
    Window.draw(0, 0, Image[:title_back])
    @@mouse.x, @@mouse.y = Input.mouse_pos_x, Input.mouse_pos_y
    case @menu
    when MENU::TITLE
      if Input.mouse_push?(M_LBUTTON) and @@mouse === @@menu0
        @menu = MENU::DEPTH
      end
      @@menu0.draw
    when MENU::DEPTH
      if Input.mouse_push?(M_LBUTTON) and @@mouse === @@menu1
        @menu = MENU::MODE
        $maxdepth = 3
      end
      Menu.draw(@@menu1)
    when MENU::MODE
      if Input.mouse_push?(M_LBUTTON) and @@mouse === @@menu2
        @menu = MENU::START
        $mode = MODE::NORMAL
      end
      Menu.draw(@@menu2)
    when MENU::START
      if Input.mouse_push?(M_LBUTTON) and @@mouse === @@menu3
        @menu = MENU::TITLE
        init
        showBoard
        Window.draw_font(@@rx, @@ey / 2 - 20, "GAME START!!", @@font)
        $scene = SCENE::GAME
      end
      @@menu3.draw
    end
  end

  def getPosFromMouse (mouse_x, mouse_y)
    x = ((mouse_x - @@sx + @@d) / @@d).floor
    y = ((mouse_y - @@sy + @@d) / @@d).floor
    return @game.getPosition(x, y)
  end

  def manPlayerGUI
    moves = Array.new(MOVENUM)
    moves, num = @game.generateMoves(moves)
    if num == 0
      @game.nextmove = PASSMOVE
      @putflag = true
      return
    else
      @putflag = false
    end
    if Input.mouse_push?(M_LBUTTON)
      move = getPosFromMouse(Input.mouse_pos_x, Input.mouse_pos_y)
      if @game.isLegalMove(move)
        @game.nextmove = move
        @putflag = true
      end
    end
  end

  def showBoard
    ry = 40
    rdy = @@STRFONTSIZE + 5
    Window.draw(0, 0, Image[:game_back])
    Window.draw_box_fill(@@sx, @@sy, @@ex, @@ey, C_GREEN)
    SIDE.times do |x|
      Window.draw_line(@@sx + @@d * x, @@sy, @@sx + @@d * x, @@sy + @@d * SIDE, C_BLACK)
    end
    SIDE.times do |y|
      Window.draw_line(@@sx, @@sy + @@d * y, @@sx + @@d * SIDE, @@sy + @@d * y, C_BLACK)
    end
    SIDE.times do |y|
      SIDE.times do |x|
        stone = @game.board[@game.getPosition(x + 1, y + 1)]
        if stone == B
          color = C_BLACK
        elsif stone == W
          color = C_WHITE
        else
          next
        end
        Window.draw_circle_fill(@@sx + @@d * x + @@r, @@sy + @@d * y + @@r, @@r, color)
      end
    end
    Window.draw_font(@@rx, ry, "○: #{@game.stonenum[BLACK_TURN]}", @@font)
    ry += rdy
    Window.draw_font(@@rx, ry, "●: #{@game.stonenum[WHITE_TURN]}", @@font)
    ry += rdy * 2
    Window.draw_font(@@rx, ry, "#{@game.ply} 手", @@font)
    Window.draw_font(@@rx, @@ey, "Thinking...", @@font) if !@finish and @putflag
  end

  def game
    moves = Array.new(MOVENUM)
    moves, num = @game.generateMoves(moves)
    if num == 0 and @game.isTerminalNode
      if $mode == MODE::WEAK
        result = @game.stonenum[WHITE_TURN] - @game.stonenum[BLACK_TURN]
      else
        result = @game.stonenum[BLACK_TURN] - @game.stonenum[WHITE_TURN]
      end
      if result == 0
        Window.draw_font(@@rx, @@ey / 2 - 20, "DRAW!!", @@font)
      else
        Window.draw_font(@@rx, @@ey / 2 - 20, "#{(result > 0 ? "BLACK" : "WHITE")} WIN!!", @@font)
      end
      @finish = true
    end
    if @finish
      showBoard
      Window.draw_font(@@rx, @@ey / 2 + 50, "Push Key!!", @@font)
      $scene = SCENE::TITLE if Input.mouse_push?(M_LBUTTON)
    else
      if @game.turn == @manturn
        manPlayerGUI
      else
        @game.comPlayer
        @putflag = true
      end
      if @putflag
        @game.makeMove(@game.nextmove, 0)
        if @game.nextmove == PASSMOVE
          Window.draw_font(@@rx, @@ey / 2 - 20, "PASS!!", @@font)
        else
          @game.ply += 1
        end
        if @game.turn == @manturn
        else
        end
      end
      showBoard
    end
  end
end
