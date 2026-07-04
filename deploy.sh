name: Deploy GitHub Pages

on:
  push:
    branches:
      - main
      - master
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure Pages
        uses: actions/configure-pages@v5

      - name: Prepare static site
        shell: bash
        run: |
          set -euo pipefail

          if [ -f "Chatbots Entre Cerros/index.html" ]; then
            SRC="Chatbots Entre Cerros"
          elif [ -f "index.html" ]; then
            SRC="."
          else
            echo "::error::No se encontró index.html en la raíz ni en 'Chatbots Entre Cerros'."
            exit 1
          fi

          rm -rf _site
          mkdir -p _site
          rsync -a \
            --exclude ".git" \
            --exclude ".github" \
            --exclude "_site" \
            "$SRC"/ _site/

          touch _site/.nojekyll
          test -f _site/index.html
          echo "Contenido a publicar:"
          find _site -maxdepth 2 -type f | sort

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
