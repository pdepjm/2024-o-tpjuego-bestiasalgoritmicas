import stickyBlocks.*
import menuYTeclado.*

//*==========================| Creacion de Niveles |==========================
//---------(Clase)--------
  class Nivel {

    method iniciar(){
      juegoStickyBlock.clear()
      self.clearPositions()

      //Dibujo UI
      new OnlyVisual(image="Menu.png",position = game.at(0,9)).iniciar()
      new OnlyVisual(image="Undo-Reset.png",position = game.origin()).iniciar()

      //Dibujo el nivel
      self.drawGridMap()
      self.drawCharacters()
      self.drawTopLayer()

      // Seteo el Teclado para el nivel
      configTeclado.gameOn()

      //Seteo el nivel actual
      juegoStickyBlock.nivelActual(self)
    }

    method clearPositions(){
      goalPositions.clear()
      stickyBlockPositions.clear()
      lampPosition.clear()
    }

    const initialGridMap

    const property siguienteNivel
    
    method drawGridMap(){
      var y = 9
      var x = 0
      initialGridMap.forEach({row =>
        row.forEach({cell => cell.decode(x, y, self)
        x+=1
      })
      y-=1
      x=0
      })
    }
 
    //Goal
    const goalPositions = []

    method addGoalPosition(x,y){
      goalPositions.add(game.at(x, y))
    }

    method cuerpoSobreMeta() = goalPositions.all({goalPos => cuerpo.compis().any({compi => compi.position() == goalPos})})

    //Personaje Principal
    var property mainCharacterPosition = null

    //StickyBlocks
    const stickyBlockPositions = []
    
    method addStickyBlockPosition(x,y){
      stickyBlockPositions.add(game.at(x, y))
    }

    method drawCharacters(){

      //Instanciamos un StickyBlock pero lo inicializamos como cuerpo 
      const personajePrincipal = new PersonajeInicial(position = mainCharacterPosition)
      personajePrincipal.iniciar()

      //Instanciamos los compis
      stickyBlockPositions.forEach({position => 
        const stickyBlock = new StickyCompi(position = position)
        stickyBlock.iniciar()
      })
    }

    //Top Layer objects
    const lampPosition = []

    method addLampPosition(x,y){
      lampPosition.add(game.at(x-1, y-1))
    }

    method drawTopLayer(){
      lampPosition.forEach({pos => 
        const lampara = new Lampara(position = pos)
        lampara.iniciar()
      })
    }
  }

//------------------ Representaciones del GridMap ------------------
//---------(Entorno)--------

  //Vacio
  object v{
    method decode(_x,_y,_level){}
  }

  //Pared
  object p{
    method decode(x,y,_level){
      const pared = new Pared(position = game.at(x, y))
      pared.iniciar()
    }
  }

  //Lamparas
  object l{
      method decode(x,y,level){
      p.decode(x, y,level)
      level.addLampPosition(x,y)
    }
  }

  //Suelo
  object _{
    method decode(x,y,_level){
      const suelo = new Suelo(position = game.at(x, y))
      suelo.iniciar()
    }
  }

  //Trampa
  object o{
    method decode(x,y,_level){
      const agujero = new Agujero(position = game.at(x, y), activa = true)
      agujero.iniciar()
    }
  }

  //Trampa
  object x{
    method decode(x,y,_level){
      const agujero = new Agujero(position = game.at(x, y), activa = false)
      agujero.iniciar()
    }
  }

  //Meta
  object g{
    method decode(x,y,level){
      const meta = new Meta(position = game.at(x, y))
      meta.iniciar()
      level.addGoalPosition(x,y)
    }
  }

  object u{
    method decode(x,y,_level){
      const arrowPopUp = new OnlyVisual(image = "ArrowsPopUp.gif",position = game.at(x, y))
      arrowPopUp.iniciar()
    }
  }

//-------(Personajes)-------

  //Personaje Principal
  object m{
    method decode(x,y,level){
      //Guardo la posicion del personaje principal
      level.mainCharacterPosition(game.at(x, y))

      //Creo suelo donde Spawnea el personaje principal
      _.decode(x, y,level)
    }
  }

  //Compis
  object z{

    method decode(x,y,level){
      //Guardo la posicion de los stickyBlocks
      level.addStickyBlockPosition(x,y)

      //Creo suelo donde Spawnea el personaje principal
      _.decode(x, y,level)
    }
  }

//*==========================| Niveles Instanciados |==========================

  //Move Tutorial
  const nivel1 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,m,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,l,_,_,_,_,_,_,_,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,u,v,v,v,v]
    ], 
    siguienteNivel = nivel2
  )

  //Friend Tutorial
  const nivel2 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,p,_,z,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,m,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,l,_,_,_,_,_,_,g,_,_,l,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,z,_,_,g,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
    ], 
    siguienteNivel = nivel3
  )

  // Friends Levels
  const nivel3 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,z,p,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,g,_,_,_,_,_,_,z,p,v,v,v,v,v],
      [v,v,v,v,l,g,g,g,_,p,_,_,_,_,l,v,v,v,v,v],
      [v,v,v,v,p,m,g,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,z,_,p,z,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
    ], 
    siguienteNivel = nivel4
  )

  const nivel4 = new Nivel(
   initialGridMap = [
      [v,v,v,v,v,v,v,p,p,p,l,p,p,p,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,_,z,_,_,_,p,p,p,p,v,v,v],
      [v,v,p,p,p,_,_,_,_,_,_,_,_,_,_,_,p,p,p,v],
      [v,v,p,_,_,_,_,z,_,_,z,_,_,_,_,_,_,_,p,v],
      [v,v,p,_,_,_,_,_,_,_,_,_,z,_,z,_,_,_,p,v],
      [v,v,l,_,_,m,_,_,_,p,p,p,p,_,_,_,_,_,l,v],
      [v,v,p,_,_,_,_,_,_,g,g,g,g,_,_,_,_,_,p,v],
      [v,v,p,_,_,_,_,_,_,_,g,g,_,_,_,_,_,_,p,v],
      [v,v,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
  ],
    siguienteNivel = null
  )



  const nivelEjemplo = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,p,_,z,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,m,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,l,_,x,_,_,_,_,o,g,g,l,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,z,_,_,_,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
    ], 
    siguienteNivel = nivel2
  )


