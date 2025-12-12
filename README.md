Small ssh git server

Contains a bash script that you can set in your path to run commands like

`git repo create -v public my_repo` and such.

# Deploy

You need to create a git user. You might have to set ownership to git:git to the config folder, and in particular change the permissions to 700

Run `build-and-deploy`. You need to specify:

- `HOST_REPO_DIR` where repository is actually stored
- `CONFIG_DIR` where config is stored, notably ssh keys.

# Install git repo locally

You can install the `git repo` command locally by either running `./install-bin.sh` from a clone of this repo, or by:

1. Set the `GIT_REPO_ADDRESS` environment variable to your git server (e.g. `git@home.server.address`).
2. If you are not on port 22, set your port in ssh config:

   ```
   Host home.server.address
       Port 2222
   ```

3. Run the following command to download and install the `git repo` script:

   ```bash
   bash -c "`ssh $GIT_REPO_ADDRESS 'remote-install'`"
   ```
