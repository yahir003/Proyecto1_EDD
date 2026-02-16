package ListaInventario;
use strict;
use warnings;
use NodoMedicamento;
use Moo;

has 'cabeza' => (is => 'rw', default => sub { undef });
has 'cola' => (is => 'rw', default => sub { undef });
has 'tamanio' => (is => 'rw', default => sub { 0 });

sub insertar_ordenado {
    my ($self, $codigo,$nombre,$principio,$laboratorio,$cantidad,$vencimiento,$precio,$minimo) = @_;

    my $nuevo = NodoMedicamento->new(
        codigo => $codigo,
        nombre => $nombre,
        principio => $principio,
        laboratorio => $laboratorio,
        cantidad => $cantidad,
        vencimiento => $vencimiento,
        precio => $precio,
        minimo => $minimo
    );

    if (!defined $self->cabeza) {
        $self->cabeza($nuevo);
        $self->cola($nuevo);
    } else {
        my $actual = $self->cabeza;

        while (defined $actual && $actual->codigo lt $codigo) {
            $actual = $actual->siguiente;
        }

        if (!defined $actual) {
            $self->cola->siguiente($nuevo);
            $nuevo->anterior($self->cola);
            $self->cola($nuevo);
        }
        elsif ($actual == $self->cabeza) {
            $nuevo->siguiente($self->cabeza);
            $self->cabeza->anterior($nuevo);
            $self->cabeza($nuevo);
        }
        else {
            my $ant = $actual->anterior;
            $ant->siguiente($nuevo);
            $nuevo->anterior($ant);
            $nuevo->siguiente($actual);
            $actual->anterior($nuevo);
        }
    }

    $self->tamanio($self->tamanio + 1);
}

sub mostrar {
    my ($self) = @_;
    my $actual = $self->cabeza;

    while (defined $actual) {
        print "Codigo: " . $actual->codigo .
              " | Nombre: " . $actual->nombre .
              " | Cantidad: " . $actual->cantidad . "\n";
        $actual = $actual->siguiente;
    }
}

1;
