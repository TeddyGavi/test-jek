#!/bin/sh
# "#################################################"
# "This file is based on a Gist, located here:"
#    "https://gist.github.com/BillRaymond/db761d6b53dc4a237b095819d33c7332#file-post-run-txt"
# "Steps to finalize a Docker image to use GitHub Pages and Jekyll"
# "Instructions:"
# " 1. Open a terminal window and cd into your repo"
# " 3. Run the script, like this:
# "      sh script-name.sh"
# "#################################################"

# Define color codes
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[36m'
reset='\033[0m' # Reset color

# Display current Ruby version
echo "Ruby version"
ruby -v

# Display current Jekyll version
echo "Jekyll version"
jekyll -v

# Add a blank Jekyll site
# echo "Create a new Jekyll site"
# NOTE: Want a blank site? Uncomment the following line
#       and also comment out the next "Add Jekyll site" lines
# echo "Create a new Jekyll blank site"
# jekyll new . --skip-bundle --force --blank
blank_site=false
read -p "Would you like to create a blank Jekyll site? Without a theme that is? (y/n): " blank_site 
if [ "$blank_site" != 'y' ] && [ "$blank_site" != 'Y' ]; then
    # Add Jekyll site
    echo "Creating a new Jekyll site with the default theme ${green}Minima${reset}"
    jekyll new . --force --skip-bundle
    else
    #New blank site
    echo "Create a new ${green}Jekyll${reset} blank site"
    # init bundle to generate GemFile 
    bundle init
    jekyll new . --force --skip-bundle --blank
fi


# Jekyll creates a .gitignore file, but it can be improved, so delete it
# NOTE: Comment out the following lines if you want to keep the original .gitignore file 
echo "Deleting default .gitignore file Jekyll generated"
GITIGNORE=.gitignore
if test -f "$GITIGNORE"; then
    rm $GITIGNORE
fi

# Create a new .gitignore file and populate it
# NOTE: Comment out the following lines if you want to keep the original .gitignore file
echo "Create a new .gitignore file"
touch $GITIGNORE

# Populate the new .gitignore file
# NOTE: Comment out the following lines if you want to keep the original .gitignore file
echo "Populating the .gitignore file"
echo "_site/" >> $GITIGNORE
echo ".sass-cache/" >> $GITIGNORE
echo ".jekyll-cache/" >> $GITIGNORE
echo ".jekyll-metadata" >> $GITIGNORE
echo ".bundle/" >> $GITIGNORE
echo "vendor/" >> $GITIGNORE
echo "**/.DS_Store" >> $GITIGNORE

# Configure Jekyll for GitHub Pages
echo "Add GitHub Pages to the bundle"
bundle add "github-pages" --group "jekyll_plugins" --version 228

# webrick is a technology that has been removed by Ruby, but needed for Jekyll
echo "Add required webrick dependency to the bundle"
bundle add webrick

# Install and update the bundle
echo "bundle install"
bundle install
echo "bundle update"
bundle update

# Modify the _config.yml file
# baseurl: "/github-pages-with-docker" # the subpath of your site, e.g. /blog
# url: "https://YourGitHubUserName.github.io" # the base hostname & protocol for your site, e.g. http://example.com

# Initialize Git and add a commit message
# Uncomment these lines to init git
# git init -b main
# git add -A
# git commit -m "initial commit"

# Get the presumed value for the baseurl (this folder name)
var=$(pwd)
BASEURL="$(basename $PWD)"

gh_action=false
gh_folder=".github/workflows"
gh_yml="jekyll-to-ghpages.yml"
echo ""
echo "To deploy your site, with Github Actions you need to enable deploy from action."
echo "Go to your repo on ${green}Github${reset}"
echo "From the header select ${cyan}Settings${reset} -> ${green}Pages (from sidebar)${reset} Then:"
echo "${green}Under build and deploy select${reset} ${cyan}From Action${reset} ${green}(BETA)${reset}"
echo "${green}Finally${reset} return ${cyan}here!${reset}"
echo ""
read -p "Do you want to create a Github workflow that will automatically deploy from an action? (y/n): " gh_action
if [ "$gh_action" = 'y' ] || [ "$gh_action" = 'Y' ]; then  
    echo "Creating GitHub Action..."
    mkdir -p "$gh_folder"
    touch "$gh_folder/$gh_yml"
    # add contents
    cat <<EOF > "$gh_folder/$gh_yml"
# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

# Sample workflow for building and deploying a Jekyll site to GitHub Pages
name: Deploy Jekyll site to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["main"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  # Build job
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Setup Ruby
        uses: ruby/setup-ruby@55283cc23133118229fd3f97f9336ee23a179fcf # v1.146.0
        with:
          ruby-version: '3.1' # Not needed with a .ruby-version file
          bundler-cache: true # runs 'bundle install' and caches installed gems automatically
          cache-version: 0 # Increment this number if you need to re-download cached gems
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v3
      - name: Build with Jekyll
        # Outputs to the './_site' directory by default
        run: bundle exec jekyll build --baseurl "\${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production
      - name: Upload artifact
        # Automatically uploads an artifact from the './_site' directory by default
        uses: actions/upload-pages-artifact@v1

  # Deployment job
  deploy:
    environment:
      name: github-pages
      url: \${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
EOF
    echo "YAML file created at $gh_folder/$gh_yml"
fi

# Done! Provide informative text for next steps
echo ""
echo "\033[1;32mDone configuring your Jekyll site! Here are the next steps:\033[00m"
echo "1. Modify the baseurl and url in your _config.yml file:"
echo "    The baseurl is \033[1m/$BASEURL\033[0m"
echo "    The url is \033[1mhttps://YourGitHubUsername.github.io\033[0m"
echo "2. Run Jekyll for the first time on your computer:"
echo "    \033[1mbundle exec jekyll serve --livereload\033[0m"
echo "    Look for the site at port 4000 (ex http://127.0.0.1:4000/)"
echo "    After testing, type CONTROL+C to stop Jekyll"
echo "3. Commit all your changes to Git locally"
echo "4. Publish your site to a new GitHub repo"
echo "    In Visual Studio Code, type:"
echo "    COMMAND+SHIFT+P (Mac) or CONTROL+SHIFT+P (Windows)"
echo "    Search for and select \033[1mPublish to GitHub\033[0m"
echo "    In most cases, you will make the repo public"
echo "    Follow the steps to complete the process"
echo "5. In GitHub, enable GitHub Pages in the repo settings and test"
echo "    https://YourGitHubUserName.github.io/$BASEURL"
echo "6. Continue developing locally and pushing changes to GitHub"
echo "    All your changes will publish to the website automatically after a few minutes"
echo ""
echo "7. Optionally, create a README.md at the root of this folder to provide yourself"
echo "    and others with pertinent details for building and using the repo"