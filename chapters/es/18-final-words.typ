= Palabras Finales

Mi hijo mayor tiene cinco años. Todavía no sabe leer, no realmente — deletrea palabras en cajas de cereales y carteles de la calle, orgulloso de cada sílaba. Pero sabe lo que hace mi ordenador. Me ha visto hablarle, ha visto texto aparecer en la pantalla en respuesta, me ha visto asentir o negar con la cabeza y hablar de nuevo. Una noche se subió a mi regazo, vio a un agente refactorizar un módulo en tiempo real — archivos abriéndose y cerrándose, tests ejecutándose, marcas verdes apareciendo — y dijo: "¿El ordenador se está arreglando solo?"

No tuve una buena respuesta. Todavía no la tengo del todo. Pero esa pregunta me acompañó a lo largo de cada capítulo de este libro. Porque lo que me di cuenta, sentado ahí con él, es que no estaba escribiendo un libro sobre herramientas. Estaba escribiendo un libro sobre lo que significa ser ingeniero en el momento exacto en que la definición de ingeniería se está reescribiendo — y sobre lo que llevamos adelante hacia lo que venga después.

Este capítulo no es un resumen. No necesitas que te recapitule quince capítulos que acabas de leer. Esto es lo que quiero decirte directamente, de ingeniero a ingeniero, antes de que nos separemos.

== Lo Que Creo

Creo que el oficio no está muriendo. Está siendo _comprimido_. Una década de boilerplate y fontanería y ceremonia se está colapsando en intención y criterio. Lo que queda cuando quitas el teclear es lo que siempre fue realmente el trabajo: saber qué construir y saber cuándo está bien.

Creo que los agentes son amplificadores, no reemplazos. Dale un agente a un ingeniero mediocre y obtienes software mediocre a velocidad aterradora. Dale uno a un gran ingeniero y obtienes algo que, francamente, hace que los últimos veinte años de desarrollo de software parezcan como si estuviéramos construyendo autopistas con palas.

Creo que los ingenieros que prosperarán serán los que dominen las cosas _aburridas_ — contexto, barandillas, testing, convenciones, pensamiento claro — mientras todos los demás persiguen el anuncio brillante del nuevo modelo. Las herramientas cambian cada trimestre. El criterio se acumula a lo largo de una carrera.

Creo que no estamos siendo reemplazados. Estamos siendo promovidos. De mecanógrafos a capitanes. De programadores a _ingenieros_, en el sentido más completo de la palabra. La pregunta es si aceptas la promoción.

Creo que este cambio es _bueno_. No fácil. No indoloro. Pero bueno. Porque la parte de nuestro trabajo que se está automatizando nunca fue la parte que amábamos. Nadie se hizo ingeniero porque soñaba con escribir parsers de JSON boilerplate. Nos hicimos ingenieros porque queríamos construir cosas que importan. Ahora podemos.

== En Qué Me Equivoqué

Seré honesto contigo: cambié de opinión al menos tres veces mientras escribía este libro.

Cuando empecé el capítulo de sandboxes, pensaba que el aislamiento con contenedores era excesivo para la mayoría de los flujos de trabajo. Para cuando lo terminé, después de que un agente hiciera rm -rf en un directorio que me importaba un martes por la tarde, creía que el sandboxing era innegociable. Esa experiencia entró en el capítulo. La convicción detrás de ella es tejido cicatricial.

Originalmente escribí el capítulo multi-agente con la suposición de que orquestar cinco o seis agentes simultáneamente era el estado final natural — una planta de fábrica de trabajadores autónomos. He retrocedido de eso. El overhead de coordinación es real, los modos de fallo se multiplican, y he descubierto que dos o tres agentes bien dirigidos superan a seis sin supervisión casi siempre. El capítulo refleja dónde terminé, pero podría terminar en otro sitio en seis meses.

También fui, durante un tiempo, demasiado despectivo con los modelos locales. Escribí un borrador temprano que básicamente decía "simplemente usa las APIs comerciales." Luego pasé un fin de semana ejecutando un modelo local fine-tuned en un código base con restricciones propietarias y me di cuenta de que hay todo un mundo de casos de uso donde lo local no es solo viable sino _necesario_. El capítulo sobre modelos locales versus comerciales existe porque estaba equivocado y tuve que corregirme.

Partes de este libro probablemente ya estén equivocadas de formas que no puedo ver todavía. El panorama se mueve así de rápido. Pero las herramientas específicas nunca fueron el punto. Si te he ayudado a construir un modelo mental — una forma de pensar sobre autonomía, confianza y estructura — entonces el libro cumplió su función, incluso cuando cada ejemplo de código en él esté desactualizado.

== La Metáfora de la Tripulación, Una Última Vez

Crecí en Dinamarca, cerca del agua. Si has navegado en aguas escandinavas, conoces la luz de finales de verano — baja y dorada, el tipo de luz que hace que el mar parezca cobre martillado. Recuerdo una travesía una vez, un barco pequeño, cuatro de nosotros. El viento cambió fuerte y de repente todos estábamos moviéndonos sin hablar. Uno en el foque, uno en la escota mayor, uno ajustando, uno al timón. Sin órdenes. Solo confianza construida a lo largo de docenas de navegaciones previas.

Eso es lo que se siente la ingeniería agéntica en un buen día. Tú al timón, los agentes ajustando y afinando, el trabajo fluyendo porque has invertido las horas en construir contexto compartido — a través de convenciones, a través de barandillas, a través de suites de tests que detectan errores antes de que importen. No necesitas gritar instrucciones. El sistema _sabe_.

Y luego están los malos días. Los días en que el viento cae y un agente alucina una API que no existe, o reescribe un módulo que no le pediste que tocara, o pasa todos los tests porque borró los que estaban fallando. Esos días, estás achicando agua y maldiciendo. Eso también es navegar.

Pero debería ser honesto sobre algo, porque este libro no funciona si no lo soy.

La metáfora de una _tripulación_ implica lealtad. Continuidad. Compañeros de barco con los que has navegado antes, que conocen tus hábitos, que anticipan la siguiente orden. Es una imagen hermosa. Tampoco es cómo trabajo realmente.

La mayoría de los días, lo que realmente hago es levantar un agente, darle un trabajo, tomar la salida y tirarlo por la borda. Luego levanto otro. No recuerdan la última sesión. No saben lo que le pedí al agente anterior. Cada uno llega fresco, hace su trabajo y desaparece. Es menos una tripulación leal y más como contratar estibadores en cada puerto — les informas, los ves trabajar, les pagas y en el siguiente puerto lo haces de nuevo.

Y eso está bien. Así es como la mayoría de las tripulaciones reales funcionaron a lo largo de la historia marítima. El barco era la continuidad. El capitán era la continuidad. Las cartas, el cuaderno de bitácora, el aparejo — eso persistía entre viajes. La tripulación a menudo se reunía para una sola travesía y se disolvía en el destino. Lo que lo hacía funcionar no era que los marineros conocieran al capitán. Era que el capitán conocía el _barco_ — y tenía sistemas lo suficientemente buenos para que cualquier marinero competente pudiera subir a bordo y ser útil.

Eso es lo que es tu código base. Eso es lo que son tus convenciones, tus suites de tests, tus archivos CLAUDE.md, tus barandillas. Son el barco. Cada nuevo agente que levantas es un nuevo miembro de la tripulación subiendo a bordo de un navío bien aparejado. No necesitan conocer tu historia. Necesitan conocer el barco. Y si has construido el barco bien, serán productivos en minutos.

Así que sí — tíralos por la borda. Levanta nuevos. Eso no es un fallo de la metáfora. Es la metáfora funcionando exactamente como se pretendía. La tripulación es desechable. El barco no lo es.

Tú eres el capitán. Siempre fuiste el capitán. La tripulación acaba de llegar — y seguirán llegando, frescos y listos, cada vez que los necesites.

== Gracias

Gracias por leer este libro. Lo digo en serio. Intercambiaste tu tiempo y atención por mis palabras, y no me lo tomo a la ligera. Espero haberlo merecido.

Gracias a la comunidad — los ingenieros en foros, en servidores de Discord, en repositorios open source — que están compartiendo sus experimentos, sus fallos, sus ideas ganadas con esfuerzo. Este libro fue moldeado por cientos de conversaciones que no tuve solo.

Y gracias, supongo, a los propios agentes — que me ayudaron a escribir código, depurar problemas, y ocasionalmente generar prosa tan mala que me recordó por qué el criterio humano sigue importando. Sois una buena tripulación. Estáis mejorando. Y sospecho que para cuando mi hijo sea lo suficientemente mayor para leer este libro, seréis algo que ninguno de nosotros predijo del todo.

== Ve y Construye Algo

Esto es lo que quiero que hagas.

Esta noche — no mañana, no la semana que viene, _esta noche_ — abre tu terminal. Elige un bug que has estado evitando. Ese que sigues moviendo al fondo del backlog, el que es molesto pero no urgente, el que vive en una parte del código base que preferirías no tocar. Apunta un agente. Dale contexto. Establece una barandilla. Mira qué pasa.

Quizá arregla el bug en cuatro minutos y sientes el suelo moverse bajo tus pies, como se movió bajo los míos aquella noche con el script de migración. Quizá hace un desastre y aprendes algo sobre cómo dar mejores instrucciones. De cualquier forma, sabrás más que antes.

Luego ve a más. Configura aislamiento con worktrees y ejecuta dos agentes en paralelo. Escribe un archivo CLAUDE.md para un proyecto que te importa. Construye una suite de tests lo suficientemente buena como para ser tu red de seguridad cuando los agentes estén haciendo commits. Refactoriza ese módulo que todo el mundo teme — pero esta vez, con una tripulación.

Luego ve más grande todavía. Introduce flujos de trabajo agénticos en tu equipo. Comparte lo que has aprendido — las victorias _y_ los desastres. Escribe tus propias historias de guerra. Contribuye al conocimiento colectivo de una disciplina que todavía se está inventando.

Porque eso es lo que es esto: una disciplina que se está inventando, ahora mismo, por las personas dispuestas a hacer el trabajo. No por las personas escribiendo posts de blog sobre el futuro. No por las personas esperando la herramienta perfecta. Por las personas que abren un terminal hoy y construyen algo real con lo que tienen.

Los ingenieros que definirán esta era no están esperando permiso. No están esperando certeza. Están entregando, rompiendo cosas, aprendiendo y volviendo a entregar — con una tripulación a su lado que mejora un poco cada día.

Espero que tú seas uno de ellos.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Marzo 2026_
]
