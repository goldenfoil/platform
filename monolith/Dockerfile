# Раннер без postgres
FROM goldenfoil/haskell-stack-builder-no-postgres-lts-11-14:1 AS builder

WORKDIR /app
ADD . /app

RUN stack setup
RUN stack build --copy-bins

FROM haskell:8.2.2

COPY --from=builder /root/.local/bin/monolith-exe /app/monolith-exe

EXPOSE 3000

CMD ["/app/monolith-exe"]