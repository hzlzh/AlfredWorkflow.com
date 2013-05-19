#------------------------------------------------------------------------------
# File:         Ricoh.pm
#
# Description:  Ricoh EXIF maker notes tags
#
# Revisions:    03/28/2005 - P. Harvey Created
#
# References:   1) http://www.ozhiker.com/electronics/pjmt/jpeg_info/ricoh_mn.html
#               2) http://homepage3.nifty.com/kamisaka/makernote/makernote_ricoh.htm
#------------------------------------------------------------------------------

package Image::ExifTool::Ricoh;

use strict;
use vars qw($VERSION);
use Image::ExifTool qw(:DataAccess :Utils);
use Image::ExifTool::Exif;

$VERSION = '1.24';

sub ProcessRicohText($$$);
sub ProcessRicohRMETA($$$);

# lens types for Ricoh GXR
my %ricohLensIDs = (
    Notes => q{
        Lens units available for the GXR, used by the Ricoh Composite LensID tag.  Note
        that unlike lenses for all other makes of cameras, the focal lengths in these
        model names have already been scaled to include the 35mm crop factor.
    },
    # (the exact lens model names used by Ricoh, except for a change in case)
    'RL1' => 'GR Lens A12 50mm F2.5 Macro',
    'RL2' => 'Ricoh Lens S10 24-70mm F2.5-4.4 VC',
    'RL3' => 'Ricoh Lens P10 28-300mm F3.5-5.6 VC',
    'RL5' => 'GR Lens A12 28mm F2.5',
    'RL8' => 'Mount A12',
    'RL6' => 'Ricoh Lens A16 24-85mm F3.5-5.5',
);

%Image::ExifTool::Ricoh::Main = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    WRITABLE => 1,
    0x0001 => { Name => 'MakerNoteType',   Writable => 'string' },
    0x0002 => { #PH
        Name => 'FirmwareVersion',
        Writable => 'string',
        # ie. "Rev0113" is firmware version 1.13
        PrintConv => '$val=~/^Rev(\d+)$/ ? sprintf("%.2f",$1/100) : $val',
        PrintConvInv => '$val=~/^(\d+)\.(\d+)$/ ? sprintf("Rev%.2d%.2d",$1,$2) : $val',
    },
    0x0005 => [ #PH
        {
            Condition => '$$valPt =~ /^[-\w ]+$/',
            Name => 'SerialNumber', # (verified for GXR)
            Writable => 'undef',
            Count => 16,
            Notes => q{
                the serial number stamped on the camera begins with 2 model-specific letters
                followed by the last 8 digits of this value.  For the GXR, this is the
                serial number of the lens unit
            },
            PrintConv => '$val=~s/^(.*)(.{8})$/($1)$2/; $val',
            PrintConvInv => '$val=~tr/()//d; $val',
        },{
            Name => 'InternalSerialNumber',
            Writable => 'undef',
            Count => 16,
            ValueConv => 'unpack("H*", $val)',
            ValueConvInv => 'pack("H*", $val)',
        },
    ],
    0x0e00 => {
        Name => 'PrintIM',
        Writable => 0,
        Description => 'Print Image Matching',
        SubDirectory => { TagTable => 'Image::ExifTool::PrintIM::Main' },
    },
    0x1001 => {
        Name => 'ImageInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::Ricoh::ImageInfo' },
    },
    0x1003 => {
        Name => 'Sharpness',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Sharp',
            1 => 'Normal',
            2 => 'Soft',
        },
    },
    0x2001 => [
        {
            Name => 'RicohSubdir',
            Condition => q{
                $self->{Model} !~ /^Caplio RR1\b/ and
                ($format ne 'int32u' or $count != 1)
            },
            SubDirectory => {
                Validate => '$val =~ /^\[Ricoh Camera Info\]/',
                TagTable => 'Image::ExifTool::Ricoh::Subdir',
                Start => '$valuePtr + 20',
                ByteOrder => 'BigEndian',
            },
        },
        {
            Name => 'RicohSubdirIFD',
            # the CX6 and GR Digital 4 write an int32u pointer in AVI videos -- doh!
            Condition => '$self->{Model} !~ /^Caplio RR1\b/',
            Flags => 'SubIFD',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Ricoh::Subdir',
                Start => '$val + 20', # (skip over "[Ricoh Camera Info]\0" header)
                ByteOrder => 'BigEndian',
            },
        },
        {
            Name => 'RicohRR1Subdir',
            SubDirectory => {
                Validate => '$val =~ /^\[Ricoh Camera Info\]/',
                TagTable => 'Image::ExifTool::Ricoh::Subdir',
                Start => '$valuePtr + 20',
                ByteOrder => 'BigEndian',
                # the Caplio RR1 uses a different base address -- doh!
                Base => '$start-20',
            },
        },
    ],
);

# Ricoh image info (ref 2)
%Image::ExifTool::Ricoh::ImageInfo = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    WRITE_PROC => \&Image::ExifTool::WriteBinaryData,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    WRITABLE => 1,
    PRIORITY => 0,
    FORMAT => 'int8u',
    FIRST_ENTRY => 0,
    IS_OFFSET => [ 28 ],   # tag 28 is 'IsOffset'
    0 => {
        Name => 'RicohImageWidth',
        Format => 'int16u',
    },
    2 => {
        Name => 'RicohImageHeight',
        Format => 'int16u',
    },
    6 => {
        Name => 'RicohDate',
        Groups => { 2 => 'Time' },
        Format => 'int8u[7]',
        # (what an insane way to encode the date)
        ValueConv => q{
            sprintf("%.2x%.2x:%.2x:%.2x %.2x:%.2x:%.2x",
                    split(' ', $val));
        },
        ValueConvInv => q{
            my @vals = ($val =~ /(\d{1,2})/g);
            push @vals, 0 if @vals < 7;
            join(' ', map(hex, @vals));
        },
    },
    28 => {
        Name => 'PreviewImageStart',
        Format => 'int16u', # ha!  (only the lower 16 bits, even if > 0xffff)
        Flags => 'IsOffset',
        OffsetPair => 30,   # associated byte count tagID
        DataTag => 'PreviewImage',
        Protected => 2,
        # prevent preview from being written to MakerNotes of DNG images
        RawConvInv => q{
            return $val if $$self{FILE_TYPE} eq "JPEG";
            warn "\n"; # suppress warning
            return undef;
        },
    },
    30 => {
        Name => 'PreviewImageLength',
        Format => 'int16u',
        OffsetPair => 28,   # point to associated offset
        DataTag => 'PreviewImage',
        Protected => 2,
        RawConvInv => q{
            return $val if $$self{FILE_TYPE} eq "JPEG";
            warn "\n"; # suppress warning
            return undef;
        },
    },
    32 => {
        Name => 'FlashMode',
        PrintConv => {
            0 => 'Off',
            1 => 'Auto', #PH
            2 => 'On',
        },
    },
    33 => {
        Name => 'Macro',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    34 => {
        Name => 'Sharpness',
        PrintConv => {
            0 => 'Sharp',
            1 => 'Normal',
            2 => 'Soft',
        },
    },
    38 => {
        Name => 'WhiteBalance',
        PrintConv => {
            0 => 'Auto',
            1 => 'Daylight',
            2 => 'Cloudy',
            3 => 'Tungsten',
            4 => 'Fluorescent',
            5 => 'Manual', #PH (GXR)
            7 => 'Detail',
            9 => 'Multi-pattern Auto', #PH (GXR)
        },
    },
    39 => {
        Name => 'ISOSetting',
        PrintConv => {
            0 => 'Auto',
            1 => 64,
            2 => 100,
            4 => 200,
            6 => 400,
            7 => 800,
            8 => 1600,
            9 => 'Auto', #PH (? CX3)
            10 => 3200, #PH (A16)
            11 => '100 (Low)', #PH (A16)
        },
    },
    40 => {
        Name => 'Saturation',
        PrintConv => {
            0 => 'High',
            1 => 'Normal',
            2 => 'Low',
            3 => 'B&W',
            6 => 'Toning Effect', #PH (GXR Sepia,Red,Green,Blue,Purple)
            9 => 'Vivid', #PH (GXR)
            10 => 'Natural', #PH (GXR)
        },
    },
);

# Ricoh subdirectory tags (ref PH)
# NOTE: this subdir is currently not writable because the offsets would require
# special code to handle the funny start location and base offset
%Image::ExifTool::Ricoh::Subdir = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    # the significance of the following 2 dates is not known.  They are usually
    # within a month of each other, but I have seen differences of nearly a year.
    # Sometimes the first is more recent, and sometimes the second.
    0x0004 => { # (NC)
        Name => 'ManufactureDate1',
        Groups => { 2 => 'Time' },
        Writable => 'string',
        Count => 20,
    },
    0x0005 => { # (NC)
        Name => 'ManufactureDate2',
        Groups => { 2 => 'Time' },
        Writable => 'string',
        Count => 20,
    },
    # 0x000c - int32u[2] 1st number is a counter (file number? shutter count?) - PH
    # 0x0014 - int8u[338] - could contain some data related to face detection? - PH
    # 0x0015 - int8u[2]: related to noise reduction?
    0x001a => { #PH
        Name => 'FaceInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::Ricoh::FaceInfo' },
    },
    0x0029 => {
        Name => 'FirmwareInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::Ricoh::FirmwareInfo' },
    },
    0x002a => {
        Name => 'NoiseReduction',
        # this is the applied value if NR is set to "Auto"
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            1 => 'Weak',
            2 => 'Strong',
            3 => 'Max',
        },
    },
    0x002c => { # (GXR)
        Name => 'SerialInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::Ricoh::SerialInfo' },
    }
    # 0x000E ProductionNumber? (ref 2) [no. zero for most models - PH]
);

# face detection information (ref PH, CX4)
%Image::ExifTool::Ricoh::FaceInfo = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    WRITE_PROC => \&Image::ExifTool::WriteBinaryData,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    DATAMEMBER => [ 181 ],
    0xb5 => { # (should be int16u at 0xb4?)
        Name => 'FacesDetected',
        DataMember => 'FacesDetected',
        RawConv => '$$self{FacesDetected} = $val',
    },
    0xb6 => {
        Name => 'FaceDetectFrameSize',
        Format => 'int16u[2]',
    },
    0xbc => {
        Name => 'Face1Position',
        Condition => '$$self{FacesDetected} >= 1',
        Format => 'int16u[4]',
        Notes => q{
            left, top, width and height of detected face in coordinates of
            FaceDetectFrameSize with increasing Y downwards
        },
    },
    0xc8 => {
        Name => 'Face2Position',
        Condition => '$$self{FacesDetected} >= 2',
        Format => 'int16u[4]',
    },
    0xd4 => {
        Name => 'Face3Position',
        Condition => '$$self{FacesDetected} >= 3',
        Format => 'int16u[4]',
    },
    0xe0 => {
        Name => 'Face4Position',
        Condition => '$$self{FacesDetected} >= 4',
        Format => 'int16u[4]',
    },
    0xec => {
        Name => 'Face5Position',
        Condition => '$$self{FacesDetected} >= 5',
        Format => 'int16u[4]',
    },
    0xf8 => {
        Name => 'Face6Position',
        Condition => '$$self{FacesDetected} >= 6',
        Format => 'int16u[4]',
    },
    0x104 => {
        Name => 'Face7Position',
        Condition => '$$self{FacesDetected} >= 7',
        Format => 'int16u[4]',
    },
    0x110 => {
        Name => 'Face8Position',
        Condition => '$$self{FacesDetected} >= 8',
        Format => 'int16u[4]',
    },
);

# firmware version information (ref PH)
%Image::ExifTool::Ricoh::FirmwareInfo = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    WRITE_PROC => \&Image::ExifTool::WriteBinaryData,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    WRITABLE => 1,
    0x00 => {
        Name => 'FirmwareRevision',
        Format => 'string[12]',
    },
    0x0c => {
        Name => 'FirmwareRevision2',
        Format => 'string[12]',
    },
);

# serial/version number information written by GXR (ref PH)
%Image::ExifTool::Ricoh::SerialInfo = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    WRITE_PROC => \&Image::ExifTool::WriteBinaryData,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    WRITABLE => 1,
    NOTES => 'This information is found in images from the GXR.',
    0 => {
        Name => 'BodyFirmware', #(NC)
        Format => 'string[16]',
        # observed: "RS1 :V00560000" --> FirmwareVersion "Rev0056"
        #           "RS1 :V01020200" --> FirmwareVersion "Rev0102"
    },
    16 => {
        Name => 'BodySerialNumber',
        Format => 'string[16]',
        # observed: "SID:00100056" --> "WD00100056" on plate
    },
    32 => {
        Name => 'LensFirmware', #(NC)
        Format => 'string[16]',
        # observed: "RL1 :V00560000", "RL1 :V01020200" - A12 50mm F2.5 Macro
        #           "RL2 :V00560000", "RL2 :V01020300" - S10 24-70mm F2.5-4.4 VC
        # --> used in a Composite tag to determine LensType
    },
    48 => {
        Name => 'LensSerialNumber',
        Format => 'string[16]',
        # observed: (S10) "LID:00010024" --> "WF00010024" on plate
        #           (A12) "LID:00010054" --> "WE00010029" on plate??
    },
);

# Ricoh text-type maker notes (PH)
%Image::ExifTool::Ricoh::Text = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PROCESS_PROC => \&ProcessRicohText,
    NOTES => q{
        Some Ricoh DC and RDC models use a text-based format for their maker notes
        instead of the IFD format used by the Caplio models.  Below is a list of known
        tags in this information.
    },
    Rev => {
        Name => 'FirmwareVersion',
        PrintConv => '$val=~/^\d+$/ ? sprintf("%.2f",$val/100) : $val',
        PrintConvInv => '$val=~/^(\d+)\.(\d+)$/ ? sprintf("%.2d%.2d",$1,$2) : $val',
    },
    Rv => {
        Name => 'FirmwareVersion',
        PrintConv => '$val=~/^\d+$/ ? sprintf("%.2f",$val/100) : $val',
        PrintConvInv => '$val=~/^(\d+)\.(\d+)$/ ? sprintf("%.2d%.2d",$1,$2) : $val',
    },
    Rg => 'RedGain',
    Gg => 'GreenGain',
    Bg => 'BlueGain',
);

%Image::ExifTool::Ricoh::RMETA = (
    GROUPS => { 0 => 'APP5', 1 => 'RMETA', 2 => 'Image' },
    PROCESS_PROC => \&Image::ExifTool::Ricoh::ProcessRicohRMETA,
    NOTES => q{
        The Ricoh Caplio Pro G3 has the ability to add custom fields to the APP5
        "RMETA" segment of JPEG images.  While only a few observed tags have been
        defined below, ExifTool will extract any information found here.
    },
    'Sign type' => { Name => 'SignType', PrintConv => {
        1 => 'Directional',
        2 => 'Warning',
        3 => 'Information',
    } },
    Location => { PrintConv => {
        1 => 'Verge',
        2 => 'Gantry',
        3 => 'Central reservation',
        4 => 'Roundabout',
    } },
    Lit => { PrintConv => {
        1 => 'Yes',
        2 => 'No',
    } },
    Condition => { PrintConv => {
        1 => 'Good',
        2 => 'Fair',
        3 => 'Poor',
        4 => 'Damaged',
    } },
    Azimuth => { PrintConv => {
        1 => 'N',
        2 => 'NNE',
        3 => 'NE',
        4 => 'ENE',
        5 => 'E',
        6 => 'ESE',
        7 => 'SE',
        8 => 'SSE',
        9 => 'S',
        10 => 'SSW',
        11 => 'SW',
        12 => 'WSW',
        13 => 'W',
        14 => 'WNW',
        15 => 'NW',
        16 => 'NNW',
    } },
    _audio => {
        Name => 'SoundFile',
        Notes => 'audio data recorded in JPEG images by the G700SE',
    },
);

# information stored in Ricoh AVI images (ref PH)
%Image::ExifTool::Ricoh::AVI = (
    GROUPS => { 0 => 'MakerNotes', 2 => 'Video' },
    ucmt => {
        Name => 'Comment',
        # Ricoh writes a "Unicode" header even when text is ASCII (spaces anyway)
        ValueConv => '$_=$val; s/^(Unicode\0|ASCII\0\0\0)//; tr/\0//d; s/\s+$//; $_',
    },
    mnrt => {
        Name => 'MakerNoteRicoh',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Ricoh::Main',
            Start => '$valuePtr + 8',
            ByteOrder => 'BigEndian',
            Base => '8',
        },
    },
    rdc2 => {
        Name => 'RicohRDC2',
        Unknown => 1,
        ValueConv => 'unpack("H*",$val)',
        # have seen values like 0a000444 and 00000000 - PH
    },
    thum => {
        Name => 'ThumbnailImage',
        Binary => 1,
    },
);

# Ricoh composite tags
%Image::ExifTool::Ricoh::Composite = (
    GROUPS => { 2 => 'Camera' },
    LensID => {
        SeparateTable => 'Ricoh LensID',
        Require => 'Ricoh:LensFirmware',
        RawConv => '$val[0] ? $val[0] : undef',
        ValueConv => '$val=~s/\s*:.*//; $val',
        PrintConv => \%ricohLensIDs,
    },
);

# add our composite tags
Image::ExifTool::AddCompositeTags('Image::ExifTool::Ricoh');


#------------------------------------------------------------------------------
# Process Ricoh text-based maker notes
# Inputs: 0) ExifTool object reference
#         1) Reference to directory information hash
#         2) Pointer to tag table for this directory
# Returns: 1 on success, otherwise returns 0 and sets a Warning
sub ProcessRicohText($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dataLen = $$dirInfo{DataLen};
    my $dirStart = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen} || $dataLen - $dirStart;
    my $verbose = $exifTool->Options('Verbose');

    my $data = substr($$dataPt, $dirStart, $dirLen);
    return 1 if $data =~ /^\0/;     # blank Ricoh maker notes
    # validate text maker notes
    unless ($data =~ /^(Rev|Rv)/) {
        $exifTool->Warn('Bad Ricoh maker notes');
        return 0;
    }
    while ($data =~ m/([A-Z][a-z]{1,2})([0-9A-F]+);/sg) {
        my $tag = $1;
        my $val = $2;
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
        if ($verbose) {
            $exifTool->VerboseInfo($tag, $tagInfo,
                Table  => $tagTablePtr,
                Value  => $val,
            );
        }
        unless ($tagInfo) {
            next unless $exifTool->{OPTIONS}->{Unknown};
            $tagInfo = {
                Name => "Ricoh_Text_$tag",
                Unknown => 1,
                PrintConv => 'length($val) > 60 ? substr($val,0,55) . "[...]" : $val',
            };
            # add tag information to table
            AddTagToTable($tagTablePtr, $tag, $tagInfo);
        }
        $exifTool->FoundTag($tagInfo, $val);
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process Ricoh APP5 RMETA information
# Inputs: 0) ExifTool ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
sub ProcessRicohRMETA($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirStart = $$dirInfo{DirStart};
    my $dataLen = length($$dataPt);
    my $dirLen = $dataLen - $dirStart;
    my $verbose = $exifTool->Options('Verbose');

    $exifTool->VerboseDir('Ricoh RMETA') if $verbose;
    $dirLen > 6 or $exifTool->Warn('Truncated Ricoh RMETA data', 1), return 0;
    my $byteOrder = substr($$dataPt, $dirStart, 2);
    SetByteOrder($byteOrder) or $exifTool->Warn('Bad Ricoh RMETA data', 1), return 0;
    my $rmetaType = Get16u($dataPt, $dirStart+4);
    if ($rmetaType != 0) {
        # not sure how to recognize audio, so do it by brute force and assume
        # all subsequent RMETA segments are part of the audio data
        $dirLen < 14 and $exifTool->Warn('Short Ricoh RMETA block', 1), return 0;
        my $audioLen = Get16u($dataPt, $dirStart+12);
        $audioLen + 14 > $dirLen and $exifTool->Warn('Truncated Ricoh RMETA audio data', 1), return 0;
        my $buff = substr($$dataPt, $dirStart + 14, $audioLen);
        my $val = $$exifTool{VALUE}{SoundFile};
        if ($val) {
            $$val .= $buff;
        } elsif ($audioLen >= 4 and substr($buff, 0, 4) eq 'RIFF') {
            $exifTool->HandleTag($tagTablePtr, '_audio', \$buff);
        } else {
            $exifTool->Warn('Unknown Ricoh RMETA type', 1);
            return 0;
        }
        return 1;
    }
    # standard RMETA tag directory
    my (@tags, @vals, @nums, $valPos);
    my $pos = $dirStart + 6;
    while ($pos <= $dataLen - 4) {
        my $type = Get16u($dataPt, $pos);
        my $size = Get16u($dataPt, $pos + 2);
        last unless $size;
        $pos += 4;
        $size -= 2;
        if ($size < 0 or $pos + $size > $dataLen) {
            $exifTool->Warn('Corrupted Ricoh RMETA data', 1);
            last;
        }
        if ($type eq 1) {
            # save the tag names
            my $tags = substr($$dataPt, $pos, $size);
            $tags =~ s/\0+$//;  # remove trailing nulls
            @tags = split /\0/, $tags;
        } elsif ($type eq 2) {
            # save the ASCII tag values
            my $vals = substr($$dataPt, $pos, $size);
            $vals =~ s/\0+$//;
            @vals = split /\0/, $vals;
            $valPos = $pos; # save position of first ASCII value
        } elsif ($type eq 3) {
            # save the numerical tag values
            my $nums = substr($$dataPt, $pos, $size);
            @nums = unpack($byteOrder eq 'MM' ? 'n*' : 'v*', $nums);
        } elsif ($type eq 0) {
            $pos += 2;  # why 2 extra bytes?
        }
        $pos += $size;
    }
    if (@tags or @vals) {
        if (@tags < @vals) {
            my ($nt, $nv) = (scalar(@tags), scalar(@vals));
            $exifTool->Warn("Fewer tags ($nt) than values ($nv) in Ricoh RMETA", 1);
        }
        # find next tag in null-delimited list
        # unpack numerical values from block of int16u values
        my ($tag, $name, $val);
        foreach $tag (@tags) {
            $val = shift @vals;
            $val = '' unless defined $val;
            ($name = $tag) =~ s/\b([a-z])/\U$1/gs;  # make capitalize all words
            $name =~ s/ (\w)/\U$1/g;                # remove special characters
            $name = 'RMETA_Unknown' unless length($name);
            my $num = shift @nums;
            my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
            if ($tagInfo) {
                # make sure print conversion is defined
                $$tagInfo{PrintConv} = { } unless $$tagInfo{PrintConv};
            } else {
                # create tagInfo hash
                $tagInfo = { Name => $name, PrintConv => { } };
                AddTagToTable($tagTablePtr, $tag, $tagInfo);
            }
            # use string value directly if no numerical value
            $num = $val unless defined $num;
            # add conversion for this value (replacing any existing entry)
            $tagInfo->{PrintConv}->{$num} = $val;
            if ($verbose) {
                $exifTool->VerboseInfo($tag, $tagInfo,
                    Table   => $tagTablePtr,
                    Value   => $num,
                    DataPt  => $dataPt,
                    DataPos => $$dirInfo{DataPos},
                    Start   => $valPos,
                    Size    => length($val),
                );
            }
            $exifTool->FoundTag($tagInfo, $num);
            $valPos += length($val) + 1;
        }
    }
    return 1;
}

1;  # end

__END__

=head1 NAME

Image::ExifTool::Ricoh - Ricoh EXIF maker notes tags

=head1 SYNOPSIS

This module is loaded automatically by Image::ExifTool when required.

=head1 DESCRIPTION

This module contains definitions required by Image::ExifTool to
interpret Ricoh maker notes EXIF meta information.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://www.ozhiker.com/electronics/pjmt/jpeg_info/ricoh_mn.html>

=back

=head1 SEE ALSO

L<Image::ExifTool::TagNames/Ricoh Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut
