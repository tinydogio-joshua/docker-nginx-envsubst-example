# 📦 Environment Variable String Substitution within NGINX Docker Containers

## 📁 Brief

> At times there is a need to pass environment variables into a Docker Container and use them via string replacement (substitution) within the application code. This allows for greater reuse of the Image between environments.
>
> This is a test to see how this can be done.

## Substitution within NGINX Conf

The [NGINX Docker Image](https://hub.docker.com/_/nginx) provides the ability to perform string substitution using [`envsubst`](https://linux.die.net/man/1/envsubst). They maintainers of the Image created a special `template directory` with `.template` files that will automatically perform string substitution of environment variables used within the template.

> NOTE: The scope of this integration with the `template directory` is limited to NGINX config files.

### Example

In this example `TEST_ENV="exists"` gets passed into the Container via [Docker](https://docker.com) (see commands below).

#### ⬇ Before Processing

```nginx
# NGINX Config
...

location /env {
  add_header Content-Type application/json;
  return 200 '{
    "TEST_ENV": "${TEST_ENV}"
  }';
}

...
```

#### ⬆ After Processing

```nginx
# NGINX Config
...

location /env {
  add_header Content-Type application/json;
  return 200 '{
    "TEST_ENV": "exists"
  }';
}

...
```

To make this work, references have added to the environment variables in the [`nginx.conf`](./nginx.conf) file. When the [`Dockerfile`](./Dockerfile) is built, it copies the [`nginx.conf`](./nginx.conf) file into the `templates directory` specified for the Image and appends `.template` to the file name per requirements.

## Substitution within Other Files

Due to [`envsubst`](https://linux.die.net/man/1/envsubst) returning an empty string on environment variables not found, and for the potential need to display (or not process) the strings that match the pattern used for substitution by [`envsubst`](https://linux.die.net/man/1/envsubst); we need a way to specify variables that are allowed to be process.

To do this, a feature within [`envsubst`](https://linux.die.net/man/1/envsubst) will need to be leveraged that allows specifying a list of environment variables to use. In doing so, it will ignore the rest.

A bash script can be made ([05-set-env.sh](./05-set-env.sh)) that is called when the Container boots up. This is leveraging a feature also built in to the [NGINX Docker Image](https://hub.docker.com/_/nginx). If a script is added to the `/docker-entrypoint.d/` directory and it is made executable (done in the [`Dockerfile`](./Dockerfile)), it will run on Container boot. In this case allowing us to pass in environment variables to [Docker](https://docker.com) and then using them in this script to process some files.

### Example String Substitution with `envsubst` (Limit Variables)

```bash
# From 05-set-env.sh
# Note: The first argument is a comma-delimited list.

envsubst '$TEST_ENV' < /frontend/index.html > /tmp/index.html.temp && cp -f /tmp/index.html.temp /frontend/index.html
```
### Example File Output

In this example `TEST_ENV="exists"` gets passed into the Container via [Docker](https://docker.com) (see commands below).

#### ⬇ Before Processing

```html
<!-- Sample from ./dist/index.html -->

<p>Replace Env Var: ${TEST_ENV}</p>
<p>Do Not Replace: ${FOR_DISPLAY}</p
```

#### ⬆  After Processing

```html
<!-- Sample from ./dist/index.html -->

<p>Replace Env Var: exists</p>
<p>Do Not Replace: ${FOR_DISPLAY}</p
```

## Running the Project

### Requirements

- [Docker](https://docker.com)

### Build and Run

To run the project, clone the repository, and make sure [Docker](https://docker.com) is running.

From your terminal, navigate to the project directory and run the following commands.

```bash
docker build -t nginx-envsubst .
```

```bash
docker run -it -p 8080:80 -e TEST_ENV="exists" nginx-envsubst
```

If all goes well, you will be able to see the string substitution working at the following URL's.

- [https://localhost:8080/](https://localhost:8080/)
- [https://localhost:8080/env](https://localhost:8080/env)
