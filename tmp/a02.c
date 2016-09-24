// Ejemplo sencillo de manipulación de registros
{ int x;
  struct{ int c1; bool c2; } r; 


  read(x); r.c1 = x * 1;
  if ( r.c1 >= 0 ) r.c2 = true;
  else r.c2 = false;
  if (r.c1 == true) print(1);
  else print(0);
}
