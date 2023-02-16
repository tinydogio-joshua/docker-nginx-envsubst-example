# 📦 Environment Variable String Substitution within NGINX Docker Container

> _Long title, right?_ 😀

## 📁 Brief

> We have a need to pass in environment variables into a Docker Container and use them to do some string replacement (substitution) within the application code. This allows for greater reuse of the container between environments.
> 
> This is a test to see how this can be done.

## Substitution within NGINX Conf

The [NGINX Docker Image](https://hub.docker.com/_/nginx) provides the ability to do string substitution using [`envsubst`](https://linux.die.net/man/1/envsubst). They have wired it up so that a special `template directory` with `.template` files that will automap to environmental variables used within the file.

> NOTE: The scope of this integration with the `template directory` is limited to NGINX config files.

### Example

In this example `TEST_ENV="exists"` gets passed into the container.

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

#### ⬆  After Processing

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

To make this work, we have added references to the environment variables in our [`nginx.conf`](./nginx.conf) file. When the [`Dockerfile`](./Dockerfile) is built, it copies the [`nginx.conf`](./nginx.conf) file into the `templates directory` specified for the container and appends `.template` to the file name per requirements.

## Substitution within Other Files

Due to [`envsubst`](https://linux.die.net/man/1/envsubst) returning an empty string on environmental variables not found, and our need for template literals within the same that use the same format as environmental variables, we need a way to specify variables that are allowed to be process.

To do this we leveraged a feature within [`envsubst`](https://linux.die.net/man/1/envsubst) that allows specifiying a list of environmental variables to use. In doing so, it will ignore the rest.

To get this to run, we wrote a bash script ([05-set-env.sh](./05-set-env.sh)) that is called when the container boots up. This is leveraging a feature also built in to the NGINX Container. If you add a script to the `/docker-entrypoint.d/` director and make it executable (done in the [`Dockerfile`](./Dockerfile)), it will run on container boot. In this case allowing us to pass in environmental variables to Docker and then using them in this script to process some files.

### Example String Substitution with `envsubst` (Limit Variables)

```bash
# From 05-set-env.sh
# Note: The first argument is a comma-delimited list.

envsubst '$TEST_ENV' < /frontend/index.html > /tmp/index.html.temp && cp -f /tmp/index.html.temp /frontend/index.html
```
### Example File Output

In this example `TEST_ENV="exists"` gets passed into the container.

#### ⬇ Before Processing

```html
<!-- Sample from ./dist/index.html -->

<p>Replace Env Var: ${TEST_ENV}</p>
<p>Do Not Replace Template Literal: ${TEMPLATE_LITERAL}</p
```

#### ⬆  After Processing

```html
<!-- Sample from ./dist/index.html -->

<p>Replace Env Var: exists</p>
<p>Do Not Replace Template Literal: ${TEMPLATE_LITERAL}</p
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

If all goes well, you should be able to see the string substitution working at the following URL's.

- [https://localhost:8080/](https://localhost:8080/)
- [https://localhost:8080/env](https://localhost:8080/env)
