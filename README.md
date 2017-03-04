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
**Finalmente iniciamos nginx**

```
service nginx start
```

Luego de ejecutar el comando anterior probamos en el browser si nuestro balanceador de carga esta funcionando digitando la ip del balanceador y el puerto 8080. 

##AUTOMATIZACIÓN DE INFRAESTRUCTURA

**Vagrantfile**

Para esta etapa se procede a explicar la creación y especificación del documento Vagrantfile. Dentro del directorio parcialUnoDistribuidos procedemos a crear el archivo con el nombre Vagrantfile y agregamos el siguiente texto:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.vm.define :centos_web do |web|
    web.vm.box = "centos64u"
    web.vm.network "private_network", ip: "192.168.33.20"
    web.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.93"
    web.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web-uno" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web"
    end
  end

  config.vm.define :centos_web2 do |web|
    web.vm.box = "centos64u"
    web.vm.network "private_network", ip: "192.168.33.21"
    web.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.94"
    web.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web-dos" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web"
    end
  end

config.vm.define :centos_balancer do |ba|
    ba.vm.box = "centos64"
    ba.vm.network "private_network", ip: "192.168.33.22"
    ba.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.95"
    ba.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-balanceador" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "balancer"
    end
  end

config.vm.define :centos_db do |db|
    db.vm.box = "centos64u"
    db.vm.network "private_network", ip: "192.168.33.23"
    db.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.96"
    db.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-database" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "db"
    end
  end
end
```

Dentro de este archivo especificamos todo el aprovisionamiento con lo siguiente:
- Maquinas a aprovisionar
- Interfaces solo anfitrión
- Interfaces tipo puente
- Declaración de cookbooks
- Variables necesarias para plantillas 

###Realización de cookbooks

Dentro del directorio parcialUnoDistribuidos creamos un directorio cookbooks con tres directorio llamados:
- balancer (Representa el balanceador de carga)
- web (Representa los servidores web)
- db (Representa la base de datos)

Dentro de estas carpetas creamos un esquema de trabajo con las siguientes carpetas: 

- Attributes
- Files
- Recipes 
- Templates

**Acontonuación se enseñara la automatización de cada una de las máquinas para que se cumplan con las especificaciones necesarias para que se presten los servicios solicitados** 

**Primero con web**

Dentro de la carpeta Attributes creamos un archivo default.rb con el siguiente texto, que define la ip de la base de datos, como los valores user y password para acceder:

```
default[:db][:ip] = '192.168.131.96'
default[:wb][:user] = 'icesi'
default[:wb][:pass] = '12345'
```
Dentro del directorio Recipes tenemos la receta llamada installweb.rb donde se descargan los paquetes necesarios y se hace la confiuración pertinenete para que el servidor web funcione correctamente:

```
package 'httpd'
package 'php'
package 'php-mysql'
package 'mysql'

service 'httpd' do
  action [:enable, :start]
end

bash 'open port' do 
 code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  service iptables save 
    EOH
end

cookbook_file '/var/www/html/index.html' do
 source 'index.html'
 mode 0644
end

cookbook_file '/var/www/html/info.php' do
 source 'info.php'
 mode 0644
end

template '/var/www/html/select.php' do
    source 'select.php.erb'
    mode 0644
    variables(
      db_ip: node[:db][:ip],
      wb_user: node[:wb][:user],
      wb_pass: node[:wb][:pass]
    )
end
```

Tambien tenemos el archivo default.rb donde hacemos llamado a dicha receta:

```
include_recipe "web::installweb"
```

Dentro del directorio templates/default tenemos el archivo select.php.erb que consulta a la base de datos la información en ella y contiene el siguiente texto: 

```
<?php
$con = mysql_connect("<%=@db_ip%>","<%=@wb_user%>","<%=@wb_pass%>");
if (!$con)
  {
  die('Could not connect: ' . mysql_error());
  }
mysql_select_db("database1", $con);
$result = mysql_query("SELECT * FROM example");

while($row = mysql_fetch_array($result))
  {
  echo $row['name'] . " " . $row['age'];
  echo "<br />";
  }

mysql_close($con);
?>
```

Con esto ya tenemos la configuración necesaria para los servidores web.

**Segundo con db**

Brevemente definimos el contenido en cada uno de los directorios:

En attributes tenemos en archivo default.rb con: 

```
default[:db][:password] = 'distribuidos'
default[:wb][:ip1] = '192.168.131.93'
default[:wb][:ip2] = '192.168.131.94'
default[:db][:user] = 'icesi'
default[:db][:pass] = '12345'
```
Definimos los componentes de acceso a la bd y las ip de los dos servidores web.

En files/default definimos el archivo configure_mysql.sh donde esta configrada la instalación predetarminada para mysql, con el lo siguiente:

```
#!/usr/bin/expect -f 
spawn /usr/bin/mysql_secure_installation
expect ":" # Enter current password for root (enter for none):
send -- "\r" 
expect "n]" # Set root password? 
send -- "y\r"
expect ":" # New password:
send -- "distribuidos\r"
expect ":" # Re-enter new password:
send -- "distribuidos\r"
expect "n]" # Remove anonymous users? 
send -- "n\r"
expect "n]" # Disallow root login remotely?
send -- "n\r"
expect "n]" # Remove test database? 
send -- "n\r"
expect "n]" # Reload privilege tables now?
send -- "y\r"
expect eof
```

En las recetas en el directorio recipes tenemos el archivo installdb.rb con la configuración para la db y el default.rb que hace llamado a dicha receta, con el siguiente contenido respectivamente:

```
package 'mysql-server' 

service 'mysqld' do 
 action [:enable, :start]
end

bash 'openPort' do
  code <<-EOH
     iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
     service iptables save
  EOH
end

package 'expect'

cookbook_file '/tmp/configure_mysql.sh' do
    source 'configure_mysql.sh'
    mode 0711
end

bash 'configure mysql' do
  cwd '/tmp'
  code <<-EOH 
  ./configure_mysql.sh
  EOH
end

template '/tmp/create_schema.sql' do
    source 'create_schema.sql.erb'
    mode 0644
    variables(
      wb_ip: node[:db][:ip],
      db_user: node[:db][:user],
      db_pass: node[:db][:pass]
    )
end

bash 'create schema' do
 cwd '/tmp'
 code <<-EOH
 cat create_schema.sql | mysql -u root -pdistribuidos
 EOH
end
```

```
include_recipe 'db::installdb'
```

Tenemos el archivo create_schema.sql.erb dentro del directorio templates/default con la definicion de todo el esquema de la base de datos:

```
CREATE database database1;
USE database1;
CREATE TABLE example(
        id INT NOT NULL AUTO_INCREMENT, 
        PRIMARY KEY(id),
        name VARCHAR(30), 
        age INT
);
INSERT INTO example (name,age) VALUES ('flanders',25);
-- http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch34_:_Basic_MySQL_Configuration
GRANT ALL PRIVILEGES ON *.* to '<%=@db_user%>'@'<%@wb_ip%>' IDENTIFIED by '<%=@db_pass%>';
```


