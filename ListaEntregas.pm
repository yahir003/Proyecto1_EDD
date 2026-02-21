package ListaEntregas;
use strict;
use warnings;
use Moo;
use NodoEntrega;

has 'cabeza' => (
    is => 'rw',
    default => sub { undef }
);

sub insertar {
    my ($self, $fecha, $factura, $codigo, $cantidad) = @_;

    my $nuevo = NodoEntrega->new(
        fecha => $fecha,
        factura => $factura,
        codigo_medicamento => $codigo,
        cantidad => $cantidad
    );

    if (!defined $self->cabeza) {
        $nuevo->siguiente($nuevo);
        $nuevo->anterior($nuevo);
        $self->cabeza($nuevo);
        return;
    }

    my $ultimo = $self->cabeza->anterior;

    $nuevo->siguiente($self->cabeza);
    $nuevo->anterior($ultimo);

    $ultimo->siguiente($nuevo);
    $self->cabeza->anterior($nuevo);
}

sub recorrer {
    my ($self) = @_;
    return if !defined $self->cabeza;

    my $actual = $self->cabeza;
    do {
        print "Fecha: " . $actual->fecha .
              " | Factura: " . $actual->factura .
              " | Codigo: " . $actual->codigo_medicamento .
              " | Cantidad: " . $actual->cantidad . "\n";

        $actual = $actual->siguiente;
    } while ($actual ne $self->cabeza);
}

sub generar_reporte_graphviz {
    my ($self, $archivo) = @_;
    return if !defined $self->cabeza;

    open(my $fh, ">", $archivo) or die "No se pudo crear el archivo";

    print $fh "digraph Entregas {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=record];\n";

    my $actual = $self->cabeza;
    my $contador = 0;

    do {
        my $id = "N" . $contador;
        print $fh "$id [label=\"{Fecha: " . $actual->fecha .
                  " | Factura: " . $actual->factura .
                  " | Cod: " . $actual->codigo_medicamento .
                  " | Cant: " . $actual->cantidad . "}\"];\n";
        $actual = $actual->siguiente;
        $contador++;
    } while ($actual ne $self->cabeza);

    for (my $i = 0; $i < $contador; $i++) {
        my $sig = ($i + 1) % $contador;
        print $fh "N$i -> N$sig;\n";
        print $fh "N$sig -> N$i;\n";
    }

    print $fh "}\n";
    close($fh);
}
sub mostrar {
    my ($self) = @_;

    if (!defined $self->cabeza) {
        print "No hay entregas registradas.\n";
        return;
    }

    my $actual = $self->cabeza;

    print "\n----- HISTORIAL DE ENTREGAS -----\n";

    do {
        print "Fecha: " . $actual->fecha . "\n";
        print "Factura: " . $actual->factura . "\n";
        print "Codigo medicamento: " . $actual->codigo_medicamento . "\n";
        print "Cantidad: " . $actual->cantidad . "\n";
        print "---------------------------------\n";

        $actual = $actual->siguiente;
    } while ($actual ne $self->cabeza);
}

1;