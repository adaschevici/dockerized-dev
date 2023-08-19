FROM alpine:latest

ARG UID=998
ARG GID=998
ARG APP_USER=zero
ARG PYTHONUNBUFFERED=1
ARG PYTHONDONTWRITEBYTECODE=1
ARG CONTAINER_SUDO_PASSWORD=${CONTAINER_SUDO_PASSWORD}


RUN set -eux \
  && addgroup --system --gid ${GID} "${APP_USER}" \
  && adduser --system \
  --uid ${UID} \
  --gecos '' \
  --ingroup "${APP_USER}" \
  --home /home/zero \
  --shell /bin/bash \
  "${APP_USER}"


RUN apk add bash git lua nodejs npm lazygit bottom python3 py-pip python3-dev go \
  neovim ripgrep alpine-sdk sudo jq netcat-openbsd net-tools iproute2 lsof \
  libffi-dev libffi tzdata tmux --update

RUN echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel
RUN adduser ${APP_USER} wheel
RUN echo 'zero:superSecurePassword' | chpasswd
ENV TZ UTC
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone



USER "${APP_USER}"
ENV PATH="${PATH}:/home/zero/.local/bin"

RUN git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
RUN pip install poetry prefect prefect-dask dask[dataframe] \
  && prefect config set PREFECT_API_DATABASE_CONNECTION_URL="postgresql+asyncpg://postgres:superSecurePassword@prefect-pg:5442/prefect"
