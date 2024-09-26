import levels.*

object juegoStickyBlock {
  method iniciar(){
    game.title("StickyBlock")
	  game.height(10)
	  game.width(20)
    game.boardGround("Fondo.png")

    nivel1.iniciar()

    keyboard.space().onPressDo({nivel2.iniciar()})
  }

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

    //* Verifica para cada elemento del cuerpo si está en la meta

    // verifica si para todos los bloques de la meta existe algun bloque del cuerpo con el que compartan posición

    method cuerpoEnLaMeta() = nivel.actual().goalPositions().all({goalPos => cuerpo.any({compi => compi.position() == goalPos})}) //!hay que delegar el chequeo de la posicion a cada objeto (debe existir ya una forma de chequear si est{a en una posición
    /*method cuerpoEnLaMeta() = cuerpo.all({compi => compi.estaEnLaMeta()})*/

    // //* Verifica si el pj principal está en la meta, fijandose si la posicion coincide con alguna de las de nivelActual.goalPositions()
    // method estaEnLaMeta() = nivel.actual().goalPositions().contains(self.position())
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
      const pj = personajePrincipal //? Por qué no se puede usar directamente personajePrincipal?
      self.eliminarHitBoxes()
      game.onCollideDo(self, {objeto => objeto.interactuarConPersonaje(pj)}) //* Ahora el bloque interactua con otros objetos como si fuese el pj principal  
    }

    method iniciarHitBoxes(){
      hitBoxes.forEach({hitBox => hitBox.iniciar()}) //? Se puede usar addVisual directamente, o cambiar la de abajo (removeVisual) a una que se llame hitBox.eliminar() para que el código sea consistente
    }

    method eliminarHitBoxes(){
      hitBoxes.forEach({hitBox => game.removeVisual(hitBox)})
    }

    //Puede avanzar
    method puedeAvanzar(posicion) = game.getObjectsIn(posicion).all({objeto => objeto.esPisable()})

    method moveTo(movimiento){
      position = movimiento.nuevaPosicion(self)
    }

    //Meta
    // //* Verifica si el pj principal está en la meta, fijandose si la posicion coincide con alguna de las de nivelActual.goalPositions()
    // method estaEnLaMeta() = nivel1.goalPositions().contains(self.position())

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

    //* Cuando el main character colisiona con una hitbox, se agrega el padre de la hitbox a la lista de cuerpo del main, y se le avisa al padre que ahora tiene que comportarse como parte de ese cuerpo ()
    method interactuarConPersonaje(personajePrincipal){ 
      //Setea como compi al padre
      personajePrincipal.agregarACuerpo(padre)
      padre.setAsCuerpo(personajePrincipal)
    }
  }

  //----------------| Movimiento Colectivo |----------------
  //!                          ☝️¿Comunista?☝️
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

    method interactuarConPersonaje(pj){
    //si la posición de cada bloque del cuerpo del pj coincide con una meta => siguiente nivel

    if(pj.cuerpoEnLaMeta())
    nivel.siguiente().iniciar()
    } //TODO: Solo interactua con el rojo, no con el sticky.

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