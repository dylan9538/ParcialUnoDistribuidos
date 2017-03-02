# ParcialUnoDistribuidos

### Examen 1
**Universidad ICESI**  
**Curso:** Sistemas Distribuidos  
**Tema:** Automatización de infraestructura  

****
Estudiante | Código
--- | --- | ---
Dylan Torres | A00265772
****

### Objetivos
* Realizar de forma autónoma el aprovisionamiento automático de infraestructura
* Diagnosticar y ejecutar de forma autónoma las acciones necesarias para lograr infraestructuras estables
* Integrar servicios ejecutandose en nodos distintos

### Prerrequisitos
* Vagrant
* Box del sistema operativo CentOS 6.5 o superior

### Problema
Se necesita realizar	el	aprovisionamiento	de	un	ambiente	compuesto	por:

- Un servidor	encargado de realizar balanceo de	carga.
- Dos	servidores	web	
- Un servidor de base de datos

Se	debe probar	el	funcionamiento	del balanceador	a través	de	una	aplicación	web	que realice	 consultas	 a	 la	 base	 de	 datos	 a	 través	 de	 los servidores	 web (mostrar visualmente cual	servidor web atiende la	petición).

##Pasos preliminares

Primeramente debemos de crear una subinterfaz de red para conectar el equipo con el mirror con el comando:
```
sudo ifconfig enp5s0:0 192.168.131.92
```
**GITHUB**

Para realizar la subida de archivos al repositorio en github se realizaran los siguientes pasos, o es importante tenerlos en cuenta:

Creamos dentro de la carpeta distribuidos un nuevo directorio llamado parcialUnoRepo:

```
mkdir parcialUnoRepo
cd parcialUnoRepo
```

**1)Clono el repositorio que necesito**

En este repositorio añadiremos los archivos que se manejen.

```
git clone https://github.com/dylan9538/parcialUnoDistribuidos.git
cd parcialUnoDistribuidos

git config remote.origin.url "https://token@github.com/dylan9538/parcialUnoDistribuidos.git"
```
En el campo token añado el token generado en github.

**2)subir archivos**

1)Creo el archivo si no existe.

2)Sigo los siguientes comandos:
Estos comandos los ejecuto donde se encuentra ubicado el archivo a cargar.

```
git add nombreArchivo
git commit -m "upload README file"
git push origin master
```
##SOLUCION DEL PROBLEMA

Consignación de los comandos de linux necesarios para el aprovisionamiento de los servicios solicitados

**Usaremos Nginx que permite realizar el balanceo de carga necesario:**

**¿Que es nginx?**

Es un servidor web/proxy inverso ligero de alto rendimiento y un proxy para protocolos de correo electrónico. Es software libre y de código abierto; también existe una versión comercial distribuida bajo el nombre de nginx plus. Es multiplataforma, por lo que corre en sistemas tipo Unix (GNU/Linux, BSD, Solaris, Mac OS X, etc.) y Windows.

**PASOS PARA LA INSTALACIÓN DE NGINX**

Estos pasos se realizan dentro del servidor que será nuestro balanceador de carga:

**Para empezar y evitar problemas de permiso ejecutamos el comando siguiente:**

```
sudo -i
```

**Empezamos dirigiendonos a la carpeta de los repositorios de yum, con el siguiente comando**

```
cd /etc/yum.repos.d
```

**se debe de crear un file de repositorio para alojar Nginx**

```
vi nginx.repo
```

**Dentro del file agregamos el siguiente texto necesario para configurar la ruta de descarga de descargar el Nginx, donde queda específicado el sistema operativo, la versión y la arquitectura del computador.**

```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```
**Luego ejecutamos el siguiente comando de instalación de nginx**

```
yum install nginx
```

**CONFIGURACIÓN DE NGINX PARA QUE CUMPLA SU FUNCIÓN DE BALANCEADOR DE CARGA**

**Primero se accede al archivo de configuración**

```
vi /etc/nginx/nginx.conf
```

**El archivo viene con un contenido por defecto. Es necesario que este sea eliminado y se agregue el siguiente código con el cual se especifican los servidores a los cuales el balanceador escuahará**

```
worker_processes  1;
events {
   worker_connections 1024;
}

http {
    upstream servers {
         server 192.168.131.93;
         server 192.168.131.94;
    }

    server {
        listen 8080;

        location / {
              proxy_pass http://servers;
        }
    }
}
```

**Luego ejecutamos los siguientes comandos donde abrimos el puerto definido en el archivo de configuración anterior:**

```
 iptables -I INPUT -p tcp --dport 8080 --syn -j ACCEPT
 service iptables save
 service iptables restart
```
**Finalmente iniciamos corriendo nginx**

```
service nginx start
```
