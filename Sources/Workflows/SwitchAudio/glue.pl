#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

my $action = shift || 'list';
my $direction = shift || 'output';

if ($action eq 'list') {
    my $devices = get_possibilities($direction);
    print qq{<?xml version="1.0"?>\n<items>\n};
    print output_device($_) for @$devices;
    print "</items>\n";
}

if ( $action eq 'set' ) {
    my $device = shift;
    print set_device($direction, $device) . "\n";
}

sub get_possibilities {
    my $direction = shift;
    my @devices;
    open( my $fh, '-|', $FindBin::Bin . '/SwitchAudioSource',
        '-at', $direction );
    while ( my $line = <$fh> ) {
        chomp $line;
        $line =~ s/ \(\Q$direction\E\)$//;
        push @devices, $line;
    }
    close $fh;
    return \@devices;
}

sub set_device {
    my ( $direction, $device ) = @_;
    open( my $fh, '-|', $FindBin::Bin . '/SwitchAudioSource',
        '-t', $direction, '-s', $device );
    my $output = join "\n", <$fh>;
    close $fh;
    return $output;
}

sub output_device {
    my $device = shift;
    ( my $device_no_space = $device ) =~ tr/ /_/;
    return qq{<item arg="$device" uid="$device_no_space"><title>$device</title><subtitle/><icon>icon.png</icon></item>\n};
}
