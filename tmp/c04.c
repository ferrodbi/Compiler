// Ejemplo sencillo de manipulacion de registros.
// Lee un numero ("x") y devuelve "14" si "x > 0"
// y "4" en caso contrario.
{
  struct { int a; bool b; int c; } r;
  int x;

  read (x); r.a = 9; r.c = 5;
  if (x > 0) r.b = true;
  else r.b = false;
  if (r.b) print(r.a + r.c);
  else  print(r.a - r.c);
}
