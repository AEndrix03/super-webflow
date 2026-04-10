# Super WebFlow CLI

CLI e validatore per documenti `Super WebFlow Contract Language`.

## Contenuto

- `cli.js`: entrypoint CLI (`ui-validate`)
- `validator.js`: validazione schema + regole semantiche
- `validator.test.js`: test del validatore
- `base-document.js`: documento base valido per test

## Requisiti

- Node.js >= 18

## Setup

```bash
cd cli
npm install
```

## Utilizzo

```bash
# da cartella cli/
node cli.js ../spec/v1.0/examples/template.json
node cli.js ../spec/v1.0/examples/website.json

# con bin locale npm
npx ui-validate ../spec/v1.0/examples/template.json
```

## Script

```bash
# esegue la suite test
npm test

# valida gli esempi presenti in ../spec/v1.0/examples
npm run check:examples
```
