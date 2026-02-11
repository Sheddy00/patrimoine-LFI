# Lancement de Patrimoine

## Méthode 1 — Exécution directe

### Étape 1 : Réinitialiser le dossier local (optionnel)
À utiliser si tu veux repartir de zéro.  
Si tu penses que ton fichier `.jar` fonctionne déjà correctement, tu n’as **pas besoin de le supprimer**.  
Le script te demandera lors de l’exécution si tu veux le remplacer (o/N).

```bash
bash <(curl -s https://raw.githubusercontent.com/Sheddy00/patrimoine-LFI/main/init.sh)
```

---

### Étape 2 : Télécharger les fichiers requis et lancer Patrimoine
À utiliser lors du **premier lancement** ou après une réinitialisation.

```bash
bash <(curl -s https://raw.githubusercontent.com/Sheddy00/patrimoine-LFI/main/main.sh) UserName M
```

- `UserName` : ton nom 
- `M / F` : ton sexe

---

## Méthode 2 — Exécution locale

### Étape 1 : Cloner le dépôt

```bash
git clone https://github.com/Sheddy00/patrimoine-LFI.git
cd patrimoine-LFI
```

---

### Étape 2 : Réinitialiser l’environnement (optionnel)

```bash
bash init.sh
```

---

### Étape 3 : Lancer Patrimoine

```bash
bash main.sh UserName M
```

- `UserName` : ton nom 
- `M / F` : ton sexe

---

## Informations importantes

- Assure-toi que le fichier `.jar` a bien été téléchargé.
- Si le lancement a réussi une première fois, utilise uniquement :
```bash
bash main.sh 
```
ou 
```bash
bash <(curl -s https://raw.githubusercontent.com/Sheddy00/patrimoine-LFI/main/main.sh)
```
pour **les prochains démarrages**.

- Pour changer les informations utilisateur :
  1. relance `init.sh` (sans supprimer le `.jar` s’il est fonctionnel),
  2. relance `main.sh UserName M`.
