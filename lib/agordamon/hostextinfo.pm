#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2010.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2010.
## version: 0.1: create definitions for contacts. 20100929.


use agordamon::definition;

package agordamon::hostextinfo;

#FIXME fix list
@EXPORT = qw(valid_field, set_field, get_field, delete_field);

@ISA = qw(agordamon::definition);

use strict;
use warnings;
sub get_valid_fields()
{   
  my ($self, $field) = @_;
  my @valid_fields = qw(use name register host_name notes
                        notes_url action_url icon_image
                        icon_image_alt vrml_image statusmap_image
                        2d_coords 3d_coords);

  return @valid_fields;
}

sub get_type()
{
  my ($self) = @_;
  return "hostextinfo";
}

