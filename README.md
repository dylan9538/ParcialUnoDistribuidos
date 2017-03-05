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

**VAGRANT FILE**

Para esta etapa se procede a explicar la creación y especificación del documento Vagrantfile. El archivo contiene toda la especificación de las máquinas que tendran los diversos papelas necesarios. Para los servidores web se requiere de mandar dos variables para que sean creadas en attributes y permitan cambiar la variable del nombre de las tablas en la base de datos, ya que ambas maquinas se crean con la misma configuración del cookbook, se debe hacer desde el vagrant por medio del chef.json. Dentro del directorio parcialUnoDistribuidos procedemos a crear el archivo con el nombre Vagrantfile y agregamos el siguiente texto:

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
chef.json = {
          "web" => {
             "tabla" => 'equipos'
          }
      }

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
     chef.json = {
          "web" => {
             "tabla" => 'equipos2'
          }
      }
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

**COOKBOOK web**

Dentro de el directorio attributes creamos un archivo default.rb con el siguiente texto, que define la ip de la base de datos, como los valores user y password para acceder (Atributos que seran usados en otros archivos dentro de la máquina):

```
default[:db][:ip] = '192.168.131.96'
default[:wb][:user] = 'icesi'
default[:wb][:pass] = '12345'
```
Dentro del directorio recipes tenemos la receta llamada installweb.rb donde se descargan los paquetes necesarios y se hace la confiuración pertinenete para que el servidor web funcione correctamente. Se hace referencia al template index.php.erb que hace llamado a las dos tablas de la base de datos que se creara:

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

template '/var/www/html/index.php' do
 source 'index.php.erb'
 mode 0644
 variables(
      db_ip: node[:db][:ip],
      wb_user: node[:wb][:user],
      wb_pass: node[:wb][:pass],
      tablename: node[:web][:tabla]    
)
end

template '/var/www/html/select.php' do
    source 'select.php.erb'
    mode 0777
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

Dentro del directorio templates/default tenemos el archivo index.php.erb que consulta a la base de datos la información en ella. Este archivo es un html que tiene en si un codigo php. Contiene el siguiente texto: 

```
<HTML>
  <BODY>
    <H1>lISTAS</H1>
      <?php
      $con = mysql_connect("<%=@db_ip%>","<%=@wb_user%>","<%=@wb_pass%>");
      if (!$con)
          {
          die('Could not connect: ' . mysql_error());
          }
      mysql_select_db("bduno", $con);
      $result = mysql_query("SELECT * FROM <%=@tablename%>");

      while($row = mysql_fetch_array($result))
            {
            echo $row['name'] . " " . $row['titulos'];
            echo "<br />";
            }
       mysql_close($con);
      ?>
  </BODY>
</HTML>
```

En el directorio files/default DEBEMOS de tener el archivo htaccess. El archivo htaccess (hypertext access) es un archivo de configuración muy popular en servidores web basados en Apache que permite a los administradores aplicar distintas políticas de acceso a directorios o archivos. Cuando se visita una página web y se pulsa sobre un enlace o se quiere descargar un archivo, en el proceso de trámite de la petición, el servidor web consulta el archivo htaccess con la idea de aplicar las directivas y restricciones definidas . Contiene la siguiente linea, que permite tener un php dentro de un html:

```
AddType php-script .php .htm .html
```

Con esto ya tenemos la configuración necesaria para los servidores web.

**COOKBOOK db**

Brevemente definimos el contenido en cada uno de los directorios:

En attributes tenemos en archivo default.rb con: 

```
default[:wb][:wb_ipOne] = '192.168.131.93'
default[:wb][:wb_ipTwo] = '192.168.131.94'
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
      wb_ipOne: node[:wb][:wb_ipOne],
      wb_ipTwo: node[:wb][:wb_ipTwo],
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


Tenemos el archivo create_schema.sql.erb dentro del directorio templates/default con la definicion de todo el esquema de la base de datos. creamos una base de datos llamada bduno con dos tablas respectivamente, que SON LAS QUE SERVIRAN PARA DIFERENCIAR Y VERIFICAR QUE EL BALANCEADOR A REALIZAR FUNCIONE CORRECTAMENTE:

```
CREATE database bduno;
USE bduno;
CREATE TABLE equipos(
        id INT NOT NULL AUTO_INCREMENT, 
        PRIMARY KEY(id),
        name VARCHAR(30), 
        titulos INT
);

CREATE TABLE equipos2(
        id INT NOT NULL AUTO_INCREMENT, 
        PRIMARY KEY(id),
        name VARCHAR(30), 
        titulos INT
);

INSERT INTO equipos (name,titulos) VALUES ('Deportivo_cali',9);
INSERT INTO equipos (name,titulos) VALUES ('America',13);
INSERT INTO equipos (name,titulos) VALUES ('Nacional',15);
INSERT INTO equipos (name,titulos) VALUES ('Millonarios',15);
INSERT INTO equipos (name,titulos) VALUES ('Junior',6);
INSERT INTO equipos (name,titulos) VALUES ('Santafe',8);

INSERT INTO equipos2 (name,titulos) VALUES ('Barcelona',10);
INSERT INTO equipos2 (name,titulos) VALUES ('Madrid',11);
INSERT INTO equipos2 (name,titulos) VALUES ('PSG',12);
INSERT INTO equipos2 (name,titulos) VALUES ('Bayern',13);
INSERT INTO equipos2 (name,titulos) VALUES ('Chelsea',14);
INSERT INTO equipos2 (name,titulos) VALUES ('Liverpool',15);


-- http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch34_:_Basic_MySQL_Configuration
GRANT ALL PRIVILEGES ON *.* to '<%=@db_user%>'@'<%=@wb_ipOne%>' IDENTIFIED by '<%=@db_pass%>';
GRANT ALL PRIVILEGES ON *.* to '<%=@db_user%>'@'<%=@wb_ipTwo%>' IDENTIFIED by '<%=@db_pass%>';

```

**COOKBOOK balancer**

Brevemente definimos el contenido en cada uno de los directorios:

En attributes tenemos en archivo default.rb con: 

```
default[:balancer][:ip_serverOne]='192.168.131.93'
default[:balancer][:ip_serverTwo]='192.168.131.94'
```
Definimos las ip de los dos servidores web los cuales seran "balanceados".

En files/default definimos el archivo nginx.repo donde esta configrada la instalación predeterminada para nginx, con lo siguiente:

```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

En el directorio recipes tenemos el archivo installbalancer.rb con la configuración para la instalación de nginx y el llamado al template y el default.rb que hace llamado a dicho recipe, con el siguiente contenido respectivamente:

```
bash 'open port' do
  code <<-EOH
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
  iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
  service iptables save
  EOH
end

cookbook_file '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo'
end 

package 'nginx'

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  variables(
    ip_serverOne: node[:balancer][:ip_serverOne],
    ip_serverTwo: node[:balancer][:ip_serverTwo]
  )
end

service 'nginx' do
  action :enable
end

service 'nginx' do
  action :start
end
```

```
include_recipe 'balancer::installbalancer'
```


Dentro del directorio templates/default tenemos el archivo nginx.conf.erb donde defino el puerto por el que escucha el balanceador y las dos ip de los servidores web que el balanceador tendra en cuenta.

```
worker_processes  1;
events {
   worker_connections 1024;
}
http {
    upstream servers {
         server <%=@ip_serverOne%>;
         server <%=@ip_serverTwo%>;
    }
    server {
        listen 8080;
        location / {
              proxy_pass http://servers;
        }
    }
}

```

**CON ESTO TODOS LOS COOKBOOKS QUEDAN TOTALMENTE TERMINADOS Y SE TIENE CONFIGURADO TODO PARA AUTOMATIZAR LA INFRAESTRUCTURA (BALANCEADOR, SERVIDORES WEB, BASE DE DATOS).**

###PRUEBAS DE FUNCIONAMIENTO

Cuando corremos y montamos nuestras máquinas aprovisionadas por medio del comando

```
vagrant up
```

Nos dirigimos al browser y digitamos la ip del balanceador en este caso la 192.168.131.95 junto con el puerto por el que escucha de la siguiente manera:

```
192.168.131.95:8080
```

Aparece la consulta a la base de datos de alguna de las dos tablas creadas en ella, y si refrescamos la página el balanceador cumplira su función y re dirigira a ambas páginas que consultan tablas diferentes, como lo muestran las siguientes imagenes.

![alt tag](https://github.com/dylan9538/ParcialUnoDistribuidos/blob/master/Prueba_1.png)

![alt tag](https://github.com/dylan9538/ParcialUnoDistribuidos/blob/master/Prueba_2.png)

###PROBLEMAS ENCONTRADOS

-- Uno de los problemas fue el de poder asociar HTML con PHP al momento de crear el index que se debia mostras en el browser. Como se dijo anteriormente dicho problema se soluciono creando el file htaccess en la explicación del cookbook web. 

-- Otro problema era encontrar la forma de diferenciar o verificar que el servidor balancer cumpliera con su función para lo que se tivo que usar el chef.json donde se pasaban especificaciones de un valor para la consulta a la base de datos que permitia que en un servidor web se consultara una tabla y en otro servidor otra tabla. Dicha explicación esta mas clara dentro de la guía del Vagrantfile.

-- Y no tanto un problema, un punto de demora fue encontrar una instalación correcta de nginx que fuera sencilla de automatizar,pero que igualmente esta explicita dentro de la documentación de nginx por lo que no fue tanto un problema aplicarla.

##FIN
