package NodoMatriz;
use Moo;

has 'fila' => (is => 'rw');        # laboratorio
has 'columna' => (is => 'rw');     # medicamento

has 'codigo' => (is => 'rw');
has 'cantidad' => (is => 'rw');
has 'fecha' => (is => 'rw');
has 'precio' => (is => 'rw');

# Punteros ortogonales (matriz dispersa real)
has 'arriba' => (is => 'rw', default => sub { undef });
has 'abajo' => (is => 'rw', default => sub { undef });
has 'izquierda' => (is => 'rw', default => sub { undef });
has 'derecha' => (is => 'rw', default => sub { undef });

1;