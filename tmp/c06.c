// Calcula el maximo comun divisor de dos numeros naturales > 0. 
// Por ejemplo, la salida esperada para 42 y 56 es 14.
// 450,360->90; 150,180->30; 
{
  struct { int x; int y; } A;
  struct { int n; int m; } B;
  int i; int j;

  read(i); read(j);
  A.x = i; A.y = j;
  for (;(A.x != A.y);) {
    if ( A.x > A.y) { 
      B.n = A.y; 
      B.m = A.x - A.y; 
    }
    else { 
      B.n = A.x; 
      B.m = A.y - A.x; 
    }
    A.x = B.n;
    A.y = B.m;
  }
  print(A.x);
}
