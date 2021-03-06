#!/usr/bin/perl

# cold fusion/ws_ftp.ini password decryption/encryption.
#
# easy decription: Take the string, each hex string subtract the location in the string
#                  and convert to ascii

print "\nCOLD FUSION/WS_FTP.INI PASSWORD DECRYPTION/ENCRYPTION\n";

if ($#ARGV <= 0) {
    print "\nUsage: $0 -d [encrypted string]\n";
    print "       $0 -e [cleartext string]\n";
    exit;
}

$opt = shift || "-d";
$pw = shift || "66626E6F37696780";
               #66616C6C33646179            fall3day
            
print "\n";

if (lc($opt) eq "-d") {
    print "enc: $pw\n";
    print "clr: " . &decrypt_cfpwd . "\n";
} else {
    print "clr: $pw\n";
    print "enc: " . &encrypt_cfpwd . "\n";
}

sub decrypt_cfpwd {
    $cnt = 0;
    for ($a = 0; $a<=((length($pw)-1)/2); $a++) {
        $hexstr = hex(substr($pw, $cnt, 2))-$a;
        $decpw .= chr($hexstr);
        $cnt += 2;
    }
    
    return $decpw;
}

sub encrypt_cfpwd {
    $cnt = 0;
    for ($a = 0; $a<=(length($pw)-1); $a++) {
        $c = (ord(substr($pw, $a, 1))+$a);
        $encpw .= uc( unpack("H*", chr($c)) );
    }
    return $encpw;
}