package NodoEntrega;
use strict;
use warnings;
use Moo;

has 'fecha' => (is => 'rw');
has 'factura' => (is => 'rw');
has 'codigo_medicamento' => (is => 'rw');
has 'cantidad' => (is => 'rw');

has 'siguiente' => (is => 'rw', default => sub { undef });

1;
