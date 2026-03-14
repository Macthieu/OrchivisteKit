# Standards Suite Orchiviste/Muni

Ce document definit les standards communs de la suite documentaire.

## 1) Conventions de repository

- Un repository par outil; aucun monolithe.
- `Orchiviste` = cockpit/hub uniquement.
- Les traitements metier restent dans les outils `Muni*`.
- Chaque outil doit fonctionner seul (CLI/app) et via Orchiviste.
- Baseline technique cible: Swift 6 / macOS 14.
- Licence obligatoire: GNU GPL v3.0.

Structure minimale recommandee:

```text
<Repo>/
  Package.swift
  Sources/
    <Repo>Core/
    <Repo>CLI/
  Tests/
  docs/
  .github/workflows/
  README.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  SECURITY.md
```

## 2) Conventions GitHub

- Branche principale: `main`.
- Pull request obligatoire pour merge sur `main`.
- CI obligatoire (`swift build` + `swift test`).
- Releases basees sur tags SemVer `vX.Y.Z`.
- Templates recommandes: bug report, feature request, pull request.
- Fichiers minimaux: `README`, `CHANGELOG`, `CONTRIBUTING`, `LICENSE`, `SECURITY`.

## 3) Conventions SemVer

- Format des tags: `vMAJOR.MINOR.PATCH`.
- Pre-releases: `-alpha.N`, `-beta.N`, `-rc.N`.
- `PATCH`: correctif compatible.
- `MINOR`: ajout compatible.
- `MAJOR`: rupture de contrat.
- Changement notable = entree `CHANGELOG`.

## 4) Conventions UI (suite)

- Utiliser des tokens partages (couleurs, espacements, rayons, etats).
- Etats UI standards: `idle`, `running`, `needs_review`, `success`, `warning`, `error`.
- Accessibilite: labels explicites, navigation clavier, contrastes suffisants.
- Cohesion du parcours: selection -> options -> execution -> resultats -> export.
- La logique metier reste dans Core/services, pas dans les vues.

## 5) Conventions de logs

Log structure recommande:

- `timestamp` (ISO-8601 UTC)
- `level` (`debug|info|warning|error`)
- `message`
- `correlation_id` (si disponible)
- `request_id` (si disponible)
- `tool`
- `metadata` (objet libre)

Regles:

- Pas de secrets dans les logs.
- Erreurs attendues: niveau `warning` ou `info` selon contexte.
- Erreurs bloquantes: niveau `error` avec code stable.

## 6) Contrat CLI JSON (integration V1)

Mode d'integration V1: execution locale via CLI avec echange JSON.

Commande type:

```bash
<tool-cli> run --request /path/request.json --result /path/result.json
```

### Valeurs autorisees de `status`

Les statuts autorises dans le contrat commun sont:

- `queued`
- `running`
- `succeeded`
- `failed`
- `needs_review`
- `cancelled`
- `not_implemented`

`not_implemented` est autorise explicitement pour les squelettes outilles en attente de logique metier.

## 7) Schemas canoniques minimaux

Schemas JSON references:

- `docs/contracts/tool-request.schema.json`
- `docs/contracts/tool-result.schema.json`
- `docs/contracts/tool-error.schema.json`
- `docs/contracts/progress-event.schema.json`
- `docs/contracts/artifact-descriptor.schema.json`
