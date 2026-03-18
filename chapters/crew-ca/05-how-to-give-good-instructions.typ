= Com donar bones instruccions

#figure(
  image("../../assets/illustrations/crew/ch05-two-captains.jpg", width: 80%),
  caption: [_La diferència entre una bona instrucció i una de dolenta._],
)

Aquest és el capítol més important d'aquest llibre.

Tota la resta — entendre la pila tecnològica, saber què són els agents, configurar mesures de seguretat — dóna suport a aquesta habilitat. Perquè un agent és tan bo com les instruccions que li dones. No de vegades. Sempre.

Si no t'emportes res més d'aquest llibre, emporta't això: _com expliques la feina és més important que l'eina que fa la feina._

== Dos capitans

Deixa'm explicar-te la història de dues persones que volien el mateix: un quadre de comandament senzill que mostrés els números de vendes setmanals del seu equip.

L'Àlex va obrir un agent i va escriure: "Fes-me un quadre de comandament de vendes."

L'agent va construir alguna cosa. Semblava un quadre de comandament. Tenia gràfics. Però les dades eren fictícies — números falsos, no connectats a res real. Els gràfics mostraven totals mensuals, no setmanals. No hi havia manera de filtrar per membre de l'equip. I feia servir una biblioteca de gràfics de JavaScript que l'Àlex no havia sentit mai, que no coincidia amb l'app de React que suposadament estaven construint.

L'Àlex va passar una hora intentant explicar què estava malament. Cada correcció introduïa un nou malentès. Després de dues hores, va llençar la tovallola i va començar de zero.

La Maia va obrir el mateix agent i va escriure una cosa diferent:

"Construeix una pàgina de quadre de comandament de vendes per a la nostra app de React. Ha de:
- Connectar-se al nostre endpoint de l'API Django existent a `/api/sales/`
- Mostrar un gràfic de barres dels totals de vendes de cadascuna de les últimes 8 setmanes
- Cada barra ha d'estar desglossada per membre de l'equip (gràfic de barres apilades)
- Fer servir la biblioteca Recharts, que ja tenim instal·lada
- Incloure un desplegable per filtrar per membre individual de l'equip, o mostrar tots
- La pàgina ha de coincidir amb l'estil existent de la nostra app — capçalera blava, targetes blanques, fons gris
- Posar-la a la ruta `/dashboard`"

L'agent va construir exactament això. Al primer intent. Trenta minuts incloent-hi una petita correcció al format de data.

Mateix agent. Mateixa tasca. Mateix objectiu. La diferència era totalment en les instruccions.

== Les tres parts d'una bona instrucció

Cada bona instrucció té tres components: *què* vols, *per què* importa i *com sabràs que ha funcionat*.

=== Què vols

Sigues específic. No "fes un quadre de comandament" sinó "fes un gràfic de barres que mostri els totals de vendes setmanals". No "arregla el disseny" sinó "la barra lateral se superposa al contingut principal en pantalles de menys de 768 píxels — fes que la barra lateral es plegui en un menú d'hamburguesa."

Com més concreta sigui la teva descripció, menys haurà de suposar l'agent. I quan els agents suposen, suposen amb confiança. No preguntaran "vols dir setmanal o mensual?" Simplement triaran un i ho construiran.

=== Per què importa

El context ho canvia tot. "Afegeix un indicador de càrrega" està bé. "Afegeix un indicador de càrrega — els nostres usuaris amb connexions rurals lentes veuen una pantalla en blanc durant 3-4 segons i pensen que l'app està trencada" és millor. Ara l'agent entén el _problema_, no només la funcionalitat. Podria suggerir solucions addicionals que no havies considerat, com skeleton screens o càrrega optimista.

=== Com sabràs que ha funcionat

Aquesta és la que la majoria de gent se salta. "Construeix una pàgina d'inici de sessió" no dóna a l'agent cap manera de verificar la seva pròpia feina. "Construeix una pàgina d'inici de sessió — hauria de poder introduir un correu electrònic i una contrasenya, clicar Iniciar sessió i ser redirigit al quadre de comandament. Si introdueixo una contrasenya incorrecta, hauria de veure un missatge d'error que digui 'Credencials no vàlides.' El botó d'inici de sessió hauria d'estar desactivat mentre la petició està en curs."

Ara l'agent té _criteris d'acceptació_. Pot comprovar la seva pròpia feina contra les teves expectatives. Aquest és el mateix concepte que fan servir els enginyers quan escriuen tests — definir com és l'èxit _abans_ de construir-ho.

== Les restriccions són la meitat de la feina

Dir a un agent què ha de fer és només la meitat de la feina. Dir-li què _no_ ha de fer és igual d'important.

Els agents són entusiastes. Optimitzen per resoldre el problema que has descrit, i redissenyaran tota la teva interfície amb molt de gust per fer-ho. Això no és malícia — és un optimitzador fent el que fan els optimitzadors. La teva feina és establir els límits.

Bones restriccions:

- "No canviïs cap pàgina existent — només afegeix la nova pàgina de quadre de comandament."
- "Fes servir l'esquema de colors existent. No introdueixis colors nous."
- "No afegeixis noves dependències. Fes servir les biblioteques que ja tenim."
- "Manté l'estructura de fitxers igual. Posa el nou component a `src/pages/`."
- "No modifiquis l'API. El quadre de comandament ha de funcionar amb les dades que l'API ja retorna."

Pensa en les restriccions com les línies de la carretera. L'agent pot conduir lliurement dins dels carrils, però no pot creuar les línies. Sense línies, obtens solucions creatives que tècnicament funcionen però creen caos. Amb elles, obtens solucions que encaixen naturalment amb el que ja existeix.

Com més experiència adquireixis, més les teves instruccions estaran definides per les restriccions. Aprens quines llibertats porten a bons resultats i quines porten a un agent reescrivint tota la teva biblioteca de components perquè li has demanat que arregli el color d'un botó.

== Els nivells d'instrucció

Hi ha un espectre des del vague fins al precís, i saber on situar-se és una habilitat que es desenvolupa amb el temps:

*Nivell 0 — El desig:* "Fes que l'app sigui millor." Això no dóna res a l'agent amb què treballar. O no farà res útil o ho canviarà tot.

*Nivell 1 — L'objectiu:* "Afegeix una manera perquè els usuaris exportin les seves dades." Millor — hi ha un objectiu clar. Però l'agent ha de decidir el format, la interfície, l'abast. Podries obtenir una exportació a CSV. Podries obtenir un endpoint d'API complet. Podries obtenir un botó de "Descarrega-ho tot" que exporta tota la base de dades.

*Nivell 2 — L'especificació:* "Afegeix un botó etiquetat 'Exportar a CSV' a la pàgina de configuració. Quan es cliqui, hauria de descarregar un fitxer CSV que contingui totes les tasques del projecte actual, amb columnes: Nom de la Tasca, Estat, Assignat, Data de Venciment, Data de Creació. El fitxer hauria de dir-se `nom-projecte-export-2026-03-18.csv`." Aquí és on vols estar per a la majoria de tasques. Prou específic perquè l'agent no pugui malinterpretar-ho, prou flexible perquè pugui gestionar els detalls d'implementació.

*Nivell 3 — El plànol:* Especificació completa d'implementació amb rutes de fitxers exactes, noms de funcions i patrons de codi a seguir. Normalment innecessari tret que treballis en un codi gran i complex amb convencions estrictes. El teu desenvolupador pot escriure prompts a aquest nivell. Tu probablement no ho necessitaràs.

Per a la majoria de gent que llegeix aquest llibre, el Nivell 2 és el punt ideal. Específic sobre el _què_ i el _resultat_, flexible sobre el _com_.

== Iterar és normal

Ningú escriu una instrucció perfecta al primer intent. Ni principiants. Ni experts. La diferència clau és que les persones amb experiència iteren _més ràpid_ perquè han après quins tipus de vaguetat causen quins tipus de problemes.

Un flux de treball saludable és així:

+ Dóna a l'agent una instrucció clara.
+ Revisa el que ha produït.
+ Identifica què està malament o què falta.
+ Dóna una instrucció de seguiment _enfocada_.
+ Repeteix fins que estigui bé.

El seguiment és on la majoria de gent té dificultats. Veuen alguna cosa malament i diuen "això no està bé, arregla-ho." Això és el capità Àlex de nou. En canvi:

- "El gràfic de barres mostra totals mensuals. Canvia-ho a setmanal — agrupa per número de setmana ISO."
- "A l'exportació li falta la columna d'Assignat. Afegeix-la entre Estat i Data de Venciment."
- "L'indicador de càrrega és massa petit. Fes-lo de 48 píxels i centra'l verticalment a la targeta."

Cada seguiment és una instrucció en miniatura amb la mateixa estructura: què està malament, què vols en canvi, com verificar-ho.

== Practica

Això és una habilitat, cosa que vol dir que millora amb la pràctica. Comença amb coses petites. Demana a un agent que redacti un correu electrònic i mira com d'específic has de ser sobre el to i el contingut. Demana-li que reorganitzi un full de càlcul i fixa't en com de precís has de descriure el disseny desitjat. Demana-li que planifiqui un viatge i observa on fa suposicions.

Cada vegada que l'agent produeix alguna cosa que no és el que volies, pregunta't: "Què podria haver dit diferent?" La resposta sempre és la mateixa — ser més específic sobre el que volies, més explícit sobre el que no volies, i més concret sobre com és l'èxit.

Les persones que treuen més profit dels agents no són les que tenen més coneixements tècnics. Són les que han après a comunicar-se amb precisió. I aquesta és una habilitat que es transfereix a cada conversa que tindràs mai — amb agents, amb col·legues i amb qualsevol persona que necessiti entendre què vols realment.
