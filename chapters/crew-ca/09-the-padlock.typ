= El Cadenat

#figure(
  image("../../assets/illustrations/crew/ch09-the-padlock.jpg", width: 80%),
  caption: [_El sobre segellat -- com Internet guarda els secrets._],
)

L'has vist milers de vegades. La petita icona del cadenat a la barra d'adreces del teu navegador, just al costat de l'URL. Saps que significa "segur." Pero que vol dir realment? I que passa quan no hi es?

Aquest capitol tracta de la capa de seguretat invisible que fa funcionar l'internet modern. No cal que entenguis les matematiques -- pero entendre el _concepte_ et fara millor jutge del que es segur, del que es arriscat, i del que fer quan alguna cosa no sembla be.

== Postals i Sobres

La manera mes senzilla d'entendre l'encriptacio es pensar en el correu postal.

Quan es va construir la primera web, cada missatge entre el teu navegador i un lloc web s'enviava com una postal. Qualsevol persona que manipules aquella postal pel cami -- el teu proveidord'internet, el router Wi-Fi de la cafeteria, qualsevol xarxa entre tu i el servidor -- la podia llegir. Les teves credencials d'inici de sessio, el teu numero de targeta de credit, els teus missatges privats: tot escrit en text pla al darrere d'una postal, visible per a qualsevol que es molestes a mirar.

Aixo era HTTP -- Hypertext Transfer Protocol. El "com" de la comunicacio web, amb zero privacitat.

HTTPS va afegir el sobre. La S significa "Secure" (Segur), i el que vol dir es senzill: la conversa entre el teu navegador i el servidor esta encriptada. Codificada d'una manera que nomes els dos extrems poden llegir. Tothom entre mig segueix portant el sobre, pero no el pot obrir. Poden veure _on_ va (l'adreca del davant), pero no _que hi ha dins_.

Avui, mes del 95% del trafic web utilitza HTTPS. Es el valor per defecte. Quan veus aquell cadenat, vol dir que el sobre esta segellat.

== Que Significa el Cadenat -- i Que No Significa

Aqui hi ha la distincio crucial que confon la gent:

*El cadenat significa que la connexio esta encriptada.* Vol dir que ningu entre tu i el servidor pot llegir o manipular les dades en transit. Aixo es tot.

*El cadenat _no_ significa que el lloc web sigui de confianca.* Un lloc de phishing pot tenir un cadenat. Una botiga estafadora pot tenir un cadenat. Una pagina de distribucio de malware pot tenir un cadenat. El cadenat et diu que la _canonada_ es segura -- no diu res sobre que hi ha a l'altre extrem.

Pensa-ho aixi: un sobre segellat garanteix que ningu ha llegit la teva carta en transit. No garanteix que la persona a qui escrius sigui honesta.

Aixo importa perque s'ha ensenyat a la gent a "buscar el cadenat" com a senyal de seguretat. Era un consell raonable el 2005, quan obtenir un certificat requeria demostrar la teva identitat a una autoritat de certificacio i pagar centenars de dollars. Avui, qualsevol pot obtenir un certificat en segons, gratuitament. El cadenat es el minim, no un senyal de confianca.

== Certificats: Carnets d'Identitat per a Llocs Web

Llavors, com sap el teu navegador que realment esta parlant amb el teu banc i no amb un impostor? Aqui es on entren els _certificats_.

Un certificat SSL/TLS es com un carnet d'identitat per a un lloc web. Conte:

+ El nom de domini per al qual s'ha emess el certificat (per exemple, "elmeubanc.com")
+ La identitat de l'organitzacio que l'ha emess (l'_autoritat de certificacio_)
+ Una data de caducitat
+ Una signatura criptografica que demostra que el certificat es genuí

Quan visites un lloc web, el teu navegador comprova el certificat abans que aparegui el cadenat. Fa tres preguntes:

+ *Es aquest certificat per al domini correcte?* Si estas visitant elmeubanc.com pero el certificat diu elmeubanc-inici-segur.com, alguna cosa no va be.
+ *L'ha emess una autoritat de certificacio en qui confia el meu navegador?* El teu navegador porta una llista integrada d'autoritats de confianca -- organitzacions validades i aprovades per emetre certificats.
+ *Ha caducat?* Els certificats tenen dates de caducitat, normalment de 90 dies a un any. Un certificat caducat genera un avis.

Si alguna d'aquestes comprovacions falla, el teu navegador et mostra aquell avis de pagina completa que fa por: "La teva connexio no es privada." Aquell avis no exagera -- t'esta dient que el carnet d'identitat no quadra.

== Let's Encrypt: Cadenat Gratuit per a Tothom

Durant la major part de la historia del web, els certificats SSL costaven diners. De vegades molts diners -- centenars de dollars l'any per un sol domini. Les petites empreses, els llocs web personals i els projectes de codi obert sovint en prescindien. Internet era una barreja de portes amb cadenat i portes obertes de bat a bat.

El 2015, una organitzacio sense anim de lucre anomenada Let's Encrypt ho va canviar tot.

Let's Encrypt emet certificats SSL gratuitament. Completament gratuits. I no nomes gratuits -- automatitzats. En lloc d'un proces manual amb paperassa i pagaments, Let's Encrypt utilitza un protocol anomenat ACME que permet als servidors demostrar que controlen un domini i rebre un certificat en segons, sense intervencio humana.

L'impacte va ser enorme. Abans de Let's Encrypt, aproximadament el 40% del trafic web estava encriptat. Avui, es mes del 95%. Han emess milers de milions de certificats. Tota la postura de seguretat d'internet va canviar perque algu va eliminar la barrera del cost.

Hi ha un pero: els certificats de Let's Encrypt caduquen cada 90 dies. Aixo es intencional -- les vides curtes limiten el dany si un certificat es compromet. Pero vol dir que necessites automatitzacio per renovar-los. Si el teu certificat caduca i ningu se n'adona, els teus visitants reben aquell avis que fa por del navegador, i molts simplement marxaran.

Aqui es on les eines importa.

== Caddy: El Servidor Que Ho Fa Tot Sol

Si algun cop has sentit un desenvolupador dir "configurare el certificat SSL," potser t'imagines un proces complex amb molts passos. Durant anys, ho era. Havies de generar una sol.licitud de certificat, enviar-la a una autoritat de certificacio, rebre el certificat, instal.lar-lo al servidor, configurar el servidor per fer-lo servir i establir un proces de renovacio.

Caddy va fer desapareixer tot aixo.

Caddy es un servidor web -- la mateixa categoria de programari que Apache o Nginx, que potser has sentit esmentar. Pero el truc de Caddy es HTTPS automatic. Li dius a Caddy quin domini ha de servir, i ell s'encarrega de la resta: sol.licita el certificat a Let's Encrypt, l'instal.la, configura l'encriptacio i el renova automaticament abans que caduqui. Sense fitxers de configuracio. Sense tasques programades. Sense oblidar-se i despertar-se amb un lloc web trencat.

Per al membre de la tripulacio, aixo importa perque Caddy es el tipus d'eina que elimina tota una categoria de problemes. Quan el teu desenvolupador diu "el certificat SSL ha caducat," pots preguntar: "Per que no fem servir Caddy?" o "Per que la renovacio no esta automatitzada?" Son preguntes raonables. El 2026, els certificats caducats haurien de ser un problema resolt.

== Cloudflare: El Porter de la Porta

Cloudflare es mes dificil d'explicar en una sola frase perque fa _moltes_ coses. Pero la manera mes senzilla d'entendre-ho: Cloudflare s'asseu entre els teus visitants i el teu servidor, com un porter a la porta d'un restaurant.

Quan algu escriu l'adreca del teu lloc web, la seva sol.licitud no va directament al teu servidor. Va a Cloudflare primer. Cloudflare inspecciona la sol.licitud, decideix si es legitima, i despres la passa al teu servidor real. La resposta torna a traves de Cloudflare tambe.

Per que voldries un intermediari? Per diverses raons:

*Terminacio SSL.* Cloudflare gestiona l'encriptacio entre el visitant i ell mateix, utilitzant els seus propis certificats. Aixo vol dir que el teu servidor real no ha de gestionar certificats -- Cloudflare s'encarrega del cadenat. Per a molts llocs petits, aixo es el cami mes facil cap a HTTPS.

*Proteccio DDoS.* Un atac DDoS es quan algu inunda el teu servidor amb milions de sol.licituds falses fins que s'ensorra sota la carrega. Cloudflare absorbeix la inundacio. Te centres de dades arreu del mon amb un ample de banda enorme -- molt mes del que el teu servidor podria gestionar sol. L'atac colpeja el mur de Cloudflare i el teu servidor ni se n'assabenta.

*CDN (Content Delivery Network).* Cloudflare emmagatzema en cache els fitxers estatics del teu lloc web -- imatges, CSS, JavaScript -- en servidors arreu del mon. Quan algu a Toquio visita el teu lloc allotjat a Londres, rep la versio en cache d'un servidor de Cloudflare proper en lloc d'esperar que les dades creuin el planeta. Carregues de pagina mes rapides. Menys carrega al teu servidor.

*Gestio DNS.* Cloudflare gestiona els registres DNS del teu domini -- el sistema que tradueix "elmeulloc.com" a l'adreca real del servidor. El seu DNS es un dels mes rapids del mon.

Reconeixeras Cloudflare per la icona del nuvol taronja als panells de DNS, o per la pagina intersticial ocasional "Comprovant el teu navegador..." que apareix abans que es carreguin alguns llocs web. Aixo es la deteccio de bots de Cloudflare en accio, assegurant-se que ets una persona real abans de deixar-te passar.

La meitat d'internet esta darrere de Cloudflare. Si gestiones un lloc web o domini de qualsevol tipus, gairebe segur que et trobaras amb el seu panell en algun moment.

== Encriptacio a la Vida Quotidiana

SSL i HTTPS son la forma mes visible d'encriptacio, pero les mateixes idees subjacents apareixen a tot arreu:

*WhatsApp i Signal* utilitzen encriptacio d'extrem a extrem. Aixo vol dir que els missatges s'encripten al teu telefon i nomes es poden desxifrar al telefon del destinatari. Ni tan sols els servidors de WhatsApp els poden llegir -- estan portant sobres segellats que no poden obrir. Aixo es un pas mes enlla d'HTTPS, on el servidor _si_ pot llegir les dades.

*Gestors de contrasenyes* com 1Password o Bitwarden encripten la teva caixa forta amb una clau derivada de la teva contrasenya mestra. L'empresa que gestiona el servei no pot accedir a les teves contrasenyes -- no te la clau. Si oblides la teva contrasenya mestra, genuinament no et poden ajudar a recuperar-la. Aixo no es una limitacio; es el model de seguretat funcionant com esta dissenyat.

*Eines d'encriptacio de fitxers* com VeraCrypt et permeten crear contenidors encriptats al teu disc dur -- caixes fortes digitals que requereixen una contrasenya per obrir. L'encriptacio de disc complet (FileVault a Mac, BitLocker a Windows) encripta tot el teu disc, de manera que si et roben el portatil, el lladre obte un bloc inutil de dades codificades.

*Signatures digitals* demostren que un document o peca de programari no ha estat manipulat. Quan descarregues una aplicacio i el teu sistema operatiu diu "aquesta aplicacio es d'un desenvolupador verificat," esta comprovant una signatura digital -- una prova criptografica que l'aplicacio es genuinament de qui diu ser.

== Claus API i Secrets

Aquesta part connecta directament amb el treball amb agents.

Quan el teu agent es connecta a serveis externs -- una base de dades, un proveidorde correu, un processador de pagaments -- s'autentica utilitzant _claus API_ o _secrets_. Aquests son essencialment contrasenyes que atorguen acces programatic a un servei. Una clau API per al teu proveidorde correu pot enviar correus com tu. Una clau API per al teu processador de pagaments pot emetre reemborsaments.

La regla cardinal: *mai posis secrets en llocs publics.*

Aixo sona obvi, pero passa constantment. Els desenvolupadors cometen accidentalment claus API a repositoris publics de GitHub. La gent enganxa claus a documents compartits. Els agents, si no estan configurats correctament, podrien incloure claus a la seva sortida o als registres.

Els secrets pertanyen a variables d'entorn o eines de gestio de secrets -- mai al codi, mai als registres de xat, mai als documents. Quan treballis amb agents que tenen acces a serveis sensibles, pregunta al teu desenvolupador: "On s'emmagatzemen les claus API? Qui hi pot accedir? Que passa si una es compromet?"

Si una clau _es_ compromesa -- publicada publicament, enviada en un missatge, trobada en un registre -- la resposta es immediata: revoca-la i genera-ne una de nova. La majoria de serveis ho fan amb un sol clic. La clau antiga es torna inutil instantaniament.

Aixo es l'equivalent de seguretat de canviar els panys quan perds les claus de casa. No perdis el temps preguntant-te si algu les ha trobat. Simplement canvia-les.

== El Minim Que Hauries de Recordar

Si aquest capitol et sembla massa, aqui tens la versio curta:

+ *HTTPS (el cadenat) vol dir que la connexio esta encriptada* -- pero no vol dir que el lloc sigui de confianca.
+ *Els certificats son carnets d'identitat per a llocs web.* Caduquen, i quan ho fan, els navegadors avisen els teus visitants. L'automatitzacio (Let's Encrypt, Caddy) ho resol.
+ *Cloudflare es el porter* -- gestiona SSL, bloqueja atacs i accelera el teu lloc. La meitat d'internet el fa servir.
+ *L'encriptacio protegeix les dades en transit i en repos.* Els teus missatges, contrasenyes i fitxers es poden encriptar.
+ *Les claus API son contrasenyes per a maquines.* Tracta-les amb almenys tanta cura com les teves propies contrasenyes -- mes, perque sovint tenen un acces mes ampli.

No cal que configuris res d'aixo tu mateix. Pero saber que fan aquestes peces vol dir que pots fer les preguntes correctes, detectar problemes d'hora i prendre decisions informades sobre les eines que fa servir el teu equip. Aixo no es enginyeria. Es bon art mariner.
