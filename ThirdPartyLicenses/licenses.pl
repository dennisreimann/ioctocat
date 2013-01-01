#!/usr/bin/perl -w

use strict;

my $out = "../Settings.bundle/en.lproj/OtherLicenses.strings";
my $plistout =  "../Settings.bundle/OtherLicenses.plist";

system("rm -f $out");

open(my $outfh, '>', $out) or die $!;
open(my $plistfh, '>', $plistout) or die $!;

print $plistfh <<'EOD';
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>StringsTable</key>
        <string>OtherLicenses</string>
        <key>PreferenceSpecifiers</key>
        <array>
EOD
for my $i (sort glob("*.license"))
{
    my $value=`cat $i`;
    $value =~ s/\r//g;
    $value =~ s/\n/\r/g;
    $value =~ s/[ \t]+\r/\r/g;
    $value =~ s/\"/\'/g;
    my $key=$i;
    $key =~ s/\.license$//;

    my $cnt = 1;
    my $keynum = $key;
    for my $str (split /\r\r/, $value)
    {
        my $field = $cnt == 1 ? "Title" : "FooterText";
        print $plistfh <<"EOD";
                <dict>
                        <key>Type</key>
                        <string>PSGroupSpecifier</string>
                        <key>$field</key>
                        <string>$keynum</string>
                </dict>
EOD

        print $outfh "\"$keynum\" = \"$str\";\n";
        $keynum = $key.(++$cnt);
    }
}

print $plistfh <<'EOD';
        </array>
</dict>
</plist>
EOD
close($outfh);
close($plistfh);