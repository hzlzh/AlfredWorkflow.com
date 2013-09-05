#------------------------------------------------------------------------------
# File:         DNG.pm
#
# Description:  Read DNG-specific information
#
# Revisions:    01/09/2006 - P. Harvey Created
#
# References:   1) http://www.adobe.com/products/dng/
#------------------------------------------------------------------------------

package Image::ExifTool::DNG;

use strict;
use vars qw($VERSION);
use Image::ExifTool qw(:DataAccess :Utils);
use Image::ExifTool::Exif;
use Image::ExifTool::MakerNotes;
use Image::ExifTool::CanonRaw;

$VERSION = '1.19';

sub ProcessOriginalRaw($$$);
sub ProcessAdobeData($$$);
sub ProcessAdobeMakN($$$);
sub ProcessAdobeCRW($$$);
sub ProcessAdobeRAF($$$);
sub ProcessAdobeMRW($$$);
sub ProcessAdobeSR2($$$);
sub ProcessAdobeIFD($$$);
sub WriteAdobeStuff($$$);

# data in OriginalRawFileData
%Image::ExifTool::DNG::OriginalRaw = (
    GROUPS => { 2 => 'Image' },
    PROCESS_PROC => \&ProcessOriginalRaw,
    NOTES => q{
        This table defines tags extracted from the DNG OriginalRawFileData
        information.
    },
    0 => { Name => 'OriginalRawImage',    Binary => 1 },
    1 => { Name => 'OriginalRawResource', Binary => 1 },
    2 => 'OriginalRawFileType',
    3 => 'OriginalRawCreator',
    4 => { Name => 'OriginalTHMImage',    Binary => 1 },
    5 => { Name => 'OriginalTHMResource', Binary => 1 },
    6 => 'OriginalTHMFileType',
    7 => 'OriginalTHMCreator',
);

%Image::ExifTool::DNG::AdobeData = ( #PH
    GROUPS => { 0 => 'MakerNotes', 1 => 'AdobeDNG', 2 => 'Image' },
    PROCESS_PROC => \&ProcessAdobeData,
    WRITE_PROC => \&WriteAdobeStuff,
    NOTES => q{
        This information is found in the "Adobe" DNGPrivateData.

        The maker notes ('MakN') are processed by ExifTool, but some information may
        have been lost by the Adobe DNG Converter.  This is because the Adobe DNG
        Converter (as of version 6.3) doesn't properly handle information referenced
        from inside the maker notes that lies outside the original maker notes
        block.  This information is lost when only the maker note block is copied to
        the DNG image.   While this doesn't effect all makes of cameras, it is a
        problem for some major brands such as Olympus and Sony.

        Other entries in this table represent proprietary information that is
        extracted from the original RAW image and restructured to a different (but
        still proprietary) Adobe format.
    },
    MakN  => [ ],   # (filled in later)
   'CRW ' => {
        Name => 'AdobeCRW',
        SubDirectory => {
            TagTable => 'Image::ExifTool::CanonRaw::Main',
            ProcessProc => \&ProcessAdobeCRW,
            WriteProc => \&WriteAdobeStuff,
        },
    },
   'MRW ' => {
        Name => 'AdobeMRW',
        SubDirectory => {
            TagTable => 'Image::ExifTool::MinoltaRaw::Main',
            ProcessProc => \&ProcessAdobeMRW,
            WriteProc => \&WriteAdobeStuff,
        },
    },
   'SR2 ' => {
        Name => 'AdobeSR2',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Sony::SR2Private',
            ProcessProc => \&ProcessAdobeSR2,
        },
    },
   'RAF ' => {
        Name => 'AdobeRAF',
        SubDirectory => {
            TagTable => 'Image::ExifTool::FujiFilm::RAF',
            ProcessProc => \&ProcessAdobeRAF,
        },
    },
    'Pano' => {
        Name => 'AdobePano',
        SubDirectory => {
            TagTable => 'Image::ExifTool::PanasonicRaw::Main',
            ProcessProc => \&ProcessAdobeIFD,
        },
    },
    'Koda' => {
        Name => 'AdobeKoda',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Kodak::IFD',
            ProcessProc => \&ProcessAdobeIFD,
        },
    },
    'Leaf' => {
        Name => 'AdobeLeaf',
        SubDirectory => {
            TagTable => 'Image::ExifTool::Leaf::SubIFD',
            ProcessProc => \&ProcessAdobeIFD,
        },
    },
);

# fill in maker notes
{
    my $tagInfo;
    my $list = $Image::ExifTool::DNG::AdobeData{MakN};
    foreach $tagInfo (@Image::ExifTool::MakerNotes::Main) {
        unless (ref $tagInfo eq 'HASH') {
            push @$list, $tagInfo;
            next;
        }
        my %copy = %$tagInfo;
        delete $copy{Groups};
        delete $copy{GotGroups};
        delete $copy{Table};
        push @$list, \%copy;
    }
}

#------------------------------------------------------------------------------
# Process DNG OriginalRawFileData information
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
sub ProcessOriginalRaw($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart};
    my $end = $start + $$dirInfo{DirLen};
    my $pos = $start;
    my ($index, $err);

    SetByteOrder('MM'); # pointers are always big-endian in this structure
    for ($index=0; $index<8; ++$index) {
        last if $pos + 4 > $end;
        my $val = Get32u($dataPt, $pos);
        $val or $pos += 4, next; # ignore zero values
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $index);
        $tagInfo or $err = "Missing DNG tag $index", last;
        if ($index & 0x02) {
            # extract a simple file type (tags 2, 3, 6 and 7)
            $val = substr($$dataPt, $pos, 4);
            $pos += 4;
        } else {
            # extract a compressed data block (tags 0, 1, 4 and 5)
            my $n = int(($val + 65535) / 65536);
            my $hdrLen = 4 * ($n + 2);
            $pos + $hdrLen > $end and $err = '', last;
            my $tag = $$tagInfo{Name};
            # only extract this information if requested (because it takes time)
            my $lcTag = lc $tag;
            if (($exifTool->{OPTIONS}{Binary} and not $exifTool->{EXCL_TAG_LOOKUP}{$lcTag}) or
                $exifTool->{REQ_TAG_LOOKUP}{$lcTag})
            {
                unless (eval 'require Compress::Zlib') {
                    $err = 'Install Compress::Zlib to extract compressed images';
                    last;
                }
                my $i;
                $val = '';
                my $p2 = $pos + Get32u($dataPt, $pos + 4);
                for ($i=0; $i<$n; ++$i) {
                    # inflate this compressed block
                    my $p1 = $p2;
                    $p2 = $pos + Get32u($dataPt, $pos + ($i + 2) * 4);
                    if ($p1 >= $p2 or $p2 > $end) {
                        $err = 'Bad compressed RAW image';
                        last;
                    }
                    my $buff = substr($$dataPt, $p1, $p2 - $p1);
                    my ($v2, $stat);
                    my $inflate = Compress::Zlib::inflateInit();
                    $inflate and ($v2, $stat) = $inflate->inflate($buff);
                    if ($inflate and $stat == Compress::Zlib::Z_STREAM_END()) {
                        $val .= $v2;
                    } else {
                        $err = 'Error inflating compressed RAW image';
                        last;
                    }
                }
                $pos = $p2;
            } else {
                $pos + $hdrLen > $end and $err = '', last;
                my $len = Get32u($dataPt, $pos + $hdrLen - 4);
                $pos + $len > $end and $err = '', last;
                $val = substr($$dataPt, $pos + $hdrLen, $len - $hdrLen);
                $val = "Binary data $len bytes";
                $pos += $len;   # skip over this block
            }
        }
        $exifTool->FoundTag($tagInfo, $val);
    }
    $exifTool->Warn($err || 'Bad OriginalRawFileData') if defined $err;
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe DNGPrivateData directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success
sub ProcessAdobeData($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dataPos = $$dirInfo{DataPos};
    my $pos = $$dirInfo{DirStart};
    my $end = $$dirInfo{DirLen} + $pos;
    my $outfile = $$dirInfo{OutFile};
    my $verbose = $exifTool->Options('Verbose');
    my $htmlDump = $exifTool->Options('HtmlDump');

    return 0 unless $$dataPt =~ /^Adobe\0/;
    unless ($outfile) {
        $exifTool->VerboseDir($dirInfo);
        # don't parse makernotes if FastScan > 1
        my $fast = $exifTool->Options('FastScan');
        return 1 if $fast and $fast > 1;
    }
    $htmlDump and $exifTool->HDump($dataPos, 6, 'Adobe DNGPrivateData header');
    SetByteOrder('MM'); # always big endian
    $pos += 6;
    while ($pos + 8 <= $end) {
        my ($tag, $size) = unpack("x${pos}a4N", $$dataPt);
        $pos += 8;
        last if $pos + $size > $end;
        my $tagInfo = $$tagTablePtr{$tag};
        if ($htmlDump) {
            my $name = "Adobe$tag";
            $name =~ tr/ //d;
            $exifTool->HDump($dataPos + $pos - 8, 8, "$name header", "Data Size: $size bytes");
            # dump non-EXIF format data
            unless ($tag =~ /^(MakN|SR2 )$/) {
                $exifTool->HDump($dataPos + $pos, $size, "$name data");
            }
        }
        if ($verbose and not $outfile) {
            $tagInfo or $exifTool->VPrint(0, "$$exifTool{INDENT}Unsupported DNGAdobeData record: ($tag)\n");
            $exifTool->VerboseInfo($tag,
                ref $tagInfo eq 'HASH' ? $tagInfo : undef,
                DataPt => $dataPt,
                DataPos => $dataPos,
                Start => $pos,
                Size => $size,
            );
        }
        my $value;
        while ($tagInfo) {
            my ($subTable, $subName, $processProc);
            if (ref $tagInfo eq 'HASH') {
                unless ($$tagInfo{SubDirectory}) {
                    if ($outfile) {
                        # copy value across to outfile
                        $value = substr($$dataPt, $pos, $size);
                    } else {
                        $exifTool->HandleTag($tagTablePtr, $tag, substr($$dataPt, $pos, $size));
                    }
                    last;
                }
                $subTable = GetTagTable($tagInfo->{SubDirectory}->{TagTable});
                $subName = $$tagInfo{Name};
                $processProc = $tagInfo->{SubDirectory}->{ProcessProc};
            } else {
                $subTable = $tagTablePtr;
                $subName = 'AdobeMakN';
                $processProc = \&ProcessAdobeMakN;
            }
            my %dirInfo = (
                Base     => $$dirInfo{Base},
                DataPt   => $dataPt,
                DataPos  => $dataPos,
                DataLen  => $$dirInfo{DataLen},
                DirStart => $pos,
                DirLen   => $size,
                DirName  => $subName,
            );
            if ($outfile) {
                $dirInfo{Proc} = $processProc;  # WriteAdobeStuff() calls this to do the actual writing
                $value = $exifTool->WriteDirectory(\%dirInfo, $subTable, \&WriteAdobeStuff);
                # use old directory if an error occurred
                defined $value or $value = substr($$dataPt, $pos, $size);
            } else {
                # override process proc for MakN
                $exifTool->ProcessDirectory(\%dirInfo, $subTable, $processProc);
            }
            last;
        }
        if (defined $value and length $value) {
            # add "Adobe" header if necessary
            $$outfile = "Adobe\0" unless $$outfile and length $$outfile;
            $$outfile .= $tag . pack('N', length $value) . $value;
            $$outfile .= "\0" if length($value) & 0x01; # pad if necessary
        }
        $pos += $size;
        ++$pos if $size & 0x01; # (darn padding)
    }
    $pos == $end or $exifTool->Warn("$pos $end Adobe private data is corrupt");
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe CRW directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
# Notes: data has 4 byte header (2 for byte order and 2 for entry count)
# - this routine would be as simple as ProcessAdobeMRW() below if Adobe hadn't
#   pulled the bonehead move of reformatting the CRW information
sub ProcessAdobeCRW($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart};
    my $end = $start + $$dirInfo{DirLen};
    my $verbose = $exifTool->Options('Verbose');
    my $buildMakerNotes = $exifTool->Options('MakerNotes');
    my $outfile = $$dirInfo{OutFile};
    my ($newTags, $oldChanged);

    SetByteOrder('MM'); # always big endian
    return 0 if $$dirInfo{DirLen} < 4;
    my $byteOrder = substr($$dataPt, $start, 2);
    return 0 unless $byteOrder =~ /^(II|MM)$/;

    # initialize maker note data if building maker notes
    $buildMakerNotes and Image::ExifTool::CanonRaw::InitMakerNotes($exifTool);

    my $entries = Get16u($dataPt, $start + 2);
    my $pos = $start + 4;
    $exifTool->VerboseDir($dirInfo, $entries) unless $outfile;
    if ($outfile) {
        # get hash of new tags
        $newTags = $exifTool->GetNewTagInfoHash($tagTablePtr);
        $$outfile = substr($$dataPt, $start, 4);
        $oldChanged = $exifTool->{CHANGED};
    }
    # loop through entries in Adobe CRW information
    my $index;
    for ($index=0; $index<$entries; ++$index) {
        last if $pos + 6 > $end;
        my $tag = Get16u($dataPt, $pos);
        my $size = Get32u($dataPt, $pos + 2);
        $pos += 6;
        last if $pos + $size > $end;
        my $value = substr($$dataPt, $pos, $size);
        my $tagID = $tag & 0x3fff;
        my $tagType = ($tag >> 8) & 0x38;   # get tag type
        my $format = $Image::ExifTool::CanonRaw::crwTagFormat{$tagType};
        my $count;
        my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, $tagID, \$value);
        if ($tagInfo) {
            $format = $$tagInfo{Format} if $$tagInfo{Format};
            $count = $$tagInfo{Count};
        }
        # set count to 1 by default for values that were in the directory entry
        if (not defined $count and $tag & 0x4000 and $format and $format ne 'string') {
            $count = 1;
        }
        # set count from tagInfo count if necessary
        if ($format and not $count) {
            # set count according to format and size
            my $fnum = $Image::ExifTool::Exif::formatNumber{$format};
            my $fsiz = $Image::ExifTool::Exif::formatSize[$fnum];
            $count = int($size / $fsiz);
        }
        $format or $format = 'undef';
        SetByteOrder($byteOrder);
        my $val = ReadValue(\$value, 0, $format, $count, $size);
        if ($outfile) {
            if ($tagInfo) {
                my $subdir = $$tagInfo{SubDirectory};
                if ($subdir and $$subdir{TagTable}) {
                    my $name = $$tagInfo{Name};
                    my $newTagTable = GetTagTable($$subdir{TagTable});
                    return 0 unless $newTagTable;
                    my $subdirStart = 0;
                    #### eval Start ()
                    $subdirStart = eval $$subdir{Start} if $$subdir{Start};
                    my $dirData = \$value;
                    my %subdirInfo = (
                        Name     => $name,
                        DataPt   => $dirData,
                        DataLen  => $size,
                        DirStart => $subdirStart,
                        DirLen   => $size - $subdirStart,
                        Parent   => $$dirInfo{DirName},
                    );
                    #### eval Validate ($dirData, $subdirStart, $size)
                    if (defined $$subdir{Validate} and not eval $$subdir{Validate}) {
                        $exifTool->Warn("Invalid $name data");
                    } else {
                        $subdir = $exifTool->WriteDirectory(\%subdirInfo, $newTagTable);
                        if (defined $subdir and length $subdir) {
                            if ($subdirStart) {
                                # add header before data directory
                                $value = substr($value, 0, $subdirStart) . $subdir;
                            } else {
                                $value = $subdir;
                            }
                        }
                    }
                } elsif ($$newTags{$tagID}) {
                    my $nvHash = $exifTool->GetNewValueHash($tagInfo);
                    if ($exifTool->IsOverwriting($nvHash, $val)) {
                        my $newVal = $exifTool->GetNewValues($nvHash);
                        my $verboseVal;
                        $verboseVal = $newVal if $verbose > 1;
                        # convert to specified format if necessary
                        if (defined $newVal and $format) {
                            $newVal = WriteValue($newVal, $format, $count);
                        }
                        if (defined $newVal) {
                            $exifTool->VerboseValue("- CanonRaw:$$tagInfo{Name}", $value);
                            $exifTool->VerboseValue("+ CanonRaw:$$tagInfo{Name}", $verboseVal);
                            $value = $newVal;
                            ++$exifTool->{CHANGED};
                        }
                    }
                }
            }
            # write out new value (always big-endian)
            SetByteOrder('MM');
            # (verified that there is no padding here)
            $$outfile .= Set16u($tag) . Set32u(length($value)) . $value;
        } else {
            $exifTool->HandleTag($tagTablePtr, $tagID, $val,
                Index   => $index,
                DataPt  => $dataPt,
                DataPos => $$dirInfo{DataPos},
                Start   => $pos,
                Size    => $size,
                TagInfo => $tagInfo,
            );
            if ($buildMakerNotes) {
                # build maker notes information if requested
                Image::ExifTool::CanonRaw::BuildMakerNotes($exifTool, $tagID, $tagInfo,
                                                           \$value, $format, $count);
            }
        }
        # (we lost the directory structure, but the second tag 0x0805
        # should be in the ImageDescription directory)
        $exifTool->{DIR_NAME} = 'ImageDescription' if $tagID == 0x0805;
        SetByteOrder('MM');
        $pos += $size;
    }
    if ($outfile and (not defined $$outfile or $index != $entries or
        $exifTool->{CHANGED} ==  $oldChanged))
    {
        $exifTool->{CHANGED} = $oldChanged; # nothing changed
        undef $$outfile;    # rewrite old directory
    }
    if ($index != $entries) {
        $exifTool->Warn('Truncated CRW notes');
    } elsif ($pos < $end) {
        $exifTool->Warn($end-$pos . ' extra bytes at end of CRW notes');
    }
    # finish building maker notes if necessary
    if ($buildMakerNotes) {
        SetByteOrder($byteOrder);
        Image::ExifTool::CanonRaw::SaveMakerNotes($exifTool);
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe MRW directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
# Notes: data has 4 byte header (2 for byte order and 2 for entry count)
sub ProcessAdobeMRW($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $dirLen = $$dirInfo{DirLen};
    my $dirStart = $$dirInfo{DirStart};
    my $outfile = $$dirInfo{OutFile};

    # construct fake MRW file
    my $buff = "\0MRM" . pack('N', $dirLen - 4);
    # ignore leading byte order and directory count words
    $buff .= substr($$dataPt, $dirStart + 4, $dirLen - 4);
    my $raf = new File::RandomAccess(\$buff);
    my %dirInfo = ( RAF => $raf, OutFile => $outfile );
    my $rtnVal = Image::ExifTool::MinoltaRaw::ProcessMRW($exifTool, \%dirInfo);
    if ($outfile and defined $$outfile and length $$outfile) {
        # remove MRW header and add Adobe header
        $$outfile = substr($$dataPt, $dirStart, 4) . substr($$outfile, 8);
    }
    return $rtnVal;
}

#------------------------------------------------------------------------------
# Process Adobe RAF directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
sub ProcessAdobeRAF($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    return 0 if $$dirInfo{OutFile}; # (can't write this yet)
    my $dataPt = $$dirInfo{DataPt};
    my $pos = $$dirInfo{DirStart};
    my $dirEnd = $$dirInfo{DirLen} + $pos;
    my ($readIt, $warn);

    # set byte order according to first 2 bytes of Adobe RAF data
    if ($pos + 2 <= $dirEnd and SetByteOrder(substr($$dataPt, $pos, 2))) {
        $pos += 2;
    } else {
        $exifTool->Warn('Invalid DNG RAF data');
        return 0;
    }
    $exifTool->VerboseDir($dirInfo);
    # make fake RAF object for processing (same acronym, different meaning)
    my $raf = new File::RandomAccess($dataPt);
    my $num = '';
    # loop through all records in Adobe RAF data:
    # 0 - RAF table (not processed)
    # 1 - first RAF directory
    # 2 - second RAF directory (if available)
    for (;;) {
        last if $pos + 4 > $dirEnd;
        my $len = Get32u($dataPt, $pos);
        $pos += 4 + $len;   # step to next entry in Adobe RAF record
        $len or last;       # ends with an empty entry
        $readIt or $readIt = 1, next;   # ignore first entry (RAF table)
        my %dirInfo = (
            RAF      => $raf,
            DirStart => $pos - $len,
        );
        $$exifTool{SET_GROUP1} = "RAF$num";
        $exifTool->ProcessDirectory(\%dirInfo, $tagTablePtr) or $warn = 1;
        delete $$exifTool{SET_GROUP1};
        $num = ($num || 1) + 1;
    }
    $warn and $exifTool->Warn('Possibly corrupt RAF information');
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe SR2 directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
# Notes: data has 6 byte header (2 for byte order and 4 for original offset)
sub ProcessAdobeSR2($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    return 0 if $$dirInfo{OutFile}; # (can't write this yet)
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart};
    my $len = $$dirInfo{DirLen};

    return 0 if $len < 6;
    SetByteOrder('MM');
    my $originalPos = Get32u($dataPt, $start + 2);
    return 0 unless SetByteOrder(substr($$dataPt, $start, 2));

    $exifTool->VerboseDir($dirInfo);
    my $dataPos = $$dirInfo{DataPos};
    my $dirStart = $start + 6;  # pointer to maker note directory
    my $dirLen = $len - 6;

    # initialize subdirectory information
    my $fix = $dataPos + $dirStart - $originalPos;
    my %subdirInfo = (
        DirName   => 'AdobeSR2',
        Base      => $$dirInfo{Base} + $fix,
        DataPt    => $dataPt,
        DataPos   => $dataPos - $fix,
        DataLen   => $$dirInfo{DataLen},
        DirStart  => $dirStart,
        DirLen    => $dirLen,
        Parent    => $$dirInfo{DirName},
    );
    if ($exifTool->Options('HtmlDump')) {
        $exifTool->HDump($dataPos + $start, 6, 'Adobe SR2 data');
    }
    # parse the SR2 directory
    $exifTool->ProcessDirectory(\%subdirInfo, $tagTablePtr);
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe-mutilated IFD directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
# Notes: data has 2 byte header (byte order of the data)
sub ProcessAdobeIFD($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    return 0 if $$dirInfo{OutFile}; # (can't write this yet)
    my $dataPt = $$dirInfo{DataPt};
    my $pos = $$dirInfo{DirStart};
    my $dataPos = $$dirInfo{DataPos};

    return 0 if $$dirInfo{DirLen} < 4;
    my $dataOrder = substr($$dataPt, $pos, 2);
    return 0 unless SetByteOrder($dataOrder);   # validate byte order of data

    # parse the mutilated IFD.  This is similar to a TIFF IFD, except:
    # - data follows directly after Count entry in IFD
    # - byte order of IFD entires is always big-endian, but byte order of data changes
    SetByteOrder('MM');     # IFD structure is always big-endian
    my $entries = Get16u($dataPt, $pos + 2);
    $exifTool->VerboseDir($dirInfo, $entries);
    $pos += 4;

    my $end = $pos + $$dirInfo{DirLen};
    my $index;
    for ($index=0; $index<$entries; ++$index) {
        last if $pos + 8 > $end;
        SetByteOrder('MM'); # directory entries always big-endian (doh!)
        my $tagID = Get16u($dataPt, $pos);
        my $format = Get16u($dataPt, $pos+2);
        my $count = Get32u($dataPt, $pos+4);
        if ($format < 1 or $format > 13) {
            # warn unless the IFD was just padded with zeros
            $format and $exifTool->Warn(
                sprintf("Unknown format ($format) for $$dirInfo{DirName} tag 0x%x",$tagID));
            return 0; # must be corrupted
        }
        my $size = $Image::ExifTool::Exif::formatSize[$format] * $count;
        last if $pos + 8 + $size > $end;
        my $formatStr = $Image::ExifTool::Exif::formatName[$format];
        SetByteOrder($dataOrder);   # data stored in native order
        my $val = ReadValue($dataPt, $pos + 8, $formatStr, $count, $size);
        $exifTool->HandleTag($tagTablePtr, $tagID, $val,
            Index   => $index,
            DataPt  => $dataPt,
            DataPos => $dataPos,
            Start   => $pos + 8,
            Size    => $size
        );
        $pos += 8 + $size;
    }
    if ($index < $entries) {
        $exifTool->Warn("Truncated $$dirInfo{DirName} directory");
        return 0;
    }
    return 1;
}

#------------------------------------------------------------------------------
# Process Adobe MakerNotes directory
# Inputs: 0) ExifTool object ref, 1) dirInfo ref, 2) tag table ref
# Returns: 1 on success, otherwise returns 0 and sets a Warning
# Notes: data has 6 byte header (2 for byte order and 4 for original offset)
sub ProcessAdobeMakN($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    my $dataPt = $$dirInfo{DataPt};
    my $start = $$dirInfo{DirStart};
    my $len = $$dirInfo{DirLen};
    my $outfile = $$dirInfo{OutFile};

    return 0 if $len < 6;
    SetByteOrder('MM');
    my $originalPos = Get32u($dataPt, $start + 2);
    return 0 unless SetByteOrder(substr($$dataPt, $start, 2));

    $exifTool->VerboseDir($dirInfo) unless $outfile;
    my $dataPos = $$dirInfo{DataPos};
    my $dirStart = $start + 6;  # pointer to maker note directory
    my $dirLen = $len - 6;

    my $hdr = substr($$dataPt, $dirStart, $dirLen < 48 ? $dirLen : 48);
    my $tagInfo = $exifTool->GetTagInfo($tagTablePtr, 'MakN', \$hdr);
    return 0 unless $tagInfo and $$tagInfo{SubDirectory};
    my $subdir = $$tagInfo{SubDirectory};
    my $subTable = GetTagTable($$subdir{TagTable});
    # initialize subdirectory information
    my %subdirInfo = (
        DirName   => 'MakerNotes',
        Name      => $$tagInfo{Name},   # needed for maker notes verbose dump
        Base      => $$dirInfo{Base},
        DataPt    => $dataPt,
        DataPos   => $dataPos,
        DataLen   => $$dirInfo{DataLen},
        DirStart  => $dirStart,
        DirLen    => $dirLen,
        TagInfo   => $tagInfo,
        FixBase   => $$subdir{FixBase},
        EntryBased=> $$subdir{EntryBased},
        Parent    => $$dirInfo{DirName},
    );
    # look for start of maker notes IFD
    my $loc = Image::ExifTool::MakerNotes::LocateIFD($exifTool,\%subdirInfo);
    unless (defined $loc) {
        $exifTool->Warn('Maker notes could not be parsed');
        return 0;
    }
    if ($exifTool->Options('HtmlDump')) {
        $exifTool->HDump($dataPos + $start, 6, 'Adobe MakN data');
        $exifTool->HDump($dataPos + $dirStart, $loc, "$$tagInfo{Name} header") if $loc;
    }

    my $fix = 0;
    unless ($$subdir{Base}) {
        # adjust base offset for current maker note position
        $fix = $dataPos + $dirStart - $originalPos;
        $subdirInfo{Base} += $fix;
        $subdirInfo{DataPos} -= $fix;
    }
    if ($outfile) {
        # rewrite the maker notes directory
        my $fixup = $subdirInfo{Fixup} = new Image::ExifTool::Fixup;
        my $oldChanged = $$exifTool{CHANGED};
        my $buff = $exifTool->WriteDirectory(\%subdirInfo, $subTable);
        # nothing to do if error writing directory or nothing changed
        unless (defined $buff and $exifTool->{CHANGED} != $oldChanged) {
            $exifTool->{CHANGED} = $oldChanged;
            return 1;
        }
        # deleting maker notes if directory is empty
        unless (length $buff) {
            $$outfile = '';
            return 1;
        }
        # apply a one-time fixup to offsets
        if ($subdirInfo{Relative}) {
            # shift all offsets to be relative to new base
            my $baseShift = $dataPos + $dirStart + $$dirInfo{Base} - $subdirInfo{Base};
            $fixup->{Shift} += $baseShift;
        } else {
            # shift offsets to position of original maker notes
            $fixup->{Shift} += $originalPos;
        }
        # if we wrote the directory as a block the header is already included
        $loc = 0 if $subdirInfo{BlockWrite};
        $fixup->{Shift} += $loc;    # adjust for makernotes header
        $fixup->ApplyFixup(\$buff); # fix up pointer offsets
        # get copy of original Adobe header (6) and makernotes header ($loc)
        my $header = substr($$dataPt, $start, 6 + $loc);
        # add Adobe and makernotes headers to new directory
        $$outfile = $header . $buff;
    } else {
        # parse the maker notes directory
        $exifTool->ProcessDirectory(\%subdirInfo, $subTable, $$subdir{ProcessProc});
        # extract maker notes as a block if specified
        if ($exifTool->Options('MakerNotes') or
            $exifTool->{REQ_TAG_LOOKUP}{lc($$tagInfo{Name})})
        {
            my $val;
            if ($$tagInfo{MakerNotes}) {
                $subdirInfo{Base}     = $$dirInfo{Base} + $fix;
                $subdirInfo{DataPos}  = $dataPos - $fix;
                $subdirInfo{DirStart} = $dirStart;
                $subdirInfo{DirLen}   = $dirLen;
                # rebuild the maker notes to identify all offsets that require fixing up
                $val = Image::ExifTool::Exif::RebuildMakerNotes($exifTool, $subTable, \%subdirInfo);
                if (not defined $val and $dirLen > 4) {
                    $exifTool->Warn('Error rebuilding maker notes (may be corrupt)');
                }
            } else {
                # extract this directory as a block if specified
                return 1 unless $$tagInfo{Writable};
            }
            $val = substr($$dataPt, 20) unless defined $val;
            $exifTool->FoundTag($tagInfo, $val);
        }
    }
    return 1;
}

#------------------------------------------------------------------------------
# Write Adobe information (calls appropriate ProcessProc to do the actual work)
# Inputs: 0) ExifTool object ref, 1) source dirInfo ref, 2) tag table ref
# Returns: new data block (may be empty if directory is deleted) or undef on error
sub WriteAdobeStuff($$$)
{
    my ($exifTool, $dirInfo, $tagTablePtr) = @_;
    $exifTool or return 1;    # allow dummy access
    my $proc = $$dirInfo{Proc} || \&ProcessAdobeData;
    my $buff;
    $$dirInfo{OutFile} = \$buff;
    &$proc($exifTool, $dirInfo, $tagTablePtr) or undef $buff;
    return $buff;
}

1; # end

__END__

=head1 NAME

Image::ExifTool::DNG.pm - Read DNG-specific information

=head1 SYNOPSIS

This module is used by Image::ExifTool

=head1 DESCRIPTION

This module contains routines required by Image::ExifTool to process
information in DNG (Digital Negative) images.

=head1 AUTHOR

Copyright 2003-2013, Phil Harvey (phil at owl.phy.queensu.ca)

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REFERENCES

=over 4

=item L<http://www.adobe.com/products/dng/>

=back

=head1 SEE ALSO

L<Image::ExifTool::TagNames/DNG Tags>,
L<Image::ExifTool::TagNames/EXIF Tags>,
L<Image::ExifTool(3pm)|Image::ExifTool>

=cut
