#------------------------------------------------------------------------------
# File:         JPEG.pm
#
# Description:  Definitions for uncommon JPEG segments
#
# Revisions:    10/06/2006 - P. Harvey Created
#------------------------------------------------------------------------------

package Image::ExifTool::JPEG;
use strict;
use vars qw($VERSION);
use Image::ExifTool qw(:DataAccess :Utils);

$VERSION = '1.16';

sub ProcessScalado($$$);
sub ProcessOcad($$$);

# (this main JPEG table is for documentation purposes only)
%Image::ExifTool::JPEG::Main = (
    NOTES => 'This table lists information extracted by ExifTool from JPEG images.',
    APP0 => [{
        Name => 'JFIF',
        Condition => '$$valPt =~ /^JFIF\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::JFIF::Main' },
      }, {
        Name => 'JFXX',
        Condition => '$$valPt =~ /^JFXX\0\x10/',
        SubDirectory => { TagTable => 'Image::ExifTool::JFIF::Extension' },
      }, {
        Name => 'CIFF',
        Condition => '$$valPt =~ /^(II|MM).{4}HEAPJPGM/s',
        SubDirectory => { TagTable => 'Image::ExifTool::CanonRaw::Main' },
      }, {
        Name => 'AVI1',
        Condition => '$$valPt =~ /^AVI1/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::AVI1' },
      }, {
        Name => 'Ocad',
        Condition => '$$valPt =~ /^Ocad/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::Ocad' },
    }],
    APP1 => [{
        Name => 'EXIF',
        Condition => '$$valPt =~ /^Exif\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::Exif::Main' },
      }, {
        Name => 'ExtendedXMP',
        Condition => '$$valPt =~ m{^http://ns.adobe.com/xmp/extension/\0}',
        SubDirectory => { TagTable => 'Image::ExifTool::XMP::Main' },
      }, {
        Name => 'XMP',
        Condition => '$$valPt =~ /^http/ or $$valPt =~ /<exif:/',
        SubDirectory => { TagTable => 'Image::ExifTool::XMP::Main' },
      }, {
        Name => 'QVCI',
        Condition => '$$valPt =~ /^QVCI\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::Casio::QVCI' },
      }, {
        Name => 'FLIR',
        Condition => '$$valPt =~ /^FLIR\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::FLIR::APP1' },
    }],
    APP2 => [{
        Name => 'ICC_Profile',
        Condition => '$$valPt =~ /^ICC_PROFILE\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::ICC_Profile::Main' },
      }, {
        Name => 'FPXR',
        Condition => '$$valPt =~ /^FPXR\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::FlashPix::Main' },
      }, {
        Name => 'MPF',
        Condition => '$$valPt =~ /^MPF\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::MPF::Main' },
      }, {
        Name => 'PreviewImage',
        Condition => '$$valPt =~ /^(|QVGA\0|BGTH)\xff\xd8\xff\xdb/',
        Notes => 'Samsung APP2 preview image', # (Samsung="", BenQ="QVGA\0", Digilife="BGTH")
    }],
    APP3 => [{
        Name => 'Meta',
        Condition => '$$valPt =~ /^(Meta|META|Exif)\0\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::Kodak::Meta' },
      }, {
        Name => 'Stim',
        Condition => '$$valPt =~ /^Stim\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::Stim::Main' },
      }, {
        Name => 'PreviewImage', # (written by HP R837 and Samsung S1060)
        Condition => '$$valPt =~ /^\xff\xd8\xff\xdb/',
        Notes => 'Samsung/HP preview image', # (Samsung, HP, BenQ)
    }],
    APP4 => [{
        Name => 'Scalado',
        Condition => '$$valPt =~ /^SCALADO\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::Scalado' },
      }, {
        Name => 'FPXR', # (non-standard location written by some HP models)
        Condition => '$$valPt =~ /^FPXR\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::FlashPix::Main' },
      }, {
        Name => 'PreviewImage', # (ie. Samsung S1060)
        Notes => 'continued from APP3',
    }],
    APP5 => [{
        Name => 'RMETA',
        Condition => '$$valPt =~ /^RMETA\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::Ricoh::RMETA' },
      }, {
        Name => 'PreviewImage', # (ie. BenQ DC E1050)
        Notes => 'continued from APP4',
    }],
    APP6 => [{
        Name => 'EPPIM',
        Condition => '$$valPt =~ /^EPPIM\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::EPPIM' },
      }, {
        Name => 'NITF',
        Condition => '$$valPt =~ /^NTIF\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::NITF' },
      }, {
        Name => 'HP_TDHD', # (written by R837)
        Condition => '$$valPt =~ /^TDHD\x01\0\0\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::HP::TDHD' },
    }],
    APP7 => {
        Name => 'Qualcomm',
        Condition => '$$valPt =~ /^\x1aQualcomm Camera Attributes/',
        SubDirectory => { TagTable => 'Image::ExifTool::Qualcomm::Main' },
    },
    APP8 => {
        Name => 'SPIFF',
        Condition => '$$valPt =~ /^SPIFF\0/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::SPIFF' },
    },
    APP10 => {
        Name => 'Comment',
        Condition => '$$valPt =~ /^UNICODE\0/',
        Notes => 'PhotoStudio Unicode comment',
    },
    APP12 => [{
        Name => 'PictureInfo',
        Condition => '$$valPt =~ /(\[picture info\]|Type=)/',
        SubDirectory => { TagTable => 'Image::ExifTool::APP12::PictureInfo' },
      }, {
        Name => 'Ducky',
        Condition => '$$valPt =~ /^Ducky/',
        SubDirectory => { TagTable => 'Image::ExifTool::APP12::Ducky' },
    }],
    APP13 => [{
        Name => 'Photoshop',
        Condition => '$$valPt =~ /^(Photoshop 3.0\0|Adobe_Photoshop2.5)/',
        SubDirectory => { TagTable => 'Image::ExifTool::Photoshop::Main' },
    }, {
        Name => 'Adobe_CM',
        Condition => '$$valPt =~ /^Adobe_CM/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::AdobeCM' },
    }],
    APP14 => {
        Name => 'Adobe',
        Condition => '$$valPt =~ /^Adobe/',
        Writable => 1,  # (for docs only)
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::Adobe' },
    },
    APP15 => {
        Name => 'GraphicConverter',
        Condition => '$$valPt =~ /^Q\s*(\d+)/',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::GraphConv' },
    },
    # APP15 - Also unknown "TEXT\0" segment stored by Casio/FujiFilm
    COM => {
        Name => 'Comment',
        # note: flag as writable for documentation, but it won't show up
        # in the TagLookup as writable because there is no WRITE_PROC
        Writable => 1,
    },
    SOF => {
        Name => 'StartOfFrame',
        SubDirectory => { TagTable => 'Image::ExifTool::JPEG::SOF' },
    },
    DQT => {
        Name => 'DefineQuantizationTable',
        Notes => 'used to calculate the Extra:JPEGDigest tag value',
    },
    Trailer => [{
        Name => 'AFCP',
        Condition => '$$valPt =~ /AXS(!|\*).{8}$/s',
        SubDirectory => { TagTable => 'Image::ExifTool::AFCP::Main' },
      }, {
        Name => 'CanonVRD',
        Condition => '$$valPt =~ /CANON OPTIONAL DATA\0.{44}$/s',
        SubDirectory => { TagTable => 'Image::ExifTool::CanonVRD::Main' },
      }, {
        Name => 'FotoStation',
        Condition => '$$valPt =~ /\xa1\xb2\xc3\xd4$/',
        SubDirectory => { TagTable => 'Image::ExifTool::FotoStation::Main' },
      }, {
        Name => 'PhotoMechanic',
        Condition => '$$valPt =~ /cbipcbbl$/',
        SubDirectory => { TagTable => 'Image::ExifTool::PhotoMechanic::Main' },
      }, {
        Name => 'MIE',
        Condition => q{
            $$valPt =~ /~\0\x04\0zmie~\0\0\x06.{4}[\x10\x18]\x04$/s or
            $$valPt =~ /~\0\x04\0zmie~\0\0\x0a.{8}[\x10\x18]\x08$/s
        },
        SubDirectory => { TagTable => 'Image::ExifTool::MIE::Main' },
      }, {
        Name => 'PreviewImage',
        Condition => '$$valPt =~ /^\xff\xd8\xff/',
        Writable => 1,  # (for docs only)
    }],
);

# EPPIM APP6 (Toshiba PrintIM) segment (ref PH, from PDR-M700 samples)
%Image::ExifTool::JPEG::EPPIM = (
    GROUPS => { 0 => 'APP6', 1 => 'EPPIM', 2 => 'Image' },
    NOTES => q{
        APP6 is used in by the Toshiba PDR-M700 to store a TIFF structure containing
        PrintIM information.
    },
    0xc4a5 => {
        Name => 'PrintIM',
        # must set Writable here so this tag will be saved with MakerNotes option
        Writable => 'undef',
        Description => 'Print Image Matching',
        SubDirectory => {
            TagTable => 'Image::ExifTool::PrintIM::Main',
        },
    },
);

# SPIFF APP8 segment.  Refs:
# 1) http://www.fileformat.info/format/spiff/
# 2) http://www.jpeg.org/public/spiff.pdf
%Image::ExifTool::JPEG::SPIFF = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'APP8', 1 => 'SPIFF', 2 => 'Image' },
    NOTES => q{
        This information is found in APP8 of SPIFF-style JPEG images (the "official"
        yet rarely used JPEG file format standard: Still Picture Interchange File
        Format).  See L<http://www.jpeg.org/public/spiff.pdf> for the official
        specification.
    },
    0 => {
        Name => 'SPIFFVersion',
        Format => 'int8u[2]',
        PrintConv => '$val =~ tr/ /./; $val',
    },
    2 => {
        Name => 'ProfileID',
        PrintConv => {
            0 => 'Not Specified',
            1 => 'Continuous-tone Base',
            2 => 'Continuous-tone Progressive',
            3 => 'Bi-level Facsimile',
            4 => 'Continuous-tone Facsimile',
        },
    },
    3 => 'ColorComponents',
    6 => {
        Name => 'ImageHeight',
        Notes => q{
            at index 4 in specification, but there are 2 extra bytes here in my only
            SPIFF sample, version 1.2
        },
        Format => 'int32u',
    },
    10 => {
        Name => 'ImageWidth',
        Format => 'int32u',
    },
    14 => {
        Name => 'ColorSpace',
        PrintConv => {
            0 => 'Bi-level',
            1 => 'YCbCr, ITU-R BT 709, video',
            2 => 'No color space specified',
            3 => 'YCbCr, ITU-R BT 601-1, RGB',
            4 => 'YCbCr, ITU-R BT 601-1, video',
            8 => 'Gray-scale',
            9 => 'PhotoYCC',
            10 => 'RGB',
            11 => 'CMY',
            12 => 'CMYK',
            13 => 'YCCK',
            14 => 'CIELab',
        },
    },
    15 => 'BitsPerSample',
    16 => {
        Name => 'Compression',
        PrintConv => {
            0 => 'Uncompressed, interleaved, 8 bits per sample',
            1 => 'Modified Huffman',
            2 => 'Modified READ',
            3 => 'Modified Modified READ',
            4 => 'JBIG',
            5 => 'JPEG',
        },
    },
    17 => {
        Name => 'ResolutionUnit',
        PrintConv => {
            0 => 'None',
            1 => 'inches',
            2 => 'cm',
        },
    },
    18 => {
        Name => 'YResolution',
        Format => 'int32u',
    },
    22 => {
        Name => 'XResolution',
        Format => 'int32u',
    },
);

# AdobeCM APP13 (no references)
%Image::ExifTool::JPEG::AdobeCM = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'APP13', 1 => 'AdobeCM', 2 => 'Image' },
    NOTES => q{
        The "Adobe_CM" APP13 segment presumably contains color management
        information, but the meaning of the data is currently unknown.  If anyone
        has an idea about what this means, please let me know.
    },
    FORMAT => 'int16u',
    0 => 'AdobeCMType',
);

# Adobe APP14 refs:
# http://partners.adobe.com/public/developer/en/ps/sdk/5116.DCT_Filter.pdf
# http://java.sun.com/j2se/1.5.0/docs/api/javax/imageio/metadata/doc-files/jpeg_metadata.html#color
%Image::ExifTool::JPEG::Adobe = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'APP14', 1 => 'Adobe', 2 => 'Image' },
    NOTES => q{
        The "Adobe" APP14 segment stores image encoding information for DCT filters.
        This segment may be copied or deleted as a block using the Extra "Adobe"
        tag, but note that it is not deleted by default when deleting all metadata
        because it may affect the appearance of the image.
    },
    FORMAT => 'int16u',
    0 => 'DCTEncodeVersion',
    1 => {
        Name => 'APP14Flags0',
        PrintConv => { BITMASK => {
            15 => 'Encoded with Blend=1 downsampling'
        } },
    },
    2 => {
        Name => 'APP14Flags1',
        PrintConv => { BITMASK => { } },
    },
    3 => {
        Name => 'ColorTransform',
        Format => 'int8u',
        PrintConv => {
            0 => 'Unknown (RGB or CMYK)',
            1 => 'YCbCr',
            2 => 'YCCK',
        },
    },
);

# GraphicConverter APP15 (ref PH)
%Image::ExifTool::JPEG::GraphConv = (
    GROUPS => { 0 => 'APP15', 1 => 'GraphConv', 2 => 'Image' },
    NOTES => 'APP15 is used by GraphicConverter to store JPEG quality.',
    'Q' => 'Quality',
);

# AVI1 APP0 segment (ref http://www.schnarff.com/file-formats/bmp/BMPDIB.TXT)
%Image::ExifTool::JPEG::AVI1 = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'APP0', 1 => 'AVI1', 2 => 'Image' },
    NOTES => 'This information may be found in APP0 of JPEG image data from AVI videos.',
    FIRST_ENTRY => 0,
    0 => {
        Name => 'InterleavedField',
        PrintConv => {
            0 => 'Not Interleaved',
            1 => 'Odd',
            2 => 'Even',
        },
    },    
);

# Ocad APP0 segment (ref PH)
%Image::ExifTool::JPEG::Ocad = (
    PROCESS_PROC => \&ProcessOcad,
    GROUPS => { 0 => 'APP0', 1 => 'Ocad', 2 => 'Image' },
    FIRST_ENTRY => 0,
    NOTES => q{
        Tags extracted from the JPEG APP0 "Ocad" segment (found in Photobucket
        images).
    },
    Rev => {
        Name => 'OcadRevision',
        Format => 'string[6]',
    }
);

# NITF APP6 segment (National Imagery Transmission Format)
# ref http://www.gwg.nga.mil/ntb/baseline/docs/n010697/bwcguide25aug98.pdf
%Image::ExifTool::JPEG::NITF = (
    PROCESS_PROC => \&Image::ExifTool::ProcessBinaryData,
    GROUPS => { 0 => 'APP6', 1 => 'NITF', 2 => 'Image' },
    NOTES => q{
        Information in APP6 used by the National Imagery Transmission Format.  See
        L<http://www.gwg.nga.mil/ntb/baseline/docs/n010697/bwcguide25aug98.pdf> for
        the official specification.
    },
    0 => {
        Name => 'NITFVersion',
        Format => 'int8u[2]',
        ValueConv => 'sprintf("%d.%.2d", split(" ",$val))',
    },
    2 => {
        Name => 'ImageFormat',
        ValueConv => 'chr($val)',
        PrintConv => { B => 'IMode B' },
    },
    3 => {
        Name => 'BlocksPerRow',
        Format => 'int16u',
    },
    5 => {
        Name => 'BlocksPerColumn',
        Format => 'int16u',
    },
    7 => {
        Name => 'ImageColor',
        PrintConv => { 0 => 'Monochrome' },
    },
    8 => 'BitDepth',
    9 => {
        Name => 'ImageClass',
        PrintConv => {
            0 => 'General Purpose',
            4 => 'Tactical Imagery',
        },
    },
    10 => {
        Name => 'JPEGProcess',
        PrintConv => {
            1 => 'Baseline sequential DCT, Huffman coding, 8-bit samples',
            4 => 'Extended sequential DCT, Huffman coding, 12-bit samples',
        },
    },
    11 => 'Quality',
    12 => {
        Name => 'StreamColor',
        PrintConv => { 0 => 'Monochrome' },
    },
    13 => 'StreamBitDepth',
    14 => {
        Name => 'Flags',
        Format => 'int32u',
        PrintConv => 'sprintf("0x%x", $val)',
    },
);

# information written by Scalado software (PhotoFusion maybe?)
%Image::ExifTool::JPEG::Scalado = (
    GROUPS => { 0 => 'APP4', 1 => 'Scalado', 2 => 'Image' },
    PROCESS_PROC => \&ProcessScalado,
    TAG_PREFIX => 'Scalado',
    FORMAT => 'int32s',
    # I presume this was written by 
    NOTES => q{
        Tags extracted from the JPEG APP4 "SCALADO" segment (presumably written by
        Scalado mobile software, L<http://www.scalado.com/>).
    },
    SPMO => {
        Name => 'DataLength',
        Unkown => 1,
    },
    WDTH => {
        Name => 'PreviewImageWidth',
        ValueConv => '$val ? abs($val) : undef',
    },
    HGHT => {
        Name => 'PreviewImageHeight',
        ValueConv => '$val ? abs($val) : undef',
    },
    QUAL => {
        Name => 'PreviewQuality',
        ValueConv => '$val ? abs($val) : undef',
    },
    # tags not yet decoded with observed values:
    # CHKH: 0, -9010
    # CHKL: -2664, -12852
    # CLEN: -1024
    # CSPC: -2232593
    # DATA: (+ve data length)
    # HDEC: 0
    # MAIN: 0
    # SCI0: (+ve data length)
    # SCX1: (+ve data length)
    # WDEC: 0
);

#------------------------------------------------------------------------------
# Extract information from the JPEG APP0 Ocad segment
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessOcad($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    $exifTool->VerboseDir('APP0 Ocad', undef, length $$dataPt);
    for (;;) {
        last unless $$dataPt =~ /\$(\w+):([^\0\$]+)/g;
        my ($tag, $val) = ($1, $2);
        $val =~ s/^\s+//; $val =~ s/\s+$//;     # remove leading/trailing spaces
        unless ($$tagTablePtr{$tag}) {
            AddTagToTable($tagTablePtr, $tag, { Name => "Ocad_$tag" });
        }
        $exifTool->HandleTag($tagTablePtr, $tag, $val);
    }
    return 1;
}

#------------------------------------------------------------------------------
# Extract information from the JPEG APP4 SCALADO segment
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessScalado($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $pos = 0;
    my $end = length $$dataPt;
    SetByteOrder('MM');
    $exifTool->VerboseDir('APP4 SCALADO', undef, $end);
    for (;;) {
        last if $pos + 12 > $end;
        my $tag = substr($$dataPt, $pos, 4);
        my $unk = Get32u($dataPt, $pos + 4); # (what is this?)
        $exifTool->HandleTag($tagTablePtr, $tag, undef,
            DataPt  => $dataPt,
            Start   => $pos + 8,
            Size    => 4,
            Extra   => ", unk $unk",
        );
        # shorten directory size by length of SPMO
        $end -= Get32u($dataPt, $pos + 8) if $tag eq 'SPMO';
        $pos += 12;
    }
    return 1;
}

1;  # end

__END__

=head1 NAME

Image::ExifTool::JPEG - Definitions for uncommon JPEG segments

=head1 SYNOPSIS

This module is used by Image::ExifTool

=head1 DESCRIPTION

This module contains definitions required by Image::ExifTool for some
uncommon JPEG segments.  For speed reasons, definitions for more common JPEG
segments are included in the Image::ExifTool module itself.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<Image::ExifTool::TagNames/JPEG Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut

