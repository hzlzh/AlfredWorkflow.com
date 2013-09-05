#------------------------------------------------------------------------------
# File:         PNG.pm
#
# Description:  Read and write PNG meta information
#
# Revisions:    06/10/2005 - P. Harvey Created
#               06/23/2005 - P. Harvey Added MNG and JNG support
#               09/16/2005 - P. Harvey Added write support
#
# References:   1) http://www.libpng.org/pub/png/spec/1.2/
#               2) http://www.faqs.org/docs/png/
#               3) http://www.libpng.org/pub/mng/
#               4) http://www.libpng.org/pub/png/spec/register/
#               5) ftp://ftp.simplesystems.org/pub/png/documents/pngext-1.4.0-pdg.html
#
# Notes:        Writing meta information in PNG images is a pain in the butt
#               for a number of reasons:  One biggie is that you have to
#               decompress then decode the ASCII/hex profile information before
#               you can edit it, then you have to ASCII/hex-encode, recompress
#               and calculate a CRC before you can write it out again.  gaaaak.
#------------------------------------------------------------------------------

package Image::ExifTool::PNG;

use strict;
use vars qw($VERSION $AUTOLOAD);
use Image::ExifTool qw(:DataAccess :Utils);

$VERSION = '1.27';

sub ProcessPNG_tEXt($$$);
sub ProcessPNG_iTXt($$$);
sub ProcessPNG_Compressed($$$);
sub CalculateCRC($;$$$);
sub HexEncode($);
sub AddChunks($$);
sub Add_iCCP($$);
sub GetLangInfo($$);
sub BuildTextChunk($$$$$);

my $noCompressLib;

# look up for file type, header chunk and end chunk, based on file signature
my %pngLookup = (
    "\x89PNG\r\n\x1a\n" => ['PNG', 'IHDR', 'IEND' ],
    "\x8aMNG\r\n\x1a\n" => ['MNG', 'MHDR', 'MEND' ],
    "\x8bJNG\r\n\x1a\n" => ['JNG', 'JHDR', 'IEND' ],
);

# map for directories in PNG images
my %pngMap = (
    IFD1         => 'IFD0',
    EXIF         => 'IFD0', # to write EXIF as a block
    ExifIFD      => 'IFD0',
    GPS          => 'IFD0',
    SubIFD       => 'IFD0',
    GlobParamIFD => 'IFD0',
    PrintIM      => 'IFD0',
    InteropIFD   => 'ExifIFD',
    MakerNotes   => 'ExifIFD',
    IFD0         => 'PNG',
    XMP          => 'PNG',
    ICC_Profile  => 'PNG',
    Photoshop    => 'PNG',
    IPTC         => 'Photoshop',
    MakerNotes   => 'ExifIFD',
);

# color type of current image
$Image::ExifTool::PNG::colorType = -1;

# PNG chunks
%Image::ExifTool::PNG::Main = (
    WRITE_PROC => \&Image::ExifTool::DummyWriteProc,
    GROUPS => { 2 => 'Image' },
    PREFERRED => 1, # always add these tags when writing
    NOTES => q{
        Tags extracted from PNG images.  See
        L<http://www.libpng.org/pub/png/spec/1.2/> for the official PNG 1.2
        specification.
    },
    bKGD => {
        Name => 'BackgroundColor',
        ValueConv => 'join(" ",unpack(length($val) < 2 ? "C" : "n*", $val))',
    },
    cHRM => {
        Name => 'PrimaryChromaticities',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::PrimaryChromaticities' },
    },
    dSIG => {
        Name => 'DigitalSignature',
        Binary => 1,
    },
    fRAc => {
        Name => 'FractalParameters',
        Binary => 1,
    },
    gAMA => {
        Name => 'Gamma',
        ValueConv => 'my $a=unpack("N",$val);$a ? int(1e9/$a+0.5)/1e4 : $val',
    },
    gIFg => {
        Name => 'GIFGraphicControlExtension',
        Binary => 1,
    },
    gIFt => {
        Name => 'GIFPlainTextExtension',
        Binary => 1,
    },
    gIFx => {
        Name => 'GIFApplicationExtension',
        Binary => 1,
    },
    hIST => {
        Name => 'PaletteHistogram',
        Binary => 1,
    },
    iCCP => {
        Name => 'ICC_Profile',
        SubDirectory => {
            TagTable => 'Image::ExifTool::ICC_Profile::Main',
            ProcessProc => \&ProcessPNG_Compressed,
        },
    },
#   IDAT
#   IEND
    IHDR => {
        Name => 'ImageHeader',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::ImageHeader' },
    },
    iTXt => {
        Name => 'InternationalText',
        SubDirectory => {
            TagTable => 'Image::ExifTool::PNG::TextualData',
            ProcessProc => \&ProcessPNG_iTXt,
        },
    },
    oFFs => {
        Name => 'ImageOffset',
        ValueConv => q{
            my @a = unpack("NNC",$val);
            $a[2] = ($a[2] ? "microns" : "pixels");
            return "$a[0], $a[1] ($a[2])";
        },
    },
    pCAL => {
        Name => 'PixelCalibration',
        Binary => 1,
    },
    pHYs => {
        Name => 'PhysicalPixel',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::PhysicalPixel' },
    },
    PLTE => {
        Name => 'Palette',
        ValueConv => 'length($val) <= 3 ? join(" ",unpack("C*",$val)) : \$val',
    },
    sBIT => {
        Name => 'SignificantBits',
        ValueConv => 'join(" ",unpack("C*",$val))',
    },
    sCAL => { # png 1.4.0
        Name => 'SubjectScale',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::SubjectScale' },
    },
    sPLT => {
        Name => 'SuggestedPalette',
        Binary => 1,
        PrintConv => 'split("\0",$$val,1)', # extract palette name
    },
    sRGB => {
        Name => 'SRGBRendering',
        ValueConv => 'unpack("C",$val)',
        PrintConv => {
            0 => 'Perceptual',
            1 => 'Relative Colorimetric',
            2 => 'Saturation',
            3 => 'Absolute Colorimetric',
        },
    },
    sTER => { # png 1.4.0
        Name => 'StereoImage',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::StereoImage' },
    },
    tEXt => {
        Name => 'TextualData',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::TextualData' },
    },
    tIME => {
        Name => 'ModifyDate',
        Groups => { 2 => 'Time' },
        Writable => 1,
        Shift => 'Time',
        ValueConv => 'sprintf("%.4d:%.2d:%.2d %.2d:%.2d:%.2d", unpack("nC5", $val))',
        ValueConvInv => q{
            my @a = ($val=~/^(\d+):(\d+):(\d+)\s+(\d+):(\d+):(\d+)/);
            @a == 6 or warn('Invalid date'), return undef;
            return pack('nC5', @a);
        },
        PrintConv => '$self->ConvertDateTime($val)',
        PrintConvInv => '$self->InverseDateTime($val)',
    },
    tRNS => {
        Name => 'Transparency',
        ValueConv => q{
            return \$val if length($val) > 6;
            join(" ",unpack($Image::ExifTool::PNG::colorType == 3 ? "C*" : "n*", $val));
        },
    },
    tXMP => {
        Name => 'XMP',
        Notes => 'obsolete location specified by a September 2001 XMP draft',
        SubDirectory => { TagTable => 'Image::ExifTool::XMP::Main' },
    },
    vpAg => { # private imagemagick chunk
        Name => 'VirtualPage',
        SubDirectory => { TagTable => 'Image::ExifTool::PNG::VirtualPage' },
    },
    zTXt => {
        Name => 'CompressedText',
        SubDirectory => {
            TagTable => 'Image::ExifTool::PNG::TextualData',
            ProcessProc => \&ProcessPNG_Compressed,
        },
    },
);

# PNG IHDR chunk
%Image::ExifTool::PNG::ImageHeader = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    0 => {
        Name => 'ImageWidth',
        Format => 'int32u',
    },
    4 => {
        Name => 'ImageHeight',
        Format => 'int32u',
    },
    8 => 'BitDepth',
    9 => {
        Name => 'ColorType',
        RawConv => '$Image::ExifTool::PNG::colorType = $val',
        PrintConv => {
            0 => 'Grayscale',
            2 => 'RGB',
            3 => 'Palette',
            4 => 'Grayscale with Alpha',
            6 => 'RGB with Alpha',
        },
    },
    10 => {
        Name => 'Compression',
        PrintConv => { 0 => 'Deflate/Inflate' },
    },
    11 => {
        Name => 'Filter',
        PrintConv => { 0 => 'Adaptive' },
    },
    12 => {
        Name => 'Interlace',
        PrintConv => { 0 => 'Noninterlaced', 1 => 'Adam7 Interlace' },
    },
);

# PNG cHRM chunk
%Image::ExifTool::PNG::PrimaryChromaticities = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    FORMAT => 'int32u',
    0 => { Name => 'WhitePointX', ValueConv => '$val / 100000' },
    1 => { Name => 'WhitePointY', ValueConv => '$val / 100000' },
    2 => { Name => 'RedX',        ValueConv => '$val / 100000' },
    3 => { Name => 'RedY',        ValueConv => '$val / 100000' },
    4 => { Name => 'GreenX',      ValueConv => '$val / 100000' },
    5 => { Name => 'GreenY',      ValueConv => '$val / 100000' },
    6 => { Name => 'BlueX',       ValueConv => '$val / 100000' },
    7 => { Name => 'BlueY',       ValueConv => '$val / 100000' },
);

# PNG pHYs chunk
%Image::ExifTool::PNG::PhysicalPixel = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    0 => {
        Name => 'PixelsPerUnitX',
        Format => 'int32u',
    },
    4 => {
        Name => 'PixelsPerUnitY',
        Format => 'int32u',
    },
    8 => {
        Name => 'PixelUnits',
        PrintConv => { 0 => 'Unknown', 1 => 'Meters' },
    },
);

# PNG sCAL chunk
%Image::ExifTool::PNG::SubjectScale = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    0 => {
        Name => 'SubjectUnits',
        PrintConv => { 1 => 'Meters', 2 => 'Radians' },
    },
    1 => {
        Name => 'SubjectPixelWidth',
        Format => 'var_string',
    },
    2 => {
        Name => 'SubjectPixelHeight',
        Format => 'var_string',
    },
);

# PNG vpAg chunk
%Image::ExifTool::PNG::VirtualPage = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    FORMAT => 'int32u',
    0 => 'VirtualImageWidth',
    1 => 'VirtualImageHeight',
    2 => {
        Name => 'VirtualPageUnits',
        Format => 'int8u',
        # what is the conversion for this?
    },
);

# PNG sTER chunk
%Image::ExifTool::PNG::StereoImage = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 2 => 'Image' },
    0 => {
        Name => 'StereoMode',
        PrintConv => {
            0 => 'Cross-fuse Layout',
            1 => 'Diverging-fuse Layout',
        },
    },
);

my %unreg = ( Notes => 'unregistered' );

# Tags for PNG tEXt zTXt and iTXt chunks
# (NOTE: ValueConv is set dynamically, so don't set it here!)
%Image::ExifTool::PNG::TextualData = (
    PROCESS_PROC => \&ProcessPNG_tEXt,
    WRITE_PROC => \&Image::ExifTool::DummyWriteProc,
    WRITABLE => 'string',
    PREFERRED => 1, # always add these tags when writing
    GROUPS => { 2 => 'Image' },
    LANG_INFO => \&GetLangInfo,
    NOTES => q{
        The PNG TextualData format allows arbitrary tag names to be used.  The tags
        listed below are the only ones that can be written (unless new user-defined
        tags are added via the configuration file), however ExifTool will extract
        any other TextualData tags that are found.
        
        These tags may be stored as tEXt, zTXt or iTXt chunks in the PNG image.  By
        default ExifTool writes new string-value tags as as uncompressed tEXt, or
        compressed zTXt if the Compress (-z) option is used and Compress::Zlib is
        available.  Alternate language tags and values containing special characters
        (unless the Latin character set is used) are written as iTXt, and compressed
        if the Compress option is used and Compress::Zlib is available.  Raw profile
        information is always created as compressed zTXt if Compress::Zlib is
        available, or tEXt otherwise.  Standard XMP is written as uncompressed iTXt.

        Alternate languages are accessed by suffixing the tag name with a '-',
        followed by an RFC 3066 language code (ie. "PNG:Comment-fr", or
        "Title-en-US").  See L<http://www.ietf.org/rfc/rfc3066.txt> for the RFC 3066
        specification.

        Some of the tags below are not registered as part of the PNG specification,
        but are included here because they are generated by other software such as
        ImageMagick.
    },
    Title       => { },
    Author      => { Groups => { 2 => 'Author' } },
    Description => { },
    Copyright   => { Groups => { 2 => 'Author' } },
   'Creation Time' => {
        Name => 'CreationTime',
        Groups => { 2 => 'Time' },
        Shift => 'Time',
    },
    Software    => { },
    Disclaimer  => { },
    # change name to differentiate from ExifTool Warning
    Warning     => { Name => 'PNGWarning', },
    Source      => { },
    Comment     => { },
#
# The following tags are not part of the original PNG specification,
# but are written by ImageMagick and other software
#
    Artist      => { %unreg, Groups => { 2 => 'Author' } },
    Document    => { %unreg },
    Label       => { %unreg },
    Make        => { %unreg, Groups => { 2 => 'Camera' } },
    Model       => { %unreg, Groups => { 2 => 'Camera' } },
   'create-date'=> {
        Name => 'CreateDate',
        Groups => { 2 => 'Time' },
        Shift => 'Time',
        %unreg,
        ValueConv => 'require Image::ExifTool::XMP; Image::ExifTool::XMP::ConvertXMPDate($val)',
        ValueConvInv => 'require Image::ExifTool::XMP; Image::ExifTool::XMP::FormatXMPDate($val)',
        PrintConv => '$self->ConvertDateTime($val)',
        PrintConvInv => '$self->InverseDateTime($val,undef,1)',
    },
   'modify-date'=> {
        Name => 'ModDate', # (to distinguish from tIME chunk "ModifyDate")
        Groups => { 2 => 'Time' },
        Shift => 'Time',
        %unreg,
        ValueConv => 'require Image::ExifTool::XMP; Image::ExifTool::XMP::ConvertXMPDate($val)',
        ValueConvInv => 'require Image::ExifTool::XMP; Image::ExifTool::XMP::FormatXMPDate($val)',
        PrintConv => '$self->ConvertDateTime($val)',
        PrintConvInv => '$self->InverseDateTime($val,undef,1)',
    },
    TimeStamp   => { %unreg, Groups => { 2 => 'Time' }, Shift => 'Time' },
    URL         => { %unreg },
   'XML:com.adobe.xmp' => {
        Name => 'XMP',
        Notes => q{
            unregistered, but this is the location according to the June 2002 or later
            XMP specification, and is where ExifTool will add a new XMP chunk if the
            image didn't already contain XMP
        },
        SubDirectory => {
            TagTable => 'Image::ExifTool::XMP::Main',
        },
    },
   'Raw profile type APP1' => [
        {
            # EXIF table must come first because we key on this in ProcessProfile()
            # (No condition because this is just for BuildTagLookup)
            Name => 'APP1_Profile',
            %unreg,
            SubDirectory => {
                TagTable=>'Image::ExifTool::Exif::Main',
                ProcessProc => \&ProcessProfile,
            },
        },
        {
            Name => 'APP1_Profile',
            SubDirectory => {
                TagTable=>'Image::ExifTool::XMP::Main',
                ProcessProc => \&ProcessProfile,
            },
        },
    ],
   'Raw profile type exif' => {
        Name => 'EXIF_Profile',
        %unreg,
        SubDirectory => {
            TagTable=>'Image::ExifTool::Exif::Main',
            ProcessProc => \&ProcessProfile,
        },
    },
   'Raw profile type icc' => {
        Name => 'ICC_Profile',
        %unreg,
        SubDirectory => {
            TagTable => 'Image::ExifTool::ICC_Profile::Main',
            ProcessProc => \&ProcessProfile,
        },
    },
   'Raw profile type icm' => {
        Name => 'ICC_Profile',
        %unreg,
        SubDirectory => {
            TagTable => 'Image::ExifTool::ICC_Profile::Main',
            ProcessProc => \&ProcessProfile,
        },
    },
   'Raw profile type iptc' => {
        Name => 'IPTC_Profile',
        %unreg,
        SubDirectory => {
            TagTable => 'Image::ExifTool::Photoshop::Main',
            ProcessProc => \&ProcessProfile,
        },
    },
   'Raw profile type xmp' => {
        Name => 'XMP_Profile',
        %unreg,
        SubDirectory => {
            TagTable => 'Image::ExifTool::XMP::Main',
            ProcessProc => \&ProcessProfile,
        },
    },
);

#------------------------------------------------------------------------------
# AutoLoad our writer routines when necessary
#
sub AUTOLOAD
{
    return Image::ExifTool::DoAutoLoad($AUTOLOAD, @_);
}

#------------------------------------------------------------------------------
# Get standard case for language code (this routine copied from XMP.pm)
# Inputs: 0) Language code
# Returns: Language code in standard case
sub StandardLangCase($)
{
    my $lang = shift;
    # make 2nd subtag uppercase only if it is 2 letters
    return lc($1) . uc($2) . lc($3) if $lang =~ /^([a-z]{2,3}|[xi])(-[a-z]{2})\b(.*)/i;
    return lc($lang);
}

#------------------------------------------------------------------------------
# Get localized version of tagInfo hash
# Inputs: 0) tagInfo hash ref, 1) language code (ie. "x-default")
# Returns: new tagInfo hash ref, or undef if invalid
sub GetLangInfo($$)
{
    my ($tagInfo, $lang) = @_;
    $lang =~ tr/_/-/;   # RFC 3066 specifies '-' as a separator
    # no alternate languages for XMP or raw profile directories
    return undef if $$tagInfo{SubDirectory};
    # language code must normalized for use in tag ID
    return Image::ExifTool::GetLangInfo($tagInfo, StandardLangCase($lang));
}

#------------------------------------------------------------------------------
# Found a PNG tag -- extract info from subdirectory or decompress data if necessary
# Inputs: 0) ExifTool object reference, 1) Pointer to tag table,
#         2) Tag ID, 3) Tag value, 4) [optional] compressed data flag:
#            0=not compressed, 1=unknown compression, 2-N=compression with type N-2
#         5) optional output buffer ref, 6) character encoding (tEXt/zTXt/iTXt only)
#         6) optional language code
# Returns: 1 on success
sub FoundPNG($$$$;$$$$)
{
    my ($exifTool, $tagTablePtr, $tag, $val, $compressed, $outBuff, $enc, $lang) = @_;
    return 0 unless defined $val;
    my $verbose = $exifTool->Options('Verbose');
    my $id = $tag;  # generate tag ID which include language code
    if ($lang) {
        # case of language code must be normalized since they are case insensitive
        $lang = StandardLangCase($lang);
        $id .= '-' . $lang;
    }
    my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $id) ||
                  # (some software forgets to capitalize first letter)
                  $exifTool->GetTagInfo($tagTablePtr, ucfirst($id));
    # create alternate language tag if necessary
    if (not $tagInfo and $lang) {
        $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tag) ||
                   $exifTool->GetTagInfo($tagTablePtr, ucfirst($tag));
        $tagInfo = GetLangInfo($tagInfo, $lang) if $tagInfo;
    }
#
# uncompress data if necessary
#
    my ($wasCompressed, $deflateErr);
    if ($compressed and $compressed > 1) {
        if ($compressed == 2) { # Inflate/Deflate compression
            if (eval 'require Compress::Zlib') {
                my ($v2, $stat);
                my $inflate = Compress::Zlib::inflateInit();
                $inflate and ($v2, $stat) = $inflate->inflate($val);
                if ($inflate and $stat == Compress::Zlib::Z_STREAM_END()) {
                    $val = $v2;
                    $compressed = 0;
                    $wasCompressed = 1;
                } else {
                    $deflateErr = "Error inflating $tag";
                }
            } elsif (not $noCompressLib) {
                $deflateErr = "Install Compress::Zlib to read compressed information";
            } else {
                $deflateErr = '';   # flag deflate error but no warning
            }
        } else {
            $compressed -= 2;
            $deflateErr = "Unknown compression method $compressed for $tag";
        }
        if ($compressed and $verbose and $tagInfo and $$tagInfo{SubDirectory}) {
            $exifTool->VerboseDir("Unable to decompress $$tagInfo{Name}", 0, length($val));
        }
        # issue warning if relevant
        if ($deflateErr and (not $outBuff or
            ($tagInfo and $$tagInfo{SubDirectory} and $$exifTool{EDIT_DIRS}{$$tagInfo{Name}})))
        {
            $exifTool->Warn($deflateErr);
            $noCompressLib = 1 if $deflateErr =~ /^Install/;
        }
    }
    # translate character encoding if necessary (tEXt/zTXt/iTXt string values only)
    if ($enc and not $compressed and not ($tagInfo and $$tagInfo{SubDirectory})) {
        $val = $exifTool->Decode($val, $enc);
    }
#
# extract information from subdirectory if available
#
    if ($tagInfo) {
        my $tagName = $$tagInfo{Name};
        my $processed;
        if ($$tagInfo{SubDirectory} and not $compressed) {
            my $len = length $val;
            if ($verbose and $exifTool->{INDENT} ne '  ') {
                if ($wasCompressed and $verbose > 2) {
                    my $name = $tagName;
                    $wasCompressed and $name = "Decompressed $name";
                    $exifTool->VerboseDir($name, 0, $len);
                    $exifTool->VerboseDump(\$val);
                }
                # don't indent next directory (since it is really the same data)
                $exifTool->{INDENT} =~ s/..$//;
            }
            my $subdir = $$tagInfo{SubDirectory};
            my $processProc = $$subdir{ProcessProc};
            # nothing more to do if writing and subdirectory is not writable
            my $subTable = GetTagTable($$subdir{TagTable});
            return 1 if $outBuff and not $$subTable{WRITE_PROC};
            my %subdirInfo = (
                DataPt   => \$val,
                DirStart => 0,
                DataLen  => $len,
                DirLen   => $len,
                DirName  => $tagName,
                TagInfo  => $tagInfo,
                ReadOnly => 1, # (only used by WriteXMP)
                OutBuff  => $outBuff,
            );
            # no need to re-decompress if already done
            undef $processProc if $wasCompressed and $processProc eq \&ProcessPNG_Compressed;
            # rewrite this directory if necessary (but always process TextualData normally)
            if ($outBuff and not $processProc and $subTable ne \%Image::ExifTool::PNG::TextualData) {
                return 1 unless $exifTool->{EDIT_DIRS}->{$tagName};
                $$outBuff = $exifTool->WriteDirectory(\%subdirInfo, $subTable);
                # if this was an XMP directory, we must make it read-only
                $tagName eq 'XMP' and Image::ExifTool::XMP::ValidateXMP(\$outBuff,'r');
                delete $exifTool->{ADD_DIRS}->{$tagName};
            } else {
                $processed = $exifTool->ProcessDirectory(\%subdirInfo, $subTable, $processProc);
            }
            $compressed = 1;    # pretend this is compressed since it is binary data
        }
        if ($outBuff) {
            my $writable = $tagInfo->{Writable};
            my $isOverwriting;
            if ($writable or ($$tagTablePtr{WRITABLE} and
                not defined $writable and not $$tagInfo{SubDirectory}))
            {
                # write new value for this tag if necessary
                my $newVal;
                if ($exifTool->{DEL_GROUP}->{PNG}) {
                    # remove this tag now, but keep in ADD_PNG list to add back later
                    $isOverwriting = 1;
                } else {
                    # remove this from the list of PNG tags to add
                    delete $exifTool->{ADD_PNG}->{$id};
                    # (also handle case of tEXt tags written with lowercase first letter)
                    delete $exifTool->{ADD_PNG}->{ucfirst($id)};
                    my $nvHash = $exifTool->GetNewValueHash($tagInfo);
                    $isOverwriting = $exifTool->IsOverwriting($nvHash);
                    if (defined $deflateErr) {
                        $newVal = $exifTool->GetNewValues($nvHash);
                        # can only write tag now if always overwriting
                        if ($isOverwriting > 0) {
                            $val = '<deflate error>';
                        } elsif ($isOverwriting) {
                            $isOverwriting = 0; # can't overwrite
                            $exifTool->Warn($deflateErr) if $deflateErr;
                        }
                    } else {
                        if ($isOverwriting < 0) {
                            $isOverwriting = $exifTool->IsOverwriting($nvHash, $val);
                        }
                        # (must get new value after IsOverwriting() in case it was shifted)
                        $newVal = $exifTool->GetNewValues($nvHash);
                    }
                }
                if ($isOverwriting) {
                    $$outBuff = (defined $newVal) ? $newVal : '';
                    ++$exifTool->{CHANGED};
                    $exifTool->VerboseValue("- PNG:$tagName", $val);
                    $exifTool->VerboseValue("+ PNG:$tagName", $newVal) if defined $newVal;
                }
            }
            if (defined $$outBuff and length $$outBuff) {
                if ($enc) { # must be tEXt/zTXt/iTXt if $enc is set
                    $$outBuff = BuildTextChunk($exifTool, $tag, $tagInfo, $$outBuff, $lang);
                } elsif ($wasCompressed) {
                    # re-compress the output data
                    my $deflate;
                    if (eval 'require Compress::Zlib') {
                        my $deflate = Compress::Zlib::deflateInit();
                        if ($deflate) {
                            $$outBuff = $deflate->deflate($$outBuff);
                            $$outBuff .= $deflate->flush() if defined $$outBuff;
                        } else {
                            undef $$outBuff;
                        }
                    }
                    $$outBuff or $exifTool->Warn("PNG:$tagName not written (compress error)");
                }
            }
            return 1;
        }
        return 1 if $processed;
    } else {
        my $name;
        ($name = $tag) =~ s/\s+(.)/\u$1/g;   # remove white space from tag name
        $tagInfo = { Name => $name };
        $$tagInfo{LangCode} = $lang if $lang;
        # make unknown profiles binary data type
        $$tagInfo{Binary} = 1 if $tag =~ /^Raw profile type /;
        AddTagToTable($tagTablePtr, $tag, $tagInfo);
    }
#
# store this tag information
#
    if ($verbose) {
        # temporarily remove subdirectory so it isn't printed in verbose information
        # since we aren't decoding it anyway;
        my $subdir = $$tagInfo{SubDirectory};
        delete $$tagInfo{SubDirectory};
        $exifTool->VerboseInfo($tag, $tagInfo,
            Table  => $tagTablePtr,
            DataPt => \$val,
        );
        $$tagInfo{SubDirectory} = $subdir if $subdir;
    }
    # set the RawConv dynamically depending on whether this is binary or not
    my $delRawConv;
    if ($compressed and not defined $$tagInfo{ValueConv}) {
        $$tagInfo{RawConv} = '\$val';
        $delRawConv = 1;
    }
    $exifTool->FoundTag($tagInfo, $val);
    delete $$tagInfo{RawConv} if $delRawConv;
    return 1;
}

#------------------------------------------------------------------------------
# Process encoded PNG profile information
# Inputs: 0) ExifTool object reference, 1) DirInfo reference, 2) Pointer to tag table
# Returns: 1 on success
sub ProcessProfile($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $tagInfo = $$dirInfo{TagInfo};
    my $outBuff = $$dirInfo{OutBuff};
    my $tagName = $$tagInfo{Name};

    # ImageMagick 5.3.6 writes profiles with the following headers:
    # "\nICC Profile\n", "\nIPTC profile\n", "\n\xaa\x01{generic prof\n"
    # and "\ngeneric profile\n"
    return 0 unless $$dataPt =~ /^\n(.*?)\n\s*(\d+)\n(.*)/s;
    my ($profileType, $len) = ($1, $2);
    # data is encoded in hex, so change back to binary
    my $buff = pack('H*', join('',split(' ',$3)));
    my $actualLen = length $buff;
    if ($len ne $actualLen) {
        $exifTool->Warn("$tagName is wrong size (should be $len bytes but is $actualLen)");
        $len = $actualLen;
    }
    my $verbose = $exifTool->Options('Verbose');
    if ($verbose) {
        if ($verbose > 2) {
            $exifTool->VerboseDir("Decoded $tagName", 0, $len);
            $exifTool->VerboseDump(\$buff);
        }
        # don't indent next directory (since it is really the same data)
        $exifTool->{INDENT} =~ s/..$//;
    }
    my %dirInfo = (
        Parent   => 'PNG',
        DataPt   => \$buff,
        DataLen  => $len,
        DirStart => 0,
        DirLen   => $len,
        Base     => 0,
        OutFile  => $outBuff,
    );
    my $processed = 0;
    my $oldChanged = $exifTool->{CHANGED};
    my $exifTable = GetTagTable('Image::ExifTool::Exif::Main');
    my $editDirs = $exifTool->{EDIT_DIRS};
    my $addDirs = $exifTool->{ADD_DIRS};
    if ($tagTablePtr ne $exifTable) {
        # process non-EXIF and non-APP1 profile as-is
        if ($outBuff) {
            # no need to rewrite this if not editing tags in this directory
            my $dir = $tagName;
            $dir =~ s/_Profile// unless $dir =~ /^ICC/;
            return 1 unless $$editDirs{$dir};
            $$outBuff = $exifTool->WriteDirectory(\%dirInfo, $tagTablePtr);
            delete $$addDirs{$dir};
        } else {
            $processed = $exifTool->ProcessDirectory(\%dirInfo, $tagTablePtr);
        }
    } elsif ($buff =~ /^$Image::ExifTool::exifAPP1hdr/) {
        # APP1 EXIF information
        return 1 if $outBuff and not $$editDirs{IFD0};
        my $hdrLen = length($Image::ExifTool::exifAPP1hdr);
        $dirInfo{DirStart} += $hdrLen;
        $dirInfo{DirLen} -= $hdrLen;
        if ($outBuff) {
            $$outBuff = $exifTool->WriteDirectory(\%dirInfo, $tagTablePtr,
                                                  \&Image::ExifTool::WriteTIFF);
            $$outBuff = $Image::ExifTool::exifAPP1hdr . $$outBuff if $$outBuff;
            delete $$addDirs{IFD0};
        } else {
            $processed = $exifTool->ProcessTIFF(\%dirInfo);
        }
    } elsif ($buff =~ /^$Image::ExifTool::xmpAPP1hdr/) {
        # APP1 XMP information
        my $hdrLen = length($Image::ExifTool::xmpAPP1hdr);
        my $tagTablePtr = GetTagTable('Image::ExifTool::XMP::Main');
        $dirInfo{DirStart} += $hdrLen;
        $dirInfo{DirLen} -= $hdrLen;
        if ($outBuff) {
            return 1 unless $$editDirs{XMP};
            $$outBuff = $exifTool->WriteDirectory(\%dirInfo, $tagTablePtr);
            $$outBuff and $$outBuff = $Image::ExifTool::xmpAPP1hdr . $$outBuff;
            delete $$addDirs{XMP};
        } else {
            $processed = $exifTool->ProcessDirectory(\%dirInfo, $tagTablePtr);
        }
    } elsif ($buff =~ /^(MM\0\x2a|II\x2a\0)/) {
        # TIFF information (haven't seen this, but what the heck...)
        return 1 if $outBuff and not $$editDirs{IFD0};
        if ($outBuff) {
            $$outBuff = $exifTool->WriteDirectory(\%dirInfo, $tagTablePtr,
                                                  \&Image::ExifTool::WriteTIFF);
            $$outBuff = $Image::ExifTool::exifAPP1hdr . $$outBuff if $$outBuff;
            delete $$addDirs{IFD0};
        } else {
            $processed = $exifTool->ProcessTIFF(\%dirInfo);
        }
    } else {
        my $profName = $profileType;
        $profName =~ tr/\x00-\x1f\x7f-\xff/./;
        $exifTool->Warn("Unknown raw profile '$profName'");
    }
    if ($outBuff and defined $$outBuff and length $$outBuff) {
        if ($exifTool->{CHANGED} != $oldChanged) {
            my $hdr = sprintf("\n%s\n%8d\n", $profileType, length($$outBuff));
            # hex encode the data
            $$outBuff = $hdr . HexEncode($outBuff);
        } else {
            undef $$outBuff;
        }
    }
    return $processed;
}

#------------------------------------------------------------------------------
# Process PNG compressed zTXt or iCCP chunk
# Inputs: 0) ExifTool object reference, 1) DirInfo reference, 2) Pointer to tag table
# Returns: 1 on success
# Notes: writes new chunk data to ${$$dirInfo{OutBuff}} if writing tag
sub ProcessPNG_Compressed($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my ($tag, $val) = split /\0/, ${$$dirInfo{DataPt}}, 2;
    return 0 unless defined $val;
    # set compressed to 2 + compression method to decompress the data
    my $compressed = 2 + unpack('C', $val);
    my $hdr = $tag . "\0" . substr($val, 0, 1);
    $val = substr($val, 1); # remove compression method byte
    my $success;
    my $outBuff = $$dirInfo{OutBuff};
    # use the PNG chunk tag instead of the embedded tag name for iCCP chunks
    if ($$dirInfo{TagInfo} and $$dirInfo{TagInfo}->{Name} eq 'ICC_Profile') {
        $tag = 'iCCP';
        $tagTablePtr = \%Image::ExifTool::PNG::Main;
        $success = FoundPNG($exifTool, $tagTablePtr, $tag, $val, $compressed, $outBuff);
        $$outBuff = $hdr . $$outBuff if $outBuff and $$outBuff;
    } else {
        $success = FoundPNG($exifTool, $tagTablePtr, $tag, $val, $compressed, $outBuff, 'Latin');
    }
    return $success;
}

#------------------------------------------------------------------------------
# Process PNG tEXt chunk
# Inputs: 0) ExifTool object reference, 1) DirInfo reference, 2) Pointer to tag table
# Returns: 1 on success
# Notes: writes new chunk data to ${$$dirInfo{OutBuff}} if writing tag
sub ProcessPNG_tEXt($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my ($tag, $val) = split /\0/, ${$$dirInfo{DataPt}}, 2;
    my $outBuff = $$dirInfo{OutBuff};
    return FoundPNG($exifTool, $tagTablePtr, $tag, $val, undef, $outBuff, 'Latin');
}

#------------------------------------------------------------------------------
# Process PNG iTXt chunk
# Inputs: 0) ExifTool object reference, 1) DirInfo reference, 2) Pointer to tag table
# Returns: 1 on success
# Notes: writes new chunk data to ${$$dirInfo{OutBuff}} if writing tag
sub ProcessPNG_iTXt($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my ($tag, $dat) = split /\0/, ${$$dirInfo{DataPt}}, 2;
    return 0 unless defined $dat and length($dat) >= 4;
    my ($compressed, $meth) = unpack('CC', $dat);
    my ($lang, $trans, $val) = split /\0/, substr($dat, 2), 3;
    # set compressed flag so we will decompress it in FoundPNG()
    $compressed and $compressed = 2 + $meth;
    my $outBuff = $$dirInfo{OutBuff};
    return FoundPNG($exifTool, $tagTablePtr, $tag, $val, $compressed, $outBuff, 'UTF8', $lang);
}

#------------------------------------------------------------------------------
# Extract meta information from a PNG image
# Inputs: 0) ExifTool object reference, 1) dirInfo reference
# Returns: 1 on success, 0 if this wasn't a valid PNG image, or -1 on write error
sub ProcessPNG($$)
{
    my ($exifTool, $dirInfo) = @_;
    my $outfile = $$dirInfo{OutFile};
    my $raf = $$dirInfo{RAF};
    my $datChunk = '';
    my $datCount = 0;
    my $datBytes = 0;
    my ($sig, $err, $ok);

    # check to be sure this is a valid PNG/MNG/JNG image
    return 0 unless $raf->Read($sig,8) == 8 and $pngLookup{$sig};
    if ($outfile) {
        delete $$exifTool{TextChunkType};
        Write($outfile, $sig) or $err = 1 if $outfile;
        # can only add tags in Main and TextualData tables
        $exifTool->{ADD_PNG} = $exifTool->GetNewTagInfoHash(
            \%Image::ExifTool::PNG::Main,
            \%Image::ExifTool::PNG::TextualData);
        # initialize with same directories, with PNG tags taking priority
        $exifTool->InitWriteDirs(\%pngMap,'PNG');
    }
    my ($fileType, $hdrChunk, $endChunk) = @{$pngLookup{$sig}};
    $exifTool->SetFileType($fileType);  # set the FileType tag
    SetByteOrder('MM'); # PNG files are big-endian
    my $tagTablePtr = GetTagTable('Image::ExifTool::PNG::Main');
    my $mngTablePtr;
    if ($fileType ne 'PNG') {
        $mngTablePtr = GetTagTable('Image::ExifTool::MNG::Main');
    }
    my $verbose = $exifTool->Options('Verbose');
    my $out = $exifTool->Options('TextOut');
    my ($hbuf, $dbuf, $cbuf, $foundHdr);

    # process the PNG/MNG/JNG chunks
    undef $noCompressLib;
    for (;;) {
        $raf->Read($hbuf,8) == 8 or $exifTool->Warn("Truncated $fileType image"), last;
        my ($len, $chunk) = unpack('Na4',$hbuf);
        $len > 0x7fffffff and $exifTool->Warn("Invalid $fileType box size"), last;
        if ($verbose) {
            # don't dump image data chunks in verbose mode (only give count instead)
            if ($datCount and $chunk ne $datChunk) {
                my $s = $datCount > 1 ? 's' : '';
                print $out "$fileType $datChunk ($datCount chunk$s, total $datBytes bytes)\n";
                $datCount = $datBytes = 0;
                $datChunk = '';
            }
            if ($chunk =~ /^(IDAT|JDAT|JDAA)$/) {
                $datChunk = $chunk;
                $datCount++;
                $datBytes += $len;
            }
        }
        if ($outfile) {
            if ($chunk eq 'IEND') {
                # add any new chunks immediately before the IEND chunk
                AddChunks($exifTool, $outfile) or $err = 1;
            } elsif ($chunk eq 'PLTE' or $chunk eq 'IDAT') {
                # iCCP chunk must come before PLTE and IDAT
                # (ignore errors -- will add later as text profile if this fails)
                Add_iCCP($exifTool, $outfile);
            }
        }
        if ($chunk eq $endChunk) {
            if ($outfile) {
                # copy over the rest of the file if necessary
                Write($outfile, $hbuf) or $err = 1;
                while ($raf->Read($hbuf, 65536)) {
                    Write($outfile, $hbuf) or $err = 1;
                }
            }
            $verbose and print $out "$fileType $chunk (end of image)\n";
            $ok = 1;
            last;
        }
        # read chunk data and CRC
        unless ($raf->Read($dbuf,$len)==$len and $raf->Read($cbuf, 4)==4) {
            $exifTool->Warn("Corrupted $fileType image");
            last;
        }
        unless ($foundHdr) {
            if ($chunk eq $hdrChunk) {
                $foundHdr = 1;
            } elsif ($hdrChunk eq 'IHDR' and $chunk eq 'CgBI') {
                $exifTool->Warn('Non-standard PNG image (Apple iPhone format)');
            } else {
                $exifTool->Warn("$fileType image did not start with $hdrChunk");
                last;
            }
        }
        if ($verbose) {
            # check CRC when in verbose mode (since we don't care about speed)
            my $crc = CalculateCRC(\$hbuf, undef, 4);
            $crc = CalculateCRC(\$dbuf, $crc);
            $crc == unpack('N',$cbuf) or $exifTool->Warn("Bad CRC for $chunk chunk");
            if ($datChunk) {
                Write($outfile, $hbuf, $dbuf, $cbuf) or $err = 1 if $outfile;
                next;
            }
            print $out "$fileType $chunk ($len bytes):\n";
            $exifTool->VerboseDump(\$dbuf, Addr => $raf->Tell() - $len - 4) if $verbose > 2;
        }
        # only extract information from chunks in our tables
        my ($theBuff, $outBuff);
        $outBuff = \$theBuff if $outfile;
        if ($$tagTablePtr{$chunk}) {
            FoundPNG($exifTool, $tagTablePtr, $chunk, $dbuf, undef, $outBuff);
        } elsif ($mngTablePtr and $$mngTablePtr{$chunk}) {
            FoundPNG($exifTool, $mngTablePtr, $chunk, $dbuf, undef, $outBuff);
        }
        if ($outfile) {
            if (defined $theBuff) {
                next unless length $theBuff; # empty if we deleted the information
                # change chunk type if necessary
                if ($$exifTool{TextChunkType}) {
                    $chunk = $$exifTool{TextChunkType};
                    delete $$exifTool{TextChunkType};
                }
                $hbuf = pack('Na4', length($theBuff), $chunk);
                $dbuf = $theBuff;
                my $crc = CalculateCRC(\$hbuf, undef, 4);
                $crc = CalculateCRC(\$dbuf, $crc);
                $cbuf = pack('N', $crc);
            }
            Write($outfile, $hbuf, $dbuf, $cbuf) or $err = 1;
        }
    }
    return -1 if $outfile and ($err or not $ok);
    return 1;   # this was a valid PNG/MNG/JNG image
}

1;  # end

__END__

=head1 NAME

Image::ExifTool::PNG - Read and write PNG meta information

=head1 SYNOPSIS

This module is used by Image::ExifTool

=head1 DESCRIPTION

This module contains routines required by Image::ExifTool to read and
write PNG (Portable Network Graphics), MNG (Multi-image Network Graphics)
and JNG (JPEG Network Graphics) images.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://www.libpng.org/pub/png/spec/1.2/>

=item L<http://www.faqs.org/docs/png/>

=item L<http://www.libpng.org/pub/mng/>

=item L<http://www.libpng.org/pub/png/spec/register/>

=back

=head1 SEE ALSO

L<Image::ExifTool::TagNames/PNG Tags>,
L<Image::ExifTool::TagNames/MNG Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut

