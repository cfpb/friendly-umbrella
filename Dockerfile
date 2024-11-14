FROM python:3.8-alpine

# Ensure that the environment uses UTF-8 encoding by default
ENV LANG en_US.UTF-8

# Disable pip cache dir
ENV PIP_NO_CACHE_DIR 1

# Allow pip install as root
ENV PIP_ROOT_USER_ACTION ignore

# We don't need Python to write out byte code
ENV PYTHONDONTWRITEBYTECODE 1

# Stops Python default buffering to stdout, improving logging to the console
ENV PYTHONUNBUFFERED 1

# Define the application home directory
ENV APP_HOME /code

# Create a non-root user for the container
ARG USERNAME=app
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN addgroup --gid $USER_GID $USERNAME &&\
    adduser --uid $USER_UID --ingroup $USERNAME --disabled-password --home $APP_HOME $USERNAME

# Set the working directory and copy the code
WORKDIR $APP_HOME
COPY --chown=$USERNAME:$USERNAME . .

# Install our dependencies
RUN set -eux; \
    apk add --no-cache --virtual .backend-deps \
        gcc \
        linux-headers \
        musl-dev \
        pkgconf \
        python3-dev; \
    pip install -U pip; \
    pip install .; \
    apk del .backend-deps

# Run the application with the user we created
USER $USERNAME

# Expose the port
EXPOSE 8000

# Run the application
CMD gunicorn friendly_umbrella.wsgi:application -b :8000
