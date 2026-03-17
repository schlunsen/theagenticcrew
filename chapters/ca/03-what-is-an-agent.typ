= Que Es un Agent?

La paraula "agent" es fa servir molt. S'aplica a tot, des d'un chatbot que respon preguntes fins a un sistema que desplega codi a produccio de manera autonoma. Abans d'anar mes lluny, siguem precisos sobre que volem dir -- perque la distincio importa per a com treballes amb ells.

== L'Espectre

No totes les eines d'IA son agents. A un extrem, l'*autocompletat* suggereix els seguents tokens mentre escrius -- reactiu, una linia cada vegada, sense pensament involucrat. Un *copilot* veu mes context i genera blocs mes grans, pero segueix sent passiu: tu demanes, ell respon. El canvi passa amb els *agents que utilitzen eines*. Un agent no nomes genera text -- _actua_. Llegeix fitxers, escriu fitxers, executa comandes, inspecciona resultats, i crucialment, ho fa en un bucle: prova, observa, ajusta, torna a provar. A l'extrem oposat, els *agents autonoms* agafen un objectiu d'alt nivell, planifiquen el seu propi enfocament i lliuren un resultat amb minima interaccio humana.

La majoria de l'enginyeria agentica practica avui passa a la zona d'us d'eines. Dones una tasca a l'agent, te acces a eines i treballa iterativament. Tu ets al bucle -- revisant, guiant, aprovant -- pero l'agent fa la feina pesada.

== Que Fa Alguna Cosa "Agentica"

Tres capacitats separen un agent d'un chatbot sofisticat:

*Planificacio.* Un agent descompon un objectiu en passos. "Afegeix autenticacio a aquesta app" es converteix en una serie d'accions -- llegir la base de codi, triar el framework, crear middleware, actualitzar rutes, afegir tests, verificar. Un chatbot et dona un bloc de codi. Un agent et dona un proces.

*Us d'eines.* Un agent interactua amb el mon -- llegeix els teus fitxers, executa els teus tests, examina la sortida d'errors. Cada crida a una eina proporciona nova informacio que dona forma a la seguent decisio. Aquest bucle de retroalimentacio es el que fa els agents potents: no estan generant codi al buit, estan generant codi i _verificant-lo_.

*Iteracio.* Un agent pot provar, fallar i tornar a provar. Escriure una funcio, executar els tests, veure un error, llegir l'error, ajustar, tornar a executar. Actuar, observar, ajustar. Un chatbot et dona un sol intent. Un agent et dona un cicle.

== Els Agents No Son Magia

Es important ser realista sobre que son els agents i que no son.

Els agents no son sentients. No entenen el teu codi com tu. No tenen intuicio, gust ni experiencia. El que tenen es la capacitat de processar grans quantitats de text, reconeixer patrons i generar seguents passos plausibles -- molt rapidament, molt incansablement, i a una escala que esgotaria qualsevol huma.

Al·lucinen. Cometen errors amb confianca. De vegades resolen el problema equivocat de manera brillant. Poden escriure codi que passa tots els tests pero no captura la intencio en absolut. Son becaris brillants amb energia infinita i zero judici.

Per aixo l'_enginyer_ importa. L'agent proporciona velocitat i amplada. Tu proporciones direccio, judici i gust. La combinacio es mes potent que qualsevol dels dos sols.

== Quan els Agents Fallen

Fallaran. Entendre _com_ fallen t'ajuda a construir millors fluxos de treball.

*Desviacio d'abast.* Demanes una correccio de bug, l'agent refactoritza tres fitxers i actualitza el sistema de build. Els agents son entusiastes, i aquell entusiasme s'esten mes enlla del que has demanat. Tasques petites i enfocades i aillament de branques son la teva defensa.

*APIs al·lucinades.* L'agent crida funcions o biblioteques que no existeixen -- o existeixen en una versio diferent. Executar tests ho detecta. L'agent no pot al·lucinar per superar una suite de tests.

*Excesiva confianca.* L'agent diu que ha acabat, i sembla que ha acabat, pero hi ha un bug subtil que nomes apareix sota condicions especifiques. Revisa els diffs. No confiis cegament en la sortida de l'agent.

*Perdua de context.* En tasques llargues, l'agent perd el fil de decisions anteriors -- es contradiu, reescriu codi que ja havia escrit, oblida restriccions. Commits petits i una gestio clara del context son la mitigacio.

Cada mode de fallada te una mitigacio, i aquestes mitigacions son els capitols d'aquest llibre: context, baranes, git, sandboxes, testing, convencions. Els principis no son teorics -- son respostes directes a com els agents fallen a la practica.

== El Model Mental Correcte

No pensis en els agents com a eines. No pensis en ells com a substituts. Pensa en ells com a col·laboradors amb un conjunt molt especific de fortaleses i debilitats.

Son rapids on tu ets lent. Son pacients on tu ets impacient. Poden mantenir mes text a la memoria de treball que tu. Mai es cansen, mai es frustren, mai tenen un mal dia.

Pero no saben que importa. No saben que necessita realment l'usuari. No saben quin deute tecnic es acceptable i quin es una bomba de rellotgeria. No saben quan cal qüestionar un requisit. No saben quan l'especificacio esta malament.

Aixo es feina teva. I sempre ho sera.
