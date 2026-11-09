# Projet Messagerie — Organisations A et B

Infrastructure de messagerie entre deux organisations : Tailscale, DNS, SMTP, IMAP, TLS et filtrage antispam/antivirus.

## État du projet
- Organisation A : configurée et tests principaux du Module 9 exécutés.
- Organisation B : à réaliser par le binôme.
- Les deux nœuds Tailscale actuels sont des conteneurs Docker sur le même hôte physique.

## Services
- tailscale-a : réseau Organisation A
- tailscale-b : second nœud de test
- bind9 : DNS Organisation A
- mail-a : Postfix / Dovecot
- filter-a : Amavis / SpamAssassin / ClamAV

## Tests
Depuis la racine du dépôt :
- docker compose config -q
- docker compose ps
- bash scripts/module9-check.sh
- bash scripts/test-all.sh

Certificat public CA : certs/ca/organisation-root-ca.crt

Ne jamais versionner de clés privées, mots de passe ou fichiers .env.

## Documentation
- Journal : docs/journal.md
- Handover : docs/HANDOFF-ORGANISATION-A.md
- Preuves : docs/preuves/

Branche : feature/spam-antivirus
