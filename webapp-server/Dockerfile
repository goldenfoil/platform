# Get elm build
FROM goldenfoil/platform.webapp:latest AS elm-build

# Build haskell
FROM goldenfoil/haskell-stack-builder-no-postgres-lts-11-14:latest AS builder
WORKDIR /app
ADD . /app

RUN stack setup
RUN stack build --copy-bins

# Run
FROM ubuntu:19.04

COPY --from=builder /root/.local/bin/webapp-server-exe /app/webapp-server-exe
COPY --from=elm-build /home/node/app/build/static /app/static

WORKDIR /app

EXPOSE 11001

CMD ["/app/webapp-server-exe"]
