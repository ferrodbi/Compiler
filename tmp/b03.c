// Ejemplo (sin sentido) sobre opeadores logicos: 5 errores
{ int a[20];
  bool b;
  int  c;
  int  b;                         // Identificador repetido

  b = ((a[2] > 0) && true) || c;  // Error en "expresion"
  b = ! (a[2] * 10);              // Error en "expresion unaria"
  b = a[20] == b;                 // Error en "expresion de igualdad"
  if (a[20] < b )                 // Error en "expresion de relacional"
    a[20] = c;
  else {}
}
