
import stickyBlocks.*

//*==========================| Creacion de Niveles |==========================
//---------(Clase)--------
  class Nivel {

    method iniciar(){
      self.drawGridMap()
      self.drawCharacters()
      self.drawTopLayer()
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

    method drawTopLayer(){
      l.lampPosition().forEach({pos => 
        const lampara = new Lampara(position = pos)
        lampara.iniciar()
      })
    }
  }

//------------------ Representaciones del GridMap ------------------
//---------(Entorno)--------

  //Vacio
  object v{
    method decode(_x,_y){}
  }

  //Pared
  object p{
    method decode(x,y){
      const pared = new Pared(position = game.at(x, y))
      pared.iniciar()
    }
  }

  //Lamparas
  object l{
    const property lampPosition = []
      method decode(x,y){
      p.decode(x, y)
      lampPosition.add(game.at(x-1, y-1))
    }
  }

  //Suelo
  object _{
    method decode(x,y){
      const suelo = new Suelo(position = game.at(x, y))
      suelo.iniciar()
    }
  }

  //Meta
  object g{
    method decode(x,y){
      const meta = new Meta(position = game.at(x, y))
      meta.iniciar()
    }
  }

//-------(Personajes)-------

  //Personaje Principal
  object m{
    var mainCharacterPosition = null

    method mainCharacterPosition() = mainCharacterPosition

    method decode(x,y){
      //Guardo la posicion del personaje principal
      mainCharacterPosition = game.at(x, y)

      //Creo suelo donde Spawnea el personaje principal
      _.decode(x, y)
    }
  }

  //Compis
  object z{
    const property stickyBlockPositions = []

    method decode(x,y){
      //Guardo la posicion de los stickyBlocks
      stickyBlockPositions.add(game.at(x, y))

      //Creo suelo donde Spawnea el personaje principal
      _.decode(x, y)
    }
  }

//*==========================| Niveles Instanciados |==========================

  const nivel1 = new Nivel(
    initialGridMap = [
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,p,_,z,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,m,_,_,p,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,l,_,_,_,_,_,_,_,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,z,_,_,_,g,_,p,v,v,v,v,v],
      [v,v,v,v,p,_,_,_,_,_,_,_,_,_,p,v,v,v,v,v],
      [v,v,v,v,p,p,p,p,p,p,p,p,p,p,p,v,v,v,v,v],
      [v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v,v]
    ]
  )