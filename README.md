# ai_coding_demo

## Start a container with bash
```sh
docker run -it \
    -v $(pwd):/workspace \
    -e OPENAI_API_KEY=${OPENAI_API_KEY} \
    ai_coding_demo
```

## Start a container with shared data VSCode Server
```sh
docker run -it \
    -v $(pwd):/workspace \
    -p 127.0.0.1:3000:3000 \
    ghcr.io/thadd3us/ai_coding_environment \
    run_vscode.sh /workspace

docker run -it \
    -v $(pwd):/workspace \
    -e OPENAI_API_KEY=${OPENAI_API_KEY} \
    -p 3000:3000 \
    ai_coding_demo \
    run_vscode.sh /workspace
```


## Start a container with shared data running a jupyter server
```sh
docker run \
    --mount type=bind,source=${HOME}/src/Strain_library_paper,target=/shared_data \
    -p 8888:8888 \
    ai_coding_demo \
    run_jupyter.sh /shared_data
```

# Publishing

## Docker login
```
echo $GHCR_PUSH_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## Build this container
```sh
docker build -t ai_coding_demo .
```

```sh
docker build . -t ghcr.io/thadd3us/ai_coding_environment:latest --push
```
