use strict;
use warnings;
use lib ".";
use Term::ANSIColor;
use MatrizDispersa;

use ListaInventario;
use ListaProveedores;
use ListaEntregas;
use ListaSolicitudes;

my $solicitudes = ListaSolicitudes->new();
my $proveedores = ListaProveedores->new();
my $inventario  = ListaInventario->new();
my $matriz = MatrizDispersa->new();


my $admin_user = "admin";
my $admin_pass = "1234";

# ---------------- REGISTRAR MEDICAMENTO ----------------
sub registrarMedicamento {

    print "\n--- REGISTRAR MEDICAMENTO ---\n";

    print "Codigo: ";
    chomp(my $codigo = <STDIN>);

    print "Nombre: ";
    chomp(my $nombre = <STDIN>);

    print "Principio activo: ";
    chomp(my $principio = <STDIN>);

    print "Laboratorio: ";
    chomp(my $laboratorio = <STDIN>);

    print "Precio unitario: ";
    chomp(my $precio = <STDIN>);

    print "Cantidad inicial: ";
    chomp(my $cantidad = <STDIN>);

    print "Fecha de vencimiento: ";
    chomp(my $vencimiento = <STDIN>);

    print "Nivel minimo: ";
    chomp(my $minimo = <STDIN>);

    if ($inventario->buscar($codigo)) {
        print "El medicamento ya existe.\n";
        return;
    }

  $inventario->insertar_ordenado(
    $codigo, $nombre, $principio,
    $laboratorio, $cantidad,
    $vencimiento, $precio, $minimo
);

$matriz->insertar(
    $laboratorio,
    $nombre,
    $codigo,
    $cantidad,
    $vencimiento,
    $precio
);

   $inventario->generar_reporte_graphviz("reporte_inventario.dot");
print "Medicamento registrado correctamente.\n";
}

# ---------------- CARGA MASIVA CSV ----------------
sub cargaMasivaCSV {

    print "\n--- CARGA MASIVA CSV ---\n";
    print "Ingrese nombre del archivo CSV: ";
    chomp(my $archivo = <STDIN>);

    if (!-e $archivo) {
        print "El archivo no existe.\n";
        return;
    }

    open(my $fh, "<", $archivo) or die "No se pudo abrir el archivo";

    # Saltar encabezado
    <$fh>;

    while (my $linea = <$fh>) {
        chomp($linea);

        my ($codigo,$nombre,$principio,$laboratorio,
            $precio,$cantidad,$vencimiento,$minimo) = split(/,/, $linea);

        # Evitar duplicados en inventario
        if (!$inventario->buscar($codigo)) {

            # 1. Insertar en inventario (tu estructura principal)
            $inventario->insertar_ordenado(
                $codigo, $nombre, $principio,
                $laboratorio, $cantidad,
                $vencimiento, $precio, $minimo
            );

            # 2. INSERTAR TAMBIÉN EN LA MATRIZ DISPERSA (PUNTO 7)
            if (defined $matriz) {
               $matriz->insertar(
                    $laboratorio,
                    $nombre,
                    $codigo,
                    $cantidad,
                    $vencimiento,
                    $precio
        );
            }
        }
    }

    close($fh);
    print "Carga masiva completada y matriz dispersa actualizada.\n";
    $inventario->generar_reporte_graphviz("reporte_inventario.dot");
}
# ---------------- REGISTRAR PROVEEDOR ----------------
sub registrarProveedor {

    print "\n--- REGISTRAR PROVEEDOR ---\n";

    print "NIT: ";
    chomp(my $nit = <STDIN>);

    if ($proveedores->buscar($nit)) {
        print "El proveedor ya existe.\n";
        return;
    }

    print "Empresa: ";
    chomp(my $empresa = <STDIN>);

    print "Contacto: ";
    chomp(my $contacto = <STDIN>);

    print "Telefono: ";
    chomp(my $telefono = <STDIN>);

    print "Direccion: ";
    chomp(my $direccion = <STDIN>);

    $proveedores->insertar($nit, $empresa, $contacto, $telefono, $direccion);

    print "Proveedor registrado correctamente.\n";
}

# ---------------- SOLICITAR REABASTECIMIENTO ----------------
sub solicitarReabastecimiento {

    print "\n--- SOLICITAR REABASTECIMIENTO ---\n";

    print "Departamento: ";
    chomp(my $dep = <STDIN>);

    print "Codigo del medicamento: ";
    chomp(my $codigo = <STDIN>);

    if (!$inventario->buscar($codigo)) {
        print "El medicamento no existe en inventario.\n";
        return;
    }

    print "Cantidad solicitada: ";
    chomp(my $cantidad = <STDIN>);

    print "Prioridad (Alta/Media/Baja): ";
    chomp(my $prioridad = <STDIN>);

    print "Justificacion: ";
    chomp(my $justificacion = <STDIN>);

    print "Fecha: ";
    chomp(my $fecha = <STDIN>);

    $solicitudes->insertar(
        $dep, $codigo, $cantidad,
        $prioridad, $justificacion, $fecha
    );

    $solicitudes->generar_reporte_graphviz("reporte_solicitudes.dot");

    print "Solicitud registrada correctamente.\n";
}

# ---------------- LOGIN ADMIN ----------------
sub loginAdmin {

    print "\n--- LOGIN ADMIN ---\n";

    print "Usuario: ";
    chomp(my $user = <STDIN>);

    print "Contrasena: ";
    chomp(my $pass = <STDIN>);

    if ($user eq $admin_user && $pass eq $admin_pass) {
        print "Acceso concedido.\n";
        return 1;
    } else {
        print "Usuario o contrasena incorrectos.\n";
        return 0;
    }
}

# ---------------- MENU ADMIN ----------------
sub menuAdmin {

    while (1) {

        print "\n------ MENU ADMIN ------\n";
        print "1. Registrar medicamento\n";
        print "2. Mostrar inventario\n";
        print "3. Carga masiva CSV\n";
        print "4. Registrar proveedor\n";
        print "5. Mostrar proveedores\n";
        print "6. Registrar entrega proveedor\n";
        print "7. Mostrar entrega proveedor\n";
        print "8. Procesar solicitudes\n";
        print "9. Reporte medicamentos criticos\n";
        print "10.Consultar por laboratorio\n";
        print "11. Consultar inventario por laboratorio/medicina (Matriz dispersa)\n";
        print "12. Reporte Graphviz Inventario\n";
        print "13. Reporte Graphviz Solicitudes\n";
        print "14. Reporte Graphviz Proveedores\n";
        print "15. Reporte Matriz Dispersa\n";
        print "16. Salir\n";
        print "Opcion: ";

        chomp(my $op = <STDIN>);

        if ($op == 1) {
            registrarMedicamento();
        }
        elsif ($op == 2) {
            $inventario->mostrar();
        }
        elsif ($op == 3) {
            cargaMasivaCSV();
        }
        elsif ($op == 4) {
            registrarProveedor();
        }
        elsif ($op == 5) {
            $proveedores->mostrar();
        }
                elsif ($op == 6) {

            print "\n--- REGISTRAR ENTREGA DE PROVEEDOR ---\n";

            print "NIT proveedor: ";
            chomp(my $nit = <STDIN>);

            my $proveedor = $proveedores->buscar($nit);

            if (!$proveedor) {
                print "Proveedor no encontrado.\n";
                next;
            }

            print "Codigo medicamento: ";
            chomp(my $codigo = <STDIN>);

            my $medicamento = $inventario->buscar($codigo);

            if (!$medicamento) {
                print "El medicamento no existe en el inventario.\n";
                next;
            }

            print "Fecha de entrega: ";
            chomp(my $fecha = <STDIN>);

            print "Numero de factura: ";
            chomp(my $factura = <STDIN>);

            print "Cantidad entregada: ";
            chomp(my $cantidad = <STDIN>);

            # Insertar en lista enlazada de entregas del proveedor
            $proveedor->entregas->insertar(
                $fecha,
                $factura,
                $codigo,
                $cantidad
            );

            # Actualizar stock en inventario
            $inventario->aumentar_stock($codigo, $cantidad);
            $inventario->generar_reporte_graphviz("reporte_inventario.dot");

            print "Entrega registrada correctamente en lista enlazada.\n";
        }
        elsif ($op == 7) {

            print "\n--- HISTORIAL DE ENTREGAS POR PROVEEDOR ---\n";

            print "Ingrese NIT del proveedor: ";
            chomp(my $nit = <STDIN>);

            my $proveedor = $proveedores->buscar($nit);

            if (!$proveedor) {
                print "Proveedor no encontrado.\n";
                next;
            }

            if ($proveedor->entregas) {
                $proveedor->entregas->mostrar();
            } else {
                print "El proveedor no tiene entregas registradas.\n";
            }
        }
        
        elsif ($op == 8) {
            $solicitudes->procesar_solicitud($inventario);
            $solicitudes->generar_reporte_graphviz("reporte_solicitudes.dot");
        }
        elsif ($op == 9) {

    print "\n--- CONSULTA POR LABORATORIO ---\n";
    print "Ingrese nombre del laboratorio: ";
    chomp(my $lab = <STDIN>);

    $inventario->consultar_por_laboratorio($lab);
}
        elsif ($op == 10) {
           
 print "\n--- REPORTE DE INVENTARIO POR LABORATORIO ---\n";
    print "Ingrese nombre del laboratorio: ";
    chomp(my $lab = <STDIN>);

    $inventario->consultar_por_laboratorio($lab);
        }
        elsif ($op == 11) {
     print "\n--- CONSULTA EN MATRIZ DISPERSA ---\n";
    print "Ingrese nombre del medicamento: ";
    chomp(my $med = <STDIN>);

    $matriz->consultar_por_medicamento($med);
}
        elsif ($op == 12) {
    $inventario->generar_reporte_graphviz("reporte_inventario.dot");
}
elsif ($op == 13) {
    $solicitudes->generar_reporte_graphviz("reporte_solicitudes.dot");
}
elsif ($op == 14) {
    $proveedores->generar_reporte_graphviz("reporte_proveedores.dot");
}
elsif ($op == 15) {
    $matriz->generar_reporte_graphviz("reporte_matriz.dot");
}
elsif ($op == 16) {
    print "Saliendo...\n";
    last;
}

        else {
            print "Opcion invalida.\n";
        }
    }
}

# ---------------- MENU USUARIO (SIN HISTORIAL) ----------------
sub menuUsuario {

    while (1) {

        print "\n------ MENU USUARIO DEPARTAMENTAL ------\n";
        print "1. Consultar disponibilidad de medicamentos\n";
        print "2. Solicitar reabastecimiento\n";
        print "3. Ver solicitudes pendientes\n";
        print "4. Salir\n";
        print "Opcion: ";

        chomp(my $op = <STDIN>);

        if ($op == 1) {
            print "\n--- CONSULTAR DISPONIBILIDAD ---\n";
            print "Ingrese codigo o nombre del medicamento: ";
            chomp(my $busqueda = <STDIN>);
            $inventario->mostrar_disponibilidad($busqueda);
        }
        elsif ($op == 2) {
            solicitarReabastecimiento();
        }
        elsif ($op == 3) {
            $solicitudes->mostrar();
        }
        elsif ($op == 4) {
            last;
        }
        else {
            print "Opcion invalida.\n";
        }
    }
}

# ---------------- LOGIN PRINCIPAL ----------------
while (1) {

    print "\n----- LOGIN -----\n";
    print "1. Administrador\n";
    print "2. Usuario Departamental\n";
    print "3. Salir\n";
    print "Opcion: ";

    chomp(my $tipo = <STDIN>);

    if ($tipo == 1) {
        if (loginAdmin()) {
            menuAdmin();
        }
    }
    elsif ($tipo == 2) {
        menuUsuario();
    }
    elsif ($tipo == 3) {
        print "Saliendo del sistema...\n";
        last;
    }
    else {
        print "Tipo de usuario invalido.\n";
    }
}


