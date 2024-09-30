import stickyBlocks.*
//*==========================| Creacion de Niveles |==========================
//---------(Clase)--------
  class Nivel {

    method iniciar(){
      juegoStickyBlock.clear()
      self.drawGridMap()
      self.drawCharacters()
      self.drawTopLayer()
    }

    const initialGridMap

    const property siguienteNivel
    
    method drawGridMap(){
      var y = 10
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
      const personajePrincipal = new StickyBlock(position = mainCharacterPosition)
      personajePrincipal.iniciar()
      personajePrincipal.setAsCuerpo()

      //Instanciamos los compis
      stickyBlockPositions.forEach({position => 
        const stickyBlock = new StickyBlock(position = position)
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

  const nivel1 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,p,_,z,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,m,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,l,_,x,_,_,_,_,o,g,g,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,z,_,_,_,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
    ], 
    siguienteNivel = nivel2
  )

    const nivel2 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,p,p,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,m,v,v,v,v,v,v,v,v,v,v,v,v,v,p,v,v,v],
      [v,v,v,v,v,v,v,l,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,z,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,p,v,v,v,v,v,v,v,v,v,v,v],
      [v,_,_,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,z,v,v,v,v,v]
    ], 
    siguienteNivel = null
  )

