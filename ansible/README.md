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

Ansible Vault (gestion des secrets)
----------------------------------

Ce dépôt fournit un exemple de variables sensibles à placer dans `ansible/group_vars/all/vault.yml`. **Ne commite jamais** de secrets en clair.

1) Créer le fichier d'exemple (fourni) :

```
ansible/group_vars/all/vault.yml.example
```

2) Copier et chiffrer en utilisant Ansible Vault :

```bash
# depuis la racine du dépôt
cp ansible/group_vars/all/vault.yml.example ansible/group_vars/all/vault.yml
ansible-vault encrypt ansible/group_vars/all/vault.yml
```

3) Options pour exécuter le playbook avec Vault :

- Demander le mot de passe au runtime :
	```bash
	ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass
	```
- Utiliser un fichier contenant le mot de passe (moins interactif) :
	```bash
	ansible-playbook -i inventory.ini deploy.yml --vault-password-file ~/.vault_pass.txt
	```

4) Bonnes pratiques :
- Utiliser `ansible-vault edit` pour modifier les valeurs chiffrées.
- Stocker le mot de passe Vault en sécurité (ex: gestionnaire de secrets de l'école), ou utiliser un fichier protégé par des permissions strictes si nécessaire.
- Ne pas committer `vault.yml` chiffré sans informer le professeur (selon la politique de l'école), mais le commit chiffré est acceptable si le mot de passe n'est pas partagé.

Intégration avec le playbook
---------------------------

Le playbook lit automatiquement les variables dans `group_vars/all/`. Si `ansible-vault` est utilisé pour chiffrer ce fichier, il faut fournir `--ask-vault-pass` ou `--vault-password-file` lors de l'exécution du playbook.

