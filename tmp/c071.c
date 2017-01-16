// Criba de Eratostenes: calcula los numeros primos > 1 y < 150 
{
  int a[150];
  int max;     // Numero maximo para buscar
  int n;       // Siguiente numero primo  
  int i;
  int OK;

  read(max); 
  // Comprueba que es un numeo admisible
  for (OK = 0; OK == 0; ) {
    if (max > 1) 
      if (max < 150) OK = 1; 
      else read(max);
    else read(max);
  }

  // Las dos siguientes instrucciones son anyadidas
  a[0] = 0;
  a[1] = 0;
  // Inicializa el vector de posible primos
  for (i=2; i <= max; i++) a[i] = 1; 

  // Criba de Earatostenes
  n = 2;  
  for (OK = 0; OK == 0; ) {
    // Eliminamos los multiplos de "n"
    for (i = 2; (i * n) <= max; i++) a[i * n] = 0; 
    // Buscamos es sigiente primo
    for (i = n + 1;  a[i] == 0 && (i <= max); i++) {}
    // control del fin (n * n > max)
    if ((i * i) < max) n = i;
    else OK = 1;
  }

  // visualiza los primos ontenidos menosres que "max"
  i = 2;
  for (i=2; i <= max; i++) {
    if (a[i] == 1) print(i); else {}
  }
}
