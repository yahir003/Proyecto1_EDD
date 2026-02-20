package NodoSolicitud;
use Moo;

has 'departamento' => (is => 'rw');
has 'codigo_medicamento' => (is => 'rw');
has 'cantidad' => (is => 'rw');
has 'prioridad' => (is => 'rw');
has 'justificacion' => (is => 'rw');
has 'fecha' => (is => 'rw');

has 'siguiente' => (is => 'rw', default => sub { undef });
has 'anterior' => (is => 'rw', default => sub { undef });

1;