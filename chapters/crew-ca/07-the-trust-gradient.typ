= El Gradient de Confianca

#figure(
  image("../../assets/illustrations/crew/ch07-trust-gradient.jpg", width: 80%),
  caption: [_Comença estret. Afluixa amb evidència._],
)

Deixaries que un becari nou envia correus als teus clients el primer dia? Probablement no. El deixaries redactar correus perque tu els revisessis? Es clar. El deixaries enviar respostes rutinaries despres d'un mes de feina, havent vist com treballa? Segurament si.

Aquesta escalada -- de "ja ho faig jo" a "fes-ho, pero jo ho reviso" a "endavant, confio en tu" -- es exactament com hauries de pensar en treballar amb agents. S'anomena el gradient de confianca, i fer-ho be es la diferencia entre un agent que t'ajuda i un que crea un embolic que et passa la tarda arreglant.

== La Taula de Mescles

Pensa en el teu nivell de confianca com una taula de mescles -- d'aquelles amb controls lliscants. Cada tipus de tasca te el seu propi control:

- *Llegir fitxers i dades* -- Risc baix. L'agent nomes mira. Puja'l.
- *Escriure i editar documents* -- Risc mitja. L'agent podria canviar alguna cosa que t'importa. Deixa'l a "revisar abans de desar."
- *Enviar missatges o correus* -- Risc mes alt. Un cop enviat, ja esta enviat. Deixa'l a "esborrany per a la meva aprovacio."
- *Fer compres o decisions financeres* -- Risc alt. Deixa'l a "suggereix, no actueis."
- *Eliminar o sobreescriure dades* -- Risc alt. Deixa'l a "pregunta'm primer."

No poses tots els controls igual, i no els ajustes un cop i te n'oblides. Es mouen amb el temps a mesura que guanyes confianca en arees concretes.

== El Trinquet

El primer dia amb un agent, tot es revisa. Cada sortida es comprova. Encara no saps on es brillant i on es fragil, aixi que ho vigiles tot. Aixo es normal. Aixo es intel.ligent.

Despres d'uns dies, apareixen patrons. L'agent es excel.lent redactant informes. Es solid en analisi de dades. De vegades fa tries qüestionables sobre el to en correus de cara al client. Ara els teus controls ho reflecteixen: informes i analisis funcionen amb revisio minima, els correus de clients reben una lectura acurada abans d'enviar-los.

Despres d'unes setmanes, has vist desenes de tasques completades amb exit. Confies mes en l'agent en les arees on ha demostrat la seva valia. Les baranes de seguretat segueixen alla, pero son invisibles per al 90% de la feina rutinaria. Nomes s'activen en situacions inusuals.

Aixo es el trinquet: un ajust lent, basat en evidencies, d'apretar i afluixar. Les persones que mai afluixen les baranes acaben abandonant els agents perque "es massa feina revisar-ho tot." Les persones que afluixen massa rapid reben el correu que no s'hauria d'haver enviat, o les dades que no s'haurien d'haver eliminat.

== Baranes de Seguretat a la Practica

Per a projectes de software -- del tipus que podries construir amb un agent -- les baranes de seguretat tenen una forma molt concreta, i ja la coneixes: les branques de Git.

Quan un agent treballa en una branca, tots els seus canvis estan aillats. Pots revisar-los en un pull request abans que toquin el projecte principal. Aixo es una barana de seguretat. L'agent te llibertat per experimentar, pero els resultats passen per la teva aprovacio abans de convertir-se en reals.

Per a tasques que no son codi, les baranes son diferents:

- *Esborranys, no enviaments.* L'agent escriu el correu. Tu l'envies.
- *Suggeriments, no decisions.* L'agent recomana l'assignacio del pressupost. Tu l'aproves.
- *Resums amb fonts.* L'agent resumeix l'informe _i et mostra d'on ve cada afirmacio_. Tu ho verifiques.
- *Desplegaments graduals.* Prova la sortida de l'agent en una tasca petita i de baix risc abans de confiar-li la gran.

El principi es sempre el mateix: mante l'huma en el circuit per a qualsevol cosa que no es pugui desfer facilment.

== Els Dos Errors

Hi ha exactament dues maneres d'equivocar-se amb el gradient de confianca:

*Massa estret:* Revises cada sortida, tornes a comprovar cada fet, reescrius cada frase. L'agent es converteix en una manera lenta i cara de produir un esborrany que anaves a reescriure de totes maneres. T'exhaureixes supervisant i conclous que "els agents no valen la pena." Si que valen -- nomes que mai has deixat moure el trinquet.

*Massa fluix:* Deixes que l'agent funcioni sense supervisio perque els primers resultats eren bons. L'agent envia un correu amb un error factual. Publica un informe amb una estadistica inventada. Elimina un fitxer que no tenia copia de seguretat. Conclous que "no es pot confiar en els agents." Si que es pot -- nomes t'has saltat la part on verifiques abans de donar autonomia.

El punt ideal no es cap dels dos. Es un canvi gradual, basat en evidencies -- revisant-ho tot al principi, afluixant a mesura que la confianca creix, pero mantenint limits ferms en les coses que realment importen.

== El Teu Paper

Potser aquesta es la idea mes encoratjadora del llibre: el gradient de confianca significa que _tu_ sempre tens el control. No l'agent. No la tecnologia. Tu.

Tu decideixes que pot veure l'agent. Tu decideixes que pot fer. Tu decideixes quan revisar i quan confiar. Pots apretar les baranes de seguretat en qualsevol moment. Pots eliminar una branca. Pots rebutjar un esborrany. Pots dir "de fet, aquesta me l'encarrego jo."

Un agent es una eina amb un dial de confianca. Tu tens el dial. Aixo no es una limitacio -- es el disseny.
