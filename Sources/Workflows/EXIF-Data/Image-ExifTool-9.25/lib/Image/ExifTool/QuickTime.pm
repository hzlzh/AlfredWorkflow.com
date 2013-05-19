#------------------------------------------------------------------------------
# File:         QuickTime.pm
#
# Description:  Read QuickTime, MP4 and M4A meta information
#
# Revisions:    10/04/2005 - P. Harvey Created
#               12/19/2005 - P. Harvey Added MP4 support
#               09/22/2006 - P. Harvey Added M4A support
#               07/27/2010 - P. Harvey Updated to 2010-05-03 QuickTime spec
#
# References:   1) http://developer.apple.com/mac/library/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html
#               2) http://search.cpan.org/dist/MP4-Info-1.04/
#               3) http://www.geocities.com/xhelmboyx/quicktime/formats/mp4-layout.txt
#               4) http://wiki.multimedia.cx/index.php?title=Apple_QuickTime
#               5) ISO 14496-12 (http://neuron2.net/library/avc/c041828_ISO_IEC_14496-12_2005(E).pdf)
#               6) ISO 14496-16 (http://www.iec-normen.de/previewpdf/info_isoiec14496-16%7Bed2.0%7Den.pdf)
#               7) http://atomicparsley.sourceforge.net/mpeg-4files.html
#               8) http://wiki.multimedia.cx/index.php?title=QuickTime_container
#               9) http://www.adobe.com/devnet/xmp/pdfs/XMPSpecificationPart3.pdf (Oct 2008)
#               10) http://code.google.com/p/mp4v2/wiki/iTunesMetadata
#               11) http://www.canieti.com.mx/assets/files/1011/IEC_100_1384_DC.pdf
#               12) QuickTime file format specification 2010-05-03
#               13) http://www.adobe.com/devnet/flv/pdf/video_file_format_spec_v10.pdf
#               14) http://standards.iso.org/ittf/PubliclyAvailableStandards/c051533_ISO_IEC_14496-12_2008.zip
#               15) http://getid3.sourceforge.net/source/module.audio-video.quicktime.phps
#------------------------------------------------------------------------------

package Image::ExifTool::QuickTime;

use strict;
use vars qw($VERSION);
use Image::ExifTool qw(:DataAccess :Utils);
use Image::ExifTool::Exif;

$VERSION = '1.67';

sub FixWrongFormat($);
sub ProcessMOV($$;$);
sub ProcessKeys($$$);
sub ProcessMetaData($$$);
sub ProcessEncodingParams($$$);
sub ConvertISO6709($);
sub PrintGPSCoordinates($);
sub UnpackLang($);

# MIME types for all entries in the ftypLookup with file extensions
# (defaults to 'video/mp4' if not found in this lookup)
my %mimeLookup = (
   '3G2' => 'video/3gpp2',
   '3GP' => 'video/3gpp',
    DVB  => 'video/vnd.dvb.file',
    F4A  => 'audio/mp4',
    F4B  => 'audio/mp4',
    JP2  => 'image/jp2',
    JPM  => 'image/jpm',
    JPX  => 'image/jpx',
    M4A  => 'audio/mp4',
    M4B  => 'audio/mp4',
    M4P  => 'audio/mp4',
    M4V  => 'video/x-m4v',
    MOV  => 'video/quicktime',
    MQV  => 'video/quicktime',
);

# look up file type from ftyp atom type, with MIME type in comment if known
# (ref http://www.ftyps.com/)
my %ftypLookup = (
    '3g2a' => '3GPP2 Media (.3G2) compliant with 3GPP2 C.S0050-0 V1.0', # video/3gpp2
    '3g2b' => '3GPP2 Media (.3G2) compliant with 3GPP2 C.S0050-A V1.0.0', # video/3gpp2
    '3g2c' => '3GPP2 Media (.3G2) compliant with 3GPP2 C.S0050-B v1.0', # video/3gpp2
    '3ge6' => '3GPP (.3GP) Release 6 MBMS Extended Presentations', # video/3gpp
    '3ge7' => '3GPP (.3GP) Release 7 MBMS Extended Presentations', # video/3gpp
    '3gg6' => '3GPP Release 6 General Profile', # video/3gpp
    '3gp1' => '3GPP Media (.3GP) Release 1 (probably non-existent)', # video/3gpp
    '3gp2' => '3GPP Media (.3GP) Release 2 (probably non-existent)', # video/3gpp
    '3gp3' => '3GPP Media (.3GP) Release 3 (probably non-existent)', # video/3gpp
    '3gp4' => '3GPP Media (.3GP) Release 4', # video/3gpp
    '3gp5' => '3GPP Media (.3GP) Release 5', # video/3gpp
    '3gp6' => '3GPP Media (.3GP) Release 6 Basic Profile', # video/3gpp
    '3gp6' => '3GPP Media (.3GP) Release 6 Progressive Download', # video/3gpp
    '3gp6' => '3GPP Media (.3GP) Release 6 Streaming Servers', # video/3gpp
    '3gs7' => '3GPP Media (.3GP) Release 7 Streaming Servers', # video/3gpp
    'avc1' => 'MP4 Base w/ AVC ext [ISO 14496-12:2005]', # video/mp4
    'CAEP' => 'Canon Digital Camera',
    'caqv' => 'Casio Digital Camera',
    'CDes' => 'Convergent Design',
    'da0a' => 'DMB MAF w/ MPEG Layer II aud, MOT slides, DLS, JPG/PNG/MNG images',
    'da0b' => 'DMB MAF, extending DA0A, with 3GPP timed text, DID, TVA, REL, IPMP',
    'da1a' => 'DMB MAF audio with ER-BSAC audio, JPG/PNG/MNG images',
    'da1b' => 'DMB MAF, extending da1a, with 3GPP timed text, DID, TVA, REL, IPMP',
    'da2a' => 'DMB MAF aud w/ HE-AAC v2 aud, MOT slides, DLS, JPG/PNG/MNG images',
    'da2b' => 'DMB MAF, extending da2a, with 3GPP timed text, DID, TVA, REL, IPMP',
    'da3a' => 'DMB MAF aud with HE-AAC aud, JPG/PNG/MNG images',
    'da3b' => 'DMB MAF, extending da3a w/ BIFS, 3GPP timed text, DID, TVA, REL, IPMP',
    'dmb1' => 'DMB MAF supporting all the components defined in the specification',
    'dmpf' => 'Digital Media Project', # various
    'drc1' => 'Dirac (wavelet compression), encapsulated in ISO base media (MP4)',
    'dv1a' => 'DMB MAF vid w/ AVC vid, ER-BSAC aud, BIFS, JPG/PNG/MNG images, TS',
    'dv1b' => 'DMB MAF, extending dv1a, with 3GPP timed text, DID, TVA, REL, IPMP',
    'dv2a' => 'DMB MAF vid w/ AVC vid, HE-AAC v2 aud, BIFS, JPG/PNG/MNG images, TS',
    'dv2b' => 'DMB MAF, extending dv2a, with 3GPP timed text, DID, TVA, REL, IPMP',
    'dv3a' => 'DMB MAF vid w/ AVC vid, HE-AAC aud, BIFS, JPG/PNG/MNG images, TS',
    'dv3b' => 'DMB MAF, extending dv3a, with 3GPP timed text, DID, TVA, REL, IPMP',
    'dvr1' => 'DVB (.DVB) over RTP', # video/vnd.dvb.file
    'dvt1' => 'DVB (.DVB) over MPEG-2 Transport Stream', # video/vnd.dvb.file
    'F4A ' => 'Audio for Adobe Flash Player 9+ (.F4A)', # audio/mp4
    'F4B ' => 'Audio Book for Adobe Flash Player 9+ (.F4B)', # audio/mp4
    'F4P ' => 'Protected Video for Adobe Flash Player 9+ (.F4P)', # video/mp4
    'F4V ' => 'Video for Adobe Flash Player 9+ (.F4V)', # video/mp4
    'isc2' => 'ISMACryp 2.0 Encrypted File', # ?/enc-isoff-generic
    'iso2' => 'MP4 Base Media v2 [ISO 14496-12:2005]', # video/mp4
    'isom' => 'MP4  Base Media v1 [IS0 14496-12:2003]', # video/mp4
    'JP2 ' => 'JPEG 2000 Image (.JP2) [ISO 15444-1 ?]', # image/jp2
    'JP20' => 'Unknown, from GPAC samples (prob non-existent)',
    'jpm ' => 'JPEG 2000 Compound Image (.JPM) [ISO 15444-6]', # image/jpm
    'jpx ' => 'JPEG 2000 with extensions (.JPX) [ISO 15444-2]', # image/jpx
    'KDDI' => '3GPP2 EZmovie for KDDI 3G cellphones', # video/3gpp2
    #LCAG  => (found in CompatibleBrands of Leica MOV videos)
    'M4A ' => 'Apple iTunes AAC-LC (.M4A) Audio', # audio/x-m4a
    'M4B ' => 'Apple iTunes AAC-LC (.M4B) Audio Book', # audio/mp4
    'M4P ' => 'Apple iTunes AAC-LC (.M4P) AES Protected Audio', # audio/mp4
    'M4V ' => 'Apple iTunes Video (.M4V) Video', # video/x-m4v
    'M4VH' => 'Apple TV (.M4V)', # video/x-m4v
    'M4VP' => 'Apple iPhone (.M4V)', # video/x-m4v
    'mj2s' => 'Motion JPEG 2000 [ISO 15444-3] Simple Profile', # video/mj2
    'mjp2' => 'Motion JPEG 2000 [ISO 15444-3] General Profile', # video/mj2
    'mmp4' => 'MPEG-4/3GPP Mobile Profile (.MP4/3GP) (for NTT)', # video/mp4
    'mp21' => 'MPEG-21 [ISO/IEC 21000-9]', # various
    'mp41' => 'MP4 v1 [ISO 14496-1:ch13]', # video/mp4
    'mp42' => 'MP4 v2 [ISO 14496-14]', # video/mp4
    'mp71' => 'MP4 w/ MPEG-7 Metadata [per ISO 14496-12]', # various
    'MPPI' => 'Photo Player, MAF [ISO/IEC 23000-3]', # various
    'mqt ' => 'Sony / Mobile QuickTime (.MQV) US Patent 7,477,830 (Sony Corp)', # video/quicktime
    'MSNV' => 'MPEG-4 (.MP4) for SonyPSP', # audio/mp4
    'NDAS' => 'MP4 v2 [ISO 14496-14] Nero Digital AAC Audio', # audio/mp4
    'NDSC' => 'MPEG-4 (.MP4) Nero Cinema Profile', # video/mp4
    'NDSH' => 'MPEG-4 (.MP4) Nero HDTV Profile', # video/mp4
    'NDSM' => 'MPEG-4 (.MP4) Nero Mobile Profile', # video/mp4
    'NDSP' => 'MPEG-4 (.MP4) Nero Portable Profile', # video/mp4
    'NDSS' => 'MPEG-4 (.MP4) Nero Standard Profile', # video/mp4
    'NDXC' => 'H.264/MPEG-4 AVC (.MP4) Nero Cinema Profile', # video/mp4
    'NDXH' => 'H.264/MPEG-4 AVC (.MP4) Nero HDTV Profile', # video/mp4
    'NDXM' => 'H.264/MPEG-4 AVC (.MP4) Nero Mobile Profile', # video/mp4
    'NDXP' => 'H.264/MPEG-4 AVC (.MP4) Nero Portable Profile', # video/mp4
    'NDXS' => 'H.264/MPEG-4 AVC (.MP4) Nero Standard Profile', # video/mp4
    'odcf' => 'OMA DCF DRM Format 2.0 (OMA-TS-DRM-DCF-V2_0-20060303-A)', # various
    'opf2' => 'OMA PDCF DRM Format 2.1 (OMA-TS-DRM-DCF-V2_1-20070724-C)',
    'opx2' => 'OMA PDCF DRM + XBS extensions (OMA-TS-DRM_XBS-V1_0-20070529-C)',
    'pana' => 'Panasonic Digital Camera',
    'qt  ' => 'Apple QuickTime (.MOV/QT)', # video/quicktime
    'ROSS' => 'Ross Video',
    'sdv ' => 'SD Memory Card Video', # various?
    'ssc1' => 'Samsung stereoscopic, single stream',
    'ssc2' => 'Samsung stereoscopic, dual stream',
);

# information for time/date-based tags (time zero is Jan 1, 1904)
my %timeInfo = (
    Notes => 'converted from UTC to local time if the QuickTimeUTC option is set',
    # It is not uncommon for brain-dead software to use the wrong time zero,
    # so assume a time zero of Jan 1, 1970 if the date is before this
    RawConv => q{
        my $offset = (66 * 365 + 17) * 24 * 3600;
        return $val - $offset if $val >= $offset;
        $self->WarnOnce('Patched incorrect time zero for QuickTime date/time tag',1) if $val;
        return $val;
    },
    # Note: This value will be in UTC if generated by a system that is aware of the time zone
    ValueConv => 'ConvertUnixTime($val, $self->Options("QuickTimeUTC"))',
    PrintConv => '$self->ConvertDateTime($val)',
    # (can't put Groups here because they aren't constant!)
);
# information for duration tags
my %durationInfo = (
    ValueConv => '$$self{TimeScale} ? $val / $$self{TimeScale} : $val',
    PrintConv => '$$self{TimeScale} ? ConvertDuration($val) : $val',
);
# parsing for most of the 3gp udta language text boxes
my %langText = (
    RawConv => sub {
        my ($val, $self) = @_;
        return '<err>' unless length $val >= 6;
        my $lang = UnpackLang(Get16u(\$val, 4));
        $lang = $lang ? "($lang) " : '';
        $val = substr($val, 6); # isolate string
        $val = $self->Decode($val, 'UCS2') if $val =~ /^\xfe\xff/;
        return $lang . $val;
    },
);

# 4-character Vendor ID codes (ref PH)
my %vendorID = (
    appl => 'Apple',
    fe20 => 'Olympus (fe20)', # (FE200)
    FFMP => 'FFmpeg',
   'GIC '=> 'General Imaging Co.',
    kdak => 'Kodak',
    KMPI => 'Konica-Minolta',
    leic => 'Leica',
    mino => 'Minolta',
    niko => 'Nikon',
    NIKO => 'Nikon',
    olym => 'Olympus',
    pana => 'Panasonic',
    pent => 'Pentax',
    pr01 => 'Olympus (pr01)', # (FE100,FE110,FE115)
    sany => 'Sanyo',
   'SMI '=> 'Sorenson Media Inc.',
    ZORA => 'Zoran Corporation',
);

# QuickTime data atom encodings for string types (ref 12)
my %stringEncoding = (
    1 => 'UTF8',
    2 => 'UTF16',
    3 => 'ShiftJIS',
    4 => 'UTF8',
    5 => 'UTF16',
);

my %graphicsMode = (
    # (ref http://homepage.mac.com/vanhoek/MovieGuts%20docs/64.html)
    0x00 => 'srcCopy',
    0x01 => 'srcOr',
    0x02 => 'srcXor',
    0x03 => 'srcBic',
    0x04 => 'notSrcCopy',
    0x05 => 'notSrcOr',
    0x06 => 'notSrcXor',
    0x07 => 'notSrcBic',
    0x08 => 'patCopy',
    0x09 => 'patOr',
    0x0a => 'patXor',
    0x0b => 'patBic',
    0x0c => 'notPatCopy',
    0x0d => 'notPatOr',
    0x0e => 'notPatXor',
    0x0f => 'notPatBic',
    0x20 => 'blend',
    0x21 => 'addPin',
    0x22 => 'addOver',
    0x23 => 'subPin',
    0x24 => 'transparent',
    0x25 => 'addMax',
    0x26 => 'subOver',
    0x27 => 'addMin',
    0x31 => 'grayishTextOr',
    0x32 => 'hilite',
    0x40 => 'ditherCopy',
    # the following ref ISO/IEC 15444-3
    0x100 => 'Alpha',
    0x101 => 'White Alpha',
    0x102 => 'Pre-multiplied Black Alpha',
    0x110 => 'Component Alpha',
);

# QuickTime atoms
%Image::ExifTool::QuickTime::Main = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    NOTES => q{
        The QuickTime format is used for many different types of audio, video and
        image files (most commonly, MOV and MP4 videos).  Exiftool extracts standard
        meta information a variety of audio, video and image parameters, as well as
        proprietary information written by many camera models.  Tags with a question
        mark after their name are not extracted unless the Unknown option is set.

        According to the specification, many QuickTime date/time tags should be
        stored as UTC.  Unfortunately, digital cameras often store local time values
        instead (presumably because they don't know the time zone).  For this
        reason, by default ExifTool does not assume a time zone for these values.
        However, if the QuickTimeUTC option is set via the API or the ExifTool
        configuration file, then ExifTool will assume these values are properly
        stored as UTC, and will convert them to local time when extracting.
    },
    free => [
        {
            Name => 'KodakFree',
            # (found in Kodak M5370 MP4 videos)
            Condition => '$$valPt =~ /^\0\0\0.Seri/s',
            SubDirectory => { TagTable => 'Image::ExifTool::Kodak::Free' },
        },{
            Unknown => 1,
            Binary => 1,
        },
        # (also Samsung WB750 uncompressed thumbnail data starting with "SDIC\0")
    ],
    skip => [
        {
            Name => 'CanonSkip',
            Condition => '$$valPt =~ /^\0.{3}(CNDB|CNCV|CNMN|CNFV|CNTH|CNDM)/s',
            SubDirectory => { TagTable => 'Image::ExifTool::Canon::Skip' },
        },
        { Name => 'Skip', Unknown => 1, Binary => 1 },
    ],
    wide => { Unknown => 1, Binary => 1 },
    ftyp => { #MP4
        Name => 'FileType',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::FileType' },
    },
    pnot => {
        Name => 'Preview',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Preview' },
    },
    PICT => {
        Name => 'PreviewPICT',
        Binary => 1,
    },
    pict => { #8
        Name => 'PreviewPICT',
        Binary => 1,
    },
    moov => {
        Name => 'Movie',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Movie' },
    },
    mdat => { Name => 'MovieData', Unknown => 1, Binary => 1 },
    'mdat-size' => {
        Name => 'MovieDataSize',
        Notes => q{
            not a real tag ID, this tag represents the size of the 'mdat' data in bytes
            and is used in the AvgBitrate calculation
        },
    },
    junk => { Unknown => 1, Binary => 1 }, #8
    uuid => [
        { #9 (MP4 files)
            Name => 'UUID-XMP',
            Condition => '$$valPt=~/^\xbe\x7a\xcf\xcb\x97\xa9\x42\xe8\x9c\x71\x99\x94\x91\xe3\xaf\xac/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::XMP::Main',
                Start => 16,
            },
        },
        { #11 (MP4 files)
            Name => 'UUID-PROF',
            Condition => '$$valPt=~/^PROF!\xd2\x4f\xce\xbb\x88\x69\x5c\xfa\xc9\xc7\x40/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::Profile',
                Start => 24, # uid(16) + version(1) + flags(3) + count(4)
            },
        },
        { #PH (Flip MP4 files)
            Name => 'UUID-Flip',
            Condition => '$$valPt=~/\x4a\xb0\x3b\x0f\x61\x8d\x40\x75\x82\xb2\xd9\xfa\xce\xd3\x5f\xf5/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::Flip',
                Start => 16,
            },
        },
        # "\x98\x7f\xa3\xdf\x2a\x85\x43\xc0\x8f\x8f\xd9\x7c\x47\x1e\x8e\xea" - unknown data in Flip videos
        { #8
            Name => 'UUID-Unknown',
            Unknown => 1,
            Binary => 1,
        },
    ],
);

# MPEG-4 'ftyp' atom
# (ref http://developer.apple.com/mac/library/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html)
%Image::ExifTool::QuickTime::FileType = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    FORMAT => 'int32u',
    0 => {
        Name => 'MajorBrand',
        Format => 'undef[4]',
        PrintConv => \%ftypLookup,
    },
    1 => {
        Name => 'MinorVersion',
        Format => 'undef[4]',
        ValueConv => 'sprintf("%x.%x.%x", unpack("nCC", $val))',
    },
    2 => {
        Name => 'CompatibleBrands',
        Format => 'undef[$size-8]',
        # ignore any entry with a null, and return others as a list
        ValueConv => 'my @a=($val=~/.{4}/sg); @a=grep(!/\0/,@a); \@a', 
    },
);

# atoms used in QTIF files
%Image::ExifTool::QuickTime::ImageFile = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Image' },
    NOTES => 'Tags used in QTIF QuickTime Image Files.',
    idsc => {
        Name => 'ImageDescription',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::ImageDesc' },
    },
    idat => {
        Name => 'ImageData',
        Binary => 1,
    },
    iicc => {
        Name => 'ICC_Profile',
        SubDirectory => { TagTable => 'Image::ExifTool::ICC_Profile::Main' },
    },
);

# image description data block
%Image::ExifTool::QuickTime::ImageDesc = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    FORMAT => 'int16u',
    2 => {
        Name => 'CompressorID',
        Format => 'string[4]',
# not very useful since this isn't a complete list and name is given below
#        # ref http://developer.apple.com/mac/library/documentation/QuickTime/QTFF/QTFFChap3/qtff3.html
#        PrintConv => {
#            cvid => 'Cinepak',
#            jpeg => 'JPEG',
#           'smc '=> 'Graphics',
#           'rle '=> 'Animation',
#            rpza => 'Apple Video',
#            kpcd => 'Kodak Photo CD',
#           'png '=> 'Portable Network Graphics',
#            mjpa => 'Motion-JPEG (format A)',
#            mjpb => 'Motion-JPEG (format B)',
#            SVQ1 => 'Sorenson video, version 1',
#            SVQ3 => 'Sorenson video, version 3',
#            mp4v => 'MPEG-4 video',
#           'dvc '=> 'NTSC DV-25 video',
#            dvcp => 'PAL DV-25 video',
#           'gif '=> 'Compuserve Graphics Interchange Format',
#            h263 => 'H.263 video',
#            tiff => 'Tagged Image File Format',
#           'raw '=> 'Uncompressed RGB',
#           '2vuY'=> "Uncompressed Y'CbCr, 3x8-bit 4:2:2 (2vuY)",
#           'yuv2'=> "Uncompressed Y'CbCr, 3x8-bit 4:2:2 (yuv2)",
#            v308 => "Uncompressed Y'CbCr, 8-bit 4:4:4",
#            v408 => "Uncompressed Y'CbCr, 8-bit 4:4:4:4",
#            v216 => "Uncompressed Y'CbCr, 10, 12, 14, or 16-bit 4:2:2",
#            v410 => "Uncompressed Y'CbCr, 10-bit 4:4:4",
#            v210 => "Uncompressed Y'CbCr, 10-bit 4:2:2",
#        },
    },
    10 => {
        Name => 'VendorID',
        Format => 'string[4]',
        RawConv => 'length $val ? $val : undef',
        PrintConv => \%vendorID,
        SeparateTable => 'VendorID',
    },
  # 14 - ("Quality" in QuickTime docs) ??
    16 => 'SourceImageWidth',
    17 => 'SourceImageHeight',
    18 => { Name => 'XResolution',  Format => 'fixed32u' },
    20 => { Name => 'YResolution',  Format => 'fixed32u' },
  # 24 => 'FrameCount', # always 1 (what good is this?)
    25 => {
        Name => 'CompressorName',
        Format => 'string[32]',
        # (sometimes this is a Pascal string, and sometimes it is a C string)
        RawConv => q{
            $val=substr($val,1,ord($1)) if $val=~/^([\0-\x1f])/ and ord($1)<length($val);
            length $val ? $val : undef;
        },
    },
    41 => 'BitDepth',
);

# preview data block
%Image::ExifTool::QuickTime::Preview = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    FORMAT => 'int16u',
    0 => {
        Name => 'PreviewDate',
        Format => 'int32u',
        Groups => { 2 => 'Time' },
        %timeInfo,
    },
    2 => 'PreviewVersion',
    3 => {
        Name => 'PreviewAtomType',
        Format => 'string[4]',
    },
    5 => 'PreviewAtomIndex',
);

# movie atoms
%Image::ExifTool::QuickTime::Movie = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    mvhd => {
        Name => 'MovieHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::MovieHeader' },
    },
    trak => {
        Name => 'Track',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Track' },
    },
    udta => {
        Name => 'UserData',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::UserData' },
    },
    meta => { # 'meta' is found here in my EX-F1 MOV sample - PH
        Name => 'Meta',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Meta' },
    },
    iods => {
        Name => 'InitialObjectDescriptor',
        Flags => ['Binary','Unknown'],
    },
    uuid => [
        { #11 (MP4 files) (also found in QuickTime::Track)
            Name => 'UUID-USMT',
            Condition => '$$valPt=~/^USMT!\xd2\x4f\xce\xbb\x88\x69\x5c\xfa\xc9\xc7\x40/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::UserMedia',
                Start => 16,
            },
        },
        {
            Name => 'UUID-Unknown',
            Unknown => 1,
            Binary => 1,
        },
    ],
    cmov => {
        Name => 'CompressedMovie',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::CMovie' },
    },
    # prfl - Profile (ref 12)
    # clip - clipping --> contains crgn (clip region) (ref 12)
    # mvex - movie extends --> contains mehd (movie extends header), trex (track extends) (ref 14)
);

# movie header data block
%Image::ExifTool::QuickTime::MovieHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    FORMAT => 'int32u',
    0 => {
        Name => 'MovieHeaderVersion',
        Format => 'int8u',
        RawConv => '$$self{MovieHeaderVersion} = $val',
    },
    1 => {
        Name => 'CreateDate',
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if MovieHeaderVersion == 1 (ref 13)
        Hook => '$$self{MovieHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    2 => {
        Name => 'ModifyDate',
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if MovieHeaderVersion == 1 (ref 13)
        Hook => '$$self{MovieHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    3 => {
        Name => 'TimeScale',
        RawConv => '$$self{TimeScale} = $val',
    },
    4 => {
        Name => 'Duration',
        %durationInfo,
        # this is int64u if MovieHeaderVersion == 1 (ref 13)
        Hook => '$$self{MovieHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    5 => {
        Name => 'PreferredRate',
        ValueConv => '$val / 0x10000',
    },
    6 => {
        Name => 'PreferredVolume',
        Format => 'int16u',
        ValueConv => '$val / 256',
        PrintConv => 'sprintf("%.2f%%", $val * 100)',
    },
    9 => {
        Name => 'MatrixStructure',
        Format => 'fixed32s[9]',
        # (the right column is fixed 2.30 instead of 16.16)
        ValueConv => q{
            my @a = split ' ',$val;
            $_ /= 0x4000 foreach @a[2,5,8];
            return "@a";
        },
    },
    18 => { Name => 'PreviewTime',      %durationInfo },
    19 => { Name => 'PreviewDuration',  %durationInfo },
    20 => { Name => 'PosterTime',       %durationInfo },
    21 => { Name => 'SelectionTime',    %durationInfo },
    22 => { Name => 'SelectionDuration',%durationInfo },
    23 => { Name => 'CurrentTime',      %durationInfo },
    24 => 'NextTrackID',
);

# track atoms
%Image::ExifTool::QuickTime::Track = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    tkhd => {
        Name => 'TrackHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::TrackHeader' },
    },
    udta => {
        Name => 'UserData',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::UserData' },
    },
    mdia => { #MP4
        Name => 'Media',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Media' },
    },
    meta => { #PH (MOV)
        Name => 'Meta',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Meta' },
    },
    tref => {
        Name => 'TrackRef',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::TrackRef' },
    },
    tapt => {
        Name => 'TrackAperture',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::TrackAperture' },
    },
    uuid => [
        { #11 (MP4 files) (also found in QuickTime::Movie)
            Name => 'UUID-USMT',
            Condition => '$$valPt=~/^USMT!\xd2\x4f\xce\xbb\x88\x69\x5c\xfa\xc9\xc7\x40/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::UserMedia',
                Start => 16,
            },
        },
        {
            Name => 'UUID-Unknown',
            Unknown => 1,
            Binary => 1,
        },
    ],
    # edts - edits --> contains elst (edit list)
    # clip - clipping --> contains crgn (clip region)
    # matt - track matt --> contains kmat (compressed matt)
    # load - track loading settings
    # imap - track input map --> contains '  in' --> contains '  ty', obid
    # prfl - Profile (ref 12)
);

# track header data block
%Image::ExifTool::QuickTime::TrackHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 1 => 'Track#', 2 => 'Video' },
    FORMAT => 'int32u',
    0 => {
        Name => 'TrackHeaderVersion',
        Format => 'int8u',
        Priority => 0,
        RawConv => '$$self{TrackHeaderVersion} = $val',
    },
    1 => {
        Name => 'TrackCreateDate',
        Priority => 0,
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if TrackHeaderVersion == 1 (ref 13)
        Hook => '$$self{TrackHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    2 => {
        Name => 'TrackModifyDate',
        Priority => 0,
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if TrackHeaderVersion == 1 (ref 13)
        Hook => '$$self{TrackHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    3 => {
        Name => 'TrackID',
        Priority => 0,
    },
    5 => {
        Name => 'TrackDuration',
        Priority => 0,
        %durationInfo,
        # this is int64u if TrackHeaderVersion == 1 (ref 13)
        Hook => '$$self{TrackHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    8 => {
        Name => 'TrackLayer',
        Format => 'int16u',
        Priority => 0,
    },
    9 => {
        Name => 'TrackVolume',
        Format => 'int16u',
        Priority => 0,
        ValueConv => '$val / 256',
        PrintConv => 'sprintf("%.2f%%", $val * 100)',
    },
    10 => {
        Name => 'MatrixStructure',
        Format => 'fixed32s[9]',
        # (the right column is fixed 2.30 instead of 16.16)
        ValueConv => q{
            my @a = split ' ',$val;
            $_ /= 0x4000 foreach @a[2,5,8];
            return "@a";
        },
    },
    19 => {
        Name => 'ImageWidth',
        Priority => 0,
        RawConv => \&FixWrongFormat,
    },
    20 => {
        Name => 'ImageHeight',
        Priority => 0,
        RawConv => \&FixWrongFormat,
    },
);

# user data atoms
%Image::ExifTool::QuickTime::UserData = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    NOTES => q{
        Tag ID's beginning with the copyright symbol (hex 0xa9) are multi-language
        text.  Alternate language tags are accessed by adding a dash followed by the
        language/country code to the tag name.  ExifTool will extract any
        multi-language user data tags found, even if they don't exist in this table.
    },
    "\xa9cpy" => { Name => 'Copyright',  Groups => { 2 => 'Author' } },
    "\xa9day" => {
        Name => 'CreateDate',
        Groups => { 2 => 'Time' },
        # handle values in the form "2010-02-12T13:27:14-0800" (written by Apple iPhone)
        ValueConv => q{
            require Image::ExifTool::XMP;
            $val =  Image::ExifTool::XMP::ConvertXMPDate($val);
            $val =~ s/([-+]\d{2})(\d{2})$/$1:$2/; # add colon to timezone if necessary
            return $val;
        },
        PrintConv => '$self->ConvertDateTime($val)',
    },
    "\xa9ART" => 'Artist', #PH (iTunes 8.0.2)
    "\xa9alb" => 'Album', #PH (iTunes 8.0.2)
    "\xa9arg" => 'Arranger', #12
    "\xa9ark" => 'ArrangerKeywords', #12
    "\xa9cmt" => 'Comment', #PH (iTunes 8.0.2)
    "\xa9cok" => 'ComposerKeywords', #12
    "\xa9com" => 'Composer', #12
    "\xa9dir" => 'Director', #12
    "\xa9ed1" => 'Edit1',
    "\xa9ed2" => 'Edit2',
    "\xa9ed3" => 'Edit3',
    "\xa9ed4" => 'Edit4',
    "\xa9ed5" => 'Edit5',
    "\xa9ed6" => 'Edit6',
    "\xa9ed7" => 'Edit7',
    "\xa9ed8" => 'Edit8',
    "\xa9ed9" => 'Edit9',
    "\xa9fmt" => 'Format',
    "\xa9gen" => 'Genre', #PH (iTunes 8.0.2)
    "\xa9grp" => 'Grouping', #PH (NC)
    "\xa9inf" => 'Information',
    "\xa9isr" => 'ISRCCode', #12
    "\xa9lab" => 'RecordLabelName', #12
    "\xa9lal" => 'RecordLabelURL', #12
    "\xa9lyr" => 'Lyrics', #PH (NC)
    "\xa9mak" => 'Make', #12
    "\xa9mal" => 'MakerURL', #12
    "\xa9mod" => 'Model', #PH
    "\xa9nam" => 'Title', #12
    "\xa9pdk" => 'ProducerKeywords', #12
    "\xa9phg" => 'RecordingCopyright', #12
    "\xa9prd" => 'Producer',
    "\xa9prf" => 'Performers',
    "\xa9prk" => 'PerformerKeywords', #12
    "\xa9prl" => 'PerformerURL',
    "\xa9dir" => 'Director', #12
    "\xa9req" => 'Requirements',
    "\xa9snk" => 'SubtitleKeywords', #12
    "\xa9snm" => 'Subtitle', #12
    "\xa9src" => 'SourceCredits', #12
    "\xa9swf" => 'SongWriter', #12
    "\xa9swk" => 'SongWriterKeywords', #12
    "\xa9swr" => 'SoftwareVersion', #12
    "\xa9too" => 'Encoder', #PH (NC)
    "\xa9trk" => 'Track', #PH (NC)
    "\xa9wrt" => 'Composer',
    "\xa9xyz" => { #PH (iPhone 3GS)
        Name => 'GPSCoordinates',
        Groups => { 2 => 'Location' },
        ValueConv => \&ConvertISO6709,
        PrintConv => \&PrintGPSCoordinates,
    },
    name => 'Name',
    WLOC => {
        Name => 'WindowLocation',
        Format => 'int16u',
    },
    LOOP => {
        Name => 'LoopStyle',
        Format => 'int32u',
        PrintConv => {
            1 => 'Normal',
            2 => 'Palindromic',
        },
    },
    SelO => {
        Name => 'PlaySelection',
        Format => 'int8u',
    },
    AllF => {
        Name => 'PlayAllFrames',
        Format => 'int8u',
    },
    meta => {
        Name => 'Meta',
        SubDirectory => {
            TagTable => 'Image::ExifTool::QuickTime::Meta',
            Start => 4, # must skip 4-byte version number header
        },
    },
    DcMD => {
        Name => 'KodakDcMD',
        SubDirectory => { TagTable => 'Image::ExifTool::Kodak::DcMD' },
    },
    # AMBA => Ambarella AVC atom (unknown data written by Kodak Playsport video cam)
   'ptv '=> {
        Name => 'PrintToVideo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Video' },
    },
   'hnti'=> {
        Name => 'HintInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::HintInfo' },
    },
   'hinf' => {
        Name => 'HintTrackInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::HintTrackInfo' },
    },
    TAGS => [ #PH
        # these tags were initially discovered in a Pentax movie,
        # but similar information is found in videos from other manufacturers
        {
            Name => 'FujiFilmTags',
            Condition => '$$valPt =~ /^FUJIFILM DIGITAL CAMERA\0/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::FujiFilm::MOV',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'KodakTags',
            Condition => '$$valPt =~ /^EASTMAN KODAK COMPANY/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Kodak::MOV',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'KonicaMinoltaTags',
            Condition => '$$valPt =~ /^KONICA MINOLTA DIGITAL CAMERA/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Minolta::MOV1',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'MinoltaTags',
            Condition => '$$valPt =~ /^MINOLTA DIGITAL CAMERA/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Minolta::MOV2',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'NikonTags',
            Condition => '$$valPt =~ /^NIKON DIGITAL CAMERA\0/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Nikon::MOV',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'OlympusTags1',
            Condition => '$$valPt =~ /^OLYMPUS DIGITAL CAMERA\0.{9}\x01\0/s',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Olympus::MOV1',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'OlympusTags2',
            Condition => '$$valPt =~ /^OLYMPUS DIGITAL CAMERA(?!\0.{21}\x0a\0{3})/s',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Olympus::MOV2',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'OlympusTags3',
            Condition => '$$valPt =~ /^OLYMPUS DIGITAL CAMERA\0/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Olympus::MP4',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'OlympusTags4',
            Condition => '$$valPt =~ /^.{16}OLYM\0/s',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Olympus::MOV3',
                Start => 12,
            },
        },
        {
            Name => 'PentaxTags',
            Condition => '$$valPt =~ /^PENTAX DIGITAL CAMERA\0/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Pentax::MOV',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'SamsungTags',
            Condition => '$$valPt =~ /^SAMSUNG DIGITAL CAMERA\0/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Samsung::MP4',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'SanyoMOV',
            Condition => q{
                $$valPt =~ /^SANYO DIGITAL CAMERA\0/ and
                $self->{VALUE}->{FileType} eq "MOV"
            },
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sanyo::MOV',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'SanyoMP4',
            Condition => q{
                $$valPt =~ /^SANYO DIGITAL CAMERA\0/ and
                $self->{VALUE}->{FileType} eq "MP4"
            },
            SubDirectory => {
                TagTable => 'Image::ExifTool::Sanyo::MP4',
                ByteOrder => 'LittleEndian',
            },
        },
        {
            Name => 'UnknownTags',
            Unknown => 1,
            Binary => 1
        },
    ],
    NCDT => { #PH
        Name => 'NikonNCDT',
        SubDirectory => { TagTable => 'Image::ExifTool::Nikon::NCDT' },
    },
    QVMI => { #PH
        Name => 'CasioQVMI',
        # Casio stores standard EXIF-format information in MOV videos (ie. EX-S880)
        SubDirectory => {
            TagTable => 'Image::ExifTool::Exif::Main',
            ProcessProc => \&Image::ExifTool::Exif::ProcessExif, # (because ProcessMOV is default)
            DirName => 'IFD0',
            Multi => 0, # (no NextIFD pointer)
            Start => 10,
            ByteOrder => 'BigEndian',
        },
    },
    PANA => { #PH
        Name => 'PanasonicPANA',
        SubDirectory => { TagTable => 'Image::ExifTool::Panasonic::PANA' },
    },
    LEIC => { #PH
        Name => 'LeicaLEIC',
        SubDirectory => { TagTable => 'Image::ExifTool::Panasonic::PANA' },
    },
    PENT => { #PH
        Name => 'PentaxPENT',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Pentax::PENT',
            ByteOrder => 'LittleEndian',
        },
    },
    MMA0 => { #PH (DiMage 7Hi)
        Name => 'MinoltaMMA0',
        SubDirectory => { TagTable => 'Image::ExifTool::Minolta::MMA' },
    },
    MMA1 => { #PH (Dimage A2)
        Name => 'MinoltaMMA1',
        SubDirectory => { TagTable => 'Image::ExifTool::Minolta::MMA' },
    },
    XMP_ => { #PH (Adobe CS3 Bridge)
        Name => 'XMP',
        SubDirectory => { TagTable => 'Image::ExifTool::XMP::Main' },
    },
    vndr => 'Vendor', #PH (Samsung PL70)
    SDLN => 'PlayMode', #PH (NC, Samsung ST80 "SEQ_PLAY")
    # Canon tags
    CNCV => 'CompressorVersion', #PH (5D Mark II)
    CNMN => 'Model', #PH (EOS 550D)
    CNFV => 'FirmwareVersion', #PH (EOS 550D)
    CNTH => { #PH (PowerShot S95)
        Name => 'CanonCNTH',
        SubDirectory => { TagTable => 'Image::ExifTool::Canon::CNTH' },
    },
    # CNDB - 2112 bytes (550D)
    # CNDM - 4 bytes - 0xff,0xd8,0xff,0xd9 (S95)
    INFO => {
        Name => 'SamsungINFO',
        SubDirectory => { TagTable => 'Image::ExifTool::Samsung::INFO' },
    },
    FFMV => { #PH (FinePix HS20EXR)
        Name => 'FujiFilmFFMV',
        SubDirectory => { TagTable => 'Image::ExifTool::FujiFilm::FFMV' },
    },
    MVTG => { #PH (FinePix HS20EXR)
        Name => 'FujiFilmMVTG',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Exif::Main',
            ProcessProc => \&Image::ExifTool::Exif::ProcessExif, # (because ProcessMOV is default)
            DirName => 'IFD0',
            Start => 16,
            Base => '$start',
            ByteOrder => 'LittleEndian',
        },
    },
    Xtra => { #PH (microsoft)
        Name => 'MicrosoftXtra',
        SubDirectory => { TagTable => 'Image::ExifTool::Microsoft::Xtra' },
    },
    hinv => 'HintVersion', #PH (guess)
    thmb => [
        { #PH (Pentax Q)
            Name => 'MakerNotePentax5a',
            Condition => '$$valPt =~ /^PENTAX \0II/',
            SubDirectory => {
                TagTable => 'Image::ExifTool::Pentax::Main',
                ProcessProc => \&Image::ExifTool::Exif::ProcessExif, # (because ProcessMOV is default)
                Start => 10,
                Base => '$start - 10',
                ByteOrder => 'LittleEndian',
            },
        },{ #PH (TG-810)
            Name => 'OlympusThumbnail',
            Condition => '$$valPt =~ /^.{4}\xff\xd8\xff\xdb/s',
            SubDirectory => { TagTable => 'Image::ExifTool::Olympus::thmb' },
        },
    ],
    scrn => { #PH (TG-810)
        Name => 'OlympusPreview',
        Condition => '$$valPt =~ /^.{4}\xff\xd8\xff\xdb/s',
        SubDirectory => { TagTable => 'Image::ExifTool::Olympus::scrn' },
    },
    PXTH => { #PH (Pentax K-01)
        Name => 'PentaxPreview',
        SubDirectory => { TagTable => 'Image::ExifTool::Pentax::PXTH' },
    },
    PXMN => { #PH (Pentax K-01)
        Name => 'MakerNotePentax5b',
        Condition => '$$valPt =~ /^PENTAX \0MM/',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Pentax::Main',
            ProcessProc => \&Image::ExifTool::Exif::ProcessExif, # (because ProcessMOV is default)
            Start => 10,
            Base => '$start - 10',
            ByteOrder => 'BigEndian',
        },
    },
    modl => { #PH (Samsung GT-S8530)
        Name => 'Model',
        Description => 'Camera Model Name',
    },
    # ducp - 4 bytes, all zero (Samsung ST96,WB750)
    GoPr => 'GoProType', #PH
    # the following are 3gp tags, references:
    # http://atomicparsley.sourceforge.net
    # http://www.3gpp.org/ftp/tsg_sa/WG4_CODEC/TSGS4_25/Docs/
    cprt => { Name => 'Copyright',  %langText, Groups => { 2 => 'Author' } },
    auth => { Name => 'Author',     %langText, Groups => { 2 => 'Author' } },
    titl => { Name => 'Title',      %langText },
    dscp => { Name => 'Description',%langText },
    perf => { Name => 'Performer',  %langText },
    gnre => { Name => 'Genre',      %langText },
    albm => { Name => 'Album',      %langText },
    rtng => {
        Name => 'Rating',
        # (4-byte flags, 4-char entity, 4-char criteria, 2-byte lang, string)
        RawConv => q{
            return '<err>' unless length $val >= 14;
            my $str = 'Entity=' . substr($val,4,4) . ' Criteria=' . substr($val,8,4);
            $str =~ tr/\0-\x1f\x7f-\xff//d; # remove unprintable characters
            my $lang = Image::ExifTool::QuickTime::UnpackLang(Get16u(\$val, 12));
            $lang = $lang ? "($lang) " : '';
            $val = substr($val, 14);
            $val = $self->Decode($val, 'UCS2') if $val =~ /^\xfe\xff/;
            return $lang . $str . ' ' . $val;
        },
    },
    clsf => {
        Name => 'Classification',
        # (4-byte flags, 4-char entity, 2-byte index, 2-byte lang, string)
        RawConv => q{
            return '<err>' unless length $val >= 12;
            my $str = 'Entity=' . substr($val,4,4) . ' Index=' . Get16u(\$val,8);
            $str =~ tr/\0-\x1f\x7f-\xff//d; # remove unprintable characters
            my $lang = Image::ExifTool::QuickTime::UnpackLang(Get16u(\$val, 10));
            $lang = $lang ? "($lang) " : '';
            $val = substr($val, 12);
            $val = $self->Decode($val, 'UCS2') if $val =~ /^\xfe\xff/;
            return $lang . $str . ' ' . $val;
        },
    },
    kywd => {
        Name => 'Keywords',
        # (4 byte flags, 2-byte lang, 1-byte count, count x pascal strings)
        RawConv => q{
            return '<err>' unless length $val >= 7;
            my $lang = Image::ExifTool::QuickTime::UnpackLang(Get16u(\$val, 4));
            $lang = $lang ? "($lang) " : '';
            my $num = Get8u(\$val, 6);
            my ($i, @vals);
            my $pos = 7;
            for ($i=0; $i<$num; ++$i) {
                last if $pos >= length $val;
                my $len = Get8u(\$val, $pos++);
                last if $pos + $len > length $val;
                my $v = substr($val, $pos, $len);
                $v = $self->Decode($v, 'UCS2') if $v =~ /^\xfe\xff/;
                push @vals, $v;
                $pos += $len;
            }
            my $sep = $self->Options('ListSep');
            return $lang . join($sep, @vals);
        },
    },
    loci => {
        Name => 'LocationInformation',
        Groups => { 2 => 'Location' },
        # (4-byte flags, 2-byte lang, location string, 1-byte role, 4-byte fixed longitude,
        #  4-byte fixed latitude, 4-byte fixed altitude, body string, notes string)
        RawConv => q{
            return '<err>' unless length $val >= 6;
            my $lang = Image::ExifTool::QuickTime::UnpackLang(Get16u(\$val, 4));
            $lang = $lang ? "($lang) " : '';
            $val = substr($val, 6);
            my $str;
            if ($val =~ /^\xfe\xff/) {
                $val =~ s/^(\xfe\xff(.{2})*?)\0\0//s or return '<err>';
                $str = $self->Decode($1, 'UCS2');
            } else {
                $val =~ s/^(.*?)\0//s or return '<err>';
                $str = $1;
            }
            $str = '(none)' unless length $str;
            return '<err>' if length $val < 13;
            my $role = Get8u(\$val, 0);
            my $lon = GetFixed32s(\$val, 1);
            my $lat = GetFixed32s(\$val, 5);
            my $alt = GetFixed32s(\$val, 9);
            my $roleStr = {0=>'shooting',1=>'real',2=>'fictional',3=>'reserved'}->{$role};
            $str .= ' Role=' . ($roleStr || "unknown($role)");
            $str .= sprintf(' Lat=%.5f Lon=%.5f Alt=%.2f', $lat, $lon, $alt);
            $val = substr($val, 13);
            if ($val =~ s/^(\xfe\xff(.{2})*?)\0\0//s) {
                $str .= ' Body=' . $self->Decode($1, 'UCS2');
            } elsif ($val =~ s/^(.*?)\0//s) {
                $str .= " Body=$1";
            }
            if ($val =~ s/^(\xfe\xff(.{2})*?)\0\0//s) {
                $str .= ' Notes=' . $self->Decode($1, 'UCS2');
            } elsif ($val =~ s/^(.*?)\0//s) {
                $str .= " Notes=$1";
            }
            return $lang . $str;
        },
    },
    yrrc => {
        Name => 'Year',
        Groups => { 2 => 'Time' },
        RawConv => 'length($val) >= 6 ? Get16u(\$val,4) : "<err>"',
    },
    # the following are various 3rd-party tags
    # ref http://code.google.com/p/mp4parser/source/browse/trunk/isoparser/src/main/resources/isoparser-default.properties?r=814
    ccid => 'ContentID',
    icnu => 'IconURI',
    infu => 'InfoURL',
    cdis => 'ContentDistributorID',
    albr => { Name => 'AlbumArtist', Groups => { 2 => 'Author' } },
    cvru => 'CoverURI',
    lrcu => 'LyricsURI',
);

# User-specific media data atoms (ref 11)
%Image::ExifTool::QuickTime::UserMedia = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    MTDT => {
        Name => 'MetaData',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::MetaData' },
    },
);

# User-specific media data atoms (ref 11)
%Image::ExifTool::QuickTime::MetaData = (
    PROCESS_PROC => \&Image::ExifTool::QuickTime::ProcessMetaData,
    GROUPS => { 2 => 'Video' },
    TAG_PREFIX => 'MetaData',
    0x01 => 'Title',
    0x03 => {
        Name => 'ProductionDate',
        Groups => { 2 => 'Time' },
        # translate from format "YYYY/mm/dd HH:MM:SS"
        ValueConv => '$val=~tr{/}{:}; $val',
        PrintConv => '$self->ConvertDateTime($val)',
    },
    0x04 => 'Software',
    0x05 => 'Product',
    0x0a => {
        Name => 'TrackProperty',
        RawConv => 'my @a=unpack("Nnn",$val); "@a"',
        PrintConv => [
            { 0 => 'No presentation', BITMASK => { 0 => 'Main track' } },
            { 0 => 'No attributes',   BITMASK => { 15 => 'Read only' } },
            '"Priority $val"',
        ],
    },
    0x0b => {
        Name => 'TimeZone',
        Groups => { 2 => 'Time' },
        RawConv => 'Get16s(\$val,0)',
        PrintConv => 'TimeZoneString($val)',
    },
    0x0c => {
        Name => 'ModifyDate',
        Groups => { 2 => 'Time' },
        # translate from format "YYYY/mm/dd HH:MM:SS"
        ValueConv => '$val=~tr{/}{:}; $val',
        PrintConv => '$self->ConvertDateTime($val)',
    },
);

# compressed movie atoms (ref http://wiki.multimedia.cx/index.php?title=QuickTime_container#cmov)
%Image::ExifTool::QuickTime::CMovie = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    dcom => 'Compression',
    # cmvd - compressed movie data
);

# Profile atoms (ref 11)
%Image::ExifTool::QuickTime::Profile = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    FPRF => {
        Name => 'FileGlobalProfile',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::FileProf' },
    },
    APRF => {
        Name => 'AudioProfile',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::AudioProf' },
    },
    VPRF => {
        Name => 'VideoProfile',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::VideoProf' },
    },
    OLYM => { #PH
        Name => 'OlympusOLYM',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Olympus::OLYM',
            ByteOrder => 'BigEndian',
        },
    },
);

# FPRF atom information (ref 11)
%Image::ExifTool::QuickTime::FileProf = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    FORMAT => 'int32u',
    0 => { Name => 'FileProfileVersion', Unknown => 1 }, # unknown = uninteresting
    1 => {
        Name => 'FileFunctionFlags',
        PrintConv => { BITMASK => {
            28 => 'Fragmented',
            29 => 'Additional tracks',
            30 => 'Edited', # (main AV track is edited)
        }},
    },
    # 2 - reserved
);

# APRF atom information (ref 11)
%Image::ExifTool::QuickTime::AudioProf = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Audio' },
    FORMAT => 'int32u',
    0 => { Name => 'AudioProfileVersion', Unknown => 1 },
    1 => 'AudioTrackID',
    2 => {
        Name => 'AudioCodec',
        Format => 'undef[4]',
    },
    3 => {
        Name => 'AudioCodecInfo',
        Unknown => 1,
        PrintConv => 'sprintf("0x%.4x", $val)',
    },
    4 => {
        Name => 'AudioAttributes',
        PrintConv => { BITMASK => {
            0 => 'Encrypted',
            1 => 'Variable bitrate',
            2 => 'Dual mono',
        }},
    },
    5 => {
        Name => 'AudioAvgBitrate',
        ValueConv => '$val * 1000',
        PrintConv => 'ConvertBitrate($val)',
    },
    6 => {
        Name => 'AudioMaxBitrate',
        ValueConv => '$val * 1000',
        PrintConv => 'ConvertBitrate($val)',
    },
    7 => 'AudioSampleRate',
    8 => 'AudioChannels',
);

# VPRF atom information (ref 11)
%Image::ExifTool::QuickTime::VideoProf = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    FORMAT => 'int32u',
    0 => { Name => 'VideoProfileVersion', Unknown => 1 },
    1 => 'VideoTrackID',
    2 => {
        Name => 'VideoCodec',
        Format => 'undef[4]',
    },
    3 => {
        Name => 'VideoCodecInfo',
        Unknown => 1,
        PrintConv => 'sprintf("0x%.4x", $val)',
    },
    4 => {
        Name => 'VideoAttributes',
        PrintConv => { BITMASK => {
            0 => 'Encrypted',
            1 => 'Variable bitrate',
            2 => 'Variable frame rate',
            3 => 'Interlaced',
        }},
    },
    5 => {
        Name => 'VideoAvgBitrate',
        ValueConv => '$val * 1000',
        PrintConv => 'ConvertBitrate($val)',
    },
    6 => {
        Name => 'VideoMaxBitrate',
        ValueConv => '$val * 1000',
        PrintConv => 'ConvertBitrate($val)',
    },
    7 => {
        Name => 'VideoAvgFrameRate',
        Format => 'fixed32u',
        PrintConv => 'int($val * 1000 + 0.5) / 1000',
    },
    8 => {
        Name => 'VideoMaxFrameRate',
        Format => 'fixed32u',
        PrintConv => 'int($val * 1000 + 0.5) / 1000',
    },
    9 => {
        Name => 'VideoSize',
        Format => 'int16u[2]',
        PrintConv => '$val=~tr/ /x/; $val',
    },
    10 => {
        Name => 'PixelAspectRatio',
        Format => 'int16u[2]',
        PrintConv => '$val=~tr/ /:/; $val',
    },
);

# meta atoms
%Image::ExifTool::QuickTime::Meta = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    ilst => {
        Name => 'ItemList',
        SubDirectory => {
            TagTable => 'Image::ExifTool::QuickTime::ItemList',
            HasData => 1, # process atoms as containers with 'data' elements
        },
    },
    # MP4 tags (ref 5)
    hdlr => {
        Name => 'Handler',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Handler' },
    },
    dinf => {
        Name => 'DataInformation',
        Flags => ['Binary','Unknown'],
    },
    ipmc => {
        Name => 'IPMPControl',
        Flags => ['Binary','Unknown'],
    },
    iloc => {
        Name => 'ItemLocation',
        Flags => ['Binary','Unknown'],
    },
    ipro => {
        Name => 'ItemProtection',
        Flags => ['Binary','Unknown'],
    },
    iinf => {
        Name => 'ItemInformation',
        Flags => ['Binary','Unknown'],
    },
   'xml ' => {
        Name => 'XML',
        SubDirectory => { TagTable => 'Image::ExifTool::XMP::Main' },
    },
   'keys' => {
        Name => 'Keys',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Keys' },
    },
    bxml => {
        Name => 'BinaryXML',
        Flags => ['Binary','Unknown'],
    },
    pitm => {
        Name => 'PrimaryItemReference',
        Flags => ['Binary','Unknown'],
    },
    free => { #PH
        Name => 'Free',
        Flags => ['Binary','Unknown'],
    },
);

# track reference atoms
%Image::ExifTool::QuickTime::TrackRef = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    chap => { Name => 'ChapterList', Format => 'int32u' },
    tmcd => { Name => 'TimeCode', Format => 'int32u' },
    # also: sync, scpt, ssrc, iTunesInfo
);

# track aperture mode dimensions atoms
# (ref https://developer.apple.com/library/mac/#documentation/QuickTime/QTFF/QTFFChap2/qtff2.html)
%Image::ExifTool::QuickTime::TrackAperture = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    clef => {
        Name => 'CleanApertureDimensions',
        Format => 'fixed32u',
        Count => 3,
        ValueConv => '$val =~ s/^.*? //; $val', # remove flags word
        PrintConv => '$val =~ tr/ /x/; $val',
    },
    prof => {
        Name => 'ProductionApertureDimensions',
        Format => 'fixed32u',
        Count => 3,
        ValueConv => '$val =~ s/^.*? //; $val',
        PrintConv => '$val =~ tr/ /x/; $val',
    },
    enof => {
        Name => 'EncodedPixelsDimensions',
        Format => 'fixed32u',
        Count => 3,
        ValueConv => '$val =~ s/^.*? //; $val',
        PrintConv => '$val =~ tr/ /x/; $val',
    },
);

# item list atoms
# -> these atoms are unique, and contain one or more 'data' atoms
%Image::ExifTool::QuickTime::ItemList = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Audio' },
    NOTES => q{
        As well as these tags, the 'mdta' handler uses numerical tag ID's which are
        added dynamically to this table after processing the Meta Keys information.
    },
    # in this table, binary 1 and 2-byte "data"-type tags are interpreted as
    # int8u and int16u.  Multi-byte binary "data" tags are extracted as binary data
    "\xa9ART" => 'Artist',
    "\xa9alb" => 'Album',
    "\xa9cmt" => 'Comment',
    "\xa9com" => 'Composer',
    "\xa9day" => { Name => 'Year', Groups => { 2 => 'Time' } },
    "\xa9des" => 'Description', #4
    "\xa9enc" => 'EncodedBy', #10
    "\xa9gen" => 'Genre',
    "\xa9grp" => 'Grouping',
    "\xa9lyr" => 'Lyrics',
    "\xa9nam" => 'Title',
    # "\xa9st3" ? #10
    "\xa9too" => 'Encoder',
    "\xa9trk" => 'Track',
    "\xa9wrt" => 'Composer',
    '----' => {
        Name => 'iTunesInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::iTunesInfo' },
    },
    aART => 'AlbumArtist',
    covr => 'CoverArt',
    cpil => { #10
        Name => 'Compilation',
        PrintConv => { 0 => 'No', 1 => 'Yes' },
    },
    disk => {
        Name => 'DiskNumber',
        Format => 'undef',  # (necessary to prevent decoding as string!)
        ValueConv => 'length($val) >= 6 ? join(" of ",unpack("x2nn",$val)) : \$val',
    },
    pgap => { #10
        Name => 'PlayGap',
        PrintConv => {
            0 => 'Insert Gap',
            1 => 'No Gap',
        },
    },
    tmpo => {
        Name => 'BeatsPerMinute',
        Format => 'int16u', # marked as boolean but really int16u in my sample
    },
    trkn => {
        Name => 'TrackNumber',
        Format => 'undef',  # (necessary to prevent decoding as string!)
        ValueConv => 'length($val) >= 6 ? join(" of ",unpack("x2nn",$val)) : \$val',
    },
#
# Note: it is possible that the tags below are not being decoded properly
# because I don't have samples to verify many of these - PH
#
    akID => { #10
        Name => 'AppleStoreAccountType',
        PrintConv => {
            0 => 'iTunes',
            1 => 'AOL',
        },
    },
    albm => 'Album', #(ffmpeg source)
    apID => 'AppleStoreAccount',
    atID => { #10 (or TV series)
        Name => 'AlbumTitleID',
        Format => 'int32u',
    },
    auth => { Name => 'Author', Groups => { 2 => 'Author' } },
    catg => 'Category', #7
    cnID => { #10
        Name => 'AppleStoreCatalogID',
        Format => 'int32u',
    },
    cprt => { Name => 'Copyright', Groups => { 2 => 'Author' } },
    dscp => 'Description',
    desc => 'Description', #7
    gnre => { #10
        Name => 'Genre',
        PrintConv => q{
            return $val unless $val =~ /^\d+$/;
            require Image::ExifTool::ID3;
            Image::ExifTool::ID3::PrintGenre($val - 1); # note the "- 1"
        },
    },
    egid => 'EpisodeGlobalUniqueID', #7
    geID => { #10
        Name => 'GenreID',
        Format => 'int32u',
        # 4005 = Kids
        # 4010 = Teens
    },
    grup => 'Grouping', #10
    hdvd => { #10
        Name => 'HDVideo',
        PrintConv => { 0 => 'No', 1 => 'Yes' },
    },
    keyw => 'Keyword', #7
    ldes => 'LongDescription', #10
    pcst => { #7
        Name => 'Podcast',
        PrintConv => { 0 => 'No', 1 => 'Yes' },
    },
    perf => 'Performer',
    plID => { #10 (or TV season)
        Name => 'PlayListID',
        Format => 'int8u',  # actually int64u, but split it up
    },
    purd => 'PurchaseDate', #7
    purl => 'PodcastURL', #7
    rtng => { #10
        Name => 'Rating',
        PrintConv => {
            0 => 'none',
            2 => 'Clean',
            4 => 'Explicit',
        },
    },
    sfID => { #10
        Name => 'AppleStoreCountry',
        Format => 'int32u',
        PrintConvColumns => 2,
        PrintConv => {
            143460 => 'Australia',
            143445 => 'Austria',
            143446 => 'Belgium',
            143455 => 'Canada',
            143458 => 'Denmark',
            143447 => 'Finland',
            143442 => 'France',
            143443 => 'Germany',
            143448 => 'Greece',
            143449 => 'Ireland',
            143450 => 'Italy',
            143462 => 'Japan',
            143451 => 'Luxembourg',
            143452 => 'Netherlands',
            143461 => 'New Zealand',
            143457 => 'Norway',
            143453 => 'Portugal',
            143454 => 'Spain',
            143456 => 'Sweden',
            143459 => 'Switzerland',
            143444 => 'United Kingdom',
            143441 => 'United States',
        },
    },
    soaa => 'SortAlbumArtist', #10
    soal => 'SortAlbum', #10
    soar => 'SortArtist', #10
    soco => 'SortComposer', #10
    sonm => 'SortName', #10
    sosn => 'SortShow', #10
    stik => { #10
        Name => 'MediaType',
        PrintConvColumns => 2,
        PrintConv => { #(http://weblog.xanga.com/gryphondwb/615474010/iphone-ringtones---what-did-itunes-741-really-do.html)
            0 => 'Movie',
            1 => 'Normal (Music)',
            2 => 'Audiobook',
            5 => 'Whacked Bookmark',
            6 => 'Music Video',
            9 => 'Short Film',
            10 => 'TV Show',
            11 => 'Booklet',
            14 => 'Ringtone',
            21 => 'Podcast', #15
        },
    },
    titl => 'Title',
    tven => 'TVEpisodeID', #7
    tves => { #7/10
        Name => 'TVEpisode',
        Format => 'int32u',
    },
    tvnn => 'TVNetworkName', #7
    tvsh => 'TVShow', #10
    tvsn => { #7/10
        Name => 'TVSeason',
        Format => 'int32u',
    },
    yrrc => 'Year', #(ffmpeg source)
    itnu => { #PH (iTunes 10.5)
        Name => 'iTunesU',
        Description => 'iTunes U',
        PrintConv => { 0 => 'No', 1 => 'Yes' },
    },
);

# item list keys (ref PH)
%Image::ExifTool::QuickTime::Keys = (
    PROCESS_PROC => \&Image::ExifTool::QuickTime::ProcessKeys,
    VARS => { LONG_TAGS => 1 },
    NOTES => q{
        This directory contains a list of key names which are used to decode
        ItemList tags written by the "mdta" handler.  The prefix of
        "com.apple.quicktime." has been removed from all TagID's below.
    },
    version     => 'Version',
    album       => 'Album',
    artist      => { },
    artwork     => { },
    author      => { Name => 'Author',      Groups => { 2 => 'Author' } },
    comment     => { },
    copyright   => { Name => 'Copyright',   Groups => { 2 => 'Author' } },
    creationdate=> {
        Name => 'CreationDate',
        Groups => { 2 => 'Time' },
        ValueConv => q{
            require Image::ExifTool::XMP;
            $val =  Image::ExifTool::XMP::ConvertXMPDate($val,1);
            $val =~ s/([-+]\d{2})(\d{2})$/$1:$2/; # add colon to timezone if necessary
            return $val;
        },
        PrintConv => '$self->ConvertDateTime($val)',
    },
    description => { },
    director    => { },
    genre       => { },
    information => { },
    keywords    => { },
    make        => { Name => 'Make',        Groups => { 2 => 'Camera' } },
    model       => { Name => 'Model',       Groups => { 2 => 'Camera' } },
    publisher   => { },
    software    => { },
    year        => { Groups => { 2 => 'Time' } },
    'camera.identifier' => 'CameraIdentifier', # (iPhone 4)
    'camera.framereadouttimeinmicroseconds' => { # (iPhone 4)
        Name => 'FrameReadoutTime',
        ValueConv => '$val * 1e-6',
        PrintConv => '$val * 1e6 . " microseconds"',
    },
    'location.ISO6709' => {
        Name => 'GPSCoordinates',
        Groups => { 2 => 'Location' },
        ValueConv => \&ConvertISO6709,
        PrintConv => \&PrintGPSCoordinates,
    },
    'location.name' => { Name => 'LocationName', Groups => { 2 => 'Location' } },
    'location.body' => { Name => 'LocationBody', Groups => { 2 => 'Location' } },
    'location.note' => { Name => 'LocationNote', Groups => { 2 => 'Location' } },
    'location.role' => {
        Name => 'LocationRole',
        Groups => { 2 => 'Location' },
        PrintConv => {
            0 => 'Shooting Location',
            1 => 'Real Location',
            2 => 'Fictional Location',
        },
    },
    'location.date' => {
        Name => 'LocationDate',
        Groups => { 2 => 'Time' },
        ValueConv => q{
            require Image::ExifTool::XMP;
            $val =  Image::ExifTool::XMP::ConvertXMPDate($val);
            $val =~ s/([-+]\d{2})(\d{2})$/$1:$2/; # add colon to timezone if necessary
            return $val;
        },
        PrintConv => '$self->ConvertDateTime($val)',
    },
    'direction.facing' => { Name => 'CameraDirection', Groups => { 2 => 'Location' } },
    'direction.motion' => { Name => 'CameraMotion', Groups => { 2 => 'Location' } },
    'location.body' => { Name => 'LocationBody', Groups => { 2 => 'Location' } },
    'player.version'                => 'PlayerVersion',
    'player.movie.visual.brightness'=> 'Brightness',
    'player.movie.visual.color'     => 'Color',
    'player.movie.visual.tint'      => 'Tint',
    'player.movie.visual.contrast'  => 'Contrast',
    'player.movie.audio.gain'       => 'AudioGain',
    'player.movie.audio.treble'     => 'Trebel',
    'player.movie.audio.bass'       => 'Bass',
    'player.movie.audio.balance'    => 'Balance',
    'player.movie.audio.pitchshift' => 'PitchShift',
    'player.movie.audio.mute' => {
        Name => 'Mute',
        Format => 'int8u',
        PrintConv => { 0 => 'Off', 1 => 'On' },
    },
    'rating.user'  => 'UserRating', # (Canon ELPH 510 HS)
    'Encoded_With' => 'EncodedWith',
);

# iTunes info ('----') atoms
%Image::ExifTool::QuickTime::iTunesInfo = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Audio' },
    NOTES => q{
        ExifTool will extract any iTunesInfo tags that exist, even if they are not
        defined in this table.
    },
    # 'mean'/'name'/'data' atoms form a triplet, but unfortunately
    # I haven't been able to find any documentation on this.
    # 'mean' is normally 'com.apple.iTunes'
    mean => {
        Name => 'Mean',
        # the 'Triplet' flag tells ProcessMOV() to generate
        # a single tag from the mean/name/data triplet
        Triplet => 1,
        Hidden => 1,
    },
    name => {
        Name => 'Name',
        Triplet => 1,
        Hidden => 1,
    },
    data => {
        Name => 'Data',
        Triplet => 1,
        Hidden => 1,
    },
    # the tag ID's below are composed from "mean/name",
    # but "mean/" is omitted if it is "com.apple.iTunes/":
    'iTunMOVI' => {
        Name => 'iTunMOVI',
        SubDirectory => { TagTable => 'Image::ExifTool::PLIST::Main' },
    },
    'tool' => {
        Name => 'iTunTool',
        Description => 'iTunTool',
        Format => 'int32u',
        PrintConv => 'sprintf("0x%.8x",$val)',
    },
    'iTunEXTC' => {
        Name => 'ContentRating',
        Notes => 'standard | rating | score | reasons',
        # ie. 'us-tv|TV-14|500|V', 'mpaa|PG-13|300|For violence and sexuality'
        # (see http://shadowofged.blogspot.ca/2008/06/itunes-content-ratings.html)
    },
    'iTunNORM' => {
        Name => 'VolumeNormalization',
        PrintConv => '$val=~s/ 0+(\w)/ $1/g; $val=~s/^\s+//; $val',
    },
    'iTunSMPB' => {
        Name => 'iTunSMPB',
        Description => 'iTunSMPB',
        # hex format, similar to iTunNORM, but 12 words instead of 10,
        # and 4th word is 16 hex digits (all others are 8)
        # (gives AAC encoder delay, ref http://code.google.com/p/l-smash/issues/detail?id=1)
        PrintConv => '$val=~s/ 0+(\w)/ $1/g; $val=~s/^\s+//; $val',
    },
    # (CDDB = Compact Disc DataBase)
    # iTunes_CDDB_1 = <CDDB1 disk ID>+<# tracks>+<logical block address for each track>...
    'iTunes_CDDB_1' => 'CDDB1Info',
    'iTunes_CDDB_TrackNumber' => 'CDDBTrackNumber',
    'Encoding Params' => {
        Name => 'EncodingParams',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::EncodingParams' },
    }
    # also heard about 'iTunPGAP', but I haven't seen a sample
);

# iTunes audio encoding parameters
# ref https://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioCodecServicesRef/Reference/reference.html
%Image::ExifTool::QuickTime::EncodingParams = (
    PROCESS_PROC => \&ProcessEncodingParams,
    GROUPS => { 2 => 'Audio' },
    # (I have commented out the ones that don't have integer values because they
    #  probably don't appear, and definitly wouldn't work with current decoding - PH)
    
    # global codec properties
    #'lnam' => 'AudioCodecName',
    #'lmak' => 'AudioCodecManufacturer',
    #'lfor' => 'AudioCodecFormat',
    'vpk?' => 'AudioHasVariablePacketByteSizes',
    #'ifm#' => 'AudioSupportedInputFormats',
    #'ofm#' => 'AudioSupportedOutputFormats',
    #'aisr' => 'AudioAvailableInputSampleRates',
    #'aosr' => 'AudioAvailableOutputSampleRates',
    'abrt' => 'AudioAvailableBitRateRange',
    'mnip' => 'AudioMinimumNumberInputPackets',
    'mnop' => 'AudioMinimumNumberOutputPackets',
    'cmnc' => 'AudioAvailableNumberChannels',
    'lmrc' => 'AudioDoesSampleRateConversion',
    #'aicl' => 'AudioAvailableInputChannelLayoutTags',
    #'aocl' => 'AudioAvailableOutputChannelLayoutTags',
    #'if4o' => 'AudioInputFormatsForOutputFormat',
    #'of4i' => 'AudioOutputFormatsForInputFormat',
    #'acfi' => 'AudioFormatInfo',

    # instance codec properties
    'tbuf' => 'AudioInputBufferSize',
    'pakf' => 'AudioPacketFrameSize',
    'pakb' => 'AudioMaximumPacketByteSize',
    #'ifmt' => 'AudioCurrentInputFormat',
    #'ofmt' => 'AudioCurrentOutputFormat',
    #'kuki' => 'AudioMagicCookie',
    'ubuf' => 'AudioUsedInputBufferSize',
    'init' => 'AudioIsInitialized',
    'brat' => 'AudioCurrentTargetBitRate',
    #'cisr' => 'AudioCurrentInputSampleRate',
    #'cosr' => 'AudioCurrentOutputSampleRate',
    'srcq' => 'AudioQualitySetting',
    #'brta' => 'AudioApplicableBitRateRange',
    #'isra' => 'AudioApplicableInputSampleRates',
    #'osra' => 'AudioApplicableOutputSampleRates',
    'pad0' => 'AudioZeroFramesPadded',
    'prmm' => 'AudioCodecPrimeMethod',
    #'prim' => 'AudioCodecPrimeInfo',
    #'icl ' => 'AudioInputChannelLayout',
    #'ocl ' => 'AudioOutputChannelLayout',
    #'acs ' => 'AudioCodecSettings',
    #'acfl' => 'AudioCodecFormatList',
    'acbf' => 'AudioBitRateControlMode',
    'vbrq' => 'AudioVBRQuality',
    'mdel' => 'AudioMinimumDelayMode',

    # deprecated
    'pakd' => 'AudioRequiresPacketDescription',
    #'brt#' => 'AudioAvailableBitRates',
    'acef' => 'AudioExtendFrequencies',
    'ursr' => 'AudioUseRecommendedSampleRate',
    'oppr' => 'AudioOutputPrecedence',
    #'loud' => 'AudioCurrentLoudnessStatistics',

    # others
    'vers' => 'AudioEncodingParamsVersion', #PH
    'cdcv' => { #PH
        Name => 'AudioComponentVersion',
        ValueConv => 'join ".", unpack("ncc", pack("N",$val))',
    },
);

# print to video data block
%Image::ExifTool::QuickTime::Video = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    0 => {
        Name => 'DisplaySize',
        PrintConv => {
            0 => 'Normal',
            1 => 'Double Size',
            2 => 'Half Size',
            3 => 'Full Screen',
            4 => 'Current Size',
        },
    },
    6 => {
        Name => 'SlideShow',
        PrintConv => {
            0 => 'No',
            1 => 'Yes',
        },
    },
);

# 'hnti' atoms
%Image::ExifTool::QuickTime::HintInfo = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    'rtp ' => {
        Name => 'RealtimeStreamingProtocol',
        PrintConv => '$val=~s/^sdp /(SDP) /; $val',
    },
    'sdp ' => 'StreamingDataProtocol',
);

# 'hinf' atoms
%Image::ExifTool::QuickTime::HintTrackInfo = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    trpY => { Name => 'TotalBytes', Format => 'int64u' }, #(documented)
    trpy => { Name => 'TotalBytes', Format => 'int64u' }, #(observed)
    totl => { Name => 'TotalBytes', Format => 'int32u' },
    nump => { Name => 'NumPackets', Format => 'int64u' },
    npck => { Name => 'NumPackets', Format => 'int32u' },
    tpyl => { Name => 'TotalBytesNoRTPHeaders', Format => 'int64u' },
    tpaY => { Name => 'TotalBytesNoRTPHeaders', Format => 'int32u' }, #(documented)
    tpay => { Name => 'TotalBytesNoRTPHeaders', Format => 'int32u' }, #(observed)
    maxr => {
        Name => 'MaxDataRate',
        Format => 'int32u',
        Count => 2,
        PrintConv => 'my @a=split(" ",$val);sprintf("%d bytes in %.3f s",$a[1],$a[0]/1000)',
    },
    dmed => { Name => 'MediaTrackBytes',    Format => 'int64u' },
    dimm => { Name => 'ImmediateDataBytes', Format => 'int64u' },
    drep => { Name => 'RepeatedDataBytes',  Format => 'int64u' },
    tmin => {
        Name => 'MinTransmissionTime',
        Format => 'int32u',
        PrintConv => 'sprintf("%.3f s",$val/1000)',
    },
    tmax => {
        Name => 'MaxTransmissionTime',
        Format => 'int32u',
        PrintConv => 'sprintf("%.3f s",$val/1000)',
    },
    pmax => { Name => 'LargestPacketSize',  Format => 'int32u' },
    dmax => {
        Name => 'LargestPacketDuration',
        Format => 'int32u',
        PrintConv => 'sprintf("%.3f s",$val/1000)',
    },
    payt => {
        Name => 'PayloadType',
        Format => 'undef',  # (necessary to prevent decoding as string!)
        ValueConv => 'unpack("N",$val) . " " . substr($val, 5)',
        PrintConv => '$val=~s/ /, /;$val',
    },
);

# MP4 media box (ref 5)
%Image::ExifTool::QuickTime::Media = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    NOTES => 'MP4 media box.',
    mdhd => {
        Name => 'MediaHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::MediaHeader' },
    },
    hdlr => {
        Name => 'Handler',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Handler' },
    },
    minf => {
        Name => 'MediaInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::MediaInfo' },
    },
);

# MP4 media header box (ref 5)
%Image::ExifTool::QuickTime::MediaHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    FORMAT => 'int32u',
    0 => {
        Name => 'MediaHeaderVersion',
        RawConv => '$$self{MediaHeaderVersion} = $val',
    },
    1 => {
        Name => 'MediaCreateDate',
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if MediaHeaderVersion == 1 (ref 5/13)
        Hook => '$$self{MediaHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    2 => {
        Name => 'MediaModifyDate',
        Groups => { 2 => 'Time' },
        %timeInfo,
        # this is int64u if MediaHeaderVersion == 1 (ref 5/13)
        Hook => '$$self{MediaHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    3 => {
        Name => 'MediaTimeScale',
        RawConv => '$$self{MediaTS} = $val',
    },
    4 => {
        Name => 'MediaDuration',
        RawConv => '$$self{MediaTS} ? $val / $$self{MediaTS} : $val',
        PrintConv => '$$self{MediaTS} ? ConvertDuration($val) : $val',
        # this is int64u if MediaHeaderVersion == 1 (ref 5/13)
        Hook => '$$self{MediaHeaderVersion} and $format = "int64u", $varSize += 4',
    },
    5 => {
        Name => 'MediaLanguageCode',
        Format => 'int16u',
        RawConv => '$val ? $val : undef',
        # allow both Macintosh (for MOV files) and ISO (for MP4 files) language codes
        ValueConv => '$val < 0x400 ? $val : pack "C*", map { (($val>>$_)&0x1f)+0x60 } 10, 5, 0',
        PrintConv => q{
            return $val unless $val =~ /^\d+$/;
            require Image::ExifTool::Font;
            return $Image::ExifTool::Font::ttLang{Macintosh}{$val} || "Unknown ($val)";
        },
    },
);

# MP4 media information box (ref 5)
%Image::ExifTool::QuickTime::MediaInfo = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    NOTES => 'MP4 media info box.',
    vmhd => {
        Name => 'VideoHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::VideoHeader' },
    },
    smhd => {
        Name => 'AudioHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::AudioHeader' },
    },
    hmhd => {
        Name => 'HintHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::HintHeader' },
    },
    nmhd => {
        Name => 'NullMediaHeader',
        Flags => ['Binary','Unknown'],
    },
    dinf => {
        Name => 'DataInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::DataInfo' },
    },
    gmhd => {
        Name => 'GenMediaHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::GenMediaHeader' },
    },
    hdlr => { #PH
        Name => 'Handler',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::Handler' },
    },
    stbl => {
        Name => 'SampleTable',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::SampleTable' },
    },
);

# MP4 video media header (ref 5)
%Image::ExifTool::QuickTime::VideoHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    NOTES => 'MP4 video media header.',
    FORMAT => 'int16u',
    2 => {
        Name => 'GraphicsMode',
        PrintHex => 1,
        SeparateTable => 'GraphicsMode',
        PrintConv => \%graphicsMode,
    },
    3 => { Name => 'OpColor', Format => 'int16u[3]' },
);

# MP4 audio media header (ref 5)
%Image::ExifTool::QuickTime::AudioHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Audio' },
    NOTES => 'MP4 audio media header.',
    FORMAT => 'int16u',
    2 => { Name => 'Balance', Format => 'fixed16s' },
);

# MP4 hint media header (ref 5)
%Image::ExifTool::QuickTime::HintHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    NOTES => 'MP4 hint media header.',
    FORMAT => 'int16u',
    2 => 'MaxPDUSize',
    3 => 'AvgPDUSize',
    4 => { Name => 'MaxBitrate', Format => 'int32u', PrintConv => 'ConvertBitrate($val)' },
    6 => { Name => 'AvgBitrate', Format => 'int32u', PrintConv => 'ConvertBitrate($val)' },
);

# MP4 sample table box (ref 5)
%Image::ExifTool::QuickTime::SampleTable = (
    PROCESS_PROC => \&ProcessMOV,
    GROUPS => { 2 => 'Video' },
    NOTES => 'MP4 sample table box.',
    stsd => [
        {
            Name => 'AudioSampleDesc',
            Condition => '$$self{HandlerType} and $$self{HandlerType} eq "soun"',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::AudioSampleDesc',
                Start => 8, # skip version number and count
            },
        },{
            Name => 'VideoSampleDesc',
            Condition => '$$self{HandlerType} and $$self{HandlerType} eq "vide"',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::ImageDesc',
                Start => 8, # skip version number and count
            },
        },{
            Name => 'HintSampleDesc',
            Condition => '$$self{HandlerType} and $$self{HandlerType} eq "hint"',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::HintSampleDesc',
                Start => 8, # skip version number and count
            },
        },{
            Name => 'OtherSampleDesc',
            SubDirectory => {
                TagTable => 'Image::ExifTool::QuickTime::OtherSampleDesc',
                Start => 8, # skip version number and count
            },
        },
        # (Note: "alis" HandlerType handled by the parent audio or video handler)
    ],
    stts => [ # decoding time-to-sample table
        {
            Name => 'VideoFrameRate',
            Notes => 'average rate calculated from time-to-sample table for video media',
            Condition => '$$self{HandlerType} and $$self{HandlerType} eq "vide"',
            Format => 'undef',  # (necessary to prevent decoding as string!)
            # (must be RawConv so appropriate MediaTS is used in calculation)
            RawConv => 'Image::ExifTool::QuickTime::CalcSampleRate($self, \$val)',
            PrintConv => 'int($val * 1000 + 0.5) / 1000',
        },
        {
            Name => 'TimeToSampleTable',
            Flags => ['Binary','Unknown'],
        },
    ],
    ctts => {
        Name => 'CompositionTimeToSample',
        Flags => ['Binary','Unknown'],
    },
    stsc => {
        Name => 'SampleToChunk',
        Flags => ['Binary','Unknown'],
    },
    stsz => {
        Name => 'SampleSizes',
        Flags => ['Binary','Unknown'],
    },
    stz2 => {
        Name => 'CompactSampleSizes',
        Flags => ['Binary','Unknown'],
    },
    stco => {
        Name => 'ChunkOffset',
        Flags => ['Binary','Unknown'],
    },
    co64 => {
        Name => 'ChunkOffset64',
        Flags => ['Binary','Unknown'],
    },
    stss => {
        Name => 'SyncSampleTable',
        Flags => ['Binary','Unknown'],
    },
    stsh => {
        Name => 'ShadowSyncSampleTable',
        Flags => ['Binary','Unknown'],
    },
    padb => {
        Name => 'SamplePaddingBits',
        Flags => ['Binary','Unknown'],
    },
    stdp => {
        Name => 'SampleDegradationPriority',
        Flags => ['Binary','Unknown'],
    },
    sdtp => {
        Name => 'IdependentAndDisposableSamples',
        Flags => ['Binary','Unknown'],
    },
    sbgp => {
        Name => 'SampleToGroup',
        Flags => ['Binary','Unknown'],
    },
    sgpd => {
        Name => 'SampleGroupDescription',
        Flags => ['Binary','Unknown'],
    },
    subs => {
        Name => 'Sub-sampleInformation',
        Flags => ['Binary','Unknown'],
    },
    cslg => {
        Name => 'CompositionToDecodeTimelineMapping',
        Flags => ['Binary','Unknown'],
    },
);

# MP4 audio sample description box (ref 5)
%Image::ExifTool::QuickTime::AudioSampleDesc = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Audio' },
    FORMAT => 'int16u',
    NOTES => 'MP4 audio sample description.',
    2  => {
        Name => 'AudioFormat',
        Format => 'undef[4]',
        RawConv => q{
            return undef unless $val =~ /^[\w ]{4}$/i;
            # check for protected audio format
            $self->OverrideFileType('M4P') if $val eq 'drms' and $$self{VALUE}{FileType} eq 'M4A';
            return $val;
        },
    },
    10 => { #PH
        Name => 'AudioVendorID',
        Format => 'undef[4]',
        RawConv => '$val eq "\0\0\0\0" ? undef : $val',
        PrintConv => \%vendorID,
        SeparateTable => 'VendorID',
    },
    12 => 'AudioChannels',
    13 => 'AudioBitsPerSample',
    16 => { Name => 'AudioSampleRate', Format => 'fixed32u' },
    28 => { #PH
        Name => 'AudioFormat',
        Format => 'undef[4]',
        RawConv => '$val =~ /^[\w ]{4}$/i ? $val : undef',
        Notes => 'in Casio MOV videos',
    },
);

# MP4 hint sample description box (ref 5)
%Image::ExifTool::QuickTime::HintSampleDesc = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FORMAT => 'int16u',
    NOTES => 'MP4 hint sample description.',
    2 => { Name => 'HintFormat', Format => 'undef[4]' },
);

# MP4 generic sample description box
%Image::ExifTool::QuickTime::OtherSampleDesc = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FORMAT => 'int16u',
    2 => { Name => 'OtherFormat', Format => 'undef[4]' },
);

# MP4 data information box (ref 5)
%Image::ExifTool::QuickTime::DataInfo = (
    PROCESS_PROC => \&ProcessMOV,
    NOTES => 'MP4 data information box.',
    dref => {
        Name => 'DataRef',
        SubDirectory => {
            TagTable => 'Image::ExifTool::QuickTime::DataRef',
            Start => 8,
        },
    },
);

# Generic media header
%Image::ExifTool::QuickTime::GenMediaHeader = (
    PROCESS_PROC => \&ProcessMOV,
    gmin => {
        Name => 'GenMediaInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::GenMediaInfo' },
    },
    text => {
        Name => 'Text',
        Flags => ['Binary','Unknown'],
    },
    tmcd => {
        Name => 'TimeCode',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::TimeCode' },
    },
);

# TimeCode header
%Image::ExifTool::QuickTime::TimeCode = (
    PROCESS_PROC => \&ProcessMOV,
    tcmi => {
        Name => 'TCMediaInfo',
        SubDirectory => { TagTable => 'Image::ExifTool::QuickTime::TCMediaInfo' },
    },
);

# TimeCode media info (ref 12)
%Image::ExifTool::QuickTime::TCMediaInfo = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    4 => {
        Name => 'TextFont',
        Format => 'int16u',
        PrintConv => { 0 => 'System' },
    },
    6 => {
        Name => 'TextFace',
        Format => 'int16u',
        PrintConv => { 
            0 => 'Plain',
            BITMASK => {
                0 => 'Bold',
                1 => 'Italic',
                2 => 'Underline',
                3 => 'Outline',
                4 => 'Shadow',
                5 => 'Condense',
                6 => 'Extend',
            },
        },
    },
    8 => {
        Name => 'TextSize',
        Format => 'int16u',
    },
    10 => {
        Name => 'TextColor',
        Format => 'int16u[3]',
    },
    16 => {
        Name => 'BackgroundColor',
        Format => 'int16u[3]',
    },
    22 => {
        Name => 'FontName',
        Format => 'pstring',
        ValueConv => '$self->Decode($val, $self->Options("CharsetQuickTime"))',
    },
);

# Generic media info (ref http://sourceforge.jp/cvs/view/ntvrec/ntvrec/libqtime/gmin.h?view=co)
%Image::ExifTool::QuickTime::GenMediaInfo = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    0  => 'GenMediaVersion',
    1  => { Name => 'GenFlags',   Format => 'int8u[3]' },
    4  => { Name => 'GenGraphicsMode',
        Format => 'int16u',
        PrintHex => 1,
        SeparateTable => 'GraphicsMode',
        PrintConv => \%graphicsMode,
    },
    6  => { Name => 'GenOpColor', Format => 'int16u[3]' },
    12 => { Name => 'GenBalance', Format => 'fixed16s' },
);

# MP4 data reference box (ref 5)
%Image::ExifTool::QuickTime::DataRef = (
    PROCESS_PROC => \&ProcessMOV,
    NOTES => 'MP4 data reference box.',
    'url ' => {
        Name => 'URL',
        Format => 'undef',  # (necessary to prevent decoding as string!)
        RawConv => q{
            # ignore if self-contained (flags bit 0 set)
            return undef if unpack("N",$val) & 0x01;
            $_ = substr($val,4); s/\0.*//s; $_;
        },
    },
    'urn ' => {
        Name => 'URN',
        Format => 'undef',  # (necessary to prevent decoding as string!)
        RawConv => q{
            return undef if unpack("N",$val) & 0x01;
            $_ = substr($val,4); s/\0.*//s; $_;
        },
    },
);

# MP4 handler box (ref 5)
%Image::ExifTool::QuickTime::Handler = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Video' },
    4 => { #PH
        Name => 'HandlerClass',
        Format => 'undef[4]',
        RawConv => '$val eq "\0\0\0\0" ? undef : $val',
        PrintConv => {
            mhlr => 'Media Handler',
            dhlr => 'Data Handler',
        },
    },
    8 => {
        Name => 'HandlerType',
        Format => 'undef[4]',
        RawConv => '$$self{HandlerType} = $val unless $val eq "alis"; $val',
        PrintConvColumns => 2,
        PrintConv => {
            alis => 'Alias Data', #PH
            crsm => 'Clock Reference', #3
            hint => 'Hint Track',
            ipsm => 'IPMP', #3
            m7sm => 'MPEG-7 Stream', #3
            mdir => 'Metadata', #3
            mdta => 'Metadata Tags', #PH
            mjsm => 'MPEG-J', #3
            ocsm => 'Object Content', #3
            odsm => 'Object Descriptor', #3
            sdsm => 'Scene Description', #3
            soun => 'Audio Track',
            text => 'Text', #PH (but what type? subtitle?)
            tmcd => 'Time Code', #PH
           'url '=> 'URL', #3
            vide => 'Video Track',
        },
    },
    12 => { #PH
        Name => 'HandlerVendorID',
        Format => 'undef[4]',
        RawConv => '$val eq "\0\0\0\0" ? undef : $val',
        PrintConv => \%vendorID,
        SeparateTable => 'VendorID',
    },
    24 => {
        Name => 'HandlerDescription',
        Format => 'string',
        # (sometimes this is a Pascal string, and sometimes it is a C string)
        RawConv => q{
            $val=substr($val,1,ord($1)) if $val=~/^([\0-\x1f])/ and ord($1)<length($val);
            length $val ? $val : undef;
        },
    },
);

# Flip uuid data (ref PH)
%Image::ExifTool::QuickTime::Flip = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    FORMAT => 'int32u',
    FIRST_ENTRY => 0,
    NOTES => 'Found in MP4 files from Flip Video cameras.',
    GROUPS => { 1 => 'MakerNotes', 2 => 'Image' },
    1 => 'PreviewImageWidth',
    2 => 'PreviewImageHeight',
    13 => 'PreviewImageLength',
    14 => { # (confirmed for FlipVideoMinoHD)
        Name => 'SerialNumber',
        Groups => { 2 => 'Camera' },
        Format => 'string[16]',
    },
    28 => {
        Name => 'PreviewImage',
        Format => 'undef[$val{13}]',
        RawConv => '$self->ValidateImage(\$val, $tag)',
    },
);

# QuickTime composite tags
%Image::ExifTool::QuickTime::Composite = (
    GROUPS => { 2 => 'Video' },
    Rotation => {
        Require => {
            0 => 'QuickTime:MatrixStructure',
            1 => 'QuickTime:HandlerType',
        },
        ValueConv => 'Image::ExifTool::QuickTime::CalcRotation($self)',
    },
    AvgBitrate => {
        Priority => 0,  # let QuickTime::AvgBitrate take priority
        Require => {
            0 => 'QuickTime::MovieDataSize',
            1 => 'QuickTime::Duration',
        },
        RawConv => q{
            return undef unless $val[1];
            $val[1] /= $$self{TimeScale} if $$self{TimeScale};
            my $key = 'MovieDataSize';
            my $size = $val[0];
            for (;;) {
                $key = $self->NextTagKey($key) or last;
                $size += $self->GetValue($key);
            }
            return int($size * 8 / $val[1] + 0.5);
        },
        PrintConv => 'ConvertBitrate($val)',
    },
    GPSLatitude => {
        Require => 'QuickTime:GPSCoordinates',
        Groups => { 2 => 'Location' },
        ValueConv => 'my @c = split " ", $val; $c[0]',
        PrintConv => q{
            require Image::ExifTool::GPS;
            Image::ExifTool::GPS::ToDMS($self, $val, 1, 'N');
        },
    },
    GPSLongitude => {
        Require => 'QuickTime:GPSCoordinates',
        Groups => { 2 => 'Location' },
        ValueConv => 'my @c = split " ", $val; $c[1]',
        PrintConv => q{
            require Image::ExifTool::GPS;
            Image::ExifTool::GPS::ToDMS($self, $val, 1, 'E');
        },
    },
    # split altitude into GPSAltitude/GPSAltitudeRef like EXIF and XMP
    GPSAltitude => {
        Require => 'QuickTime:GPSCoordinates',
        Groups => { 2 => 'Location' },
        Priority => 0, # (because it may not exist)
        ValueConv => 'my @c = split " ", $val; defined $c[2] ? abs($c[2]) : undef',
        PrintConv => '"$val m"',
    },
    GPSAltitudeRef  => {
        Require => 'QuickTime:GPSCoordinates',
        Groups => { 2 => 'Location' },
        Priority => 0, # (because altitude information may not exist)
        ValueConv => 'my @c = split " ", $val; defined $c[2] ? ($c[2] < 0 ? 1 : 0) : undef',
        PrintConv => {
            0 => 'Above Sea Level',
            1 => 'Below Sea Level',
        },
    },
    GPSLatitude2 => {
        Name => 'GPSLatitude',
        Require => 'QuickTime:LocationInformation',
        Groups => { 2 => 'Location' },
        ValueConv => '$val =~ /Lat=([-+.\d]+)/; abs($1)',
        PrintConv => q{
            require Image::ExifTool::GPS;
            Image::ExifTool::GPS::ToDMS($self, $val, 1, 'N');
        },
    },
    GPSLongitude2 => {
        Name => 'GPSLongitude',
        Require => 'QuickTime:LocationInformation',
        Groups => { 2 => 'Location' },
        ValueConv => '$val =~ /Lon=([-+.\d]+)/; abs($1)',
        PrintConv => q{
            require Image::ExifTool::GPS;
            Image::ExifTool::GPS::ToDMS($self, $val, 1, 'E');
        },
    },
    GPSAltitude2 => {
        Name => 'GPSAltitude',
        Require => 'QuickTime:LocationInformation',
        Groups => { 2 => 'Location' },
        ValueConv => '$val =~ /Alt=([-+.\d]+)/; abs($1)',
        PrintConv => '"$val m"',
    },
    GPSAltitudeRef2  => {
        Name => 'GPSAltitudeRef',
        Require => 'QuickTime:LocationInformation',
        Groups => { 2 => 'Location' },
        ValueConv => '$val =~ /Alt=([-+.\d]+)/; $1 < 0 ? 1 : 0',
        PrintConv => {
            0 => 'Above Sea Level',
            1 => 'Below Sea Level',
        },
    },
    CDDBDiscPlayTime => {
        Require => 'CDDB1Info',
        Groups => { 2 => 'Audio' },
        ValueConv => '$val =~ /^..([a-z0-9]{4})/i ? hex($1) : undef',
        PrintConv => 'ConvertDuration($val)',
    },
    CDDBDiscTracks => {
        Require => 'CDDB1Info',
        Groups => { 2 => 'Audio' },
        ValueConv => '$val =~ /^.{6}([a-z0-9]{2})/i ? hex($1) : undef',
    },
);

# add our composite tags
Image::ExifTool::AddCompositeTags('Image::ExifTool::QuickTime');


#------------------------------------------------------------------------------
# Calculate rotation of video track
# Inputs: 0) ExifTool object ref
# Returns: rotation angle or undef
sub CalcRotation($)
{
    my $exifTool = shift;
    my $value = $$exifTool{VALUE};
    my ($i, $track);
    # get the video track family 1 group (ie. "Track1");
    for ($i=0; ; ++$i) {
        my $idx = $i ? " ($i)" : '';
        my $tag = "HandlerType$idx";
        last unless $$value{$tag};
        next unless $$value{$tag} eq 'vide';
        $track = $exifTool->GetGroup($tag, 1);
        last;
    }
    return undef unless $track;
    # get the video track matrix
    for ($i=0; ; ++$i) {
        my $idx = $i ? " ($i)" : '';
        my $tag = "MatrixStructure$idx";
        last unless $$value{$tag};
        next unless $exifTool->GetGroup($tag, 1) eq $track;
        my @a = split ' ', $$value{$tag};
        return undef unless $a[0] or $a[1];
        # calculate the rotation angle (assume uniform rotation)
        my $angle = atan2($a[1], $a[0]) * 180 / 3.14159;
        $angle += 360 if $angle < 0;
        return int($angle * 1000 + 0.5) / 1000;
    }
    return undef;
}

#------------------------------------------------------------------------------
# Determine the average sample rate from a time-to-sample table
# Inputs: 0) ExifTool object ref, 1) time-to-sample table data ref
# Returns: average sample rate (in Hz)
sub CalcSampleRate($$)
{
    my ($exifTool, $valPt) = @_;
    my @dat = unpack('N*', $$valPt);
    my ($num, $dur) = (0, 0);
    my $i;
    for ($i=2; $i<@dat-1; $i+=2) {
        $num += $dat[$i];               # total number of samples
        $dur += $dat[$i] * $dat[$i+1];  # total sample duration
    }
    return undef unless $num and $dur and $$exifTool{MediaTS};
    return $num * $$exifTool{MediaTS} / $dur;
}

#------------------------------------------------------------------------------
# Fix incorrect format for ImageWidth/Height as written by Pentax
sub FixWrongFormat($)
{
    my $val = shift;
    return undef unless $val;
    if ($val & 0xffff0000) {
        $val = unpack('n',pack('N',$val));
    }
    return $val;
}

#------------------------------------------------------------------------------
# Convert ISO 6709 string to standard lag/lon format
# Inputs: 0) ISO 6709 string (lat, lon, and optional alt)
# Returns: position in decimal degress with altitude if available
# Notes: Wikipedia indicates altitude may be in feet -- how is this specified?
sub ConvertISO6709($)
{
    my $val = shift;
    if ($val =~ /^([-+]\d{2}(?:\.\d*)?)([-+]\d{3}(?:\.\d*)?)([-+]\d+)?/) {
        $val = ($1 + 0) . ' ' . ($2 + 0);
        $val .= ' ' . ($3 + 0) if $3;
    } elsif ($val =~ /^([-+])(\d{2})(\d{2}(?:\.\d*)?)([-+])(\d{3})(\d{2}(?:\.\d*)?)([-+]\d+)?/) {
        my $lat = $2 + $3 / 60;
        $lat = -$lat if $1 eq '-';
        my $lon = $5 + $6 / 60;
        $lon = -$lon if $4 eq '-';
        $val = "$lat $lon";
        $val .= ' ' . ($7 + 0) if $7;
    } elsif ($val =~ /^([-+])(\d{2})(\d{2})(\d{2}(?:\.\d*)?)([-+])(\d{3})(\d{2})(\d{2}(?:\.\d*)?)([-+]\d+)?/) {
        my $lat = $2 + $3 / 60 + $4 / 3600;
        $lat = -$lat if $1 eq '-';
        my $lon = $6 + $7 / 60 + $8 / 3600;
        $lon = -$lon if $5 eq '-';
        $val = "$lat $lon";
        $val .= ' ' . ($9 + 0) if $9;
    }
    return $val;
}

#------------------------------------------------------------------------------
# Format GPSCoordinates for printing
# Inputs: 0) string with numerical lat, lon and optional alt, separated by spaces
#         1) ExifTool object reference
# Returns: PrintConv value
sub PrintGPSCoordinates($)
{
    my ($val, $exifTool) = @_;
    require Image::ExifTool::GPS;
    my @v = split ' ', $val;
    my $prt = Image::ExifTool::GPS::ToDMS($exifTool, $v[0], 1, "N") . ', ' .
              Image::ExifTool::GPS::ToDMS($exifTool, $v[1], 1, "E");
    if (defined $v[2]) {
        $prt .= ', ' . ($v[2] < 0 ? -$v[2] . ' m Below' : $v[2] . ' m Above') . ' Sea Level';
    }
    return $prt;
}

#------------------------------------------------------------------------------
# Unpack packed ISO 639/T language code
# Inputs: 0) packed language code (or undef)
# Returns: language code, or undef for default language, or 'err' for format error
sub UnpackLang($)
{
    my $lang = shift;
    if ($lang) {
        # language code is packed in 5-bit characters
        $lang = pack "C*", map { (($lang>>$_)&0x1f)+0x60 } 10, 5, 0;
        # validate language code
        if ($lang =~ /^[a-z]+$/) {
            # treat 'eng' or 'und' as the default language
            undef $lang if $lang eq 'und' or $lang eq 'eng';
        } else {
            $lang = 'err';  # invalid language code
        }
    }
    return $lang;
}

#------------------------------------------------------------------------------
# Process MPEG-4 MTDT atom (ref 11)
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessMetaData($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirLen = length $$dataPt;
    my $verbose = $exifTool->Options('Verbose');
    return 0 unless $dirLen >= 2;
    my $count = Get16u($dataPt, 0);
    $verbose and $exifTool->VerboseDir('MetaData', $count);
    my $i;
    my $pos = 2;
    for ($i=0; $i<$count; ++$i) {
        last if $pos + 10 > $dirLen;
        my $size = Get16u($dataPt, $pos);
        last if $size < 10 or $size + $pos > $dirLen;
        my $tag  = Get32u($dataPt, $pos + 2);
        my $lang = Get16u($dataPt, $pos + 6);
        my $enc  = Get16u($dataPt, $pos + 8);
        my $val  = substr($$dataPt, $pos + 10, $size);
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
        if ($tagInfo) {
            # convert language code to ASCII (ignore read-only bit)
            $lang = UnpackLang($lang);
            # handle alternate languages
            if ($lang) {
                my $langInfo = Image::ExifTool::GetLangInfo($tagInfo, $lang);
                $tagInfo = $langInfo if $langInfo;
            }
            $verbose and $exifTool->VerboseInfo($tag, $tagInfo,
                Value  => $val,
                DataPt => $dataPt,
                Start  => $pos + 10,
                Size   => $size - 10,
            );
            # convert from UTF-16 BE if necessary
            $val = $exifTool->Decode($val, 'UCS2') if $enc == 1;
            if ($enc == 0 and $$tagInfo{Unknown}) {
                # binary data
                $exifTool->FoundTag($tagInfo, \$val);
            } else {
                $exifTool->FoundTag($tagInfo, $val);
            }
        }
        $pos += $size;
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process iTunes Encoding Params (ref PH)
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessEncodingParams($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirLen = length $$dataPt;
    my $pos;
    $exifTool->VerboseDir('Encoding Params', $dirLen / 8);
    for ($pos = 0; $pos + 8 <= $dirLen; $pos += 8) {
        my ($tag, $val) = unpack("x${pos}a4N", $$dataPt);
        $exifTool->HandleTag($tagTablePtr, $tag, $val);
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process Meta keys and add tags to the ItemList table ('mdta' handler) (ref PH)
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessKeys($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirLen = length $$dataPt;
    my $out;
    if ($exifTool->Options('Verbose')) {
        $exifTool->VerboseDir('Keys');
        $out = $exifTool->Options('TextOut');
    }
    my $pos = 8;
    my $index = 1;
    my $infoTable = GetTagTable('Image::ExifTool::QuickTime::ItemList');
    my $userTable = GetTagTable('Image::ExifTool::QuickTime::UserData');
    while ($pos < $dirLen - 4) {
        my $len = unpack("x${pos}N", $$dataPt);
        last if $len < 8 or $pos + $len > $dirLen;
        delete $$tagTablePtr{$index};
        my $ns  = substr($$dataPt, $pos + 4, 4);
        my $tag = substr($$dataPt, $pos + 8, $len - 8);
        $tag =~ s/\0.*//s; # truncate at null
        if ($ns eq 'mdta') {
            $tag =~ s/^com\.apple\.quicktime\.//;   # remove common apple quicktime domain
        }
        next unless $tag;
        # (I have some samples where the tag is a reversed ItemList or UserData tag ID)
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
        unless ($tagInfo) {
            $tagInfo = $exifTool->GetTagInfo($infoTable, $tag);
            unless ($tagInfo) {
                $tagInfo = $exifTool->GetTagInfo($userTable, $tag);
                if (not $tagInfo and $tag =~ /^\w{3}\xa9$/) {
                    $tag = pack('N', unpack('V', $tag));
                    $tagInfo = $exifTool->GetTagInfo($infoTable, $tag);
                    $tagInfo or $tagInfo = $exifTool->GetTagInfo($userTable, $tag);
                }
            }
        }
        my ($newInfo, $msg);
        if ($tagInfo) {
            $newInfo = {
                Name      => $$tagInfo{Name},
                Format    => $$tagInfo{Format},
                ValueConv => $$tagInfo{ValueConv},
                PrintConv => $$tagInfo{PrintConv},
            };
            my $groups = $$tagInfo{Groups};
            $$newInfo{Groups} = { %$groups } if $groups;
        } elsif ($tag =~ /^[-\w.]+$/) {
            # create info for tags with reasonable id's
            my $name = $tag;
            $name =~ s/\.(.)/\U$1/g;
            $newInfo = { Name => ucfirst($name) };
            $msg = ' (Unknown)';
        }
        # substitute this tag in the ItemList table with the given index
        delete $$infoTable{$index};
        if ($newInfo) {
            $msg or $msg = '';
            AddTagToTable($infoTable, $index, $newInfo);
            $out and printf $out "%sAdded ItemList Tag 0x%.4x = $tag$msg\n", $exifTool->{INDENT}, $index;
        }
        $pos += $len;
        ++$index;
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process a QuickTime atom
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) optional tag table ref
# Returns: 1 on success
sub ProcessMOV($$;$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $raf = $$dirInfo{RAF};
    my $dataPt = $$dirInfo{DataPt};
    my $verbose = $exifTool->Options('Verbose');
    my $dataPos = $$dirInfo{Base} || 0;
    my $charsetQuickTime = $exifTool->Options('CharsetQuickTime');
    my ($buff, $tag, $size, $track, $isUserData, %triplet);

    # more convenient to package data as a RandomAccess file
    $raf or $raf = new File::RandomAccess($dataPt);
    # skip leading bytes if necessary
    if ($$dirInfo{DirStart}) {
        $raf->Seek($$dirInfo{DirStart}, 1) or return 0;
        $dataPos += $$dirInfo{DirStart};
    }
    # read size/tag name atom header
    $raf->Read($buff,8) == 8 or return 0;
    $dataPos += 8;
    if ($tagTablePtr) {
        $isUserData = ($tagTablePtr eq \%Image::ExifTool::QuickTime::UserData);
    } else {
        $tagTablePtr = GetTagTable('Image::ExifTool::QuickTime::Main');
    }
    ($size, $tag) = unpack('Na4', $buff);
    if ($dataPt) {
        $verbose and $exifTool->VerboseDir($$dirInfo{DirName});
    } else {
        # check on file type if called with a RAF
        $$tagTablePtr{$tag} or return 0;
        if ($tag eq 'ftyp') {
            # read ahead 4 bytes to see what type of file this is
            my $fileType;
            if ($raf->Read($buff, 4) == 4) {
                $raf->Seek(-4, 1);
                # see if we know the extension for this file type
                $fileType = $1 if $ftypLookup{$buff} and $ftypLookup{$buff} =~ /\(\.(\w+)/;
            }
            $fileType or $fileType = 'MP4'; # default to MP4
            $exifTool->SetFileType($fileType, $mimeLookup{$fileType} || 'video/mp4');
        } else {
            $exifTool->SetFileType();       # MOV
        }
        SetByteOrder('MM');
    }
    for (;;) {
        if ($size < 8) {
            last if $size == 0;
            $size == 1 or $exifTool->Warn('Invalid atom size'), last;
            $raf->Read($buff, 8) == 8 or last;
            $dataPos += 8;
            my ($hi, $lo) = unpack('NN', $buff);
            $size = $lo;
            if ($hi or $lo > 0x7fffffff) {
                if ($hi > 0x7fffffff) {
                    $exifTool->Warn('Invalid atom size');
                    last;
                } elsif (not $exifTool->Options('LargeFileSupport')) {
                    $exifTool->Warn('End of processing at large atom (LargeFileSupport not enabled)');
                    last;
                }
            }
            $size = $hi * 4294967296 + $lo - 8;
            $size < 8 and $exifTool->Warn('Invalid extended size'), last;
        }
        $size -= 8;
        if ($isUserData and $$exifTool{SET_GROUP1}) {
            my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
            # add track name to UserData tags inside tracks
            $tag = $$exifTool{SET_GROUP1} . $tag;
            if (not $$tagTablePtr{$tag} and $tagInfo) {
                my %newInfo = %$tagInfo;
                foreach ('Name', 'Description') {
                    $newInfo{$_} = $$exifTool{SET_GROUP1} . $$tagInfo{$_} if $$tagInfo{$_};
                }
                AddTagToTable($tagTablePtr, $tag, \%newInfo);
            }
        }
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag);
        # allow numerical tag ID's
        unless ($tagInfo) {
            my $num = unpack('N', $tag);
            if ($$tagTablePtr{$num}) {
                $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $num);
                $tag = $num;
            }
        }
        # generate tagInfo if Unknown option set
        if (not defined $tagInfo and ($exifTool->{OPTIONS}->{Unknown} or
            $verbose or $tag =~ /^\xa9/))
        {
            my $name = $tag;
            my $n = ($name =~ s/([\x00-\x1f\x7f-\xff])/'x'.unpack('H*',$1)/eg);
            # print in hex if tag is numerical
            $name = sprintf('0x%.4x',unpack('N',$tag)) if $n > 2;
            if ($name =~ /^xa9(.*)/) {
                $tagInfo = {
                    Name => "UserData_$1",
                    Description => "User Data $1",
                };
            } else {
                $tagInfo = {
                    Name => "Unknown_$name",
                    Description => "Unknown $name",
                    Unknown => 1,
                    Binary => 1,
                };
            }
            AddTagToTable($tagTablePtr, $tag, $tagInfo);
        }
        # save required tag sizes
        $exifTool->HandleTag($tagTablePtr, "$tag-size", $size) if $$tagTablePtr{"$tag-size"};
        # load values only if associated with a tag (or verbose) and < 16MB long
        if ((defined $tagInfo or $verbose) and $size < 0x1000000) {
            my $val;
            unless ($raf->Read($val, $size) == $size) {
                $exifTool->Warn("Truncated '$tag' data");
                last;
            }
            # use value to get tag info if necessary
            $tagInfo or $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag, \$val);
            my $hasData = ($$dirInfo{HasData} and $val =~ /\0...data\0/s);
            if ($verbose and not $hasData) {
                my $tval;
                if ($tagInfo and $$tagInfo{Format}) {
                    $tval =  ReadValue(\$val, 0, $$tagInfo{Format}, $$tagInfo{Count}, length($val));
                }
                $exifTool->VerboseInfo($tag, $tagInfo,
                    Value   => $tval,
                    DataPt  => \$val,
                    DataPos => $dataPos,
                    Size    => $size,
                    Format  => $tagInfo ? $$tagInfo{Format} : undef,
                );
            }
            # handle iTunesInfo mean/name/data triplets
            if ($tagInfo and $$tagInfo{Triplet}) {
                if ($tag eq 'data' and $triplet{mean} and $triplet{name}) {
                    $tag = $triplet{name};
                    # add 'mean' to name unless it is 'com.apple.iTunes'
                    $tag = $triplet{mean} . '/' . $tag unless $triplet{mean} eq 'com.apple.iTunes';
                    $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag, \$val);
                    unless ($tagInfo) {
                        my $name = $triplet{name};
                        my $desc = $name;
                        $name =~ tr/-_a-zA-Z0-9//dc;
                        $desc =~ tr/_/ /;
                        $tagInfo = {
                            Name => $name,
                            Description => $desc,
                        };
                        AddTagToTable($tagTablePtr, $tag, $tagInfo);
                    }
                    # ignore 8-byte header
                    $val = substr($val, 8) if length($val) >= 8;
                    unless ($$tagInfo{Format} or $$tagInfo{SubDirectory}) {
                        # extract as binary if it contains any non-ASCII or control characters
                        if ($val =~ /[^\x20-\x7e]/) {
                            my $buff = $val;
                            $val = \$buff;
                        }
                    }
                    undef %triplet;
                } else {
                    undef %triplet if $tag eq 'mean';
                    $triplet{$tag} = substr($val,4) if length($val) > 4;
                    undef $tagInfo;  # don't store this tag
                }
            }
            if ($tagInfo) {
                my $subdir = $$tagInfo{SubDirectory};
                if ($subdir) {
                    my $start = $$subdir{Start} || 0;
                    my ($base, $dPos) = ($dataPos, 0);
                    if ($$subdir{Base}) {
                        $dPos -= eval $$subdir{Base};
                        $base -= $dPos;
                    }
                    my %dirInfo = (
                        DataPt   => \$val,
                        DataLen  => $size,
                        DirStart => $start,
                        DirLen   => $size - $start,
                        DirName  => $$subdir{DirName} || $$tagInfo{Name},
                        HasData  => $$subdir{HasData},
                        Multi    => $$subdir{Multi},
                        DataPos  => $dPos,
                        # Base needed for IsOffset tags in binary data
                        Base     => $base,
                    );
                    if ($$subdir{ByteOrder} and $$subdir{ByteOrder} =~ /^Little/) {
                        SetByteOrder('II');
                    }
                    my $oldGroup1 = $exifTool->{SET_GROUP1};
                    if ($$tagInfo{Name} eq 'Track') {
                        $track or $track = 0;
                        $exifTool->{SET_GROUP1} = 'Track' . (++$track);
                    }
                    my $subTable = GetTagTable($$subdir{TagTable});
                    my $proc = $$subdir{ProcessProc};
                    # make ProcessMOV() the default processing procedure for subdirectories
                    $proc = \&ProcessMOV unless $proc or $$subTable{PROCESS_PROC};
                    $exifTool->ProcessDirectory(\%dirInfo, $subTable, $proc) if $size > $start;
                    $exifTool->{SET_GROUP1} = $oldGroup1;
                    SetByteOrder('MM');
                } elsif ($hasData) {
                    # handle atoms containing 'data' tags
                    # (currently ignore contained atoms: 'itif', 'name', etc.)
                    my $pos = 0;
                    for (;;) {
                        last if $pos + 16 > $size;
                        my ($len, $type, $flags, $ctry, $lang) = unpack("x${pos}Na4Nnn", $val);
                        last if $pos + $len > $size;
                        my $value;
                        my $format = $$tagInfo{Format};
                        if ($type eq 'data' and $len >= 16) {
                            $pos += 16;
                            $len -= 16;
                            $value = substr($val, $pos, $len);
                            # format flags (ref 12):
                            # 0x0=binary, 0x1=UTF-8, 0x2=UTF-16, 0x3=ShiftJIS,
                            # 0x4=UTF-8  0x5=UTF-16, 0xd=JPEG, 0xe=PNG,
                            # 0x15=signed int, 0x16=unsigned int, 0x17=float,
                            # 0x18=double, 0x1b=BMP, 0x1c='meta' atom
                            if ($stringEncoding{$flags}) {
                                # handle all string formats
                                $value = $exifTool->Decode($value, $stringEncoding{$flags});
                            } else {
                                if (not $format) {
                                    if ($flags == 0x15 or $flags == 0x16) {
                                        $format = { 1=>'int8', 2=>'int16', 4=>'int32' }->{$len};
                                        $format .= $flags == 0x15 ? 's' : 'u' if $format;
                                    } elsif ($flags == 0x17) {
                                        $format = 'float';
                                    } elsif ($flags == 0x18) {
                                        $format = 'double';
                                    } elsif ($flags == 0x00) {
                                        # read 1 and 2-byte binary as integers
                                        if ($len == 1) {
                                            $format = 'int8u',
                                        } elsif ($len == 2) {
                                            $format = 'int16u',
                                        }
                                    }
                                }
                                if ($format) {
                                    $value = ReadValue(\$value, 0, $format, $$tagInfo{Count}, $len);
                                } elsif (not $$tagInfo{ValueConv}) {
                                    # make binary data a scalar reference unless a ValueConv exists
                                    my $buf = $value;
                                    $value = \$buf;
                                }
                            }
                        }
                        my $langInfo;
                        if ($ctry or $lang) {
                            # ignore country ('ctry') and language lists ('lang') for now
                            undef $ctry if $ctry and $ctry <= 255;
                            undef $lang if $lang and $lang <= 255;
                            $lang = UnpackLang($lang);
                            # add country code if specified
                            if ($ctry) {
                                $ctry = unpack('a2',pack('n',$ctry)); # unpack as ISO 3166-1
                                # treat 'ZZ' like a default country (see ref 12)
                                undef $ctry if $ctry eq 'ZZ';
                                if ($ctry and $ctry =~ /^[A-Z]{2}$/) {
                                    $lang or $lang = 'und';
                                    $lang .= "-$ctry";
                                }
                            }
                            $langInfo = Image::ExifTool::GetLangInfo($tagInfo, $lang) if $lang;
                        }
                        $langInfo or $langInfo = $tagInfo;
                        $exifTool->VerboseInfo($tag, $langInfo,
                            Value   => ref $value ? $$value : $value,
                            DataPt  => \$val,
                            DataPos => $dataPos,
                            Start   => $pos,
                            Size    => $len,
                            Format  => $format,
                            Extra   => sprintf(", Type='$type', Flags=0x%x",$flags)
                        ) if $verbose;
                        $exifTool->FoundTag($langInfo, $value) if defined $value;
                        $pos += $len;
                    }
                } elsif ($tag =~ /^\xa9/) {
                    # parse international text to extract all languages
                    my $pos = 0;
                    for (;;) {
                        last if $pos + 4 > $size;
                        my ($len, $lang) = unpack("x${pos}nn", $val);
                        $pos += 4;
                        # according to the QuickTime spec (ref 12), $len should include
                        # 4 bytes for length and type words, but nobody (including
                        # Apple, Pentax and Kodak) seems to add these in, so try
                        # to allow for either
                        if ($pos + $len > $size) {
                            $len -= 4;
                            last if $pos + $len > $size or $len < 0;
                        }
                        # ignore any empty entries (or null padding) after the first
                        next if not $len and $pos;
                        my $str = substr($val, $pos, $len);
                        my $langInfo;
                        if ($lang < 0x400) {
                            # this is a Macintosh language code
                            # a language code of 0 is Macintosh english, so treat as default
                            if ($lang) { 
                                # use Font.pm to look up language string
                                require Image::ExifTool::Font;
                                $lang = $Image::ExifTool::Font::ttLang{Macintosh}{$lang};
                            }
                            # the spec says only "Macintosh text encoding", but
                            # allow this to be configured by the user
                            $str = $exifTool->Decode($str, $charsetQuickTime);
                        } else {
                            # convert language code to ASCII (ignore read-only bit)
                            $lang = UnpackLang($lang);
                            # may be either UTF-8 or UTF-16BE
                            my $enc = $str=~s/^\xfe\xff// ? 'UTF16' : 'UTF8';
                            $str = $exifTool->Decode($str, $enc);
                        }
                        $langInfo = Image::ExifTool::GetLangInfo($tagInfo, $lang) if $lang;
                        $exifTool->FoundTag($langInfo || $tagInfo, $str);
                        $pos += $len;
                    }
                } else {
                    my $format = $$tagInfo{Format};
                    if ($format) {
                        $val = ReadValue(\$val, 0, $format, $$tagInfo{Count}, length($val));
                    }
                    my $key = $exifTool->FoundTag($tagInfo, $val);
                    # decode if necessary (NOTE: must be done after RawConv)
                    if (defined $key and (not $format or $format =~ /^string/) and
                        not $$tagInfo{Unknown} and not $$tagInfo{Binary} and
                        defined $$exifTool{VALUE}{$key} and not ref $val)
                    {
                        my $vp = \$$exifTool{VALUE}{$key};
                        if (not ref $$vp and length($$vp) <= 65536 and $$vp =~ /[\x80-\xff]/) {
                            # the encoding of this is not specified, so use CharsetQuickTime
                            $$vp = $exifTool->Decode($$vp, $charsetQuickTime);
                        }
                    }
                }
            }
        } else {
            $raf->Seek($size, 1) or $exifTool->Warn("Truncated '$tag' data"), last;
        }
        $raf->Read($buff, 8) == 8 or last;
        $dataPos += $size + 8;
        ($size, $tag) = unpack('Na4', $buff);
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process a QuickTime Image File
# Inputs: 0) ExifTool object reference, 1) directory information reference
# Returns: 1 on success
sub ProcessQTIF($$)
{
    my ($exifTool, $dirInfo) = @_;
    my $table = GetTagTable('Image::ExifTool::QuickTime::ImageFile');
    return ProcessMOV($exifTool, $dirInfo, $table);
}

1;  # end

__END__

=head1 NAME

Image::ExifTool::QuickTime - Read QuickTime and MP4 meta information

=head1 SYNOPSIS

This module is used by Image::ExifTool

=head1 DESCRIPTION

This module contains routines required by Image::ExifTool to extract
information from QuickTime and MP4 video, and M4A audio files.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://developer.apple.com/mac/library/documentation/QuickTime/QTFF/QTFFChap1/qtff1.html>

=item L<http://search.cpan.org/dist/MP4-Info-1.04/>

=item L<http://www.geocities.com/xhelmboyx/quicktime/formats/mp4-layout.txt>

=item L<http://wiki.multimedia.cx/index.php?title=Apple_QuickTime>

=item L<http://atomicparsley.sourceforge.net/mpeg-4files.html>

=item L<http://wiki.multimedia.cx/index.php?title=QuickTime_container>

=item L<http://code.google.com/p/mp4v2/wiki/iTunesMetadata>

=item L<http://www.canieti.com.mx/assets/files/1011/IEC_100_1384_DC.pdf>

=item L<http://www.adobe.com/devnet/flv/pdf/video_file_format_spec_v10.pdf>

=back

=head1 SEE ALSO

L<Image::ExifTool::TagNames/QuickTime Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut

