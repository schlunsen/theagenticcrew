= Què és un agent, realment?

#figure(
  image("../../assets/illustrations/crew/ch04-agent-loop.jpg", width: 80%),
  caption: [_Observar, planificar, actuar, comprovar — repetir._],
)

Fa anys que fas servir agents. Simplement no ho sabies.

Quan la teva app de correu mou un butlletí a la pestanya de Promocions, això és un agent — un de petit, amb una feina molt concreta. Quan el teu telèfon et suggereix "normalment surts cap a la feina a les 8:15, hi ha molt de trànsit, surt ara" — això és un agent. Quan Spotify et crea una llista de reproducció basada en el que has estat escoltant — agent.

Aquests són agents petits. D'una sola tasca. Limitats. Observen alguna cosa (el teu correu, la teva ubicació, el teu historial d'escolta), decideixen alguna cosa (això és una promoció, el trànsit és dolent, t'agradaria aquesta cançó) i actuen (mouen el correu, envien una notificació, posen la cançó a la cua).

Els agents dels quals tracta aquest llibre són la mateixa idea, però molt, molt més grans. No només classifiquen el teu correu — poden llegir tot el teu codi, planificar una sèrie de canvis, escriure el codi, executar els tests i iterar sobre els errors. No fan una cosa enginyosa. Fan _moltes_ coses, en seqüència, adaptant-se a mesura que avancen.

== El bucle

Cada agent, des del filtre de correu més senzill fins a l'eina d'escriptura de codi més sofisticada, executa el mateix bucle bàsic:

+ *Observar.* Recopilar informació. Llegir els fitxers. Veure el missatge d'error. Mirar l'estat actual de les coses.
+ *Planificar.* Decidir què fer. "El test falla perquè aquesta funció retorna el valor incorrecte. He de canviar la línia 47."
+ *Actuar.* Fer l'acció. Escriure el codi. Moure el fitxer. Enviar el missatge.
+ *Comprovar.* Ha funcionat? Executar el test. Llegir la sortida. Veure si l'error ha desaparegut.
+ *Repetir.* Si ha funcionat, passar a la tasca següent. Si no, tornar al pas 1 amb nova informació.

Això és tot. Observar, planificar, actuar, comprovar, repetir. El bucle és el mateix tant si l'agent està ordenant la teva bústia d'entrada com si està construint una aplicació web. El que canvia és l'_abast_ — quant pot veure l'agent, quantes eines té i quanta autonomia li has donat.

Un agent simple executa aquest bucle una vegada. Un agent potent l'executa dotzenes de vegades, ajustant el seu enfocament cada cop, construint sobre el que ha après dels intents anteriors.

== Les eines defineixen la capacitat

Un agent sense eines és simplement un chatbot. Pot _pensar_ i _respondre_, però no pot _fer_ res. Les eines que dones a un agent defineixen de què és capaç.

Un agent amb accés al teu sistema de fitxers pot llegir i escriure codi. Un agent amb un navegador web pot investigar documentació. Un agent amb un terminal pot executar comandes, llançar tests i engegar servidors. Un agent amb accés al teu repositori Git pot crear branches, fer commits i obrir pull requests.

Pensa-hi com un empleat nou. Una persona intel·ligent sense accés a cap sistema és simplement algú assegut davant un escriptori buit. Dóna-li accés a l'eina de gestió de projectes i pot fer seguiment de la feina. Dóna-li accés al repositori de codi i pot fer canvis. Dóna-li credencials de desplegament i pot posar coses en producció.

Les eines són l'accés. L'agent és la persona. Tu decideixes quin accés concedir en funció del que confies que pugui fer — que és exactament del que tracta el capítol del Gradient de Confiança.

== Què no és un agent

Un agent no és una persona. No té objectius, desitjos ni sentiments. No està "intentant" ajudar-te en cap sentit significatiu. Està executant un procés de reconeixement de patrons molt sofisticat — predient la següent acció útil més probable donada tota la informació que pot veure.

Aquesta distinció importa perquè canvia com hi treballes. No motives un agent. No necessites ser amable (tot i que no fa mal). El que necessites ser és _clar_. Un agent respon a la claredat de la mateixa manera que una persona respon a la motivació. Com millor descriguis el que vols, millor serà el resultat. Sempre.

Un agent tampoc és infal·lible. Produirà respostes incorrectes amb total confiança. Al·lucinarà biblioteques que no existeixen. Resoldrà el problema equivocat amb una precisió preciosa. Treballarà incansablement en la direcció equivocada tret que li corregeixis el rumb.

Aquesta és la teva feina. No escriure el codi — _dirigir_.

== L'espectre

No tots els agents són iguals. Hi ha un espectre des del simple fins al sofisticat:

*Autocompletar* — La forma més simple. Comences a escriure i l'eina prediu què ve a continuació. GitHub Copilot ho fa per al codi. El teclat del teu telèfon ho fa per al text. Poca autonomia, poc risc, constantment supervisat.

*Assistents de xat* — Fas una pregunta, obtens una resposta. ChatGPT, Claude, Gemini. Més capaços, però encara reactius — fan el que demanes, un intercanvi a la vegada. Sense eines, sense memòria entre sessions (normalment), sense capacitat d'actuar sobre el món.

*Agents equipats amb eines* — La mateixa intel·ligència, però amb mans. Poden llegir fitxers, executar comandes, cercar a la web, interactuar amb APIs. Aquí és on les coses es tornen potents — i on viu la resta d'aquest llibre. Claude Code, Cursor, Windsurf — aquests són agents amb accés al teu projecte, al teu terminal, a les teves eines.

*Agents autònoms* — Agents que funcionen sense supervisió durant períodes llargs. Els dones un objectiu, ells descobreixen els passos, els executen, gestionen els errors i tornen amb resultats. Els més potents i els més perillosos. La majoria de les mesures de seguretat d'aquest llibre existeixen per aquesta categoria.

On et situïs en aquest espectre depèn del teu nivell de comoditat, del teu cas d'ús i de quant confies en el resultat. La majoria de gent que llegeix aquest llibre treballarà principalment amb agents equipats amb eines — prou potents per construir coses reals, prou supervisats per detectar errors.

== Per què això t'importa

No necessites entendre com funciona internament el model de llenguatge. No necessites saber sobre transformers, caps d'atenció o predicció de tokens. Això és el motor. Tu necessites saber conduir.

El que _sí_ necessites entendre:

- Els agents treballen en un bucle: observar, planificar, actuar, comprovar.
- Les eines defineixen el que poden fer. Més eines vol dir més capacitat, però també més risc.
- S'equivoquen amb confiança tan sovint com encerten amb confiança. La verificació no és opcional.
- La claredat és el teu superpoder. Com millor comuniquis, millor serà el resultat.

Si alguna vegada has dirigit persones, ja tens l'habilitat bàsica. Estàs a punt d'aprendre com aplicar-la a un membre de l'equip molt ràpid, molt literal i molt incansable que mai necessita cafè però que tampoc mai fa preguntes per aclarir dubtes.
