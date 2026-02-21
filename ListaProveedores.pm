package ListaProveedores;
use strict;
use warnings;
use NodoProveedor;
use ListaEntregas;
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


sub generar_reporte_graphviz {
    my ($self, $archivo) = @_;

    return unless defined $self->cabeza;

    open(my $fh, ">", $archivo) or die "No se pudo crear archivo";

    print $fh "digraph Proveedores {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [fontname=\"Arial\"];\n";
    print $fh "splines=true;\n";

    my $inicio = $self->cabeza;
    my $prov = $inicio;
    my $p = 0;

    do {
        my $id_prov = "prov$p";
        my $label_prov = "NIT: " . $prov->nit . "\\nEmpresa: " . $prov->empresa;

        # Nodo proveedor (lista principal horizontal)
        print $fh "$id_prov [shape=box, style=filled, fillcolor=lightyellow, label=\"$label_prov\"];\n";

        # Graficar lista de entregas (vertical)
        my $ent = $prov->entregas->cabeza;
        my $e = 0;
        my $anterior_ent = "";

        while ($ent) {
            my $id_ent = "ent_${p}_$e";
            my $label_ent = "Fecha: " . $ent->fecha .
                            "\\nFactura: " . $ent->factura .
                            "\\nCod: " . $ent->codigo_medicamento .
                            "\\nCant: " . $ent->cantidad;

            print $fh "$id_ent [shape=ellipse, style=filled, fillcolor=lightblue, label=\"$label_ent\"];\n";

            # Conexión proveedor -> primera entrega
            if ($e == 0) {
                print $fh "$id_prov -> $id_ent;\n";
            } else {
                # Conexión vertical entre entregas
                print $fh "$anterior_ent -> $id_ent;\n";
            }

            $anterior_ent = $id_ent;
            $ent = $ent->siguiente;
            $e++;
        }

        $prov = $prov->siguiente;
        $p++;

    } while ($prov != $inicio);

    # Conectar proveedores de forma circular (doble enlace visual)
    for (my $i = 0; $i < $p; $i++) {
        my $siguiente = ($i + 1) % $p;
        print $fh "prov$i -> prov$siguiente [dir=both];\n";
    }

    print $fh "}\n";
    close($fh);

    system("dot -Tpng $archivo -o reporte_proveedores.png");
    print "Reporte Proveedores generado: reporte_proveedores.png\n";
}
1;
