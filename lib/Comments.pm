package Comments;

use CGI;
use XML::Simple;
use Date::Format;
use HTML::Template;
use FindBin qw($Bin);
use strict;

sub xmlFile {
    return "$Bin/data/comments.xml";
}

sub add
{
    my ($name, $text) = @_;

    my $xml = loadXml();

    if ($name eq '' || $name !~ /\s/ || $text eq '')
    {
        addScreen();
        return;
        #$name = 'Anonymous';
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
        return;
    }
    writeXML();
    loadXML();
    view();
}

sub view
{
    my $template = new HTML::Template(filename => "comments.tmpl",
        die_on_bad_params => 0);
    my $comments = sortComments();
    if ($comments)
    {
        $template->param(comments => $comments);
    }

    print CGI::header('text/html');
    print $template->output();

}

sub sortComments
{
    my $xml = loadXML();
    
    my $return;
    for my $time (reverse sort keys %$xml)
    {
        $$xml{$time}{unixtime} = $time;
        push @$return, $$xml{$time}; 
    }

    return $return;
}

sub addScreen
{
    my $template = new HTML::Template(filename => "add_comment.tmpl",
        die_on_bad_params => 0);

    print CGI::header('text/html');
    print $template->output();
}

sub writeXML
{
    my ($xml) = @_;
    
    my $output = XML::Simple->new(NoAttr=>1, RootName=>'data');
    my $newXML = $output->XMLout($xml);
    my $xmlFile = xmlFile();
    open FILE, ">$xmlFile";
    print FILE $newXML;
    close FILE;
}

sub loadXML
{
    return XMLin(xmlFile());
}

1;