#!/bin/bash

# Couleurs pour les messages
BLUE="\033[38;5;081m"
GREEN="\033[0;32m"
RED="\033[38;5;167m"
NC="\033[0m" # Reset des couleurs

# Fonction pour afficher un message en bleu
print_info() {
  if [ -z $2 ]; then
    echo
  fi

  echo -e "${BLUE}$1${NC} \c"
}

# Fonction pour afficher un message en vert
print_success() {
  if [ -z $2 ]; then
    echo
  fi

  echo -e "${GREEN}$1${NC}"
}

# Fonction pour afficher un message en rouge
print_error() {
  if [ -z $2 ]; then
    echo
  fi

  echo -e "${RED}$1${NC}"
}

print_info "⌂"
echo Bienvenue dans l\'assistant de configuration de votre nouveau projet
echo

echo "Veuillez entrer l'adresse du dépôt Git ou le nom de votre projet :"
ASK=$(print_success ">" 0)
read -p "$ASK " GIT_REPO

if [ -z "$GIT_REPO" ]; then
  print_error "❌ Aucun chemin de dépôt Git ou de nom spécifié."
  exit 1
fi

if [[ "$GIT_REPO" =~ \.git$ ]]; then
  if ! git ls-remote --exit-code "$GIT_REPO" >/dev/null 2>&1; then
    print_error "❌ Le dépôt Git n'existe pas ou est inaccessible."
    exit 1
  fi

  git clone "$GIT_REPO"

  if [ $? -eq 0 ]; then
    TARGET_DIRECTORY=$(basename "$GIT_REPO" .git)
  else
    print_error "❌ Échec du clonage du dépôt Git."
    exit 1
  fi
else
  TARGET_DIRECTORY="$GIT_REPO"
  mkdir "$TARGET_DIRECTORY"
fi

print_info "→"
echo Copie des dossiers et des fichiers du template

cp -n ./vite-amidon/{.*,*} "./$TARGET_DIRECTORY"
cp -rn ./vite-amidon/{src,public,.vscode} "./$TARGET_DIRECTORY"

if [ $? -eq 0 ]; then
  print_success "✓ Le modèle a été copié"
else
  print_error "❌ Impossible de copier."
  exit 1
fi

cd "./$TARGET_DIRECTORY"

print_info "→"
echo "Installation des dépendances avec pnpm"
pnpm i
print_success "✓ Les dépendances sont installées"

print_info "→"
echo "Génération du premier commit"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi

git add .
git commit -m "Install modèle vite-amidon"

if git remote >/dev/null 2>&1; then
  git push
fi
print_success "✓ Le premier commit est validé"

print_info "→"
echo "Ouverture du projet dans VS Code"
code .
print_success "✓ Le projet est ouvert"

print_info "→"
echo "Lancement du serveur avec pnpm dev"
pnpm dev --open