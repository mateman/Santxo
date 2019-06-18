//Verificacion de que no este vacia ni sean espacios en blanco
function vacio(q){ 
         for ( i = 0; i< q.length; i++ ) 
         		{  
                if ( q.charAt(i)== " " ) 
                		{ return false;  
                 		}  
         		};  
         return true;  
 						}  

//Validacion de cuenta
function vcuenta(crea){
	var er_cuenta = /(^([0-9a-z]|\.|\-)+|^)$/;
	  if (!er_cuenta.test(crea.value)) {
				  alert('error valor no aceptado'); //Colocamos el cursor en ese campo	  
				  crea.focus(); //Colocamos el cursor en ese campo
				  crea.value=''; //Borramos el error

        } else {
                return false;
        }
		  }
//Validacion del nombre
function vnombre(crea){
	if(!(/(^([a-zA-Z]|á|é|í|ó|ú|ñ|ü|\.|-|\s)+)$/).test(crea.value)||((/^\s+$/).test(crea.value)))  
	  { //Validamos que el nombre no sea un numero y que tenga informacion
	  alert('El nombre no puede ser un numero o caracteres extraños');
	  crea.value=''; //Borramos el error
	  crea.focus(); //Colocamos el cursor en ese campo		
	  }
	return false;
					  }
					  
// Validacion del DNI
function DNI(crea){

	if (!(/(^(\d|\.|\s)+([a-zA-Z])*|^)$/).test(crea.value)||((/^\s+$/).test(crea.value)))
	{
	    alert('El valor ingreasdo debe ser un numero');	
	    crea.value='';
	    crea.focus();
	}
	return false;
		 				}

//Validacion del sector
function vsector(crea){
	if(!(/(^([a-zA-Z]|\d|á|é|í|ó|ú|ñ|ü|\s|\.|-|ª|=)+|^)$/).test(crea.value)||((/^\s+$/).test(crea.value)))  
	    { //Validamos que el nombre no sea un numero y que tenga informacion
	     alert('El nombre del sector no es valido');	 	
	     crea.value=''; //Borramos el error
	     crea.focus(); //Colocamos el cursor en ese campo
	    }
	return false;
		  				}

// Validacion del telefono
function vtel(crea){
if (!(/(^(\d|\.|-|\s)+|^)$/).test(crea.value)||((/^\s+$/).test(crea.value)))
	{
	alert('El valor ingreasdo debe ser un numero valido');	
	crea.value='';
	crea.focus();
	}
	return false;
		 				}

//Validacion de password
function vpasswd(pas, npas){
var pass=pas.value;
var newpass=npas.value;
if ((pass == '')||( pass != newpass))
	{ //Validamos que tenga informacion
	  pas.value=''; //Borramos el error
	  npas.value='';	  
	  pas.focus(); //Colocamos el cursor en ese campo
	  document.getElementById('bclave').disabled=true;	  
	  alert('La contraseña no coincide con la nuevamente escrita');	  
	} else { document.getElementById('bclave').disabled=false;};
	return false;
		  				}

function chpass(pas, npas){
if (( pas.value != npas.value)||((/^(\s)$/).test(pas.value)))
		{  alert('Las contraseñas no coinciden'); 
		return false;}
else {change_passwd(document.getElementById('edcuenta'),pas,npas);}
return false;
        }

function setbotoncopiar(){
if ((document.getElementById('sourcecuenta').value !='')&&(document.getElementById('sourcehost').value !='')&&(document.getElementById('sourcepass').value !='')&&(document.getElementById('destinocuenta').value !='')&&(document.getElementById('destinohost').value !='')&&(document.getElementById('destinopass').value !=''))
		{ document.getElementById('botoncopiar').disabled=false; return false;}
else 	{ return false;}
			}

function setdominio(){
	document.getElementById('cdomi').innerHTML ="@"+ document.getElementById('dominio').options[document.getElementById('dominio').selectedIndex].text;
	document.getElementById('bdomi').innerHTML ="@"+ document.getElementById('dominio').options[document.getElementById('dominio').selectedIndex].text;
	document.getElementById('edomi').innerHTML ="@"+ document.getElementById('dominio').options[document.getElementById('dominio').selectedIndex].text;
	return false;
			}
//borrar todos los campos del formulario crearCuenta

function vempezar(){ 
 document.getElementById('cuenta').value='';
 document.getElementById('nombre').value='';
 document.getElementById('sector').value='';
 document.getElementById('tel').value='';
 document.getElementById('secreto').value='';
 document.getElementById('newsecreto').value='';  
         return true;  
 						}  
		  

//Salir del sistema 
function Salir() { 
	window.location='index.cgi';
	cerrar_ajax();}
	
//Funcion de Error por session
function errorSession(){
	document.bgcolor='#808080';
	document.getElementById('botones').style.visibility= "hidden";
	document.getElementById('divdominio').style.visibility= "hidden";
	MostrarDiv('divsession');
	setTimeout("window.location='index.cgi'",7000);
	}