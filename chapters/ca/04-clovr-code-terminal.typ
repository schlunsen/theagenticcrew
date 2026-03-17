= El Que Vaig Aprendre Construint les Meves Propies Eines Agentiques

Aqui tens el que ningu et diu quan comences a treballar amb agents d'IA: la part dificil no es aconseguir que un agent faci alguna cosa util. La part dificil es gestionar el caos quan en tens tres executant-se alhora. Quatre finestres de terminal obertes, agents treballant en tasques diferents, un s'ha penjat silenciosament fa vint minuts i no t'has adonat. Els agents estan be. _Tu_ ets el coll d'ampolla.

Vaig passar cent hores construint la meva propia eina per resoldre aixo -- Clovr Code Terminal, un panell de control basat en navegador per executar multiples sessions d'agents. Aquelles hores em van ensenyar mes sobre enginyeria agentica del que qualsevol quantitat de lectura podria haver-ho fet. Aquest capitol destil·la els principis que van emergir. CCT es el cas d'estudi, no el punt central.

== El Treball Agentic Es Inherentment Paral·lel

Els fluxos de treball d'un sol agent son una crossa. No sempre -- de vegades un agent en una tasca es exactament el correcte. Pero el poder real de l'enginyeria agentica apareix quan executes multiples agents en paral·lel, cadascun enfocat en una peca diferent del problema.

Aixo es contraintuintiu. La majoria de nosaltres venim d'un mon on _nosaltres_ som el fil d'execucio unic. Escriure codi, despres tests, despres documentacio. Seqüencial. Els agents trenquen aquest model -- tots poden treballar simultaneament, pero nomes si pots fer-ne el seguiment.

Si el teu flux de treball no et dona visibilitat sobre el treball en paral·lel, o serialitzaras tot (malbaratant el potencial dels agents) o executaras coses en paral·lel i perdras el fil (malbaratant el teu propi temps netejant l'embolic). Qualsevol eina que facis servir -- panells de tmux, multiples projectes de Cursor, fins i tot un post-it que fa seguiment de que s'esta executant on -- resol primer el problema de visibilitat. Els agents no es gestionaran sols.

#figure(
  image("../../assets/cct-dashboard.png", width: 100%),
  caption: [El panell principal de CCT -- multiples sessions d'agents executant-se en paral·lel, amb estat en temps real i seguiment de costos.],
)

== Els Agents Necessiten Pas de Context Estructurat

Tens un agent que acaba de planificar una funcionalitat. Coneix els requisits, l'estructura de fitxers, els casos limits. Ara vols que un agent diferent implementi el que s'ha planificat. Com transfereixes aquell coneixement?

L'enfocament naif es copiar i enganxar -- agafar el pla de la sortida de l'agent un, enganxar-lo al prompt de l'agent dos. Aixo funciona, a penes. Perds matisos, oblides coses, i et converteixes en un porta-retalls huma, que es exactament el tipus de feina de baix valor que se suposa que els agents han d'eliminar.

L'enfocament millor son traspassos estructurats: un format definit per passar context d'un agent a un altre. Escriu una plantilla de traspas. Fes que els agents resumeixin la seva feina en un format consistent abans d'acabar. Alimenta aquell resum al seguent agent. Aquesta es la metafora de la "tripulacio" feta operativa -- agents col·laborant no a traves de memoria compartida, sino a traves de comunicacio estructurada.

He utilitzat aquest patro per encadenar tres agents en seqüencia: un per planificar, un per dissenyar, un per implementar. Cadascun llegeix el traspas de l'agent anterior. El resultat es consistentment millor que un sol agent intentant fer-ho tot, perque cada agent treballa dins d'un context enfocat en lloc d'un d'extens.

== La Confianca Ha de Ser Configurable

Cada crida a eina que fa un agent -- cada comanda bash, cada escriptura de fitxer, cada peticio de xarxa -- es una decisio de confianca. Executar agents sense baranes es rapid i terrorific. Un dels meus va executar `rm -rf` en un directori que m'importava. (Era en un worktree, aixi que no hi va haver dany real. Llico apresa igualment.) L'extrem oposat -- aprovar cada operacio manualment -- fa els agents inutilitzables. Et passes tot el temps clicant "permetre" a `git status` i `ls`.

La resposta real es un espectre de confianca configurable. Regles de sempre-permetre per a comandes segures, aprovacio manual per a operacions sensibles, i mode completament automatic per a prototipatge rapid en entorns d'un sol us. Amb el temps, la teva configuracio de permisos es converteix en un document viu de la teva relacio de confianca amb els agents.

Qualsevol flux de treball agentic necessita una manera d'ajustar la confianca. Si la teva eina nomes ofereix "permetre tot" o "aprovar tot", oscil·laras entre l'ansietat i la frustracio. La capa de permisos no es sobrecost -- es el que fa possible el treball agentic sostingut.

== El Control de Versions Es Infraestructura d'Agents

Cada vegada que un agent feia un embolic, el meu primer instint era `git diff` i `git stash`. El control de versions ja era la meva xarxa de seguretat. Fer-lo de primera classe a l'eina nomes va formalitzar el que ja feia manualment.

El principi es simple: _mai deixis un agent treballar a la teva branca principal_. Dona-li una branca. Dona-li un worktree. Dona-li un contenidor. Qualsevol mecanisme d'aillament que prefereixis, utilitza'l. Els bons resultats es fusionen. Els mals resultats s'eliminen. Sense embolic, sense risc, sense drama.

#figure(
  image("../../assets/cct-new-session.png", width: 80%),
  caption: [Creant una nova sessio amb aillament de worktree, mode de permisos, i seleccio de model -- cada principi d'aquest llibre integrat en un sol dialog.],
)

Si estas utilitzant Claude Code a un terminal, un simple script de shell que crea un worktree i inicia una sessio et dona el vuitanta per cent d'aquest benefici. L'eina no importa. L'aillament si.

== No Necessites Construir el Teu Propi

Vull ser directe: _no construeixis el teu propi IDE agentic._ Jo ho vaig fer perque tenia necessitats especifiques que satisfer i perque construir-lo em va ensenyar coses sobre les quals volia escriure. Pero podria haver estat productiu amb Claude Code a un terminal i uns quants bons scripts de shell.

Els principis d'aquest capitol -- visibilitat paral·lela, traspassos estructurats, confianca configurable, control de versions com a infraestructura -- es poden implementar amb qualsevol eina:

- *Visibilitat paral·lela:* panells de tmux, un simple fitxer de log, fins i tot un post-it que fa seguiment de que s'esta executant on.
- *Traspassos estructurats:* una plantilla markdown que els agents omplen quan acaben. Copia-la al prompt del seguent agent.
- *Confianca configurable:* els flags de permisos de Claude Code, `.claude/settings.json`, o simplement executar agents en un sandbox restringit.
- *Aillament amb Git:* un script de shell de tres linies que crea un worktree i inicia una sessio.

L'eina no importa. El model mental si.

== La Llico Real

L'enginyeria agentica no tracta realment sobre els agents. Tracta sobre els _sistemes al voltant dels agents_ -- la visibilitat, el pas de context, els limits de confianca, l'aillament, els bucles de retroalimentacio. Encerta-ho i gairebe qualsevol model capac produira bons resultats. Falla-ho i fins i tot el millor model creara un caos car.

La resta d'aquest llibre tracta sobre aquests sistemes.
