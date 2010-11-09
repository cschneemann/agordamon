#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for hosts, services, contacts. 20100810.
## version: 0.2: give complete nagios definition to hostcreation. 20100807.


## TODO:
# add *groups
# make the internal data structure easier

package agordamon;

use agordamon::host;
use agordamon::hostdependency;
use agordamon::hostescalation;
use agordamon::hostextinfo;
use agordamon::hostgroup;
use agordamon::service;
use agordamon::servicedependency;
use agordamon::serviceescalation;
use agordamon::serviceextinfo;
use agordamon::servicegroup;
use agordamon::contact;
use agordamon::command;
use agordamon::contactgroup;
use agordamon::timeperiod;

#use agordamon::conffile;

use MongoDB;
use MongoDB::OID;

@EXPORT = qw(add_srv2host, add_host, del_host, update_config2db, create_nagios_config);
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


sub add_srv2host($$);
sub add_host($\%\%);
sub del_host($);
sub update_config2db($);
sub create_nagios_config($);
sub is_valid($$);

sub list_services()
{

}

sub get_object()
{
	my ($self, $type, $name) = @_;
	
}

# function to check if value already exists in structure?
sub does_exist($$)
{
	my ($self, $type, %name) = @_;
#	connect to db
#	query
#	return 	
}

sub create_object($\%)
{
	my ($self, $type, %definition) = @_;
	if ($type eq "host" || $type eq "hosts")
	{
		return push(@{$self->{hosts}}, new agordamon::host(%definition));
	}
	elsif ($type eq "hostgroup" || $type eq "hostgroups")
	{
		return push(@{$self->{hostgroups}}, new agordamon::hostgroup(%definition));
	}
	elsif ($type eq "hostescalation" || $type eq "hostescalations")
	{
		return push(@{$self->{hostescalations}}, new agordamon::hostescalation(%definition));
	}
	elsif ($type eq "hostextinfo" || $type eq "hostextinfos")
	{
		return push(@{$self->{hostextinfos}}, new agordamon::hostextinfo(%definition));
	}
	elsif ($type eq "hostdependency" || $type eq "hostdependencies")
	{
		return push(@{$self->{hostdependencies}}, new agordamon::hostdependency(%definition));
	}
	elsif ($type eq "service" || $type eq "services")
	{
		return push(@{$self->{services}}, new agordamon::service(%definition));
	}
	elsif ($type eq "servicegroup" || $type eq "servicegroups")
	{
		return push(@{$self->{servicegroups}}, new agordamon::servicegroup(%definition));
	}
	elsif ($type eq "contact" || $type eq "contacts")
	{
		return push(@{$self->{contacts}}, new agordamon::contact(%definition));
	}
	elsif ($type eq "contactgroup" || $type eq "contactgroups")
	{
		return push(@{$self->{contactgroups}}, new agordamon::contactgroup(%definition));
	}
	elsif ($type eq "serviceextinfo" || $type eq "serviceextinfos")
	{
		return push(@{$self->{serviceextinfos}}, new agordamon::serviceextinfo(%definition));
	}
	elsif ($type eq "serviceescalation" || $type eq "serviceescalations")
	{
		return push(@{$self->{serviceescalations}}, new agordamon::serviceescalation(%definition));
	}
	elsif ($type eq "servicedependency" || $type eq "servicedendencies")
	{
		return push(@{$self->{servicedependencies}}, new agordamon::servicedependency(%definition));
	}
	elsif ($type eq "command" || $type eq "commands")
	{
		return push(@{$self->{commands}}, new agordamon::command(%definition));
	}
	elsif ($type eq "timeperiod" || $type eq "timeperiods")
	{
		return push(@{$self->{timeperiods}}, new agordamon::timeperiod(%definition));
	}
	else {
		return undef;
	}
}

sub add_member2group()
{
	my ($self, $type, $group, $member) = @_;
	if ($type eq "hostgroup" || $type eq "servicegroup")
	{
		foreach (@{$self->{$type."s"}}) #FIXME find a better way for doing this, works but looks strange...
		{
			if ($_->get_field($type."_name") eq $group)
			{
				$_->add_member($member);
				last;
			}
		}
	}
}

sub add_group2member()
{
	my ($self, $type, $host, $group) = @_;
	if ($type eq "host" || $type eq "service")
	{
		foreach (@{$self->{$type."s"}}) #FIXME find a better way for doing this, works but looks strange...
		{
			if (defined($_->get_field($type."_name")))
			{
				if ($_->get_field($type."_name") eq $host)
				{
					$_->add_group($group);
					last;
				}
			}
		}
	}
}

# needed function?
# function to change a field for definition
sub change_field()
{
	my ($self, $type, $name, $field, $data) = @_;
	
	foreach (@{$self->{$type."s"}})
	{
		if (defined($_->get_field($type."_name")))
		{
			if ($_->get_field($type."_name") eq $name)
			{
				$_->set_field($field, $data);
			}
		}
	}
}

# go through $type and create config for each element
sub create_config($)
{
	my ($self, @types) = @_;
	my $config = "";

	if (@types eq "")
	{
		@types = qw( hosts hostgroups hostescalations hostextinfos hostdependencies 
					services servicegroups serviceescalations serviceextinfos 
					servicedependencies contacts contactgroups timeperiods commands);
	}

	foreach my $type (@types)
	{
		foreach (@{$self->{$type}})
		{
			$config = $config.$_->create_config($_->get_type());
		}
	}

	return $config;
}

# delete host from db
sub del_host($)
{
	my ($self, $hostname) = @_;
	
}

# add host to db!
sub write_host($\%)
{
	my ($self, %definition) = @_;
	

}
sub query_mongodb
{
	my ($self, $type, %query) = @_;
	# if $query empty get all

	my $conn = MongoDB::Connection->new(host => $self->{db_host});
	my $db = $conn->agordamon23;
	my $table = $db->$type;
	
	my $data;
	my $key = keys %query;
	$data = $table->find({$key => $query{$key}});
	while (my $dat = $data->next)
	{
		$self->create_object($type, %{$dat});
	}
}

sub get_mongodb
{
	my ($self, @types) = @_;
	if (!defined(@types))
	{
		@types = qw( hosts hostgroups hostescalations hostextinfos hostdependencies 
					services servicegroups serviceescalations serviceextinfos 
					servicedependencies contacts contactgroups timeperiods commands);
	}
	# if $query empty get all

	my $conn = MongoDB::Connection->new(host => $self->{db_host});
	my $db = $conn->agordamon23;
	my $table;
	
	foreach my $type (@types)
	{
		my $data;
		$table = $db->$type;
		$data = $table->find;
		while (my $dat = $data->next)
		{
			$self->create_object($type, %{$dat});
		}
	}
}

sub write_mongodb
{
	my ($self, @types) = @_;
	if (@types eq "")
	{
		@types = qw( hosts hostgroups hostescalations hostextinfos hostdependencies 
					services servicegroups serviceescalations serviceextinfos 
					servicedependencies contacts contactgroups timeperiods commands);
	}

	my $conn = MongoDB::Connection->new(host => $self->{db_host});
    my $db = $conn->agordamon23;
	my $table;
	my %ids;
	foreach my $type (@types)
	{
		if ($self->{$type})
		{
			$table = $db->$type;	# check if object already exists.. possible with batch_insert?
		    $ids{$type} = $table->batch_insert(\@{$self->{$type}}, {safe => 1}) || die($!);
		}
		
	}
	$table = $db->test;
	$table->insert( {name => 'mongo', type => 'database' }, {safe => 1});

}


