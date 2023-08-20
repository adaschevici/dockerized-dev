ARG TAG="3.11.4-bookworm"

FROM manjarolinux/base:latest

ARG UID=4242
ARG GID=998
ARG APP_USER=zero
ARG PYTHONUNBUFFERED=1
ARG PYTHONDONTWRITEBYTECODE=1
ARG PY_VERSION=3.11.4
ARG BOTTOM_VERSION=0.9.4_arm64

RUN set -eux \
  && pacman -Syyu \
  && pacman -S --noconfirm base-devel \
  &&  pacman -Syu --noconfirm neovim git nodejs go npm lazygit bottom  tmux \
  python-pip ripgrep jq yq fish fisher gnu-netcat net-tools lsof sudo pyenv

RUN set -eux \
  # && groupadd --system --gid ${GID} "${APP_USER}" \
  && useradd --system \
  --uid ${UID} \
  --user-group \
  # --groups "${APP_USER}" \
  --create-home \
  --home-dir /home/zero \
  --shell /usr/bin/fish \
  "${APP_USER}"
#
#
#
RUN set -eux \
  && echo "${APP_USER}:superSecurePassword" | chpasswd \
  && usermod --append --groups wheel "${APP_USER}" \
  && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && usermod --shell /bin/fish ${APP_USER}
# #
# # RUN wget https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz \
# #   && tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
# #
# # ENV PATH="${PATH}:/usr/local/go/bin"
# #
# #
# # RUN usermod -aG sudo ${APP_USER}
# # RUN echo 'zero:superSecurePassword' | chpasswd
ENV TZ UTC
# # RUN ls /usr/share/
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# #
# #
WORKDIR /home/${APP_USER}
USER "${APP_USER}"
ENV PATH="${PATH}:/home/zero/.local/bin"
#
RUN fisher install jethrokuan/z
RUN git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
RUN pyenv install ${PY_VERSION} \
  && /home/zero/.pyenv/versions/${PY_VERSION}/bin/python -m venv .venv

ENV PATH="/home/${APP_USER}/.venv/bin:$PATH"
RUN  pip install --upgrade pip \
  && pip install poetry prefect prefect-dask dask[dataframe] \
  && prefect config set PREFECT_API_DATABASE_CONNECTION_URL="postgresql+asyncpg://postgres:superSecurePassword@prefect-pg:5442/prefect"
# RUN pip install poetry prefect prefect-dask dask[dataframe] \
