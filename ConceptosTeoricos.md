# Conceptos Teóricos aplicados en el TP

## ***Polimorfismo***
>Capacidad de los objetos de diferentes clases de responder de manera distinta a un mismo mensaje. Esto permite que un mismo código interactúe con diferentes tipos de objetos de una manera uniforme y flexible.

En este trabajo práctico, aplicamos en varias ocasiones el concepto de *polimorfismo*:

### ¿Cómo se renderizan nuestros niveles?

Una aplicacion clara de este concepto se observa en los objetos **"decoders"** *(v, p, _, m, z, g, l, x, o)*, que se encargan de generar los elementos dentro de cada nivel según su posición en el `Gridmap`. Cada uno de estos objetos implementa el método `decode()`, pero realiza una tarea diferente al ejecutarlo, permitiendo que cada objeto decodificador interprete su función específica de forma autónoma.

### UnDo() y la posibilidad de retroceder acciones In Game

Otro caso de aplicación de polimorfismo en el juego es el mensaje `undo()`, que es entendido por todos los **"Movimientos"** *(arriba, abajo, izquierda, derecha, StickyCompi, Agujero)*. Cada uno de estos movimientos ejecuta su propia lógica al deshacer la acción, adaptándose a su comportamiento específico.

### Colisiones: ante un problema recurrente, una solución efectiva

Para resolver el problema de las colisiones, aparece el método `interactuarConPersonaje()` . Este método es utilizado con frecuencia para que los distintos objetos identifiquen cómo comportarse en caso de que colisionen con el personaje principal. Por ejemplo: las **hitboxes** de los StickyCompis permiten acoplarse al personaje principal, la **meta** valida si el jugador ganó el nivel al colisionar con ella, entre otros casos.

## ***Herencia***

> Mecanismo que permite a una clase adquirir las propiedades y métodos de otra clase, estableciendo una relación jerárquica entre ellas. Esto facilita la reutilización de código, evitando que se repita la lógica, permitiendo crear estructuras de clases más organizadas y extensibles.

### Nuestros personajes

La *herencia* se aplica directamente en el diseño de `PersonajeInicial` y los `StickyCompis`, los cuales heredan las propiedades de los `stickyBlocks`. Esta herencia les permite moverse, colisionar, aparecer, desaparecer e interactuar con otros objetos, a la vez que conservan sus propias funcionalidades específicas, como la inicialización, creación y características únicas de sus hitboxes.

### ¿Cómo validamos que un nivel haya sido completado exitosamente?

La *herencia* aquí se observa en la implementación de `MetaValidadora`, que extiende las funcionalidades básicas de `Meta` para encargarse de validar la condición de victoria al colisionar con un elemento del cuerpo y permitir el avance al siguiente nivel. Se optó por hacer que solo una de las metas sea la validadora, evitando así que múltiples instancias ejecuten la misma lógica, lo que optimiza los tiempos de carga de nivel.

## ***Clase Abstracta***

### Teclado
Se implementaron varios objetos que representan distintas instancias del teclado, permitiendo intercambiar entre modo `juego`, `menú` y `selector de nivel` mediante métodos que modifican la referencia de la variable `teclado`. Estos objetos heredan de un `tecladoBase` que tiene métodos vacíos y actúa a modo de **clase abstracta**.

# Diagrama de clases 

![alt text](ImageReadme/StickyBlockClassDiagram.svg)