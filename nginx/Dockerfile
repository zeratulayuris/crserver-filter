FROM openresty/openresty:bionic

COPY ./lualib /usr/local/openresty/lualib/v8/
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http && /usr/local/openresty/luajit/bin/luarocks install base64
RUN rm /etc/nginx/conf.d/*.conf
COPY ./storage.conf /etc/nginx/conf.d
