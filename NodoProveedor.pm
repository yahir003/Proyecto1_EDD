package NodoProveedor;
use Moo;

has 'nit' => (is => 'rw');
has 'empresa' => (is => 'rw');
has 'contacto' => (is => 'rw');
has 'telefono' => (is => 'rw');
has 'direccion' => (is => 'rw');

has 'lista_entregas' => (is => 'rw', default => sub { undef });
has 'siguiente' => (is => 'rw', default => sub { undef });

1;
