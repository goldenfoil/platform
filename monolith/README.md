# monolith

## Prepare

- install docker
- install docker-compose
- install postgres (`brew install postgres`)
- install haskell stack
- install watch

## Run

``` bash
# run postgres in docker
docker-compose up -d

# run server in dev mode
stack build --file-watch --exec monolith-exe

# after all... stop and remove volumes
docker-compose down -v
```

## Auxilary commands

``` bash
# watch status
watch docker-compose ps

# bonus: locate an executable file
stack exec --whereis monolith 

## clear postgres data
rm -rf ~/docker/volumes/postgres

# reset and restart DB
docker-compose down -v &&
rm -rf ~/docker/volumes/postgres &&
docker-compose up
```

## Requests

```bash

# login
curl "http://localhost:3000/api/login"\
  --header "Content-Type: application/json"\
  --request POST\
  --data '{
      "username": "username1",
      "password": "password1"
    }'

# balance
curl "http://localhost:3000/api/balance"

```


```bash
# build with docker (first tag is latest, and second tag is commit hash)
docker build -t goldenfoil/platform.monolith:latest -t goldenfoil/platform.monolith:$(git log -1 --pretty=%h) .

docker push goldenfoil/platform.monolith

# run with docker (use latest unless have a specific need)
docker run -p 3000:3000 goldenfoil/platform.monolith:latest
```
