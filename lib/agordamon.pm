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
#FIXME move to agordamon::multi
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

@EXPORT = qw(add_srv2host, add_host, del_host, update_config2db, create_nagios_config);
#@ISA = qw(agordamon::conffile);

our $VERSION = "0.23";

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
	$self->{db_type} = $params{db_type};
	#TODO FIXME Fehlerbehandlung wenn Parameter fehlen
	if ($params{db_type} eq "mongodb") 
	{
		use agordamon::backend::mongoDB;
		$self->{database} = agordamon::backend::mongoDB->new( db_host => $params{db_host}, db_user => $params{db_user}, db_pass => $params{db_pass}, db_name => $params{db_name} );
	} 
	if ( $params{db_type} eq "mysql")
#	{
#		use agordamon::backend::MySQL;
#		$self->{database} = new agordamon::backend::MySQL( db_host => $params{db_host}, db_user => $params{db_user}, db_pass => $params{db_pass}, db_name => $params{db_name} );
#	}
	if ( $params{db_type} eq "files")
	{
		use agordamon::backend::Files;
		$self->{database} = new agordamon::backend::Files( nagios_cfg =>$params{nagios_cfg} );
	}

	$self->{if_exists} = "";
	bless $self, $pkg;
	return $self;
}


sub add_srv2host($$);
sub add_host($\%\%);
sub del_host($);
sub update_config2db($);
sub create_nagios_config($);
sub is_valid($$);

sub set()
{
	my ($self, $field, $value ) = @_;
	$self->{$field} = $value;
}

sub list_objects($$$)
{
	my ($self, $type, $field, $value) = @_;

	# TODO test if $field is valid
	return grep { if ($_->{$field} ) { $_->{$field} =~ m/$value/ } } @{$self->{$type}};

}


# function to check if value already exists in structure?
sub does_exist($$)
{
	my ($self, $type, %name) = @_;
#	connect to db
#	query
#	return 	
}

sub get_counter_of() # returns counter where a element is in elementsarray
{
	my ($self, $type, $query) = @_;
	my @return;
	my ($searchfield, $name);

	foreach my $key (keys %$query)
	{
		$searchfield = $key;
		$name = $query->{$key};
	}
 #FIXME clean these if-causes
	if ($self->{$type} )
	{
		for ( my $i=0; $i < scalar(@{$self->{$type}}); $i++)
		{
			if ( $self->{$type}[$i]->get_field($searchfield) )
			{
				if ( $self->{$type}[$i]->get_field($searchfield) eq $name )
				{
					push(@return, $i);
				}
			}
		}
	}

	if ($#return > 0)
	{
		return @return;
	} else {
		return undef;
	}
}

#sub get_object {
#	my ($self, $type, $query) = @_;
#	my %obj = $self->{$type}	
#    return grep { if ($_->{$field} ) { $_->{$field} =~ m/$value/ } } @{$self->{$type}};
#
#}

sub create_object($\%)
{
	my ($self, $type, %definition) = @_;
	my $temp;
	if ($type eq "host" )
	{
		return push(@{$self->{host}}, new agordamon::host(%definition));
	}
	elsif ($type eq "hostgroup" )
	{
		return push(@{$self->{hostgroup}}, new agordamon::hostgroup(%definition));
	}
	elsif ($type eq "hostescalation" )
	{
		return push(@{$self->{hostescalation}}, new agordamon::hostescalation(%definition));
	}
	elsif ($type eq "hostextinfo" )
	{
		return push(@{$self->{hostextinfo}}, new agordamon::hostextinfo(%definition));
	}
	elsif ($type eq "hostdependency" )
	{
		return push(@{$self->{hostdependency}}, new agordamon::hostdependency(%definition));
	}
	elsif ($type eq "service" )
	{
		return push(@{$self->{service}}, new agordamon::service(%definition));
	}
	elsif ($type eq "servicegroup" )
	{
		return push(@{$self->{servicegroup}}, new agordamon::servicegroup(%definition));
	}
	elsif ($type eq "contact" )
	{
		return push(@{$self->{contact}}, new agordamon::contact(%definition));
	}
	elsif ($type eq "contactgroup" )
	{
		return push(@{$self->{contactgroup}}, new agordamon::contactgroup(%definition));
	}
	elsif ($type eq "serviceextinfo" )
	{
		return push(@{$self->{serviceextinfo}}, new agordamon::serviceextinfo(%definition));
	}
	elsif ($type eq "serviceescalation" )
	{
		return push(@{$self->{serviceescalation}}, new agordamon::serviceescalation(%definition));
	}
	elsif ($type eq "servicedependency")
	{
		return push(@{$self->{servicedependency}}, new agordamon::servicedependency(%definition));
	}
	elsif ($type eq "command")
	{
		return push(@{$self->{command}}, new agordamon::command(%definition));
	}
	elsif ($type eq "timeperiod")
	{
		return push(@{$self->{timeperiod}}, new agordamon::timeperiod(%definition));
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
		foreach (@{$self->{$type}}) #FIXME find a better way for doing this, works but looks strange...
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
		foreach (@{$self->{$type}}) #FIXME find a better way for doing this, works but looks strange...
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
# mehr suchparameter ermöglichen, dass auch beim richtigen geändert wird
sub change_field()
{
	my ($self, $type, $name, $field, $data) = @_;
	
	foreach (@{$self->{$type}})
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

	if (!@types )
	{
		@types = qw( host hostgroup hostescalation hostextinfo hostdependency 
					service servicegroup serviceescalation serviceextinfo 
					servicedependency contact contactgroup timeperiod command);
	}

	foreach my $type (@types)
	{
		foreach (@{$self->{$type}})
		{
			$config = $config.$_->create_config($_->get_type()) if defined;
		}
	}

	return $config;
}

# TODO how to delete a service? from hostconfig?
sub delete_srv() # host, service übergeben
{

}
# delete host from struct
# delete also from db if db is configured
# delete more than only host!
# TODO use map for this too?!
sub delete_object()
{
	my ($self, $type, $query) = @_;
	my @to_delete = $self->get_counter_of($type, $query);
	if (@to_delete)	
	{
		@to_delete = sort {$b <=> $a} @to_delete if (scalar(@to_delete) > 1 );
		foreach my $counter (@to_delete)
		{	
				$counter = 0 if (!defined($counter));# but why?
				splice(@{$self->{$type}}, $counter);
		}
	}
	$self->{database}->delete_obj_from_db($type, $query);
}

sub write_db()
{
	my ($self, @types) = @_;
	my %objs;
    if (@types eq "")
    {   
        @types = qw( host hostgroup hostescalation hostextinfo hostdependency 
                    service servicegroup serviceescalation serviceextinfo 
                    servicedependency contact contactgroup timeperiod command);
    }
	
	foreach my $type (@types)
	{
		my @items;
		foreach my $item (@{$self->{$type}})
		{
				my %item = $item->get_fields if (defined $item);
				push(@items, \%item);
		}
		$self->{database}->write_db($type, $self->{if_exists}, @items, );
	}

}

sub load_object_from_db()
{
    my ($self, $type, $query) = @_;

	my @return = $self->{database}->query_db($type, $query);

	#return @return;
	foreach (@return)
	{
	$self->create_object($type, %{$_});
	}
}

sub load_from_db()
{
	my ($self, @types) = @_;
	if (!@types) #FIXME why does this not work here?! 
    {   
        @types = qw( host hostgroup hostescalation hostextinfo hostdependency 
                    service servicegroup serviceescalation serviceextinfo 
                    servicedependency contact contactgroup timeperiod command);
    }
	
	my %objects = $self->{database}->get_from_db(@types);

	foreach my $type (keys %objects)
	{
		for my $item (@{$objects{$type}})
		{
			$self->create_object($type, %{$item});	
		}
	}
}

