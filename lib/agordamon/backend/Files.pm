#!/usr/bin/perl
## vim: set syn=on ts=4 sw=4 sts=0 noet foldmethod=indent:
## purpose: create objects suitable for a nagios configuration.
## copyright: B1 Systems GmbH <info@b1-systems.de>, 2011.
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Christian Schneemann <schneemann@b1-systems.de>, 2011.


## TODO:
# make the internal data structure easier

package agordamon::backend::Files;

@EXPORT = qw(get);
#@ISA = qw(agordamon::conffile);

our $VERSION = "0.13";

use strict;
use warnings;

sub new {

	my ( $pkg, %params) = @_;
	my $self = {};

	$self->{nagios_cfg} = $params{nagios_cfg};
	bless $self, $pkg;
	return $self;
}


sub get_cfg_files()
{
	my ( $self ) = @_;
    my (@cfg_files, @cfg_dirs);

    open(CFG, "<",$self->{nagios_cfg}) or return -1;

    while (<CFG>)
    {
        next if /#\s*/;
        if (/cfg_file=(.+)$/ )
        {
            push (@cfg_files, $1); 
        } elsif (/cfg_dir=(.+)$/ ) {
            push (@cfg_dirs, $1);  
        }
    }
    close (CFG);

	# get files in config_dirs
    foreach my $cfg_dir (@cfg_dirs)
    {   
        opendir(my $dir, $cfg_dir) or return -1;
        while ( readdir($dir) )
        {   
            if (/\.cfg$/)
            {   
                push(@cfg_files, $_);
            }
        }
    }
	return @cfg_files;
}

sub get
{
	my ($self, @types) = @_;

	my %return;

	my @cfg_files = $self->get_cfg_files;
    
	# now read/parse the configfiles...
    foreach my $file (@cfg_files)
    {
        open (FILE, "<$file") or return -1;
        my @file = <FILE>;
        for (my $i=0; $i < scalar(@file); $i++)
        {
            my $definition = 0;
            my $type = "";
            my %object;
			
            if ($file[$i] =~/define\s(\w+)\s*{/)
            {
                $type = $1;
                $definition = 1;
            }

            while ($definition)
            {

                if ($file[$i] =~ /\s*(\w+)\s+(.+)$/ )
                {
                    my $key = $1,
                    my $value = $2;
                    ($value) = (split(";", $value))[0];
                    $object{$key} = $value;
#					print $file[$i], "\n";
 #                 print "key: $key value: $object{$key}\n";
                }

                if ($file[$i] =~ /}/)
                {
                    $definition = 0;
					push(@{$return{$type}}, \%object) if (scalar(grep($type, @types)) && $type ne "timeperiod");
                }
                $i++;
            }
        }

    }
	return %return;

}

