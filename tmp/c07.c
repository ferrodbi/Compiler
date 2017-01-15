// Criba de Eratostenes: calcula los numeros primos > 1 y < 150 
{
  bool a[150];
  int max;     // Numero maximo para buscar
  int n;       // Siguiente numero primo  
  int i;
  bool OK;

  read(max); 
  // Comprueba que es un numeo admisible
  for (OK = false; !OK; ) {
    if (max > 1) 
      if (max < 150) OK = true; 
      else read(max);
    else read(max);
  }

  // Inicializa el vector de posible primos
  for (i=2; i <= max; i++) a[i] = true; 

  // Criba de Earatostenes
  n = 2;  
  for (OK = false; !OK; ) {
    // Eliminamos los multiplos de "n"
    for (i = 2; (i * n) <= max; i++) a[i * n] = false; 
    // Buscamos es sigiente primo
    for (i = n + 1;  !a[i] && (i <= max); i++) {}
    // control del fin (n * n > max)
    if ((i * i) < max) n = i;
    else OK = true;
  }

  // visualiza los primos ontenidos menosres que "max"
  i = 2;
  for (i=2; i <= max; i++) {
    if (a[i]) print(i); else {}
  }
}
