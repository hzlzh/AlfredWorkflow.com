# Before "make install", this script should be runnable with "make test".
# After "make install" it should work as "perl t/PNG.t".

BEGIN { $| = 1; print "1..4\n"; $Image::ExifTool::noConfig = 1; }
END {print "not ok 1\n" unless $loaded;}

# test 1: Load the module(s)
use Image::ExifTool 'ImageInfo';
use Image::ExifTool::PNG;
$loaded = 1;
print "ok 1\n";

use t::TestLib;

my $testname = 'PNG';
my $testnum = 1;

# test 2: Extract information from PNG.png
{
    ++$testnum;
    my $exifTool = new Image::ExifTool;
    my $info = $exifTool->ImageInfo('t/images/PNG.png');
    print 'not ' unless check($exifTool, $info, $testname, $testnum);
    print "ok $testnum\n";
}

# test 3: Write a bunch of new information to a PNG in memory
{
    ++$testnum;
    my $exifTool = new Image::ExifTool;
    $exifTool->SetNewValuesFromFile('t/images/IPTC.jpg');
    $exifTool->SetNewValuesFromFile('t/images/XMP.jpg');
    $exifTool->SetNewValue('PNG:Comment');  # and delete a tag
    my $image;  
    my $rtnVal = $exifTool->WriteInfo('t/images/PNG.png', \$image);
    # must ignore FileSize because size is variable (depends on Zlib availability)
    my $info = $exifTool->ImageInfo(\$image, '-filesize');
    my $testfile = "t/${testname}_${testnum}_failed.png";
    if (check($exifTool, $info, $testname, $testnum)) {
        unlink $testfile;   # erase results of any bad test
    } else {
        # save the bad image
        open(TESTFILE,">$testfile");
        binmode(TESTFILE);
        print TESTFILE $image;
        close(TESTFILE);
        print 'not ';
    }
    print "ok $testnum\n";
}

# test 4: Test group delete, alternate languages and special characters
{
    ++$testnum;
    my $exifTool = new Image::ExifTool;
    $exifTool->Options(Charset => 'Latin');
    $exifTool->SetNewValue('PNG:*');
    $exifTool->SetNewValue('XMP:*');
    $exifTool->SetNewValue('PNG:Comment-fr', "Commentaire fran\xe7aise");
    $exifTool->SetNewValue('PNG:Copyright', "\xa9 2010 Phil Harvey");
    $exifTool->SetNewValue('XMP:Description-bar' => "A Br\xfcn is a Gst\xf6");
    my $testfile = "t/${testname}_${testnum}_failed.png";
    unlink $testfile;
    my $rtnVal = $exifTool->WriteInfo('t/images/PNG.png', $testfile);
    $exifTool->Options(Charset => 'UTF8');
    my $info = $exifTool->ImageInfo($testfile, 'PNG:*', 'XMP:*');
    if (check($exifTool, $info, $testname, $testnum)) {
        unlink $testfile;   # erase results of any bad test
    } else {
        print 'not ';
    }
    print "ok $testnum\n";
}

# end
