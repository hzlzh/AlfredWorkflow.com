# Before "make install", this script should be runnable with "make test".
# After "make install" it should work as "perl t/QuickTime.t".

BEGIN { $| = 1; print "1..3\n"; $Image::ExifTool::noConfig = 1; }
END {print "not ok 1\n" unless $loaded;}

# test 1: Load the module(s)
use Image::ExifTool 'ImageInfo';
use Image::ExifTool::QuickTime;
$loaded = 1;
print "ok 1\n";

use t::TestLib;

my $testname = 'QuickTime';
my $testnum = 1;

# tests 2-3: Extract information from QuickTime.mov and QuickTime.m4a
{
    my $ext;
    foreach $ext (qw(mov m4a)) {
        ++$testnum;
        my $exifTool = new Image::ExifTool;
        my $info = $exifTool->ImageInfo("t/images/QuickTime.$ext");
        print 'not ' unless check($exifTool, $info, $testname, $testnum);
        print "ok $testnum\n";
    }
}


# end
