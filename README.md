# platform

## Webapp

### Requirements

Install `elm` and `elm-live` (dev server)

```bash
yarn global add elm elm-live
```

### develop

Use [Mockoon](https://mockoon.com/) to play with `./mock_responses/platform.json` (for some reasons CORS headers could not be saved as an environment setting in Mockoon - they need to be enabled manually)

```bash
cd webapp

# Clean build, copy static assets,
# save new build,
# run dev server on port 8000 with time-travel debugger
# and open in browser
rm -rf "./build" &&
mkdir "build" &&
cp -r "./src/static" "./build" &&
elm-live "src/Main.elm" --dir="./build" --open --port=8000 --pushstate --start-page "static/index.html" -- --debug --output="./build/static/bundle.js"
```

### build

```bash
cd webapp

# Clean build, copy static assets,
# save new build,
rm -rf "./build" &&
mkdir "build" &&
cp -r "./src/static" "./build" &&
elm make "src/Main.elm" --optimize --output="./build/static/bundle.js"
```
