Small ssh git server

Contains a bash script that you can set in your path to run commands like

`git repo create -v public my_repo` and such.

# Deploy

You need to create a git user. You might have to set ownership to git:git to the config folder, and in particular change the permissions to 700

Run `build-and-deploy`. You need to specify:

- `HOST_REPO_DIR` where repository is actually stored
- `CONFIG_DIR` where config is stored, notably ssh keys.