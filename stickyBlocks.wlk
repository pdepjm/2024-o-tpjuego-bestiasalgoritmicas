import levels.*

object juegoStickyBlock {
  method iniciar(){
    game.title("StickyBlock")
	  game.height(10)
	  game.width(20)
    game.boardGround("Fondo.png")
    menu.iniciar()
    keyboard.m().onPressDo({menu.iniciar()})
    keyboard.r().onPressDo({nivelActual.iniciar()})
    keyboard.t().onPressDo({nivelEjemplo.iniciar()})
    cuerpo.iniciar()
  }

  var property nivelActual = nivel1

  method siguienteNivel(){
    nivelActual = nivelActual.siguienteNivel()
    nivelActual.iniciar()
  }

  method clear(){
    cuerpo.clear()	
    game.allVisuals().forEach({visual => game.removeVisual(visual)})
  }
}

//*==========================| MENU Inicial |==========================
  object menu{
    method iniciar(){
      juegoStickyBlock.clear()

      menuActivo = true
      levelMenuIsOpen = false

      self.drawMenu()

      keyboard.r().onPressDo({})
      keyboard.p().onPressDo({if(menuActivo) {juegoStickyBlock.nivelActual().iniciar() menuActivo = false}})
      keyboard.l().onPressDo({if(menuActivo) {self.toggleLevelMenu()}})
    }
  
    var menuActivo = true  //!AYUDA!! esto es una mierda pero no se como eliminar el onPressDo lpm
    var levelMenu = null
    var levelMenuIsOpen = false

    method toggleLevelMenu() = if(levelMenuIsOpen) self.closeLevelMenu() else self.openLevelMenu()
    
    method drawMenu(){
      new OnlyVisual(image = "Logo.png", position = game.at(7,6)).iniciar()
      levelMenu = new OnlyVisual(image = "CloseMenu.png", position = game.at(6,3))
      levelMenu.iniciar()
    }

    method closeLevelMenu(){
      levelMenu.image("CloseMenu.png")
      levelMenuIsOpen = false
      keyboard.num1().onPressDo({})
      keyboard.num2().onPressDo({})
      keyboard.num3().onPressDo({})
      keyboard.num4().onPressDo({})
    }

    method openLevelMenu(){
      levelMenu.image("OpenMenu.png")
      levelMenuIsOpen = true
      keyboard.num1().onPressDo({if(menuActivo && levelMenuIsOpen) {nivel1.iniciar() juegoStickyBlock.nivelActual(nivel1)}})
      keyboard.num2().onPressDo({if(menuActivo && levelMenuIsOpen) {nivel2.iniciar() juegoStickyBlock.nivelActual(nivel2)}})
      keyboard.num3().onPressDo({if(menuActivo && levelMenuIsOpen) {nivel3.iniciar() juegoStickyBlock.nivelActual(nivel3)}})
      keyboard.num4().onPressDo({if(menuActivo && levelMenuIsOpen) {nivel4.iniciar() juegoStickyBlock.nivelActual(nivel4)}})
    }
  }

  //PD: Level menu podría ser un objeto pero...

  class OnlyVisual{
    method iniciar(){
      game.addVisual(self)
    }

    var property image 

    const property position 
  }

//*==========================| Cuerpo |==========================
  object cuerpo{

    var movimiento = null

    method iniciar(){

      // Movimiento
      movimiento = null
      keyboard.up().onPressDo({movimiento = arriba self.moverCuerpo() })
      keyboard.down().onPressDo({movimiento = abajo self.moverCuerpo() })
      keyboard.left().onPressDo({movimiento = izquierda self.moverCuerpo() })
      keyboard.right().onPressDo({movimiento = derecha self.moverCuerpo() })
    }

    method clear(){
      compis.clear()
    }

      // Cuerpo
    const property compis = []

    method agregarACuerpo(compi){
      compis.add(compi)
    }

    method eliminarCompi(compi){
      compis.remove(compi)
    }
        
    method moverCuerpo(){

      const cuerpoPuedeAvanzar = compis.all({compi => compi.puedeAvanzar(movimiento.nuevaPosicion(compi))})

      if(cuerpoPuedeAvanzar) compis.forEach({compi => compi.moveTo(movimiento)  compi.collideWith()}) //Mueve a los elementos del cuerpo //? y ejecuta Nuesto "Collider" 
      //?PD: El "collider" lo hago como schedule ya que asi se ve visualmente que el pj se sube a la meta, en el otro caso no se ve ya que wollok calcula todo antes de ejecutar y cambia de nivel sin avanzar al personaje
      
      //game.flushEvents(game.currentTime()) //! Esto soluciona el problema de la colision pero genra mucho lag 😡😡💢
    }

    // Victoria
      method victoriaValida() = juegoStickyBlock.nivelActual().cuerpoSobreMeta() // Verifica si existen compis sobre cada meta
  }

//*==========================| Personajes |==========================
//--------- StickyCompis ---------
  class StickyBlock{
    method iniciar(){
      game.addVisual(self)
      self.iniciarHitBoxes()
    }
    
    //Imagen
    method image() = "Rojo.png"

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
    method setAsCuerpo(){

      self.eliminarHitBoxes()

      cuerpo.agregarACuerpo(self)
      // game.onCollideDo(self, {objeto => objeto.interactuarConPersonaje(self)}) //! Esto no funciona 😡😡💢
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

    method collideWith(){
      game.getObjectsIn(position).forEach({objeto => objeto.interactuarConPersonaje(self)}) //? Utilizamos esto como onCollideDo ya que on colide se saltea colisiones y va mas lento
    }

    //Desaparecer  🚙😥🔫
    method desaparecer(){
      game.removeVisual(self)
      cuerpo.eliminarCompi(self)
    }

    method interactuarConPersonaje(pj){}
  }
  
//--------- HitBox ---------
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

    method interactuarConPersonaje(pj){ 
      
      //Setea como compi al padre
      padre.setAsCuerpo()
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

    method interactuarConPersonaje(pj){

      //Verifica si ha ganado el nivel
      const ganoNivel = cuerpo.victoriaValida()
      if (ganoNivel) {juegoStickyBlock.siguienteNivel()}
      
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

  class Agujero{
    method iniciar(){
      self.choseImage()
      game.addVisual(self)
    }

    var activa // activa = abierta

    //Imagen
    const images = ["Trampa2.png","Trampa3.png","Trampa4.png","Trampa5.png"]
    var image = ""

    method image() = image

    method choseImage(){
      image = if(activa) "Trampa1.png" else images.randomized().head()
    
    }

    //Posicion
    const property position

    method activar(){
      image = "Trampa1.png"
      activa = true
    }

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(compi){
      if(activa) compi.desaparecer() else self.activar()
    }
  }