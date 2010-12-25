#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for hosts, services, contacts. 20100810.
## version: 0.2: give complete nagios definition to hostcreation. 20100807.


## TODO:
# make the internal data structure easier

package agordamon::mongoDB;

use MongoDB;
use MongoDB::OID;

@EXPORT = qw(exists_in_mongodb, delete_ob_from_mongodb, query_mongodb, get_mongodb, write_mongodb);
#@ISA = qw(agordamon::conffile);

our $VERSION = "0.13";

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
#	$self->{db_type} = $params{db_type};
	$self->{db_host} = $params{db_host};
	$self->{db_user} = $params{db_user};
	$self->{db_pass} = $params{db_pass};
	$self->{db_name} = $params{db_name};
	bless $self, $pkg;
	return $self;
}

sub exists_in_mongodb()
{
	my ($self, $type, $query) = @_;
	if ( $self->query_mongodb($type, $query) )
	{
		return 1;
	} else {
		return 0;
	}
}

sub delete_obj_from_mongodb()
{
	my ($self, $type, $name) = @_;
	my $conn = MongoDB::Connection->new(host => $self->{db_host});
	my $db = $conn->agordamon;
	my $table = $db->$type;

	$table->remove(name => $name);	

}

sub query_mongodb
{
	my ($self, $type, $query) = @_;
	# if $query empty get all
	my @return;

	my $conn = MongoDB::Connection->new(host => $self->{db_host});
	my $db = $conn->agordamon;
	my $table = $db->$type;
	
	my $data = $table->find($query);
	while (my $dat = $data->next)
	{
#		$self->create_object($type, %{$dat});
		push(@return, $dat);
	}
	return @return;
}

sub get_mongodb
{
	my ($self, @types) = @_;
	if (!@types)
	{
		@types = qw( hosts hostgroups hostescalations hostextinfos hostdependencies 
					services servicegroups serviceescalations serviceextinfos 
					servicedependencies contacts contactgroups timeperiods commands);
	}
	# if $query empty get all
#TODO alles per return zurückgeben	
	my %return;
	foreach my $type (@types)
	{
		my @data = $self->query_mongodb($type, "" );
#		foreach my $dat (@data )
#
#		{
		#	$self->create_object($type, %{$dat});
#			push(@{$return->$type}, $dat);
#		}
		@{$return->$type} = @data;
	}
	return %return;
}

sub write_mongodb
{
	my ($self, @types, @objs) = @_;
	if (@types eq "")
	{
		@types = qw( hosts hostgroups hostescalations hostextinfos hostdependencies 
					services servicegroups serviceescalations serviceextinfos 
					servicedependencies contacts contactgroups timeperiods commands);
	}

	my $conn = MongoDB::Connection->new(host => $self->{db_host});
    my $db = $conn->agordamon;
#	$db->drop;

	my $table;
	my %ids;
	foreach my $type (@types)
	{
		$table = $db->$type;	# check if object already exists.. possible with batch_insert?
		if ($self->{$type})
		{
			foreach my $obj (@objs )
			{
				if ( $self->exists_in_mongodb($type, \%{$obj} ) == 0 ) 
				{ 
				    $ids{$type} = $table->insert(\%{$obj}, {safe => 1}) || die("write_mongodb(): ", $!);
				} else { 
					print "scohn drin!\n"; 
				}
			}
		}
		
	}
#	$table = $db->test;
#	$table->insert( {name => 'mongo', type => 'database' }, {safe => 1}); #????
}


