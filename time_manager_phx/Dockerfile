# ------------- BUILD STAGE -------------
FROM elixir:1.17-alpine AS build

# needed packages
RUN apk add --no-cache build-base git nodejs npm bash

WORKDIR /app
ENV MIX_ENV=prod

# install hex/rebar
RUN mix local.hex --force && mix local.rebar --force

# copy mix files first (caches deps)
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# copy assets and build them
COPY assets assets
WORKDIR /app/assets
RUN npm install
RUN npm run build

# copy rest of the app
WORKDIR /app
COPY . .

# compile app and create digest
RUN mix compile
RUN mix phx.digest

# ------------- RUNTIME STAGE -------------
FROM elixir:1.17-alpine AS app
RUN apk add --no-cache openssl ncurses-libs bash postgresql-client

WORKDIR /app
ENV MIX_ENV=prod PORT=4000

# copy compiled app from build stage
COPY --from=build /app ./

# add entrypoint script that will wait for DB and run migrations
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 4000
CMD ["/app/entrypoint.sh"]
