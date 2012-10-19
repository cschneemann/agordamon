#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a services configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for services, contacts. 20100929.

use agordamon::definition;

package agordamon::service;

#FIXME fix list
@EXPORT = qw(valid_field, set_field, get_field, delete_field);

@ISA = qw(agordamon::definition);

use strict;
use warnings;

sub get_valid_fields()
{   
  my ($self, $field) = @_;
  my @valid_fields = qw(use name register host_name hostgroup_name service_description display_name 
                        servicegroups is_volatile check_command initial_state max_check_attempts
                        check_interval retry_interval active_checks_enabled passive_checks_enabled 
                        check_period obsess_over_service check_freshness freshness_threshold 
                        event_handler event_handler_enabled low_flap_threshold high_flap_threshold 
                        flap_detection_enabled flap_detection_options process_perf_data 
                        retain_status_information retain_nonstatus_information notification_interval 
                        first_notification_delay notification_period notification_options 
                        notifications_enabled contacts contact_groups stalking_options notes 
                        notes_url action_url icom_image icon_image_alt);

  return @valid_fields;
}

sub add_group
{   
  my ($self, $member) = @_;
  if (defined($self->get_field("servicegroups")))
  {   
    $self->set_field("servicegroups", $self->get_field("servicegroups").", ".$member);
  } else {
    $self->set_field("servicegroups", $member);
  }
}

sub get_type()
{
  my ($self) = @_;
  return "service";
}

