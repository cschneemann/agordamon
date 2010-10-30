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

use agordamon::conffile;

use MongoDB;
use MongoDB::OID;

@EXPORT = qw(add_srv2host, add_host, del_host, update_config2db, create_nagios_config);
@ISA = qw(agordamon::conffile);

our $VERSION = "0.13";

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
	$self->{db_type} = $params{db_type};
	$self->{db_host} = $params{db_host};
	$self->{db_user} = $params{db_user};
	$self->{db_pass} = $params{db_pass};

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

sub get_host()
{
	my ($self) = @_;

}

sub get_service()
{
	my ($self) = @_;
}

sub get_contact()
{
	my ($self) = @_;
}

# create host in data
sub create_host($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{hosts}}, new agordamon::host(%definition));
}

sub create_hostgroup($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{hostgroups}}, new agordamon::hostgroup(%definition));
}

sub create_hostescalation($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{hostescalations}}, new agordamon::hostescalation(%definition));
}

sub create_hostextinfo($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{hostextinfos}}, new agordamon::hostextinfo(%definition));
}

sub create_hostdependency($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{hostdependencies}}, new agordamon::hostdependency(%definition));
}

sub create_service($\%)
{
	my ($self, %definition) = @_;
	
	push(@{$self->{services}}, new agordamon::service(%definition));
}

sub create_servicegroup($\%)
{
	my ($self, %definition) = @_;
	
	push(@{$self->{servicegroups}}, new agordamon::servicegroup(%definition));
}

sub create_contact($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{contacts}}, new agordamon::contact(%definition));
}

sub create_contactgroup($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{contactgroups}}, new agordamon::contactgroup(%definition));
}

sub create_serviceextinfo($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{serviceextinfos}}, new agordamon::serviceextinfo(%definition));
}

sub create_serviceescalation($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{serviceescalations}}, new agordamon::serviceescalation(%definition));
}

sub create_servicedependency($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{servicedependencies}}, new agordamon::servicedependency(%definition));
}

sub create_command($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{commands}}, new agordamon::command(%definition));
}

sub create_timeperiod($\%)
{
	my ($self, %definition) = @_;
	push(@{$self->{timeperiods}}, new agordamon::timeperiod(%definition));
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

	foreach my $type (@types)
	{
		foreach (@{$self->{$type}})
		{
			$config = $config.$_->create_config($_->get_type());
		}
	}

	return $config;
}

sub load_from_files() # if searchstring empty get all
{
	my ($self, $type, $searchstring) = @_;

	
} 

sub load_from_db()
{
	my ($self, $type, $searchstring) = @_;

}

# delete host from db
sub del_host($)
{
	my ($self, $hostname) = @_;
	
	my %configured_hosts = %{$self->{configured_hosts}};
	my %configured_services = %{$self->{configured_services}};
#FIXME TODO muss aus der DB geloescht werden, nicht nur aus dem hash	
	delete $configured_hosts{$hostname};
	delete $configured_services{$hostname};
}

# add host to db!
sub write_host($\%)
{
	my ($self, %definition) = @_;
	
#	$self->{hosts}[] = new agordamon::host(%definition);

}

# sub read_from_db()
# aus datenbank einlesen, objekte für host, contact, services, etc anlegen


