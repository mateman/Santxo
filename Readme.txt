Hola !!!

Para el Cliente Santxo:

Bien primero hay que copiar la el contenido de /etc que se encuentra dentro de config a /etc del sistema
luego crear un link simbolico del directorio cgi  como sancho dentro de /usr/lib/cgi-bin/
es decir ln -s /usr/share/santxo/cgi /usr/lib/cgi-bin/santxo

Y por ultimo creamos un usuario para logearnos en el sistema
entrando a sancho/programs y ejecutando: users4sancho unUser unaPAss
los usuarios quedan guradados en el archivo que le indiquemos en el sancho.conf del etc

y ponemos en la URL http://my.maquina.algo/sancho/cgi/index.cgi y a usarlo

Para el Servidor Santxo:
Este debe estar en la maquina de correo, lo que hace este es abrir un puerto y recibir del cliente
una orden con parametros, esta orden debe coincidir con el nombre de algunos de los archivos
que se encuentren en santxo junto con el servidor (todo esto en el dir module-server-santxo)
para darle marcha al demonio hay que ejecutar el script que esta en etc dentro de module-server-santxo
para probarlo si levanto usa telnet maquina 1235 y te deberia aparecer una leyenda de bienvenida

Cualquier cosa chiflame.

Un ABRAZO!
