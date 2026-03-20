= Quan No Utilitzar Agents

Aquest llibre tracta sobre utilitzar agents be. Aquest capitol tracta sobre saber quan no utilitzar-los en absolut.

Si has llegit fins aqui, probablement estas convençut de l'enginyeria agentica. Be. Pero la manera mes rapida de perdre credibilitat -- i perdre temps -- es buscar un agent quan la feina demana un huma. Els millors enginyers agentics no son els que utilitzen agents mes. Son els que saben _exactament_ quan deixar l'agent i fer la feina ells mateixos.

== L'Impost del Sobrecost

Cada interaccio amb un agent te un cost. Escrius el prompt. Esperes la sortida. Revises el que ha produit. Arregles els errors. Tornes a executar si no ha captat la idea. Aixo es sobrecost, i es real.

Per a tasques complexes que et costarien una hora, dedicar dos minuts a prompt i revisio es una ganga. Pero per a tasques que pots fer en trenta segons? El sobrecost fa els agents _mes lents_, no mes rapids.

Renomenar una variable. Arreglar un error tipografic. Ajustar un valor de configuracio. Afegir una linia de log. Aquestes son tasques de memoria muscular. Els teus dits coneixen les pulsacions de tecles. Quan hagis acabat de teclejar un prompt descrivint el que vols, ja ho podries haver fet.

Aixo no es una fallada dels agents. Son matematiques. Les tasques petites tenen retorns petits, i el cost fix de la interaccio amb agents es menja el marge. No deixis que la novetat dels agents et faci caure en la trampa d'utilitzar-los per a tot. Alguna feina es simplement mes rapida a ma.

== Decisions d'Arquitectura Novel·les

Quan estas dissenyant un sistema des de zero -- triant entre un monolit i microserveis, decidint el teu model de dades, triant els teus patrons de comunicacio -- el _pensament es la feina_. El valor no es al diagrama o al document. El valor es al model mental que construeixes mentre lluites amb els compromisos.

Un agent pot ajudar-te a explorar opcions. Pot llistar els pros i contres de l'event sourcing versus CRUD. Pot esbossar com podria ser una arquitectura particular. Aixo es util com a input.

Pero delegar l'arquitectura mateixa a un agent vol dir que no entens el teu propi sistema. Tindras dificultats per depurar-lo, ampliar-lo, o explicar-lo al teu equip. La feina de l'enginyer senior es prendre les decisions dificils -- pesar els compromisos que no tenen respostes netes, decidir quina complexitat val la pena carregar i quina no. Aquell judici ve de fer la feina, no de llegir el resum d'un agent.

Utilitza agents com a sparring partner per a l'arquitectura. No com a arquitecte.

== Codi Critic de Seguretat

Fluxos d'autenticacio. Xifratge. Control d'acces. Validacio d'entrada. Gestio de tokens. Aquestes son arees on "sembla correcte" no es prou bo.

Els bugs de seguretat son diferents dels bugs normals. Una funcio d'ordenacio trencada produeix sortida incorrecta que algu nota. Una comprovacio d'autenticacio trencada no produeix _cap simptoma visible_ fins que un atacant la troba. El codi es veu be. Els tests passen. I sis mesos despres estas escrivint un informe d'incident.

Els agents produeixen codi plausible. Aquesta es la seva fortalesa i, en contextos de seguretat, el seu perill. Un defecte subtil en un flux de validacio de JWT, una comprovacio absent en una URL de redireccio, un canal lateral de temps en una comparacio de contrasenyes -- aquests son el tipus d'errors que sobreviuen la revisio de codi perque _semblen correctes_.

Escriu el codi critic de seguretat tu. Revisa'l curosament. Aconsegueix un segon parell d'ulls humans. Si utilitzes un agent per esbossar codi de seguretat, tracta aquell esborrany amb mes sospita de la que donaries al primer intent d'un desenvolupador junior, no menys.

== Quan Necessites Aprendre

Estas aprenent un nou llenguatge. Un nou framework. Un nou paradigma. La temptacio es obvia: deixa que l'agent escrigui el codi mentre tu et centres en la imatge general.

Resisteix-la.

Si deixes que l'agent escrigui tot el Rust mentre estas aprenent Rust, no has apres Rust. Has construit alguna cosa que no pots mantenir, depurar, ni ampliar sense l'agent. Has creat una dependencia, no una habilitat.

Hi ha una diferencia crucial entre utilitzar un agent per _explicar_ alguna cosa i utilitzar-lo per _fer_ alguna cosa. Preguntar "per que es produeix aquest error del borrow checker?" construeix comprensio. Preguntar "arregla aquest error del borrow checker" no.

Quan l'objectiu es aprendre, frena. Escriu el codi tu. Comet els errors tu. Utilitza agents com a tutors, no com a escriptors fantasma. La comprensio que construeixes lluitant a traves de les parts dificils es tota la qüestio.

== Decisions Emocionalment Carregades

No totes les decisions d'enginyeria son tecniques. Algunes de les mes dificils son humanes.

Deprecar una API de la qual un soci depen. Dir a un stakeholder que la seva peticio de funcionalitat no entrara. Resistir un termini que saps que no es realista. Decidir retirar un producte que encara te usuaris.

Aquestes decisions requereixen empatia. Requereixen llegir l'ambient, entendre la politica, pesar el cost huma al costat del cost tecnic. Requereixen _responsabilitat_ -- algu que sigui propietari de la decisio i les seves consequencies.

Un agent pot redactar el correu. Pot ajudar-te a pensar en els punts de conversa. Pero la decisio mateixa, i la conversa que la lliura, han de venir d'un huma. La gent mereix rebre males noticies d'una persona, no d'algu que ha copiat i enganxat la sortida d'un agent.

== Quan la Base de Codi Es Massa Desordenada

Els agents amplifiquen el que ja hi ha. En una base de codi neta i ben estructurada amb convencions fortes, els agents produeixen codi net i ben estructurat. Recullen els patrons i els segueixen.

En un desastre? Produeixen mes desastre.

Si la teva base de codi te nomenclatura inconsistent, dependencies enredades, cap frontera de moduls clara, i tres maneres diferents de fer el mateix -- un agent recollira _tots_ aquells patrons. Podria combinar les pitjors parts de cadascun. No sap quins patrons son intencionals i quins son deute tecnic. Simplement veu el que hi ha i produeix mes del mateix.

De vegades el moviment correcte es netejar abans de portar agents. Refactoritza el modul. Estableix la convencio. Esborra el codi mort. Fes de la base de codi un lloc on un agent pugui fer bona feina. Aixo es feina poc glamurosa i manual. Pero es la base que fa possible tota la resta.

Pensa-ho com un taller. No dones eines electriques a algu en un taller desordenat i desorganitzat. Primer neteges, _despres_ portes les eines.

== Treballar amb Codi Legacy

Aquella metafora del taller es maca. Pero no tothom te el luxe de netejar primer. Alguns de nosaltres mantenim monolits Java de 500.000 linies que es van iniciar el 2014 i han passat per tres migracions de framework, dues adquisicions, i un breu periode on algu va pensar que la configuracio XML era una bona idea. El consell de "refactoritza abans de portar agents" es solid en teoria i risible a la practica quan estas mirant una base de codi que trigaria anys a refactoritzar.

Aixi que _com_ fas servir agents en codi legacy? Amb cura. I amb una estrategia especifica.

*Comenca pels tests.* Abans d'apuntar un agent a codi legacy, escriu tests de caracteritzacio -- tests que capturen el que el codi _fa actualment_, no el que _hauria_ de fer. No son aspiracionals. Son descriptius. Diuen "quan crides aquesta funcio amb aquestes entrades, aixo es el que surt, i aquest es el contracte actual tant si algu ho pretenia com si no."

Els tests de caracteritzacio donen a l'agent una xarxa de seguretat. Sense ells, l'agent canviara comportament que no enten, i no ho sabras fins que produccio t'ho digui. Amb ells, qualsevol canvi de comportament apareix com una fallada de test _abans_ que el codi surti de la teva maquina. Aixo es no negociable. Codi legacy sense tests es codi legacy que no pots deixar que els agents toquin amb seguretat.

*Acota despiadadament.* En una base de codi legacy, l'agent no pot entendre tot el sistema. No intentis que ho faci. Apunta'l a un fitxer, una funcio, un bug. Dona-li el context immediat -- la signatura de la funcio, els cridadors, el comportament esperat -- i res mes. El codi legacy esta ple de suposicions implicites, efectes secundaris no documentats, i peculiaritats que aguanten pes. Com menys vegi l'agent, menys pot malinterpretar. Un abast estret amb context clar guanya a un abast ampli amb complexitat arqueologica.

*Utilitza agents per a les parts tedioses.* Les bases de codi legacy estan plenes de feina mecanica: actualitzar crides d'API deprecades a centenars de fitxers, migrar d'una versio de dependencia a una altra, afegir anotacions de tipus a codi sense tipar, estandarditzar patrons de gestio d'errors, substituir un framework de logging per un altre. Aquestes son tasques _perfectes_ per a agents -- repetitives, ben definides, facilment verificables per comprovacions automatiques. Deixa que els agents facin la feina dura. Guarda la teva energia per a les parts que requereixen entendre _per que_ el codi es com es. Aquesta es la feina que nomes un huma que ha viscut amb el sistema pot fer.

*Documenta a mesura que avances.* Cada vegada que un agent treballa en un fitxer legacy amb exit, afegeix un breu comentari explicant que fa el codi, o actualitza el `CLAUDE.md` del projecte amb context sobre aquell modul. Amb el temps, passa alguna cosa interessant: les parts de la base de codi legacy que els agents han tocat es tornen millor documentades que les parts que no. No perque t'hagis proposat documentar el sistema, sino perque fer servir agents _et va forcar_ a articular que fa cada peca per poder fer prompts efectivament. Els agents estan fent lentament la base de codi mes llegible -- no refactoritzant-la, sino fent-te explicar-la.

== L'Argument de l'Ofici

Hi ha una rao mes per de vegades deixar l'agent, i no es sobre eficiencia o risc. Es sobre l'ofici.

Escriure codi a ma construeix alguna cosa que els agents no et poden donar. Memoria muscular. Reconeixement de patrons que viu als teus dits, no nomes al teu cap. La comprensio profunda i intuitiva que ve d'haver escrit el mateix tipus de funcio dotzenes de vegades. La satisfaccio silenciosa de resoldre un problema dificil a traves del teu propi raonament.

Aquestes coses importen. No perque siguin romantiques, sino perque et fan un millor enginyer. El desenvolupador que ha escrit un parser a ma enten el parsing de manera diferent que un que nomes ha demanat a un agent que en faci un. El desenvolupador que ha depurat un problema de concurrencia a les 2 de la matinada _sent_ el perill de l'estat mutable compartit d'una manera que llegir-ne no proporciona.

Els agents son eines. Potents. Pero si els deixes fer tota la feina, les teves propies habilitats s'atrofien. I quan topis amb un problema que l'agent no pot resoldre -- i ho faras -- necessites que aquelles habilitats segueixin afilades.

Segueix practicant. Escriu codi a ma regularment. No perque sigui mes rapid, sino perque et mante perillos.

== El Judici Que Importa

L'habilitat central de l'enginyeria agentica no es el prompting. No es la configuracio d'eines. No es saber quin model utilitzar per a quina tasca.

Es el _judici_.

Saber quan un agent t'estalviara una hora i quan en malbaratara una. Saber quan confiar en la sortida i quan reescriure-la des de zero. Saber quan delegar i quan endinsar-s'hi tu.

Els millors enginyers agentics utilitzen agents agressivament -- pero selectivament. Busquen agents quan el palanquejament es real: refactoritzacions a gran escala, generacio de boilerplate, exploracio de codi, escriptura de tests, documentacio. I deixen l'agent quan la feina requereix pensament huma, responsabilitat humana, o ofici huma.

Aquell judici es el que separa els enginyers agentics dels simples operadors de prompts. Qualsevol pot teclejar un prompt. Saber _quan no fer-ho_ es l'habilitat mes dificil.
