package NodoEntrega;
use Moo;

has 'fecha' => (is => 'rw');
has 'factura' => (is => 'rw');
has 'codigo_med' => (is => 'rw');
has 'cantidad' => (is => 'rw');

has 'siguiente' => (is => 'rw', default => sub { undef });

1;
