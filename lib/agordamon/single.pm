#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: 
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.



package agordamon::single;

use agordamon::backend::mongoDB;
use agordamon::host;
use agordamon::service;
use agordamon::contact;
use agordamon::hostgroup;
use agordamon::servicegroup;
use agordamon::contactgroup;

#FIXME fix list
@EXPORT = qw();

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
	bless $self, $pkg;

    if ($params{db_type} eq "mongodb")
    {  
#        use agordamon::backend::mongoDB;
        $self->{db} = agordamon::backend::mongoDB->new( db_host => $params{db_host}, db_user => $params{db_user}, db_pass => $params{db_pass}, db_name => $params{db_name} );
    }

	return $self;
}
sub create_object() {
	my ($self, $type, $obj) = @_;
	
	return $self->{db}->insert_entry($type, $obj);
}

sub get_object() {
	my ($self, $type, $query) = @_;

	return undef if (!$query);

	my @obj = $self->{db}->query_db($type, $query);
	
	my $object;
	if (@obj)
	{
			my %params = %{$obj[0]};
			$object = agordamon::host->new(%params) if ($type eq "host");
			$object = agordamon::service->new(%params) if ($type eq "service");
			$object = agordamon::contact->new(%params) if ($type eq "contact");
			$object = agordamon::hostgroup->new(%params) if ($type eq "hostgroup");
			$object = agordamon::servicegroup->new(%params) if ($type eq "servicegroup");
			$object = agordamon::contactgroup->new(%params) if ($type eq "contactgroup");

			return $object->get_fields();

	} else {
		return undef;
	}
}

sub update_object() {
	my ($self, $type, $obj) = @_;

	return $self->{db}->update_entry($type, $obj);
#FIXME add errorhandling
}


1;
