package ListaSolicitudes;
use Moo;
use NodoSolicitud;

has 'cabeza' => (is => 'rw', default => sub { undef });
has 'total'  => (is => 'rw', default => sub { 0 });

sub insertar {
    my ($self, $dep, $cod, $cant, $prio, $just, $fecha) = @_;

    my $nuevo = NodoSolicitud->new(
        departamento => $dep,
        codigo_medicamento => $cod,
        cantidad => $cant,
        prioridad => $prio,
        justificacion => $just,
        fecha => $fecha
    );

    if (!defined $self->cabeza) {
        $nuevo->siguiente($nuevo);
        $nuevo->anterior($nuevo);
        $self->cabeza($nuevo);
    } else {
        my $ultimo = $self->cabeza->anterior;

        $ultimo->siguiente($nuevo);
        $nuevo->anterior($ultimo);

        $nuevo->siguiente($self->cabeza);
        $self->cabeza->anterior($nuevo);
    }

    $self->total($self->total + 1);
}

sub mostrar {
    my ($self) = @_;

    if (!defined $self->cabeza) {
        print "No hay solicitudes pendientes.\n";
        return;
    }

    my $actual = $self->cabeza;
    my $contador = 0;

    print "\n--- SOLICITUDES PENDIENTES ---\n";

    do {
        print "Departamento: " . $actual->departamento .
              " | Codigo: " . $actual->codigo_medicamento.
              " | Cantidad: " . $actual->cantidad .
              " | Prioridad: " . $actual->prioridad .
              " | Justificacion: " . $actual->justificacion .
              " | Fecha: " . $actual->fecha . "\n";

        $actual = $actual->siguiente;
        $contador++;
    } while ($actual != $self->cabeza);

    print "Total de solicitudes pendientes: $contador\n";
}
sub procesar_solicitud {
    my ($self, $inventario) = @_;

    if (!defined $self->cabeza) {
        print "No hay solicitudes pendientes.\n";
        return;
    }

    my $sol = $self->cabeza;

    print "\n--- PRIMERA SOLICITUD PENDIENTE ---\n";
    print "Departamento: " . $sol->departamento . "\n";
    print "Codigo medicamento: " . $sol->codigo_medicamento . "\n";
    print "Cantidad: " . $sol->cantidad . "\n";
    print "Prioridad: " . $sol->prioridad . "\n";
    print "Justificacion: " . $sol->justificacion . "\n";
    print "Fecha: " . $sol->fecha . "\n";

    print "\n1. Aprobar\n2. Rechazar\nOpcion: ";
    chomp(my $op = <STDIN>);

    if ($op == 1) {
        my $med = $inventario->buscar($sol->codigo_medicamento);

        if (!$med) {
            print "El medicamento no existe en inventario.\n";
            return;
        }

        if ($med->cantidad >= $sol->cantidad) {
            $inventario->disminuir_stock($sol->codigo_medicamento, $sol->cantidad);
            print "Solicitud APROBADA y stock actualizado.\n";
            $self->eliminar_primera();
        } else {
            print "Stock insuficiente. No se puede aprobar.\n";
        }

    } elsif ($op == 2) {
        print "Solicitud RECHAZADA.\n";
        $self->eliminar_primera();
    } else {
        print "Opcion invalida.\n";
    }
}
sub ver_primera {
    my ($self) = @_;

    if (!defined $self->cabeza) {
        print "No hay solicitudes pendientes.\n";
        return undef;
    }

    my $n = $self->cabeza;

    print "\n--- PRIMERA SOLICITUD ---\n";
    print "Departamento: " . $n->departamento . "\n";
    print "Codigo: " . $n->codigo_medicamento . "\n";
    print "Cantidad: " . $n->cantidad . "\n";
    print "Prioridad: " . $n->prioridad . "\n";
    print "Fecha: " . $n->fecha . "\n";
    print "Justificacion: " . $n->justificacion . "\n";

    return $n;
}
sub eliminar_primera {
    my ($self) = @_;

    if (!defined $self->cabeza) {
        return;
    }

    if ($self->cabeza->siguiente == $self->cabeza) {
        $self->cabeza(undef);
        $self->total(0);
        return;
    }

    my $ultimo = $self->cabeza->anterior;
    my $nueva = $self->cabeza->siguiente;

    $ultimo->siguiente($nueva);
    $nueva->anterior($ultimo);

    $self->cabeza($nueva);
    $self->total($self->total - 1);
}
1;