package NodoUsuario;
use Moo;

has 'codigo' => (is => 'rw');
has 'contrasena' => (is => 'rw');
has 'departamento' => (is => 'rw');

has 'siguiente' => (is => 'rw', default => sub { undef });

1;
