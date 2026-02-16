package NodoMedicamento;
use Moo;

has 'codigo' => (is => 'rw');
has 'nombre' => (is => 'rw');
has 'principio' => (is => 'rw');
has 'laboratorio' => (is => 'rw');
has 'cantidad' => (is => 'rw');
has 'vencimiento' => (is => 'rw');
has 'precio' => (is => 'rw');
has 'minimo' => (is => 'rw');

has 'siguiente' => (is => 'rw', default => sub { undef });
has 'anterior' => (is => 'rw', default => sub { undef });

1;
