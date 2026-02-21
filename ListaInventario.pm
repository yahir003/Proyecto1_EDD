package ListaInventario;
use strict;
use warnings;
use NodoMedicamento;
use Moo;
use Term::ANSIColor;

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

    if (!$self->{cabeza}) {
        print "Inventario vacio.\n";
        return;
    }

    my $actual = $self->{cabeza};

    print "\n========== INVENTARIO DE MEDICAMENTOS ==========\n";

    while ($actual) {

        my $stock = $actual->{cantidad};
        my $minimo = $actual->{minimo};
        my $vencimiento = $actual->{vencimiento};

        my $estado = "NORMAL";
        my $color = "green";

       
        if ($stock <= $minimo) {
            $estado = "BAJO STOCK";
            $color = "red";
        }

        elsif ($vencimiento le "2026-06-01") {
            $estado = "PROXIMO A VENCER";
            $color = "yellow";
        }

        print color($color);
        print "Codigo: $actual->{codigo}\n";
        print "Nombre: $actual->{nombre}\n";
        print "Stock: $stock\n";
        print "Nivel minimo: $minimo\n";
        print "Vencimiento: $vencimiento\n";
        print "Estado: $estado\n";
        print "--------------------------------------\n";
        print color("reset");

        $actual = $actual->{siguiente};
    }
}

sub reporte_criticos {
    my ($self) = @_;

    if (!$self->{cabeza}) {
        print "\nNo hay medicamentos en el inventario.\n";
        return;
    }

    my $actual = $self->{cabeza};
    my $encontrado = 0;

    print "\n===== REPORTE DE MEDICAMENTOS CRITICOS =====\n";

    while ($actual) {

        if ($actual->{cantidad} <= $actual->{minimo}) {
            $encontrado = 1;
            print "Codigo: " . $actual->{codigo} . "\n";
            print "Nombre: " . $actual->{nombre} . "\n";
            print "Stock actual: " . $actual->{cantidad} . "\n";
            print "Nivel minimo: " . $actual->{minimo} . "\n";
            print "Estado: CRITICO (Reabastecimiento urgente)\n";
            print "-----------------------------------------\n";
        }

        $actual = $actual->{siguiente};
    }

    if (!$encontrado) {
        print "No hay medicamentos en estado critico.\n";
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

sub consultar_por_laboratorio {
    my ($self, $nombre_lab) = @_;

    if (!defined $self->{cabeza}) {
        print "Inventario vacio.\n";
        return;
    }

    my $actual = $self->{cabeza};
    my $encontrado = 0;

    print "\n===== CONSULTA POR LABORATORIO =====\n";

    while ($actual) {

        if (lc($actual->{laboratorio}) eq lc($nombre_lab)) {

            $encontrado = 1;

            print "Laboratorio: " . $actual->{laboratorio} . "\n";
            print "Nombre medicamento: " . $actual->{nombre} . "\n";
            print "Precio unitario: Q" . $actual->{precio} . "\n";
            print "Cantidad disponible: " . $actual->{cantidad} . "\n";
            print "------------------------------------\n";
        }

        $actual = $actual->{siguiente};
    }

    if (!$encontrado) {
        print "No se encontraron medicamentos de ese laboratorio.\n";
    }
}

sub generar_reporte_graphviz {
    my ($self, $archivo) = @_;

    open(my $fh, ">", $archivo) or die "No se pudo crear el archivo DOT";

    print $fh "digraph Inventario {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [shape=rectangle, style=filled, fontname=\"Arial\"];\n";

    if (!defined $self->cabeza) {
        print $fh "vacio [label=\"Inventario vacio\", fillcolor=white];\n";
        print $fh "}\n";
        close($fh);
        system("dot -Tpng $archivo -o reporte_inventario.png");
        print "Reporte Inventario generado: reporte_inventario.png\n";
        return;
    }

    my $actual = $self->cabeza;
    my $i = 0;

    # Nodo puntero primero (requisito del PDF)
    print $fh "primero [shape=plaintext, label=\"PRIMERO\"];\n";

    while ($actual) {

        my $id = "med$i";

        # ===== COLORES SEGUN EL PDF =====
        my $color = "lightgreen"; # Normal

        # Rojo = bajo stock
        if (defined $actual->minimo && $actual->cantidad <= $actual->minimo) {
            $color = "red";
        }
        # Amarillo = proximo a vencer (si tiene fecha registrada)
        elsif (defined $actual->vencimiento && $actual->vencimiento ne "") {
            $color = "yellow";
        }

        my $label = "Codigo: " . $actual->codigo .
                    "\\nNombre: " . $actual->nombre .
                    "\\nCantidad: " . $actual->cantidad .
                    "\\nVence: " . $actual->vencimiento;

        print $fh "$id [fillcolor=$color, label=\"$label\"];\n";

        # Conectar puntero primero al nodo cabeza
        if ($i == 0) {
            print $fh "primero -> $id;\n";
        }

        # Flechas bidireccionales (DOBLEMENTE ENLAZADA)
        if ($actual->siguiente) {
            my $sig = "med" . ($i + 1);
            print $fh "$id -> $sig;\n";
            print $fh "$sig -> $id;\n";
        }

        $actual = $actual->siguiente;
        $i++;
    }

    # Nodo puntero ultimo
    my $ultimo = "med" . ($i - 1);
    print $fh "ultimo [shape=plaintext, label=\"ULTIMO\"];\n";
    print $fh "$ultimo -> ultimo;\n";

    print $fh "}\n";
    close($fh);

    system("dot -Tpng $archivo -o reporte_inventario.png");
    print "Reporte Inventario generado: reporte_inventario.png\n";
}
1;