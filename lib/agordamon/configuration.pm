#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for hosts, services, contacts. 20100810.
## version: 0.2: give complete nagios definition to hostcreation. 20100807.


package agordamon:configuration;


@EXPORT = qw(add_srv2host, add_host, del_host, update_config2db, create_nagios_config);

our $VERSION = "0.12"

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
	$self->{mongoDB_host} = $params{db_host};

	bless $self, $pkg;
	return $self;
}


#TODO connect funktion auslagern...
sub create_nagios_config($)
{
	my ($self, $type) = @_;
	my $connection = MongoDB::Connection->new(host => $self->{mongoDB_host});
    my $db = $connection->sism;
    my $hosts = $db->hosts;
    my $services = $db->services;

	my ($all_hosts, $all_services, @return);	
	if ($type eq "full")
	{
		$all_hosts = $hosts->find;
		$all_services = $services->find;
	}
	push(@return,"");

	while ( my $host = $all_hosts->next)
	{
		push(@return, "define host {\n");
		foreach my $hkey (keys %{$host} )
		{
			push(@return, "\t ". $hkey. "\t". $host->{$hkey}. "\n") if ($hkey ne "_id");
		}
		push(@return, "}\n\n");
	}
	while ( my $srv = $all_services->next)
	{
		push(@return, "define service {\n");
		foreach my $skey (keys %{$srv} )
		{
			push(@return, "\t". $skey. "\t". $srv->{$skey}. "\n") if ($skey ne "_id");	
		}
		push(@return, "}\n\n");
	}
	return  join("", @return);
}

sub update_config2db($)
{
	my ($self ) = @_;
#host nach host hinzufügen... foreach....
	my %configured_hosts = %{$self->{configured_hosts}};
	my ($tmp, $srv);

	
	my %insert_host;
	my %insert_service;
	foreach $tmp (keys(%configured_hosts))
	{
		foreach my $key (keys(%{$configured_hosts{$tmp}}))
		{
			# Abfrage einbauen, ob $key gueltige option ist
			$insert_host{$key} = $configured_hosts{$tmp}{$key};
		}
		$self->update_host(0, %insert_host);
	}

# services...
	my %configured_services = %{$self->{configured_services}};
	foreach $srv  (keys %configured_services )
	{
		foreach my $srvh (keys %{$configured_services{$srv}} )
		{
			$insert_service{$srvh} = $configured_services{$srv}{$srvh};
		}
		$self->update_service(0, %insert_service);
	# nur überschreiben,wenn $configured_hosts{$tmp}{"edited"} != 1
	}

}


sub update_service($\%)
{
	my ($self, $user_edited, %insert_service) = @_;
	my $connection = MongoDB::Connection->new(host => $self->{mongoDB_host});
	my $db = $connection->sism;
	my $services = $db->services;
	$services->update( {"hostname" => $insert_service{"hostname"},
                        "service_description" => $insert_service{"service_description"},
                        "edited" => { '$ne' => 1 } 
                        }, \%insert_service, {upsert => 1});	
}

sub exists_in_db($$)
{
	my ($self, $type, $name) = @_;

	my $connection = MongoDB::Connection->new(host => $self->{mongoDB_host});
	my $db = $connection->sism;
	my $data;
	if ($type eq "hosts")
	{
		$data = $db->$type;
	}		
}	
		
 
sub update_host($\%)
{
	my ($self, $user_edited, %insert_host) = @_;
	my $connection = MongoDB::Connection->new(host => $self->{mongoDB_host});
	my $db = $connection->sism;
	my $hosts = $db->hosts;
#	TODO	ueberlegen was hier sinn macht.. was passiert wenn die bedingung nicht zutrifft? neu angelegt?
# methode schreiben um zu schauen ob ein host existiert..
	if (!$self->exists_in_db($insert_host{"hostname"}))
	{
		$hosts->insert (\%insert_host);
#		$hosts->update( {"hostname" => $insert_host{"hostname"} , "edited" => { '$ne' => 1 } }, \%insert_host, {upsert => 1});	
	}
}

	
#TODO connect funktion auslagern...
sub create_nagios_config($)
{
	my ($self, $type) = @_;
	my $connection = MongoDB::Connection->new(host => $self->{mongoDB_host});
    my $db = $connection->sism;
    my $hosts = $db->hosts;
    my $services = $db->services;

	my ($all_hosts, $all_services, @return);	
	if ($type eq "full")
	{
		$all_hosts = $hosts->find;
		$all_services = $services->find;
	}
	push(@return,"");

	while ( my $host = $all_hosts->next)
	{
		push(@return, "define host {\n");
		foreach my $hkey (keys %{$host} )
		{
			push(@return, "\t ". $hkey. "\t". $host->{$hkey}. "\n") if ($hkey ne "_id");
		}
		push(@return, "}\n\n");
	}
	while ( my $srv = $all_services->next)
	{
		push(@return, "define service {\n");
		foreach my $skey (keys %{$srv} )
		{
			push(@return, "\t". $skey. "\t". $srv->{$skey}. "\n") if ($skey ne "_id");	
		}
		push(@return, "}\n\n");
	}
	return  join("", @return);
}

