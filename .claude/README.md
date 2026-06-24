# Perfis de modelo Claude Code — fork samirhvbr

Este `.claude/` **mistura dois mundos**:

- **Do upstream** (`aaddrick`): `agents/`, `hooks/`, `scripts/`, `skills/` e
  `settings.local.json` (hooks de lint/simplify). **Não mexo nesses** — vêm do projeto.
- **Deste fork** (samirhvbr): os perfis de modelo abaixo, para alternar Opus/Fable.

## Arquivos de perfil

| Arquivo | Papel |
|---------|-------|
| `settings.json` | Perfil **ativo** (versionado). Hoje = **Opus-only**. |
| `json-opus` | Template stand-by — **Opus 4.8** em tudo. |
| `json-fable5-opus` | Template stand-by — **Fable 5** + fallback Opus. |
| `json-fable5-opus-sonnet` | Template stand-by — **Fable 5** + fallback Opus → Sonnet. |

**Trocar de perfil:** copie o template por cima do ativo e reinicie o Claude Code.

```bash
cp .claude/json-fable5-opus .claude/settings.json   # ex.: passa a usar Fable 5
```

## Regras que valem lembrar

- **Effort `max` vai por env** (`CLAUDE_CODE_EFFORT_LEVEL=max`). O campo `effortLevel`
  do JSON só aceita `low/medium/high/xhigh` — `max` ali é ignorado.
- **1M é nativo** no Opus 4.8 e no Fable 5 (API Anthropic), sem flag. Não setar
  `CLAUDE_CODE_DISABLE_1M_CONTEXT`. No plano Max é incluso — usar longe do limite.
- **Fable 5 / créditos:** incluso no Max até ~22/jun/2026; depois consome créditos
  (~$10/$50 por MTok, 2× o Opus). Requer Claude Code v2.1.170+.
- **Adaptive thinking:** OFF no Opus; no Fable 5 é sempre adaptativo (a flag não tem efeito).

## Permissões (mesmo bloco nos três perfis)

- `defaultMode: plan`.
- **deny:** `rm -rf`, `git push --force/-f`, `git reset --hard`, `git clean -fd`,
  `curl|sh`/`wget|sh`, e leitura de `*.pem` / `*.key` / `.env` / `auth.json`.
- **ask:** `sudo`, `dpkg -i`, `apt`/`apt-get`, `npm install --save`.
- **allow:** read/edit/write, git read-only + `add`/`commit`/`push`, `./build.sh`,
  `node`/`npm`/`npx`, `shellcheck`, `bats`, `codespell`, `nix build`/`flake check`.

> O `settings.local.json` (do upstream) tem **precedência** e traz os hooks do projeto;
> ele fica fora dos perfis acima de propósito.
