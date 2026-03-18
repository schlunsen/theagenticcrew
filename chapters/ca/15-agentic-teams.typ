= Equips Agentics

#figure(
  image("../../assets/illustrations/ch15-crew.jpg", width: 80%),
)

El software sempre ha estat un esport d'equip. Els agents no canvien aixo. Pero canvien la forma de l'equip, el ritme de la feina, i les habilitats que importen. Si lideres un equip -- o hi treballes -- necessites pensar-hi ara, no despres.

== El Multiplicador de 10x Es Real, Pero Es Distribueix Diferent

Has sentit l'afirmacio: els agents fan els enginyers 10x mes productius. No es incorrecta. Nomes es engannyosa.

Els agents fan certes tasques _dramaticament_ mes rapides. Generar boilerplate, escriure infraestructura de tests, refactoritzar a cent fitxers, migrar versions d'API, cablear endpoints CRUD -- passen d'hores a minuts. El guany de velocitat es real i es massiu.

Pero altres tasques a penes canvien. El disseny de sistemes segueix requerint pensar. Depurar una condicio de carrera subtil segueix requerint paciencia, intuicio i comprensio profunda del runtime. Les converses amb stakeholders segueixen trigant el que triguen. L'agent no pot seure a la teva revisio d'arquitectura i fer les preguntes correctes.

El multiplicador de 10x no es un multiplicador pla al llarg del teu dia. Es un grafic d'espigues. Algunes tasques van 50x mes rapides. Algunes van 1x. Unes poques fins i tot es poden frenar si lluites contra l'agent en lloc de fer-ho tu.

Els equips que entenen aixo despleguen agents estrategicament. No donen cada tasca a un agent i esperen magia. Identifiquen les zones d'alt palanquejament -- les tasques on els agents genuinament comprimeixen els terminis -- i centren l'esforc dels agents alla. La resta es queda humana.

== La Revisio de Codi Canvia

Aqui tens que passa quan els agents entren al flux de treball d'un equip: el volum de PRs puja. _Molt_. Un enginyer que solia obrir dos PRs al dia ara n'obre cinc. El codi d'aquells PRs es sintacticament correcte, ben formatat, i passa els tests. I revisar-lo es _esgotador_.

El model antic de revisio de codi -- llegir cada linia, buscar errors d'un-per-un, verificar gestio de casos limits -- no escala quan la meitat del codi va ser generat en segons. Cremaras els teus revisors en una setmana.

El canvi es de "es correcte?" a "es l'enfocament correcte?" El codi generat per agents normalment es _localment_ correcte. Fa el que es va demanar. La questio es si el que es va demanar era la cosa correcta. Necessita existir aquest nou servei, o hauria d'estar aquesta logica dins l'existent? Es la frontera d'abstraccio correcta? Fa aquest canvi el sistema mes simple o mes complex?

Els revisors es converteixen en arquitectes. Amplien la visio. Comproven intencio, no implementacio.

Adaptacions practiques que funcionen:
- PRs mes petits i mes enfocats -- mes facils per a agents i revisors
- Comprovacions automatiques gestionen la part mecanica (linting, cobertura de tests, verificacio de tipus)
- El temps de revisio esta protegit al calendari, no espremut entre reunions
- L'equip acorda "patrons de confianca" -- si un PR segueix un patro conegut i passa CI, te una via de revisio mes rapida

La fatiga de revisio es l'assassi silencis dels equips assistits per agents. Pren-t'ho seriosament.

== La Questio de l'Enginyer Junior

Aixo es el problema mes dificil d'aquest capitol, i no tinc una resposta neta.

Els enginyers juniors tradicionalment aprenien fent la feina que ara els agents fan mes rapid i millor. Escriure aquell primer endpoint CRUD. Lluitar amb un layout CSS complicat. Esbrinar per que el test falla. Aquestes tasques eren tedioses per als seniors pero _formatives_ per als juniors. La lluita era l'educacio.

Si els agents gestionen tot aixo, on passa l'aprenentatge?

El pitjor resultat son juniors que es tornen dependents dels prompts -- poden aconseguir que un agent generi codi, pero no poden explicar que fa el codi o depurar-lo quan es trenca. Es salten completament la fase de comprensio. Aixo no es enginyeria; es un flux de treball de copiar i enganxar molt car.

El cami millor es utilitzar agents com a _tutors_, no substituts. Un junior escrivint una migracio de base de dades hauria de demanar a l'agent que _expliqui_ la migracio, no nomes que la generi. "Per que has posat una transaccio aqui?" "Que passa si aixo falla a mitges?" "Mostra'm com es veu sense l'ORM." L'agent es converteix en un professor pacient amb temps infinit -- alguna cosa que la majoria de seniors no poden oferir.

La programacio en parella amb agents, _supervisada per seniors_, es el model mes prometedor que he vist. El junior dirigeix l'agent. El senior observa, fa preguntes, i intervé quan el junior accepta alguna cosa que no enten. Es mes lent que deixar l'agent fer-ho tot, pero produeix enginyers que realment saben el que fan.

Els equips que es salten aquesta inversio estan prenent en prestec del futur. Els juniors sense supervisio d'avui son els seniors de dema que no poden depurar produccio sense una crossa d'IA.

== Distribucio de Coneixement

Aqui tens un patro que apareix a cada equip que adopta agents de manera desigual: un enginyer es torna fluid amb agents, comenca a lliurar al triple de velocitat que la resta, i en pocs mesos ha tocat cada part de la base de codi. Es converteix en l'unic punt de fallada.

El bus factor cau a u. No perque ningu ho hagi planificat, sino perque velocitat i concentracio de coneixement estan correlacionats. L'enginyer que lliura mes apren mes. Els altres es queden enrere, no nomes en output sino en _comprensio_ del sistema que col·lectivament posseeixen.

Aixo es un problema de gestio, no de tecnologia. L'arreglament es estructural:

- *Fitxers `CLAUDE.md` compartits.* Cada projecte en te un. Tothom hi contribueix. Codifica el coneixement col·lectiu de l'equip, no el d'una sola persona.
- *Fluxos de treball i convencions compartits.* L'equip acorda com utilitza agents -- quines eines, quins patrons, quines baranes. Sense configuracions de llop solitari.
- *Rotacio.* Els enginyers fluids amb agents roten a diferents parts de la base de codi. El coneixement s'escampa a traves de la feina, no de la documentacio.
- *Comparticio de sessions d'agents.* Alguns equips han comencat a compartir sessions d'agents interessants -- els prompts, les sortides, les decisions. Es una forma de transferencia de coneixement que no existia abans.

L'objectiu no es frenar el teu enginyer mes rapid. Es assegurar-se que el coneixement de l'equip segueix el ritme del output de l'equip.

== Les Convencions Compartides Importen Mes

Vam cobrir les convencions a un capitol anterior. En un context d'equip, el que hi ha en joc es mes alt.

Quan un enginyer individual utilitza agents, les seves convencions afecten una persona. Quan un equip utilitza agents, les convencions afecten _cada sessio d'agent a tot l'equip_. Un projecte ben estructurat amb nomenclatura clara, patrons consistents, i un `CLAUDE.md` mantingut vol dir que els agents de cada enginyer comencen des d'una base solida.

Un projecte desordenat vol dir que cada agent reinventa la roda. Diferents enginyers obtenen sortides diferents. La base de codi deriva. Les revisions es tornen mes dificils perque ara estas revisant no nomes el codi sino l'_estil_ del codi, que varia segons l'agent de quin enginyer l'hagi escrit.

Els estandards de codi en un equip agentic no son sobre estetica. Son sobre _efectivitat dels agents_. L'equip que acorda estructura del projecte, convencions de nomenclatura, patrons de testing, i format de documentacio obte millor output de cada sessio d'agent. Es un multiplicador de forca sobre un multiplicador de forca.

Inverteix el temps. Escriu els estandards. Imposa'ls a CI. Es retorna a cada PR.

== El Nou Standup

Com es la coordinacio diaria quan cada enginyer esta executant multiples sessions d'agents en paral·lel?

L'standup antic: "Ahir vaig treballar en la refactoritzacio d'autenticacio. Avui continuare. Sense blocadors."

El nou standup: "Tinc tres agents executant-se. La refactoritzacio d'autenticacio ha aterrat i esta en revisio. La migracio d'API esta al 80% -- l'agent s'ha encallat amb el parsing XML legacy, aixi que estic agafant-ho manualment. Acabo de llancar una tercera sessio per generar tests d'integracio per al modul de facturacio."

La granularitat canvia. La feina es mou mes rapid, aixi que la coordinacio necessita seguir el ritme. Un enginyer podria _comencar i acabar_ una tasca entre standups. La sincronitzacio diaria es converteix menys en actualitzacions de progres i mes en alineament d'intencio -- assegurant-se que tres enginyers no estan enviant agents al mateix problema des d'angles diferents.

Alguns equips estan passant a standups asincrons amb check-ins mes frequents. Altres utilitzen dashboards compartits que fan seguiment de sessions d'agents actives. La resposta correcta depen de l'equip, pero l'antic ritme de "una actualitzacio per persona per dia" sovint no es suficient.

== Compliment i Rastre d'Auditoria

Si un agent escriu codi que causa un incident de produccio, qui es el responsable? L'enginyer que va fer el prompt? El revisor que va aprovar el PR? El lider d'equip que va decidir adoptar fluxos de treball agentics? Aixo no es una pregunta filosofica que debats davant unes cerveses. Es una questio legal i de compliment, i les industries regulades necessiten respostes clares _abans_ que passi l'incident, no durant el postmortem.

La bona noticia es que la resposta no es realment tan complicada. Les eines i processos ja existeixen. Nomes necessites ser explicit sobre ells.

*Git es el teu rastre d'auditoria.* Cada commit generat per un agent hauria de ser atribuible. El missatge de commit hauria d'indicar que va ser assistit per agent -- una etiqueta `Co-Authored-By`, un prefix, qualsevol convencio que adopti el teu equip. El PR hauria de mostrar qui l'ha revisat. L'aprovacio de fusio es la signatura. Aixo ja es com funcionen la majoria d'equips; la clau es fer-ho _consistent_. Atribucio ad-hoc -- de vegades etiquetar, de vegades no -- es pitjor que cap sistema, perque crea la impressio d'un proces sense la fiabilitat d'un.

*El revisor n'es responsable.* La resposta practica per a la majoria d'organitzacions es senzilla: l'enginyer que revisa i aprova el PR assumeix la responsabilitat, igual que ho faria per a qualsevol codi de qualsevol font. El codi generat per agents no te un estandard de responsabilitat diferent. Si aproves un PR, estas dient "he revisat aixo i crec que es correcte." L'eina que va generar el codi es irrellevant per a aquella afirmacio. Aixo tambe vol dir que les revisions de codi generat per agents necessiten ser revisions _reals_, no segells de goma. Si el volum de PRs generats per agents esta fent impossible una revisio exhaustiva, aixo es un problema de flux de treball a resoldre, no un estandard a rebaixar.

*Per a industries regulades.* Documenta el teu flux de treball agentic com a part de la teva documentacio d'SDLC. Quins models s'utilitzen, quina versio, quines baranes hi ha, quin proces de revisio passa el codi generat per agents abans d'arribar a produccio. Els auditors volen veure un _proces_, no perfeccio. Un proces documentat que inclou "generacio de codi assistida per IA amb revisio humana obligatoria i verificacio de CI" es auditable. Un proces no documentat on els enginyers utilitzen les eines que volen sense cap enfocament consistent no ho es. Si ets a fintech, sanitat, o qualsevol cosa amb supervisio regulatoria, documenta-ho abans que algu ho demani.

*Guarda logs de sessions.* Rete logs de sessions d'agents, especialment per a codi que toca sistemes sensibles -- facturacio, autenticacio, gestio de dades, qualsevol cosa amb implicacions regulatories. No perque els llegiras rutinariament, sino perque podries necessitar-los durant una revisio d'incidents. "Que va veure l'agent quan va generar aquest codi? Quin prompt va produir aquesta sortida? Amb quin context estava treballant?" Aquestes son preguntes que vols poder respondre sis mesos despres. La majoria d'eines agentiques poden exportar o registrar sessions. Configura la retencio abans de necessitar-la. El cost d'emmagatzematge es trivial comparat amb el cost de no tenir els logs quan compliment ve a trucar.

== La Contractacio Canvia

Si els agents gestionen les parts mecaniques del codi, que necessites realment d'un enginyer?

La velocitat bruta de codi importa menys. L'enginyer que podia escriure una cerca binaria perfecta a la pissarra en tres minuts te una habilitat que els agents han commodititzat. Aixo no es inutil -- entendre algoritmes segueix important -- pero ja no es el diferenciador.

El que importa mes:

- *Disseny de sistemes.* La capacitat de descompondre un problema en components, definir interficies, i raonar sobre compromisos. Els agents poden implementar un disseny. No poden dir-te quin disseny es correcte per a les teves restriccions.
- *Judici.* Saber quan utilitzar l'agent i quan pensar. Saber quan la sortida de l'agent es incorrecta encara que sembli correcta. Saber quines dreceres prendre i quines protegir.
- *Comunicacio.* La capacitat d'articular intencio clarament -- als agents, als companys d'equip, als stakeholders. Pensadors vagues obtenen sortida d'agents vaga. Pensadors precisos obtenen resultats precisos.
- *Descomposicio de problemes.* Dividir una tasca gran en peces de mida d'agent es una habilitat. Esta relacionada amb el disseny de sistemes pero es mes tactica. L'enginyer que pot convertir un epic de Jira en deu prompts d'agents ben acotats superara el que enganxa tot l'epic en una finestra de xat.

L'entrevista que pregunta "implementa aquest algoritme a la pissarra" esta testejant una habilitat que importa menys cada any. L'entrevista que pregunta "aqui tens un sistema amb aquestes restriccions -- explica'm com el construiries, quins compromisos faries, i com verificaries que funciona" esta testejant les habilitats que importen _mes_ cada any.

Contracta per judici. Sempre pots donar-los un agent per a la resta.
