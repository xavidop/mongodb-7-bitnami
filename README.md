# Container Image for Mongo 7 working with bitnami charts

This repo uses the mongodb bitnami container image located [here](https://github.com/bitnami/containers/tree/main/bitnami/mongodb)

Updates that image following the instructions in the [ZCube/bitnami-compat](https://github.com/ZCube/bitnami-compat) README.md file and this [gist](https://gist.github.com/ZCube/7e3045b1f15b1c1223f58267fc738e57)

# Build the image
```bash
./build.sh <container-registry> <image-name>
```

In my case I used the following command:
```bash
./build.sh xavidop mongodb
```
And:
```bash
./build.sh ghcr.io/xavidop mongodb
```

# Notes
- The `bitnami-compat` repo is a fork of the `bitnami` repo with the necessary changes to make the image compatible with the ARM platform and without Bitnami's StackSmith binaries.
- This image has been only tested on Macbook M1 using Docker Desktop for Mac and Kind Kubernetes clusters.
- This image is not intended for production use, it is only for development purposes.
- Sometime the build process fails, just run the build command again.
- This is not an active project, it is just a proof of concept.
