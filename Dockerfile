FROM nginx:1.19.10-alpine

RUN mkdir -p /frontend

COPY ./05-set-env.sh /docker-entrypoint.d/05-set-env.sh
RUN chmod +x /docker-entrypoint.d/05-set-env.sh

COPY ./nginx.conf /etc/nginx/templates/default.conf.template

COPY ./dist /frontend
