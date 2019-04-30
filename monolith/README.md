# monolith

## Build and publish

```bash
# Build and tag
# first tag is latest, and second tag is commit hash
bash -c 'docker build -t goldenfoil/platform.monolith:latest -t goldenfoil/platform.monolith:$(git log -1 --pretty=%h) .'

# Push to docker hub
docker push goldenfoil/platform.monolith
```

## Local development

- install postgres (`brew install postgres`)
- install haskell stack

```bash
# run server in dev mode
stack build --file-watch --exec monolith-exe
```

## Useful commands

```bash
# locate an executable file on host
stack exec --whereis monolith

## clear postgres data
rm -rf ~/docker/volumes/postgres

# reset and restart DB
docker-compose down -v &&
rm -rf ~/docker/volumes/postgres &&
docker-compose up

# login request
curl "http://localhost:3000/api/login"\
  --header "Content-Type: application/json"\
  --request POST\
  --data '{
      "username": "username1",
      "password": "password1"
    }'

# balance request
curl "http://localhost:3000/api/balance"
```
