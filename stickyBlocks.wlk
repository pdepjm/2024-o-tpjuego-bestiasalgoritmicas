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
  
  //Posicion
  var property position

  //Movimiento
  var movimiento = null

  method esPisable() = true

  method iniciar(){
    game.addVisual(self)

    //Colision
    game.onCollideDo(self, { objeto => objeto.interactuarConPersonaje(self) })

    //Movimiento
    keyboard.up().onPressDo({movimiento = arriba self.moveTo(arriba.nuevaPosicion(self)) })
    keyboard.down().onPressDo({movimiento = abajo self.moveTo(abajo.nuevaPosicion(self)) })
    keyboard.left().onPressDo({movimiento = izquierda self.moveTo(izquierda.nuevaPosicion(self)) })
    keyboard.right().onPressDo({movimiento = derecha self.moveTo(derecha.nuevaPosicion(self)) })
  }
  
  //Imagen
  method image() = "RojoAnim.gif"

  method moveTo(newPosition){
    const selfPuedeAvanzar = game.getObjectsIn(newPosition).all({objeto => objeto.esPisable()}) 
    const stickyCompisPuedenAvanzar = stickyCompis.all({compi => compi.puedeAvanzar(movimiento.nuevaPosicion(compi))}) || stickyCompis.isEmpty()
    
    if(selfPuedeAvanzar && stickyCompisPuedenAvanzar) {
      position = newPosition //Mueve al personaje principal
      stickyCompis.forEach({compi => compi.moveTo(movimiento)}) //Mueve a los stickyCompis
    }
  }

  //StickyCompis
  const stickyCompis = []

  method agregarCompi(compi){
    stickyCompis.add(compi)
  }
}

class StickyBlock{
  method iniciar(){
    game.addVisual(self)
    self.iniciarHitBoxes()
  }
  
  //Imagen
  method image() = "Azul.png"

  //Posicion
  var property position

  //Colision
  method esPisable() = true

  //Genera las HitBox alrededor del StickyBlock
  const hitBoxes = [
    new HitBox(padre = self, position = position.up(1)), 
    new HitBox(padre = self, position = position.down(1)),
    new HitBox(padre = self, position = position.left(1)),
    new HitBox(padre = self, position = position.right(1))
  ]

  //Seto el stickyBlock como Compi

  method setAsCompi(){
    self.eliminarHitBoxes()
    game.onCollideDo(self, { objeto => objeto.interactuarConPersonaje(self) })
  }

  method iniciarHitBoxes(){
    hitBoxes.forEach({hitBox => hitBox.iniciar()})
  }

  method eliminarHitBoxes(){
    hitBoxes.forEach({hitBox => game.removeVisual(hitBox)})
  }

  //Puede avanzar
  method puedeAvanzar(posicion) = game.getObjectsIn(posicion).all({objeto => objeto.esPisable()})

  method moveTo(movimiento){
    position = movimiento.nuevaPosicion(self)
  }
  
}

class HitBox{
  method iniciar(){
    game.addVisual(self)
  }

  const padre

  //Posicion
  const property position

  //Colision
  method esPisable() = true

  method interactuarConPersonaje(personajePrincipal){
    //Setea como compi al padre
    personajePrincipal.agregarCompi(padre)
    padre.setAsCompi()
  }
}

//==========================| Movimiento Colectivo |==========================

object arriba {
  method nuevaPosicion(objeto) = objeto.position().up(1)
}

object abajo {
  method nuevaPosicion(objeto) = objeto.position().down(1)
}

object izquierda {
  method nuevaPosicion(objeto) = objeto.position().left(1)
}

object derecha {
  method nuevaPosicion(objeto) = objeto.position().right(1)
}

//==========================| Entorno |==========================
class Meta{
  method iniciar(){
    game.addVisual(self)
  }

  //Imagen
  method image() = "Salida.png"

  //Posicion
  const property position

  //Colision
  method esPisable() = true

  method interactuarConPersonaje(pj){} //TODO: Solo interactua con el rojo, no con el sticky.

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

  //Posicion
  const property position

  //Colision
  method esPisable() = false

  method interactuarConPersonaje(pj){}

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

  //Posicion
  const property position

  //Colision
  method esPisable() = true

  method interactuarConPersonaje(pj){}

}

//==========================| Creacion de Niveles |==========================
class Nivel {

  method iniciar(){
    self.drawGridMap()
    self.drawCharacters()
  }

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

  //instanciamos de personaje
  method drawCharacters(){
    const personajePrincipal = new PersonajePrincipal(position = m.mainCharacterPosition())
    personajePrincipal.iniciar()

    z.stickyBlockPositions().forEach({position => 
      const stickyBlock = new StickyBlock(position = position)
      stickyBlock.iniciar()
    })
  }
}

//------------------ Representaciones del GridMap ------------------

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

object m{
  var mainCharacterPosition = null

  method mainCharacterPosition() = mainCharacterPosition

  method decode(x,y){
    //Guardo la posicion del personaje principal
    mainCharacterPosition = game.at(x, y)

    //Creo suelo donde Spawnea el personaje principal
    const suelo = new Suelo(position = mainCharacterPosition)
    suelo.iniciar()
  }
}

object z{
  const stickyBlockPositions = []

  method stickyBlockPositions() = stickyBlockPositions

  method decode(x,y){
    //Guardo la posicion de los stickyBlocks
    stickyBlockPositions.add(game.at(x, y))

    //Creo suelo donde Spawnea el personaje principal
    const suelo = new Suelo(position = game.at(x, y))
    suelo.iniciar()
  }
}