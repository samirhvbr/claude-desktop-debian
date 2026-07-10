#!/usr/bin/env bash
#===============================================================================
# update.sh — atualiza o Claude Desktop (unofficial) a partir do SEU fork
#
# Fluxo: sync git (upstream -> main -> seu fork)  ->  build .deb  ->  instala
#
# Uso:
#   ./update.sh                 # sync + build + instala (padrão)
#   SYNC_FORK=0 ./update.sh     # não faz push pro seu fork (origin)
#   DO_BUILD=0  ./update.sh     # só sincroniza o git
#   DO_INSTALL=0 ./update.sh    # builda mas não instala
#
# Alternativa SEM buildar (se preferir): o repo APT unofficial ja entrega o
# mesmo pacote pronto e auto-atualizado —
#   sudo apt update && sudo apt install --only-upgrade claude-desktop-unofficial
# (nesse caso NAO use este script; veja o aviso sobre repo no fim.)
#===============================================================================
set -euo pipefail

# ---- Config -----------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRANCH="main"
# ponte gh p/ os remotes HTTPS (sem isso, fetch/push falha "could not read Username")
GIT_CRED=(-c "credential.helper=!gh auth git-credential")

SYNC_FORK="${SYNC_FORK:-1}"    # 1 = da push do main pro seu fork (origin/samirhvbr)
DO_BUILD="${DO_BUILD:-1}"      # 1 = roda ./build.sh --build deb
DO_INSTALL="${DO_INSTALL:-1}"  # 1 = instala o .deb gerado

cd "$REPO_DIR"

# ---- 1. Sync git ------------------------------------------------------------
echo "==> [1/3] Sincronizando git (upstream -> $BRANCH)"
git "${GIT_CRED[@]}" fetch --tags upstream
git switch "$BRANCH"
# --ff-only: falha de proposito se voce tiver commits locais divergentes em main
git merge --ff-only "upstream/$BRANCH"

if [[ "$SYNC_FORK" == "1" ]]; then
  echo "==> Empurrando $BRANCH pro seu fork (origin) [best-effort]"
  if ! git "${GIT_CRED[@]}" push origin "$BRANCH"; then
    echo "!! push pro fork FALHOU — seguindo mesmo assim (build/instalacao nao dependem disso)."
    echo "   Se o erro foi falta de escopo 'workflow' no token gh, habilite uma vez com:"
    echo "     gh auth refresh -h github.com -s workflow"
  fi
fi

# ---- 2. Build ---------------------------------------------------------------
if [[ "$DO_BUILD" == "1" ]]; then
  echo "==> [2/3] Buildando .deb (baixa o .deb OFICIAL da Anthropic + aplica os patches Linux)"
  # limpa .debs antigos na raiz p/ o glob de instalacao pegar so o novo
  rm -f ./claude-desktop-unofficial_*_amd64.deb ./claude-desktop_*_all.deb
  ./build.sh --build deb
else
  echo "==> [2/3] build pulado (DO_BUILD=0)"
fi

# ---- 3. Install -------------------------------------------------------------
if [[ "$DO_INSTALL" == "1" ]]; then
  deb="$(ls -t ./claude-desktop-unofficial_*_amd64.deb 2>/dev/null | head -1 || true)"
  [[ -n "$deb" ]] || { echo "ERRO: .deb nao encontrado (build falhou?)"; exit 1; }
  echo "==> [3/3] Instalando $deb"
  # dpkg -i evita o aviso de sandbox do _apt e aceita 'downgrade' do esquema de versao local;
  # o apt -f resolve qualquer dependencia que falte.
  sudo dpkg -i "$deb" || sudo apt-get -f install -y
else
  echo "==> [3/3] instalacao pulada (DO_INSTALL=0)"
fi

# ---- Estado final + avisos --------------------------------------------------
echo
echo "==> Pronto. Versao instalada:"
dpkg-query -W -f='  ${Package}  ${Version}\n' claude-desktop-unofficial 2>/dev/null || true
echo "    (checagem completa: claude-desktop-unofficial --doctor)"

# Aviso: repo APT unofficial ativo brigaria com o build local (ele serve uma
# versao MAIOR -x.y.z e o 'apt upgrade' reverteria seu build).
if [[ -f /etc/apt/sources.list.d/claude-desktop-unofficial.list ]]; then
  echo
  echo "!! ATENCAO: o repo APT 'claude-desktop-unofficial.list' esta ATIVO."
  echo "   Enquanto ele existir, 'sudo apt upgrade' vai SUBSTITUIR este build local"
  echo "   pela versao do repo. Se voce quer ficar no build-a-partir-do-fork, desative:"
  echo "     sudo mv /etc/apt/sources.list.d/claude-desktop-unofficial.list{,.disabled}"
  echo "   (ou, para nao mais buildar, apague este update.sh e use o 'apt upgrade' do repo.)"
fi
