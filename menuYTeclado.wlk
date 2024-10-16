import stickyBlocks.*
import levels.*

//*==========================| MENU Inicial |==========================
  object menu{
    method iniciar(){
      juegoStickyBlock.clear()
      
      //Visuales
      self.drawMenu()

      //Teclado
      configTeclado.menuOn()
    }
    
    method drawMenu(){
      new OnlyVisual(image = "Logo.png", position = game.at(7,6)).iniciar()
      levelMenu.iniciar()
    }

  }

  object levelMenu{
    const property position = game.at(6,3)
    var levelMenuIsOpen = false
    var image = "CloseMenu.png"
    
    method image() = image
    
    method iniciar(){
      game.addVisual(self)
    }

    method toggle() = if(levelMenuIsOpen) self.close() else self.open()

    method close(){
    image = "CloseMenu.png"
    configTeclado.menuOn()
    levelMenuIsOpen = false
    }

    method open(){
    image = "OpenMenu.png"
    configTeclado.levelMenuOn()
    levelMenuIsOpen = true
    }
  }

  class OnlyVisual{
    method iniciar(){
      game.addVisual(self)
    }

    var property image 

    const property position 
  }

//*==========================| Config Teclado |==========================
  object configTeclado{

    var gameState = false
    var menuState = false
    var levelMenuState = false

    method iniciar(){

      //* GAME ON:

        //Movimientos:
        keyboard.up().onPressDo({if(gameState) {cuerpo.moverCuerpo(arriba) juegoStickyBlock.addMove(arriba)}})
        keyboard.down().onPressDo({if(gameState) {cuerpo.moverCuerpo(abajo) juegoStickyBlock.addMove(abajo)}})
        keyboard.left().onPressDo({if(gameState) {cuerpo.moverCuerpo(izquierda) juegoStickyBlock.addMove(izquierda)}})
        keyboard.right().onPressDo({if(gameState) {cuerpo.moverCuerpo(derecha) juegoStickyBlock.addMove(derecha)}})

        //unDo:
        keyboard.control().onPressDo({if(gameState) juegoStickyBlock.unDo()})

        //Menu en nivel:
        keyboard.m().onPressDo({if(gameState) menu.iniciar()})
        keyboard.r().onPressDo({if(gameState) juegoStickyBlock.reset()})

      //* MENU ON:
        keyboard.p().onPressDo({if(menuState) juegoStickyBlock.nivelActual().iniciar()})
        keyboard.l().onPressDo({if(menuState) levelMenu.toggle()})

      //* LEVEL MENU ON:
        keyboard.num1().onPressDo({if(levelMenuState) nivel1.iniciar()})
        keyboard.num2().onPressDo({if(levelMenuState) nivel2.iniciar()})
        keyboard.num3().onPressDo({if(levelMenuState) nivel3.iniciar()})
        keyboard.num4().onPressDo({if(levelMenuState) nivel4.iniciar()})
      
    }

    method limpiarTeclado(){
      //Game: OFF
      gameState = false
      //Menu: OFF
      menuState = false
      //LevelMenu: OFF
      levelMenuState = false
    }

    method gameOn(){
      self.limpiarTeclado()
      gameState = true
    }

    method menuOn(){
      self.limpiarTeclado()
      menuState = true
    }

    method levelMenuOn(){
      self.limpiarTeclado()
      self.menuOn()
      levelMenuState = true
    }
  }