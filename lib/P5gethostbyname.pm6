use v6.c;
unit module P5gethostbyname:ver<0.0.1>:auth<cpan:ELIZABETH>;

use NativeCall;

my class HoStruct is repr<CStruct> {
    has Str            $.h_name;
    has CArray[Str]    $.h_aliases;
    has uint32         $.h_addrtype;
    has uint32         $.h_length;
    has CArray[uint32] $.h_addr_list;

    sub HLLizeCArray(\list) {
        my @members;
        with list -> $members {
            for ^10 {
                print "&inet_ntoa($members[$_]), ";
                with $members[$_] -> $member {
                    @members.push($member)
                }
                else {
                    last
                }
            }
        }
        @members
    }

    sub HLLizeCArrayStr(\list) {
        my @members;
        with list -> $members {
            for ^Inf {
                with $members[$_] -> $member {
                    @members.push($member)
                }
                else {
                    last
                }
            }
        }
        @members
    }

    multi method result(HoStruct:U: :$scalar) {
        $scalar ?? Nil !! ()
    }
    multi method result(HoStruct:D: :$scalar, :$addr) {
        dd $.h_name, $.h_aliases[0], $.h_addrtype; $.h_length;
        my @addr is default(Nil) = HLLizeCArray($.h_addr_list);
        $scalar
          ?? $addr
            ?? @addr[0]
            !! $.h_name
          !! ($.h_name,HLLizeCArrayStr($.h_aliases),
              $.h_addr_type,$.h_length,@addr)
    }
}

my constant AF_INET is export(:all) = 2;
my sub inet_ntoa(Int:D $ip is copy) is export(:all) {
    my @a;
    for ^4 {
        @a.push($ip +& 0xff);
        $ip = $ip +> 8;
    }
    @a.join('.')
}
my sub inet_aton(Str:D $name) is export(:all) {
    my @parts = $name.split('.');
    my $ip = 0;
    for ^4 {
        $ip = ($ip +< 8);
        $ip = $ip + (@parts[$_] +& 0xff) if @parts[$_];
    }
    $ip
}

my sub gethostbyname(Str() $name, :$scalar)
  is export(:DEFAULT:all)
{
    sub _gethostbyname(Str --> HoStruct) is native is symbol<gethostbyname> {*}
    _gethostbyname($name).result(:$scalar, :addr($scalar))
}

my int32 $type = AF_INET;
my int32 $len  = 4;
my sub gethostbyaddr(Int:D $addr, Int:D $type, :$scalar)
  is export(:DEFAULT:all)
{
    sub _gethostbyaddr(int32 is rw, int32, int32 --> HoStruct)
      is native is symbol<gethostbyaddr> {*}
    die "Address type $type not supported" unless $type == AF_INET;
    _gethostbyaddr($addr,$len,$type).result(:$scalar)
}

=begin pod

=head1 NAME

P5gethostbyname - Implement Perl 5's gethostbyname() and associated built-ins

=head1 SYNOPSIS

    use P5gethostbyname;  # exports gethostbyname, gethostbyaddr

    my $ip = gethostbyname("perl6.org", :scalar);

    say gethostbyaddr($ip, 2, :scalar);   # something akin to perl6.org

    my @result_byname = gethostbyname("perl6.org");

    my @result_byaddr = gethostbyaddr(@result_byname[4][0]); 


    use P5gethostbyname(:all); # also exports AF_INET, inet_ntoa, inet_aton

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<gethostbyname> and associated
functions of Perl 5 as closely as possible.  It exports by default:

    gethostbyname gethostbyaddr

=head1 PORTING CAVEATS

Since there's no equivalent of the Perl 5 C<Socket> module in Perl 6 yet
(this is all abstracted in C<IO::Socket> and C<IO::Socket::Async>), it felt
appropriate to also implement the most common C<Socket> logic and provide it
as additional imports:

  AF_INET    the protocol family of IPv4 addresses
  inet_aton  convert a IP number as a string to a packed integer IPv4 value
  inet_ntoa  convert a packed integer value to an IPv4 string

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5gethostbyname . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
