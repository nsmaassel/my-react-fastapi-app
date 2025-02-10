#!/bin/sh

# Debug: Show environment variables
echo "Runtime environment variables:"
echo "VITE_API_URL=${VITE_API_URL}"

# Recreate config file
echo "window.env = {" > /usr/share/nginx/html/env.js

# Add environment variables with proper JavaScript string syntax
if [ -n "${VITE_API_URL}" ]; then
    echo "  VITE_API_URL: '${VITE_API_URL}'," >> /usr/share/nginx/html/env.js
    echo "Setting VITE_API_URL to: ${VITE_API_URL}"
else
    echo "Warning: VITE_API_URL is not set!"
fi

echo "};" >> /usr/share/nginx/html/env.js

# Verify the contents of env.js
echo "Contents of env.js:"
cat /usr/share/nginx/html/env.js

# Execute CMD
exec "$@"