FROM goldenfoil/haskell-stack-builder-no-postgres-lts-11-14:1 AS builder

WORKDIR /app
ADD . /app

RUN stack setup
RUN stack build --copy-bins

FROM ubuntu:19.04

COPY --from=builder /root/.local/bin/webapp-server-exe /app/webapp-server-exe

EXPOSE 11001

CMD ["/app/monolith-exe"]