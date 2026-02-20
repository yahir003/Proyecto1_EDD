package ListaUsuarios;
use Moo;
use NodoUsuario;

has 'cabeza' => (is => 'rw', default => sub { undef });

sub insertar {
    my ($self, $codigo, $contrasena, $departamento) = @_;

    my $nuevo = NodoUsuario->new(
        codigo => $codigo,
        contrasena => $contrasena,
        departamento => $departamento
    );

    if (!defined $self->cabeza) {
        $self->cabeza($nuevo);
    } else {
        my $actual = $self->cabeza;
        while (defined $actual->siguiente) {
            $actual = $actual->siguiente;
        }
        $actual->siguiente($nuevo);
    }
}

sub login {
    my ($self, $codigo, $contrasena) = @_;
    my $actual = $self->cabeza;

    while ($actual) {
        if ($actual->codigo eq $codigo && $actual->contrasena eq $contrasena) {
            return $actual;
        }
        $actual = $actual->siguiente;
    }
    return undef;
}

1;
