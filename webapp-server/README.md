# webapp-server

## Build and publish

```bash
# Build and tag
# first tag is latest, and second tag is commit hash
bash -c 'docker build -t goldenfoil/platform.webapp-server:latest -t goldenfoil/platform.webapp-server:$(git log -1 --pretty=%h) .'

# Push to docker hub
docker push goldenfoil/platform.webapp-server
```

## Useful commands

```bash
# rebuild both webapp and webapp server and restart them
docker-compose build webapp webapp-server && docker-compose up -d

# request a static file
curl "http://localhost:11001/index.html"
```
