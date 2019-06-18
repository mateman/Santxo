			var http = nuevoAjax();
		
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function nuevoAjax(){ 
				var xmlhttp=false;
				try{
					xmlhttp=new ActiveXObject("Msxml2.XMLHTTP");
				}catch(e){
					try{
						xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
					}catch(E){
						if (!xmlhttp && typeof XMLHttpRequest!='undefined') xmlhttp=new XMLHttpRequest();
					};
				};
				return xmlhttp; 
			};
			
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
			function crea_query_string(agr) {
  				return "cuenta=" + encodeURIComponent(agr.value);
			};

	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function crear_cuenta (cuenta,nombre,sector,tel,dni,secreto,newsecreto){							

				http.onreadystatechange = respuesta_crear_cuenta;
				http.open("POST", "./crear.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				http.send("cuenta=" + encodeURIComponent(cuenta.value)+ "&nombre=" + encodeURIComponent(nombre.value) +"&DNI="+ encodeURIComponent(dni.value) +"&sector=" + encodeURIComponent(sector.value) +"&tel=" + encodeURIComponent(tel.value) + "&clave=" + encodeURIComponent(secreto.value) + "&newclave=" + encodeURIComponent(newsecreto.value) + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);
			
			}
			
	//------------------------------------------------------------
	
			function respuesta_crear_cuenta(){
				if(http.readyState == 4){
					document.getElementById('divmensaje').innerHTML = http.responseText;					
					if (document.getElementById('c').value=='true'){
						document.getElementById('botoncrearcuenta').disabled=true;
						mensaje('visible','#00FF00','true');
					}else{
						document.getElementById('botoncrearcuenta').disabled=false;						
						mensaje('visible','#FF0000','true');					
					}
				if (document.getElementById('creavalido').value == 'false') { errorSession();}				
				}						
			}

	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function MostrarLista(){			
				Espera(true);
				MostrarDiv('divlistar');				
				http.open("POST","./listar.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");				
				http.onreadystatechange = respuesta_MostrarListar;
				http.send("session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);		
			}
			
	//------------------------------------------------------------

			function respuesta_MostrarListar(){
				if(http.readyState == 4){					
					document.getElementById('divlistar').innerHTML = http.responseText;
					Espera(false);
					if (document.getElementById('valido').value == 'false') { errorSession();}				
				}		
			}
			
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function MostrarEdit(){			
				Espera(true);				
				http.open("POST","./edi.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");				
				http.onreadystatechange = respuesta_MostrarEdit;	
				http.send("cuenta=" + encodeURIComponent(document.getElementById('edcuenta').value)+ "&operacion=editar" + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);						
			}
			
	//------------------------------------------------------------

			function respuesta_MostrarEdit(){
				if(http.readyState == 4){
					document.getElementById('divedit').innerHTML = http.responseText;
					Espera(false);
				}		
			}
			
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function mostrarDatos(cuenta){							
				http.open("POST","./edi.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");				
				http.onreadystatechange = respuesta_MostrarDatos;	
				http.send("cuenta=" + encodeURIComponent(cuenta.value)+ "&operacion=ver" + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);						
			}
			
	//------------------------------------------------------------

			function respuesta_MostrarDatos(){
				if(http.readyState == 4){
					document.getElementById('divb').innerHTML = http.responseText;
				if (document.getElementById('ver').value=='false'){
					document.getElementById('divb').style.visibility = "hidden";
					document.getElementById('botonborrar').disabled =true;				
				}else{document.getElementById('divb').style.visibility = "visible";
								document.getElementById('botonborrar').disabled =false;
								return true ;}
				if (document.getElementById('vvalido').value == 'false') { errorSession();}		
			}
	}		
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function verifica_cuenta(cuenta){							

				http.onreadystatechange = respuesta_verifica_cuenta;
				http.open("POST", "./verifica.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				var query_string = crea_query_string(cuenta)+ "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value;
				http.send(query_string);
			
			}
			
	//------------------------------------------------------------
	
			function respuesta_verifica_cuenta(){
				if(http.readyState == 4){
					document.getElementById('divmensaje').innerHTML = http.responseText;
					if (document.getElementById('c').value=='true'){
						document.getElementById('botoncrearcuenta').disabled=true;						
						mensaje('visible','#FFFACD','false');						
						}else{
						document.getElementById('botoncrearcuenta').disabled=false;
						mensaje('hidden','#FFFACD','false');																							
					}
					if (document.getElementById('cvalido').value == 'false') { errorSession();}				
				}						
			}
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function verifica_DNI(dni){							

				http.onreadystatechange = respuesta_verifica_DNI;
				http.open("POST", "./verificaDNI.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				var query_string = crea_query_string(dni)+ "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value;
				http.send(query_string);
			
			}
			
	//------------------------------------------------------------
	
			function respuesta_verifica_DNI(){
				if(http.readyState == 4){
					document.getElementById('divmensaje').innerHTML = http.responseText;
					if (document.getElementById('c').value=='true'){
						document.getElementById('botoncrearcuenta').disabled=true;						
						mensaje('visible','#FFFACD','false');						
						}else{
						document.getElementById('botoncrearcuenta').disabled=false;
						mensaje('hidden','#FFFACD','false');																							
					}
					if (document.getElementById('cvalido').value == 'false') { errorSession();}				
				}						
			}

	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function verifica_DNIedit(dni){							

				http.onreadystatechange = respuesta_verifica_DNIedit;
				http.open("POST", "./verificaDNI.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				var query_string = crea_query_string(dni)+ "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value;
				http.send(query_string);
			
			}
			
	//------------------------------------------------------------
	
			function respuesta_verifica_DNIedit(){
				if(http.readyState == 4){
					document.getElementById('divmensaje').innerHTML = http.responseText;
					if (document.getElementById('c').value=='true'){
						document.getElementById('botonedit').disabled=true;						
						mensaje('visible','#FFFACD','false');						
						}else{
						document.getElementById('botonedit').disabled=false;
						mensaje('hidden','#FFFACD','false');																							
					}
					if (document.getElementById('cvalido').value == 'false') { errorSession();}				
				}						
			}


	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
			function verifica_editar(cuenta){							
				http.onreadystatechange = respuesta_verifica_editar;
				http.open("POST", "./verifica.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				var query_string = crea_query_string(cuenta)+ "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value;
				http.send(query_string);
	
			}
			
	//------------------------------------------------------------

			function respuesta_verifica_editar(){
				if(http.readyState == 4){
					document.getElementById('divmensaje').innerHTML = http.responseText;
					if (document.getElementById('c').value=='false'){
						document.getElementById('edi').disabled=true;
					}else{
						document.getElementById('edi').disabled=false;					
					}
				if (document.getElementById('cvalido').value == 'false') { errorSession();}				
				}						
			}
	
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			function cambiar_cuenta (cuenta,nombre,sector,tel,dni){							

				http.onreadystatechange = respuesta_change;
				http.open("POST", "./cambiar.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				http.send("cuenta=" + encodeURIComponent(cuenta.value)+ "&nombre=" + encodeURIComponent(nombre.value) +"&sector=" + encodeURIComponent(sector.value) +"&tel=" + encodeURIComponent(tel.value) +"&DNI=" + encodeURIComponent(dni.value)+ "&clave=" + encodeURIComponent(secreto.value) + "&newclave=" + encodeURIComponent(newsecreto.value) + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);
			
			}

	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

			function copiar_cuenta(sourcecuenta , sourcehost , sourcepass , destinocuenta , destinohost , destinopass ){
				Espera(true);
				http.onreadystatechange = respuesta_change;
				http.open("POST", "./copiar.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				http.send("sourcecuenta=" + encodeURIComponent(sourcecuenta.value)+ "&sourcehost=" + encodeURIComponent(sourcehost.value) +"&sourcepass=" + encodeURIComponent(sourcepass.value) +"&destinocuenta=" + encodeURIComponent(destinocuenta.value) + "&destinohost=" + encodeURIComponent(destinohost.value) + "&destinopass=" + encodeURIComponent(destinopass.value) + "&session=" + document.getElementById('sessionval').value);
			
			}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function change_passwd(cuenta, pass, newpass){							

				http.onreadystatechange = respuesta_change;
				http.open("POST", "./passwd.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");			
				http.send("cuenta=" + encodeURIComponent(cuenta.value)+ "&clave=" + encodeURIComponent(pass.value) + "&newclave=" + encodeURIComponent(newpass.value) + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);
	
			}
			
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

			function delete_cuenta(cuenta){							

				http.onreadystatechange = respuesta_change;
				http.open("POST", "./delete.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");			
				http.send("cuenta=" + encodeURIComponent(cuenta.value) + "&session=" + document.getElementById('sessionval').value + "&server=" + document.getElementById('dominio').value);
	
			}
			
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			function cerrar_ajax(){							

				http.onreadystatechange = respuesta_change;
				http.open("POST", "./cerrar.cgi", true);
				http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");			
				http.send("session=" + document.getElementById('sessionval').value);
	
			}
			
	//------------------------------------------------------------
			function respuesta_change(){
				if(http.readyState == 4){
					Espera(false);					
					document.getElementById('divmensaje').innerHTML = http.responseText;
					if (document.getElementById('c').value=='true'){
						mensaje('visible','#00FF00','true');
					}else{				
						mensaje('visible','#FF0000','true');					
					}
				}						
			}

	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			function Espera(activo){
				
				if (activo==true){					
					document.getElementById('espera').style.visibility= "visible";
				}else{
					document.getElementById('espera').style.visibility= "hidden";
				}				
			}
			