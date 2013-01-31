package Index;

use Lego;
use FindBin qw($Bin);
use lib "$Bin/lib";
@ISA = (Lego);

use Comments;

sub new {
    my ($class, $cgi) = @_;

    my $mapping = {
        # page name is mapped to function name automagically.
        # special case key to functional mapping should go here.
        # hopefully won't be any, but nice to have option.
    };

    my $self = Lego->new(
        cgi       => $cgi,
        mapping   => $mapping,
        base_tmpl => 'index_default_main.tt',
        config    => "config/config.yml",
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

sub page_default {
    my ($self) = @_;

    my $comments = Comments::sorted($self->{root} . "/data/comments.xml");

    my ($vars) = $self->members();
    $$vars{comments} = $comments;

    $self->display($self->template('index_frontpage.tt', $vars));
}

sub page_paintball {
    my ($self) = @_;

    my ($vars) = $self->members();
    $$vars{title} = 'Paintball Prices';

    $self->display($self->template('paintball.tt', $vars));
}

sub page_airsoft {
    my ($self) = @_;

    my ($vars) = $self->members();
    $$vars{title} = 'AirSoft Prices';

    $self->display($self->template('airsoft.tt', $vars));
}

sub page_lasertag {
    my ($self) = @_;

    my ($vars) = $self->members();
    $$vars{title} = 'LaserTag Prices';

    $self->display($self->template('lasertag.tt', $vars));
}

sub page_fields {
    my ($self) = @_;

    my ($vars) = $self->members();
    $$vars{title} = 'Fields';

    $self->display($self->template('fields.tt', $vars));
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
