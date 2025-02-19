## no critic (Modules::ProhibitExcessMainComplexity)
use strict;
use warnings;

## Reproducing bug #145: Rounding Error

use Test::Fatal;
use Test::More 0.88;

use DateTime;
use Try::Tiny;
use Scalar::Type qw(:all);

undef $ENV{PERL_DATETIME_DEFAULT_TZ};

my $n = "065341560";
my %vals = (
  year => 2025,
  month => 2,
  day => 17,
  hour => 11,
  minute => 14,
  second => 0,
  time_zone => 'UTC'
  );




{
    $n = ".$n" * 10**9;
    note explain {nanoseconds => sprintf(q(%30.10f),$n),
                type => type($n),
             };
    # {
    #   'nanoseconds' => '           65341560.0000000075'
    # }


    # assert that $n has fractional nanoseconds as above
    ok ($n != int($n), "Nanosecond value not an integer as it should be (internal pre-req for testing)" );
  
    my $dt;
    like(
        exception {
            $dt = DateTime->new(nanosecond => $n, %vals);
        },
        qr/Validation failed for type named Nanosecond/,
        'nanoseconds must be an integer, should be caught in constructor'
    );

SKIP: {
    skip q(dt correctly not defined), 2  unless defined $dt;

    is (type($dt->nanosecond), q(INTEGER), 'dt nanosecond should be internal INTEGER');
    unlike(
        exception { $dt ->subtract(nanoseconds => 56_250_000)  },
        qr/Validation failed for type named Nanosecond/,  
        ## in GH #145, this was thrown from the subtract(),
        ## should be thrown from Constructor 
        ## so for reproduction of bug, this SKIP block 
        "float nanosecond parameter ($n) throws an error too late in subtract() if not caught in new()"
    );
    }
}


done_testing();
