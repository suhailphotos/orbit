#!/bin/bash

# Only set the Cloudflare API tokens if they are not already set in the environment

# For suhail.tech
if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_TECH" ]; then
  export CLOUDFLARE_API_TOKEN_SUHAIL_TECH="4Ng9kIGPI_M2LxmmJ_3MUAhRzWkS99wehU2pUA0j"
fi

# For suhail.life
if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_LIFE" ]; then
  export CLOUDFLARE_API_TOKEN_SUHAIL_LIFE="IlOLyKeO9p1zl-ei_lQGTnFOITxOlIS7JuK6wdvX"
fi

# For suhail.photos
if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS" ]; then
  export CLOUDFLARE_API_TOKEN_SUHAIL_PHOTOS="Kxco5ZSvTpqVQwyBwBAmU8ekCYgJqI0trQ488n-d"
fi

# For suhail.art
if [ -z "$CLOUDFLARE_API_TOKEN_SUHAIL_ART" ]; then
  export CLOUDFLARE_API_TOKEN_SUHAIL_ART="7km60lCSMETMqh2M6S_11jb3P9H-p48V0MjmREwM"
fi
