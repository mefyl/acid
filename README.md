# Acid

[![Master build status](https://gitlab.routine.co/routine/acid/badges/master/pipeline.svg)](https://gitlab.routine.co/routine/acid/pipelines/master/latest)

# Git hooks

See [./.githooks/README.md](./.githooks/README.md)

I couldn't understand how to make the framework used to manage these to work (at least not without it being utterly invasive), but you can manually symlink the one hook in it with `ln -s ../../.githooks/pre-commit/versioning .git/hooks/pre-commit`.
