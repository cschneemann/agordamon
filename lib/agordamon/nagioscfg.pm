#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for contacts. 20100929.


use agordamon::definition;

package agordamon::nagioscfg;

#FIXME fix list
@EXPORT = qw(valid_field, set_field, get_field, delete_field);

@ISA = qw(agordamon::definition);

use strict;
use warnings;
sub get_valid_fields()
{   
    my ($self, $field) = @_;
	my @valid_fields = qw(log_file cfg_file cfg_dir object_cache_file 
						precached_object_file resource_file temp_file 
						temp_path status_file status_update_interval 
						nagios_user nagios_group enable_notifications 
						execute_service_checks accept_passive_service_checks 
						execute_host_checks accept_passive_host_checks 
						enable_event_handlers log_rotation_method 
						log_archive_path check_external_commands 
						command_check_interval command_file 
						external_command_buffer_slots check_for_updates 
						bare_update_checks lock_file retain_state_information 
						state_retention_file retention_update_interval 
						use_retained_program_state use_retained_scheduling_info 
						retained_host_attribute_mask retained_process_host_attribute_mask 
						retained_contact_host_attribute_mask use_syslog 
						log_notifications log_service_retries log_host_retries 
						log_event_handlers log_initial_states log_external_commands 
						log_passive_checks global_host_event_handler 
						global_service_event_handler sleep_time service_inter_check_delay_method 
						max_service_check_spread service_interleave_factor 
						max_concurrent_checks check_result_reaper_frequency 
						max_check_result_reaper_time check_result_path 
						max_check_result_file_age host_inter_check_delay_method 
						max_host_check_spread interval_length auto_reschedule_checks 
						auto_rescheduling_interval auto_rescheduling_window 
						use_aggressive_host_checking translate_passive_host_checks 
						passive_host_checks_are_soft enable_predictive_host_dependency_checks 
						enable_predictive_service_dependency_checks cached_host_check_horizon 
						cached_service_check_horizon use_large_installation_tweaks 
						free_child_process_memory child_processess_fork_twice 
						enable_environment_macros enable_flap_detection 
						low_service_flap_threshold high_service_flap_threshold 
						low_host_flap_threshold high_host_flap_threshold 
						soft_state_dependencies service_check_timeout host_check_timeout 
						event_handler_timeout notification_timeout ocsp_timeout 
						ochp_timeout perfdata_timeout obsess_over_services ocsp_command 
						obsess_over_hosts ochp_command process_performance_data 
						host_perfdata_command service_perfdata_command host_perfdata_file 
						service_perfdata_file host_perfdata_file_template 
						service_perfdata_file_template host_perfdata_file_mode 
						service_perfdata_file_mode host_perfdata_file_processing_interval 
						service_perfdata_file_processing_interval host_perfdata_file_processing_command 
						service_perfdata_file_processing_command check_for_orphaned_services 
						check_for_orphaned_hosts check_service_freshness service_freshness_check_interval 
						check_host_freshness host_freshness_check_interval additional_freshness_latency 
						enable_embedded_perl use_embedded_perl_implicitly date_format use_timezone 
						illegal_object_name_chars illegal_macro_output_chars use_regexp_matching 
						use_true_regexp_matching admin_email admin_pager event_broker_options 
						broker_module debug_file debug_level debug_verbosity max_debug_file_size );
 

    return @valid_fields;
}

sub get_type()
{
        my ($self) = @_;
        return "nagios.cfg";
}

sub create_config($)
{
    my ($self, $type) = @_;
    my $config = "";

    foreach my $field ( $self->get_valid_fields())
    {
        if ( defined( $self->get_field($field) ) )
        {
            $config = $config.$field."=".$self->get_field($field)."\n" ;
        }
    }
    return $config;
}

