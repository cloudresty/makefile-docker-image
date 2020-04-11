# Base image source
FROM 		alpine:latest

# Packages to be installed
RUN 		apk add --no-cache \
				curl && \
				nginx

# Copy local files to image
COPY 		local/folder/index.html /usr/share/nginx/html

# Set the working directory
WORKDIR 	/var/www/html

# Expose container port
EXPOSE 		80

# Start supervisord service
CMD 		["nginx", "-g", "daemon off;"]

# Healthcheck to validate that everything is up and running
HEALTHCHECK --start-period=5s \
			--interval=30s \ 
			--timeout=10s \	
			--retries=3 \
		CMD curl --fail http://127.0.0.1/ || exit 1