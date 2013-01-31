package CommentsEdit;

use Lego;
use FindBin qw($Bin);
use lib "$Bin/../lib";
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
        root      => "$Bin/..",
    );

    $self->{comment_xml} = $self->{root} . "/data/comments.xml";

    return bless $self, $class;
}

sub page_default {
    my ($self) = @_;

    my $comments = Comments::sorted($self->{comment_xml});

    my ($vars) = $self->members();
    $$vars{comments} = $comments;
    $$vars{title} = "Edit Comments";

    $self->display($self->template('comments_edit.tt', $vars));
}

sub action_add {
    my ($self) = @_;

    my ($vars) = $self->members();

    Comments::add($$vars{name}, $$vars{comment}, $self->{comment_xml});
    $self->add_error($@) if $@;
}

sub action_delete {
    my ($self) = @_;

    my ($vars) = $self->members();

    my @ids = ();
    for my $key (keys %$vars) {
        if ($key =~ /pick_(.*)/) {
            push @ids, $1;
        }
    }

    Comments::bulk_delete(\@ids, $self->{comment_xml});
    $self->add_error($@) if $@;
}

sub site_down {
    my ($self) = @_;

    $self->remodeling();
}

sub remodeling {
    my ($self) = @_;

    my ($vars) = $self->members();

    $$vars{problem} = 'Remodeling';
    $$vars{title} = 'Remodeling';

    $self->display($self->template('index_construction.tt', $vars));
}
