#------------------------------------------------------------------------------
# File:         Sony.pm
#
# Description:  Sony EXIF Maker Notes tags
#
# Revisions:    04/06/2004  - P. Harvey Created
#
# References:   1) http://www.cybercom.net/~dcoffin/dcraw/
#               2) http://homepage3.nifty.com/kamisaka/makernote/makernote_sony.htm (2006/08/06)
#               3) Thomas Bodenmann private communication
#               4) Philippe Devaux private communication (A700)
#               5) Marcus Holland-Moritz private communication (A700)
#               6) Andrey Tverdokhleb private communication
#               7) Rudiger Lange private communication (A700)
#               8) Igal Milchtaich private communication
#               9) Michael Reitinger private communication (DSC-TX7,RX100)
#               10) http://www.klingebiel.com/tempest/hd/pmp.html
#               11) Mike Battilana private communication
#               12) Jos Roost private communication (A580)
#               JD) Jens Duttke private communication
#------------------------------------------------------------------------------

package Image::ExifTool::Sony;

use strict;
use vars qw($VERSION %sonyLensTypes);
use Image::ExifTool qw(:DataAccess :Utils);
use Image::ExifTool::Exif;
use Image::ExifTool::Minolta;

$VERSION = '1.85';

sub ProcessSRF($$$);
sub ProcessSR2($$$);
sub ProcessMoreInfo($$$);
sub Decipher($;$);
sub ProcessEnciphered($$$);
sub WriteEnciphered($$$);
sub WriteSR2($$$);
sub ConvLensSpec($);
sub ConvInvLensSpec($);
sub PrintLensSpec($);
sub PrintInvLensSpec($);
sub MakeTiffHeader($$$$;$);

# (%sonyLensTypes is filled in based on Minolta LensType's)

# ExposureProgram values (ref PH, mainly decoded from A200)
my %sonyExposureProgram = (
    0 => 'Auto', # (same as 'Program AE'?)
    1 => 'Manual',
    2 => 'Program AE',
    3 => 'Aperture-priority AE',
    4 => 'Shutter speed priority AE',
    8 => 'Program Shift A', #7
    9 => 'Program Shift S', #7
    19 => 'Night Portrait', # (A330)
    18 => 'Sunset', # (A330)
    17 => 'Sports', # (A330)
    21 => 'Macro', # (A330)
    20 => 'Landscape', # (A330)
    16 => 'Portrait', # (A330)
    35 => 'Auto No Flash', # (A330)
);

# ExposureProgram values in CameraSettings3 (ref 12)
my %sonyExposureProgram2 = (            # A580 Mode Dial setting:
     1 => 'Program AE',                 # P
     2 => 'Aperture-priority AE',       # A
     3 => 'Shutter speed priority AE',  # S
     4 => 'Manual',                     # M
     5 => 'Cont. Priority AE',          # (A35)
    16 => 'Auto',                       # AUTO
    17 => 'Auto (no flash)',            # "flash strike-out" symbol
    18 => 'Auto+',                      #PH (A33)
    49 => 'Portrait',                   # SCN
    50 => 'Landscape',                  # SCN
    51 => 'Macro',                      # SCN
    52 => 'Sports',                     # SCN
    53 => 'Sunset',                     # SCN
    54 => 'Night view',                 # SCN
    55 => 'Night view/portrait',        # SCN
    56 => 'Handheld Night Shot',        # SCN (also called "Hand-held Twilight")
    57 => '3D Sweep Panorama',          # "Panorama" symbol
    64 => 'Auto 2',                     #PH (A33 AUTO)
    65 => 'Auto 2 (no flash)',          #12 (NC, A35)
    80 => 'Sweep Panorama',             # "Panorama" symbol
    96 => 'Anti Motion Blur',           #PH (NEX-5)
    # 128-138 are A35 picture effects (combined SCN/Picture effect mode dial position)
    128 => 'Toy Camera',
    129 => 'Pop Color',
    130 => 'Posterization',
    131 => 'Posterization B/W',
    132 => 'Retro Photo',
    133 => 'High-key',
    134 => 'Partial Color Red',
    135 => 'Partial Color Green',
    136 => 'Partial Color Blue',
    137 => 'Partial Color Yellow',
    138 => 'High Contrast Monochrome',
);

# WhiteBalanceSetting values (ref 12)
my %whiteBalanceSetting = (
    0x10 => 'Auto (-3)', #(NC)
    0x11 => 'Auto (-2)', #(NC)
    0x12 => 'Auto (-1)', #(NC)
    0x13 => 'Auto (0)',
    0x14 => 'Auto (+1)', #(NC)
    0x15 => 'Auto (+2)', #(NC)
    0x16 => 'Auto (+3)', #(NC)
    0x20 => 'Daylight (-3)',
    0x21 => 'Daylight (-2)', #(NC)
    0x22 => 'Daylight (-1)', #(NC)
    0x23 => 'Daylight (0)',
    0x24 => 'Daylight (+1)',
    0x25 => 'Daylight (+2)',
    0x26 => 'Daylight (+3)',
    0x30 => 'Shade (-3)', #(NC)
    0x31 => 'Shade (-2)', #(NC)
    0x32 => 'Shade (-1)', #(NC)
    0x33 => 'Shade (0)',
    0x34 => 'Shade (+1)', #(NC)
    0x35 => 'Shade (+2)', #(NC)
    0x36 => 'Shade (+3)',
    0x40 => 'Cloudy (-3)', #(NC)
    0x41 => 'Cloudy (-2)', #(NC)
    0x42 => 'Cloudy (-1)', #(NC)
    0x43 => 'Cloudy (0)',
    0x44 => 'Cloudy (+1)', #(NC)
    0x45 => 'Cloudy (+2)', #(NC)
    0x46 => 'Cloudy (+3)', #(NC)
    0x50 => 'Tungsten (-3)', #(NC)
    0x51 => 'Tungsten (-2)', #(NC)
    0x52 => 'Tungsten (-1)', #(NC)
    0x53 => 'Tungsten (0)',
    0x54 => 'Tungsten (+1)', #(NC)
    0x55 => 'Tungsten (+2)', #(NC)
    0x56 => 'Tungsten (+3)', #(NC)
    0x60 => 'Fluorescent (-3)', #(NC)
    0x61 => 'Fluorescent (-2)', #(NC)
    0x62 => 'Fluorescent (-1)', #(NC)
    0x63 => 'Fluorescent (0)',
    0x64 => 'Fluorescent (+1)', #(NC)
    0x65 => 'Fluorescent (+2)', #(NC)
    0x66 => 'Fluorescent (+3)', #(NC)
    0x70 => 'Flash (-3)', #(NC)
    0x71 => 'Flash (-2)', #(NC)
    0x72 => 'Flash (-1)', #(NC)
    0x73 => 'Flash (0)',
    0x74 => 'Flash (+1)', #(NC)
    0x75 => 'Flash (+2)', #(NC)
    0x76 => 'Flash (+3)', #(NC)
    0xa3 => 'Custom',
    0xf3 => 'Color Temperature/Color Filter',
);

# AF points for cameras with 15-point AF (ref 12)
my %afPoint15 = (
    0 => 'Upper-left',
    1 => 'Left',
    2 => 'Lower-left',
    3 => 'Far Left',
    4 => 'Top (horizontal)',
    5 => 'Near Right',
    6 => 'Center (horizontal)',
    7 => 'Near Left',
    8 => 'Bottom (horizontal)',
    9 => 'Top (vertical)',
    10 => 'Center (vertical)',
    11 => 'Bottom (vertical)',
    12 => 'Far Right',
    13 => 'Upper-right',
    14 => 'Right',
    15 => 'Lower-right',
    16 => 'Upper-middle',
    17 => 'Lower-middle',
);

# AF points for cameras with 19-point AF (ref PH)
# (verified for A77 firmware 1.07)
my %afPoint19 = (
    0 => 'Upper Far Left',
    1 => 'Upper-left (horizontal)',
    2 => 'Far Left (horizontal)',
    3 => 'Left (horizontal)',
    4 => 'Lower Far Left',
    5 => 'Lower-left (horizontal)',
    6 => 'Upper-left (vertical)',
    7 => 'Left (vertical)',
    8 => 'Lower-left (vertical)',
    9 => 'Far Left (vertical)',
    10 => 'Top (horizontal)',
    11 => 'Near Right',
    12 => 'Center (horizontal)',
    13 => 'Near Left',
    14 => 'Bottom (horizontal)',
    15 => 'Top (vertical)',
    16 => 'Upper-middle',
    17 => 'Center (vertical)',
    18 => 'Lower-middle',
    19 => 'Bottom (vertical)',
    20 => 'Upper Far Right',
    21 => 'Upper-right (horizontal)',
    22 => 'Far Right (horizontal)',
    23 => 'Right (horizontal)',
    24 => 'Lower Far Right',
    25 => 'Lower-right (horizontal)',
    26 => 'Far Right (vertical)',
    27 => 'Upper-right (vertical)',
    28 => 'Right (vertical)',
    29 => 'Lower-right (vertical)',
);

# ReleaseMode values in Tags 2010 and 94xx (ref 12)
my %sonyReleaseMode2 = (
    0 => 'Normal',
    1 => 'Continuous', # (RX100 "Continuous - Self-timer")
    2 => 'Continuous - Exposure Bracketing', # (RX100)
    3 => 'Continuous - White Balance Bracketing', # (HX9V) (RX100)
    5 => 'Continuous - Burst', # (HX9V)
    6 => 'Single Frame - Capture During Movie', #PH (RX100)
    7 => 'Continuous - Sweep Panorama',
    8 => 'Continuous - Anti-Motion Blur, Hand-held Twilight', # (HX9V)
    9 => 'Continuous - HDR',
    10 => 'Continuous - Background defocus', # (HX9V)
    13 => 'Continuous - 3D Sweep Panorama', #PH/12
    16 => 'Continuous - 3D Image', # (HX9V)
    # 17 - ReleaseMode3 is 'Continuous - Burst' (WX7 - PH)
    19 => 'Continuous - Speed/Advance Priority', #PH/12 (RX100)
    20 => 'Continuous - Multi Frame NR',
    26 => 'Continuous Low', #PH (A77)
    27 => 'Continuous - High Sensitivity',  # seen for DSC-WX60 and WX300
    28 => 'Smile Shutter', #PH (RX100)
    29 => 'Continuous - Tele-zoom Advance Priority',
);

my %binaryDataAttrs = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    WRITE_PROC => \&Image::ExifTool::WriteBinaryData,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    WRITABLE => 1,
    FIRST_ENTRY => 0,
);

# tagInfo attributes for unknown cipher block tags
my %unknownCipherData = (
    Unknown => 1,   # require Unknown option
    Hidden => 1,    # doesn't appear in Tag Name documentation
    RawConv => sub { Decipher(\$_[0]); return $_[0] },
    ValueConv => 'PrintHex($val)',                      # print as hex
    PrintConv => 'length($val) > 65 ? substr($val,0,60) . "[...]" : $val',  # limit length
);

# Sony maker notes tags (some elements in common with %Image::ExifTool::Minolta::Main)
%Image::ExifTool::Sony::Main = (
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => q{
        The following information has been decoded from the MakerNotes of Sony
        cameras.  Some of these tags have been inherited from the Minolta
        MakerNotes.
    },
    0x0010 => [ #PH
        {
            Name => 'CameraInfo',
            # count: A33/A35/A55V/A450/A500/A550/A560/A580/NEX3/5/C3/VG10E=15360
            Condition => '$count == 15360',
            SubDirectory => { TagTable => 'Image::ExifTool::Sony::CameraInfo' },
        },{
            Name => 'CameraInfo2',
            # count: A850/A900=5478, A200/A300/A350=5506, A230/A290/A330/A380/A390=6118, A700=368
            SubDirectory => { TagTable => 'Image::ExifTool::Sony::CameraInfo2' },
        }
    ],
    # 0x0018 - starts with "GYRO" for sweep panorama images (ref 12)
    #        - contains ImageStabilization information for Minolta
    0x0020 => [
        {
            Name => 'FocusInfo', #PH
            # count: A200/A230/A290/A300/A330/A350/A380/A390==19154, A700/A850/A900=19148
            Condition => '$count == 19154 or $count == 19148',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::FocusInfo',
                ByteOrder => 'BigEndian',
            },
        },{
            Name => 'MoreInfo', #12
            # count: A450/A500/A550/A560/A580/A33/A35/A55/NEX-3/5/C3/VG10E==20480
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::MoreInfo',
                ByteOrder => 'LittleEndian',
            },
        },
    ],
    0x0102 => { #5/JD
        Name => 'Quality',
        Writable => 'int32u',
        PrintConv => {
            0 => 'RAW',
            1 => 'Super Fine',
            2 => 'Fine',
            3 => 'Standard',
            4 => 'Economy',
            5 => 'Extra Fine',
            6 => 'RAW + JPEG',
            7 => 'Compressed RAW',
            8 => 'Compressed RAW + JPEG',
            0xffffffff => 'n/a', #PH (SLT-A57 panorama)
        },
    },
    0x0104 => { #5/JD
        Name => 'FlashExposureComp',
        Description => 'Flash Exposure Compensation',
        Writable => 'rational64s',
    },
    0x0105 => { #5/JD
        Name => 'Teleconverter',
        Writable => 'int32u',
        PrintHex => 1,
        PrintConv => \%Image::ExifTool::Minolta::minoltaTeleconverters,
    },
    0x0112 => { #JD
        Name => 'WhiteBalanceFineTune',
        Format => 'int32s',
        Writable => 'int32u',
    },
    0x0114 => [ #PH
        {
            Name => 'CameraSettings',
            # count: A200/A300/A350/A700=280, A850/A900=364
            Condition => '$count == 280 or $count == 364',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::CameraSettings',
                ByteOrder => 'BigEndian',
            },
        },
        {
            Name => 'CameraSettings2',
            # count: A230/A290/A330/A380/A390=332
            Condition => '$count == 332',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::CameraSettings2',
                ByteOrder => 'BigEndian',
            },
        },
        {
            Name => 'CameraSettings3',
            # count: A560/A580/A33/A35/A55/NEX3/5/C3/VG10E=1536, A450/A500/A550=2048
            Condition => '$count == 1536 || $count == 2048',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::CameraSettings3',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'CameraSettingsUnknown',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::CameraSettingsUnknown',
                ByteOrder => 'BigEndian',
            },
        },
    ],
    0x0115 => { #JD
        Name => 'WhiteBalance',
        Writable => 'int32u',
        PrintHex => 1,
        PrintConv => {
            0x00 => 'Auto',
            0x01 => 'Color Temperature/Color Filter',
            0x10 => 'Daylight',
            0x20 => 'Cloudy',
            0x30 => 'Shade',
            0x40 => 'Tungsten',
            0x50 => 'Flash',
            0x60 => 'Fluorescent',
            0x70 => 'Custom',
        },
    },
    # Tag 0x0116: extra hardware info (ref 12)
    # (tag not present for A100, A200, A300, A350, A700, nor for A37, A57, A65, A77)
    0x0116 => [ #12
        {
            Name => 'ExtraInfo',
            Condition => '$$self{Model} =~ /^(DSLR-A(850|900))\b/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sony::ExtraInfo',
                ByteOrder => 'BigEndian',
            },
        },{
            Name => 'ExtraInfo2',
            Condition => '$$self{Model} =~ /^(DSLR-A(230|290|330|380|390))\b/',
            SubDirectory => { TagTable => 'Image::ExifTool::Sony::ExtraInfo2' },
        },{
            Name => 'ExtraInfo3',
            # for DSLR-A450/500/550/560/580, SLT-A33/35/55 and NEX-3/5.
            SubDirectory => { TagTable => 'Image::ExifTool::Sony::ExtraInfo3' },
        }
    ],
    0x0e00 => {
        Name => 'PrintIM',
        Description => 'Print Image Matching',
        SubDirectory => { TagTable => 'Image::ExifTool::PrintIM::Main' },
    },
    # the next 3 tags have a different meaning for some models (with format int32u)
    0x1000 => { #9 (F88, multi burst mode only)
        Name => 'MultiBurstMode',
        Condition => '$format eq "undef"',
        Notes => 'MultiBurst tags valid only for models with this feature, like the F88',
        Writable => 'undef',
        Format => 'int8u',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x1001 => { #9 (F88, multi burst mode only)
        Name => 'MultiBurstImageWidth',
        Condition => '$format eq "int16u"',
        Writable => 'int16u',
    },
    0x1002 => { #9 (F88, multi burst mode only)
        Name => 'MultiBurstImageHeight',
        Condition => '$format eq "int16u"',
        Writable => 'int16u',
    },
    0x1003 => { #9 (TX7, panorama mode only)
        Name => 'Panorama',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Panorama' },
    },
    # 0x2000 - undef[1]
    0x2001 => { #PH (JPEG images from all DSLR's except the A100)
        Name => 'PreviewImage',
        Writable => 'undef',
        DataTag => 'PreviewImage',
        # Note: the preview data starts with a 32-byte proprietary Sony header
        WriteCheck => 'return $val=~/^(none|.{32}\xff\xd8\xff)/s ? undef : "Not a valid image"',
        RawConv => q{
            return \$val if $val =~ /^Binary/;
            $val = substr($val,0x20) if length($val) > 0x20;
            return \$val if $val =~ s/^.(\xd8\xff\xdb)/\xff$1/s;
            $$self{PreviewError} = 1 unless $val eq 'none';
            return undef;
        },
        # must construct 0x20-byte header which contains length, width and height
        ValueConvInv => q{
            return 'none' unless $val;
            my $e = new Image::ExifTool;
            my $info = $e->ImageInfo(\$val,'ImageWidth','ImageHeight');
            return undef unless $$info{ImageWidth} and $$info{ImageHeight};
            my $size = Set32u($$info{ImageWidth}) . Set32u($$info{ImageHeight});
            return Set32u(length $val) . $size . ("\0" x 8) . $size . ("\0" x 4) . $val;
        },
    },
    0x2002 => { #12 (written by Sony IDC)
        Name => 'Rating',
        Writable => 'int32u', # (0-5 stars) (4294967295 for an HX9V iSweep Panorama, ref 12)
    },
    # 0x2003 - string[256]: all 0 for DSLR, SLT, NEX; data for DSC-HX9V
    0x2004 => { #PH (NEX-5)
        Name => 'Contrast',
        Writable => 'int32s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x2005 => { #PH (NEX-5)
        Name => 'Saturation',
        Writable => 'int32s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x2006 => { #PH
        Name => 'Sharpness',
        Writable => 'int32s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x2007 => { #PH
        Name => 'Brightness',
        Writable => 'int32s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x2008 => { #PH
        Name => 'LongExposureNoiseReduction',
        Writable => 'int32u',
        PrintHex => 1,
        PrintConv => {
            0 => 'Off',
            1 => 'On (unused)',
            0x10001 => 'On (dark subtracted)', # (NEX-C3)
            0xffff0000 => 'Off (65535)',
            0xffff0001 => 'On (65535)',
            0xffffffff => 'n/a',
        },
    },
    0x2009 => { #PH
        Name => 'HighISONoiseReduction',
        Writable => 'int16u',
        PrintConv => {
            0 => 'Off',
            1 => 'Low',
            2 => 'Normal',
            3 => 'High',
            256 => 'Auto',
            # it seems that all DSC models except DSC-RX models give n/a here (ref 12)
            65535 => 'n/a',
        },
    },
    0x200a => { #PH (A550)
        Name => 'HDR',
        Writable => 'int32u',
        Format => 'int16u',
        Count => 2,
        Notes => 'stored as a 32-bit integer, but read as two 16-bit integers',
        PrintHex => 1,
        PrintConv => [{
            0x0 => 'Off',
            0x01 => 'Auto',
            0x10 => '1.0 EV',
            0x11 => '1.5 EV',
            0x12 => '2.0 EV',
            0x13 => '2.5 EV',
            0x14 => '3.0 EV',
            0x15 => '3.5 EV',
            0x16 => '4.0 EV',
            0x17 => '4.5 EV',
            0x18 => '5.0 EV',
            0x19 => '5.5 EV',
            0x1a => '6.0 EV',
        },{ #12 (A580)
            0 => 'Uncorrected image',  # A580 stores 2 images: uncorrected and HDR
            1 => 'HDR image (good)',
            2 => 'HDR image (fail 1)', # alignment problem?
            3 => 'HDR image (fail 2)', # contrast problem?
        }],
    },
    0x200b => { #PH
        Name => 'MultiFrameNoiseReduction',
        Writable => 'int32u',
        Notes => 'may not be valid for RS100', # (RS100 sample was 0 when this feature was turned on)
        PrintConv => {
            0 => 'Off',
            1 => 'On',
            255 => 'n/a',
        },
    },
    # 0x200c - int32u[3]: '0 0 0'; seen '2 1 0' for HX9V 3D-Image (in both JPG and MPO image)
    # 0x200d - rational64u: 10/10
    0x200e => { #PH (HX20V)
        Name => 'PictureEffect',
        Writable => 'int16u',
        PrintConv => {
            0 => 'Off',
            1 => 'Toy Camera', #12 (A35)
            2 => 'Pop Color', # (also A35/NEX-C3, ref 12)
            3 => 'Posterization', #12 (A35)
            4 => 'Posterization B/W', #12 (A35)
            5 => 'Retro Photo', #12 (A35, NEX-5)
            6 => 'Soft High Key', # (also A65V, A35/NEX-C3 call this "High-key", ref 12)
            7 => 'Partial Color (red)', #12 (A35)
            8 => 'Partial Color (green)', #12 (A35, NEX-5)
            9 => 'Partial Color (blue)', #12 (A35)
            10 => 'Partial Color (yellow)', #12 (A35, NEX-5)
            13 => 'High Contrast Monochrome', #12 (A35)
            16 => 'Toy Camera (normal)', # (also A65, ref 12)
            17 => 'Toy Camera (cool)', # (RX100)
            18 => 'Toy Camera (warm)', # (RX100)
            19 => 'Toy Camera (green)', # (RX100)
            20 => 'Toy Camera (magenta)', # (RX100)
            32 => 'Soft Focus (low)', #12 (RX100)
            33 => 'Soft Focus', #12 (A65V)
            34 => 'Soft Focus (high)', # (RX100)
            48 => 'Miniature (auto)', #12 (A65V/NEX-7, horizontal)
            49 => 'Miniature (top)', # (RX100)
            50 => 'Miniature (middle horizontal)', # (WX100/HX20V, horizontal)
            51 => 'Miniature (bottom)', # (WX100, rotate 90 CW)
            52 => 'Miniature (left)', # (RX100)
            53 => 'Miniature (middle vertical)', # (RX100)
            54 => 'Miniature (right)', # (RX100)
            64 => 'HDR Painting (low)', # (RX100)
            65 => 'HDR Painting', # (also A65V, ref 12)
            66 => 'HDR Painting (high)', # (RX100)
            80 => 'Rich-tone Monochrome', # (also A65V, ref 12)
            97 => 'Water Color', # (HX200V)
            98 => 'Water Color 2',
            112 => 'Illustration (low)', # (RX100)
            113 => 'Illustration', # (RX100)
            114 => 'Illustration (high)', # (RX100)
        },
    },
    0x200f => { #PH (RX100)
        Name => 'SoftSkinEffect',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            1 => 'Low',
            2 => 'Mid',
            3 => 'High',
            0xffffffff => 'n/a', # (A35)
        },
    },
    0x2010 => {
        Name => 'Sony_0x2010',
        %unknownCipherData,
        # notes for data in this block (PH):
        # 0x00 - int32u: SequenceImageNumber
        # 0x04 - int32u: SequenceFileNumber
        # 0x08 - related to drive mode
        # other stuff in 0x2010 (ref 12)
        # 0x1154 => {
        #     Name => 'MeteringMode_2010',
        #     Condition => '$$self{Model} =~ /^SLT-A(37|57)\b/',
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         2 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
        # 0x1178 => {
        #     Name => 'MeteringMode_2010',
        #     Condition => '$$self{Model} =~ /^(SLT-A(65V|77V)|NEX-VG20E)\b/',   # maybe also A99V - to be checked
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         2 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
        # 0x11ac => {
        #     Name => 'MeteringMode_2010',
        #     Condition => '$$self{Model} !~ /^(SLT-A(37|57|65V|77V)|NEX-VG20E)\b/',
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         2 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
    },
    0x2011 => { #PH (A77, NEX-5N)
        Name => 'VignettingCorrection',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            2 => 'Auto',
            0xffffffff => 'n/a', # (RX100)
        },
    },
    0x2012 => { #PH (A77, NEX-5N)
        Name => 'LateralChromaticAberration',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            2 => 'Auto',
            0xffffffff => 'n/a', # (RX100)
        },
    },
    0x2013 => { #PH (A77, NEX-5N)
        Name => 'DistortionCorrection',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            2 => 'Auto',
            0xffffffff => 'n/a', # (RX100)
        },
    },
    0x2014 => { #12/9
        Name => 'WBShiftAB_GM',
        Writable => 'int32s',
        Count => 2,
        Notes => q{
            2 numbers: 1. positive is a shift toward amber, 2. positive is a shift
            toward magenta
        },
    },
    # 0x2015 - int16u: 65535, also for 'normal' HDR images; 0 for HDR-paint and high-contrast-BW effect images
    0x2016 => { #PH (RX100)
        Name => 'AutoPortraitFramed',
        Writable => 'int16u',
        Notes => '"Yes" if this image was created by the Auto Portrait Framing feature',
        PrintConv => { 0 => 'No', 1 => 'Yes' },
    },
    # 0x2017 - int32u: flash mode. 0=off, 1=fired, 2=red-eye (PH NEX-6) (also in A99, RX1, NEX-5R)
    0x201b => { #PH (A99, also written by RX1, NEX-5R, NEX-6)
        Name => 'FocusMode',
        Condition => '$$self{Model} !~ /^DSC-/', # (doesn't seem to apply to RX1)
        Writable => 'int8u',
        Priority => 0,
        PrintConv => {
            0 => 'Manual',
            2 => 'AF-A',
            3 => 'AF-C',
            4 => 'AF-S',
            6 => 'DMF', # "Direct Manual Focus"
            7 => 'AF-D', # "Depth Map Assist Continuous AF"
        },
    },
    0x201c => [ #12
        {
            Name => 'AFAreaModeSetting',
            Condition => '$$self{Model} =~ /^SLT-/',
            Notes => 'SLT models',
            Writable => 'int8u',
            # (the actual AFAreaMode used may be different because
            # the camera overrides this to use Wide mode when tracking)
            PrintConv => {
                0 => 'Wide',
                4 => 'Local',
                8 => 'Zone', #PH
                9 => 'Spot',
            },
        },{
            Name => 'AFAreaModeSetting',
            Condition => '$$self{Model} =~ /^NEX-/',
            Notes => 'NEX models',
            Writable => 'int8u',
            PrintConv => {
                0 => 'Multi',
                1 => 'Center',
                3 => 'Flexible Spot',
            },
        },
    ],
    0x201d => { #12
        Name => 'FlexibleSpotPosition',
        Condition => '$$self{Model} =~ /^NEX-/',
        Writable => 'int16u',
        Count => 2,
        # position in an 11x9 grid. Values are (ref 12, NC in brackets)
        # X = 135,165,196,227,(258),289,320,281,412,442/443
        # Y = (70?),104,(138),(172),206,240,274,308,342,(376?)
        Notes => q{
            X and Y coordinages of the AF point.  Valid only when AFAreaMode is Flexible
            Spot
        },
    },
    0x201e => { #PH (A99) (also exists but not confirmed for RX1 and NEX-5R/6)
        Name => 'AFPointSelected',
        Condition => '$$self{Model} !~ /^DSC-/', # (doesn't seem to apply to RX1)
        Writable => 'int8u',
        PrintConvColumns => 2,
        PrintConv => {
            0 => 'Auto', # (NC)
            1 => 'Center',
            2 => 'Top',
            3 => 'Upper-right',
            4 => 'Right',
            5 => 'Lower-right',
            6 => 'Bottom',
            7 => 'Lower-left',
            8 => 'Left',
            9 => 'Upper-left',
            10 => 'Far Right',
            11 => 'Far Left',
            12 => 'Upper-middle',
            13 => 'Near Right',
            14 => 'Lower-middle',
            15 => 'Near Left',
            16 => 'Upper Far Right',
            17 => 'Lower Far Right',
            18 => 'Lower Far Left',
            19 => 'Upper Far Left',
        },
    },
    0x3000 => {
        Name => 'ShotInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::ShotInfo' },
    },
    # 0x3000: data block that includes DateTimeOriginal string
#
# at least some data for tags 0x2010, 0x9050 and 0x94xx is encrypted - PH
# (This is certainly true for at least parts of 0x2010, 0x9050, 0x9400, 0x9402 and 0x9403,
# but hasn't been verified for other tags -- just to be thorough, decipher all of them)
#
    0x9050 => {
        Name => 'Tag9050',
        # 944 bytes for A37, A57, A99, NEX-F3, NEX-5R, NEX-6, DSC-RX1, DSC-RX100
        # 3072 bytes for A65, A77, NEX-5N, NEX-7, NEX-VG20 (ref 12)
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9050' },
    },
    0x9400 => [
    {
        Name => 'Tag9400a',
        # - first byte must be 0x07, 0x09 or 0x0a (e)
        #   or 0x0c (e) for latest models like NEX-3N, SLT-A58, DSC-WX60 and WX300
        # (the Condition acts on the enciphered data)
        Condition => q{
            $$valPt =~ /^[\x07\x09\x0a]/ or
           ($$valPt =~ /^[\x5e\xe7\x04]/ and $$self{DoubleCipher} = 1)
        },
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9400a' },
    },{
        Name => 'Tag9400b',
        # - first byte 0x0c (e) for the NEX-3N, SLT-A58 and DSC-WX60 and WX300
        Condition => '$$valPt =~ /^\x0c/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9400b' },
    },{
        Name => 'Sony_0x9400',
        %unknownCipherData,
    }],
    0x9401 => {
        Name => 'Sony_0x9401',
        %unknownCipherData,
        # notes for data in this block (ref 12):
        # 0x0000 - 0x0003: (ref PH)
        #   1c 00 ac 0f - HDR models
        #   21 2b cf 0f - NEX-7/VG20E, SLT-A65V/A77V
        #   27 00 fd 0f - DSC-TX20/TX55
        #   2d 00 d5 0d - DSC-HX10V/HX20V/HX200V/TX66/W100/WX50
        #   2f 00 d6 0d - NEX-F3, SLT-A37/A57
        #   32 00 e2 0d - DSC-RX100
        #   33 00 e2 0d - NEX-5R/6
        #   33 40 0d 0e - DSC-RX1
        #   33 50 e2 0d - SLT-A99V
        #   69 1f ff 0f - NEX-5N
        #   b7 0f f7 0f - DSC-HX7V/TX10/WX7/WX10
        #   b7 0f fa 0f - DSC-HX9V/HX100V/TX100/TX100V
        #   cf 0b 9f 0f - DSC-WX9
        #   f4 00 00 03 - DSC-H90/W690
        #   ff ff ff ff - DSC-W650
        # 0x0004 - (RX100: 0 or 1. subsequent data valid only if 1 - PH)
        # 0x0004 => {
        #     Name => 'DynamicRangeOptimizer_JR9401',
        # #        Condition => '$$self{Model} !~ /^NEX-/',
        #     PrintConv => {
        #         0 => 'Off',
        #         1 => 'On',
        #     },
        # },
        # 0x0005 - 0
        # 0x0006 - some DRO Info, 8 or 9 bytes ??
        # 0x0007 => {
        #     Name => 'DynamicRangeOptimizer_9401',
        #     PrintConv => {
        #         0 => 'Disabled', # seen for Panorama images
        #         1 => 'Auto',
        #         3 => 'Lv1', #NC
        #         4 => 'Lv2', #NC
        #         5 => 'Lv3',
        #         6 => 'Lv4',
        #         7 => 'Lv5',
        #         # 8 - seen for VG20E and some other models - PH
        #         255 => 'Off',
        #     },
        # },
        # 0x000d  - something to do with DRO level ?? (int16u ?)
        # 0x0017 - 0=?, 1=normal shots,2=special effects,5=face detection (PH)
        # 0x00f0 - 0x0118: data for HDR-image, HDR-paint, High-contrast-BW, otherwise 0
        # 0x09a3 => {
        #     Name => 'MeteringMode_9401',
        #     Condition => '$$self{Model} =~ /^SLT-/',
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         2 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
        # 0x09ac => {
        #     Name => 'MeteringMode_9401',
        #     Condition => '$$self{Model} =~ /^NEX-/',
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         2 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
        # 0x09e0 => {
        #     Name => 'MeteringMode_9401',
        #     Condition => '$$self{Model} =~ /^DSC-/',
        #     PrintConv => {
        #         0 => 'Multi-segment',
        #         3 => 'Center-weighted average',
        #         3 => 'Spot',
        #     },
        # },
    },
    0x9402 => [{
        Name => 'Tag9402',
        # only valid for some models:
        # - first byte must be 0x0f or 0x10 (enciphered 0x8a or 0x70)
        Condition => '$$self{DoubleCipher} ? $$valPt =~ /^[\x7e\x46]/ : $$valPt =~ /^[\x8a\x70]/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9402' },
    },{
        Name => 'Sony_0x9402',
        %unknownCipherData,
    }],
    0x9403 => [{
        Name => 'Tag9403',
        # first byte must be 0x01
        Condition => '$$valPt =~ /^\x01/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9403' },
    },{
        Name => 'Sony_0x9403',
        %unknownCipherData,
    }],
    0x9404 => {
        Name => 'Sony_0x9404',
        %unknownCipherData,
    },
    0x9405 => {
        Name => 'Sony_0x9405',
        %unknownCipherData,
    },
    0x9406 => [{
        Name => 'Tag9406',
        # - first byte must be 0x01 or 0x02 (enciphered 0x01 or 0x08) and
        #   third byte must be 0x02 or 0x03 (enciphered 0x08 or 0x1b) - ref 12
        # (applies to most SLT and NEX models, but no DSC models)
        Condition => '$$valPt =~ /^[\x01\x08].[\x08\x1b]/s',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag9406' },
    },{
        Name => 'Sony_0x9406',
        %unknownCipherData,
    }],
    0x9407 => {
        Name => 'Sony_0x9407',
        %unknownCipherData,
    },
    0x9408 => {
        Name => 'Sony_0x9408',
        %unknownCipherData,
    },
    0x9409 => {
        Name => 'Sony_0x9409',
        %unknownCipherData,
    },
    0x940a => [{
        Name => 'Tag940a',
        Condition => '$$self{Model} =~ /^SLT-/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag940a' },
    },{
        Name => 'Sony_0x940a',
        %unknownCipherData,
    }],
    0x940b => {
        Name => 'Sony_0x940b',
        %unknownCipherData,
    },
    0x940c => {
        Name => 'Sony_0x940c',
        %unknownCipherData,
    },
    0x940d => {
        Name => 'Sony_0x940d',
        %unknownCipherData,
    },
    0x940e => [{
        Name => 'Tag940e',
        Condition => '$$self{Model} =~ /^SLT-/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::Tag940e' },
    },{
        Name => 'Sony_0x940e',
        %unknownCipherData,
    }],
    0x940f => {
        Name => 'Sony_0x940f',
        %unknownCipherData,
    },
    0x9411 => {
        Name => 'Sony_0x9411',
        %unknownCipherData,
        # 0x02 - int32u?: 1,3,5,7,9 (A77)
    },
    0xb000 => { #8
        Name => 'FileFormat',
        Writable => 'int8u',
        Count => 4,
        # dynamically set the file type to SR2 because we could have assumed ARW up till now
        RawConv => q{
            $self->OverrideFileType($$self{TIFF_TYPE} = 'SR2') if $val eq '1 0 0 0';
            return $val;
        },
        PrintConvColumns => 2,
        PrintConv => {
            '0 0 0 2' => 'JPEG',
            '1 0 0 0' => 'SR2',
            '2 0 0 0' => 'ARW 1.0',
            '3 0 0 0' => 'ARW 2.0',
            '3 1 0 0' => 'ARW 2.1',
            '3 2 0 0' => 'ARW 2.2', #PH (NEX-5)
            '3 3 0 0' => 'ARW 2.3', #PH (SLT-A65,SLT-A77)
            # what about cRAW images?
        },
    },
    0xb001 => { # ref http://forums.dpreview.com/forums/read.asp?forum=1037&message=33609644
        # (ARW and SR2 images only until the SLT-A65V started writing them to JPEG too)
        Name => 'SonyModelID',
        Writable => 'int16u',
        PrintConvColumns => 2,
        PrintConv => {
            2 => 'DSC-R1',
            256 => 'DSLR-A100',
            257 => 'DSLR-A900',
            258 => 'DSLR-A700',
            259 => 'DSLR-A200',
            260 => 'DSLR-A350',
            261 => 'DSLR-A300',
            262 => 'DSLR-A900 (APS-C mode)', #http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,3994.0.html
            263 => 'DSLR-A380/A390', #PH (A390)
            264 => 'DSLR-A330',
            265 => 'DSLR-A230',
            266 => 'DSLR-A290', #PH
            269 => 'DSLR-A850',
            270 => 'DSLR-A850 (APS-C mode)', #http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,3994.0.html
            273 => 'DSLR-A550',
            274 => 'DSLR-A500', #PH
            275 => 'DSLR-A450', #http://dev.exiv2.org/issues/show/0000611
            278 => 'NEX-5', #PH
            279 => 'NEX-3', #PH
            280 => 'SLT-A33', #PH
            281 => 'SLT-A55 / SLT-A55V', #PH (A55 NC)
            282 => 'DSLR-A560', #PH
            283 => 'DSLR-A580', #http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,2881.0.html
            284 => 'NEX-C3', #PH
            285 => 'SLT-A35', #12
            286 => 'SLT-A65 / SLT-A65V', #PH
            287 => 'SLT-A77 / SLT-A77V', #PH
            288 => 'NEX-5N', #PH
            289 => 'NEX-7', #PH
            290 => 'NEX-VG20E', #12
            291 => 'SLT-A37', #12
            292 => 'SLT-A57', #12
            293 => 'NEX-F3', #PH
            294 => 'SLT-A99 / SLT-A99V', #12
            295 => 'NEX-6', #12
            296 => 'NEX-5R', #12
            297 => 'DSC-RX100', #PH
            298 => 'DSC-RX1', #12
            299 => 'NEX-VG900', #12
            303 => 'SLT-A58', #12
            305 => 'NEX-3N', #PH
        },
    },
    0xb020 => { #2
        Name => 'CreativeStyle',
        Writable => 'string',
        # (all of these values have been observed, ref 12 and PH)
        # - this PrintConv is included to make these strings consistent with
        #   other CreativeStyle tags, and to facilitate the language translations
        # - these values are always English, regardless of the camera language settings
        PrintConv => {
            OTHER => sub { shift }, # pass other values straight through
            None        => 'None',
            AdobeRGB    => 'Adobe RGB',
            Real        => 'Real',
            Standard    => 'Standard',
            Vivid       => 'Vivid',
            Portrait    => 'Portrait',
            Landscape   => 'Landscape',
            Sunset      => 'Sunset',
            Nightview   => 'Night View/Portrait',
            BW          => 'B&W',
            Neutral     => 'Neutral',
            Clear       => 'Clear',
            Deep        => 'Deep',
            Light       => 'Light',
            Autumnleaves=> 'Autumn Leaves',
            Sepia       => 'Sepia',
        },
    },
    0xb021 => { #2
        Name => 'ColorTemperature',
        Writable => 'int32u',
        PrintConv => '$val ? ($val==0xffffffff ? "n/a" : $val) : "Auto"',
        PrintConvInv => '$val=~/Auto/i ? 0 : ($val eq "n/a" ? 0xffffffff : $val)',
    },
    0xb022 => { #7
        Name => 'ColorCompensationFilter',
        Format => 'int32s',
        Writable => 'int32u', # (written incorrectly as unsigned by Sony)
        Notes => 'negative is green, positive is magenta',
    },
    0xb023 => { #PH (A100) - (set by mode dial)
        Name => 'SceneMode',
        Writable => 'int32u',
        PrintConvColumns => 2,
        PrintConv => \%Image::ExifTool::Minolta::minoltaSceneMode,
    },
    0xb024 => { #PH (A100)
        Name => 'ZoneMatching',
        Writable => 'int32u',
        PrintConv => {
            0 => 'ISO Setting Used',
            1 => 'High Key',
            2 => 'Low Key',
        },
    },
    0xb025 => { #PH (A100)
        Name => 'DynamicRangeOptimizer',
        Writable => 'int32u',
        PrintConvColumns => 2,
        PrintConv => {
            0 => 'Off',
            1 => 'Standard',
            2 => 'Advanced Auto',
            3 => 'Auto', # (A550)
            8 => 'Advanced Lv1', #JD
            9 => 'Advanced Lv2', #JD
            10 => 'Advanced Lv3', #JD
            11 => 'Advanced Lv4', #JD
            12 => 'Advanced Lv5', #JD
            16 => 'Lv1', # (NEX-5)
            17 => 'Lv2',
            18 => 'Lv3',
            19 => 'Lv4',
            20 => 'Lv5',
        },
    },
    0xb026 => { #PH (A100)
        Name => 'ImageStabilization',
        Writable => 'int32u',
        PrintConv => {
            0 => 'Off',
            1 => 'On',
            0xffffffff => 'n/a', # (HX9V sweep panorama, ref 12)
        },
    },
    0xb027 => { #2
        Name => 'LensType',
        Writable => 'int32u',
        SeparateTable => 1,
        ValueConvInv => 'int($val)', # (must truncate decimal part)
        PrintConv => \%sonyLensTypes,
    },
    0xb028 => { #2
        # (used by the DSLR-A100)
        Name => 'MinoltaMakerNote',
        # must check for zero since apparently a value of zero indicates the IFD doesn't exist
        # (dumb Sony -- they shouldn't write this tag if the IFD is missing!)
        Condition => '$$valPt ne "\0\0\0\0"',
        Flags => 'SubIFD',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Minolta::Main',
            Start => '$val',
        },
    },
    0xb029 => { #2 (set by creative style menu)
        Name => 'ColorMode',
        Writable => 'int32u',
        PrintConvColumns => 2,
        PrintConv => \%Image::ExifTool::Minolta::sonyColorMode,
    },
    0xb02a => {
        Name => 'LensSpec',
        Format => 'undef',
        Writable => 'int8u',
        Count => 8,
        Notes => q{
            like LensInfo, but also specifies lens features: DT, E, ZA, G, SSM, SAM,
            OSS, STF, Reflex, Macro and Fisheye
        },
        ValueConv => \&ConvLensSpec,
        ValueConvInv => \&ConvInvLensSpec,
        PrintConv => \&PrintLensSpec,
        PrintConvInv => \&PrintInvLensSpec,
    },
    0xb02b => { #PH (A550 JPEG and A200, A230, A300, A350, A380, A700 and A900 ARW)
        Name => 'FullImageSize',
        Writable => 'int32u',
        Count => 2,
        # values stored height first, so swap to get "width height"
        ValueConv => 'join(" ", reverse split(" ", $val))',
        ValueConvInv => 'join(" ", reverse split(" ", $val))',
        PrintConv => '$val =~ tr/ /x/; $val',
        PrintConvInv => '$val =~ tr/x/ /; $val',
    },
    0xb02c => { #PH (A550 JPEG and A200, A230, A300, A350, A380, A700 and A900 ARW)
        Name => 'PreviewImageSize',
        Writable => 'int32u',
        Count => 2,
        ValueConv => 'join(" ", reverse split(" ", $val))',
        ValueConvInv => 'join(" ", reverse split(" ", $val))',
        PrintConv => '$val =~ tr/ /x/; $val',
        PrintConvInv => '$val =~ tr/x/ /; $val',
    },
    0xb040 => { #2
        Name => 'Macro',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Off',
            1 => 'On',
            2 => 'Close Focus', #9
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb041 => { #2
        Name => 'ExposureMode',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConvColumns => 2,
        PrintConv => {
            0 => 'Program AE', # (RX100 'Program','Sunset' - PH)
            1 => 'Portrait', #PH (HX1)
            2 => 'Beach', #9
            3 => 'Sports', #9
            4 => 'Snow', #9
            5 => 'Landscape',
            6 => 'Auto', # (RX100 'Intelligent Auto' - PH)
            7 => 'Aperture-priority AE',
            8 => 'Shutter speed priority AE',
            9 => 'Night Scene / Twilight',#2/9
            10 => 'Hi-Speed Shutter', #9
            11 => 'Twilight Portrait', #9 (RX100 'Night Portrait' - PH)
            12 => 'Soft Snap/Portrait', #9 (TX7 'Soft Snap'; RX100/A37 'Portrait' but manuals say "reproduces soft skin tone" - PH)
            13 => 'Fireworks', #9
            14 => 'Smile Shutter', #9 (T200)
            15 => 'Manual',
            18 => 'High Sensitivity', #9
            19 => 'Macro', #12
            20 => 'Advanced Sports Shooting', #9
            29 => 'Underwater', #9
            33 => 'Food', #9
            34 => 'Sweep Panorama', #PH (HX1)
            35 => 'Handheld Night Shot', #PH (HX1/TX1, also called "Hand-held Twilight")
            36 => 'Anti Motion Blur', #PH (TX1)
            37 => 'Pet', #9
            38 => 'Backlight Correction HDR', #9
            39 => 'Superior Auto', #9
            40 => 'Background Defocus', #PH (HX20V)
            41 => 'Soft Skin', #12 (HX9V) (HX200V Portrait - PH)
            42 => '3D Image', #12 (HX9V)
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb042 => { #9
        Name => 'FocusMode',
        Condition => '$$self{Model} !~ /^DSC-[HR]X/', #12
        Notes => 'not FocusMode for all models',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            # 0 - seen this for panorama shot
            1 => 'AF-S', # (called Single-AF by Sony)
            2 => 'AF-C', # (called Monitor-AF by Sony)
            4 => 'Permanent-AF', # (TX7,HX9V?)
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb043 => { #9
        Name => 'AFAreaMode',
        Writable => 'int16u',
        Condition => '$$self{Model} !~ /^DSC-[HR]X/', #12
        RawConv => '$val == 65535 ? undef : $val',
        Notes => 'not valid for some models', # (ie. RX100 which is always 0 - PH)
        PrintConv => {
            # 0 - (takes this value after camera reset, but can't be set back once changed)
            # 0 - 'Multi AF' for the HX9V (ref 12)
            0 => 'Default',
            1 => 'Multi', # ('Center AF' for the HX9V, ref 12)
            2 => 'Center',
            3 => 'Spot', # ('Flexible Spot' for the HX9V, ref 12)
            4 => 'Flexible Spot', # (T200)
            6 => 'Touch',
            14 => 'Tracking', #12 (HX9V) ("Manual" for the T200?, ref 9)
            15 => 'Face Tracking', # (not set when in face detect mode and no faces detected)
            # 255 - 'n/a' for the HX9V (ref 12)
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb044 => { #9
        Name => 'AFIlluminator',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Off',
            1 => 'Auto',
            65535 => 'n/a', #PH (A100)
        },
    },
    # 0xb045 - int16u: 0
    # 0xb046 - int16u: 0
    0xb047 => { #2
        Name => 'JPEGQuality',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Standard',
            1 => 'Fine',
            2 => 'Extra Fine', #12
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb048 => { #9
        Name => 'FlashLevel',
        Writable => 'int16s',
        RawConv => '($val == -1 and $$self{Model} =~ /DSLR-A100\b/) ? undef : $val',
        PrintConv => {
            -32768 => 'Low',
            -6 => '-6/3', #12 (NC)
            -5 => '-5/3', #12 (NC)
            -4 => '-4/3', #12 (NC)
            -3 => '-3/3',
            -2 => '-2/3',
            -1 => '-1/3', # (for the A100, -1 is effectively 'n/a' - PH)
            0 => 'Normal',
            1 => '+1/3',
            2 => '+2/3',
            3 => '+3/3',
            4 => '+4/3', #12 (NC)
            5 => '+5/3', #12 (NC)
            6 => '+6/3', #12
            128 => 'n/a', #12 (HX9V)
            32767 => 'High',
        },
    },
    0xb049 => { #9
        Name => 'ReleaseMode',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Normal', # (ie. shutter button)
            2 => 'Continuous',
            5 => 'Exposure Bracketing',
            6 => 'White Balance Bracketing', # (HX5)
            65535 => 'n/a', #PH (A100)
        },
    },
    0xb04a => { #9
        Name => 'SequenceNumber',
        Notes => 'shot number in continuous burst',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Single',
            65535 => 'n/a', #PH (A100)
            OTHER => sub { shift }, # pass all other numbers straight through
        },
    },
    0xb04b => { #2/PH
        Name => 'Anti-Blur',
        Writable => 'int16u',
        RawConv => '$val == 65535 ? undef : $val',
        PrintConv => {
            0 => 'Off',
            1 => 'On (Continuous)', #PH (NC)
            2 => 'On (Shooting)', #PH (NC)
            65535 => 'n/a',
        },
    },
    # 0xb04c - rational64u: 10/10 (seen 5 for HX9V Manual-exposure images, ref 12)
    # 0xb04d - int16u: 0
    0xb04e => [
        { #PH (RX100)
            Name => 'FocusMode',
            Condition => '$$self{Model} =~ /^DSC-[HR]X/', #12
            Notes => 'FocusMode for RX100',
            Writable => 'int16u',
            PrintConv => {
                0 => 'Manual',
                2 => 'AF-S',
                3 => 'AF-C',
                5 => 'Semi-manual', #12 (HX9V)
                6 => 'Direct Manual Focus',
            },
        },{ #2
            Name => 'LongExposureNoiseReduction',
            Notes => 'LongExposureNoiseReduction for other models',
            Writable => 'int16u',
            RawConv => '$val == 65535 ? undef : $val',
            PrintConv => {
                0 => 'Off',
                1 => 'On',
                2 => 'On 2', #PH (TX10, TX100, WX9, WX10, etc)
                # 4 - seen this (CX360E, CX700E)
                65535 => 'n/a', #PH (A100)
            },
        },
    ],
    0xb04f => { #PH (TX1)
        Name => 'DynamicRangeOptimizer',
        Writable => 'int16u',
        Priority => 0, # (unreliable for the A77)
        PrintConv => {
            0 => 'Off',
            1 => 'Standard',
            2 => 'Plus',
            # 8 for HDR models - what does this mean?
        },
    },
    0xb050 => { #PH (RX100)
        Name => 'HighISONoiseReduction2',
        Condition => '$$self{Model} =~ /^DSC-/',
        Notes => 'DSC models only',
        Writable => 'int16u',
        PrintConv => {
            0 => 'Normal',
            1 => 'High',
            2 => 'Low',
            3 => 'Off', #12
            # it seems that all SLT and NEX models give n/a here (ref 12)
            65535 => 'n/a',
        },
    },
    # 0xb051 - int16u: 0
    0xb052 => { #PH (TX1)
        Name => 'IntelligentAuto',
        Writable => 'int16u',
        PrintConv => {
            0 => 'Off',
            1 => 'On',
            2 => 'Advanced', #9
        },
    },
    # 0xb053 - int16u: normally 0, but got 1 for a superior auto backlight picture (RX100)
    0xb054 => { #PH/9/12 (TX1,TX7,RX100,HX9V)
        Name => 'WhiteBalance',
        Writable => 'int16u',
        Notes => q{
            decoding of the Fluorescent settings matches the EXIF standard, which is
            different than the names used by Sony for some models
        },
        PrintConv => {
            0 => 'Auto',
            4 => 'Custom', # (manual)
            5 => 'Daylight',
            6 => 'Cloudy',
            # PrintConv names matching Exif Fluorescent LightSource names (ref 12)
            # (Sony uses conflicting names for some models)
            7 => 'Cool White Fluorescent', # (RX100) (TX7/HX9V "Fluorescent 1 (White)", ref 9/12)
            8 => 'Day White Fluorescent',  # (RX100) (TX7/HX9V "Fluorescent 2 (Natural White)", ref 9/12)
            9 => 'Daylight Fluorescent',   # (RX100) (TX7/HX9V "Fluorescent 3 (Day White)", ref 9/12)
            10 => 'Incandescent2', #12 (HX9V)
            11 => 'Warm White Fluorescent',
            14 => 'Incandescent',
            15 => 'Flash',
            17 => 'Underwater 1 (Blue Water)', #9
            18 => 'Underwater 2 (Green Water)', #9
        },
    },
);

# "SEMC MS" maker notes
%Image::ExifTool::Sony::Ericsson = (
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    NOTES => 'Maker notes found in images from some Sony Ericsson phones.',
    0x2000 => {
        Name => 'MakerNoteVersion',
        Writable => 'undef',
        Count => 4,
    },
    0x201 => {
        Name => 'PreviewImageStart',
        IsOffset => 1,
        MakerPreview => 1, # force preview inside maker notes
        OffsetPair => 0x202,
        DataTag => 'PreviewImage',
        Writable => 'int32u',
        Protected => 2,
        Notes => 'a small 320x200 preview image',
    },
    0x202 => {
        Name => 'PreviewImageLength',
        OffsetPair => 0x201,
        DataTag => 'PreviewImage',
        Writable => 'int32u',
        Protected => 2,
    },
);

# Camera information for the A55 (ref PH)
# (also valid for A33, A35, A560, A580 - ref 12)
%Image::ExifTool::Sony::CameraInfo = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => q{
        Camera information stored by the A33, A35, A55, A450, A500, A550, A560,
        A580, NEX-3/5/C3 and VG10E.  Some tags are valid only for some of these
        models.
    },
    0x00 => { #12
        Name => 'LensSpec',
        Format => 'undef[8]',
        ValueConv => \&ConvLensSpec,
        ValueConvInv => \&ConvInvLensSpec,
        PrintConv => \&PrintLensSpec,
        PrintConvInv => \&PrintInvLensSpec,
    },
    0x0e => { #12
        Name => 'FocalLength',
        Condition => '$$self{Model} !~ /^(DSLR-(A450|A500|A550)$)/',
        Format => 'int16u',
        Priority => 0,
        ValueConv => '$val / 10',
        ValueConvInv => '$val * 10',
        PrintConv => 'sprintf("%.1f mm",$val)',
        PrintConvInv => '$val =~ s/ mm//; $val',
    },
    0x10 => { #12
        Name => 'FocalLengthTeleZoom',
        Condition => '$$self{Model} !~ /^(DSLR-(A450|A500|A550)$)/',
        Format => 'int16u',
        ValueConv => '$val * 2 / 3',
        ValueConvInv => 'int($val * 3 / 2 + 0.5)',
        PrintConv => 'sprintf("%.1f mm",$val)',
        PrintConvInv => '$val =~ s/ mm//; $val',
    },
    0x19 => { #12
        Name => 'FocusStatus',
        Condition => '$$self{Model} =~ /^(SLT-|DSLR-A(560|580))\b/',
        Notes => 'not valid with Contrast AF or for NEX models',
        # seen the following values:
        #  0 with MF (A35, A55V-HDR, A560, A580), non-AF lens (A35), and A580 Contrast-AF
        #  4 with MF (A33, A55V), and A580 Contrast-AF
        # 16 with AF-C (or AF-A) and focus OK
        # 24 with AF-C (or AF-A) and unsharp or fast moving subject e.g. bird in flight
        # 64 with AF-S (or AF-A) and focus OK
        PrintConv => {
            0 => 'Manual - Not confirmed (0)',
            4 => 'Manual - Not confirmed (4)',
            16 => 'AF-C - Confirmed',
            24 => 'AF-C - Not Confirmed',
            64 => 'AF-S - Confirmed',
        },
    },
    0x1c => {
        Name => 'AFPointSelected',  # (v8.88: renamed from LocalAFAreaPointSelected)
        Condition => '$$self{Model} =~ /^(SLT-|DSLR-A(560|580))\b/',
        Notes => 'not valid for Contrast AF', #12
        # (all of these cameras have an 15-point three-cross AF system, ref 12)
        PrintConvColumns => 2,
        PrintConv => {
            0 => 'Auto', # (seen in Wide mode)
            1 => 'Center',
            2 => 'Top',
            3 => 'Upper-right',
            4 => 'Right',
            5 => 'Lower-right',
            6 => 'Bottom',
            7 => 'Lower-left',
            8 => 'Left',
            9 => 'Upper-left',
            10 => 'Far Right',
            11 => 'Far Left',
            12 => 'Upper-middle',
            13 => 'Near Right',
            14 => 'Lower-middle',
            15 => 'Near Left',
        },
    },
    0x1d => {
        Name => 'FocusMode',
        Condition => '$$self{Model} =~ /^(SLT-|DSLR-A(560|580))\b/',
        PrintConv => {
            0 => 'Manual',
            1 => 'AF-S',
            2 => 'AF-C',
            3 => 'AF-A',
        },
    },
    0x20 => { #12
        Name => 'AFPoint',  # (v8.88: renamed from LocalAFAreaPointUsed)
        Condition => '$$self{Model} =~ /^(SLT-|DSLR-A(560|580))\b/',
        Notes => 'the AF sensor used for focusing. Not valid for Contrast AF',
        PrintConvColumns => 2,
        PrintConv => {
            %afPoint15,
            255 => '(none)', #PH (A55, guess; also A35 with non-AF lens, ref 12)
        },
    },
    # 0x0166 - starting here there are 96 unknown blocks of 155 bytes each for the
    #          A33/35/55, A560/580, but NOT for NEX or A450/500/550, and not
    #          for the A580 in Contrast-AF mode (ref 12)
);

# camera information for other DSLR and NEX models (ref PH)
%Image::ExifTool::Sony::CameraInfo2 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => 'Camera information for other DSLR and NEX models.',
    0x00 => [ #12
        {
            Name => 'LensSpec',
            # the A700/A850/A900 use a different int16 byte ordering! - PH
            Condition => '$$self{Model} =~ /^DSLR-A(700|850|900)\b/',
            Format => 'undef[8]',
            ValueConv => sub {
                my $val = shift;;
                return ConvLensSpec(pack('v*', unpack('n*', $val)));
            },
            ValueConvInv => sub {
                my $val = shift;
                return pack('v*', unpack('n*', ConvInvLensSpec($val)));
            },
            PrintConv => \&PrintLensSpec,
            PrintConvInv => \&PrintInvLensSpec,
        },{
            Name => 'LensSpec',
            Format => 'undef[8]',
            ValueConv => \&ConvLensSpec,
            ValueConvInv => \&ConvInvLensSpec,
            PrintConv => \&PrintLensSpec,
            PrintConvInv => \&PrintInvLensSpec,
        },
    ],
    0x0130 => { #12
        Name => 'AFMicroAdjValue',
        Condition => '$$self{Model} =~ /^DSLR-A(850|900)\b/',
        ValueConv => '$val - 20',
        ValueConvInv => '$val + 20',
    },
    0x0131 => { #12
        Name => 'AFMicroAdjMode',
        Condition => '$$self{Model} =~ /^DSLR-A(850|900)\b/',
        Mask => 0x80,
        PrintConv => {
            0x00 => 'Off',
            0x80 => 'On',
        },
    },
    305.1 => { #12 (0x131)
        Name => 'AFMicroAdjRegisteredLenses',
        Notes => 'number of registered lenses with a non-zero AFMicroAdjValue',
        Condition => '$$self{Model} =~ /^DSLR-A(850|900)\b/',
        Mask => 0x7f,
    },
);

# white balance and other camera information (ref PH)
%Image::ExifTool::Sony::FocusInfo = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PRIORITY => 0,
    NOTES => q{
        More camera settings and focus information decoded for models such as the
        A200, A230, A290, A300, A330, A350, A380, A390, A700, A850 and A900.
    },
    0x0e => [{ #7/12
        Name => 'DriveMode2',
        Condition => '$$self{Model} =~ /^DSLR-A(230|290|330|380|390)$/',
        Notes => 'A230, A290, A330, A380 and A390',
        ValueConvInv => '$val',
        PrintHex => 1,
        PrintConv => { # (values confirmed for specified models - PH)
            0x01 => 'Single Frame', # (A230,A330,A380)
            0x02 => 'Continuous High', #PH (A230,A330)
            0x04 => 'Self-timer 10 sec', # (A230)
            0x05 => 'Self-timer 2 sec, Mirror Lock-up', # (A230,A290,A330,A380,390)
            0x07 => 'Continuous Bracketing', # (A230,A330)
            0x0a => 'Remote Commander', # (A230)
            0x0b => 'Continuous Self-timer', # (A230,A330)
        },
    },{
        Name => 'DriveMode2',
        Notes => 'A200, A300, A350, A700, A850 and A900',
        ValueConvInv => '$val',
        PrintHex => 1,
        PrintConv => {
            0x01 => 'Single Frame',
            0x02 => 'Continuous High', # A700/A900; not on A850
            0x12 => 'Continuous Low', #12
            0x04 => 'Self-timer 10 sec',
            0x05 => 'Self-timer 2 sec, Mirror Lock-up',
            0x06 => 'Single-frame Bracketing',
            0x07 => 'Continuous Bracketing',
            0x18 => 'White Balance Bracketing Low', #12
            0x28 => 'White Balance Bracketing High', #12
            0x19 => 'D-Range Optimizer Bracketing Low', #12
            0x29 => 'D-Range Optimizer Bracketing High', #12
            0x0a => 'Remote Commander', #12
            0x0b => 'Mirror Lock-up', #12 (A850/A900; not on A700)
        },
    }],
    0x10 => { #12 (1 and 2 inverted!)
        Name => 'Rotation',
        PrintConv => {
            0 => 'Horizontal (normal)',
            1 => 'Rotate 270 CW',
            2 => 'Rotate 90 CW',
        },
    },
    0x14 => {
        Name => 'ImageStabilizationSetting',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x15 => { #7
        Name => 'DynamicRangeOptimizerMode',
        PrintConv => {
            0 => 'Off',
            1 => 'Standard',
            2 => 'Advanced Auto',
            3 => 'Advanced Level',
        },
    },
    0x2b => { #12 seen 2,1,3 for both WB and DRO bracketing
        Name => 'BracketShotNumber',
        Notes => 'WB and DRO bracketing',
    },
    0x2c => { #12
        Name => 'WhiteBalanceBracketing',
        PrintConv => {
            0 => 'Off',
            1 => 'Low',
            2 => 'High',
        },
    },
    0x2d => { #12 seen 2,1,3 for both WB and DRO bracketing
        Name => 'BracketShotNumber2',
    },
    0x2e => { # 12
        Name => 'DynamicRangeOptimizerBracket',
        PrintConv => {
            0 => 'Off',
            1 => 'Low',
            2 => 'High',
        },
    },
    0x2f => { #12 seen 0,1,2 and 0,1,2,3,4 for 3 and 5 image bracketing sequences
        Name => 'ExposureBracketShotNumber',
    },
    0x3f => { #12
        Name => 'ExposureProgram',
        PrintConv => \%sonyExposureProgram,
    },
    0x41 => { #12 style actually used (combination of mode dial + creative style menu)
        Name => 'CreativeStyle',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Standard',
            2 => 'Vivid',
            3 => 'Portrait',
            4 => 'Landscape',
            5 => 'Sunset',
            6 => 'Night View/Portrait',
            8 => 'B&W',
            9 => 'Adobe RGB', # A700
            11 => 'Neutral',
            12 => 'Clear', #7
            13 => 'Deep', #7
            14 => 'Light', #7
            15 => 'Autumn Leaves', #7
            16 => 'Sepia', #7
        },
    },
    0x09bb => { #PH (validated only for DSLR-A850)
        Condition => '$$self{Model} =~ /^DSLR-A(200|230|290|300|330|350|380|390|700|850|900)$/',
        Notes => 'only valid for some DSLR models',
        Name => 'FocusPosition',  # 128 = infinity -- see Composite:FocusDistance below
    },
);

# more camera setting information (ref 12)
# - many of these tags are the same as in CameraSettings3
%Image::ExifTool::Sony::MoreInfo = (
    PROCESS_PROC => \&ProcessMoreInfo,
    WRITE_PROC => \&ProcessMoreInfo,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => q{
        More camera settings information decoded for the A450, A500, A550, A560,
        A580, A33, A35, A55, NEX-3/5/C3 and VG10E.
    },
    0x0001 => { # (256 bytes)
        Name => 'MoreSettings',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::MoreSettings' },
    },
    # (byte sizes for a single A580 image -- not checked for other images)
    0x0002 => { # (256 bytes)
        Name => 'FaceInfo',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::FaceInfo' },
    },
    # 0x0101:  512 bytes
    # 0x0102: 1804 bytes
    # 0x0103:  176 bytes
    # 0x0104: 1088 bytes
    # 0x0105:  160 bytes (all zero unless flash is used, ref 12)
    # 0x0106:  256 bytes (faces detected if first byte is non-zero? ref 12)
    0x0107 => { # (7200 bytes: 3 sets of 40x30 int16u values in the range 0-1023)
        Name => 'TiffMeteringImage',
        Notes => q{
            10-bit RGB data from the 1200 AE metering segments, converted to a 16-bit
            TIFF image
        },
        ValueConv => sub {
            my ($val, $exifTool) = @_;
            return undef unless length $val >= 7200;
            return \ "Binary data 7404 bytes" unless $exifTool->Options('Binary');
            my @dat = unpack('v*', $val);
            # TIFF header for a 16-bit RGB 10dpi 40x30 image
            $val = MakeTiffHeader(40,30,3,16,10);
            # re-order data to RGB pixels
            my ($i, @val);
            for ($i=0; $i<40*30; ++$i) {
                # data is 10-bit (max 1023), shift left to fill 16 bits
                # (typically, this gives a very dark image since the data should
                # really be anti-logged to convert from EV to perceived brightness)
                push @val, $dat[$i]<<6, $dat[$i+1200]<<6, $dat[$i+2400]<<6;
            }
            $val .= pack('v*', @val);   # add TIFF strip data
            return \$val;
        },
    },
    # 0x0108:  140 bytes
    # 0x0109:  256 bytes
    # 0x010a:  256 bytes
    # 0x0306:  276 bytes
    # 0x0307:  256 bytes
    # 0x0308:   96 bytes
    # 0x0309:  112 bytes
    # 0xffff:  788 bytes
    # 0x0201:  368 bytes
    # 0x0202:  144 bytes
    # 0x0401: 4608 bytes
);

# more camera setting information (ref 12)
# - many of these tags are the same as in CameraSettings3
%Image::ExifTool::Sony::MoreSettings = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    PRIORITY => 0,
    0x01 => { # interesting: somewhere between CameraSettings3 0x04 and 0x34
        Name => 'DriveMode2',
        PrintHex => 1,
        PrintConv => {
            0x10 => 'Single Frame',
            0x21 => 'Continuous High', # also automatically selected for Scene mode Sports-action (0x05=52)
            0x22 => 'Continuous Low',
            0x30 => 'Speed Priority Continuous',
            0x51 => 'Self-timer 10 sec',
            0x52 => 'Self-timer 2 sec, Mirror Lock-up',
            0x71 => 'Continuous Bracketing 0.3 EV',
            0x75 => 'Continuous Bracketing 0.7 EV',
            0x91 => 'White Balance Bracketing Low',
            0x92 => 'White Balance Bracketing High',
            0xc0 => 'Remote Commander',
        },
    },
    0x02 => {
        Name => 'ExposureProgram',
        PrintConv => \%sonyExposureProgram2,
    },
    0x03 => {
        Name => 'MeteringMode',
        PrintConv => {
            1 => 'Multi-segment',
            2 => 'Center-weighted average',
            3 => 'Spot',
        },
    },
    0x04 => {
        Name => 'DynamicRangeOptimizerSetting',
        PrintConv => {
            1 => 'Off',
            16 => 'On (Auto)',
            17 => 'On (Manual)',
        },
    },
    0x05 => 'DynamicRangeOptimizerLevel',
    0x06 => {
        Name => 'ColorSpace',
        PrintConv => {
            1 => 'sRGB',
            2 => 'Adobe RGB',
        },
    },
    0x07 => {
        Name => 'CreativeStyleSetting',
        PrintConvColumns => 2,
        PrintConv => {
            16 => 'Standard',
            32 => 'Vivid',
            64 => 'Portrait',
            80 => 'Landscape',
            96 => 'B&W',
            160 => 'Sunset',
        },
    },
    0x08 => { #12
        Name => 'ContrastSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x09 => {
        Name => 'SaturationSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x0a => {
        Name => 'SharpnessSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x0d => {
        Name => 'WhiteBalanceSetting',
        # many guessed, based on "logical system" as observed for Daylight and Shade and steps of 16 between the modes
        PrintHex => 1,
        PrintConvColumns => 2,
        PrintConv => \%whiteBalanceSetting,
        SeparateTable => 1,
    },
    0x0e => {
        Name => 'ColorTemperatureSetting',
        # matches "0xb021 ColorTemperature" when WB set to "Custom" or "Color Temperature/Color Filter"
        ValueConv => '$val * 100',
        ValueConvInv => '$val / 100',
        PrintConv => '"$val K"',
        PrintConvInv => '$val =~ s/ ?K$//i; $val',
    },
    0x0f => {
        Name => 'ColorCompensationFilterSet',
        # seen 0, 1-9 and 245-255, corresponding to 0, M1-M9 and G9-G1 on camera display
        # matches "0xb022 ColorCompensationFilter" when WB set to "Custom" or "Color Temperature/Color Filter"
        Format => 'int8s',
        Notes => 'negative is green, positive is magenta',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x10 => {
        Name => 'FlashMode',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Flash Off',
            16 => 'Autoflash',
            17 => 'Fill-flash',
            18 => 'Slow Sync',
            19 => 'Rear Sync',
            20 => 'Wireless',
        },
    },
    0x11 => {
        Name => 'LongExposureNoiseReduction',
        PrintConv => {
            1 => 'Off',
            16 => 'On',  # (unused or dark subject)
        },
    },
    0x12 => {
        Name => 'HighISONoiseReduction',
        PrintConv => {
            16 => 'Low',
            19 => 'Auto',
        },
    },
    0x13 => { # why is this not valid for A450/A500/A550 ?
        Name => 'FocusMode',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            17 => 'AF-S',
            18 => 'AF-C',
            19 => 'AF-A',
            32 => 'Manual',
            48 => 'DMF', # (NC) (seen for NEX-5)
        },
    },
    0x15 => {
        Name => 'MultiFrameNoiseReduction',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            0 => 'n/a', # seen for A450/A500/A550
            1 => 'Off',
            16 => 'On',
            255 => 'None', # seen for NEX-3/5/C3
        },
    },
    0x16 => {
        Name => 'HDRSetting',
        PrintConv => {
            1 => 'Off',
            16 => 'On (Auto)',
            17 => 'On (Manual)',
        },
    },
    0x17 => {
        Name => 'HDRLevel',
        PrintConvColumns => 3,
        PrintConv => {
            33 => '1 EV',
            34 => '1.5 EV', #12 (NC)
            35 => '2 EV',
            36 => '2.5 EV', #12 (NC)
            37 => '3 EV',
            38 => '3.5 EV', #PH (NC)
            39 => '4 EV',
            40 => '5 EV',
            41 => '6 EV',
        },
    },
    0x18 => {
        Name => 'ViewingMode',
        PrintConv => {
            16 => 'ViewFinder',
            33 => 'Focus Check Live View',
            34 => 'Quick AF Live View',
        },
    },
    0x19 => {
        Name => 'FaceDetection',
        PrintConv => {
            1 => 'Off',
            16 => 'On',
        },
    },
    0x1a => {
        Name => 'CustomWB_RBLevels',
        # matches "0x7313 WB_RGGBLevels" when WB set to "Custom", except factor of 4
        Format => 'int16uRev[2]',
    },
    0x1e => {
        Name => 'ExposureCompensationSet',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        ValueConv => '($val - 128) / 24', #PH
        ValueConvInv => 'int($val * 24 + 128.5)',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => 'Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x1f => {
        Name => 'FlashExposureCompSet',
        Description => 'Flash Exposure Comp. Setting',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        ValueConv => '($val - 128) / 24', #PH
        ValueConvInv => 'int($val * 24 + 128.5)',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => 'Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x20 => {
        Name => 'LiveViewAFMethod',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'n/a',
            1 => 'Phase-detect AF',
            2 => 'Contrast AF',
            # Contrast AF is only available with SSM/SAM lenses and in Focus Check LV,
            # NOT in Quick AF LV, and is automatically set when mounting SSM/SAM lens
            # - changes into Phase-AF when switching to Quick AF LV.
        },
    },
    0x26 => { # (this is not in CameraSettings3)
        Name => 'FNumber',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
    0x27 => { # (this is not in CameraSettings3)
        Name => 'ExposureTime',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x2a => {
        Name => 'ExposureCompensation2',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        Format => 'int16s',
        ValueConv => '$val / 8',
        ValueConvInv => '$val * 8',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => '$val',
    },
    0x2c => {
        Name => 'FlashExposureCompSet2',
        Description => 'Flash Exposure Comp. Setting 2',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        Format => 'int16s',
        ValueConv => '$val / 8',
        ValueConvInv => '$val * 8',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => '$val',
    },
    0x2e => { # seen some A55 images where this does not match the other Orientation tags
        Name => 'Orientation2',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            1 => 'Horizontal (normal)',
            6 => 'Rotate 90 CW',
            8 => 'Rotate 270 CW',
        },
    },
    0x30 => {
        Name => 'FlashAction2',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'Did not fire',
            1 => 'Fired',
        },
    },
    0x32 => {
        Name => 'FocusMode2',
        Condition => '$$self{Model} !~ /^(NEX-(3|5)|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'AF',
            1 => 'MF',
        },
    },
    # 0x86: 17=fill flash, 18=slow sync (PH; A550)
    # 0x89: FlashExposureComp = ($val-128)/24 (PH; A550) [same in MoreInfo_0002]
    # 0xfa: same as 0x86 (PH; A550) [same in MoreInfo_0002]
);

# Face detection information (ref 12)
my %faceInfo = (
    Format => 'int16u[4]',
    # re-order to top,left,height,width and scale to full-sized image like other Sony models
    ValueConv => 'my @v=split(" ",$val); $_*=15 foreach @v; "$v[1] $v[0] $v[3] $v[2]"',
    ValueConvInv => 'my @v=split(" ",$val); $_=int($_/15+0.5) foreach @v; "$v[1] $v[0] $v[3] $v[2]"',
);
%Image::ExifTool::Sony::FaceInfo = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    FORMAT => 'int16u',
    DATAMEMBER => [ 0x00 ],
    0x00 => {
        Name => 'FacesDetected',
        DataMember => 'FacesDetected',
        Format => 'int16s',
        RawConv => '$$self{FacesDetected} = ($val == -1 ? 0 : $val); $val',
        PrintConv => {
            OTHER => sub { shift }, # pass other values straight through
            -1 => 'n/a',
        },
    },
    0x01 => {
        Name => 'Face1Position',
        Condition => '$$self{FacesDetected} >= 1',
        %faceInfo,
        Notes => q{
            re-ordered and scaled to return the top, left, height and width of detected
            face, with coordinates relative to the full-sized unrotated image and
            increasing Y downwards
        },
    },
    0x06 => {
        Name => 'Face2Position',
        Condition => '$$self{FacesDetected} >= 2',
        %faceInfo,
    },
    0x0b => {
        Name => 'Face3Position',
        Condition => '$$self{FacesDetected} >= 3',
        %faceInfo,
    },
    0x10 => {
        Name => 'Face4Position',
        Condition => '$$self{FacesDetected} >= 4',
        %faceInfo,
    },
    0x15 => {
        Name => 'Face5Position',
        Condition => '$$self{FacesDetected} >= 5',
        %faceInfo,
    },
    0x1a => {
        Name => 'Face6Position',
        Condition => '$$self{FacesDetected} >= 6',
        %faceInfo,
    },
    0x1f => {
        Name => 'Face7Position',
        Condition => '$$self{FacesDetected} >= 7',
        %faceInfo,
    },
    0x24 => {
        Name => 'Face8Position',
        Condition => '$$self{FacesDetected} >= 8',
        %faceInfo,
    },
);

# Camera settings (ref PH) (decoded mainly from A200)
%Image::ExifTool::Sony::CameraSettings = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    FORMAT => 'int16u',
    PRIORITY => 0,
    NOTES => 'Camera settings for the A200, A300, A350, A700, A850 and A900.',
    0x00 => { #12
        Name => 'ExposureTime',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x01 => { #12
        Name => 'FNumber',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
    0x04 => { #7/12
        Name => 'DriveMode',
        Mask => 0xff, # (not sure what upper byte is for)
        PrintConv => {
            0x01 => 'Single Frame',
            0x02 => 'Continuous High', # A700/A900; not on A850
            0x12 => 'Continuous Low', #12
            0x04 => 'Self-timer 10 sec',
            0x05 => 'Self-timer 2 sec, Mirror Lock-up',
            0x06 => 'Single-frame Bracketing',
            0x07 => 'Continuous Bracketing', # (A200 val=0x1107)
            0x18 => 'White Balance Bracketing Low', #12
            0x28 => 'White Balance Bracketing High', #12
            0x19 => 'D-Range Optimizer Bracketing Low', #12
            0x29 => 'D-Range Optimizer Bracketing High', #12
            0x0a => 'Remote Commander', #12
            0x0b => 'Mirror Lock-up', #12 (A850/A900; not on A700)
        },
    },
    0x06 => { #7 (A700, not valid for other models?)
        Name => 'WhiteBalanceFineTune',
        Condition => '$$self{Model} =~ /DSLR-A700\b/',
        Format => 'int16s',
        Notes => 'A700 only',
    },
    0x0c => { #12
        Name => 'ColorTemperatureSetting',
        # matches "0xb021 ColorTemperature" when WB set to "Custom" or "Color Temperature/Color Filter"
        ValueConv => '$val * 100',
        ValueConvInv => '$val / 100',
        PrintConv => '"$val K"',
        PrintConvInv => '$val =~ s/ ?K$//i; $val',
    },
    0x0d => { #12
        Name => 'ColorCompensationFilterSet',
        Notes => 'negative is green, positive is magenta',
        ValueConv => '$val > 128 ? $val - 256 : $val',
        ValueConvInv => '$val < 0 ? $val + 256 : $val',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x10 => { #7 (A700)
        Name => 'FocusModeSetting',
        PrintConv => {
            0 => 'Manual',
            1 => 'AF-S',
            2 => 'AF-C',
            3 => 'AF-A',
        },
    },
    0x11 => { #JD (A700)
        Name => 'AFAreaMode',
        PrintConv => {
            0 => 'Wide',
            1 => 'Local',
            2 => 'Spot',
        },
    },
    0x12 => { #7 (A700)
        Name => 'AFPointSelected',
        Format => 'int16u',
        # A200, A300, A350: 9-point centre-cross (ref 12)
        # A700: 11-point centre-dual-cross (ref 12)
        # A850, A900: 9-point centre-dual-cross with 10 assist-points (ref 12)
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Center',
            2 => 'Top',
            3 => 'Top-Right',
            4 => 'Right',
            5 => 'Bottom-Right',
            6 => 'Bottom',
            7 => 'Bottom-Left',
            8 => 'Left',
            9 => 'Top-Left',
            10 => 'Far Right', # (presumably A700 only)
            11 => 'Far Left', # (presumably A700 only)
        },
    },
    0x15 => { #7
        Name => 'MeteringMode',
        PrintConv => {
            1 => 'Multi-segment',
            2 => 'Center-weighted Average',
            4 => 'Spot',
        },
    },
    0x16 => {
        Name => 'ISOSetting',
        # 0 indicates 'Auto' (I think)
        ValueConv => '$val ? exp(($val/8-6)*log(2))*100 : $val',
        ValueConvInv => '$val ? 8*(log($val/100)/log(2)+6) : $val',
        PrintConv => '$val ? sprintf("%.0f",$val) : "Auto"',
        PrintConvInv => '$val =~ /auto/i ? 0 : $val',
    },
    0x18 => { #7
        Name => 'DynamicRangeOptimizerMode',
        PrintConv => {
            0 => 'Off',
            1 => 'Standard',
            2 => 'Advanced Auto',
            3 => 'Advanced Level',
        },
    },
    0x19 => { #7
        Name => 'DynamicRangeOptimizerLevel',
    },
    0x1a => { # style actually used (combination of mode dial + creative style menu)
        Name => 'CreativeStyle',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Standard',
            2 => 'Vivid',
            3 => 'Portrait',
            4 => 'Landscape',
            5 => 'Sunset',
            6 => 'Night View/Portrait',
            8 => 'B&W',
            9 => 'Adobe RGB', # A700
            11 => 'Neutral',
            12 => 'Clear', #7
            13 => 'Deep', #7
            14 => 'Light', #7
            15 => 'Autumn Leaves', #7
            16 => 'Sepia', #7
        },
    },
    0x1b => { #12
        Name => 'ColorSpace',
        PrintConv => {
            0 => 'sRGB',
            1 => 'Adobe RGB',        # (A850, selected via Colorspace menu item)
            5 => 'Adobe RGB (A700)', # (A700, selected via CreativeStyle menu)
        },
    },
    0x1c => {
        Name => 'Sharpness',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x1d => {
        Name => 'Contrast',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x1e => {
        Name => 'Saturation',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x1f => { #7
        Name => 'ZoneMatchingValue',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x22 => { #7
        Name => 'Brightness',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x23 => {
        Name => 'FlashMode',
        PrintConv => {
            0 => 'ADI',
            1 => 'TTL',
        },
    },
    0x28 => { #7
        Name => 'PrioritySetupShutterRelease',
        PrintConv => {
            0 => 'AF',
            1 => 'Release',
        },
    },
    0x29 => { #7
        Name => 'AFIlluminator',
        PrintConv => {
            0 => 'Auto',
            1 => 'Off',
        },
    },
    0x2a => { #7
        Name => 'AFWithShutter',
        PrintConv => { 0 => 'On', 1 => 'Off' },
    },
    0x2b => { #7
        Name => 'LongExposureNoiseReduction',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x2c => { #7
        Name => 'HighISONoiseReduction',
        PrintConv => {
            0 => 'Normal',
            1 => 'Low',
            2 => 'High',
            3 => 'Off',
        },
    },
    0x2d => { #7
        Name => 'ImageStyle',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Standard',
            2 => 'Vivid',
            3 => 'Portrait', #PH
            4 => 'Landscape', #PH
            5 => 'Sunset', #PH
            7 => 'Night View/Portrait', #PH (A200/A350 when CreativeStyle was 6!)
            8 => 'B&W', #PH (guess)
            9 => 'Adobe RGB',
            11 => 'Neutral',
            129 => 'StyleBox1',
            130 => 'StyleBox2',
            131 => 'StyleBox3',
            132 => 'StyleBox4', #12 (A850)
            133 => 'StyleBox5', #12 (A850)
            134 => 'StyleBox6', #12 (A850)
        },
    },
    0x2e => { #12 (may not apply to A200/A300/A350 -- they don't have the AF/MF button)
        Name => 'FocusModeSwitch',
        PrintConv => {
            0 => 'AF',
            1 => 'Manual',
        },
    },
    0x2f => { #12
        Name => 'ShutterSpeedSetting',
        Notes => 'used in M, S and Program Shift S modes',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x30 => { #12
        Name => 'ApertureSetting',
        Notes => 'used in M, A and Program Shift A modes',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
    0x3c => {
        Name => 'ExposureProgram',
        PrintConv => \%sonyExposureProgram,
    },
    0x3d => {
        Name => 'ImageStabilizationSetting',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x3f => { # (verified for A330/A380)
        Name => 'Rotation',
        PrintConv => {
            0 => 'Horizontal (normal)',
            1 => 'Rotate 90 CW', #(NC)
            2 => 'Rotate 270 CW',
        },
    },
    0x4d => { #12
        Name => 'FocusMode', # (focus mode actually used)
        PrintConv => {
            0 => 'Manual',
            1 => 'AF-S',
            2 => 'AF-C',
            3 => 'AF-A',
        },
    },
    0x51 => { #12
        Name => 'BatteryLevel',
        PrintConv => '"$val%"',
        PrintConvInv => '$val=~s/\s*\%//; $val',
    },
    0x53 => { #12
        Name => 'FocusStatus',
        PrintConv => {
            0 => 'Not confirmed',
            4 => 'Not confirmed, Tracking',
            BITMASK => {
                0 => 'Confirmed',
                1 => 'Failed',
                2 => 'Tracking',
            },
        },
    },
    0x54 => {
        Name => 'SonyImageSize',
        PrintConv => {
            1 => 'Large',
            2 => 'Medium',
            3 => 'Small',
        },
    },
    0x55 => { #7
        Name => 'AspectRatio',
        PrintConv => {
            1 => '3:2',
            2 => '16:9',
        },
    },
    0x56 => { #PH/7
        Name => 'Quality',
        PrintConv => {
            0 => 'RAW',
            2 => 'CRAW',
            34 => 'RAW + JPEG',
            35 => 'CRAW + JPEG',
            16 => 'Extra Fine',
            32 => 'Fine',
            48 => 'Standard',
        },
    },
    0x58 => { #7
        Name => 'ExposureLevelIncrements',
        PrintConv => {
            33 => '1/3 EV',
            50 => '1/2 EV',
        },
    },
    0x9b => { #12
        Name => 'ImageNumber',
        ValueConv => '$val & 0x3fff', #PH (not sure what the upper 2 bits are for)
        ValueConvInv => '$val',
        PrintConv => 'sprintf("%.4d",$val)',
        PrintConvInv => '$val',
    },
);

# Camera settings (ref PH) (A230, A290, A330, A380 and A390)
%Image::ExifTool::Sony::CameraSettings2 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    FORMAT => 'int16u',
    PRIORITY => 0,
    NOTES => 'Camera settings for the A230, A290, A330, A380 and A390.',
### 0x00-0x03: same TagID as CameraSettings
    0x00 => { #12
        Name => 'ExposureTime',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x01 => { #12
        Name => 'FNumber',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
### 0x04-0x11: subtract 1 from CameraSettings TagID
    # 0x05 - maybe WhiteBalanceFineTune
    0x0b => { #12
        Name => 'ColorTemperatureSetting',
        # matches "0xb021 ColorTemperature" when WB set to "Custom" or "Color Temperature/Color Filter"
        ValueConv => '$val * 100',
        ValueConvInv => '$val / 100',
        PrintConv => '"$val K"',
        PrintConvInv => '$val =~ s/ ?K$//i; $val',
    },
    0x0c => { #12
        Name => 'ColorCompensationFilterSet',
        Notes => 'negative is green, positive is magenta',
        ValueConv => '$val > 128 ? $val - 256 : $val',
        ValueConvInv => '$val < 0 ? $val + 256 : $val',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x0f => { #12/PH (educated guess)
        Name => 'FocusModeSetting',
        PrintConv => {
            0 => 'Manual',
            1 => 'AF-S',
            2 => 'AF-C',
            3 => 'AF-A',
            # seen 5 for A380 (FocusMode was Manual and FocusStatus was Confirmed)
        },
    },
    0x10 => { #12/PH (educated guess)
        Name => 'AFAreaMode',
        PrintConv => {
            0 => 'Wide',
            1 => 'Local',
            2 => 'Spot',
        },
    },
    0x11 => { #12/PH (educated guess)
        Name => 'AFPointSelected',
        Format => 'int16u',
        # (all of these cameras have a 9-point centre-cross AF system, ref 12)
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Center',
            2 => 'Top',
            3 => 'Top-Right',
            4 => 'Right',
            5 => 'Bottom-Right',
            6 => 'Bottom',
            7 => 'Bottom-Left',
            8 => 'Left',
            9 => 'Top-Left',
        },
    },
### 0x12-0x18: subtract 2 from CameraSettings TagID
    0x13 => {
        Name => 'MeteringMode',
        PrintConv => {
            1 => 'Multi-segment',
            2 => 'Center-weighted Average',
            4 => 'Spot',
        },
    },
    0x14 => { # A330/A380
        Name => 'ISOSetting',
        # 0 indicates 'Auto' (?)
        ValueConv => '$val ? exp(($val/8-6)*log(2))*100 : $val',
        ValueConvInv => '$val ? 8*(log($val/100)/log(2)+6) : $val',
        PrintConv => '$val ? sprintf("%.0f",$val) : "Auto"',
        PrintConvInv => '$val =~ /auto/i ? 0 : $val',
    },
    0x16 => {
        Name => 'DynamicRangeOptimizerMode',
        PrintConv => {
            0 => 'Off',
            1 => 'Standard',
            2 => 'Advanced Auto',
            3 => 'Advanced Level',
        },
    },
    0x17 => 'DynamicRangeOptimizerLevel',
    0x18 => { # A380
        Name => 'CreativeStyle',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Standard',
            2 => 'Vivid',
            3 => 'Portrait',
            4 => 'Landscape',
            5 => 'Sunset',
            6 => 'Night View/Portrait',
            8 => 'B&W',
            # (these models don't have Neutral - PH)
        },
    },
### 0x19-0x1b: subtract 3 from CameraSettings TagID
    0x19 => {
        Name => 'Sharpness',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x1a => {
        Name => 'Contrast',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x1b => {
        Name => 'Saturation',
        ValueConv => '$val - 10',
        ValueConvInv => '$val + 10',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
### 0x1c-0x24: subtract 4 from CameraSettings TagID (not sure about 0x1c)
    0x1f => { #PH (educated guess)
        Name => 'FlashMode',
        PrintConv => {
            0 => 'ADI',
            1 => 'TTL',
        },
    },
### 0x25-0x27: subtract 6 from CameraSettings TagID
    0x25 => { #PH
        Name => 'LongExposureNoiseReduction',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x26 => { #PH
        Name => 'HighISONoiseReduction',
        # (Note: the order is different from that in CameraSettings)
        PrintConv => {
            0 => 'Off',
            1 => 'Low',
            2 => 'Normal',
            3 => 'High',
        },
    },
    0x27 => { #PH
        Name => 'ImageStyle',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Standard',
            2 => 'Vivid',
            3 => 'Portrait', #PH
            4 => 'Landscape', #PH
            5 => 'Sunset', #PH
            7 => 'Night View/Portrait', #PH (A200 when CreativeStyle was 6!)
            8 => 'B&W', #PH (A380)
            # (these models don't have Neutral - PH)
        },
    },
### 0x28-0x3b: subtract 7 from CameraSettings TagID
    0x28 => { #PH
        Name => 'ShutterSpeedSetting',
        Notes => 'used in M, S and Program Shift S modes',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x29 => { #PH
        Name => 'ApertureSetting',
        Notes => 'used in M, A and Program Shift A modes',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
### 0x3c-0x59: same TagID as CameraSettings
    0x3c => {
        Name => 'ExposureProgram',
        PrintConv => \%sonyExposureProgram,
    },
    0x3d => { # (copied from CameraSettings, ref 12)
        Name => 'ImageStabilizationSetting',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    0x3f => { # (verified for A330/A380)
        Name => 'Rotation',
        PrintConv => {
            0 => 'Horizontal (normal)',
            1 => 'Rotate 90 CW', #(NC)
            2 => 'Rotate 270 CW',
        },
    },
    0x4d => { #12
        Name => 'FocusMode', # (focus mode actually used)
        PrintConv => {
            0 => 'Manual',
            1 => 'AF-S',
            2 => 'AF-C',
            3 => 'AF-A',
        },
    },
    0x53 => { #12 (copied from CameraSettings, but all bits may not be applicable for these models)
        Name => 'FocusStatus',
        PrintConv => {
            0 => 'Not confirmed',
            4 => 'Not confirmed, Tracking',
            BITMASK => {
                0 => 'Confirmed',
                1 => 'Failed',
                2 => 'Tracking',
            },
        },
    },
    0x54 => {
        Name => 'SonyImageSize',
        PrintConv => {
            1 => 'Large',
            2 => 'Medium',
            3 => 'Small',
        },
    },
    0x55 => { # (copied from CameraSettings, ref 12)
        Name => 'AspectRatio',
        PrintConv => {
            1 => '3:2',
            2 => '16:9',
        },
    },
    0x56 => { # (copied from CameraSettings, ref 12)
        Name => 'Quality',
        PrintConv => {
            0 => 'RAW',
            2 => 'CRAW',
            34 => 'RAW + JPEG',
            35 => 'CRAW + JPEG',
            16 => 'Extra Fine',
            32 => 'Fine',
            48 => 'Standard',
        },
    },
    0x58 => { # (copied from CameraSettings, ref 12)
        Name => 'ExposureLevelIncrements',
        PrintConv => {
            33 => '1/3 EV',
            50 => '1/2 EV',
        },
    },
### 0x5a onwards: subtract 1 from CameraSettings TagID
    0x7e => { #12
        Name => 'DriveMode',
        Mask => 0xff, # (not sure what upper byte is for)
        PrintConv => { # (values confirmed for specified models - PH)
            0x01 => 'Single Frame', # (A230,A330,A380)
            0x02 => 'Continuous High', #PH (A230,A330)
            0x04 => 'Self-timer 10 sec', # (A230)
            0x05 => 'Self-timer 2 sec, Mirror Lock-up', # (A230,A290,A330,A380,390)
            0x07 => 'Continuous Bracketing', # (A230 val=0x1107, A330 val=0x1307 [0.7 EV])
            0x0a => 'Remote Commander', # (A230)
            0x0b => 'Continuous Self-timer', # (A230 val=0x800b [5 shots], A330 val=0x400b [3 shots])
        },
    },
    0x83 => { #PH
        Name => 'ColorSpace',
        PrintConv => {
            5 => 'Adobe RGB',
            6 => 'sRGB',
        },
    },
);

# more Camera settings (ref PH)
# This was decoded for the A55, but it seems to apply to the following models:
# A33, A35, A55, A450, A500, A550, A560, A580, NEX-3, NEX-5, NEX-C3 and NEX-VG10E
%Image::ExifTool::Sony::CameraSettings3 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    FORMAT => 'int8u',
    PRIORITY => 0,
    NOTES => q{
        Camera settings for models such as the A33, A35, A55, A450, A500, A550,
        A560, A580, NEX-3, NEX-5, NEX-C3 and NEX-VG10E.
    },
    0x00 => { #12
        Name => 'ShutterSpeedSetting',
        Notes => 'used only in M and S exposure modes',
        ValueConv => '$val ? 2 ** (6 - $val/8) : 0',
        ValueConvInv => '$val ? int((6 - log($val) / log(2)) * 8 + 0.5) : 0',
        PrintConv => '$val ? Image::ExifTool::Exif::PrintExposureTime($val) : "Bulb"',
        PrintConvInv => 'lc($val) eq "bulb" ? 0 : Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x01 => { #12
        Name => 'ApertureSetting',
        Notes => 'used only in M and A exposure modes',
        ValueConv => '2 ** (($val/8 - 1) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'Image::ExifTool::Exif::PrintFNumber($val)',
        PrintConvInv => '$val',
    },
    0x02 => {
        Name => 'ISOSetting',
        ValueConv => '($val and $val < 254) ? exp(($val/8-6)*log(2))*100 : $val',
        ValueConvInv => '($val and $val != 254) ? 8*(log($val/100)/log(2)+6) : $val',
        PrintConv => {
            OTHER => sub {
                my ($val, $inv) = @_;
                return int($val + 0.5) unless $inv;
                return Image::ExifTool::IsFloat($val) ? $val : undef;
            },
            0 => 'Auto',
            254 => 'n/a', # get this for multi-shot noise reduction
        },
    },
    0x03 => { #12
        Name => 'ExposureCompensationSet',
        ValueConv => '($val - 128) / 24', #PH
        ValueConvInv => 'int($val * 24 + 128.5)',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => 'Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x04 => { #12
        Name => 'DriveModeSetting',
        # Same drivemode info is repeated in 0x0034, but with at least the following exceptions:
        # - 0x0034 not for A550 ? - seen "0"
        # - hand-held night   (0x05=56): 0x0004=0x10 and 0x0034=0xd3
        # - 3D sweep panorama (0x05=57): 0x0004=0x10 and 0x0034=0xd6
        # - sweep panorama    (0x05=80): 0x0004=0x10 and 0x0034=0xd5
        # preliminary conclusion: 0x0004 is Drivemode as pre-set, but may be overruled by Scene/Panorama mode selections
        #                         0x0034 is Divemode as actually used
        PrintHex => 1,
        PrintConv => {
            0x10 => 'Single Frame',
            0x21 => 'Continuous High', # also automatically selected for Scene mode Sports-action (0x05=52)
            0x22 => 'Continuous Low',
            0x30 => 'Speed Priority Continuous',
            0x51 => 'Self-timer 10 sec',
            0x52 => 'Self-timer 2 sec, Mirror Lock-up',
            0x71 => 'Continuous Bracketing 0.3 EV',
            0x75 => 'Continuous Bracketing 0.7 EV',
            0x91 => 'White Balance Bracketing Low',
            0x92 => 'White Balance Bracketing High',
            0xc0 => 'Remote Commander',
        },
    },
    0x05 => { #12
        Name => 'ExposureProgram',
        # Camera exposure program/mode as selected with the Mode dial.
        # For SCN a further selection is done via the menu
        # Matches OK with 0xb023
        PrintConv => \%sonyExposureProgram2,
    },
    0x06 => { #12
        Name => 'FocusModeSetting',
        PrintConv => {
            17 => 'AF-S',
            18 => 'AF-C',
            19 => 'AF-A',
            32 => 'Manual',
            48 => 'DMF', # (NC) (seen for NEX-5)
        },
    },
    0x07 => { #12
        Name => 'MeteringMode',
        PrintConv => {
            1 => 'Multi-segment',
            2 => 'Center-weighted average',
            3 => 'Spot',
        },
    },
    0x09 => { #12
        Name => 'SonyImageSize',
        PrintConv => {  # values confirmed as noted for the A580 and A33
           21 => 'Large (3:2)',    # A580: 16M  (4912x3264), A33: 14M  (4592x3056)
           22 => 'Medium (3:2)',   # A580: 8.4M (3568x2368), A33: 7.4M (3344x2224)
           23 => 'Small (3:2)',    # A580: 4.0M (2448x1624), A33: 3.5M (2288x1520)
           25 => 'Large (16:9)',   # A580: 14M  (4912x2760)
           26 => 'Medium (16:9)',  # A580: 7.1M (3568x2000)
           27 => 'Small (16:9)',   # A580: 3.4M (2448x1376)
        },
    },
    0x0a => { #12
        Name => 'AspectRatio',
        # normally 4 for A580 3:2 ratio images
        # seen 8 when selecting 16:9 via menu, and when selecting Panorama mode
        PrintConv => {
            4 => '3:2',
            8 => '16:9',
        },
    },
    0x0b => { #12
        Name => 'Quality',
        PrintConv => {
            2 => 'RAW',
            4 => 'RAW + JPEG',
            6 => 'Fine',
            7 => 'Standard',
        },
    },
    0x0c => {
        Name => 'DynamicRangeOptimizerSetting',
        PrintConv => {
            1 => 'Off',
            16 => 'On (Auto)',
            17 => 'On (Manual)',
        },
    },
    0x0d => 'DynamicRangeOptimizerLevel',
    0x0e => { #12
        Name => 'ColorSpace',
        PrintConv => {
            1 => 'sRGB',
            2 => 'Adobe RGB',
        },
    },
    0x0f => { #12
        Name => 'CreativeStyleSetting',
        PrintConvColumns => 2,
        PrintConv => {
            16 => 'Standard',
            32 => 'Vivid',
            64 => 'Portrait',
            80 => 'Landscape',
            96 => 'B&W',
            160 => 'Sunset',
        },
    },
    0x10 => { #12 (seen values 253, 254, 255, 0, 1, 2, 3)
        Name => 'ContrastSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x11 => { #12
        Name => 'SaturationSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x12 => { #12
        Name => 'SharpnessSetting',
        Format => 'int8s',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x16 => { #12
        Name => 'WhiteBalanceSetting',
        # many guessed, based on "logical system" as observed for Daylight and Shade and steps of 16 between the modes
        PrintHex => 1,
        PrintConvColumns => 2,
        PrintConv => \%whiteBalanceSetting,
        SeparateTable => 1,
    },
    0x17 => { #12
        Name => 'ColorTemperatureSetting',
        # matches "0xb021 ColorTemperature" when WB set to "Custom" or "Color Temperature/Color Filter"
        ValueConv => '$val * 100',
        ValueConvInv => '$val / 100',
        PrintConv => '"$val K"',
        PrintConvInv => '$val =~ s/ ?K$//i; $val',
    },
    0x18 => { #12
        Name => 'ColorCompensationFilterSet',
        # seen 0, 1-9 and 245-255, corresponding to 0, M1-M9 and G9-G1 on camera display
        # matches "0xb022 ColorCompensationFilter" when WB set to "Custom" or "Color Temperature/Color Filter"
        Format => 'int8s',
        Notes => 'negative is green, positive is magenta',
        PrintConv => '$val > 0 ? "+$val" : $val',
        PrintConvInv => '$val',
    },
    0x19 => { #12
        Name => 'CustomWB_RGBLevels',
        Format => 'int16uRev[3]',
        # 0x19 - 0x1e are related to Custom WB measurements performed by the camera.
        # The values change only each time when measuring and setting a new Custom WB.
        # (0x19,0x1a) and (0x1d,0x1e) are same as MoreSettings (0x1a,0x1b) and (0x1c,0x1d)
    },
    # 0x1f - always 2 (ref 12)
    0x20 => { #12
        Name => 'FlashMode',
        PrintConvColumns => 2,
        PrintConv => {
            1 => 'Flash Off',
            16 => 'Autoflash',
            17 => 'Fill-flash',
            18 => 'Slow Sync',
            19 => 'Rear Sync',
            20 => 'Wireless',
        },
    },
    0x21 => { #12
        Name => 'FlashControl',
        PrintConv => {
            1 => 'ADI Flash',
            2 => 'Pre-flash TTL',
        },
    },
    0x23 => { #12
        Name => 'FlashExposureCompSet',
        Description => 'Flash Exposure Comp. Setting',
        # (as pre-selected by the user, not zero if flash didn't fire)
        ValueConv => '($val - 128) / 24', #PH
        ValueConvInv => 'int($val * 24 + 128.5)',
        PrintConv => '$val ? sprintf("%+.1f",$val) : $val',
        PrintConvInv => 'Image::ExifTool::Exif::ConvertFraction($val)',
    },
    0x24 => {
        Name => 'AFAreaMode',
        PrintConv => {
            1 => 'Wide',
            2 => 'Spot',
            3 => 'Local',
            4 => 'Flexible', #12
            # (Flexible Spot is a grid of 17x11 points for the NEX-5)
        },
    },
    0x25 => { #12
        Name => 'LongExposureNoiseReduction',
        PrintConv => {
            1 => 'Off',
            16 => 'On',  # (unused or dark subject)
        },
    },
    0x26 => { #12
        Name => 'HighISONoiseReduction',
        PrintConv => {
            16 => 'Low',
            19 => 'Auto',
        },
    },
    0x27 => { #12
        Name => 'SmileShutterMode',
        PrintConv => {
            17 => 'Slight Smile',
            18 => 'Normal Smile',
            19 => 'Big Smile',
        },
    },
    0x28 => { #12
        Name => 'RedEyeReduction',
        PrintConv => {
            1 => 'Off',
            16 => 'On',
        },
    },
    0x2d => {
        Name => 'HDRSetting',
        PrintConv => {
            1 => 'Off',
            16 => 'On (Auto)',
            17 => 'On (Manual)',
        },
    },
    0x2e => {
        Name => 'HDRLevel',
        PrintConvColumns => 3,
        PrintConv => {
            33 => '1 EV',
            34 => '1.5 EV', #12 (NC)
            35 => '2 EV',
            36 => '2.5 EV', #12 (NC)
            37 => '3 EV',
            38 => '3.5 EV', #PH (NC)
            39 => '4 EV',
            40 => '5 EV',
            41 => '6 EV',
        },
    },
    0x2f => { #12 (not sure what is difference with 0x85)
        Name => 'ViewingMode',
        PrintConv => {
            16 => 'ViewFinder',
            33 => 'Focus Check Live View',
            34 => 'Quick AF Live View',
        },
    },
    0x30 => { #12
        Name => 'FaceDetection',
        PrintConv => {
            1 => 'Off',
            16 => 'On',
        },
    },
    0x31 => { #12
        Name => 'SmileShutter',
        PrintConv => {
            1 => 'Off',
            16 => 'On',
        },
    },
    0x32 => { #12
        Name => 'SweepPanoramaSize',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            1 => 'Standard',
            2 => 'Wide',
        },
    },
    0x33 => { #12
        Name => 'SweepPanoramaDirection',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            1 => 'Right',
            2 => 'Left',
            3 => 'Up',
            4 => 'Down',
        },
    },
    0x34 => { #12
        Name => 'DriveMode', # (drive mode actually used)
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintHex => 1,
        PrintConv => {
            0x10 => 'Single Frame',
            0x21 => 'Continuous High', # also automatically selected for Scene mode Sports-action (0x05=52)
            0x22 => 'Continuous Low',
            0x30 => 'Speed Priority Continuous',
            0x51 => 'Self-timer 10 sec',
            0x52 => 'Self-timer 2 sec, Mirror Lock-up',
            0x71 => 'Continuous Bracketing 0.3 EV',
            0x75 => 'Continuous Bracketing 0.7 EV',
            0x91 => 'White Balance Bracketing Low',
            0x92 => 'White Balance Bracketing High',
            0xc0 => 'Remote Commander',
            0xd1 => 'Continuous - HDR',
            0xd2 => 'Continuous - Multi Frame NR',
            0xd3 => 'Continuous - Handheld Night Shot', # (also called "Hand-held Twilight")
            0xd4 => 'Continuous - Anti Motion Blur', #PH (NEX-5)
            0xd5 => 'Continuous - Sweep Panorama',
            0xd6 => 'Continuous - 3D Sweep Panorama',
        },
    },
    0x35 => {
        Name => 'MultiFrameNoiseReduction',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            0 => 'n/a', # seen for A450/A500/A550
            1 => 'Off',
            16 => 'On',
            255 => 'None', # seen for NEX-3/5/C3
        },
    },
    0x36 => { #12 (not 100% sure about this one)
        Name => 'LiveViewAFSetting',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'n/a',
            1 => 'Phase-detect AF',
            2 => 'Contrast AF',
            # Contrast AF is only available with SSM/SAM lenses and in Focus Check LV,
            # NOT in Quick AF LV, and is automatically set when mounting SSM/SAM lens
            # - changes into Phase-AF when switching to Quick AF LV.
        },
    },
    0x38 => { #12
        Name => 'PanoramaSize3D',
        Description => '3D Panorama Size',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/',
        PrintConv => {
            0 => 'n/a',
            1 => 'Standard',
            2 => 'Wide',
            3 => '16:9',
        },
    },
    0x83 => { #12
        Name => 'AFButtonPressed',
        # only indicates pressing and holding the "AF" button (centre-controller),
        # not pressing the shutter release button halfway down
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            1 => 'No',
            16 => 'Yes',
        },
    },
    0x84 => { #12 (not 100% sure about this one)
        Name => 'LiveViewMetering',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'n/a',
            16 => '40 Segment',             # DSLR with LiveView/OVF switch in OVF position
            32 => '1200-zone Evaluative',   # SLT, or DSLR with LiveView/OVF switch in LiveView position
        },
    },
    0x85 => { #12 (not sure what is difference with 0x2f)
        Name => 'ViewingMode2',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'n/a',
            16 => 'Viewfinder',
            33 => 'Focus Check Live View',
            34 => 'Quick AF Live View',
        },
    },
    0x86 => { #12
        Name => 'AELock',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            1 => 'On',
            2 => 'Off',
        },
    },
    0x87 => { #12
        Name => 'FlashAction',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/', # seen 0 for A550, so better exclude ?
        PrintConv => {
            1 => 'Did not fire',
            2 => 'Fired',
        },
    },
    0x8b => { #12
        Name => 'LiveViewFocusMode',
        Condition => '$$self{Model} !~ /^(NEX-|DSLR-(A450|A500|A550)$)/',
        PrintConv => {
            0 => 'n/a',
            1 => 'AF',
            16 => 'Manual',
        },
    },
    0x10c => { #12
        Name => 'SequenceNumber',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/', # seen 18 for A550, so better exclude ?
        # normally 0; seen 1,2,3 for bracketing, 6 for Handheld Night Shot, 3 for HDR, 6 for MFNR
        PrintConv => {
            0 => 'Single',
            255 => 'n/a',
            OTHER => sub { shift }, # pass all other numbers straight through
        },
    },
    0x114 => { #12
        Name => 'ImageNumber',
        Condition => '$$self{Model} !~ /^DSLR-(A450|A500|A550)$/', #PH
        Format => 'int16u',
        Mask => 0x3fff, #PH (not sure what the upper 2 bits are for)
        ValueConvInv => '$val',
        PrintConv => 'sprintf("%.4d",$val)',
        PrintConvInv => '$val',
    },
    0x0287 => { #12
        Name => 'FlashAction',
        Condition => '$$self{Model} =~ /^DSLR-(A450|A500|A550)$/',
        Notes => 'A450, A500 and A550',
        PrintConv => {
            1 => 'Did not fire',
            2 => 'Fired',
        },
    },
    0x030c => { #12
        Name => 'SequenceNumber',
        Condition => '$$self{Model} =~ /^DSLR-(A450|A500|A550)$/',
        Notes => 'A450, A500 and A550',
        # normally 0; seen 2 for HDR
        PrintConv => {
            0 => 'Single',
            255 => 'n/a',
            OTHER => sub { shift }, # pass all other numbers straight through
        },
    },
    0x0314 => { #12
        Name => 'ImageNumber',
        Condition => '$$self{Model} =~ /^DSLR-(A450|A500|A550)$/',
        Format => 'int16u',
        Notes => 'A450, A500 and A550',
        Mask => 0x3fff, #PH (not sure what the upper 2 bits are for)
        ValueConvInv => '$val',
        PrintConv => 'sprintf("%.4d",$val)',
        PrintConvInv => '$val',
    },
    0x0400 => { #12
        Name => 'ImageNumber',
        Condition => '$$self{Model} =~ /^DSLR-(A450|A500|A550)$/',
        Format => 'int16u',
        Notes => 'A450, A500 and A550',
        Mask => 0x3fff, #PH (not sure what the upper 2 bits are for)
        ValueConvInv => '$val',
        PrintConv => 'sprintf("%.4d",$val)',
        PrintConvInv => '$val',
    },
);

# Camera settings for other models
%Image::ExifTool::Sony::CameraSettingsUnknown = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    FORMAT => 'int16u',
);

# extra hardware information (ref 12)
%Image::ExifTool::Sony::ExtraInfo = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => 'Extra hardware information for the A850 and A900.',
    # 0x0000: seen values 5 or 6
    0x0001 => {
        Name => 'BatteryTemperature',
        # seen values of appr. 55 - 115: looks like temperature Fahrenheit
        # changing battery in cold weather: new battery starts with value 53
        ValueConv => '($val - 32) / 1.8', # convert to Celsius
        ValueConvInv => '$val * 1.8 + 32',
        PrintConv => 'sprintf("%.1f C",$val)',
        PrintConvInv => '$val=~ s/\s*C//; $val',
        # (may be invalid for non-OEM batteries)
    },
    0x0002 => {
        Name => 'BatteryUnknown',
        # appears to be an int16u value together with 0x0005 (values similar to ExtraInfo3 0x0000)
        # seen values of appr. 800 at 23 deg C to 630 at 40 deg C for A850 with NP-FM500H battery (7.2 V nominal)
        # i.e. inversely proportional to BatteryTemperature: can not be BatteryVoltage, must be something else ?
        Unknown => 1,
        Format => 'undef[4]',
        ValueConv => sub {
            my $val = shift;;
            my @a = unpack("CvC",pack('v*', unpack('n*', $val)));
            return $a[1];
        },
    },
    # 0x0003: seen 0 or 16
    # 0x0004: always 255
    # 0x0006: int16u value together with 0x0009: same behaviour and almost same values as 0x0002
    # 0x0007: always 3
    0x0008 => {
        Name => 'BatteryVoltage',
        # 0x0008: int16u value together with 0x000b:
        # values follow BatteryLevel: from appr.900 when battery full, to appr. 775 when empty.
        # with factor 118 they range from appr. 7.6 to 6.6 - looks like battery voltage (nominal 7.2 V)
        Unknown => 1,
        Format => 'undef[4]',
        ValueConv => sub {
            my $val = shift;;
            my @a = unpack("CvC",pack('v*', unpack('n*', $val)));
            return $a[1]/118;
        },
        PrintConv => 'sprintf("%.2f V",$val)',
    },
    0x000a => {
        # seen mostly 213 and 246, corresponding with other ImageStabilization On/Off tags.
        Name => 'ImageStabilization2',
        Unknown => 1, # (because the decoding is funny and possibly incomplete - PH)
        PrintConv => {
            191 => 'On (191)', # seen a few times with moving subject, continuous drive, bracketing
            207 => 'On (207)', # seen once with RemoteCommander
            210 => 'On (210)', # seen a few times with continous drive
            213 => 'On',
            246 => 'Off',
        },
    },
    # 0x000c: seen always decreasing values, from max. 107 to min. 0,
    #   then jump back to high value: correlates with battery change/recharging
    #   Seen once 255 immediately after inserting new battery, next frame OK at 106.
    #   Validation: matches exactly with batterylevel display on camera (all 100+ values displayed as 100%)
    0x000c => {
        Name => 'BatteryLevel',
        PrintConv => '"$val%"',
        PrintConvInv => '$val=~s/\s*\%//; $val',
    },
    # 0x000d: always 2
    # 0x000e: always 204
    # 0x000f: always 0
    # 0x0010-0x0019: always 204
    0x001a => {
        Name => 'ExtraInfoVersion',
        Format => 'int8u[4]',
        PrintConv => '$val=~tr/ /./; $val',
        PrintConvInv => '$val=~tr/./ /; $val',
        # always 0 1 0 1 for 0x0131 Software = DSLR-A850 v1.00
        # always 0 2 0 4 for 0x0131 Software = DSLR-A850 v2.00
        # seen   0 2 0 0 for 0x0131 Software = DSLR-A900 v1.00
        # seen   0 4 0 0 for 0x0131 Software = DSLR-A900 v1.00
        # seen   0 5 0 4 for 0x0131 Software = DSLR-A900 v2.00
        # A850: correlates exactly with Firmware versions.
        # A900: have there been different FW 1.0 versions ?
    },
);

# extra hardware information (ref 12)
%Image::ExifTool::Sony::ExtraInfo2 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => 'Extra hardware information for the A230/290/330/380/390.',
    0x0004 => {
        Name => 'BatteryLevel',
        PrintConv => '"$val%"',
        PrintConvInv => '$val=~s/\s*\%//; $val',
    },
    0x0012 => {
        Name => 'ImageStabilization',
        PrintConv => {
            0 => 'Off',
            64 => 'On',
        },
    },
);

# extra hardware information (ref 12)
%Image::ExifTool::Sony::ExtraInfo3 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => q{
        Extra hardware information for the A33, A35, A55, A450, A500, A550, A560,
        A580 and NEX-3/5/C3/VG10.
    },
    0x0000 => {
        Name => 'BatteryUnknown',
        # seen values of appr. 870 at 10 deg C to 650 at 39 deg C for A580 with NP-FM500H battery (7.2 V nominal)
        # i.e. inversely proportional to BatteryTemperature: can not be BatteryVoltage, must be something else ?
        Unknown => 1,
        Format => 'int16u',
    },
    0x0002 => {
        Name => 'BatteryTemperature',
        ValueConv => '($val - 32) / 1.8', # convert to Celsius
        ValueConvInv => '$val * 1.8 + 32',
        PrintConv => 'sprintf("%.1f C",$val)',
        PrintConvInv => '$val=~ s/\s*C//; $val',
    },
    0x0004 => {
        Name => 'BatteryLevel',
        PrintConv => '"$val%"',
        PrintConvInv => '$val=~s/\s*\%//; $val',
    },
    # 0x0005:  always 255
    # from here on the differences between DSLR, SLT and NEX
    # 0x0006 and 0x0008:
    #   values follow BatteryLevel: start high (970, 940) when battery full,
    #   and decrease with decreasing battery level to (850, 815)
    #   with factor 128 they range from (7.6, 7.3) to (6.6, 6.4) - looks like battery voltage (nominal 7.2 V)
    0x0006 => {
        Name => 'BatteryVoltage1',
        Format => 'int16u',
        Condition => '$$self{Model} !~ /^(NEX-(3|5|C3|VG10|VG10E))\b/',
        ValueConv => '$val / 128',
        ValueConvInv => '$val * 128',
        PrintConv => 'sprintf("%.2f V",$val)',
        PrintConvInv => '$val=~s/\s*V//; $val',
    },
    0x0008 => {
        Name => 'BatteryVoltage2',
        Format => 'int16u',
        Condition => '$$self{Model} !~ /^(NEX-(3|5|C3|VG10|VG10E))\b/',
        ValueConv => '$val / 128',
        ValueConvInv => '$val * 128',
        PrintConv => 'sprintf("%.2f V",$val)',
        PrintConvInv => '$val=~s/\s*V//; $val',
    },
    # 0x000a - 0x000f: 3 int16u values: probably some mode or status info:
    # seen various 3-number-sequences for SLT and DSLR, but meaning unknown
    # 0x000a => {
    #     Name => 'ExtraInfo_000a',
    #     Format => 'int16u[3]',
    #     Condition => '$$self{Model} !~ /^(NEX-(3|5|C3|VG10|VG10E))\b/',
    # },
    # 0x0010 seen:
    #     176 for SLT
    #     204 for NEX
    #     240 for DSLR
    0x0011 => {
        Name => 'ImageStabilization',
        # usually matches 0xb026 ImageStabilization, except some images with SelfTimer and on tripod
        PrintConv => {
            0 => 'Off',
            64 => 'On',
        },
    },
    0x0014 => [
        {
            Name => 'BatteryState',
            Condition => '$$self{Model} =~ /^(SLT-)\b/',
            # possibly relates to "simple" batterylevel indication with battery-icon, but not completely sure
            Notes => 'BatteryState for SLT models',
            PrintConv => {
                1 =>  'Empty',
                2 =>  'Low',
                3 =>  'Half full',
                4 =>  'Almost full',
                5 =>  'Full',
            },
        },{
            Name => 'ExposureProgram',
            Condition => '$$self{Model} =~ /^DSLR-(A450|A500|A550)\b/',
            Notes => 'ExposureProgram for the A450, A500 and A550',
            Priority => 0, # (some unknown values)
            PrintConv => {
                241 => 'Landscape',
                243 => 'Aperture-priority AE',
                245 => 'Portrait',
                246 => 'Auto',
                247 => 'Program AE',
                249 => 'Macro',
                252 => 'Sunset',
                253 => 'Sports', #PH (A550)
                255 => 'Manual',
                # missing: Shutter speed priority AE, No Flash, Night View
            },
        },{
            Name => 'ModeDialPosition',
            Condition => '$$self{Model} =~ /^DSLR-/',
            Notes => 'ModeDialPosition for other DSLR models',
            # (decoded from A560/A580)
            PrintConv => {
                248 => 'No Flash',
                249 => 'Aperture-priority AE',
                250 => 'SCN', # <-- the reason we don't call it ExposureProgram for these models
                251 => 'Shutter speed priority AE',
                252 => 'Auto',
                253 => 'Program AE',
                254 => 'Panorama',
                255 => 'Manual',
            },
        },
    ],
    # 0x0015: DSLR: appears to be a bitmask relating to "switch" positions:
    #   bit 0 (  1) only seen OFF for A580
    #   bit 1 (  2) ON = Flash down, OFF = Flash raised
    #   bit 2 (  4) only seen ON for A580
    #   bit 3 (  8) only seen ON for A580
    #   bit 4 ( 16) ON = AF,         OFF = MF
    #   bit 5 ( 32) ON = OVF,        OFF = LiveView
    #   bit 6 ( 64) seen ON and OFF, meaning unknown
    #   bit 7 (128) seen ON and OFF, meaning unknown
    0x0016 => {
        Name => 'MemoryCardConfiguration',
        Condition => '$$self{Model} =~ /^(DSLR-)\b/',
        #  DSLR: seen 244,245,252,254, decoded for A580 with 32GB SD and 16GB MS cards
        #  SLT:  seen 64 - 78,   NEX:  seen 62, 190
        PrintConv => {
            244 => 'MemoryStick in use, SD card present',
            245 => 'MemoryStick in use, SD slot empty',
            252 => 'SD card in use, MemoryStick present',
            254 => 'SD card in use, MemoryStick slot empty',
        },
    },
    # 0x0017: seen 0 for SLT, 255 for DSLR, variable for NEX
    0x0018 => {
        Name => 'CameraOrientation',
        Condition => '$$self{Model} !~ /^(NEX-(3|5|C3|VG10|VG10E))\b/',
        Mask => 0x30, # (don't know what other bits mean)
        PrintConv => {
            0x00 =>  'Horizontal (normal)',
            0x10 =>  'Rotate 90 CW',
            0x20 =>  'Rotate 270 CW',
        },
    },
    # 0x0019:
    #   A500/550:  0 - 6 and 251 - 255: could be something from -6 to +6 ?
    #   A560/580:  1 or 64, seen a few 0 and 8
    #   A33/35/55: seen 0, 1, 64
    #   NEX:       204
    # 0x001a, 0x001c appear to be 2 int16u values, meaning unknown
);


# shot information (ref PH)
%Image::ExifTool::Sony::ShotInfo = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    DATAMEMBER => [ 0x02, 0x30, 0x32 ],
    IS_SUBDIR => [ 0x48, 0x5e ],
    # 0x00 - byte order 'II'
    0x02 => {
        Name => 'FaceInfoOffset',
        Format => 'int16u',
        DataMember => 'FaceInfoOffset',
        Writable => 0,
        RawConv => '$$self{FaceInfoOffset} = $val',
    },
    0x06 => {
        Name => 'SonyDateTime',
        Format => 'string[20]',
        Groups => { 2 => 'Time' },
        Shift => 'Time',
        PrintConv => '$self->ConvertDateTime($val)',
        PrintConvInv => '$self->InverseDateTime($val,0)',
    },
    0x1a => { #12
        Name => 'SonyImageHeight',
        Format => 'int16u',
    },
    0x1c => { #12
        Name => 'SonyImageWidth',
        Format => 'int16u',
    },
    0x30 => { #Jeffrey Friedl
        Name => 'FacesDetected',
        DataMember => 'FacesDetected',
        Format => 'int16u',
        RawConv => '$$self{FacesDetected} = $val',
    },
    0x32 => {
        Name => 'FaceInfoLength', # length of a single FaceInfo entry
        DataMember => 'FaceInfoLength',
        Format => 'int16u',
        Writable => 0,
        RawConv => '$$self{FaceInfoLength} = $val',
    },
    #0x34 => {
    #    # values: 'DC5303320222000', 'DC6303320222000' or 'DC7303320222000'
    #    Name => 'UnknownString',
    #    Format => 'string[16]',
    #    Unknown => 1,
    #},
    0x48 => { # (most models: DC5303320222000 and DC6303320222000)
        Name => 'FaceInfo1',
        Condition => q{
            $$self{FacesDetected} and
            $$self{FaceInfoOffset} == 0x48 and
            $$self{FaceInfoLength} == 0x20
        },
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::FaceInfo1' },
    },
    0x5e => { # (HX7V: DC7303320222000)
        Name => 'FaceInfo2',
        Condition => q{
            $$self{FacesDetected} and
            $$self{FaceInfoOffset} == 0x5e and
            $$self{FaceInfoLength} == 0x25
        },
        SubDirectory => { TagTable => 'Image::ExifTool::Sony::FaceInfo2' },
    },
);

# Tag9050 information (ref 12)
%Image::ExifTool::Sony::Tag9050 = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    NOTES => q{
        Data for tags 0x9050, 0x94xx and 0x2010 is encrypted by a simple
        substitution cipher, but the deciphered values are listed below.
    },
    0x0000 => {
        Condition => '$$self{Model} !~ /^(NEX-|DSC-)\b/',
        Name => 'MaxAperture',
        # seen values from 17 - 48
        ValueConv => '2 ** (($val/8 - 1.06) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'sprintf("%.1f",$val)',
        PrintConvInv => '$val',
    },
    0x0001 => {
        Condition => '$$self{Model} !~ /^(NEX-|DSC-)\b/',
        Name => 'MinAperture',
        # seen values from 80 - 95
        ValueConv => '2 ** (($val/8 - 1.06) / 2)',
        ValueConvInv => 'int((log($val) * 2 / log(2) + 1) * 8 + 0.5)',
        PrintConv => 'sprintf("%.0f",$val)',
        PrintConvInv => '$val',
    },
#    0x0002 and 0x0004 (int16u) for SLT:
#           appears to be difference between used FNumber and MaxAperture, 256 being +1 APEX or stop
#           however, not always valid e.g. bracketing, Shutter-prio e.a.
#           difference between 0x0002 and 0x0004 mostly 0.0, 0.1 or 0.2 stops.
    0x0031 => { #12  not DSC-RX
        Condition => '$$self{Model} !~ /^(DSC-(RX1|RX100))\b/',
        Name => 'FlashStatus',
        PrintConv => {
            0 => 'No Flash present',                   # seen for SLT-A99 and NEX-5N, 5R
            64 => 'Built-in Flash present',            # seen for SLT-A37, A57, A65, A77 and NEX-F3, 6, 7
            65 => 'Built-in Flash present and fired',  # seen for SLT-A37, A57, A65, A77 and NEX-F3, 6, 7
            128 => 'External Flash present',           # seen for NEX-5N
            129 => 'External Flash present and fired', # seen for NEX-5N, A99V
        },
    },
    # 0x0032 - increments for each image (PH, A77)
);

# (decoding based on limited number of SLT-A37/A57/A65/A77, NEX-F3/5R, and DSC-HX9V images)
# Note: "(e)" in a comment indicates an enciphered value, all other values are deciphered
# 0x0000-0x0007:    7 1 1 1 0 0 0 0 (e) for several DSC models, e.g. DSC-HX9V
#                   9 1 1 1 0 0 0 0 (e) for several DSC models
#                  10 1 1 1 0 0 0 0 (e) for most SLT, NEX, DSC-RX100, DSC-RX1
#                  12 1 1 1 0 0 0 0 (e) for NEX-3N, SLT-A58, DSC-WX60, DSC-WX300
#                 208 1 1 0 0 0 0 0 (e) H90, W650: tag9400 decoding appears not valid
%Image::ExifTool::Sony::Tag9400a = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    0x0008 => { #PH
        Name => 'SequenceImageNumber',
        Notes => 'number of images captured in burst sequence',
        # (not shutter count because it increments for auto portrait framing)
        Format => 'int32u',
        ValueConv => '$val + 1',
        ValueConvInv => '$val - 1',
    },
    0x000c => { #PH
        Name => 'SequenceFileNumber',
        Notes => 'file number in burst sequence',
        Format => 'int32u',
        ValueConv => '$val + 1', #12
        ValueConvInv => '$val - 1',
    },
    0x0010 => {
        Name => 'ReleaseMode2',
        PrintConv => \%sonyReleaseMode2,
    },
#    0x0012 - Digital Zoom used 0=no, 1=yes (but not for A65V, A77V)
#    0x0013 - Flash fired 0=no, 1=yes
    0x001a => { #PH
        Name => 'ShotNumberSincePowerUp',
        Format => 'int32u',
    },
#    0x001e - increments by 4 each shutter release press since power up?,
#             bit 0x02 has some meaning (RX100 - PH)
#    0x001f - 0=most pictures, 1='Self-timer/Self-portrait', 2='Self-portrait (2 people)',
#             3='Continuous Self-timer', 26='Sweep Panorama' (PH; RX100)
#    0x0021 - maybe related to Image Stabilization or Smile Shutter ?
    0x0022 => {
        Name => 'SequenceLength',
        PrintConv => {
            0 => 'Continuous', # (RX100 too)
            1 => '1 shot',
            2 => '2 shots', # (Background defocus, 3D Image)
            3 => '3 shots', # (HDR, WB Bracketing) (RX100, also continuous bracket)
            4 => '4 shots', # seen for DSC-WX300 in Superior-Auto Anti-Motion-Blur
            5 => '5 shots', # (PH; RX100)
            6 => '6 shots', # (Multi Frame NR, Anti Motion blur, Hand-held Twilight)
            10 => '10 shots', # (HX9V Burst)
            100 => 'Continuous - iSweep Panorama', # (HX9V)
            200 => 'Continuous - Sweep Panorama',
        },
    },
#    0x0027 - 1=single exposure, 2=multi-exposure (ie. pano,some superior auto) (PH; RX100)
    0x0028 => {
        Name => 'CameraOrientation', # (also RX100 - PH)
        PrintConv => {
            1 => 'Horizontal (normal)',
            3 => 'Rotate 180',
            6 => 'Rotate 90 CW',
            8 => 'Rotate 270 CW',
        },
    },
    0x0029 => {
        Name => 'Quality2', # (also RX100 - PH)
        PrintConv => {
            0 => 'JPEG',
            1 => 'RAW',
            2 => 'RAW + JPEG',
            3 => 'JPEG + MPO', # 3D images
        },
    },
#    0x002b - FacesDetected_OK  0=no, 1=yes  appears valid for SLT, but not for NEX and DSC-HX9V
#    0x0030 - long exposure noise reduction used 0=no, 1=yes (PH; RX100)
#    0x0031 - smile shutter used 0=no, 1=yes (PH; RX100)
#    0x0033 - 0 for DSC-HX9V, 8 for SLT, NEX
#    0x0034 and 0x0038 - different offset for HX9V and SLT/NEX, but similar numbers, non-zero when flash fired
);

%Image::ExifTool::Sony::Tag9400b = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    0x0008 => { #PH
        Name => 'SequenceImageNumber',
        Notes => 'number of images captured in burst sequence',
        # (not shutter count because it increments for auto portrait framing)
        Format => 'int32u',
        ValueConv => '$val + 1',
        ValueConvInv => '$val - 1',
    },
    0x000c => { #PH
        Name => 'SequenceFileNumber',
        Notes => 'file number in burst sequence',
        Format => 'int32u',
        ValueConv => '$val + 1', #12
        ValueConvInv => '$val - 1',
    },
    0x0010 => {
        Name => 'ReleaseMode2',
        PrintConv => \%sonyReleaseMode2,
    },
    0x0016 => { #PH
        Name => 'ShotNumberSincePowerUp',
        Format => 'int32u',
    },
    0x001e => {
        Name => 'SequenceLength',
        PrintConv => {
            0 => 'Continuous',
            1 => '1 shot',
            2 => '2 shots',
            3 => '3 shots',
            4 => '4 shots',
            5 => '5 shots',
            6 => '6 shots',
            10 => '10 shots',
            100 => 'Continuous - iSweep Panorama',
            200 => 'Continuous - Sweep Panorama',
        },
    },
    0x0024 => {
        Name => 'CameraOrientation',
        PrintConv => {
            1 => 'Horizontal (normal)',
            3 => 'Rotate 180',
            6 => 'Rotate 90 CW',
            8 => 'Rotate 270 CW',
        },
    },
    0x0025 => {
        Name => 'Quality2',
        PrintConv => {
            0 => 'JPEG',
            1 => 'RAW',
            2 => 'RAW + JPEG',
            3 => 'JPEG + MPO', # 3D images
        },
    },
);


# PH (RX100)
%Image::ExifTool::Sony::Tag9402 = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    DATAMEMBER => [ 0x02 ],
    0x02 => {
        Name => 'TempTest1',
        DataMember => 'TempTest1',
        Hidden => 1,
        RawConv => '$$self{TempTest1}=$val; $$self{OPTIONS}{Unknown}<2 ? undef : $val',
    },
    0x04 => {
        Name => 'AmbientTemperature',
        # this (and many other values) are only valid if 0x02 is 255 (why?)
        Condition => '$$self{TempTest1} == 255',
        Format => 'int8s', # (verified for negative temperature)
        PrintConv => '"$val C"',
        PrintConvInv => '$val=~s/ ?C//; $val',
    },
    0x17 => {
        Name => 'AFAreaMode',
        PrintConv => {
            0 => 'Multi',
            1 => 'Center',
            3 => 'Flexible Spot',
            # 10 - seen for WX100
            14 => 'Tracking',
            15 => 'Face Tracking',
            255 => 'Manual',
        },
    },
    # 0x8a - int32u: some sort of accumulated time or something since power up
    #        (doesn't increment during continuous shooting and at some other times)
);

# PH (RX100)
%Image::ExifTool::Sony::Tag9403 = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    DATAMEMBER => [ 0x04 ],
    0x04 => {
        # seen values 0,2,3,18,32,49,50,83,148
        # CameraTemperature is value for all values except 0,148
        Name => 'TempTest2',
        DataMember => 'TempTest2',
        Hidden => 1,
        RawConv => '$$self{TempTest2}=$val; $$self{OPTIONS}{Unknown}<2 ? undef : $val',
    },
    0x05 => {
        Name => 'CameraTemperature', # (maybe SensorTemperature? - heats up when taking movies)
        Condition => '$$self{TempTest2} and $$self{TempTest2} < 100',
        Format => 'int8s', # signed int untested -- need colder temperatures
        PrintConv => '"$val C"',
        PrintConvInv => '$val=~s/ ?C//; $val',
    },
    # 0x0f - same as 0x05
    # 0x18 - maybe another temperature?
);

# Tag9406 (ref 12)
%Image::ExifTool::Sony::Tag9406 = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
#    0x0000: 1 for A37, A57, A65, A77, NEX-5N, 7, F3, VG20
#            2 for A99, NEX-5R, NEX-6
#    0x0001+0x0002: Int16u, seen 580 - 770: similar to "BatteryUnknown" ??
#    0x0005+0x0006: Int16u, seen  73 - 117: maybe Fahrenheit ? (but considerably higher than "AmbientTemperature")
#    0x0007: seen values from 8 - 105, decreasing in sequences of images: BatteryLevel
    0x0007 => {
        Name => 'BatteryLevel',
        PrintConv => '"$val%"',
        PrintConvInv => '$val=~s/\s*\%//; $val',
    },
#    0x0009-0x001a: looks like 9 Int16u values
#    0x0022: 0 or 1 for A99, NEX-5R, 6
#    0x0025: 0 or 1 for other SLT and NEX (0x0022, 0x0023, 0x0024 = 255)
);

# Tag940a (ref PH, decoded mainly from A77)
%Image::ExifTool::Sony::Tag940a = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => 'These tags are currently extracted for SLT models only.',
    # 0x00 - 10(A65,A77,NEX-5N,7,VG20E), 11(A37,A57,A99,NEX-5R,6,F3,RX1,RX100),
    #        9(HX9V), 4,68,86,110(panoramas) - ref 12
    0x04 => {
        Name => 'AFPointsSelected',
        Format => 'int32u',
        PrintConvColumns => 2,
        PrintConv => {
            # verified for A77 firmware 1.03 and 1.07 and A99 firmware 1.00,
            # but there were inconsistencies with my A77 firmware 1.04 samples - PH
            0 => '(none)',
            0x00007801 => 'Center Zone',
            0x0001821c => 'Right Zone',
            0x000605c0 => 'Left Zone',
            0x7fffffff => '(all)',
            # 0xffffffff - 'n/a' - RX1 and NEX models always give this
            # (on Wide AFAreaMode, outer focus points are dropped
            #  at progressively higher digital zoom ratios, ref 12)
            BITMASK => {
                0 => 'Center',          # (1.04 gave this for Upper-middle and Near Left)
                1 => 'Top',             # (1.04 didn't give this value)
                2 => 'Upper-right',     # (1.04 OK)
                3 => 'Right',           # (1.04 didn't give this value)
                4 => 'Lower-right',     # (1.04 gave this for Bottom)
                5 => 'Bottom',          # (1.04 gave this for Lower-middle)
                6 => 'Lower-left',      # (1.04 gave this for Left and Lower Far Left)
                7 => 'Left',            # (1.04 gave this for Far Left)
                8 => 'Upper-left',      # (1.04 OK)
                9 => 'Far Right',       # (1.04 gave this for Upper Far Right and Right)
                10 => 'Far Left',       # (1.04 didn't give this value)
                11 => 'Upper-middle',   # (1.04 gave this for Top)
                12 => 'Near Right',     # (1.04 gave this for Center)
                13 => 'Lower-middle',   # (1.04 gave this for Lower-left and Near Right)
                14 => 'Near Left',      # (1.04 didn't give this value)
                15 => 'Upper Far Right',# (1.04 didn't give this value)
                16 => 'Lower Far Right',# (1.04 OK, but gave this for Far Right and Lower-right too)
                17 => 'Lower Far Left', # (1.04 didn't give this value)
                18 => 'Upper Far Left', # (1.04 OK)
                # higher bits may be used in panorama images - ref 12
            },
        },
    },
    # 0x0a - int16u: 0,1,2,3
);

# Tag940e (SLT models only) (ref PH, decoded mainly from A77)
%Image::ExifTool::Sony::Tag940e = (
    PROCESS_PROC => \&ProcessEnciphered,
    WRITE_PROC => \&WriteEnciphered,
    CHECK_PROC => \&Image::ExifTool::CheckBinaryData,
    FORMAT => 'int8u',
    WRITABLE => 1,
    FIRST_ENTRY => 0,
    PRIORITY => 0,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Camera' },
    NOTES => 'These tags are currently extracted for SLT models only.',
    0x07 => [ # the active AF sensor
        {
            Name => 'AFPoint',
            Condition => '$$self{Model} =~ /^SLT-A(37|57|65)/',
            Notes => 'A37, A57 and A65',
            PrintConvColumns => 2,
            PrintConv => \%afPoint15,
        },{
            Name => 'AFPoint',
            Condition => '$$self{Model} =~ /^SLT-A(77|99)/',
            Notes => 'A77 and A99',
            PrintConvColumns => 2,
            PrintConv => \%afPoint19,
        },
    ],
    0x08 => [ # the AF sensor in focus at focus time (shutter release half press)
        {
            Name => 'AFPointInFocus',
            Condition => '$$self{Model} =~ /^SLT-A(37|57|65)/',
            Notes => 'A37, A57 and A65',
            PrintConvColumns => 2,
            PrintConv => {
                %afPoint15,
                255 => '(none)',
            },
        },{
            Name => 'AFPointInFocus',
            Condition => '$$self{Model} =~ /^SLT-A(77|99)/',
            Notes => 'A77 and A99',
            PrintConvColumns => 2,
            PrintConv => {
                %afPoint19,
                255 => '(none)',
            },
        },
    ],
    0x09 => [ # the AF sensor in focus at shutter release (shutter release full press)
        {
            Name => 'AFPointAtShutterRelease',
            Condition => '$$self{Model} =~ /^SLT-A(37|57|65)/',
            Notes => 'A37, A57 and A65',
            PrintConvColumns => 2,
            PrintConv => {
                %afPoint15,
                30 => '(out of focus)',
            },
        },{
            Name => 'AFPointAtShutterRelease',
            Condition => '$$self{Model} =~ /^SLT-A(77|99)/',
            Notes => 'A77 and A99',
            PrintConvColumns => 2,
            PrintConv => {
                %afPoint19,
                30 => '(out of focus)',
            },
        },
    ],
    0x0a => {
        Name => 'AFAreaMode',
        PrintConv => {
            0 => 'Wide',
            1 => 'Spot',
            2 => 'Local',
            3 => 'Zone',
        },
    },
    0x0b => [
        {
            Name => 'FocusMode',
            Condition => '$$self{Model} =~ /^SLT-A99/',
            Notes => 'A99',
            PrintConv => {
                0 => 'Manual',
                2 => 'AF-A',
                3 => 'AF-C',
                4 => 'AF-S',
                6 => 'DMF',
                7 => 'AF-D', # (unique to A99)
            },
        },
        {
            Name => 'FocusMode',
            Notes => 'other models', # (verified for A77 only)
            PrintConvColumns => 2,
            # validated for A77 firmware 1.03, 1.04 and 1.07
            # - not confirmed for A37,A57 and A65 which also write this tag
            PrintConv => {
                0 => 'Manual',
                2 => 'AF-S', # <-- different from A99!
                3 => 'AF-C',
                4 => 'AF-A', # <-- different from A99!
                6 => 'DMF',
            },
        },
    ],
    0x017d => { #PH (verified for the A77/A99; likely valid for other SLT models - ref 12)
        # (different from AFMicroAdjValue because it is 0 when the adjustment is off)
        Name => 'AFMicroAdj',
        Format => 'int8s',
    },
    0x017e => { #12
        Name => 'ExposureProgram',
        Priority => 0,
        PrintConv => {
            0 => 'Program AE',
            1 => 'Aperture-priority AE',
            2 => 'Shutter speed priority AE',
            3 => 'Manual',
            4 => 'Auto',                 # seen for NEX-VG900
            5 => 'iAuto',
            6 => 'Superior Auto',        # seen for DSC-WX60,WX300
            7 => 'iAuto+',
            8 => 'Portrait',
            9 => 'Landscape',            # seen for DSC-WX300
            12 => 'Sunset',
            17 => 'Handheld Night Shot', # seen for DSC-WX60
            29 => 'Macro',
            33 => 'Sweep Panorama',
            36 => 'Background Defocus',  # seen for DSC-WX60
            43 => 'Cont. Priority AE',
        },
    },
    # 0xf38,0x1208,0x14d8,0x158c,0x1640,(and more) - 0 if AFMicroAdj is On, 1 if Off
    # 0x1ab6 - 0x80 if AFMicroAdj is On, 0 if Off
    # tags also related to AFPoint (PH, A77):
    #   0x11ec, 0x122a, 0x1408, 0x1446, 0x14bc, 0x1f86,
    #   0x14fa, 0x1570, 0x1572, 0x15ae, 0x1f48
);

%Image::ExifTool::Sony::FaceInfo1 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    0x00 => {
        Name => 'Face1Position',
        Format => 'int16u[4]',
        Notes => q{
            top, left, height and width of detected face.  Coordinates are relative to
            the full-sized unrotated image, with increasing Y downwards
        },
        RawConv => '$$self{FacesDetected} < 1 ? undef : $val',
    },
    0x20 => {
        Name => 'Face2Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 2 ? undef : $val',
    },
    0x40 => {
        Name => 'Face3Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 3 ? undef : $val',
    },
    0x60 => {
        Name => 'Face4Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 4 ? undef : $val',
    },
    0x80 => {
        Name => 'Face5Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 5 ? undef : $val',
    },
    0xa0 => {
        Name => 'Face6Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 6 ? undef : $val',
    },
    0xc0 => {
        Name => 'Face7Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 7 ? undef : $val',
    },
    0xe0 => {
        Name => 'Face8Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 8 ? undef : $val',
    },
);

%Image::ExifTool::Sony::FaceInfo2 = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    0x00 => {
        Name => 'Face1Position',
        Format => 'int16u[4]',
        Notes => q{
            top, left, height and width of detected face.  Coordinates are relative to
            the full-sized unrotated image, with increasing Y downwards
        },
        RawConv => '$$self{FacesDetected} < 1 ? undef : $val',
    },
    0x25 => {
        Name => 'Face2Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 2 ? undef : $val',
    },
    0x4a => {
        Name => 'Face3Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 3 ? undef : $val',
    },
    0x6f => {
        Name => 'Face4Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 4 ? undef : $val',
    },
    0x94 => {
        Name => 'Face5Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 5 ? undef : $val',
    },
    0xb9 => {
        Name => 'Face6Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 6 ? undef : $val',
    },
    0xde => {
        Name => 'Face7Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 7 ? undef : $val',
    },
    0x103 => {
        Name => 'Face8Position',
        Format => 'int16u[4]',
        RawConv => '$$self{FacesDetected} < 8 ? undef : $val',
    },
);

# panorama info for cameras such as the HX1, HX5, TX7 (ref 9/PH)
%Image::ExifTool::Sony::Panorama = (
    %binaryDataAttrs,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    FORMAT => 'int32u',
    NOTES => q{
        Tags found only in panorama images from Sony cameras such as the HX1, HX5
        and TX7.  The width/height values of these tags are not affected by camera
        rotation -- the width is always the longer dimension.
    },
    # 0: 257
    1 => 'PanoramaFullWidth', # (including black/grey borders)
    2 => 'PanoramaFullHeight',
    3 => {
        Name => 'PanoramaDirection',
        PrintConv => {
            0 => 'Right to Left',
            1 => 'Left to Right',
        },
    },
    # crop area to remove black/grey borders from full image
    4 => 'PanoramaCropLeft',
    5 => 'PanoramaCropTop', #PH guess (NC)
    6 => 'PanoramaCropRight',
    7 => 'PanoramaCropBottom',
    # 8: 1728 (HX1), 1824 (HX5/TX7) (value8/value9 = 16/9)
    8 => 'PanoramaFrameWidth', #PH guess (NC)
    # 9: 972 (HX1), 1026 (HX5/TX7)
    9 => 'PanoramaFrameHeight', #PH guess (NC)
    # 10: 3200-3800 (HX1), 4000-4900 (HX5/TX7)
    10 => 'PanoramaSourceWidth', #PH guess (NC)
    # 11: 800-1800 (larger for taller panoramas)
    11 => 'PanoramaSourceHeight', #PH guess (NC)
    # 12-15: 0
);

# tag table for SRF0 IFD (ref 1)
%Image::ExifTool::Sony::SRF = (
    PROCESS_PROC => \&ProcessSRF,
    GROUPS => { 0 => 'MakerNotes', 1 => 'SRF#', 2 => 'Camera' },
    NOTES => q{
        The maker notes in SRF (Sony Raw Format) images contain 7 IFD's with family
        1 group names SRF0 through SRF6.  SRF0 and SRF1 use the tags in this table,
        while SRF2 through SRF5 use the tags in the next table, and SRF6 uses
        standard EXIF tags.  All information other than SRF0 is encrypted, but
        thanks to Dave Coffin the decryption algorithm is known.  SRF images are
        written by the Sony DSC-F828 and DSC-V3.
    },
    # tags 0-1 are used in SRF1
    0 => {
        Name => 'SRF2Key',
        Notes => 'key to decrypt maker notes from the start of SRF2',
        RawConv => '$self->{SRF2Key} = $val',
    },
    1 => {
        Name => 'DataKey',
        Notes => 'key to decrypt the rest of the file from the end of the maker notes',
        RawConv => '$self->{SRFDataKey} = $val',
    },
    # SRF0 contains a single unknown tag with TagID 0x0003
);

# tag table for Sony RAW Format (ref 1)
%Image::ExifTool::Sony::SRF2 = (
    PROCESS_PROC => \&ProcessSRF,
    GROUPS => { 0 => 'MakerNotes', 1 => 'SRF#', 2 => 'Camera' },
    NOTES => "These tags are found in the SRF2 through SRF5 IFD's.",
    # the following tags are used in SRF2-5
    2 => 'SRF6Offset', #PH
    # SRFDataOffset references 2220 bytes of unknown data for the DSC-F828 - PH
    3 => { Name => 'SRFDataOffset', Unknown => 1 }, #PH
    4 => { Name => 'RawDataOffset' }, #PH
    5 => { Name => 'RawDataLength' }, #PH
);

# tag table for Sony RAW 2 Format Private IFD (ref 1)
%Image::ExifTool::Sony::SR2Private = (
    PROCESS_PROC => \&ProcessSR2,
    WRITE_PROC => \&WriteSR2,
    GROUPS => { 0 => 'MakerNotes', 1 => 'SR2', 2 => 'Camera' },
    NOTES => q{
        The SR2 format uses the DNGPrivateData tag to reference a private IFD
        containing these tags.  SR2 images are written by the Sony DSC-R1, but
        this information is also written to ARW images by other models.
    },
    0x7200 => {
        Name => 'SR2SubIFDOffset',
        # (adjusting offset messes up calculations for AdobeSR2 in DNG images)
        # Flags => 'IsOffset',
        # (can't set OffsetPair or else DataMember won't be set when writing)
        # OffsetPair => 0x7201,
        DataMember => 'SR2SubIFDOffset',
        RawConv => '$$self{SR2SubIFDOffset} = $val',
    },
    0x7201 => {
        Name => 'SR2SubIFDLength',
        # (can't set OffsetPair or else DataMember won't be set when writing)
        # OffsetPair => 0x7200,
        DataMember => 'SR2SubIFDLength',
        RawConv => '$$self{SR2SubIFDLength} = $val',
    },
    0x7221 => {
        Name => 'SR2SubIFDKey',
        Format => 'int32u',
        Notes => 'key to decrypt SR2SubIFD',
        DataMember => 'SR2SubIFDKey',
        RawConv => '$$self{SR2SubIFDKey} = $val',
        PrintConv => 'sprintf("0x%.8x", $val)',
    },
    0x7240 => { #PH
        Name => 'IDC_IFD',
        Groups => { 1 => 'SonyIDC' },
        Condition => '$$valPt !~ /^\0\0\0\0/',   # (just in case this could be zero)
        Flags => 'SubIFD',
        SubDirectory => {
            DirName => 'SonyIDC',
            TagTable => 'Image::ExifTool::SonyIDC::Main',
            Start => '$val',
        },
    },
    0x7241 => { #PH
        Name => 'IDC2_IFD',
        Groups => { 1 => 'SonyIDC' },
        Condition => '$$valPt !~ /^\0\0\0\0/',   # may be zero if dir doesn't exist
        Flags => 'SubIFD',
        SubDirectory => {
            DirName => 'SonyIDC2',
            TagTable => 'Image::ExifTool::SonyIDC::Main',
            Start => '$val',
            Base => '$start',
            MaxSubdirs => 20,   # (A900 has 10 null entries, but IDC writes only 1)
            RelativeBase => 1,  # needed to write SubIFD with relative offsets
        },
    },
    0x7250 => { #1
        Name => 'MRWInfo',
        Condition => '$$valPt !~ /^\0\0\0\0/',   # (just in case this could be zero)
        SubDirectory => {
            TagTable => 'Image::ExifTool::MinoltaRaw::Main',
        },
    },
);

%Image::ExifTool::Sony::SR2SubIFD = (
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    GROUPS => { 0 => 'MakerNotes', 1 => 'SR2SubIFD', 2 => 'Camera' },
    SET_GROUP1 => 1, # set group1 name to directory name for all tags in table
    NOTES => 'Tags in the encrypted SR2SubIFD',
    0x7303 => 'WB_GRBGLevels', #1
    0x74c0 => { #PH
        Name => 'SR2DataIFD',
        Groups => { 1 => 'SR2DataIFD' }, # (needed to set SubIFD DirName)
        Flags => 'SubIFD',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Sony::SR2DataIFD',
            Start => '$val',
            MaxSubdirs => 20, # an A700 ARW has 14 of these! - PH
        },
    },
    0x7313 => 'WB_RGGBLevels', #6
    0x74a0 => 'MaxApertureAtMaxFocal', #PH
    0x74a1 => 'MaxApertureAtMinFocal', #PH
    0x7820 => 'WB_RGBLevelsDaylight', #6
    0x7821 => 'WB_RGBLevelsCloudy', #6
    0x7822 => 'WB_RGBLevelsTungsten', #6
    0x7825 => 'WB_RGBLevelsShade', #6
    0x7826 => 'WB_RGBLevelsFluorescent', #6
    0x7828 => 'WB_RGBLevelsFlash', #6
);

%Image::ExifTool::Sony::SR2DataIFD = (
    WRITE_PROC => \&Image::ExifTool::Exif::WriteExif,
    CHECK_PROC => \&Image::ExifTool::Exif::CheckExif,
    GROUPS => { 0 => 'MakerNotes', 1 => 'SR2DataIFD', 2 => 'Camera' },
    SET_GROUP1 => 1, # set group1 name to directory name for all tags in table
    # 0x7313 => 'WB_RGGBLevels', (duplicated in all SR2DataIFD's)
    0x7770 => { #PH
        Name => 'ColorMode',
        Priority => 0,
    },
);

# tags found in DSC-F1 PMP header (ref 10)
%Image::ExifTool::Sony::PMP = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
    FIRST_ENTRY => 0,
    NOTES => q{
        These tags are written in the proprietary-format header of PMP images from
        the DSC-F1.
    },
    8 => { #PH
        Name => 'JpgFromRawStart',
        Format => 'int32u',
        Notes => q{
            OK, not really a RAW file, but this mechanism is used to allow extraction of
            the JPEG image from a PMP file
        },
    },
    12 => { Name => 'JpgFromRawLength',Format => 'int32u' },
    22 => { Name => 'SonyImageWidth',  Format => 'int16u' },
    24 => { Name => 'SonyImageHeight', Format => 'int16u' },
    27 => {
        Name => 'Orientation',
        PrintConv => {
            0 => 'Horizontal (normal)',
            1 => 'Rotate 270 CW',#11
            2 => 'Rotate 180',
            3 => 'Rotate 90 CW',#11
        },
    },
    29 => {
        Name => 'ImageQuality',
        PrintConv => {
            8 => 'Snap Shot',
            23 => 'Standard',
            51 => 'Fine',
        },
    },
    # 40 => ImageWidth again (int16u)
    # 42 => ImageHeight again (int16u)
    52 => { Name => 'Comment',         Format => 'string[19]' },
    76 => {
        Name => 'DateTimeOriginal',
        Description => 'Date/Time Original',
        Format => 'int8u[6]',
        Groups => { 2 => 'Time' },
        ValueConv => q{
            my @a = split ' ', $val;
            $a[0] += $a[0] < 70 ? 2000 : 1900;
            sprintf('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', @a);
        },
        PrintConv => '$self->ConvertDateTime($val)',
    },
    84 => {
        Name => 'ModifyDate',
        Format => 'int8u[6]',
        Groups => { 2 => 'Time' },
        ValueConv => q{
            my @a = split ' ', $val;
            $a[0] += $a[0] < 70 ? 2000 : 1900;
            sprintf('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', @a);
        },
        PrintConv => '$self->ConvertDateTime($val)',
    },
    102 => {
        Name => 'ExposureTime',
        Format => 'int16s',
        RawConv => '$val <= 0 ? undef : $val',
        ValueConv => '2 ** (-$val / 100)',
        PrintConv => 'Image::ExifTool::Exif::PrintExposureTime($val)',
    },
    106 => { # (NC -- not written by DSC-F1)
        Name => 'FNumber',
        Format => 'int16s',
        RawConv => '$val <= 0 ? undef : $val',
        ValueConv => '$val / 100', # (likely wrong)
    },
    108 => { # (NC -- not written by DSC-F1)
        Name => 'ExposureCompensation',
        Format => 'int16s',
        RawConv => '($val == -1 or $val == -32768) ? undef : $val',
        ValueConv => '$val / 100', # (probably wrong too)
    },
    112 => { # (NC -- not written by DSC-F1)
        Name => 'FocalLength',
        Format => 'int16s',
        Groups => { 2 => 'Camera' },
        RawConv => '$val <= 0 ? undef : $val',
        ValueConv => '$val / 100',
        PrintConv => 'sprintf("%.1f mm",$val)',
    },
    118 => {
        Name => 'Flash',
        Groups => { 2 => 'Camera' },
        PrintConv => { 0 => 'No Flash', 1 => 'Fired' },
    },
);

# Composite Sony tags
%Image::ExifTool::Sony::Composite = (
    GROUPS => { 2 => 'Camera' },
    FocusDistance => {
        Require => {
            0 => 'Sony:FocusPosition',
            1 => 'FocalLength',
        },
        Notes => 'distance in metres = FocusPosition * FocalLength / 1000',
        ValueConv => '$val >= 128 ? "inf" : $val * $val[1] / 1000',
        PrintConv => '$val eq "inf" ? $val : "$val m"',
    },
);

# add our composite tags
Image::ExifTool::AddCompositeTags('Image::ExifTool::Sony');

# fill in Sony LensType lookup based on Minolta values
{
    my $minoltaTypes = \%Image::ExifTool::Minolta::minoltaLensTypes;
    %sonyLensTypes = %$minoltaTypes;
    delete $$minoltaTypes{Notes};   # (temporarily)
    my $id;
    # 5-digit lens ID's are missing the last digit (usually "1") in the metadata for
    # some Sony models, so generate corresponding 4-digit entries for these cameras
    foreach $id (sort { $a <=> $b } keys %$minoltaTypes) {
        next if $id < 10000;
        my $sid = int($id/10);
        my $i;
        my $lens = $$minoltaTypes{$id};
        if ($sonyLensTypes{$sid}) {
            # put lens name with "or" first in list
            if ($lens =~ / or /) {
                my $tmp = $sonyLensTypes{$sid};
                $sonyLensTypes{$sid} = $lens;
                $lens = $tmp;
            }
            for (;;) {
                $i = ($i || 0) + 1;
                $sid = int($id/10) . ".$i";
                last unless $sonyLensTypes{$sid};
            }
        }
        $sonyLensTypes{$sid} = $lens;
    }
    $$minoltaTypes{Notes} = $sonyLensTypes{Notes}; # (restore original Notes)
}

#------------------------------------------------------------------------------
# Make TIFF header for raw data
# Inputs: 0) width, 1) height, 2) num colour components, 3) bits, 4) resolution
# Returns: TIFF header
# Notes: Multi-byte data must be little-endian
sub MakeTiffHeader($$$$;$)
{
    my ($w, $h, $cols, $bits, $res) = @_;
    $res or $res = 72;
    my $saveOrder = GetByteOrder();
    SetByteOrder('II');
    my $hdr =
    "\x49\x49\x2a\0\x08\0\0\0\x0e\0" .          # 0x00 14 menu entries:
    "\xfe\x00\x04\0\x01\0\0\0\x00\0\0\0" .      # 0x0a SubfileType = 0
    "\x00\x01\x04\0\x01\0\0\0" . Set32u($w) .   # 0x16 ImageWidth
    "\x01\x01\x04\0\x01\0\0\0" . Set32u($h) .   # 0x22 ImageHeight
    "\x02\x01\x03\0" . Set32u($cols) .          # 0x2e BitsPerSample
    Set32u($cols == 1 ? $bits : 0xb6) .
    "\x03\x01\x03\0\x01\0\0\0\x01\0\0\0" .      # 0x3a Compression = 1
    "\x06\x01\x03\0\x01\0\0\0" .                # 0x46 PhotometricInterpretation
    Set32u($cols == 1 ? 1 : 2) .
    "\x11\x01\x04\0\x01\0\0\0\xcc\0\0\0" .      # 0x52 StripOffsets = 0xcc
    "\x15\x01\x03\0\x01\0\0\0" . Set32u($cols) .# 0x5e SamplesPerPixel
    "\x16\x01\x04\0\x01\0\0\0" . Set32u($h) .   # 0x6a RowsPerStrip
    "\x17\x01\x04\0\x01\0\0\0" .                # 0x76 StripByteCounts
    Set32u($w * $h * $cols * int(($bits+7)/8)) .
    "\x1a\x01\x05\0\x01\0\0\0\xbc\0\0\0" .      # 0x82 XResolution
    "\x1b\x01\x05\0\x01\0\0\0\xc4\0\0\0" .      # 0x8e YResolution
    "\x1c\x01\x03\0\x01\0\0\0\x01\0\0\0" .      # 0x9a PlanarConfiguration = 1
    "\x28\x01\x03\0\x01\0\0\0\x02\0\0\0" .      # 0xa6 ResolutionUnit = 2
    "\0\0\0\0" .                                # 0xb2 (no IFD1)
    (Set16u($bits) x 3) .                       # 0xb6 BitsPerSample value
    Set32u($res) . "\x01\0\0\0" .               # 0xbc XResolution = 72
    Set32u($res) . "\x01\0\0\0";                # 0xc4 YResolution = 72
    SetByteOrder($saveOrder);                   # 0xcc (data goes here)
    return $hdr;
}

#------------------------------------------------------------------------------
# LensSpec value conversions
# Inputs: 0) value
# Returns: converted value
# Notes: unpacks in format compatible with LensInfo, with extra flags bytes at start and end
sub ConvLensSpec($)
{
    my $val = shift;
    return \$val unless length($val) == 8;
    my @a = unpack("H2H4H4H2H2H2",$val);
    $a[1] += 0;  $a[2] += 0;    # remove leading zeros from focal lengths
    $a[3] /= 10; $a[4] /= 10;   # divide f-numbers by 10
    return join ' ', @a;
}
sub ConvInvLensSpec($)
{
    my $val = shift;
    my @a=split(" ", $val);
    return $val unless @a == 6;
    $a[3] *= 10; $a[4] *= 10;   # f-numbers are multiplied by 10
    $_ = hex foreach @a;        # convert from hex
    return pack 'CnnCCC', @a;
}

#------------------------------------------------------------------------------
# Print Sony LensSpec value
# Inputs: 0) LensSpec numerical value
# Returns: converted LensSpec string (ie. "DT 18-55mm F3.5-5.6 SAM")
# Refs: http://equational.org/importphotos/alphalensinfo.html
#       http://www.dyxum.com/dforum/the-lens-information-different-from-lensid_topic37682.html
my @lensFeatures = (
    # lens features in the order they are added to the LensSpec string
    # (high byte of Mask/Bits represents byte 0 of LensSpec, low byte is byte 7)
    #  Mask   {  Bits     Name    Bits     Name  } Prefix flag
    # ------    ------    -----  ------    -----   -----------
    [ 0x4000, { 0x4000 => 'PZ'                   }, 1 ],
    [ 0x0300, { 0x0100 => 'DT',  0x0300 => 'E'   }, 1 ], # (will come before preceding prefix)
    [ 0x000c, { 0x0004 => 'ZA',  0x0008 => 'G'   } ],
    [ 0x00e0, { 0x0020 => 'STF', 0x0040 => 'Reflex', 0x0060 => 'Macro', 0x0080 => 'Fisheye' } ],
    [ 0x0003, { 0x0001 => 'SSM', 0x0002 => 'SAM' } ],
    [ 0x8000, { 0x8000 => 'OSS' } ],
    [ 0x2000, { 0x2000 => 'LE' } ], #12
    [ 0x0800, { 0x0800 => 'II' } ], #12
);
sub PrintLensSpec($)
{
    my $val = shift;
    # 0=flags1, 1=short focal, 2=long focal, 3=max aperture at short focal,
    # 4=max aperture at long focal, 5=flags2
    my ($f1, $sf, $lf, $sa, $la, $f2) = split ' ', $val;
    my ($rtnVal, $feature);
    # crude validation of focal length and aperture values
    if ($sf != 0 and $sa != 0 and ($lf == 0 or $lf >= $sf) and ($la == 0 or $la >= $sa)) {
        # use focal and aperture range if this is a zoom lens
        $sf .= '-' . $lf if $lf != $sf and $lf != 0;
        $sa .= '-' . $la if $sa != $la and $la != 0;
        $rtnVal = "${sf}mm F$sa";     # heart of LensSpec is a LensInfo string
        # loop through available lens features
        my $flags = hex($f1 . $f2);
        foreach $feature (@lensFeatures) {
            my $bits = $$feature[0] & $flags;
            next unless $bits or $$feature[1]{$bits};
            # add feature name as a prefix or suffix to the LensSpec
            my $str = $$feature[1]{$bits} || sprintf('Unknown(%.4x)',$bits);
            $rtnVal = $$feature[2] ? "$str $rtnVal" : "$rtnVal $str";
        }
    } else {
        $rtnVal = "Unknown ($val)";
    }
    return $rtnVal;
}
# inverse conversion
sub PrintInvLensSpec($)
{
    my $val = shift;
    return $1 if $val =~ /Unknown \((.*)\)/i;
    my ($sf, $lf, $sa, $la) = Image::ExifTool::Exif::GetLensInfo($val);
    $sf or return undef;
    # fixed focal length and aperture have zero for 2nd number
    $lf = 0 if $lf == $sf;
    $la = 0 if $la == $sa;
    my $flags = 0;
    my ($feature, $bits);
    foreach $feature (@lensFeatures) {
        foreach $bits (keys %{$$feature[1]}) {
            # set corresponding flag bits for each feature name found
            my $name = $$feature[1]{$bits};
            $val =~ /\b$name\b/i and $flags |= $bits;
        }
    }
    return sprintf "%.2x $sf $lf $sa $la %.2x", $flags>>8, $flags&0xff;
}

#------------------------------------------------------------------------------
# Read/Write MoreInfo information (tag 0x0020, count 20480)
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success when reading, or new directory when writing (IsWriting set)
sub ProcessMoreInfo($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    $exifTool or return 1;    # allow dummy access to write routine
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen} || length($$dataPt);
    my $isWriting = $$dirInfo{IsWriting};
    my $rtnVal = $isWriting ? undef : 0;
    return $rtnVal if $dirLen < 4;

    my $num = Get16u($dataPt, $start);      # number of entries
    my $len = Get16u($dataPt, $start + 2);  # total data length

    if ($dirLen < 4 + $num * 4) {
        $exifTool->Warn('Truncated MoreInfo data', 1);
        return $rtnVal;
    }
    if ($num > 50) {
        $exifTool->Warn('Possibly corrupted MoreInfo data', 1);
        return $rtnVal;
    }

    $exifTool->VerboseDir('MoreInfo', $num, $len) unless $isWriting;

    if ($len > $dirLen) {
        $exifTool->Warn('MoreInfo data length too large', 1);
        $len = $dirLen;
    }
    # loop through the MoreInfo index section to get the block offsets and tag ID's
    # (in case they are out of order, even though this may never happen)
    my ($i, @offset, @tagID, %blockSize);
    for ($i=0; $i<$num; ++$i) {
        my $entry = $start + 4 + $i * 4;
        push @tagID, Get16u($dataPt, $entry);
        push @offset, Get16u($dataPt, $entry + 2);
        if ($offset[-1] > $len and $offset[-1] <= $dirLen) {
            $exifTool->Warn('MoreInfo data length too small', 1);
            $len = $dirLen;
        }
    }
    # generate a lookup table of block sizes
    my @sorted = sort { $a <=> $b } @offset;
    push @sorted, 0xffff;   # (simplifies logic in loop below)
    for ($i=0; $i<$num; ++$i) {
        my $offset = $sorted[$i];
        my $size = $sorted[$i+1] - $offset;
        # note that block size will be negative for blocks with starting
        # offsets greater than $dirLen, but we will ignore these below
        $size = $len - $offset if $size > $len - $offset;
        # (if blockSize is already defined for this offset, then there
        #  are 2 blocks with the same starting offset and the existing
        #  size must be zero.  Since we can't know which block is
        #  actually non-zero size, the reasonable thing to do is
        #  assume that both have a size of zero)
        $blockSize{$offset} = $size unless defined $blockSize{$offset};
    }
    # initialize successful return value
    $rtnVal = $isWriting ? substr($$dataPt, $start, $dirLen) : 1;
    # now process each block
    my $unknown = $exifTool->{OPTIONS}{Unknown};
    for ($i=0; $i<$num; ++$i) {
        next if $offset[$i] > $dirLen;  # ignore bad offsets
        my $tag = $tagID[$i];
        if ($isWriting) {
            # write new tags
            my $tagInfo = $$tagTablePtr{$tag};
            next unless ref $tagInfo eq 'HASH' and $$tagInfo{SubDirectory};
            my $offset = $offset[$i];
            my $size = $blockSize{$offset};
            next unless $size;  # ignore zero-length blocks
            my %dirInfo = (
                DirName  => $$tagInfo{Name},
                Parent   => $$dirInfo{DirName},
                DataPt   => \$rtnVal,
                DirStart => $offset,
                DirLen   => $size,
            );
            my $subTable = GetTagTable($$tagInfo{SubDirectory}{TagTable});
            my $val = $exifTool->WriteDirectory(\%dirInfo, $subTable);
            # update this block in the returned MoreInfo data
            substr($rtnVal, $offset, $size) = $val if defined $val;
            next;
        }
        # generate binary tables for unknown tags if -U option used
        if (not defined $$tagTablePtr{$tag} and $unknown > 1) {
            my $name = sprintf('MoreInfo%.4x', $tag);
            my $table = "Image::ExifTool::Sony::$name";
            no strict 'refs';
            %$table = (
                PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
                FIRST_ENTRY => 0,
                GROUPS => { 0 => 'MakerNotes', 2 => 'Image' },
            );
            use strict 'refs';
            my %tagInfo = (
                Name => $name,
                SubDirectory => { TagTable => $table },
            );
            AddTagToTable($tagTablePtr, $tag, \%tagInfo);
        }
        $exifTool->HandleTag($tagTablePtr, $tag, undef,
            Index   => $i,
            DataPt  => $dataPt,
            DataPos => $$dirInfo{DataPos},
            Start   => $start + $offset[$i],
            Size    => $blockSize{$offset[$i]},
        );
    }
    return $rtnVal;
}

#------------------------------------------------------------------------------
# Read Sony DSC-F1 PMP file
# Inputs: 0) ExifTool object ref, 1) dirInfo ref
# Returns: 1 on success when reading, 0 if this isn't a valid PMP file
sub ProcessPMP($$)
{
    my ($exifTool, $dirInfo) = @_;
    my $raf = $$dirInfo{RAF};
    my $buff;
    $raf->Read($buff, 128) == 128 or return 0;
    # validate header length (124 bytes)
    $buff =~ /^.{8}\0{3}\x7c.{112}\xff\xd8\xff\xdb$/s or return 0;
    $exifTool->SetFileType();
    SetByteOrder('MM');
    $exifTool->FoundTag(Make => 'Sony');
    $exifTool->FoundTag(Model => 'DSC-F1');
    # extract information from 124-byte header
    my $tagTablePtr = GetTagTable('Image::ExifTool::Sony::PMP');
    my %dirInfo = ( DataPt => \$buff, DirName => 'PMP' );
    $exifTool->ProcessDirectory(\%dirInfo, $tagTablePtr);
    # process JPEG image
    $raf->Seek(124, 0);
    $$dirInfo{Base} = 124;
    $exifTool->ProcessJPEG($dirInfo);
    return 1;
}

#------------------------------------------------------------------------------
# Set the ARW file type and decide between SubIFD and A100DataOffset
# Inputs: 0) ExifTool object ref, 1) reference to tag 0x14a raw data
# Returns: true if tag 0x14a is a SubIFD, false otherwise
sub SetARW($$)
{
    my ($exifTool, $valPt) = @_;

    # assume ARW for now -- SR2's get identified when FileFormat is parsed
    $exifTool->OverrideFileType($$exifTool{TIFF_TYPE} = 'ARW');

    # this should always be a SubIFD for models other than the A100
    return 1 unless $$exifTool{Model} eq 'DSLR-A100' and length $$valPt == 4;

    # for the A100, IFD0 tag 0x14a is either a pointer to the raw data if this is
    # an original image, or a SubIFD offset if the image was edited by Sony IDC,
    # so assume it points to the raw data if it isn't a valid IFD (this assumption
    # will be checked later when we try to parse the SR2Private directory)
    my %subdir = (
        DirStart => Get32u($valPt, 0),
        Base     => 0,
        RAF      => $$exifTool{RAF},
        AllowOutOfOrderTags => 1, # doh!
    );
    return Image::ExifTool::Exif::ValidateIFD(\%subdir);
}

#------------------------------------------------------------------------------
# Finish writing ARW image, patching necessary Sony quirks, etc
# Inputs: 0) ExifTool ref, 1) dirInfo ref, 2) EXIF data ref, 3) image data reference
# Returns: undef on success, error string otherwise
# Notes: (it turns that all of this is for the A100 only)
sub FinishARW($$$$)
{
    my ($exifTool, $dirInfo, $dataPt, $imageData) = @_;

    # pre-scan IFD0 to get IFD entry offsets for each tag
    my $dataLen = length $$dataPt;
    return 'Truncated IFD0' if $dataLen < 2;
    my $n = Get16u($dataPt, 0);
    return 'Truncated IFD0' if $dataLen < 2 + 12 * $n;
    my ($i, %entry, $dataBlock, $pad, $dataOffset);
    for ($i=0; $i<$n; ++$i) {
        my $entry = 2 + $i * 12;
        $entry{Get16u($dataPt, $entry)} = $entry;
    }
    # fix up SR2Private offset and A100DataOffset (A100 only)
    if ($entry{0xc634} and $$exifTool{MRWDirData}) {
        return 'Unexpected MRW block' unless $$exifTool{Model} eq 'DSLR-A100';
        return 'Missing A100DataOffset' unless $entry{0x14a} and $$exifTool{A100DataOffset};
        # account for total length of image data
        my $totalLen = 8 + $dataLen;
        if (ref $imageData) {
            foreach $dataBlock (@$imageData) {
                my ($pos, $size, $pad) = @$dataBlock;
                $totalLen += $size + $pad;
            }
        }
        # align MRW block on an even 4-byte boundary
        my $remain = $totalLen & 0x03;
        $pad = 4 - $remain and $totalLen += $pad if $remain;
        # set offset for the MRW directory data
        Set32u($totalLen, $dataPt, $entry{0xc634} + 8);
        # also pad MRWDirData data to an even 4 bytes (just to be safe)
        $remain = length($$exifTool{MRWDirData}) & 0x03;
        $$exifTool{MRWDirData} .= "\0" x (4 - $remain) if $remain;
        $totalLen += length $$exifTool{MRWDirData};
        # fix up A100DataOffset
        $dataOffset = $$exifTool{A100DataOffset};
        Set32u($totalLen, $dataPt, $entry{0x14a} + 8);
    }
    # patch double-referenced and incorrectly-sized A100 PreviewImage
    if ($entry{0x201} and $$exifTool{A100PreviewStart} and
        $entry{0x202} and $$exifTool{A100PreviewLength})
    {
        Set32u($$exifTool{A100PreviewStart}, $dataPt, $entry{0x201} + 8);
        Set32u($$exifTool{A100PreviewLength}, $dataPt, $entry{0x202} + 8);
    }
    # write TIFF IFD structure
    my $outfile = $$dirInfo{OutFile};
    my $header = GetByteOrder() . Set16u(0x2a) . Set32u(8);
    Write($outfile, $header, $$dataPt) or return 'Error writing';
    # copy over image data
    if (ref $imageData) {
        $exifTool->CopyImageData($imageData, $outfile) or return 'Error copying image data';
    }
    # write MRW data if necessary
    if ($$exifTool{MRWDirData}) {
        Write($outfile, "\0" x $pad) if $pad;   # write padding if necessary
        Write($outfile, $$exifTool{MRWDirData});
        delete $$exifTool{MRWDirData};
        # set TIFF_END to copy over the MRW image data
        $$exifTool{TIFF_END} = $dataOffset if $dataOffset;
    }
    return undef;
}

#------------------------------------------------------------------------------
# Decrypt/Encrypt Sony data (ref 1) (reversible encryption)
# Inputs: 0) data reference, 1) start offset, 2) data length, 3) decryption key
# Returns: nothing (original data buffer is updated with decrypted data)
# Notes: data length should be a multiple of 4
sub Decrypt($$$$)
{
    my ($dataPt, $start, $len, $key) = @_;
    my ($i, $j, @pad);
    my $words = int ($len / 4);

    for ($i=0; $i<4; ++$i) {
        my $lo = ($key & 0xffff) * 0x0edd + 1;
        my $hi = ($key >> 16) * 0x0edd + ($key & 0xffff) * 0x02e9 + ($lo >> 16);
        $pad[$i] = $key = (($hi & 0xffff) << 16) + ($lo & 0xffff);
    }
    $pad[3] = ($pad[3] << 1 | ($pad[0]^$pad[2]) >> 31) & 0xffffffff;
    for ($i=4; $i<0x7f; ++$i) {
        $pad[$i] = (($pad[$i-4]^$pad[$i-2]) << 1 |
                    ($pad[$i-3]^$pad[$i-1]) >> 31) & 0xffffffff;
    }
    my @data = unpack("x$start N$words", $$dataPt);
    for ($i=0x7f,$j=0; $j<$words; ++$i,++$j) {
        $data[$j] ^= $pad[$i & 0x7f] = $pad[($i+1) & 0x7f] ^ $pad[($i+65) & 0x7f];
    }
    substr($$dataPt, $start, $words*4) = pack('N*', @data);
}

#------------------------------------------------------------------------------
# Decipher/encipher Sony tag 0x94xx data (ref PH)
# Inputs: 0) data reference, 1) true to encipher the data
sub Decipher($;$)
{
    my ($dataPt, $encipher) = @_;
    # This is a simple substitution cipher, so use a hardcoded translation table for speed.
    # The formula is: $c = ($b*$b*$b) % 249, where $c is the enciphered data byte
    # (note that bytes with values 249-255 are not translated, and 0-1, 82-84,
    #  165-167 and 248 have the same enciphered value)
    if ($encipher) {    # encipher
        $$dataPt =~ tr/\x02-\xf7/\x08\x1b\x40\x7d\xd8\x5e\x0e\xe7\x04V\xea\xcd\x05\x8ap\xb6i\x88\x200\xbe\xd7\x81\xbb\x92\x0c\x28\xecl\xa0\x95Q\xd3\x2f\x5dj\x5c9\x07\xc5\x87L\x1a\xf0\xe2\xef\x24y\x02\xb7\xac\xe0\x60\x2bG\xba\x91\xcbu\x8e\x233\xc4\xe3\x96\xdc\xc2N\x7fb\xf6OeE\xeet\xcf\x138KRST\x5bn\x93\xd02\xb1aAW\xa9D\x27X\xdd\xc3\x10\xbc\xdbs\x83\x181\xd4\x15\xe5_\x7bF\xbf\xf3\xe8\xa4\x2d\x82\xb0\xbd\xaf\x8cZ\x1f\xda\x9fmJ\x3cIw\xccU\x11\x06\x3a\xb3\x7e\x9a\x14\xe4\x25\xc8\xe1v\x86\x1e\x3d\xe96\x1c\xa1\xd2\xb5P\xa2\xb8\x98H\xc7\x29f\x8b\x9e\xa5\xa6\xa7\xae\xc1\xe6\x2a\x85\x0b\xb4\x94\xaa\x03\x97z\xab7\x1dc\x165\xc6\xd6k\x84\x2eh\x3f\xb2\xce\x99\x19MB\xf7\x80\xd5\x0a\x17\x09\xdf\xadr4\xf2\xc0\x9d\x8f\x9c\xca\x26\xa8dY\x8d\x0d\xd1\xedg\x3ex\x22\x3b\xc9\xd9q\x90C\x89o\xf4\x2c\x0f\xa3\xf5\x12\xeb\x9b\x21\x7c\xb9\xde\xf1/;
    } else {            # decipher
        $$dataPt =~ tr/\x08\x1b\x40\x7d\xd8\x5e\x0e\xe7\x04V\xea\xcd\x05\x8ap\xb6i\x88\x200\xbe\xd7\x81\xbb\x92\x0c\x28\xecl\xa0\x95Q\xd3\x2f\x5dj\x5c9\x07\xc5\x87L\x1a\xf0\xe2\xef\x24y\x02\xb7\xac\xe0\x60\x2bG\xba\x91\xcbu\x8e\x233\xc4\xe3\x96\xdc\xc2N\x7fb\xf6OeE\xeet\xcf\x138KRST\x5bn\x93\xd02\xb1aAW\xa9D\x27X\xdd\xc3\x10\xbc\xdbs\x83\x181\xd4\x15\xe5_\x7bF\xbf\xf3\xe8\xa4\x2d\x82\xb0\xbd\xaf\x8cZ\x1f\xda\x9fmJ\x3cIw\xccU\x11\x06\x3a\xb3\x7e\x9a\x14\xe4\x25\xc8\xe1v\x86\x1e\x3d\xe96\x1c\xa1\xd2\xb5P\xa2\xb8\x98H\xc7\x29f\x8b\x9e\xa5\xa6\xa7\xae\xc1\xe6\x2a\x85\x0b\xb4\x94\xaa\x03\x97z\xab7\x1dc\x165\xc6\xd6k\x84\x2eh\x3f\xb2\xce\x99\x19MB\xf7\x80\xd5\x0a\x17\x09\xdf\xadr4\xf2\xc0\x9d\x8f\x9c\xca\x26\xa8dY\x8d\x0d\xd1\xedg\x3ex\x22\x3b\xc9\xd9q\x90C\x89o\xf4\x2c\x0f\xa3\xf5\x12\xeb\x9b\x21\x7c\xb9\xde\xf1/\x02-\xf7/;
    }
}

#------------------------------------------------------------------------------
# Process Sony 0x94xx cipherdata directory
# Inputs: 0) ExifTool object ref, 1) directory information ref, 2) tag table ref
# Returns: 1 on success
# Notes:
# 1) dirInfo may contain VarFormatData (reference to empty list) to return
#    details about any variable-length-format tags in the table (used when writing)
# 2) A bug in ExifTool 9.04-9.10 could have double-enciphered these blocks
sub ProcessEnciphered($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirStart = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen} || (length($$dataPt) - $dirStart);
    my $data = substr($$dataPt, $dirStart, $dirLen);
    my %dirInfo = (
        %$dirInfo,
        DataPt => \$data,
        DataPos => $$dirInfo{DataPos} + $dirStart,
        DirStart => 0,
    );
    Decipher(\$data);
    if ($$exifTool{DoubleCipher}) {
        Decipher(\$data);
        $exifTool->WarnOnce('Some Sony metadata is double-enciphered. Write any tag to fix',1);
    }
    if ($exifTool->Options('Verbose') > 2) {
        my $tagInfo = $$dirInfo{TagInfo} || { Name => 'data' };
        my $str = $$exifTool{DoubleCipher} ? 'ouble-d' : '';
        $exifTool->VerboseDir("D${str}eciphered $$tagInfo{Name}");
        $exifTool->VerboseDump(\$data,
            Prefix  => $exifTool->{INDENT} . '  ',
            DataPos => $$dirInfo{DirStart} + $$dirInfo{DataPos} + ($$dirInfo{Base} || 0),
        );
    }
    return $exifTool->ProcessBinaryData(\%dirInfo, $tagTablePtr);
}

#------------------------------------------------------------------------------
# Write Sony 0x94xx cipherdata directory
# Inputs: 0) ExifTool object ref, 1) source dirInfo ref, 2) tag table ref
# Returns: cipherdata block or undefined on error
sub WriteEnciphered($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    $exifTool or return 1;
    my $dataPt = $$dirInfo{DataPt};
    my $dirStart = $$dirInfo{DirStart} || 0;
    my $dirLen = $$dirInfo{DirLen} || (length($$dataPt) - $dirStart);
    my $data = substr($$dataPt, $dirStart, $dirLen);
    my $changed = $$exifTool{CHANGED};
    Decipher(\$data);
    # fix double-enciphered data (due to bug in ExifTool 9.04-9.10)
    if ($$exifTool{DoubleCipher}) {
        Decipher(\$data);
        ++$$exifTool{CHANGED};
        $exifTool->WarnOnce('Fixed double-enciphered Sony metadata',1);
    }
    my %dirInfo = (
        %$dirInfo,
        DataPt => \$data,
        DataPos => $$dirInfo{DataPos} + $dirStart,
        DirStart => 0,
    );
    $data = $exifTool->WriteBinaryData(\%dirInfo, $tagTablePtr);
    if ($changed == $$exifTool{CHANGED}) {
        # nothing changed, so recover original data
        $data = substr($$dataPt, $dirStart, $dirLen);
    } elsif (defined $data) {
        Decipher(\$data,1);     # re-encipher
    }
    return $data;
}

#------------------------------------------------------------------------------
# Process SRF maker notes
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessSRF($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart};
    my $verbose = $exifTool->Options('Verbose');

    # process IFD chain
    my ($ifd, $success);
    for ($ifd=0; ; ) {
        # switch tag table for SRF2-5 and SRF6
        if ($ifd == 2) {
            $tagTablePtr = GetTagTable('Image::ExifTool::Sony::SRF2');
        } elsif ($ifd == 6) {
            # SRF6 uses standard EXIF tags
            $tagTablePtr = GetTagTable('Image::ExifTool::Exif::Main');
        }
        my $srf = $$dirInfo{DirName} = "SRF$ifd";
        $exifTool->{SET_GROUP1} = $srf;
        $success = Image::ExifTool::Exif::ProcessExif($exifTool, $dirInfo, $tagTablePtr);
        delete $exifTool->{SET_GROUP1};
        last unless $success;
#
# get pointer to next IFD
#
        my $count = Get16u($dataPt, $$dirInfo{DirStart});
        my $dirEnd = $$dirInfo{DirStart} + 2 + $count * 12;
        last if $dirEnd + 4 > length($$dataPt);
        my $nextIFD = Get32u($dataPt, $dirEnd);
        last unless $nextIFD;
        $nextIFD -= $$dirInfo{DataPos}; # adjust for position of makernotes data
        $$dirInfo{DirStart} = $nextIFD;
#
# decrypt next IFD data if necessary
#
        ++$ifd;
        my ($key, $len);
        if ($ifd == 1) {
            # get the key to decrypt IFD1
            my $cp = $start + 0x8ddc;    # why?
            my $ip = $cp + 4 * unpack("x$cp C", $$dataPt);
            $key = unpack("x$ip N", $$dataPt);
            $len = $cp + $nextIFD;  # decrypt up to $cp
        } elsif ($ifd == 2) {
            # get the key to decrypt IFD2
            $key = $exifTool->{SRF2Key};
            $len = length($$dataPt) - $nextIFD; # decrypt rest of maker notes
        } else {
            next;   # no decryption needed
        }
        # decrypt data
        Decrypt($dataPt, $nextIFD, $len, $key) if defined $key;
        next unless $verbose > 2;
        # display decrypted data in verbose mode
        $exifTool->VerboseDir("Decrypted SRF$ifd", 0, $nextIFD + $len);
        $exifTool->VerboseDump($dataPt,
            Prefix => "$exifTool->{INDENT}  ",
            Start => $nextIFD,
            DataPos => $$dirInfo{DataPos},
        );
    }
}

#------------------------------------------------------------------------------
# Write SR2 data
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success when reading, or SR2 directory or undef when writing
sub WriteSR2($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    $exifTool or return 1;      # allow dummy access
    my $buff = '';
    $$dirInfo{OutFile} = \$buff;
    return ProcessSR2($exifTool, $dirInfo, $tagTablePtr);
}

#------------------------------------------------------------------------------
# Read/Write SR2 IFD and its encrypted subdirectories
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success when reading, or SR2 directory or undef when writing
sub ProcessSR2($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $raf = $$dirInfo{RAF};
    my $dataPt = $$dirInfo{DataPt};
    my $dataPos = $$dirInfo{DataPos};
    my $dataLen = $$dirInfo{DataLen} || length $$dataPt;
    my $base = $$dirInfo{Base} || 0;
    my $outfile = $$dirInfo{OutFile};

    # clear SR2 member variables to be safe
    delete $$exifTool{SR2SubIFDOffset};
    delete $$exifTool{SR2SubIFDLength};
    delete $$exifTool{SR2SubIFDKey};

    # make sure we have the first 4 bytes available to test directory type
    my $buff;
    if ($dataLen < 4 and $raf) {
        my $pos = $dataPos + ($$dirInfo{DirStart}||0) + $base;
        if ($raf->Seek($pos, 0) and $raf->Read($buff, 4) == 4) {
            $dataPt = \$buff;
            undef $$dirInfo{DataPt};    # must load data from file
            $raf->Seek($pos, 0);
        }
    }
    # this may either be a normal IFD, or a MRW data block
    # (only original ARW images from the A100 use the MRW block)
    my $dataOffset;
    if ($dataPt and $$dataPt =~ /^\0MR[IM]/) {
        my ($err, $srfPos, $srfLen, $dataOffset);
        $dataOffset = $$exifTool{A100DataOffset};
        if ($dataOffset) {
            # save information about the RAW data trailer so it will be preserved
            $$exifTool{KnownTrailer} = { Name => 'A100 RAW Data', Start => $dataOffset };
        } else {
            $err = 'A100DataOffset tag is missing from A100 ARW image';
        }
        $raf or $err = 'Unrecognized SR2 structure';
        unless ($err) {
            $srfPos = $raf->Tell();
            $srfLen = $dataOffset - $srfPos;
            unless ($srfLen > 0 and $raf->Read($buff, $srfLen) == $srfLen) {
                $err = 'Error reading MRW directory';
            }
        }
        if ($err) {
            $outfile and $exifTool->Error($err), return undef;
            $exifTool->Warn($err);
            return 0;
        }
        my %dirInfo = ( DataPt => \$buff );
        require Image::ExifTool::MinoltaRaw;
        if ($outfile) {
            # save MRW data to be written last
            $$exifTool{MRWDirData} = Image::ExifTool::MinoltaRaw::WriteMRW($exifTool, \%dirInfo);
            return $$exifTool{MRWDirData} ? "\0\0\0\0\0\0" : undef;
        } else {
            if (not $outfile and $$exifTool{HTML_DUMP}) {
                $exifTool->HDump($srfPos, $srfLen, '[A100 SRF Data]');
            }
            return Image::ExifTool::MinoltaRaw::ProcessMRW($exifTool, \%dirInfo);
        }
    } elsif ($$exifTool{A100DataOffset}) {
        my $err = 'Unexpected A100DataOffset tag';
        $outfile and $exifTool->Error($err), return undef;
        $exifTool->Warn($err);
        return 0;
    }
    my $verbose = $exifTool->Options('Verbose');
    my $result;
    if ($outfile) {
        $result = Image::ExifTool::Exif::WriteExif($exifTool, $dirInfo, $tagTablePtr);
        return undef unless $result;
        $$outfile .= $result;

    } else {
        $result = Image::ExifTool::Exif::ProcessExif($exifTool, $dirInfo, $tagTablePtr);
    }
    return $result unless $result and $$exifTool{SR2SubIFDOffset};
    # only take first offset value if more than one!
    my @offsets = split ' ', $exifTool->{SR2SubIFDOffset};
    my $offset = shift @offsets;
    my $length = $exifTool->{SR2SubIFDLength};
    my $key = $exifTool->{SR2SubIFDKey};
    my @subifdPos;
    if ($offset and $length and defined $key) {
        my $buff;
        # read encrypted SR2SubIFD from file
        if (($raf and $raf->Seek($offset+$base, 0) and
                $raf->Read($buff, $length) == $length) or
            # or read from data (when processing Adobe DNGPrivateData)
            ($offset - $dataPos >= 0 and $offset - $dataPos + $length < $dataLen and
                ($buff = substr($$dataPt, $offset - $dataPos, $length))))
        {
            Decrypt(\$buff, 0, $length, $key);
            # display decrypted data in verbose mode
            if ($verbose > 2 and not $outfile) {
                $exifTool->VerboseDir("Decrypted SR2SubIFD", 0, $length);
                $exifTool->VerboseDump(\$buff, Addr => $offset + $base);
            }
            my $num = '';
            my $dPos = $offset;
            for (;;) {
                my %dirInfo = (
                    Base => $base,
                    DataPt => \$buff,
                    DataLen => length $buff,
                    DirStart => $offset - $dPos,
                    DirName => "SR2SubIFD$num",
                    DataPos => $dPos,
                );
                my $subTable = GetTagTable('Image::ExifTool::Sony::SR2SubIFD');
                if ($outfile) {
                    my $fixup = new Image::ExifTool::Fixup;
                    $dirInfo{Fixup} = $fixup;
                    $result = $exifTool->WriteDirectory(\%dirInfo, $subTable);
                    return undef unless $result;
                    # save position of this SubIFD
                    push @subifdPos, length($$outfile);
                    # add this directory to the returned data
                    $$fixup{Start} += length($$outfile);
                    $$outfile .= $result;
                    $dirInfo->{Fixup}->AddFixup($fixup);
                } else {
                    $result = $exifTool->ProcessDirectory(\%dirInfo, $subTable);
                }
                last unless @offsets;
                $offset = shift @offsets;
                $num = ($num || 1) + 1;
            }

        } else {
            $exifTool->Warn('Error reading SR2 data');
        }
    }
    if ($outfile and @subifdPos) {
        # the SR2SubIFD must be padded to a multiple of 4 bytes for the encryption
        my $sr2Len = length($$outfile) - $subifdPos[0];
        if ($sr2Len & 0x03) {
            my $pad = 4 - ($sr2Len & 0x03);
            $sr2Len += $pad;
            $$outfile .= ' ' x $pad;
        }
        # save the new SR2SubIFD Length and Key to be used later for encryption
        $$exifTool{SR2SubIFDLength} = $sr2Len;
        my $newKey = $$exifTool{VALUE}{SR2SubIFDKey};
        $$exifTool{SR2SubIFDKey} = $newKey if defined $newKey;
        # update SubIFD pointers manually and add to fixup, and set SR2SubIFDLength
        my $n = Get16u($outfile, 0);
        my ($i, %found);
        for ($i=0; $i<$n; ++$i) {
            my $entry = 2 + 12 * $i;
            my $tagID = Get16u($outfile, $entry);
            # only interested in SR2SubIFDOffset (0x7200) and SR2SubIFDLength (0x7201)
            next unless $tagID == 0x7200 or $tagID == 0x7201;
            $found{$tagID} = 1;
            my $fmt = Get16u($outfile, $entry + 2);
            if ($fmt != 0x04) { # must be int32u
                $exifTool->Error("Unexpected format ($fmt) for SR2SubIFD tag");
                return undef;
            }
            if ($tagID == 0x7201) { # SR2SubIFDLength
                Set32u($sr2Len, $outfile, $entry + 8);
                next;
            }
            my $tag = 'SR2SubIFDOffset';
            my $valuePtr = @subifdPos < 2 ? $entry+8 : Get32u($outfile, $entry+8);
            my $pos;
            foreach $pos (@subifdPos) {
                Set32u($pos, $outfile, $valuePtr);
                $dirInfo->{Fixup}->AddFixup($valuePtr, $tag);
                undef $tag;
                $valuePtr += 4;
            }
        }
        unless ($found{0x7200} and $found{0x7201}) {
            $exifTool->Error('Missing SR2SubIFD tag');
            return undef;
        }
    }
    return $outfile ? $$outfile : $result;
}

1; # end

__END__

=head1 NAME

Image::ExifTool::Sony - Sony EXIF maker notes tags

=head1 SYNOPSIS

This module is loaded automatically by Image::ExifTool when required.

=head1 DESCRIPTION

This module contains definitions required by Image::ExifTool to interpret
Sony maker notes EXIF meta information.

=head1 NOTES

Also see Minolta.pm since Sony DSLR models use structures originating from
Minolta.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://www.cybercom.net/~dcoffin/dcraw/>

=item L<http://homepage3.nifty.com/kamisaka/makernote/makernote_sony.htm>

=item L<http://www.klingebiel.com/tempest/hd/pmp.html>

=item (...plus lots of testing with my RX100!)

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Thomas Bodenmann, Philippe Devaux, Jens Duttke, Marcus
Holland-Moritz, Andrey Tverdokhleb, Rudiger Lange, Igal Milchtaich, Michael
Reitinger and Jos Roost for help decoding some tags.

=head1 SEE ALSO

L<Image::ExifTool::TagNames/Sony Tags>,
L<Image::ExifTool::TagNames/Minolta Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut
