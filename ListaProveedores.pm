package ListaProveedores;
use strict;
use warnings;
use NodoProveedor;
use Moo;

has 'cabeza' => (is => 'rw', default => sub { undef });

sub insertar {
    my ($self, $nit,$empresa,$contacto,$telefono,$direccion) = @_;

    my $nuevo = NodoProveedor->new(
        nit => $nit,
        empresa => $empresa,
        contacto => $contacto,
        telefono => $telefono,
        direccion => $direccion
    );

    if (!defined $self->cabeza) {
        $self->cabeza($nuevo);
        $nuevo->siguiente($nuevo);
    } else {
        my $actual = $self->cabeza;
        while ($actual->siguiente != $self->cabeza) {
            $actual = $actual->siguiente;
        }
        $actual->siguiente($nuevo);
        $nuevo->siguiente($self->cabeza);
    }
}

sub mostrar {
    my ($self) = @_;
    return unless defined $self->cabeza;

    my $actual = $self->cabeza;
    do {
        print "NIT: " . $actual->nit .
              " | Empresa: " . $actual->empresa . "\n";
        $actual = $actual->siguiente;
    } while ($actual != $self->cabeza);
}

sub buscar {
    my ($self, $nit) = @_;
    return unless defined $self->cabeza;

    my $actual = $self->cabeza;
    do {
        if ($actual->nit eq $nit) {
            return $actual;
        }
        $actual = $actual->siguiente;
    } while ($actual != $self->cabeza);

    return undef;
}

1;
