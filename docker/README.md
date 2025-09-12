## Build this container
```sh
docker build -t ai_coding_demo .
```

```sh
docker build . -t ghcr.io/thadd3us/ai_coding_demo:latest --push
```

## Start a container with shared data running bash
```sh
docker run \
    --mount type=bind,source=${HOME}/src/Strain_library_paper,target=/shared_data \
    -it \
    -p 1455:1455 \
    ai_coding_demo \
    bash
```


## Start a container with shared data running a jupyter server
```sh
docker run \
    --mount type=bind,source=${HOME}/src/Strain_library_paper,target=/shared_data \
    -p 8888:8888 \
    ai_coding_demo \
    run_jupyter.sh /shared_data
```
