# Build elm
FROM goldenfoil/builder-elm-0.19-node-12-with-cache:latest

WORKDIR /home/node/app
ADD . /home/node/app
RUN rm -rf "./build" && mkdir "build" && cp -r "./src/static" "./build" && elm make "src/Main.elm" --optimize --output="./build/static/bundle.js"
