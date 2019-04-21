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

# Clean build, copy html, save new build, run dev server on port 8000 with time-travel debugger and open in browser
rm -rf "./build" &&
mkdir "build" &&
cp -r "./src/static" "./build" &&
elm-live "src/Main.elm" --dir="./build" --open --port=8000 --pushstate --start-page "static/index.html" -- --debug --output="./build/static/bundle.js"
```

### build

```bash
cd webapp

# Clean build, copy html, save new build
rm -rf "./build" &&
mkdir "build" &&
cp -r "./src/static" "./build" &&
elm make "src/Main.elm" --optimize --output="./build/static/bundle.js"
```
