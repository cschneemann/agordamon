#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: split configuration for distributed usage.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: split config into files for distributed server and master. 20100930.


package agordamon:distributed;


@EXPORT = qw();

our $VERSION = "0.12"

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};

	bless $self, $pkg;
	return $self;
}

# main files
# nagios.cfg
# objects


# distributed files
# nagios.cfg
# objects




