use strict;
use warnings;

use Test::More;
use FindBin;
use Calendar::Japanese::Business;

{
    my $c = Calendar::Japanese::Business->new(
        {
            year           => 2011,
            month          => 5,
            custom_holiday => [2],
        }
    );

    # get_date_from_businessday
    {
        is( $c->get_date_from_businessday(16)->date, '2011-05-27', 'get_date_from_businessday ok' );
    }

    # get_workday_from_day
    {
        is( $c->get_workday_from_day(16), 7, 'get_workday_from_day ok' );
    }

    # get_first_date
    {
        is( $c->get_first_date->date, '2011-05-06', 'get_first_date ok' );
    }

    # get_first_workday
    {
        is( $c->get_first_workday, 1, 'get_first_workday ok' );
    }

    # get_last_date
    {
        is( $c->get_last_date->date, '2011-05-31', 'get_last_date ok' );
    }

    # get_last_workday
    {
        is( $c->get_last_workday, 18, 'get_last_workday ok' );
    }

    # dump
    {
        my $test = [
            [ 1,  0 ],  [ 2,  0 ],  [ 3,  0 ],  [ 4,  0 ],
            [ 5,  0 ],  [ 6,  1 ],  [ 7,  0 ],  [ 8,  0 ],
            [ 9,  2 ],  [ 10, 3 ],  [ 11, 4 ],  [ 12, 5 ],
            [ 13, 6 ],  [ 14, 0 ],  [ 15, 0 ],  [ 16, 7 ],
            [ 17, 8 ],  [ 18, 9 ],  [ 19, 10 ], [ 20, 11 ],
            [ 21, 0 ],  [ 22, 0 ],  [ 23, 12 ], [ 24, 13 ],
            [ 25, 14 ], [ 26, 15 ], [ 27, 16 ], [ 28, 0 ],
            [ 29, 0 ],  [ 30, 17 ], [ 31, 18 ],
        ];
        is_deeply( $c->dump, $test, 'dump ok' );
    }
}

# last test
{
    my $c = Calendar::Japanese::Business->new(
        {
            year           => 2011,
            month          => 7,
        }
    );
    # get_last_date
    {
        is( $c->get_last_date->date, '2011-07-29', 'get_last_date 2 ok' );
    }

    # get_last_workday
    {
        is( $c->get_last_workday, 20, 'get_last_workday 2 ok' );
    }
}

done_testing;
