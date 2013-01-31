package Lego;

use Template;
use YAML;
use FindBin qw($Bin);

sub new {
    my ($class, %args) = @_;

    my $root = $args{root} || $Bin;

    my $template_dir = "$root/templates";

    my $config = YAML::LoadFile($root . "/" . $args{config});

    my $template = Template->new({
        INCLUDE_PATH => $template_dir,
    });

    my $self = {
        cgi          => $args{cgi},
        key          => $args{key},
        page         => $args{page} || 'page',
        action       => $args{action} || 'action',
        default      => $args{default},
        mapping      => $args{mapping},
        tmpl_dir     => $template_dir,
        tmpl_obj     => $template,
        tmpl_main    => $args{base_tmpl},
        config       => $config,
        root         => $root,
        errors       => [],
    };

    return bless $self, $class;
}

sub template {
    my ($self, $section_name, $vars) = @_;

    ($vars )= $self->members() if !$vars;

    $$vars{section} = $section_name;

    my $output = '';

    $vars = $self->add_tmpl_vars($vars);

    $self->{tmpl_obj}->process($self->{tmpl_main}, $vars, \$output)
        || die "Template process failed: ", $self->{tmpl_obj}->error(), "\n";

    return $output;
}

sub display {
    my ($self, $output) = @_;

    print $self->hdr_html();
    print $output;
}

sub add_tmpl_vars {
    my ($self, $values) = @_;

    return $values;
}

sub process {
    my ($self) = @_;

    my ($vars, $cgi, $page, $action, $default, $mapping) = $self->members();

    if ($self->{config}->{site_down} and !$$vars{test}) {
        $self->site_down();
        return;
    }

    my $action_func = $self->get_function_name($action);
    if ($action_func) {
        $self->$action_func();
    }

    my $page_func = $self->get_function_name($page);

    if ($page_func) {
        $self->$page_func();
    } else {
        my $func = "${page}_default";
        $self->$func;
    }
}

sub get_function_name {
    my ($self, $key) = @_;

    my ($vars, $cgi, $page, $action, $default, $mapping) = $self->members();

    my $function = undef;
    if ($$mapping{$$vars{$key}}) {
        $function = $$mapping{$$vars{$key}};
    } elsif ($default) {
        $function = $$mapping{$default};
    } else {
        $function = $$vars{$key};
    }

    my $func = "";
    if (defined $function && $self->can("${key}_${function}")) {
        $func = "${key}_${function}";
    } else {
        $func = "";
    }

    return $func;

}

sub default {
    my ($self) = @_;

    print "Need to define default.\n";
}

sub site_down {
    my ($self) = @_;

    print 'Site is down.\n';
}

sub members {
    my ($self) = @_;

    my %vars = $self->{cgi}->Vars;

    #add error messages
    $vars{errors} = $self->{errors};

    return (\%vars, $self->{cgi}, $self->{page}, $self->{action}, $self->{default}, $self->{mapping});
}

sub hdr_html {
    my ($self) = @_;

    return $self->{cgi}->header('text/html');
}

sub add_error {
    my ($self, $error) = @_;

    push @{$self->{errors}}, {msg => $error};
}

1;
