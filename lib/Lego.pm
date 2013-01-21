package Lego;

use Template;
use YAML;
use FindBin qw($Bin);

sub new {
    my ($class, %args) = @_;

    my $template_dir = "$Bin/templates";

    my $config = YAML::LoadFile($args{config});

    my $template = Template->new({
        INCLUDE_PATH => $template_dir,
    });

    my $self = {
        cgi          => $args{cgi},
        key          => $args{key},
        default      => $args{default},
        mapping      => $args{mapping},
        tmpl_dir     => $template_dir,
        tmpl_obj     => $template,
        tmpl_main    => $args{base_tmpl},
        config       => $config,
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

    my ($vars, $cgi, $key, $default, $mapping) = $self->members();

    if ($self->{config}->{site_down} and !$$vars{test}) {
        $self->site_down();
        return;
    }

    my $function;
    if ($$mapping{$$vars{$key}}) {
        $function = $$mapping{$$vars{$key}};
    } elsif ($default) {
        $function = $$mapping{$default};
    } else {
        $function = 'default';
    }

    $self->$function();
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

    return (\%vars, $self->{cgi}, $self->{key}, $self->{default}, $self->{mapping});
}

sub hdr_html {
    my ($self) = @_;

    return $self->{cgi}->header('text/html');
}

1;
