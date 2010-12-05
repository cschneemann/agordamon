#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for hosts, services, contacts. 20100810.
## version: 0.2: give complete nagios definition to hostcreation. 20100807.


use agordamon::definition;

package agordamon::host;

#FIXME fix list
@EXPORT = qw(valid_field, set_field, get_field, delete_field);

@ISA = qw(agordamon::definition);
use strict;
use warnings;

sub get_valid_fields()
{   
    my ($self, $field) = @_;
	my @valid_fields = qw(use name register host_name alias display_name address 
						parents hostgroups check_command initial_state 
						max_check_attempts check_interval retry_interval 
						active_checks_enabled passive_checks_enabled check_period 
						obsess_over_host check_freshness freshness_threshold 
						event_handler event_handler_enabled low_flap_threshold 
						high_flap_threshold flap_detection_enabled flap_detection_options 
						process_perf_data retain_status_information retain_nonstatus_information 
						contacts contact_groups notification_interval first_notification_delay 
						notification_period notification_options notifications_enabled 
						stalking_options notes notes_url action_url icom_image icon_image_alt 
						vrml_image statusmap_image 2d_coords 3d_coords );

    return @valid_fields;
}

sub add_group
{
    my ($self, $member) = @_;
	if (defined($self->get_field("hostgroups")))
	{
	    $self->set_field("hostgroups", $self->get_field("hostgroups").", ".$member);
	} else {
		$self->set_field("hostgroups", $member);
	}
}

sub get_type()
{
        my ($self) = @_;
        return "host";
}

