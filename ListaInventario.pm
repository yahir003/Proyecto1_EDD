package ListaInventario;
use strict;
use warnings;
use NodoMedicamento;
use Moo;

has 'cabeza' => (is => 'rw', default => sub { undef });
has 'cola'   => (is => 'rw', default => sub { undef });
has 'tamanio'=> (is => 'rw', default => sub { 0 });

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
      " | Cantidad: " . $actual->cantidad .
      " | Vencimiento: " . $actual->vencimiento .
      " | Precio: " . $actual->precio .
      " | Minimo: " . $actual->minimo . "\n";
              "\n";
        $actual = $actual->siguiente;
    }
}

sub buscar {
    my ($self, $codigo) = @_;

    my $actual = $self->cabeza;

    while ($actual) {
        if ($actual->codigo eq $codigo) {
            return $actual;
        }
        $actual = $actual->siguiente;
    }

    return undef;
}

sub aumentar_stock {
    my ($self, $codigo, $cantidad) = @_;
    my $actual = $self->cabeza;

    while ($actual) {
        if ($actual->codigo eq $codigo) {
            $actual->cantidad($actual->cantidad + $cantidad);
            print "Stock actualizado correctamente.\n";
            return;
        }
        $actual = $actual->siguiente;
    }

    print "Medicamento no encontrado en inventario.\n";
}

sub disminuir_stock {
    my ($self, $codigo, $cantidad) = @_;
    my $actual = $self->cabeza;

    while ($actual) {
        if ($actual->codigo eq $codigo) {
            if ($actual->cantidad >= $cantidad) {
                $actual->cantidad($actual->cantidad - $cantidad);
            } else {
                print "Stock insuficiente.\n";
            }
            return;
        }
        $actual = $actual->siguiente;
    }

    print "Medicamento no encontrado en inventario.\n";
}

sub mostrar_disponibilidad {
    my ($self, $busqueda) = @_;
    my $actual = $self->cabeza;

    while ($actual) {
        if ($actual->codigo eq $busqueda || $actual->nombre eq $busqueda) {

            print "\n--- DISPONIBILIDAD DE MEDICAMENTO ---\n";
            print "Codigo: " . $actual->codigo . "\n";
            print "Nombre: " . $actual->nombre . "\n";
            print "Cantidad disponible: " . $actual->cantidad . "\n";
            print "Minimo de reorden: " . $actual->minimo . "\n";

            if ($actual->cantidad <= $actual->minimo) {
                print "Estado: BAJO STOCK\n";
                print "Tiempo estimado de reabastecimiento: Pendiente de proveedor\n";
            } else {
                print "Estado: Stock suficiente\n";
            }

            return;
        }
        $actual = $actual->siguiente;
    }

    print "Medicamento no encontrado en inventario.\n";
}

1;