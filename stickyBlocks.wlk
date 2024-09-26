import levels.*

object juegoStickyBlock {
  method iniciar(){
    game.title("StickyBlock")
	  game.height(10)
	  game.width(20)
    game.boardGround("Fondo.png")

    nivelActual.iniciar()
  }

  var property nivelActual = nivel1

  method clear(){
    game.allVisuals().forEach({visual => game.removeVisual(visual)})
  }
}



//*==========================| Personajes |==========================

//--------- Personaje Principal ---------
  class PersonajePrincipal{
    
    //Posicion
    var property position

    //Movimiento
    var movimiento = null

    method esPisable() = true

    method iniciar(){
      game.addVisual(self)

      

      // Colision
      game.onCollideDo(self, { objeto => objeto.interactuarConPersonaje(self) })

      // Movimiento
      keyboard.up().onPressDo({movimiento = arriba self.moverCuerpo() })
      keyboard.down().onPressDo({movimiento = abajo self.moverCuerpo() })
      keyboard.left().onPressDo({movimiento = izquierda self.moverCuerpo() })
      keyboard.right().onPressDo({movimiento = derecha self.moverCuerpo() })
    }
  
    // Imagen
    method image() = "Rojo.png"
  
    // Cuerpo
    const cuerpo = [self]

    method agregarACuerpo(compi){
      cuerpo.add(compi)
    }

    // Desplazamiento
    method puedeAvanzar(posicion) = game.getObjectsIn(posicion).all({objeto => objeto.esPisable()})

    method moveTo(movement){
      position = movement.nuevaPosicion(self)
    }

    method moverCuerpo(){
      const cuerpoPuedeAvanzar = cuerpo.all({compi => compi.puedeAvanzar(movimiento.nuevaPosicion(compi))})
      if(cuerpoPuedeAvanzar)
      cuerpo.forEach({elemento => elemento.moveTo(movimiento)}) //Mueve a los elementos del cuerpo
    }

    // Meta

    // Verifica si para todos los bloques de la meta existe algun bloque del cuerpo con el que compartan posición
    method cuerpoEnLaMeta() = juegoStickyBlock.nivelActual().goalPositions().all({goalPos => cuerpo.any({compi => compi.position() == goalPos})}) //!hay que delegar el chequeo de la posicion a cada objeto (debe existir ya una forma de chequear si est{a en una posición
  }

//--------- StickyCompis ---------
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

    //Setea el compi como elemento del cuerpo del personaje principal
    method setAsCuerpo(personajePrincipal){
      const pj = personajePrincipal
      self.eliminarHitBoxes()
      game.onCollideDo(self, {objeto => objeto.interactuarConPersonaje(pj)}) 
    }

    method iniciarHitBoxes(){
      hitBoxes.forEach({hitBox => hitBox.iniciar()})
    } 

    method eliminarHitBoxes(){
      hitBoxes.forEach({hitBox => hitBox.eliminar()})
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

    method eliminar(){
    game.removeVisual(self)
    }

    const padre

    //Posicion
    const property position

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(personajePrincipal){ 
      //Setea como compi al padre
      personajePrincipal.agregarACuerpo(padre)
      padre.setAsCuerpo(personajePrincipal)
    }
  }

  //----------------| Movimiento Colectivo |----------------
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

//*===========================| Entorno |===========================
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

    method interactuarConPersonaje(personajePrincipal){
    const ganoNivel = personajePrincipal.cuerpoEnLaMeta()
    if(ganoNivel)
    juegoStickyBlock.nivelActual().siguienteNivel().iniciar() //t0do eso solamente para decir nivel.siguiente() 
    }

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

  class Lampara{
    method iniciar(){
      game.addVisual(self)
    } 

    //Imagen
    method image() = "Lampara.png"

    //Posicion
    const property position

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(pj){}
  }