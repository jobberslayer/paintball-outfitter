#!/usr/bin/perl

use CGI;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use CommentsEdit;

use strict;
use warnings;

my $page = new CommentsEdit(new CGI());
$page->process();
