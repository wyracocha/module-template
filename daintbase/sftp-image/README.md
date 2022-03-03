# Credicorp SFTP
### Basada en [atmoz/sftp](https://github.com/atmoz/sftp)

El propósito del proyecto es gestionar la imagen del sftp para los container instance o aks 
## Agregar un nuevo usuario
Para agregar un nuevo usuario se debe agregar sus directorios y dar permisos. Guiarse del Dockerfile para el usuario int-sapetl-interno-col. Seguido se debe modificar el archivo users.conf de la carpeta files agregando el usuario y su clave encryptada. El proceso de encryptacion de claves se puede seguir a partir de la imagen base ([atmoz/sftp](https://github.com/atmoz/sftp)). Luego de agregar un nuevo usuario, es necesario crear un nuevo build y pushear la imagen al registry correspondiente
## Building
Para construir la imagen, se debe correr el comando **make build** y enviar los parametros solicitados en el archivo make file
## Running
Para ejecutar la imagen en local, ejecutar **make run** y enviar los parametros solicitados en el archivo make file
## Deploy
Para desplegar la imagen construida, ejecutar **make deploy** y enviar los parametros solicitados en el archivo make file
## Ejemplo
**REGISTRY=crdataintdev001eu2arqsop.azurecr.io IMAGE=sftp-imagen VERSION=2.5 make push**