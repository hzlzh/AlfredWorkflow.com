#------------------------------------------------------------------------------
# File:         FLIR.pm
#
# Description:  Read FLIR meta information
#
# Revisions:    2013/03/28 - P. Harvey Created
#
# References:   1) http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,4898.0.html
#               2) http://www.nuage.ch/site/flir-i7-some-analysis/
#               JD) Jens Duttke private communication
#
# Notes:        "FLIR" = Forward Looking Infra Red
#------------------------------------------------------------------------------

package Image::ExifTool::FLIR;

use strict;
use vars qw($VERSION);
use Image::ExifTool qw(:DataAccess :Utils);
use Image::ExifTool::Exif;

$VERSION = '1.00';

sub ProcessFLIR($$$);
sub ProcessFLIRText($$$);

my %temperatureInfo = (
    Writable => 'rational64u',
    Format => 'rational64s', # (have seen negative values)
);

# tag information for floating point Kelvin tag
my %floatKelvin = (
    Format => 'float',
    ValueConv => '$val - 273.15',
    PrintConv => 'sprintf("%.1f C",$val)',
);

# FLIR makernotes tags (ref PH)
%Image::ExifTool::FLIR::Main = (
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    WRITABLE => 1,
    PRIORITY => 0, # (unreliable)
    NOTES => q{
        Information extracted from the maker notes of JPEG images from thermal
        imaging cameras by FLIR Systems Inc.
    },
    0x01 => { #2
        Name => 'ImageMaximumTemperature',
        %temperatureInfo,
        Notes => q{
            these temperatures may be in Celcius, Kelvin or Fahrenheit, but there is no
            way to tell which
        },
    },
    0x02 => { Name => 'ImageMinimumTemperature', %temperatureInfo }, #2
    0x03 => { Name => 'Emissivity', Writable => 'rational64u', PrintConv => 'sprintf("%.2f",$val)' }, #1
    # 0x04 does not change with temperature units; often 238, 250 or 457
    0x04 => { Name => 'UnknownTemperature', %temperatureInfo, Unknown => 1 },
    # 0x05 often 393
    0x05 => { Name => 'UnknownMaximumTemperature', %temperatureInfo, Unknown => 1 },
    # 0x06 often 233
    0x06 => { Name => 'UnknownMinimumTemperature', %temperatureInfo, Unknown => 1 },
    # 0x07 - string[33] (some sort of image ID?)
    # 0x08 - string[33]
    # 0x09 - undef (tool info)
    # 0x0a - int32u: 1
);

# FLIR APP1 tag table (ref PH)
%Image::ExifTool::FLIR::APP1 = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&ProcessFLIR,
    NOTES => 'Information extracted from the FLIR APP1 segment of JPEG images.',
    0x01 => {
        Name => 'RawData',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::RawData' },
    },
    0x20 => {
        Name => 'CameraInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::CameraInfo' },
    },
    # 0x21 - ToolInfo (spot tool, line tool, area tool)
    0x22 => {
        Name => 'PaletteInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::PaletteInfo' },
    },
    0x23 => {
        Name => 'TextInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::TextInfo' },
    },
    0x24 => {
        Name => 'EmbeddedAudioFile',
        # (sometimes has an unknown 8-byte header)
        RawConv => q{
            return \$val if $val =~ s/^.{0,16}?RIFF/RIFF/s;
            $self->Warn('Unknown EmbeddedAudioFile format');
            return undef;
        },
    },
    # 0x27: 01 00 08 00 10 00 00 00
    0x2b => {
        Name => 'GPSInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::GPSInfo' },
    },
    0x2e => {
        Name => 'ParamInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::ParamInfo' },
    },
);

# FLIR raw data record (ref PH)
%Image::ExifTool::FLIR::RawData = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FORMAT => 'int16u',
    FIRST_ENTRY => 0,
    NOTES => q{
        The thermal data may be stored either as raw data, or in PNG format. If
        stored as raw data, ExifTool adds a TIFF header to allow the data to be
        viewed as a TIFF image.  If stored in PNG format, the PNG image is extracted
        as-is.  Note that most FLIR cameras using the PNG format seem to write the
        16-bit raw image data in the wrong byte order.
    },
    0x00 => {
        # use this tag only to determine the byte order of the raw data
        # (the value should be 0x0002 if the byte order is correct)
        # - always "II" when RawThermalImageType is "TIFF"
        # - seen both "II" and "MM" when RawThermalImageType is "PNG"
        Name => 'RawDataByteOrder',
        Hidden => 1,
        RawConv => 'ToggleByteOrder() if $val >= 0x0100; undef',
    },
    0x01 => {
        Name => 'RawThermalImageWidth',
        RawConv => '$$self{RawThermalImageWidth} = $val',
    },
    0x02 => {
        Name => 'RawThermalImageHeight',
        RawConv => '$$self{RawThermalImageHeight} = $val',
    },
    # 0x03-0x05: 0
    # 0x06: raw image width - 1
    # 0x07: 0
    # 0x08: raw image height - 1
    # 0x09: 0,15,16
    # 0x0a: 0,2,3,11,12,13,30
    # 0x0b: 0,2
    # 0x0c: 0 or a large number
    # 0x0d: 0,3,4,6
    # 0x0e-0x0f: 0
    16 => {
        Name => 'RawThermalImageType',
        # this is actually the location of the image, but extract the
        # image type as a separate tag because it may be useful
        Format => 'undef[$size-0x20]',
        Notes => 'TIFF or PNG',
        RawConv => sub {
            my ($val, $self) = @_;
            my ($w, $h) = @$self{'RawThermalImageWidth','RawThermalImageHeight'};
            my $type = 'DAT';
            # add TIFF header only if this looks like 16-bit raw data
            # (note: MakeTiffHeader currently works only for little-endian,
            #  and I haven't seen any big-endian samples, but check anwyay)
            if ($val =~ /^\x89PNG\r\n\x1a\n/) {
                $type = 'PNG';
            } elsif (length $val != $w * $h * 2) {
                $self->Warn('Unrecognized FLIR raw data format');
            } elsif (GetByteOrder() eq 'II') {
                require Image::ExifTool::Sony;
                $val = Image::ExifTool::Sony::MakeTiffHeader($w,$h,1,16) . $val;
                $type = 'TIFF';
            } else {
                $self->Warn("Don't yet support big-endian TIFF RawThermalImage");
            }
            # save image data
            $$self{RawThermalImage} = $val;
            return $type;
        },
    },
    16.1 => {
        Name => 'RawThermalImage',
        RawConv => '\$$self{RawThermalImage}',
    },
);

# FLIR camera record (ref PH)
%Image::ExifTool::FLIR::CameraInfo = (
    GROUPS => { 0 => 'APP1', 2 => 'Camera' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FIRST_ENTRY => 0,
    0x00 => {
        # use this tag only to determine the byte order
        # (the value should be 0x0002 if the byte order is correct)
        Name => 'CameraInfoByteOrder',
        Format => 'int16u',
        Hidden => 1,
        RawConv => 'ToggleByteOrder() if $val >= 0x0100; undef',
    },
    # 0x02 - int16u: image width
    # 0x04 - int16u: image height
    # 0x0c - int32u: image width - 1
    # 0x10 - int32u: image height - 1
    0x20 => { Name => 'Emissivity', Format => 'float', PrintConv => 'sprintf("%.2f",$val)' },
    0x24 => { Name => 'ObjectDistance', Format => 'float', PrintConv => 'sprintf("%.2f m",$val)' },
    0x28 => { Name => 'ReflectedApparentTemperature', %floatKelvin },
    0x2c => { Name => 'AtmosphericTemperature',       %floatKelvin },
    0x30 => { Name => 'IRWindowTemperature',          %floatKelvin },
    0x34 => { Name => 'IRWindowTransmission', Format => 'float', PrintConv => 'sprintf("%.2f",$val)' },
    # 0x38: 0
    0x3c => { Name => 'RelativeHumidity', Format => 'float', PrintConv => 'sprintf("%.1f %%",$val*100)' },
    # 0x40 - float: 0,6
    # 0x44,0x48,0x4c: 0
    # 0x50 - int32u: 1
    # 0x54: 0
    # 0x58,0x5c: ?
    # 0x60 - float: 1,1.5,1.54
    # 0x64,0x68,0x6c: 0
    # 0x70 - float: 0.006568
    # 0x74 - float: 0.012620
    # 0x78 - float: -0.00227
    # 0x7c - float: -0.00667
    # 0x80 - float: 1.89999
    # 0x84,0x88: 0
    # 0x8c - float: 0,4,6
    0x90 => { Name => 'CameraMaximumTemperature', %floatKelvin }, # (NC)
    0x94 => { Name => 'CameraMinimumTemperature', %floatKelvin }, # (NC)
    0x98 => { Name => 'UnknownTemperature1', %floatKelvin, Unknown => 1 }, # 50 degrees over camera max
    0x9c => { Name => 'UnknownTemperature2', %floatKelvin, Unknown => 1 }, # usually 10 or 20 degrees below camera min
    0xa0 => { Name => 'UnknownTemperature3', %floatKelvin, Unknown => 1 }, # same as camera max
    0xa4 => { Name => 'UnknownTemperature4', %floatKelvin, Unknown => 1 }, # same as camera min
    0xa8 => { Name => 'UnknownTemperature5', %floatKelvin, Unknown => 1 }, # usually 50 or 88 degrees over camera max
    0xac => { Name => 'UnknownTemperature6', %floatKelvin, Unknown => 1 }, # usually 10, 20 or 40 degrees below camera min
    0xd4 => { Name => 'CameraModel',        Format => 'string[32]' },
    0xf4 => { Name => 'CameraPartNumber',   Format => 'string[16]' }, #1
    0x104 => { Name => 'CameraSerialNumber',Format => 'string[16]' }, #1
    0x114 => { Name => 'CameraSoftware',    Format => 'string[16]' }, #1/PH (NC)
    0x170 => { Name => 'LensModel',         Format => 'string[32]' },
    # note: it seems that FLIR updated their lenses at some point, so lenses with the same
    # name may have different part numbers (ie. the FOL38 is either 1196456 or T197089)
    0x190 => { Name => 'LensPartNumber',    Format => 'string[16]' },
    0x1a0 => { Name => 'LensSerialNumber',  Format => 'string[16]' }, #JD (printed on back of camera)
    # 0x43c - string: either "Live" or the file name
);

# FLIR palette record (ref PH/JD)
%Image::ExifTool::FLIR::PaletteInfo = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FIRST_ENTRY => 0,
    0x00 => { #JD
        Name => 'PaletteColors',
        RawConv => '$$self{PaletteColors} = $val',
    },
    0x06 => { Name => 'AboveColor', Format => 'int8u[3]', Notes => 'Y Cb Cr color components' }, #JD
    0x09 => { Name => 'BelowColor', Format => 'int8u[3]' }, #JD
    0x0c => { Name => 'OverflowColor', Format => 'int8u[3]' }, #JD
    0x0f => { Name => 'UnderflowColor', Format => 'int8u[3]' }, #JD
    0x12 => { Name => 'Isotherm1Color', Format => 'int8u[3]' }, #JD
    0x15 => { Name => 'Isotherm2Color', Format => 'int8u[3]' }, #JD
    0x1a => { Name => 'PaletteMethod' }, #JD
    0x1b => { Name => 'PaletteStretch' }, #JD
    0x30 => {
        Name => 'PaletteFileName',
        Format => 'string[32]',
        # (not valid for all images)
        RawConv => q{
            $val =~ s/\0.*//;
            $val =~ /^[\x20-\x7e]{3,31}$/ ? $val : undef;
        },
    },
    0x50 => {
        Name => 'PaletteName',
        Format => 'string[32]',
        # (not valid for all images)
        RawConv => q{
            $val =~ s/\0.*//;
            $val =~ /^[\x20-\x7e]{3,31}$/ ? $val : undef;
        },
    },
    0x70 => {
        Name => 'Palette',
        Format => 'undef[3*$$self{PaletteColors}]',
        Notes => 'Y Cb Cr byte values for each palette color',
        Binary => 1,
    },
);

# FLIR text information record (ref PH)
%Image::ExifTool::FLIR::TextInfo = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&ProcessFLIRText,
    VARS => { NO_ID => 1 },
    Label0 => { },
    Value0 => { },
    Label1 => { },
    Value1 => { },
    Label2 => { },
    Value2 => { },
    Label3 => { },
    Value3 => { },
    # (there could be more, and we will generate these on the fly if necessary)
);

# FLIR parameter information record (ref PH)
%Image::ExifTool::FLIR::ParamInfo = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&ProcessFLIRText,
    VARS => { NO_ID => 1 },
    Generated => {
        Name => 'DateTimeGenerated',
        Groups => { 2 => 'Time' },
        ValueConv => '$val =~ tr/-/:/; $val',
        PrintConv => '$self->ConvertDateTime($val)',
    },
    Param0 => { },
    Param1 => { },
    Param2 => { },
    Param3 => { },
    # (there could be more, and we will generate these on the fly if necessary)
);

# FLIR GPS record (ref PH/JD)
%Image::ExifTool::FLIR::GPSInfo = (
    GROUPS => { 0 => 'APP1', 2 => 'Image' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FIRST_ENTRY => 0,
    0x58 => {
        Name => 'GPSMapDatum',
        Format => 'string[16]',
    },
);

#------------------------------------------------------------------------------
# Unescape FLIR Unicode character
# Inputs: 0) escaped character code
# Returns: UTF8 character
sub UnescapeFLIR($)
{
    my $char = shift;
    return $char unless length $char eq 4; # escaped ASCII char (ie. '\\')
    my $val = hex $char;
    return chr($val) if $val < 0x80;   # simple ASCII
    return pack('C0U', $val) if $] >= 5.006001;
    return Image::ExifTool::PackUTF8($val);
}

#------------------------------------------------------------------------------
# Process FLIR text info record (ref PH)
# Inputs: 0) ExifTool ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessFLIRText($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirStart = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen};

    return 0 if $dirLen < 12;

    $exifTool->VerboseDir('FLIR Text');

    my $dat = substr($$dataPt, $dirStart+12, $dirLen-12);
    $dat =~ s/\0.*//s; # truncate at null

    # the parameter text contains an additional header entry...
    if ($tagTablePtr eq \%Image::ExifTool::FLIR::ParamInfo and
        $dat =~ /# (Generated) at (.*?)[\n\r]/)
    {
        $exifTool->HandleTag($tagTablePtr, $1, $2);
    }

    for (;;) {
        $dat =~ /.(\d+).(label|value|param) (unicode|text) "(.*)"/g or last;
        my ($tag, $val) = (ucfirst($2) . $1, $4);
        if ($3 eq 'unicode' and $val =~ /\\/) {
            # convert escaped Unicode characters (backslash followed by 4 hex digits)
            $val =~ s/\\([0-9a-fA-F]{4}|.)/UnescapeFLIR($1)/sge;
            $exifTool->Decode($val, 'UTF8');
        }
        $$tagTablePtr{$tag} or AddTagToTable($tagTablePtr, $tag, { Name => $tag });
        $exifTool->HandleTag($tagTablePtr, $tag, $val);
    }

    return 1;
}

#------------------------------------------------------------------------------
# Process FLIR APP1 record (ref PH/1)
# Inputs: 0) ExifTool ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessFLIR($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirStart = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen};
    my $verbose = $exifTool->Options('Verbose');
    my $out = $exifTool->Options('TextOut');

    return 0 if $dirLen < 0x60;

    $exifTool->VerboseDir('FLIR APP1');

    SetByteOrder('MM');

    # offset 0x18 - int32u with value 0x0040 (start of FLIR record directory?)
    my $pos = 0x40; # start of FLIR record directory

    for (;;) {
        last if $pos + 0x20 > $dirLen;
        # FLIR record directory:
        # 0x00 - int16u (record type)
        # 0x02 - int16u (2 or 3 for record type 0x01, always 1 for other records)
        # 0x04 - int32u (unknown. values: 0x64,0x66,0x67,0x68,0x6f,0x104)
        # 0x08 - int32u (1)
        # 0x0c - int32u (record offset from start of FLIR data)
        # 0x10 - int32u (record length)
        # 0x14 - int32u (0)
        # 0x18 - int32u (0)
        # 0x1c - int32u (checksum, or 0 for no checksum)
        my $recType = Get16u($dataPt, $pos);
        last if $recType == 0;
        my $recPos = Get32u($dataPt, $pos + 0x0c);
        my $recLen = Get32u($dataPt, $pos + 0x10);
        $verbose and printf $out "%sFLIR Record 0x%.2x, offset 0x%.4x, length 0x%.4x\n",
                                 $$exifTool{INDENT}, $recType, $recPos, $recLen;
        if ($recPos < $pos + 0x20 || $recPos + $recLen > $dirLen) {
            $exifTool->Warn('Invalid FLIR record');
            last;
        }
        if ($$tagTablePtr{$recType}) {
            $exifTool->HandleTag($tagTablePtr, $recType, undef,
                DataPt => $dataPt,
                Start  => $recPos,
                Size   => $recLen,
            );
        } elsif ($verbose > 2) {
            my $dat = substr($$dataPt, $recPos, $recLen);
            my %parms = ( Prefix => $$exifTool{INDENT} );
            $parms{MaxLen} = 96 if $verbose < 4;
            Image::ExifTool::HexDump(\$dat, $recLen, %parms);
        }
        $pos += 0x20;
    }
    return 1;
}


1; # end


__END__

=head1 NAME

Image::ExifTool::FLIR - Read FLIR meta information

=head1 SYNOPSIS

This module is loaded automatically by Image::ExifTool when required.

=head1 DESCRIPTION

This module contains the definitions to read meta information from the maker
notes and FLIR APP1 segment of FLIR Systems thermal images.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,4898.0.html>

=item L<http://www.nuage.ch/site/flir-i7-some-analysis/>

=back

=head1 SEE ALSO

L<Image::ExifTool::TagNames/FLIR Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut
