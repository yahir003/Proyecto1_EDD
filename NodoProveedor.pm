package NodoProveedor;
use Moo;
use ListaEntregas;

has 'nit' => (is => 'rw');
has 'empresa' => (is => 'rw');
has 'contacto' => (is => 'rw');
has 'telefono' => (is => 'rw');
has 'direccion' => (is => 'rw');

has 'entregas' => (
    is => 'rw',
    default => sub { ListaEntregas->new() }
);

has 'siguiente' => (is => 'rw', default => sub { undef });

1;
