# Platform

## How to run

1. Install [Docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/)

1. Run all services: `docker-compose up -d`

1. Open [localhost:11001/index.html](http://localhost:11001/index.html)

## Development instructions per service:

- [monolith](./monolith/README.md)
- [webapp-server](./webapp-server/README.md)
- [webapp](./webapp/README.md)

## Useful commands

```bash
# list running containers
docker-compose ps

# view logs
docker-compose logs -f

# stop all services and remove volumes
docker-compose down -v
```
