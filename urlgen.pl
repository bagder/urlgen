#!/usr/bin/perl

# [scheme][divider][userinfo][hostname][port number][path][query][fragment]

sub get_part
{
    my ($part, $g) = @_;
    my @a;

    if($part eq "scheme") {

        if($g) {
            # - c   url supported scheme
            # - curl unsupported sheme

            push @a, ("https",
                      "ploink");
        }
        if($g & 2) {
            # - invalid scheme (by character)
            # - invalid scheme (by length)
            # - blank scheme
            # - url-encoded scheme

            push @a, ("htt_ps",
                      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                      "",
                      "http%73");
        }
    }

    elsif($part eq "divider") {

        if($g) {
            # - one,two,three slashes

            push @a, (":/",
                      "://",
                      ":///");
        }
        if($g & 2) {

            # - only colon no slash
            # - four slashes
            # - two backslashes
            # - blank

            push @a, (":",
                      ":////",
                      ":\\\\",
                      "");
        }
    }

    elsif($part eq "userinfo") {

        if($g) {

            # - blank
            # - user + password
            # - only user
            # - URL-encoded user + URL encoded password
            # - 4k + 4k password

            push @a, ("",
                      "user:password@",
                      "user@",
                      "%75%73%65%72:%70%61%73%73%77%6f%64@",
                      ("a" x 4096) .":". ("b" x 4096)."@");
        }
        if($g & 2) {
            # - invalid letter in user
            # - invalid letter in password

            push @a, ("use\x1fr:password@",
                      "user:passwo\x1frd@");
        }

    }

    elsif($part eq "hostname") {

        if($g) {

            # - example.com
            # - URL-encoded letters in hostname
            # - räksmörgås.se
            # - IPv4 address (normal)
            # - IPv4 address with 3 numbers
            # - IPv4 address with 2 numbers
            # - IPv4 address with 1 number
            # - IPv6 address (normal)
            # - localhost
            # - IPv6 address + zoneid
            # - just five dots
            # - 4k hostname

            push @a, ("example.com",
                      "exam%70%6C%65.com",
                      "räksmörgås.se",
                      "127.0.0.1",
                      "127.0.1",
                      "127.1",
                      "12312312",
                      "[fd00:a41::50]",
                      "[::1]",
                      "[::1%252]",
                      "[::ffd02%252]",
                      ".....",
                      "c" x 4096);
        }
        if($g & 2) {
            # - invalid letter in hostname
            # - invalid IPv4 number
            # - IPv4 address with space
            # - invalid IPv6 address
            # - invalid IPv6 address + zoneid
            # - IPv6 address + invalid zoneid
            # - blank name
            # - IDN sequence evaluating to blank

            push @a, ("exam^ple.com",
                      "192.168.0.1.5",
                      "192.168.0 .1",
                      "[fd00:a41::g0]",
                      "[fd00:a41::g0%255]",
                      "[::ffd0%25]",
                      "",
                      "\xc2\xad");
        }
    }
    elsif($part eq "portnum") {

        if($g) {
            # - blank
            # - zero-padded 80
            # - normal number
            # - blank number
            push @a, ("",
                      ":080",
                      ":4567",
                      ":");

        }
        if($g & 2) {
            # - invalid number
            # - space in number
            # - space after number
            # - space before number
            # - larger than 64 bit number
            # - negative 80
            # - hex 50
            # - 4k number
            push @a, (":67000",
                      ":12 45",
                      ":80 ",
                      ": 27",
                      ":18446744073709551617", # 2^64 + 1
                      ":-80",
                      ":0x50",
                      ":".("1" x 4096));
        }
    }
    elsif($part eq "path") {

        if($g) {
            # - blank
            # - /
            # - /plain
            # - /.
            # - /one/../two/../three
            # - URL-encoded
            # - URL-encoded with /one/../two/../three
            # - with embedded space
            # - with UTF-8 bytes
            # - 4k path
            push @a, ("",
                      "/",
                      "/plain",
                      "/.",
                      "/one/../two/../three",
                      "/%70%61%73%73%77%6f%64",
                      "/one/../%70%61%73%73%77%6f%64/plus/../this",
                      "/plain/ with /spaces",
                      "/räksmörgås",
                      "/". ("d" x 4096));
        }
        if($g & 2) {
            ;
        }

    }
    elsif($part eq "query") {

        if($g) {
            # - blank
            # - normal
            # - with embedded ?-marks
            # - /one/../two/../three
            # - URL-encoded
            # - with embedded space
            # - 4k query
            push @a, ("",
                      "?search=this",
                      "?search?for??-marks",
                      "?/one/../two",
                      "?%70%61%73%73%77%6f%64",
                      "?search for life",
                      "?". ("e" x 4096));
        }
        if($g & 2) {
            ;
        }
    }
    elsif($part eq "fragment") {

        if($g) {

            # - blank
            # - normal
            # - with question-mark and @-sign
            # - /one/../two/../three
            # - with embedded space
            # - with hash signs
            # - 4k query
            push @a, ("",
                      "#section",
                      "#section?yes\@here",
                      "#/one/../two",
                      "#frag ment",
                      "#this#is#us",
                      "#".("f" x 4096));
        }
        if($g & 2) {
            ;
        }
    }
    return @a;
}

# the 8 different parts
my @parts = ("scheme",
             "divider",
             "userinfo",
             "hostname",
             "portnum",
             "path",
             "query",
             "fragment");

my $combos;

for my $p (@parts) {
    my @alts = get_part($p, 2);

    if(!$combos) {
        $combos = scalar(@alts);
    }
    else {
        $combos *= scalar(@alts);
    }
}

print "/* Combos: $combos */\n";

sub geturls
{
    my ($good) = @_;

    for(get_part("scheme", $good)) {
        my $scheme = $_;
        for(get_part("divider", $good)) {
            my $div = "$scheme$_";
            for(get_part("userinfo", $good)) {
                my $user = "$div$_";
                for(get_part("hostname", $good)) {
                    my $h = "$user$_";
                    for(get_part("portnum", $good)) {
                        my $p = "$h$_";
                        for(get_part("path", $good)) {
                            my $path = "$p$_";
                            for(get_part("query", $good)) {
                                my $qe = "$path$_";
                                for(get_part("fragment", $good)) {
                                    print "$qe$_\n";
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#geturls(1);
geturls(2);
