package ListaEntregas;
use Moo;
use NodoEntrega;

has 'cabeza' => (is => 'rw', default => sub { undef });

sub insertar {
    my ($self, $fecha, $factura, $codigo, $cantidad) = @_;

    my $nuevo = NodoEntrega->new(
        fecha => $fecha,
        factura => $factura,
        codigo_medicamento => $codigo,
        cantidad => $cantidad
    );

    if (!defined $self->cabeza) {
        $self->cabeza($nuevo);
    } else {
        my $actual = $self->cabeza;
        while (defined $actual->siguiente) {
            $actual = $actual->siguiente;
        }
        $actual->siguiente($nuevo);
    }
}

sub mostrar {
    my ($self) = @_;
    my $actual = $self->cabeza;

    while ($actual) {
        print "Fecha: " . $actual->fecha .
              " | Factura: " . $actual->factura .
              " | Codigo: " . $actual->codigo_medicamento .
              " | Cantidad: " . $actual->cantidad . "\n";
        $actual = $actual->siguiente;
    }
}

1;
