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

@EXPORT = qw(exists_in_db, query_db, get_db, write_db);
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

sub exists_in_db()
{
	my ($self, $type, $name) = @_;
	my $query = { name => $name };
	if ( $self->query_db($type, $query) )
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

	$table->remove($query);	
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

sub write_db
{
	my ($self, $type, $if_exists, @objs) = @_;

	my $table;
	my %ids;
	$table = $self->{db}->$type;	# check if object already exists.. possible with batch_insert?
	foreach my $obj (@objs)
	{
		if ( $self->exists_in_db($type, $obj->{name} ) == 0 ) 
		{
			print "writing: ",$obj->{name}, "\n"; 
		    $ids{$type} = $table->insert(\%{$obj}, {safe => 1}) || print("write_mongodb(): ", $!);
		} else { 
	#		print "scohn drin!\n";
			if ($if_exists =~ /^update$/)
			{
				#update entry, untouched values will be untouched!
			} elsif ($if_exists =~ /^overwrite$/)
			{
				# overwrite entry (delete and write new one)
				print "overwrite\n";
			}
		}
	}
}


