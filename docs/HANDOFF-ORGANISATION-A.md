# Handover — Organisation A vers Organisation B

## 1. État transmis
Organisation A est configurée et les principaux tests du Module 9 ont été exécutés. Organisation B reste à réaliser par le binôme. Le Module 10 est hors périmètre de ce handover.

## 2. Architecture actuelle

| Service | Fonction |
|---|---|
| tailscale-a | Nœud Tailscale A |
| tailscale-b | Second nœud Tailscale de test |
| bind9 | DNS autoritaire A |
| mail-a | Postfix et Dovecot |
| filter-a | Amavis, SpamAssassin et ClamAV |

Les services DNS, mail et filtrage partagent le réseau de tailscale-a via network_mode: service:tailscale-a.

- Adresse Tailscale A : 100.104.64.49
- Adresse Tailscale B : 100.79.54.119
- Domaine A : organisation-a.test
- Serveur mail : mail.organisation-a.test

## 3. Réalisations vérifiées

### Réseau et DNS
- Ping Tailscale entre A et B réussi.
- Résolution DNS depuis le nœud B vérifiée.
- Enregistrements A, MX et NS vérifiés.

### Messagerie et TLS
- Postfix configuré pour SMTP.
- Dovecot configuré pour IMAP sécurisé.
- SMTP submission sur le port 587 avec STARTTLS et AUTH après TLS.
- IMAPS sur le port 993.
- Certificat serveur vérifié avec le certificat CA du projet.

### Sécurité
- Relais SMTP non authentifié vers un domaine externe refusé : 554 5.7.1 Relay access denied.
- spamassassin --lint exécuté sans erreur.
- GTUBE détecté comme spam.
- EICAR détecté et mis en quarantaine par Amavis/ClamAV.

Attention : la transaction SMTP initiale du test EICAR a été acceptée. La preuve montre la détection et la mise en quarantaine, pas un rejet SMTP explicite ni un bounce.

## 4. Preuves
Les résultats sont conservés dans docs/preuves/. Fichiers principaux :
- tailscale-ping.txt et tailscale-status.txt
- dns-cross-node.txt et module9-dns.txt
- module9-infrastructure.txt et module9-security.txt
- test-tls-port25.txt, test-tls-port587.txt, test-tls-port993.txt
- test-smtp-auth.txt et test-imaps-auth.txt
- gtube-spam-detection.txt
- eicar-detection-quarantine.txt
- module9-final-report.txt

Attention : eicar-smtp-rejection.txt a un nom trompeur ; son contenu indique que la transaction SMTP initiale a été acceptée.

## 5. Certificats et secrets
Le certificat public CA est versionné dans certs/ca/organisation-root-ca.crt et peut être partagé pour vérifier le certificat serveur A.

La clé privée CA reste hors du dépôt. Ne jamais ajouter à Git de clés privées, mots de passe, fichiers .env, comptes Dovecot ou données de boîtes mail.

Les scripts de test utilisent le certificat public versionné.

## 6. Travail du binôme — Organisation B
1. Préparer le nœud Tailscale de B.
2. Vérifier la connectivité entre A et B.
3. Définir le domaine DNS de B et ses enregistrements.
4. Déployer et configurer les services mail de B.
5. Préparer les certificats et la confiance TLS.
6. Configurer les échanges inter-organisations.
7. Tester DNS, SMTP, IMAP, authentification et échanges de mails.
8. Ajouter les preuves des tests dans docs/preuves/.

Le binôme doit définir et documenter ses propres domaines, adresses, utilisateurs et paramètres. Ne pas réutiliser automatiquement les paramètres de A.

## 7. Limitation de l’environnement
Les deux nœuds Tailscale actuels sont des conteneurs Docker sur le même hôte physique. Les tests prouvent la communication entre conteneurs, mais pas encore entre deux machines physiques ou deux VM indépendantes.

Des avertissements Tailscale liés à l’environnement conteneurisé (modules noyau/iptables) ont été observés. Les pings entre les nœuds ont néanmoins réussi.

Si le cahier des charges exige deux machines distinctes, l’architecture devra être adaptée ou cette limite explicitement présentée.

## 8. Commandes utiles
Depuis la racine du dépôt :
- docker compose config -q
- docker compose ps
- bash scripts/module9-check.sh
- bash scripts/test-all.sh
- docker build -t projet-messagerie-tester:1.0 ./scripts/tester

## 9. Git
Branche de travail : feature/spam-antivirus.
Avant de commencer les modifications de B, récupérer la dernière version de la branche et vérifier les changements. Ne jamais pousser de secrets ou de clés privées.

---
État transmis : Organisation A configurée et tests principaux du Module 9 exécutés, avec les limitations ci-dessus documentées. Organisation B reste à réaliser.
