docker run -it \
    --env="DISPLAY=$DISPLAY" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name=arcanain_ws \
    arcanain_workspace:1.0