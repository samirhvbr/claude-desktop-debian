# claude-desktop-debian (fork samirhvbr) — Estado e Continuidade

> Notas de continuidade do fork (ler primeiro). Iniciado em **24/06/2026**.

## O que é

Fork de **`aaddrick/claude-desktop-debian`** — empacota o **Claude Desktop para Linux**
(`.deb`/AppImage). Mantido sob a conta **`samirhvbr`**.

Objetivo do fork: **a definir** (customizar/rebrand? correção p/ PR? só manter o build no
Debian Trixie?). Atualizar aqui quando decidido.

## Git / remotes

| Remote | URL | Push |
|--------|-----|------|
| `origin` | `git@github.com:samirhvbr/claude-desktop-debian.git` (seu fork) | ✓ |
| `upstream` | `git@github.com:aaddrick/claude-desktop-debian.git` (original) | **desabilitado** |

- Branch de trabalho: **`master`** (criada a partir de `main`).
- `main` segue espelhando o upstream.
- Sincronizar com o original: `git fetch upstream && git merge upstream/main` na `master`.

## Convenções deste fork

- **Commits:** `versão - comentário` (ex.: `0.1.0 - ajusta build`). Versão lida de
  `version.md`. Mensagens em **pt-BR**. (Documentado também no README.)
- **`version.md`:** incrementar a cada feature/mudança relevante (Z+1).
- **`.claude/`:** perfis de modelo Opus/Fable em `settings.json` + templates `json-*`
  (ver `.claude/README.md`). **Coexiste** com o `.claude/` do upstream
  (agents/hooks/skills/settings.local.json) — não removi nada deles.

## Build (do upstream)

- `./build.sh` gera o pacote (`.deb`/AppImage); ver `README.md`/`docs/` do projeto.
- Testes em `tests/` (bats). Há flake Nix (`flake.nix`).
- Plataforma alvo do Samir: Debian Trixie (Gnome).

## Próximos passos

1. Definir o objetivo do fork (atualizar a seção "O que é").
2. (Opcional) Buildar e validar o `.deb` localmente no Trixie.
