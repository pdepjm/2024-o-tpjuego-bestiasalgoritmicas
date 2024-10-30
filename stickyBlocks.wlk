import levels.*
import menuYTeclado.*

object juegoStickyBlock {
  
  var property nivelActual = nivel1
  var movimientos = []

  //Config Audio
  const music = game.sound("InideGame.mp3")
  
  method iniciar(){

    //Set game properties
    game.title("StickyBlock")
	  game.height(12)
	  game.width(24)
    game.boardGround("Fondo.png")

    //Set Background Audio
    music.shouldLoop(true)
    music.volume(0.3)
    music.play()
    

    //inicializo teclado
    configTeclado.iniciar()

    //Inicio el menu
    menu.iniciar()

    //nivelActual.iniciar()
  }
  
  method reset(){
    movimientos.forEach({_=> self.unDo()}) // Ejecuta unDo() por la cantidad de movimientos ejecutados
  }

  method clear(){
    cuerpo.clear()
    movimientos.clear()
    game.allVisuals().forEach({visual => game.removeVisual(visual)})
  }

  method siguienteNivel(){
    nivelActual = nivelActual.siguienteNivel()
    nivelActual.iniciar()
  }

  method addMove(movimiento){
    movimientos = [movimiento] + movimientos
  }

  method unDo(){
    if(!movimientos.isEmpty()){
      const move = movimientos.head()
      movimientos = movimientos.drop(1)
      move.unDo()
    }
  }
}

//*==========================| Cuerpo |==========================
  object cuerpo{

    // Cuerpo
    const property compis = []

    method clear(){
      compis.clear()
    }

    method agregarACuerpo(compi){
      compis.add(compi)
    }

    method eliminarCompi(compi){
      compis.remove(compi)
    }
 
    method moverCuerpo(movimiento){

      const cuerpoPuedeAvanzar = compis.all({compi => compi.puedeAvanzar(movimiento.nuevaPosicion(compi))}) && !compis.isEmpty()

      if(cuerpoPuedeAvanzar){
        juegoStickyBlock.addMove(movimiento) // Agrega el movimiento al stack de movimientos
        
        self.ejecutarMovimiento(movimiento) //Mueve a los elementos del cuerpo

        compis.forEach({compi => compi.collideWith()})  // Ejecuta Nuesto "Collider"
      }
    }

    method ejecutarMovimiento(movimiento){
      compis.forEach({compi => compi.moveTo(movimiento)})
    }

    // Victoria
    method victoriaValida() = juegoStickyBlock.nivelActual().cuerpoSobreMeta() // Verifica si existen compis sobre cada meta
  }

//*========================| StickyBlock |=======================
  class StickyBlock{
    
    //Imagen
    var property image = "RojoCerrado.png"

    //Posicion
    var property position

    method iniciar(){
      game.addVisual(self)
    }

    //Colision
    method esPisable() = true

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

      //Se agrega a movimientos para poder deshacer
      juegoStickyBlock.addMove(self)
    }

    //Aparecer 
    method aparecer(){
      game.addVisual(self)
      cuerpo.agregarACuerpo(self)

      //Deshace el movimiento anterior
      juegoStickyBlock.unDo()
    }

    method interactuarConPersonaje(pj){}
  }

  //--------- Personaje Inicial ---------
  class PersonajeInicial inherits StickyBlock{

    override method iniciar(){
      
      super()
      
      cuerpo.agregarACuerpo(self)

      image = "RojoParpadea.gif"
    }

    method unDo(){
      self.aparecer()
    }
  }

  //--------- Sticky Compis ---------
  class StickyCompi inherits StickyBlock{

    //Genera las HitBox alrededor del StickyBlock
    const hitBoxes = [
      new HitBox(padre = self, position = position.up(1)), 
      new HitBox(padre = self, position = position.down(1)),
      new HitBox(padre = self, position = position.left(1)),
      new HitBox(padre = self, position = position.right(1))
    ]

    override method iniciar(){
      super()
      self.iniciarHitBoxes()
    }

    //Setea el compi como elemento del cuerpo del personaje principal
    method setAsCuerpo(){

      self.eliminarHitBoxes()

      cuerpo.agregarACuerpo(self)

      self.collideWith()

      image = "RojoParpadea.gif"

      juegoStickyBlock.addMove(self) //Se agrega a movimientos para poder deshacer
    }

    method iniciarHitBoxes(){
      hitBoxes.forEach({hitBox => hitBox.iniciar()})
    } 

    method eliminarHitBoxes(){
      hitBoxes.forEach({hitBox => hitBox.eliminar()})
    }

    method desanclar(){

      cuerpo.eliminarCompi(self)  //1. Lo elimino del cuerpo
      juegoStickyBlock.unDo()     //2. Hago el movimiento anterior
      self.iniciarHitBoxes()      //3. Agrego la hitbox

      image = "RojoCerrado.png" 
    }

    method unDo(){
      //Valida si se esta esta haciendo el unDo de la caida en una Trampa/Agujero o de un seteo como cuerpo
      if(game.hasVisual(self)){self.desanclar()}else{self.aparecer()}
    }
  }

  //----- HitBox 
  class HitBox{
      
    const padre

    //Posicion
    const property position

    method iniciar(){
      game.addVisual(self)
    }

    method eliminar(){
      game.removeVisual(self)
    }

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
    method unDo(){cuerpo.ejecutarMovimiento(abajo)}
  }

  object abajo {
    method nuevaPosicion(objeto) = objeto.position().down(1)
    method unDo(){cuerpo.ejecutarMovimiento(arriba)}
  }

  object izquierda {
    method nuevaPosicion(objeto) = objeto.position().left(1)
    method unDo(){cuerpo.ejecutarMovimiento(derecha)}
  }

  object derecha {
    method nuevaPosicion(objeto) = objeto.position().right(1)
    method unDo(){cuerpo.ejecutarMovimiento(izquierda)}
  }

  //PD: Los unDo directamente ejeceutan el movimiento contrario (sin pasar por la validacion ni del collider de MoverCuerpo)

//*==========================| Entorno |=========================
  class Meta{

    //Posicion
    const property position

    //Imagen
    method image() = "Salida.png"

    method iniciar(){
      game.addVisual(self)
    }

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(pj){
    }
  }

  class MetaValidadora inherits Meta{
    override method interactuarConPersonaje(pj){
      //Verifica si ha ganado el nivel
      const ganoNivel = cuerpo.victoriaValida()
      if (ganoNivel){

        //Sonido de Victoria
        const winSound = game.sound("Victoria.mp3")
        winSound.volume(0.1)
        winSound.play()

        juegoStickyBlock.siguienteNivel()

        }
    }
  }

  class Pared{
   
    //Imagen
    const images = ["Ladrillo1.png","Ladrillo2.png","Ladrillo3.png","Ladrillo4.png"]
    var property image = ""

    //Posicion
    const property position

    method iniciar(){
      self.choseImage()
      game.addVisual(self)
    }

    method choseImage(){
      image = images.randomized().head()
    }

    //Colision
    method esPisable() = false

    method interactuarConPersonaje(pj){}

  }

  class Suelo{
    
    //Imagen
    const images = ["Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png","Piso1.png", "Piso2.png", "Piso3.png"]
    var property image = ""

    //Posicion
    const property position

    method iniciar(){
      self.choseImage()
      game.addVisual(self)
    }

    method choseImage(){
      image = images.randomized().head()
    }

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(pj){}

  }

  class Lampara{
    
    //Posicion
    const property position

    //Imagen
    method image() = "Lampara.png"


    method iniciar(){
      game.addVisual(self)
    } 

    //Colision
    method esPisable() = true

    method interactuarConPersonaje(pj){}
  }

  class Agujero{
    
    var estadoActual // true = abierta

    //Posicion
    const property position

    //Imagen
    const images = ["Trampa2.png","Trampa3.png","Trampa4.png","Trampa5.png"]
    var property image = ""

    method iniciar(){

      self.choseImage()
      game.addVisual(self)
    }

    method choseImage(){
      image = if(estadoActual) "Trampa1.png" else images.randomized().head()
    }

    //Colision
    method esPisable() = true

    method activar(){
      image = "Trampa1.png"
      estadoActual = true
    }

    //Este unDo es para desactivar la trampa --> En el caso de deshacer la eliminacion de un personaje se encarga el StickyBlock
    method unDo(){
      estadoActual = false
      self.choseImage()

      //Se ejecuta tambien el movimiento anterior
      juegoStickyBlock.unDo()
    }

    method interactuarConPersonaje(compi){
      
      if(estadoActual){
        compi.desaparecer()
      } else {
        self.activar()
        //Se agrega a movimientos para poder deshacer
        juegoStickyBlock.addMove(self)
      }
    }
  }

  