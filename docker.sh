#!/bin/bash

printf "\n ************** Docker Deploy ************** \n \n"

read -p "Have you done build the docker images? (y/n) " input_exists_dockerimg

# Delete existing .tar file
find . -name '*.tar' -type f -delete
rm -rf dockerDir/public/

function action() {
    echo "See this config: docker-compose.yml"
    cat docker-compose.yml
    echo "\n"

    printf "\n"
    read -p "Have you done build the project? (y/n) " input_is_build
    val_input_is_build=$(echo $input_is_build | cut -c1-1)


    if [ $val_input_is_build == 'y' ]; then
        # Copy public dir to docker dir
        mkdir -p dockerDir
        cp -rip  public/ dockerDir/public

        read -p "Name of docker image: " input_docker_image_name
        echo "Building docker image"
        docker build -t $input_docker_image_name .

        printf "\n"
        printf "Container running:"
        printf "\n"
        docker ps -a
        docker-compose down

        echo "Save docker image"

        printf "\n"
        read -p "Name of file (*.tar): " input_docker_file
        docker save -o ${input_docker_file}.tar $input_docker_image_name

        docker load --input ${input_docker_file}.tar

        docker images
        printf "\n"
        echo "$(tput setaf 2)Done! Build finished"

    elif [ $val_input_is_build == 'n' ]; then
        echo "Please waiting, build process is running"
        npm run prod:build:docs && npm run prod:build:lib

        # Copy public dir to docker dir
        mkdir -p dockerDir
        cp -rip  public/ dockerDir/public

        read -p "Name of docker image: " input_docker_image_name

        printf "\n"
        printf "Container running:"
        printf "\n"
        docker ps -a
        docker-compose down

        echo "Save docker image"
        read -p "Name of file (*.tar): " input_docker_file
        docker save -o ${input_docker_file}.tar $input_docker_image_name

        echo "\n"
        docker load --input ${input_docker_file}.tar

        docker images

        printf "\n"
        echo "$(tput setaf 2)Done! Build finished"
    else
        echo "$(tput setaf 1)Choose y/n!"
    fi
}

if [ $input_exists_dockerimg == 'y' ]; then
    docker images
    printf "\n"

    read -p "Enter container id: " input_id
    val_input_id=$(echo $input_id)

    docker-compose down
    docker rmi $val_input_id
    printf "\n"

    action
elif
    [ $input_exists_dockerimg == 'n' ];
then
    action
else
    echo "$(tput setaf 1)Choose y/n!"
fi
