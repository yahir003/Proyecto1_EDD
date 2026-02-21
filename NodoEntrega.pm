package NodoEntrega;
use strict;
use warnings;
use Moo;

has 'fecha' => (
    is => 'rw',
    required => 1
);

has 'factura' => (
    is => 'rw',
    required => 1
);

has 'codigo_medicamento' => (
    is => 'rw',
    required => 1
);

has 'cantidad' => (
    is => 'rw',
    required => 1
);

# Puntero al siguiente nodo
has 'siguiente' => (
    is => 'rw',
    default => sub { undef }
);

# Puntero al nodo anterior (clave para doble enlace)
has 'anterior' => (
    is => 'rw',
    default => sub { undef }
);

1;