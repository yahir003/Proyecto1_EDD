use lib ".";
use ListaInventario;
use ListaProveedores;
use ListaEntregas;
use ListaSolicitudes;

my $solicitudes = ListaSolicitudes->new();
my $proveedores = ListaProveedores->new();
my $inventario  = ListaInventario->new();

# Credenciales del administrador
my $admin_user = "admin";
my $admin_pass = "1234";

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
        print "9. Cerrar sesion\n";
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

            print "\n--- REGISTRAR ENTREGA ---\n";
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
                print "Medicamento no existe en inventario.\n";
                next;
            }

            print "Fecha entrega: ";
            chomp(my $fecha = <STDIN>);

            print "Numero factura: ";
            chomp(my $factura = <STDIN>);

            print "Cantidad entregada: ";
            chomp(my $cantidad = <STDIN>);

            $proveedor->entregas->insertar($fecha, $factura, $codigo, $cantidad);
            $inventario->aumentar_stock($codigo, $cantidad);

            print "Entrega registrada correctamente.\n";
        }
        elsif ($op == 7) {

            print "\n--- MOSTRAR ENTREGAS ---\n";
            print "NIT proveedor: ";
            chomp(my $nit = <STDIN>);

            my $proveedor = $proveedores->buscar($nit);

            if ($proveedor) {
                print "\nHistorial de entregas del proveedor:\n";
                $proveedor->entregas->mostrar();
            } else {
                print "Proveedor no encontrado.\n";
            }
        }
        elsif ($op == 8) {
            $solicitudes->procesar_solicitud($inventario); 
        }
        elsif ($op == 9) {
            print "Cerrando sesion...\n";
            last;
        }
        else {
            print "Opcion no valida.\n";
        }
    }
}

# ---------------- MENU USUARIO ----------------
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
            print "\n--- SOLICITUDES PENDIENTES ---\n";
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