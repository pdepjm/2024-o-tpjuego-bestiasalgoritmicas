import levels.*

object juegoStickyBlock {
  method iniciar(){
    game.title("StickyBlock")
	  game.height(10)
	  game.width(20)
    game.boardGround("Fondo.png")

    nivel1.iniciar()
  }
}

//==========================| Entidades |==========================
class PersonajePrincipal{
  method iniciar(){
    game.addVisual(self)

    //Movimiento
    keyboard.up().onPressDo({self.moveTo(position.up(1))})
    keyboard.down().onPressDo({self.moveTo(position.down(1))})
    keyboard.left().onPressDo({self.moveTo(position.left(1))})
    keyboard.right().onPressDo({self.moveTo(position.right(1))})
  }
  
  //Imagen
  method image() = "RojoAnim.gif"

  //Posicion
  var property position

  //Movimiento
  method moveTo(newPosition){
    const puedeAvanzar = game.getObjectsIn(newPosition).all({objeto => objeto.esPisable()})
    if(puedeAvanzar) position = newPosition
  }
}

//==========================| Entorno |==========================
class Meta{
  method iniciar(){
    game.addVisual(self)
  }

  //Imagen
  method image() = "Salida.png"

  //Posision
  const position

  method position() = position

  //Colision
  method esPisable() = true
}

class Pared{
  method iniciar(){
    self.choseImage()
    game.addVisual(self)
  }

  //Imagen
  const images = ["Ladrillo1.png","Ladrillo2.png","Ladrillo3.png","Ladrillo4.png"]
  var image = ""

  method image() = image

  method choseImage(){
    image = images.randomized().head()
  }

  //Posision
  const position

  method position() = position

  //Colision
  method esPisable() = false

}

class Suelo{
  method iniciar(){
    self.choseImage()
    game.addVisual(self)
  }

  //Imagen
  const images = ["Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png", "Piso2.png", "Piso3.png"]
  var image = ""

  method image() = image

  method choseImage(){
    image = images.randomized().head()
  }

  //Posision
  const position

  method position() = position

  //Colision
  method esPisable() = true

}

//==========================| Creacion de Niveles |==========================
class Nivel {

  method iniciar(){
    self.drawGridMap()
    self.drawCharacters()
  }

  const mainCharacterPosition

  const initialGridMap

  method drawGridMap(){
    var y = 10
    var x = 0
    initialGridMap.forEach({row =>
      row.forEach({cell => cell.decode(x, y)
      x+=1
    })
    y-=1
    x=0
    })
  }

  //inciializacion de personaje
  method drawCharacters(){
    const personajePrincipal = new PersonajePrincipal(position = mainCharacterPosition)
    personajePrincipal.iniciar()
  }
}

//------------------| Representaciones del GridMap |------------------

//-------(Entorno)-------

//Pared
object p{
  method decode(x,y){
    const pared = new Pared(position = game.at(x, y))
    pared.iniciar()
  }
}

//Suelo
object _{
  method decode(x,y){
    const suelo = new Suelo(position = game.at(x, y))
    suelo.iniciar()
  }
}

//Vacio
object v{
  method decode(_x,_y){}
}

//Meta
object g{
  method decode(x,y){
    const meta = new Meta(position = game.at(x, y))
    meta.iniciar()
  }
}
