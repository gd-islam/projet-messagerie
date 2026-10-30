## Étape 1 — Mise en place de Tailscale

- Déploiement de deux nœuds distincts avec Docker Compose.
- Connexion des deux nœuds au même réseau privé Tailscale.
- Vérification de la connectivité dans les deux sens avec ping.
- Vérification de l'état du réseau avec tailscale status.
- Les communications observées utilisent une connexion directe
  via les adresses 172.19.0.x, sans relais DERP.

### Interprétation

Les deux nœuds communiquent correctement.
La connexion directe est cohérente avec notre architecture :
les deux conteneurs fonctionnent sur le même PC et utilisent
le réseau interne Docker.

### Étape suivante

Déploiement du serveur DNS autoritatif Bind9 pour
organisation-a.test.
