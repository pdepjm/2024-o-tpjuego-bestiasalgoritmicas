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
    method limpiarTeclado(){
        
        //Movimientos: OFF
        keyboard.up().onPressDo({})
        keyboard.down().onPressDo({})
        keyboard.left().onPressDo({})
        keyboard.right().onPressDo({})

        //Menu: OFF
        keyboard.m().onPressDo({})
        keyboard.l().onPressDo({})
        keyboard.r().onPressDo({})

        //LevelMenu: OFF
        keyboard.num1().onPressDo({})
        keyboard.num2().onPressDo({})
        keyboard.num3().onPressDo({})
        keyboard.num4().onPressDo({})

    }

    method gameOn(){
        self.limpiarTeclado()

        //Movimientos:
        keyboard.up().onPressDo({ cuerpo.moverCuerpo(arriba) })
        keyboard.down().onPressDo({ cuerpo.moverCuerpo(abajo) })
        keyboard.left().onPressDo({ cuerpo.moverCuerpo(izquierda) })
        keyboard.right().onPressDo({ cuerpo.moverCuerpo(derecha) })

        //Menu en nivel:
        keyboard.m().onPressDo({menu.iniciar()})
        keyboard.r().onPressDo({juegoStickyBlock.nivelActual.iniciar()})
    }

    method menuOn(){
        self.limpiarTeclado()

        //Menu:
        keyboard.p().onPressDo({{juegoStickyBlock.nivelActual().iniciar()}})
        keyboard.l().onPressDo({{levelMenu.toggle()}})
    }

    method levelMenuOn(){
        self.limpiarTeclado()

        //Menu:
        self.menuOn()

        //LevelMenu:
        keyboard.num1().onPressDo({nivel1.iniciar()})
        keyboard.num2().onPressDo({nivel2.iniciar()})
        keyboard.num3().onPressDo({nivel3.iniciar()})
        keyboard.num4().onPressDo({nivel4.iniciar()})
    }
}