package MatrizDispersa;
use strict;
use warnings;
use Moo;
use NodoMatriz;

has 'raiz' => (
    is => 'rw',
    default => sub {
        NodoMatriz->new(
            fila => "RAIZ",
            columna => "RAIZ"
        );
    }
);

# ---------- BUSCAR CABECERA FILA (LABORATORIO) ----------
sub buscar_fila {
    my ($self, $lab) = @_;
    my $actual = $self->raiz->abajo;

    while ($actual) {
        return $actual if $actual->fila eq $lab;
        $actual = $actual->abajo;
    }
    return undef;
}

# ---------- BUSCAR CABECERA COLUMNA (MEDICAMENTO) ----------
sub buscar_columna {
    my ($self, $med) = @_;
    my $actual = $self->raiz->derecha;

    while ($actual) {
        return $actual if $actual->columna eq $med;
        $actual = $actual->derecha;
    }
    return undef;
}

# ---------- CREAR CABECERA FILA ----------
sub crear_fila {
    my ($self, $lab) = @_;
    my $nuevo = NodoMatriz->new(fila => $lab);

    my $raiz = $self->raiz;

    if (!$raiz->abajo) {
        $raiz->abajo($nuevo);
        $nuevo->arriba($raiz);
        return $nuevo;
    }

    my $actual = $raiz->abajo;
    while ($actual->abajo) {
        $actual = $actual->abajo;
    }

    $actual->abajo($nuevo);
    $nuevo->arriba($actual);
    return $nuevo;
}

# ---------- CREAR CABECERA COLUMNA ----------
sub crear_columna {
    my ($self, $med) = @_;
    my $nuevo = NodoMatriz->new(columna => $med);

    my $raiz = $self->raiz;

    if (!$raiz->derecha) {
        $raiz->derecha($nuevo);
        $nuevo->izquierda($raiz);
        return $nuevo;
    }

    my $actual = $raiz->derecha;
    while ($actual->derecha) {
        $actual = $actual->derecha;
    }

    $actual->derecha($nuevo);
    $nuevo->izquierda($actual);
    return $nuevo;
}

# ---------- INSERTAR EN MATRIZ DISPERSA ----------
sub insertar {
    my ($self, $lab, $med, $codigo, $cantidad, $fecha, $precio) = @_;

    # Buscar o crear cabeceras
    my $fila = $self->buscar_fila($lab);
    $fila = $self->crear_fila($lab) unless $fila;

    my $col = $self->buscar_columna($med);
    $col = $self->crear_columna($med) unless $col;

    # Crear nodo de valor (celda)
    my $nuevo = NodoMatriz->new(
        fila => $lab,
        columna => $med,
        codigo => $codigo,
        cantidad => $cantidad,
        fecha => $fecha,
        precio => $precio
    );

    # Insertar en fila (horizontal)
    if (!$fila->derecha) {
        $fila->derecha($nuevo);
        $nuevo->izquierda($fila);
    } else {
        my $temp = $fila->derecha;
        while ($temp->derecha) {
            $temp = $temp->derecha;
        }
        $temp->derecha($nuevo);
        $nuevo->izquierda($temp);
    }

    # Insertar en columna (vertical)
    if (!$col->abajo) {
        $col->abajo($nuevo);
        $nuevo->arriba($col);
    } else {
        my $temp = $col->abajo;
        while ($temp->abajo) {
            $temp = $temp->abajo;
        }
        $temp->abajo($nuevo);
        $nuevo->arriba($temp);
    }
}

# ---------- CONSULTAR POR MEDICAMENTO (PUNTO 7) ----------
sub consultar_por_medicamento {
    my ($self, $med) = @_;

    my $col = $self->buscar_columna($med);

    if (!$col) {
        print "No existe informacion de ese medicamento en la matriz.\n";
        return;
    }

    print "\n===== COMPARACION POR LABORATORIO =====\n";
    print "Medicamento: $med\n\n";

    my $actual = $col->abajo;

    while ($actual) {
        print "Laboratorio: " . $actual->fila . "\n";
        print "Codigo: " . $actual->codigo . "\n";
        print "Cantidad disponible: " . $actual->cantidad . "\n";
        print "Precio unitario: Q" . $actual->precio . "\n";
        print "Fecha vencimiento: " . $actual->fecha . "\n";
        print "--------------------------------------\n";
        $actual = $actual->abajo;
    }
}

sub generar_reporte_graphviz {
    my ($self, $archivo) = @_;

    open(my $fh, ">", $archivo) or die "No se pudo crear el archivo DOT";

    print $fh "digraph MatrizDispersa {\n";
    print $fh "rankdir=LR;\n";
    print $fh "node [fontname=\"Arial\"];\n";

    print $fh "raiz [label=\"Matriz Dispersa\", shape=box, style=filled, fillcolor=gray];\n";
    my $fila = $self->raiz->abajo;

    while ($fila) {
        my $lab = $fila->fila;
        my $id_fila = "lab_" . $lab;
        $id_fila =~ s/\s/_/g;

        print $fh "$id_fila [label=\"$lab\", shape=box, style=filled, fillcolor=lightblue];\n";
        print $fh "raiz -> $id_fila;\n";

        # Nodos internos de la fila
        my $actual = $fila->derecha;
        while ($actual) {
            my $id_nodo = "nodo_" . $actual->codigo;
            my $label = "Cod: " . $actual->codigo .
                        "\\nCant: " . $actual->cantidad .
                        "\\nFecha: " . $actual->fecha .
                        "\\nPrecio: Q" . $actual->precio;

            print $fh "$id_nodo [label=\"$label\", shape=circle, style=filled, fillcolor=white];\n";
            print $fh "$id_fila -> $id_nodo;\n";

            my $med = $actual->columna;
            my $id_col = "med_" . $med;
            $id_col =~ s/\s/_/g;

            print $fh "$id_nodo -> $id_col;\n";

            $actual = $actual->derecha;
        }

        $fila = $fila->abajo;
    }

   
    my $col = $self->raiz->derecha;

    while ($col) {
        my $med = $col->columna;
        my $id_col = "med_" . $med;
        $id_col =~ s/\s/_/g;

        print $fh "$id_col [label=\"$med\", shape=box, style=filled, fillcolor=lightyellow];\n";
        print $fh "raiz -> $id_col;\n";

        $col = $col->derecha;
    }

    print $fh "}\n";
    close($fh);

    system("dot -Tpng $archivo -o reporte_matriz.png");

    print "Reporte de matriz dispersa generado: reporte_matriz.png\n";
}
1;