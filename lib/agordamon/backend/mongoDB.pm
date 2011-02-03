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

package agordamon::backend::mongoDB;

use MongoDB;
use MongoDB::OID;

@EXPORT = qw(_exists, query_db, get, write_db);
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

	$self->{connection} = MongoDB::Connection->new(host => $self->{db_host});
	$self->{db} = $self->{connection}->agordamon;

	bless $self, $pkg;
	return $self;
}

sub _exists()
{
	my ($self, $type, $name) = @_;
	my $query = { name => $name };
	if ( $self->query_db($type, $query) ) # .count? mit rueckgabe der anzahl, extra fehler wenn größer 1!
	{
		return 1;
	} else {
		return 0;
	}
}

sub delete_obj_from_db()
{
	my ($self, $type, $query) = @_;
	my $table = $self->{db}->$type;

	my $d = $table->remove($query, {safe => 1});	
	return $d;
	
}

sub query_db
{
	my ($self, $type, $query) = @_;
	# if $query empty get all
	my @return;

	my $table = $self->{db}->$type;
	
	my $data = $table->find($query);
	while (my $dat = $data->next)
	{
#		$self->create_object($type, %{$dat});
		push(@return, $dat);
	}
	return @return;
}

sub get_from_db
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
		my @data = $self->query_db($type, "" );
		foreach my $dat (@data )
		{
		#	$self->create_object($type, %{$dat});
			push(@{$return{$type}}, $dat);
		}
#		@{$return->$type} = @data;
	}
	return %return;
}

sub update_db
{
	my ($self, $type, @objs) = @_;

}
sub update_entry
{
	my ($self, $type, $obj) = @_;
	my $table;
	$table = $self->{db}->$type;
	my $criteria = { name => $obj->{name} };
	my $r = $table->update($criteria, $obj, { safe => 1});
	return $r;
}

sub overwrite_entry
{
	my ($self, $type, $obj) =@_;
	my $table;
	$table = $self->{db}->$type; 
	my $name = $obj->{name};
	my $query = { name => $name };
	my $r = $self->delete_obj_from_db($type, $query);

	$self->insert_entry($type, $obj) if $r;

}
sub insert_entry
{
	my ($self, $type, $obj) = @_;
	my $table;
	my %ids; #what to do with this? into log?
	$table = $self->{db}->$type; 
    $ids{$type} = $table->insert(\%{$obj}, {safe => 1}) || print("write_mongodb(): ", $!);
# TODO errorhandling
}

sub write_db
{
	my ($self, $type, $if_exists, @objs) = @_;

	my $table;
	my %ids;
	$table = $self->{db}->$type;	# check if object already exists.. possible with batch_insert?
	foreach my $obj (@objs)
	{
		if ( $self->_exists($type, $obj->{name} ) == 0 ) 
		{
			$self->insert_entry($type, $obj);
		} else { 
			if ($if_exists =~ /^update$/)
			{
				#update entry, untouched values will be untouched!
				$self->update_entry($type, $obj);
			} elsif ($if_exists =~ /^overwrite$/)
			{
				# overwrite entry (delete and write new one)
				$self->overwrite_entry($type, $obj);
			}
		}
	}
	# FIXME TODO zurückgeben was geschrieben wurde, was nicht, was vorhanden war....
}


