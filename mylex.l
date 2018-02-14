/*
	Realizado por Adrián Sánchez Cerrillo
	Grado en Ingeniería Informática.- Grupo A
	Asignatura: Modelos de Computación
	Práctica: 3 (Lex)
*/

 	/*----- Sección de Declaraciones --------------*/
%{

#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <vector>
#include <string>
#include <cmath>
#include <limits>

using namespace std;

vector<string> Zona; 
vector<float>  Magnitud;
vector<double>  Latitud;
vector<double>  Longitud;
vector<string> Fecha;
vector<string> Hora;

bool hora, coordenada;
string cadena;

void eliminar_tag (string &str);
void print_menu();
double distanciaCoordenadas(const double &LAT1, const double &LONG1, const double &LAT2, const double &LONG2);


%}

digito		[0-9]
letra		[A-Z]
signo		(\-|\+)
numero		({digito}+)
suc_digitos ({digito}{digito}{digito}{digito})
simbolo 	[\<\>\/]
exclusion   [^ \t\n]+

Coordenada 	({signo}?{digito}?{digito}\.{suc_digitos})
Magnitud	({digito}\.{digito})
EtTAR       ("<td class=\"tar\">")
EtTAL       ("<td class=\"tal\">")
Zona		(({letra}[ ]?)+)
Fecha		({digito}{digito}\/{digito}{digito}\/{suc_digitos})
Hora		(([01]?{digito}|2[0-3]):[0-5]{digito}:[0-5]{digito})
%%
	/*----- Sección de Reglas ----------------*/ 

{exclusion}{Fecha}{exclusion}	{
									cadena = yytext; 
									eliminar_tag(cadena);
									Fecha.push_back(cadena);;
								}

{exclusion}{Hora}{exclusion}	{  
							        if (hora){ 
										cadena = yytext; 
										eliminar_tag(cadena);
										Hora.push_back(cadena);
										hora = false;
									}
									else{
										hora = true;
									}
								}

{EtTAR}{Coordenada}			    {
									cadena = yytext;
									eliminar_tag(cadena);

									if (coordenada){
										Latitud.push_back(stod(cadena));
										coordenada = false;
									}
									else{
										Longitud.push_back(stod(cadena));
										coordenada = true;
									}
								}

{EtTAL}{Zona}{exclusion}		{
									cadena = yytext;
									eliminar_tag(cadena);
									Zona.push_back(cadena);
								}

{EtTAR}{Magnitud}" "			{
									cadena = yytext;
									eliminar_tag(cadena);

									Magnitud.push_back(stof(cadena));
								}


[^ \t\n]+	{ }

[ \t]+	{ }

\n		{ }

%%
	/*----- Sección de Procedimientos --------*/  

int main (int argc, char *argv[]) {
	string localizacion = "Granada";
	double latitud  = 37.1886273;
	double longitud = -3.5907775;
	char eleccion = '0';
	double magnitud, media;
	int index;

	while (yyin == NULL){

	  	yyin = fopen ("IGN.html", "rt");

	  	if (yyin != NULL){
	  		cout << "\nFichero \"IGN.html\" encontrado." << endl;
	  	}

	  	if (yyin == NULL){
	  		char opcion = '0';

	  		cout << "El fichero IGN.html no se puede abrir" << endl;

	  		cout << "¿Desea descargar el archivo? (s/n)?" << endl;

			
			while (opcion == '0'){
				cin >> opcion;

				if (opcion == 's' || opcion == 'S'){
					system("wget www.ign.es/web/ign/portal/ultimos-terremotos -q -O IGN.html");
					cout << "\nDescarga realizada." << endl;
				}
				else if (opcion == 'n' || opcion == 'N'){
					cout << "El fichero IGN.html es necesario para el funcionamiento de este programa." << "\n\n";

					exit(-1);
				}
				else{
					opcion = '0';
				}
	  		}
	 	}
	}

hora = coordenada = true;

yylex ();

index = -1;
magnitud = media = 0.0;

for (int i = 0; i < Fecha.size(); i++){
	
	if (Magnitud[i] > magnitud){
		index = i;
		magnitud = Magnitud[i];
	}

	media += Magnitud[i];
}

media = media/Fecha.size();


do{
	
	print_menu();
	cin >> eleccion;

	system("clear");

	switch (eleccion){
		
		case '1':
			for (int i = 0; i < Fecha.size(); i++){
				cout << "\nTerremoto en \'" << Zona[i] << "\'"
				     << "(" << Latitud[i] << ", " << Longitud[i] << ")"
				     << " el día " << Fecha[i] << " a las " << Hora[i] 
				     << " de magnitud " << Magnitud[i] << " mbLg" << endl;
			}
			
			break;
		
		case '2': 

			cout << "El último terremoto se produjo el día " << Fecha[0]
				 << " a las " << Hora[0] << " (Hora GMT)" <<"\nLocalización: " << Zona[0] << endl;
			cout << "Magnitud: " << Magnitud[0] << " mbLg";

			break;

		case '3':{
			double distancia = std::numeric_limits<double>::max();
			double cercana;
			int indice;

			for (int i = 0; i < Fecha.size(); i++){
				cercana = distanciaCoordenadas(latitud, longitud, Latitud[i], Longitud[i]);

				if (cercana < distancia){
					distancia = cercana;
					indice    = i;
				}
			}

			cout << "El terremoto más cercano a " << localizacion << " fue el producido en " << Zona[indice] 
	    		 << "\nDía: " << Fecha[indice] 
		         << "\nDistancia aproximada: " << distancia << " Km." 
                 <<	"\nMagnitud: " << Magnitud[indice] 
				 << endl; 
		}
			break;
		
		case '4': 

			cout << Fecha.size() << " terremotos producidos en los últimos días en la península y alrededores!" << endl;

			cout  << "\n> La media de las magnitudes de los últimos terremotos es de " << media << " mbLg" << endl;

			cout << "\n> El terremoto más intenso ha sido el producido en " << Zona[index] 
				 << " el día " << Fecha[index]          
                 << "\nIntensidad máxima: " << Magnitud[index] << " mbLg" 
                 << endl;

			break;
		
		case '5': 
			
			cout << "La localización definida actualmente es " << localizacion 
                 << "\nCoordenadas [LAT,LONG] = [" << latitud << "," << longitud << "]" 
                 << endl;

			break;

		case '6': 
			
			cout << "\nEscriba el nombre de su localización: ";
			cin >> localizacion;

			cout << "\nEscriba la latitud de su localización: ";
			cin >> latitud;

			cout << "\nEscriba la longitud de su localización: ";
			cin >> longitud;

			cout << "Localización modificada con éxito." << endl;
			break;
		
		default: 
			system("reset");
			break;
	}

	
} while (eleccion != '7');


return 0;
}


void eliminar_tag (string &str){
	std::size_t first, last;
	int n_tag = 0;

	for (int i = 0; i < str.size(); i++){
		
		if (str[i] == '<'){
			n_tag++;
		}
	}

	for (int i = 0; i < n_tag; i++ ){
		first = str.find("<");
		last  = str.find(">");

		str.erase(first, last+1);
	}
}

void print_menu(){
	cout << "\n==============================================================================" << endl;
	cout << "\n Seleccione una opción:" << endl;
	cout << "\t1.- Mostrar todos los terremotos." << endl;
	cout << "\t2.- Mostrar el último terremoto." << endl;
	cout << "\t3.- Mostrar el terremoto más cercano a tu localización." << endl;
	cout << "\t4.- Mostrar estadísticas." << endl;
	cout << "\t5.- Mostrar mi localización definida." << endl;
	cout << "\t6.- Modificar localización actual." << endl;
	cout << "\t7.- Salir." << endl;
	cout << "\n-> ";
}

double distanciaCoordenadas(const double &LAT1, const double &LONG1, const double &LAT2, const double &LONG2){
	const double Pi    = 3.141592653;
	const double Radio = 6371.0;

	double LA1 = LAT1  * Pi / 180.0;
	double LN1 = LONG1 * Pi / 180.0;
	double LA2 = LAT2  * Pi / 180.0;
	double LN2 = LONG2 * Pi / 180.0;

    double distancia, latitud, longitud, a, b;
    
    distancia = 0;
    
    latitud  = LA2 - LA1;
    longitud = LN2 - LN1;

    a = sin(latitud/2.0) * sin(latitud/2.0) + 
    	cos(LA1) * cos(LA2) * sin(longitud/2.0) * sin(longitud/2.0);

    b = 2 * atan2(sqrt(a), sqrt(1-a));

    distancia = Radio * b;
    
    return distancia;
}
