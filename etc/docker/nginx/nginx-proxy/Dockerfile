FROM jwilder/nginx-proxy

COPY nginx.conf /etc/nginx/nginx.conf
RUN { \
      echo 'proxy_connect_timeout 1200s;'; \
      echo 'proxy_send_timeout 1200s;'; \
      echo 'proxy_read_timeout 1200s;'; \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100m;'; \
      echo 'client_header_timeout 3000;'; \
      echo 'client_body_timeout 3000;'; \
      echo 'fastcgi_read_timeout 3000;'; \
      echo 'fastcgi_connect_timeout 600;'; \
      echo 'fastcgi_send_timeout 600;'; \
      echo 'fastcgi_buffers 8 128k;'; \
      echo 'fastcgi_buffer_size 128k;'; \
      echo 'keepalive_timeout 3000;'; \
    } > /etc/nginx/conf.d/my_proxy.conf
