package Comments;

use CGI;
use XML::Simple;
use Date::Format;
use HTML::Template;
use FindBin qw($Bin);
use strict;

sub writeXML
{
    my ($xml, $xmlFile) = @_;

    #use Data::Dumper;print Dumper $xml;exit;

    my $output = XML::Simple->new(NoAttr=>1, RootName=>'data');
    my $newXML = $output->XMLout($xml);

    open FILE, ">$xmlFile";
    print FILE $newXML;
    close FILE;
}

sub loadXML
{
    my ($xmlFile) = @_;
    return XMLin($xmlFile);
}

sub add
{
    my ($name, $text, $xmlFile) = @_;

    my $xml = loadXML($xmlFile);

    if ($name eq '' || $name !~ /\s/ || $text eq '')
    {
        $@ = "Name or comment can not be empty.  Name must contain a space.";
        return;
    }

    if ($text ne '')
    {
        my $ts = time2str('%a %Y %b %d %r %Z', time);
        my $time = time;
        my $hash = { name => $name, text => $text, timestamp => $ts };
        $$xml{"c" . $time} = $hash;

    }

    #Ignore messages that contain html
    if ($text =~ /\<.*\>/) {
        $@ = "Comment can not contain html code.";
        return;
    }

    writeXML($xml, $xmlFile);

    return 1;
}

sub bulk_delete {
    my ($ids, $xmlFile) = @_;

    my $xml = loadXML($xmlFile);
    for my $id (@$ids) {
        delete $$xml{$id};
    }

    writeXML($xml, $xmlFile);

    return 1;
}

sub sorted
{
    my ($xmlFile) = @_;

    my $xml = loadXML($xmlFile);

    my $return;
    for my $time (reverse sort keys %$xml)
    {
        $$xml{$time}{unixtime} = $time;
        push @$return, $$xml{$time};
    }

    return $return;
}

1;
