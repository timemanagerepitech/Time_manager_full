# === Build stage ===
FROM elixir:1.15-alpine AS build

# Install build tools and node (if you need assets)
RUN apk add --no-cache build-base git bash openssl postgresql-client

# Set environment
ENV MIX_ENV=prod
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files and deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy source code
COPY lib lib
COPY priv priv

# Compile release
RUN mix compile
RUN mix release

# === Runtime stage ===
FROM elixir:1.15-alpine AS runtime

RUN apk add --no-cache bash openssl postgresql-client

WORKDIR /app
ENV MIX_ENV=prod
ENV SHELL=/bin/bash

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/chrono_pulse ./

# Copy entrypoint script
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bin/chrono_pulse", "start"]
