# platform

## Webapp

### Requirements

Install `elm` and `elm-live` (dev server)

```bash
yarn global add elm elm-live
```

### develop

```bash
cd webapp

# Run dev server on port 8000 with time-travel debugger and open in browser
elm-live --port=8000 "src/Main.elm" --open -- --debug
```

### build

```bash
cd webapp

# Clean build, copy html, save new build
rm -rf "./build" && mkdir "build" && cp "./src/index.html" "./build/index.html" && elm make src/Main.elm --optimize --output="./build/bundle.js"
```
