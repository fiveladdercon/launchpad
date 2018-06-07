1. Create a local workarea accessible from both machines:

>mkdir /data/live/files/Business/SpacecraftRDL
>ln -s /data/live/files/Business/SpacecraftRDL ~/SpacecraftRDL

2. Create a local private spacecraft repo

>mkdir /data/live/git
>ln -s /data/live/git /git
>git init --bare /git/spacecraft.git

3. Create a github launchpad repo, add the docs/ directory and
   configure the settings to publish the docs/ as the site page.

4. Clone the repos into the workarea

>cd ~/SpacecraftRDL
>git clone /git/spacecraft.git
>git clone https://github.com/fiveladdercon/launchpad.git

5. Set up Jekyll locally to stage the static site

https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/

5.1 Install ruby

>sudo apt-add-repository ppa:brightbox/ruby-ng
>sudo apt-get install ruby ruby-dev

5.1.b Install bundler dependencies:

>sudo apt-get install g++ zlib1g-dev

5.2 Install bundler

>sudo gem install bundler

5.3 Install jekyll

>bundle install