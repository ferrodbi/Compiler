// Ejemplo (rebuscado) del uso de operadores logicos
// Lee un numero ("x") y si "0 <= x" imprime un "0" y
// repite hasta que "x > 0" e imprime un "1"
{ int x; int y; bool z; 

  z = true; 
  for (; z;) {
    read(x);
    if (! ((x == 0) || (x != x)))
      if (((x > 0) && true) || false ) {
	z = false; 
        print(1);
      }
      else { print(0); }
    else { print(0); }
  }
}
