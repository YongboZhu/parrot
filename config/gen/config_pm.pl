#! perl -w
# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

config/gen/config_pm.pl - Record configuration data

=head1 DESCRIPTION

Writes the C<Parrot::Config> Perl module, the F<library/config.fpmc> 
generator program, and the F<myconfig> file.

=cut

package Configure::Step;

use strict;
use vars qw($description @args);
use Parrot::Configure::Step;
use Data::Dumper;

$description="Recording configuration data for later retrieval";

@args=();

sub runstep {
  Configure::Data->clean;
  
  genfile('config/gen/config_pm/myconfig.in',      'myconfig');

  open(IN, "config/gen/config_pm/Config_pm.in") or die "Can't open Config_pm.in: $!";
  open(OUT, ">lib/Parrot/Config.pm") or die "Can't open lib/Parrot/Config.pm: $!";

  print OUT "# Generated by config/gen/config_pm.pl\n";

  while(<IN>) {
    s/<<HERE>>/Configure::Data->dump()/e;
    print OUT;
  }
 
  close IN  or die "Can't close Config_pm.in: $!";
  close OUT or die "Can't close Config.pm: $!";
  
  open(IN, "config/gen/config_pm/config_lib.in") or die "Can't open config_lib.in: $!";
  open(OUT, ">config_lib.pasm") or die "Can't open config_lib.pasm: $!";
  
  print OUT <<"END";
# Generated by config/gen/config_pm.pl
# This file should be the last thing run during 
# the make process, after Parrot is built.
END
  
  while(<IN>) {      
    if(/<<HERE>>/) {
      my $k;
      for $k(Configure::Data->keys) {
	my $v=Configure::Data->get($k);
	if(defined $v) {
          $v =~ s/(["\\])/\\$1/g;
          $v =~ s/\n/\\\n/g;
          print OUT qq(\tset P0["$k"], "$v"\n);
        }
        else {
          print OUT qq(\tset P0["$k"], P1\n);
        }
      }
    }
    else {
      print OUT;
    }
  }
  
  close IN  or die "Can't close config_lib.in: $!";
  close OUT or die "Can't close config_lib.pasm: $!";
}

1;
