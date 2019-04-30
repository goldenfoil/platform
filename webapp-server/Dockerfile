# Build elm
FROM goldenfoil/builder-elm-0.19-node-12-with-cache:latest AS elm-builder

WORKDIR /home/node/app
ADD ./webapp /home/node/app
RUN rm -rf "./build" && mkdir "build" && cp -r "./src/static" "./build" && elm make "src/Main.elm" --optimize --output="./build/static/bundle.js"

# Build haskell
FROM goldenfoil/haskell-stack-builder-no-postgres-lts-11-14:latest AS builder
WORKDIR /app
ADD . /app

RUN stack setup
RUN stack build --copy-bins

# Run
FROM ubuntu:19.04

COPY --from=builder /root/.local/bin/webapp-server-exe /app/webapp-server-exe
COPY --from=elm-builder /home/node/app/build/static /app/static

WORKDIR /app

EXPOSE 11001

CMD ["/app/webapp-server-exe"]
