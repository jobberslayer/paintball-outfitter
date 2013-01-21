package Index;

use Lego;
use FindBin qw($Bin);
@ISA = (Lego);

sub new {
    my ($class, $cgi) = @_;

    my $mapping = {
        add => 'add',
    };

    my $self = Lego->new(
        cgi       => $cgi,
        mapping   => $mapping,
        key       => 'page',
        base_tmpl => 'index_default_main.tt',
        config    => "$Bin/config/config.yml",
    );

    return bless $self, $class;
}

sub remodeling {
    my ($self) = @_;

    my ($vars) = $self->members();

    $$vars{problem} = 'Remodeling';
    $$vars{title} = 'Remodeling';

    $self->display($self->template('index_construction.tt', $vars));
}

sub add_tmpl_vars {
    my ($self, $values) = @_;

    $$values{current_year} = (localtime(time))[5] + 1900;

    return $values;
}

sub default {
    my ($self) = @_;

    $self->display($self->template('index_frontpage.tt'));
}

sub site_down {
    my ($self) = @_;

    $self->remodeling();
}

sub add {
    my ($self) = @_;

    print "in add\n";
}

1;
