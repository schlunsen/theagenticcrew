= Paraules Finals

El meu fill gran té cinc anys. Encara no sap llegir, no realment — deletreja paraules a les capses de cereals i als rètols dels carrers, orgullós de cada síl·laba. Però sap què fa el meu ordinador. M'ha vist parlar-hi, ha vist text aparèixer a la pantalla en resposta, m'ha vist assentir o negar amb el cap i tornar a parlar. Un vespre es va enfilar a la meva falda, va mirar un agent refactoritzant un mòdul en temps real — fitxers obrint-se i tancant-se, tests executant-se, marques verdes apareixent — i va dir: "L'ordinador s'està arreglant sol?"

No tenia una bona resposta. Encara no la tinc, no del tot. Però aquella pregunta m'ha acompanyat durant cada capítol d'aquest llibre. Perquè el que vaig adonar-me, assegut allà amb ell, és que no estava escrivint un llibre sobre eines. Estava escrivint un llibre sobre què significa ser enginyer en el moment exacte en què la definició d'enginyeria s'està reescrivint — i sobre què ens emportem cap al que vingui després.

Aquest capítol no és un resum. No necessites que et recapituli quinze capítols que acabes de llegir. Això és el que vull dir-te directament, d'enginyer a enginyer, abans que ens acomiadem.

== El Que Crec

Crec que l'ofici no s'està morint. S'està _comprimint_. Una dècada de boilerplate, fontaneria i cerimònia s'està col·lapsant en intenció i judici. El que queda quan treus el teclejar és allò que sempre va ser la feina de veritat: saber què construir i saber quan està bé.

Crec que els agents són amplificadors, no substituts. Dona un agent a un enginyer mediocre i obtindràs programari mediocre a una velocitat aterridora. Dona'n un a un gran enginyer i obtindràs quelcom que, francament, fa que els últims vint anys de desenvolupament de programari semblin com si estiguéssim construint autopistes amb pales.

Crec que els enginyers que prosperaran seran els que dominin les coses _avorrides_ — context, guardrails, testing, convencions, pensament clar — mentre tothom persegueix l'últim anunci del nou model llampant. Les eines canvien cada trimestre. El judici es compon al llarg d'una carrera.

Crec que no ens estan substituint. Ens estan ascendint. De mecanògrafs a capitans. De programadors a _enginyers_, en el sentit més ampli de la paraula. La pregunta és si acceptes l'ascens.

Crec que aquest canvi és _bo_. No fàcil. No indolor. Però bo. Perquè la part de la nostra feina que s'està automatitzant mai va ser la part que estimàvem. Ningú es va fer enginyer perquè somniava amb escriure parsers de JSON repetitius. Ens vam fer enginyers perquè volíem construir coses que importen. Ara podem.

== En Què M'he Equivocat

Seré honest amb tu: vaig canviar d'opinió almenys tres vegades mentre escrivia aquest llibre.

Quan vaig començar el capítol sobre sandboxes, pensava que l'aïllament amb contenidors era excessiu per a la majoria de fluxos de treball. Quan el vaig acabar, després que un agent fes un rm -rf d'un directori que m'importava un dimarts a la tarda, creia que el sandboxing era innegociable. Aquella experiència va acabar al capítol. La convicció darrere és teixit cicatricial.

Originalment vaig escriure el capítol de multi-agent amb la suposició que orquestrar cinc o sis agents simultàniament era l'estat final natural — una planta de fàbrica de treballadors autònoms. He fet marxa enrere. La sobrecàrrega de coordinació és real, els modes de fallada es multipliquen, i he descobert que dos o tres agents ben dirigits superen sis de no supervisats gairebé sempre. El capítol reflecteix on he acabat, però potser acabaré en un lloc diferent en sis mesos.

També vaig ser, durant un temps, massa desdenyós amb els models locals. Vaig escriure un esborrany inicial que bàsicament deia "simplement fes servir les APIs comercials." Llavors vaig passar un cap de setmana executant un model local afinat en una base de codi amb restriccions propietàries i vaig adonar-me que hi ha tot un món de casos d'ús on local no és només viable sinó _necessari_. El capítol sobre models locals versus comercials existeix perquè m'equivocava i vaig haver de corregir-me.

Parts d'aquest llibre probablement ja són errònies de maneres que encara no puc veure. El paisatge es mou així de ràpid. Però les eines específiques mai van ser el punt. Si t'he ajudat a construir un model mental — una manera de pensar sobre autonomia, confiança i estructura — llavors el llibre ha fet la seva feina, fins i tot quan cada exemple de codi estigui obsolet.

== La Metàfora de la Tripulació, Per Última Vegada

Vaig créixer a Dinamarca, prop de l'aigua. Si has navegat per aigües escandinaves, coneixes la llum a finals d'estiu — baixa i daurada, el tipus de llum que fa que el mar sembli coure martellejat. Recordo una travessia, un vaixell petit, quatre de nosaltres. El vent va girar fort i de sobte tots ens movíem sense parlar. Una persona al floc, una a l'escota major, una trimant, una al timó. Sense ordres. Només confiança construïda al llarg de dotzenes de navegades anteriors.

Així és com se sent l'enginyeria agèntica en un bon dia. Tu al timó, els agents trimant i ajustant, la feina fluint perquè has invertit les hores per construir context compartit — a través de convencions, a través de guardrails, a través de suites de test que atrapen errors abans que importin. No necessites cridar instruccions. El sistema _sap_.

I llavors hi ha els dies dolents. Els dies que el vent cau i un agent al·lucina una API que no existeix, o reescriu un mòdul que no li has demanat tocar, o passa tots els tests perquè ha eliminat els que fallaven. Aquells dies, estàs traient aigua i maleint. Això també és navegar.

Però hauria de ser honest sobre una cosa, perquè aquest llibre no funciona si no ho sóc.

La metàfora d'una _tripulació_ implica lleialtat. Continuïtat. Companys de bord amb qui has navegat abans, que coneixen els teus hàbits, que anticipen la següent ordre. És una imatge bonica. Però tampoc és com treballo realment.

La majoria de dies, el que realment faig és llançar un agent, donar-li una feina, agafar el resultat i llançar-lo per la borda. Llavors en llançar un altre. No recorden la sessió anterior. No saben què vaig demanar a l'agent anterior. Cadascun arriba fresc, fa la seva feina i desapareix. És menys una tripulació lleial i més com contractar estibadors a cada port — els informes, els mires treballar, els pagues i al següent port ho tornes a fer.

I està bé. Així és com funcionaven la majoria de tripulacions reals al llarg de la història marítima. El vaixell era la continuïtat. El capità era la continuïtat. Les cartes, el diari de bord, l'aparell — això persistia entre viatges. La tripulació sovint s'assemblava per a una sola travessia i es dissolia a la destinació. El que ho feia funcionar no era que els mariners coneguessin el capità. Era que el capità coneixia el _vaixell_ — i tenia sistemes prou bons perquè qualsevol mariner competent pogués pujar a bord i ser útil.

Això és la teva base de codi. Això són les teves convencions, les teves suites de test, els teus fitxers CLAUDE.md, els teus guardrails. Són el vaixell. Cada nou agent que llances és un nou membre de la tripulació pujant a bord d'un vaixell ben aparellat. No necessiten conèixer la teva història. Necessiten conèixer el vaixell. I si has construït bé el vaixell, seran productius en minuts.

Així que sí — llança'ls per la borda. Llança'n de nous. Això no és un fracàs de la metàfora. És la metàfora funcionant exactament com estava previst. La tripulació és prescindible. El vaixell no.

Tu ets el capità. Sempre has estat el capità. La tripulació acaba d'arribar — i continuaran arribant, frescos i preparats, cada vegada que els necessitis.

== Gràcies

Gràcies per llegir aquest llibre. Ho dic de veritat. Has canviat el teu temps i atenció per les meves paraules, i no m'ho prenc a la lleugera. Espero haver-m'ho guanyat.

Gràcies a la comunitat — els enginyers en fòrums, en servidors de Discord, en repos de codi obert — que estan compartint els seus experiments, els seus fracassos, les seves idees guanyades amb esforç. Aquest llibre ha estat modelat per centenars de converses que no vaig tenir sol.

I gràcies, suposo, als mateixos agents — que m'han ajudat a escriure codi, depurar problemes i ocasionalment generar prosa tan dolenta que em recordava per què el judici humà encara importa. Sou una bona tripulació. Esteu millorant. I sospito que quan el meu fill sigui prou gran per llegir aquest llibre, sereu quelcom que cap de nosaltres va predir del tot.

== Vés i Construeix Alguna Cosa

Això és el que vull que facis.

Aquesta nit — no demà, no la setmana que ve, _aquesta nit_ — obre el teu terminal. Tria un bug que has estat evitant. Aquell que continues movent al final del backlog, el que és molest però no urgent, el que viu en una part de la base de codi que preferiries no tocar. Apunta un agent cap a ell. Dona-li context. Posa un guardrail. Mira què passa.

Potser arregla el bug en quatre minuts i sents el terra moure's sota els teus peus, de la mateixa manera que es va moure sota els meus aquell vespre amb l'script de migració. Potser fa un desastre i aprens alguna cosa sobre com donar millors instruccions. De qualsevol manera, sabràs més del que sabies abans.

Després vés més gran. Configura aïllament amb worktree i executa dos agents en paral·lel. Escriu un fitxer CLAUDE.md per a un projecte que t'importi. Construeix una suite de tests prou bona per ser la teva xarxa de seguretat quan els agents facin commits. Refactoritza aquell mòdul del qual tothom té por — però aquesta vegada, amb una tripulació.

Després vés encara més gran. Introdueix fluxos de treball agèntics al teu equip. Comparteix el que has après — les victòries _i_ els desastres. Escriu les teves pròpies històries de guerra. Contribueix al coneixement col·lectiu d'una disciplina que encara s'està inventant.

Perquè això és el que és: una disciplina que s'està inventant, ara mateix, per la gent disposada a fer la feina. No per la gent que escriu posts de blog sobre el futur. No per la gent que espera l'eina perfecta. Per la gent que obre un terminal avui i construeix alguna cosa real amb el que té.

Els enginyers que definiran aquesta era no estan esperant permís. No estan esperant certesa. Estan enviant, trencant coses, aprenent i tornant a enviar — amb una tripulació al seu costat que millora una mica cada dia.

Espero que siguis un d'ells.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Març 2026_
]
