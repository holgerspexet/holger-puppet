# Har allt gått åt helvete med Holgerspexets IT-infrastruktur?

Det här dokumentet dokumenterar det man behöver veta för att återställa Holgerspexets IT-infrastruktur från total katastrof, när allt gått åt helvete.

## Om dokumentet

Det här dokumentet är rätt tekniskt och bör läsas av någon med måttliga kunskaper inom systemadministration av Linuxsystem. Men om du inte har kompetensen själv så frukta icke, hjälp finns att få. Dessutom, läser du det här dokumentet kan du knappast göra saker värre. Det här skrivs år 2019, något som kan vara värt att ha i åtanke. Tveksamt om det här någonsin kommer uppdateras. Förlåt och lycka till!

## Jag behöver hjälp.

Chilledill!

Det finns några personer och grupper man kan kontakta för att få hjälp. Systemen sattes ursprungligen upp av Henrik Henriksson `<hx@hx.ax>` år 2019, vilket kan vara en bra startpunkt.

På universitetet finns det lite hjälp att få. Datorföreningen Lysator kan eventuellt vara till hjälp, kontakta `<root@lysator.liu.se>`. Det rekommenderas att ta med kakor i så fall. Även LiSS har troligen medlemmar som kan hjälpa till.

Om Lysator och/eller LiSS har slutat existera eller mot förmodan är ohjälpsamma går det att kontakta LiU-IT. De har inget ansvar alls att hjälpa till. Däremot bör det finnas någon där som kan vara villig att hjälpa till eller peka vidare till någon annan.

### Förkunskaper

För att kunna fixa det här så behöver man kunna saker om

*   Linux
*   Servrar
*   Puppet
*   nginx
*   wordpress (förlåt)

### Behov

För att lösa problemen så behöver man

*   Två maskiner med publika IP-addresser (det går att knöla in på bara en om man anstränger sig)
*   Access till holgerspexets konto på Loopia för DNS (användarnamn &#39;holgerspexet.se&#39;)
*   Access till holgerspexets GitHub, `https://github.com/holgerspexet`
*   Access till holgerspexets google-organisation
*   Någon slags backup att återställa från. Har man riktigt mycket tur så finns det inkrementella backupper på Lysators backupserver eller rent av ett fräsht snapshot av den virtuella maskinen. Har man mindre tur så kanske det finns fysiska hårddiskar avsedda för disaster recovery i någon av Holgers lokaler. Har man ännu mindre tur så är det bara att börja om.
*   Lösenord! Som minimum krävs lösenord till Loopia för DNS och en spexare med access till holgerspexets github-organisation. Webbmaster torde ha en fysisk lapp. Om den fortfarande är handskriven i lila glittrigt bläck får ni gärna byta lösenorden i samma veva, då har de varit oförändrade sedan 2019 när Henrik inte orkade ta sig till en skrivare.
*   Potentiellt sett kakor, bullar och/eller sprit. Om du inte är spexare, utan bara hjälper till, be om kakor!

# Återställa från noll

Holgerspexet kör (kördes?) på två virtuella maskiner, en för alla interna sidor och en för den publika hemsidan. De interna systemen är byggda kring OpenProject, medan den publika hemsidan bara är en wordpressinstallation.

## Fixa maskiner

Fixa två virtuella maskiner med publika IPn någonstans. DigitalOcean, AWS, Lysator, eller någon spexares garderob. År 2019 rekommenderas Ubuntu 18.04 LTS,. Rekommenderade namn på maskinerna är typ `holgerspexet-insidan` och `holgerspexet-public`.

## DNS

Peka `insidan.holgerspexet.se` och `[www.]holgerspexet.se` mot rätt maskiner. Detta görs på loopia.

## Puppet

Holgerspexets puppetmanifest klonas från `https://github.com/holgerspexet/holger-puppet.git`. Det körs ett cronjob som pullar från github en gång per timme och applicerar puppetmanifesten. Om puppetkörningen mot förmodan lyckas första gången på en ny maskin så behöver man fortfarande göra några saker manuellt.

*   Sätta upp OpenProject. Puppet kommer förhoppningsvis installera paketen, men det behöver konfigureras med `$ openproject configure`. Välj bort allt som har med apache/nginx att göra, det hanteras av puppet. Däremot vill man ha en postgresdatabas.
*   Återställ openprojects databas. I bästa fall finns det en postgres-dump att återställa från. Om den inte fungerar ordentligt kan det vara på plats med  `$ openproject reconfigure` för att utföra databasmigreringar.
*   Återställ wordpress. Dumpa in wordpress i `/srv/holgerspexet-wordpress` och återställ mysql-databasen. Om puppet beter sig så kommer apache konfigureras korrekt.
*   Om Let&#39;s Encrypt fortfarande är en grej så borde saker lösa sig med certifikat automagiskt. Annars, fixa cert. Nginx kommer vägra starta om det inte finns giltiga certifikat, följaktligen kommer puppetkörningen misslyckas där tills giltiga cert finns.
*   Se till så att ssh-nycklar uppdateras efter vem som ska ha access, de finns i puppet-manifesten.
*   Generera _två_ par ssh-nycklar med olika namn för rootkontot på maskinen, dessa används för att hämta kod från GitHub. År 2019 tyckte GitHub det var en bra idé att förbjuda samma deploy-key från att hämta från flera olika repon `(╯°□°）╯︵ ┻━┻`. Konfigurera `holger-puppet`\-och `holger-archive`\-projekten på GitHub så de har deploy-keys.

När puppetkörningen misslyckas är det fritt fram att göra lite vad som. Pilla för hand tills det fungerar (bra), eller försök fixa till den halvdana puppetkoden (bättre). Ditt val, men dokumentera gärna.

## Mail

Inkommande mail kommer via google, där spexet har ett organisationskonto för non-profits. Lösenord borde finnas hos webmaster eller/eller ordförande.

Utgående massmail går via mailchimp. Någon kanske fortfarande har lösenord, annars är det bara att börja om. Även här bör lösenord finnas hos webmaster eller ordförande.

OpenProject tycker om att skicka mail. All mail från OpenProject kommer från `insidan.holgerspexet.se`, så det ligger på en separat domän från övrig mail. När servern sattes upp 2019 hade den en vidöppen port 25, så den bara kastade ut mail direkt på mottagaren. Ifall det ska sättas upp hos någon leverantör som tycker att det är en bra idé att blockera utgående mail, typ en spexares garderob, beöver man sätta upp forwarding på något sätt.

_Se till att uppdatera alla SPF-records!_

## Om allt annat skiter sig

*   Dumpa in wordpressinstallationen på godtycklig server med apache och lämna till nästa ansvarige. Spring.
*   Installera openproject på en server och återställ databasen. OpenProject har år 2019 en typ helautomagisk installer som löser allt. Kör den, döda servicen, dumpa in databasen, starta servicen, släng på en reverse proxy och hoppas på det bästa.  Finns ingen databas att återställa, installera OpenProject, acceptera smärtan och sätt upp allt igen, det borde inte vara _så_ jobbigt...
*   Ät en kaka.


En kopia av det här dokumentet finns på OpenProject-wikin. Se till att uppdatera den också!
