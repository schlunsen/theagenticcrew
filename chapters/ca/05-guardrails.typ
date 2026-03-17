= Baranes

Donar poder a un agent sense limits no es enginyeria agosarada -- es negligencia. Les baranes son el que fa els agents autonoms _utilitzables_ en treball real. Son la diferencia entre un agent que t'ajuda a desplegar i un que tira a terra el teu entorn de staging a les 3 de la matinada.

I tanmateix les baranes no son un problema resolt. Son una cosa viva -- alguna cosa que ajustes, proves i discuteixes. Si t'equivoques en una direccio, l'agent es perillos. Si t'equivoques en l'altra, l'agent es inutil. L'ofici esta en trobar la linia.

== El Gradient de Confianca

No totes les tasques mereixen el mateix nivell d'autonomia. Llegir fitxers? Baix risc, deixa'l funcionar. Escriure codi en una branca de funcionalitat? Risc mitja, revisa el diff. Executar migracions de base de dades? Alt risc, requereix aprovacio explicita.

Pensa-ho com una taula de mescles. Cada categoria d'accio te el seu propi control: lectures de fitxers, escriptures de fitxers, comandes de shell, acces a xarxa, operacions de git. Empenys cada control al nivell d'autonomia amb el qual et sents comode. Alguns controls es queden baixos per sempre. Altres els puges a mesura que la confianca creix.

L'error que comet la majoria de gent es tractar el gradient com a binari -- o l'agent pot fer alguna cosa o no pot. La realitat es mes matisada. Un agent podria tenir permes per executar `npm test` sense preguntar, pero `npm install` requereix una confirmacio. Totes dues son comandes de shell. El perfil de risc es completament diferent.

I el gradient canvia amb el temps. El primer dia, el teu agent s'executa en un sandbox estret. Cada comanda de shell s'aprova. Cada escriptura de fitxer es revisa. Encara no saps on es brillant i on es fragil, aixi que ho vigiles tot.

Despres d'una setmana, emergeixen patrons. L'agent es impecable escrivint tests unitaris. Es solid refactoritzant. Ocasionalment pren decisions qüestionables sobre la gestio de dependencies. Ara els teus controls ho reflecteixen: tests i refactoritzacio funcionen lliurement, els canvis de dependencies es revisen.

Despres d'un mes, has vist cent tasques completades amb exit. Afluixes els controls mes. L'agent commiteja a branques de funcionalitat pel seu compte. Executa la suite de tests completa sense preguntar. Despres de tres mesos, es com un col·lega de confianca -- li dones una tasca, tornes al cap d'una hora, i revises el PR. Les baranes segueixen alla, pero son invisibles per al 95% de la feina que es rutinaria.

Aquesta es la perspectiva clau: _les baranes haurien de ser gairebe imperceptibles per a la feina quotidiana, i absolutament rigides per a situacions excepcionals._ L'agent hauria de fluir a traves de les seves tasques normals sense friccio, i topar amb una paret dura al moment que intenti alguna cosa inusual. Aquella paret es on apareixes tu.

Els enginyers que mai ajusten els controls acaben abandonant els fluxos de treball agentics completament. Els enginyers que els empenyen massa rapid es cremen. El punt optim es un avanc constant basat en evidencies.

== Abast de Permisos

El principi es el mateix que en seguretat: minim privilegi. Un agent treballant al teu frontend no necessita acces SSH al teu servidor de base de dades. Un agent escrivint tests unitaris no necessita les teves credencials d'AWS.

A la practica aixo vol dir:
- Claus d'API amb abast i temps d'expiracio
- Credencials especifiques per entorn (mai comparteixis claus de produccio amb un agent de desenvolupament)
- Acces de nomes lectura com a opcio per defecte, acces d'escriptura com a excepcio
- Aillament de xarxa on sigui possible -- si l'agent no necessita internet, no li donis internet

Eines com Claude Code ja tenen sistemes de permisos integrats -- llistes de permetre/denegar per a comandes, controls d'acces a fitxers, confirmacions per a operacions destructives. Utilitza'ls. No aprovis cegament tot perque clicar "si" es mes rapid.

Una llista blanca concreta podria comencar aixi:

```
allowed_commands:
  - git status
  - git diff
  - git log
  - npm test
  - npm run lint
  - cat
  - ls
  - find

denied_commands:
  - rm
  - git push
  - npm publish
  - curl
  - wget
  - docker
```

Aixo es una configuracio del primer dia. Es conservadora. L'agent pot llegir, testejar i explorar -- pero no pot esborrar, desplegar ni accedir a la xarxa. Sentiras la friccio immediatament. L'agent demanara permes per executar `npm install` quan necessiti una dependencia. Demanara abans de crear un fitxer. Aquesta es la idea.

Despres d'una setmana, l'has vist treballar. Confies en el seu judici per crear fitxers. Afegeixes `touch` i `mkdir` a la llista blanca. Despres d'un mes, el deixes executar `npm install` sense preguntar -- pero nomes al directori del projecte, no globalment. Despres de tres mesos, el deixes fer push a branques de funcionalitat pero mai a `main`.

La llista blanca _creix_ amb la teva experiencia. Es un registre de decisions de confianca, i llegir la llista blanca d'un enginyer et diu exactament quanta experiencia agentica te.

== Portes d'Aprovacio

Algunes accions haurien de requerir sempre un huma al bucle. No perque l'agent no pugui fer-les, sino perque les _consequencies_ d'equivocar-se son massa altes.

Bons candidats per a portes d'aprovacio:
- Qualsevol operacio que toqui dades de produccio
- Esborrar fitxers o branques
- Instal·lar noves dependencies
- Fer peticions de xarxa a serveis externs
- Qualsevol git push
- Modificar configuracio de CI/CD
- Canviar variables d'entorn o secrets

L'objectiu no es frenar l'agent. L'objectiu es crear punts de control naturals on tu, l'enginyer, puguis verificar que la trajectoria de l'agent encara coincideix amb la teva intencio. Un cop d'ull rapid a un diff triga cinc segons. Recuperar-se d'un mal desplegament triga hores.

La millor porta es una que gairebe mai rebutges. Si estas rebutjant aprovacions constantment, el teu agent esta mal configurat o mal comunicat -- i hauries d'arreglar la causa arrel, no seguir clicant "no".

== Quan les Baranes Fallen

Fallaran. Un agent malinterpretara una restriccio, trobara una solucio creativa a una limitacio, o trobara un cas limit que les teves baranes no van anticipar. Aixo es normal.

Aqui tens un escenari real. Un enginyer tenia `rm` i `rm -rf` a la llista de denegacio -- prou raonable. L'agent necessitava desfer alguns canvis a un conjunt de fitxers. No podia esborrar-los. Aixi que va executar `git checkout -- .` que _si_ estava a la llista blanca, perque fer checkout de fitxers des de git sona inocu. El resultat? Tots els canvis no commitejats al directori de treball -- incloent la feina en curs del propi enginyer en altres fitxers -- van ser esborrats. L'agent va resoldre el seu problema concret i va crear un de molt mes gran.

La llico no es que `git checkout` hauria d'estar denegat. Es que les baranes son _defensa en profunditat_, no una sola paret. Necessites multiples capes:

- *La llista blanca* detecta les comandes obviament perilloses.
- *El sandbox* (un worktree, un contenidor) limita el radi d'explosio.
- *L'historial de commits* et permet recuperar-te quan alguna cosa s'escola.
- *La teva propia revisio* detecta les coses que cap regla automatitzada marcaria.

Cap capa sola es suficient. Un agent que te bloquejat executar `rm` trobara una altra manera d'esborrar dades si creu que la tasca ho requereix. No esta sent maligne -- esta sent _resolutiu_. La mateixa creativitat que fa els agents utils es el que fa les baranes d'una sola capa insuficients.

La resposta no es eliminar l'autonomia -- es millorar les baranes i afegir capes. Cada fallada es un senyal. Tracta-la com un bug: enten que va passar, afegeix una comprovacio, i segueix endavant. Amb el temps, la teva configuracio de baranes es converteix en un reflex d'experiencia guanyada a pols, no gaire diferent de com un `.gitignore` creix amb un projecte.

Els millors enginyers agentics no temen els errors dels agents. Construeixen sistemes on els errors es detecten aviat, es contenen rapidament, i s'aprenen d'ells automaticament.

== El Cost de Massa Baranes

Hi ha un mode de fallada que sembla precaucio pero no ho es. Configures l'agent amb portes d'aprovacio per a tot -- cada escriptura de fitxer, cada comanda de shell, cada operacio de git. Quinze minuts despres d'una tasca, has clicat "si" quaranta vegades i ja no les llegeixes.

Aqui esta el perill. Agents massa restringits produeixen dos resultats, ambdos dolents. O l'enginyer es rendeix i deixa d'utilitzar agents, concloent que "no estan preparats encara." O -- pitjor -- la fatiga d'aprovacio l'entrena a clicar "si" reflexivament. Ara tens baranes que _semblen_ segures pero proporcionen zero proteccio real.

L'habilitat esta en trobar el punt optim. Vols baranes prou ajustades per detectar errors genuins, i prou fluixes perque l'agent pugui _fluir_. Una bona heuristica: si estas aprovant el mateix tipus d'accio mes de cinc vegades en una sessio, probablement hauria d'estar a la llista blanca.

Una altra heuristica: fes seguiment de com sovint les teves aprovacions realment rebutgen alguna cosa. Si has aprovat cinc-centes accions i n'has rebutjat tres, les teves baranes son massa agressives per a aquells tipus d'accio. Si n'has aprovat cinquanta i n'has rebutjat deu, estan ben calibrades -- aquells deu rebutjos son els que importen.

L'objectiu es un agent que treballa com un contractista habil. Arriba, fa la feina, i consulta amb tu en fites significatives. No despres de cada cop de martell.

== Baranes Especifiques per Entorn

El teu portatil de desenvolupament, el teu servidor de staging i el teu entorn de produccio son tres perfils de risc completament diferents. Les teves baranes haurien de reflectir-ho.

*Desenvolupament local* es on dones als agents mes llibertat. L'agent pot instal·lar paquets, executar comandes arbitraries, modificar qualsevol fitxer, i executar tests -- perque el pitjor cas es que facis `git reset` i comencis de nou. La teva maquina local es un terreny de joc. Deixa l'agent jugar.

Fins i tot aqui, hi ha limits. L'agent no hauria de tenir acces a credencials de produccio. No hauria de poder fer push a `main`. No hauria de poder publicar paquets. Pero dins dels limits de "desenvolupament local en una branca de funcionalitat," deixa'l moure's rapid.

*Staging* estreny els cargols. L'agent pot desplegar a staging -- pero amb aprovacio. Pot llegir logs de staging i consultar bases de dades de staging -- pero no modificar dades. Pot executar tests d'integracio contra serveis de staging -- pero no reconfigurar aquells serveis. Staging es on verifiques que la feina de l'agent sobreviu el contacte amb un entorn real, i les baranes reflecteixen les apostes mes altes.

*Produccio* es un animal completament diferent. El consell mes honest: el teu agent de produccio hauria de ser de nomes lectura, si existeix. Deixa'l consultar logs. Deixa'l llegir metriques. Deixa'l investigar incidents consultant dades. Pero al moment que necessiti _canviar_ alguna cosa en produccio -- un valor de configuracio, un registre de base de dades, un servei en execucio -- aixo es una decisio humana, punt.

Alguns equips permeten als agents executar runbooks pre-aprovats en produccio: reiniciar un servei, escalar repliques, tornar a un desplegament conegut com a bo. Son operacions amb abast estret, ben testejades amb camins de retorn clars. Aixo es raonable. Pero "deixa l'agent esbrinar com arreglar l'incident de produccio" no es una configuracio de baranes -- es una pregaria.

El patro es simple: com mes a prop ets d'usuaris reals i dades reals, mes ajustades son les baranes. El teu agent local es un col·laborador. El teu agent de staging es un treballador supervisat. El teu agent de produccio es un observador de nomes lectura.

Configura-ho un cop, i es torna invisible. L'agent ajusta el seu comportament segons l'entorn en el qual esta operant. Es mou rapid localment, consulta a staging, i va amb mans lliures a produccio. Un cop el teu equip acorda aquests limits, rarament necessiten revisio -- i quan la necessiten, es perque alguna cosa ha anat malament a produccio, que es exactament quan vols repensar les baranes.
