# Har allt gått åt helvete med Holgerspexets IT-infrastruktur?

Det här dokumentet dokumenterar det man behöver veta för att återställa Holgerspexets IT-infrastruktur från total katastrof, när allt gått åt helvete.

## Om dokumentet

Det här dokumentet är rätt tekniskt och bör läsas av någon med måttliga kunskaper inom systemadministration av Linuxsystem. Men om du inte har kompetensen själv så frukta icke, hjälp finns att få. Dessutom, läser du det här dokumentet kan du knappast göra saker värre. Det här skrivs år 2019, något som kan vara värt att ha i åtanke. Tveksamt om det här någonsin kommer uppdateras. Förlåt och lycka till!

## Jag behöver hjälp.

Chilledill!

Det finns några personer och grupper man kan kontakta för att få hjälp. Systemen sattes ursprungligen upp av den dåvarande webmastern år 2019, vilket kan vara en bra startpunkt.

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

*   Dumpa in wordpressinstallationen på godtycklig server med apache och lämna till nästa ansvariga. Spring.
*   OpenProject är numera inte längre ett debpaket - paketen är döda för nya distributioner. Kör i stället den officiella
    compose-stacken via podman, se sektionen "OpenProject: deb -> compose" nedan. Om du ska återställa databas från
    den gamla debinstallationen, följ den sektionen, annars blir det gråt.
*   Ät en kaka.


# OpenProject: deb -> compose

Sedan 2026 körs OpenProject som podman-compose-stack i `/opt/openproject`
(hanterad av `insidan::openproject`, systemd-enhet `openproject.service`).
web ligger på `127.0.0.1:6000` och hocuspocus-websocketen på
`127.0.0.1:6001`, nginx (i `insidan::openproject`) tar hand om TLS och
vidarebefordran.

## Återställa data från den gamla debinstallationen (OpenProject 10.x)

Officiell guide:
`https://www.openproject.org/docs/installation-and-operations/misc/packaged-docker-migration/`

1.  Dumpa databasen som *plain SQL* (inte det binära pgdump-formatet i
    det inbyggda backup-scriptet, det spelar inte med postgres 17):

    ```
    pg_dump $(sudo openproject config:get DATABASE_URL) -x -O > openproject.sql
    ```

2.  Plocka hem hemligheten, annars ogiltigförklaras alla sessions-cookies:

    ```
    sudo openproject config:get SECRET_KEY_BASE
    # eller, på riktigt gamla installationer:
    sudo openproject config:get SECRET_TOKEN
    ```

3.  Starta stacken en gång (den seedar en tom instans), stoppa sedan
    webb-tjänsterna:

    ```
    systemctl start openproject
    systemctl stop openproject   # eller: podman-compose -f /opt/openproject/docker-compose.yml stop web worker cron seeder
    ```

4.  En dump från 10.x kan inte läggas in direkt i 17.x. Kör det officiella
    migrationsskriptet, som migrerar major version för major version:

    ```
    curl -fsSL -o migrate https://raw.githubusercontent.com/opf/openproject/dev/bin/migrate
    chmod +x migrate
    ./migrate /path/to/openproject.sql
    # -> openproject-migrated.sql.gz
    ```

5.  Lägg in databasen i db-containern:

    ```
    cd /opt/openproject
    podman-compose -f docker-compose.yml exec -T db psql -U postgres -c 'DROP DATABASE IF EXISTS openproject WITH (FORCE);'
    podman-compose -f docker-compose.yml exec -T db psql -U postgres -c 'CREATE DATABASE openproject OWNER postgres;'
    gunzip -c openproject-migrated.sql.gz | podman-compose -f docker-compose.yml exec -T db psql -U postgres -d openproject
    ```

6.  Bifogade filer ligger i volymen `opdata`, monterad som
    `/var/openproject/assets` i containrarna, under `files/`:

    ```
    podman volume ls | grep opdata
    tar -xzf attachments-<ts>.tar.gz -C <punkt-i-volym>/var/openproject/assets/files
    chown -R 1000:1000 <...>
    ```

7.  Kör klart migreringarna och starta:

    ```
    podman-compose -f docker-compose.yml run --rm seeder
    systemctl start openproject
    ```

    Om `seeder` krashloopar saknas migrationsstegen i punkt 4.

## Uppgradering i compose-världen

Bara X -> X+1 stöds officiellt; gå inte förbi 16.x på vägen till 17.x.
`TAG` i `/opt/openproject/.env` styr versionen. Kom ihåg:
`SECRET_KEY_BASE` ska aldrig ändras, alla cookies ogiltigförklaras.



En kopia av det här dokumentet finns på OpenProject-wikin. Se till att uppdatera den också!
