# webapp

## Build and publish

```bash
# Build and tag
# first tag is latest, and second tag is commit hash
bash -c 'docker build -t goldenfoil/platform.webapp:latest -t goldenfoil/platform.webapp:$(git log -1 --pretty=%h) .'

# Push to docker hub
docker push goldenfoil/platform.webapp
```

## Local development

```bash
# Install elm
# For mac os and windows use official binaries, not NPM.
# For Linux better use yarn instead of npm, because it does not require special access
yarn global add elm

# Install `elm-live` (dev server)
yarn global add elm-live
```

```shell
cd webapp

# Clean build, copy static assets,
# save new build,
# run dev server on port 8000 with time-travel debugger
# and open in browser
rm -rf "./build" &&
mkdir "build" &&
cp -r "./src/static" "./build" &&
elm-live "src/Main.elm" --dir="./build/static" --open --port=8000 --pushstate --start-page "index.html" -- --debug --output="./build/static/bundle.js"
```

### Mock API endpoints

Use [Mockoon](https://mockoon.com/) to play with `./mock_responses/platform.json` (for some reasons CORS headers could not be saved as an environment setting in Mockoon - they need to be enabled manually)
