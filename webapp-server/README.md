# webapp-server

## Docker build

```bash
# build with docker (first tag is latest, and second tag is commit hash)
bash -c 'docker build -t goldenfoil/platform.webapp-server:latest -t goldenfoil/platform.webapp-server:$(git log -1 --pretty=%h) .'

docker push goldenfoil/platform.webapp-server

# run with docker (use latest unless have a specific need)
docker run -p 11001:11001 goldenfoil/platform.webapp-server:latest
```

## Requests

```bash
# static file
curl "http://localhost:11001/index.html"

```