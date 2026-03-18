= Introducció

Fa sis mesos vaig decidir posar-me seriós amb els agents d'IA. No només provar -- realment descobrir com fer-los part del meu treball diari com a enginyer. Em vaig asseure, vaig buidar l'agenda i vaig començar a experimentar amb les tècniques que acabarien convertint-se en aquest llibre. Com guiar un agent. Com posar límits. Com pensar en termes d'intenció en lloc de sintaxi.

Vaig aprendre a base de prova i error. Molt error. Vaig cremar tokens en tasques que haurien d'haver estat simples. Vaig veure com agents reescrivien mòduls sencers que no els havia demanat que toquessin. Vaig fusionar codi que passava tots els tests i es trencava en producció perquè havia confiat en la marca verda en lloc del meu propi judici. Cada error em va ensenyar alguna cosa, i a poc a poc -- en setmanes, després mesos -- els principis van començar a cristal·litzar.

El que més em va sorprendre va ser com va canviar la meva pròpia productivitat. Tasques que abans em prenien un dia sencer -- construir un pipeline de dades, connectar un nou servei, refactoritzar un mòdul legacy -- van començar a portar-me menys d'una hora. No perquè els agents fessin tota la feina de pensar, sinó perquè havia après a _dirigir_ el pensament. Arquitectura neta. Tests exhaustius. PRs que passaven la revisió al primer intent. No era màgia -- només una manera diferent de treballar que ningú m'havia ensenyat, perquè ningú l'havia desxifrat encara.

Aquest llibre va néixer d'aquest procés. Està construït sobre principis que vaig desenvolupar i provar en projectes reals -- com estructurar el pensament, com comunicar la intenció a un agent, com verificar la sortida i com saber quan cal reprendre el control. De cap manera estic segur que siguin els millors enfocaments -- el camp es mou massa ràpid perquè ningú pugui afirmar certeses. Però he vist una millora genuïna i mesurable en el meu propi treball, i crec que aquestes idees poden fer el mateix per a tu. Les tècniques no són complicades. Simplement no són evidents -- i ningú més les ensenya encara.

== El Terra s'Esta Movent

Durant vint anys, ser enginyer de software significava una cosa: obres un editor, escrius codi, el desplegues. Les eines canviaven -- de Vim a VS Code, d'SVN a Git, de bare metal a Kubernetes -- pero el bucle fonamental seguia igual. Tu, un teclat i un problema.

Aquell bucle s'esta trencant. I s'esta trencant rapid.

Els agents d'IA no nomes autocompletam el teu codi. Llegeixen tota la teva base de codi, raonen sobre l'arquitectura, fan canvis a desenes de fitxers, executen els teus tests i iteren sobre els errors -- tot sense que toquis el teclat. No estan substituint l'editor. Estan substituint el _flux de treball_. L'enginyer que solia passar el 80% del temps teclejant ara passa el 80% del temps pensant, revisant i dirigint.

Alguns enginyers estan prosperant en aquest canvi. Estan lliurant mes, amb mes qualitat, i et diran que estan gaudint mes de la seva feina que en anys. Altres estan frustrats, esceptics, o discretament aterroritzats que l'ofici que van passar una decada dominant s'estigui evaporant sota els seus peus.

Les dues reaccions son racionals. La veritat es en algun lloc al mig incomode.

== Per Que Aquest Llibre

Perque ningu ens va donar un manual.

Les eines van arribar rapid -- Copilot, despres Claude, despres agents que poden executar tasques de manera autonoma d'extrem a extrem -- i tots ho estem descobrint en temps real. Vaig buscar el llibre que m'expliques com treballar realment amb aquestes coses. No el discurs de marketing. No l'article academic. No el fil de Twitter d'algu que ho va provar durant vint minuts. Volia la guia d'enginyeria honesta -- escrita per algu que desplega codi a produccio i ha vist agents fer coses brillants i coses catastroficament estupides a parts iguals.

Aquell llibre no existia. Aixi que el vaig escriure.

El vaig escriure perque jo tambe estava perdut. Jo era l'enginyer senior que no podia entendre per que l'agent seguia reescrivint tota la meva biblioteca de components quan li demanava que arregles un color d'un boto. Jo era el tipus que va cremar 500.000 tokens en una tasca que hauria d'haver trigat deu minuts, perque no sabia com posar limits. Vaig cometre cada error d'aquest llibre abans d'aprendre a evitar-los.

Aquesta es la guia que m'hauria agradat que algu m'hagues donat.

== Per a Qui Es Aixo

Ets enginyer de software. Has desplegat coses reals. Saps el que es sent un incident de produccio a les 2 de la matinada. No tens por del terminal.

Pero ultimament, alguna cosa es diferent. Potser has provat eines de codi amb IA i les has trobat impressionants pero caotiques -- com fer parella amb algu que es increiblement rapid pero no te cap concepte d'abast. Com ser en Tom Cruise a _Rain Man_, excepte que el teu Dustin Hoffman pot refactoritzar tota una base de codi en lloc de comptar cartes. Potser has vist quelcom amb una fraccio de la teva experiencia lliurar de cop com un veterà de deu anys, i t'ha fet sentir alguna cosa que no esperaves. Potser estas emocionat pero no saps per on comencar. Potser ets esceptic i vols que algu et convenci amb substancia, no amb hype.

Aquest llibre es per a tu. Assumeix que saps programar. Assumeix que portes temps en aixo. Et troba alla on ets.

== Com Llegir Aquest Llibre

Aixo no es un manual de referencia. Es un viatge, i esta estructurat com un.

Comencem entenent que esta canviant realment i per que -- el canvi en com es construeix el software, no nomes les eines sino el _pensament_. Despres entrem en que son realment els agents, despullats del llenguatge de marketing, perque tinguis un model mental que aguanti quan les eines canviin el proxim trimestre.

A partir d'aqui, ens embrutem les mans. Aprendras com funcionen els agents al terminal, com configurar baranes perque no destrossin la teva base de codi, com canvien els fluxos de treball amb Git quan els agents fan commits, i per que el sandboxing no es opcional. Aprofundirem en els tests com a bucle de retroalimentacio que fa els agents _fiables_ en lloc de simplement rapids, i les convencions com l'arma secreta que la majoria de gent passa per alt.

Despres anem mes a fons -- models locals versus comercials, prompt engineering com a disciplina real, i orquestracio multi-agent. Veurem histories de guerra: fracassos reals, llicons reals, teixit cicatricial real. Parlarem de quan _no_ utilitzar agents, perque saber quan deixar l'eina es tan important com saber com fer-la servir. I tancarem amb com els equips adopten aixo sense implosionar.

Al final, no nomes sabras com utilitzar agents d'IA. Sabras com _pensar_ sobre ells -- que es l'habilitat que sobreviu quan la generacio actual d'eines queda obsoleta.

== Que No Es Aquest Llibre

Deixa'm estalviar-te temps.

Aixo no es un receptari de prompts. No trobaras "50 prompts de ChatGPT per a desenvolupadors" aqui. Els prompts importen, i en parlem, pero copiar i enganxar prompts sense entendre el sistema de sota es una recepta per a una frustracio cara.

Aixo no es un manifest de hype de la IA. No soc aqui per dir-te que els agents substituiran tots els programadors dimarts vinent. No ho faran. La distancia entre demo i produccio es tan ampla com sempre, i algu encara ha de vigilar aquesta distancia.

Aixo tampoc es una narrativa apocaliptica. El marc de "la IA ve a buscar la teva feina" es mandrosa i majoritariament incorrecte. El que ve es un canvi fonamental en _com_ funciona la feina, i aixo es una conversa completament diferent.

Aixo es un llibre d'enginyeria. Per a enginyers. Escrit per algu que es passa els dies escrivint codi amb agents i te l'historial de git per demostrar-ho. Serem practics, honestos i especifics. Si aixo et sona be, passa la pagina.
