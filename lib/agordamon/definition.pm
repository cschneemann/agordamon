#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for nagios definitiotions.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions. 20100929.



package agordamon::definition;

#FIXME fix list
@EXPORT = qw(valid_field, set_field, get_field, delete_field get_valid_fields);

use strict;
use warnings;

sub valid_field($);
sub set_field($$);
sub get_field($);
sub delete_field($);
sub create_config($);
sub get_valid_fields();
sub get_type();
sub get_field($);

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};
	bless $self, $pkg;

	foreach my $param (keys %params)
	{
		if ($self->valid_field($param))
		{
			$self->{$param} = $params{$param};
		}
	}
	if (! $self->{"name"} )
	{
		$self->{"name"} = $self->{$self->get_type()."_name"};
	}
	return $self;
}

sub delete_field($)
{
	my ($self, $field) = @_;
	delete $self->{$field};

	return 0;
}

sub set_field($$)
{
	my ($self, $field, $data) = @_;
	if ($self->valid_field($field))
	{
		$self->{$field} = $data;
	}
}

sub get_field($)
{
	my ($self, $field) = @_;

	if (exists($self->{$field}))
	{
		return $self->{$field};
	} else {
		return undef;
	}
}

sub get_fields($)
{
	my ($self) = @_;
	my %return;
	foreach my $field ($self->get_valid_fields())
	{
		$return{$field} = $self->get_field($field) if ( defined($self->get_field($field)));
	}
	return %return;
}

sub get_valid_fields()
{
	my ($self, $field) = @_;
	my @valid_fields = qw();

	return @valid_fields;
}

sub valid_field($)
{
	my ($self, $field) = @_;
	my @valid_fields = $self->get_valid_fields();
	if (grep(/^$field$/, @valid_fields))
	{
		return 1;
	} else {
		return 0;
	}
}

sub get_type()
{
	my ($self) = @_;
	return "notset";
}

sub create_config($)
{
	my ($self, $type) = @_;	
	my $config;

	$config = "define $type";
	$config = $config."{\n";
	foreach my $field ( $self->get_valid_fields())
	{
		if ( defined( $self->get_field($field) ) )
		{
			$config = $config."\t $field \t ".$self->get_field($field)."\n" ;
		}
	}
	$config = $config."}\n\n";
	return $config;	
}

