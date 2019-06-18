function mensaje(estado,color,tiempo){
	document.getElementById('divmensaje').style.visibility= estado;
	document.getElementById('divmensaje').style.background= color;
	if (tiempo =='true') {setTimeout("document.getElementById('divmensaje').style.visibility='hidden'",3000);};	
	if (document.getElementById('cvalido').value == 'false') { errorSession();}	;	
	return;
		}
		
function buscar(d1,d2){
	document.getElementById(d1).style.visibility= "visible";
	document.getElementById(d2).style.visibility= "visible";
	return;
		}

function ocultar(d1,d2){
	document.getElementById(d1).style.visibility= "hidden";
	document.getElementById(d2).style.visibility= "hidden";
	return;
		}
				
function vsalir(){
		  window.close();
		  }						

function MostrarDiv(d1){
	document.getElementById('divcrear').style.visibility= "hidden";
	document.getElementById('divborrar').style.visibility= "hidden";
	document.getElementById('diveditar').style.visibility= "hidden";
	document.getElementById('divlistar').style.visibility= "hidden";
	document.getElementById('divedit').style.visibility= "hidden";
	document.getElementById('divcopiar').style.visibility= "hidden";
	document.getElementById('divclave').style.visibility= "hidden";
	document.getElementById('divmensaje').style.visibility= "hidden";	
	document.getElementById('divb').style.visibility= "hidden";
	document.getElementById('divsession').style.visibility= "hidden";
	document.getElementById(d1).style.visibility= "visible";	
	return;	
		  }