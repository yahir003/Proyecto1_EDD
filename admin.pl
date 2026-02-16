use lib ".";
use ListaInventario;
use ListaProveedores;
my $proveedores = ListaProveedores->new();
my $inventario = ListaInventario->new();

sub registrarMedicamento {
    print "\n--- REGISTRAR MEDICAMENTO ---\n";

    print "Codigo: "; chomp(my $c = <STDIN>);
    print "Nombre: "; chomp(my $n = <STDIN>);
    print "Principio activo: "; chomp(my $p = <STDIN>);
    print "Laboratorio: "; chomp(my $l = <STDIN>);
    print "Cantidad: "; chomp(my $q = <STDIN>);
    print "Fecha vencimiento: "; chomp(my $v = <STDIN>);
    print "Precio: "; chomp(my $pr = <STDIN>);
    print "Minimo reorden: "; chomp(my $m = <STDIN>);

    $inventario->insertar_ordenado($c,$n,$p,$l,$q,$v,$pr,$m);
    print "Medicamento registrado correctamente.\n";
}

sub registrarProveedor {
    print "\n--- REGISTRAR PROVEEDOR ---\n";
    print "NIT: "; chomp(my $nit = <STDIN>);
    print "Empresa: "; chomp(my $emp = <STDIN>);
    print "Contacto: "; chomp(my $cont = <STDIN>);
    print "Telefono: "; chomp(my $tel = <STDIN>);
    print "Direccion: "; chomp(my $dir = <STDIN>);

    $proveedores->insertar($nit,$emp,$cont,$tel,$dir);
    print "Proveedor registrado.\n";
}


sub cargaMasivaCSV {
    print "\n--- CARGA MASIVA CSV ---\n";
    print "Ingrese la ruta del archivo CSV: ";
    chomp(my $ruta_archivo = <STDIN>);

    open(my $fh, '<', $ruta_archivo) or die "No se pudo abrir el archivo\n";
    my $header = <$fh>; 

    print "\nContenido del archivo:\n";
    while (my $linea = <$fh>) {
        print $linea;
    }
    print "\n";
    seek($fh, 0, 0);

    while (my $linea = <$fh>) {
        chomp($linea);
        my ($c,$n,$p,$l,$q,$v,$pr,$m) = split(',', $linea);
        $inventario->insertar_ordenado($c,$n,$p,$l,$q,$v,$pr,$m);
    }

    close($fh);
    print "Medicamentos cargados correctamente.\n";
}

while (1) {
    print "\n------ MENU ADMIN ------\n";
    print "1. Registrar medicamento\n";
    print "2. Mostrar inventario\n";
    print "3. Carga masiva CSV\n";
    print "4. Registrar proveedor\n";
    print "5. | Mostrar proveedores\n";
    print "6. Salir\n";
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
    elsif ($op == 5){
        $proveedores->mostrar();
    
    }
    elsif ($op == 6) {
        last;
    }
    else {
        print "Opcion no valida. Intente de nuevo.\n";
    }
}
