#!/usr/bin/perl

use CGI;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Index;

use strict;
use warnings;

my $page = new Index(new CGI());
use Data::Dumper;

$page->process();
