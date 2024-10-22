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
	  game.height(10)
	  game.width(20)
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
 
    method moverCuerpo(direccion, isUnDo){

      const cuerpoPuedeAvanzar = compis.all({compi => compi.puedeAvanzar(direccion.nuevaPosicion(compi))})

      if(cuerpoPuedeAvanzar){
        if (!isUnDo) juegoStickyBlock.addMove(direccion) // Agrega el movimiento al stack de movimientos
        
        compis.forEach({compi => compi.moveTo(direccion)}) //Mueve a los elementos del cuerpo

        compis.forEach({compi => compi.collideWith()})  // Ejecuta Nuesto "Collider"
      }
      
    }

    // Victoria
    method victoriaValida() = juegoStickyBlock.nivelActual().cuerpoSobreMeta() // Verifica si existen compis sobre cada meta
  }

//*==========================| StickyBlock |==========================
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

    image = "RojoParpadea.gif"

    juegoStickyBlock.addMove(self) // Se agrega el movimiento al stack de movimientos
  }

  method iniciarHitBoxes(){
    hitBoxes.forEach({hitBox => hitBox.iniciar()})
  } 

  method eliminarHitBoxes(){
    hitBoxes.forEach({hitBox => hitBox.eliminar()})
  }

  method unDo(){
    cuerpo.eliminarCompi(self)  //1. Lo elimino del cuerpo !Por algún motivo a veces no se desancla en el primer movimiento, si no en el segundo
    juegoStickyBlock.unDo()     //2. Hago el movimiento anterior
    self.iniciarHitBoxes()      //3. Agrego la hitbox

    image = "RojoCerrado.png" 
  }
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
    method unDo(){cuerpo.moverCuerpo(abajo,true)}
  }

  object abajo {
    method nuevaPosicion(objeto) = objeto.position().down(1)
    method unDo(){cuerpo.moverCuerpo(arriba,true)}
  }

  object izquierda {
    method nuevaPosicion(objeto) = objeto.position().left(1)
    method unDo(){cuerpo.moverCuerpo(derecha,true)}
  }

  object derecha {
    method nuevaPosicion(objeto) = objeto.position().right(1)
    method unDo(){cuerpo.moverCuerpo(izquierda,true)}
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
      if (ganoNivel){
        juegoStickyBlock.siguienteNivel()

        //Sonido de Victoria
        const winSound = game.sound("Victoria.mp3")
        winSound.volume(0.1)
        winSound.play()
        }
      
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

  