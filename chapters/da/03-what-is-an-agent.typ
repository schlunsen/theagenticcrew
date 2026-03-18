= Hvad Er en Agent?

Ordet "agent" bliver kastet rundt i flæng. Det bruges om alt fra en chatbot der svarer på spørgsmål til et system der autonomt deployer kode til produktion. Før vi går videre, lad os være præcise om hvad vi mener — for distinktionen er vigtig for hvordan du arbejder med dem.

== Spektrummet

Ikke alle AI-værktøjer er agenter. I den ene ende foreslår *autocomplete* de næste par tokens mens du taster — reaktivt, én linje ad gangen, ingen tænkning involveret. *En copilot* ser mere kontekst og genererer større blokke, men den er stadig passiv: du spørger, den svarer. Skiftet sker med *værktøjsbrugende agenter*. En agent genererer ikke bare tekst — den _handler_. Den læser filer, skriver filer, kører kommandoer, inspicerer resultater, og gør det afgørende i et loop: prøv, observer, justér, prøv igen. I den anden ende tager *autonome agenter* et overordnet mål, planlægger deres egen tilgang og leverer et resultat med minimal menneskelig interaktion.

Det meste praktiske agentiske ingeniørarbejde i dag foregår i den værktøjsbrugende zone. Du giver agenten en opgave, den har adgang til værktøjer, og den arbejder iterativt. Du er i loopet — reviewende, vejledende, godkendende — men agenten laver det tunge løft.

== Hvad Gør Noget "Agentisk"

Tre evner adskiller en agent fra en fancy chatbot:

*Planlægning.* En agent bryder et mål ned i trin. "Tilføj autentificering til denne app" bliver til en række handlinger — læs codebasen, vælg frameworket, opret middleware, opdater routes, tilføj tests, verificer. En chatbot giver dig en kodeblok. En agent giver dig en proces.

*Værktøjsbrug.* En agent interagerer med verden — læser dine filer, kører dine tests, undersøger fejloutput. Hvert tool call giver ny information der former den næste beslutning. Dette feedback loop er det der gør agenter kraftfulde: de genererer ikke kode i et vakuum, de genererer kode og _verificerer_ den. Og her er det folk overser: de værktøjer du giver en agent definerer hvilken slags agent den _er_. En LLM med kun tekst-ind, tekst-ud er en chatbot. Giv den filadgang, kommandoudførelse og integrationer med eksterne systemer, og den bliver en ingeniør. Værktøjerne er forfremmelsen.

*Iteration.* En agent kan prøve, fejle og prøve igen. Skriv en funktion, kør testene, se en fejl, læs fejlen, justér, kør igen. Handl, observer, justér. En chatbot giver dig ét skud. En agent giver dig en cyklus.

== Agenter Er Ikke Magi

Det er vigtigt at være klar i øjnene om hvad agenter er og hvad de ikke er.

Agenter er ikke bevidste. De forstår ikke din kode på den måde du gør. De har ikke intuition, smag eller erfaring. Hvad de har er evnen til at processere store mængder tekst, genkende mønstre og generere plausible næste skridt — meget hurtigt, meget utrætteligt, og i et omfang der ville udtømme ethvert menneske.

De hallucinerer. De laver selvsikre fejl. De løser nogle gange det forkerte problem på smuk vis. De kan skrive kode der passerer alle tests men fuldstændig misser pointen. De er geniale praktikanter med uendelig energi og ingen dømmekraft.

Det er derfor _ingeniøren_ er vigtig. Agenten bidrager med hastighed og bredde. Du bidrager med retning, dømmekraft og smag. Kombinationen er mere kraftfuld end nogen af delene alene.

== Når Agenter Fejler

De vil fejle. At forstå _hvordan_ de fejler hjælper dig med at bygge bedre workflows.

*Scope creep.* Du beder om et bugfix, agenten refaktorerer tre filer og opdaterer build-systemet. Agenter er ivrige, og den iver strækker sig ud over hvad du bad om. Små, fokuserede opgaver og branch-isolering er dit forsvar.

*Hallucinerede API'er.* Agenten kalder funktioner eller biblioteker der ikke eksisterer — eller eksisterer i en anden version. At køre tests fanger dette. Agenten kan ikke hallucinere sig forbi en testsuite.

*Overselvsikkerhed.* Agenten siger den er færdig, og det ser færdigt ud, men der er en subtil bug der kun viser sig under specifikke betingelser. Review diffs. Stol ikke blindt på agentens output.

*Konteksttab.* På lange opgaver mister agenten overblikket over tidligere beslutninger — modsiger sig selv, omskriver kode den allerede skrev, glemmer begrænsninger. Små commits og klar kontekststyring er modgiften.

Hver fejltilstand har en modforanstaltning, og de modforanstaltninger er kapitlerne i denne bog: kontekst, guardrails, git, sandboxes, testing, konventioner. Principperne er ikke teoretiske — de er direkte svar på hvordan agenter fejler i praksis.

== Den Rigtige Mentale Model

Tænk ikke på agenter som værktøjer. Tænk ikke på dem som erstatninger. Tænk på dem som samarbejdspartnere med et meget specifikt sæt styrker og svagheder.

De er hurtige hvor du er langsom. De er tålmodige hvor du er utålmodig. De kan holde mere tekst i arbejdshukommelsen end du kan. De bliver aldrig trætte, aldrig frustrerede, har aldrig en dårlig dag.

Men de ved ikke hvad der er vigtigt. De ved ikke hvad brugeren faktisk har brug for. De ved ikke hvilken teknisk gæld der er acceptabel og hvilken der er en tikkende bombe. De ved ikke hvornår man skal skubbe tilbage på et krav. De ved ikke hvornår specifikationen er forkert.

Den bedste analogi jeg har fundet er _Rain Man_. Du er Tom Cruise. Agenten er Dustin Hoffman.

Raymond kan tælle kort som ingen anden levende — han ser mønstre i bjerge af data, processerer dem øjeblikkeligt, bliver aldrig træt, mister aldrig fokus. Men han kan ikke navigere et kasinogulv. Han ved ikke _hvorfor_ de tæller kort. Han ved ikke hvornår man skal rejse sig fra bordet, hvornår pitbossen begynder at blive mistænksom, eller hvad man skal gøre med pengene. Overladt til sig selv ville han tælle kort for evigt i et tomt rum.

Charlie er den med planen. Han ved hvilket kasino de skal ramme, hvornår man satser stort, hvornår man indkasserer, hvornår man ændrer strategi fuldstændigt. Han kan ikke selv tælle kort — ikke i Raymonds tempo, ikke i Raymonds skala. Men det behøver han ikke. Hans job er retning, dømmekraft og at vide hvad hele operationen er _til_.

Det er agentisk ingeniørarbejde. Din agent vil processere hele din codebase, generere løsninger i et tempo du ikke kan matche, og iterere utrætteligt. Men den ved ikke hvilket problem der er værd at løse. Den ved ikke hvornår den elegante løsning er den forkerte. Den ved ikke hvornår den skal stoppe.

Det er dit job. Og det vil det altid være.
