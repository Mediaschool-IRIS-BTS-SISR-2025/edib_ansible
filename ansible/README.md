Guide de déploiement Ansible

Prérequis sur la machine de contrôle (où tu lances ansible):
- Ansible installé (`pip install ansible`) ou via apt/yum.

Prérequis côté cible:
- SSH access + privilèges `sudo` pour l'utilisateur défini dans l inventory.

Utilisation rapide (test local):

```bash
# depuis la racine du dépôt
cd ansible
ansible-playbook -i inventory.ini deploy.yml
```

Notes:
- Le playbook installe git, python3-venv, docker.io, clone le repo sur la cible, exécute `deploy.sh` (qui crée le venv et active le service systemd) puis build & run le conteneur frontend sur le port `8080`.
- Si tu veux utiliser hosts distants, modifie `inventory.ini` avec l'adresse et méthode de connexion.
